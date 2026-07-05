/* =========================================================================
   ATUALIZAÇÃO v3 - perfis/privilégios, licença (bloqueio) e pedidos.
   Rode DEPOIS de criar_banco.sql e atualizar_v2.sql, no mesmo ERP.FDB.
   ========================================================================= */

/* -------------------------------------------------------------------------
   PERFIS DE USUÁRIO (ex.: Administrador, Vendedor, Financeiro)
   ------------------------------------------------------------------------- */
CREATE TABLE PERFIS (
  ID    INTEGER      NOT NULL PRIMARY KEY,
  NOME  VARCHAR(40)  NOT NULL
);

/* -------------------------------------------------------------------------
   ÁRVORE DE PERMISSÕES.
   Cada permissão tem uma CHAVE (ex.: 'FAT.MOV.NF') e aponta para o "pai"
   (PARENT_CHAVE). Isso forma a árvore que aparece na tela de privilégios.
   ------------------------------------------------------------------------- */
CREATE TABLE PERMISSOES (
  CHAVE        VARCHAR(40)  NOT NULL PRIMARY KEY,
  PARENT_CHAVE VARCHAR(40),
  DESCRICAO    VARCHAR(80)  NOT NULL
);

/* Quais permissões cada perfil possui (relação N:N). */
CREATE TABLE PERFIL_PERMISSAO (
  ID_PERFIL       INTEGER     NOT NULL,
  CHAVE_PERMISSAO VARCHAR(40) NOT NULL,
  PRIMARY KEY (ID_PERFIL, CHAVE_PERMISSAO),
  CONSTRAINT FK_PP_PERFIL FOREIGN KEY (ID_PERFIL)       REFERENCES PERFIS(ID),
  CONSTRAINT FK_PP_PERM   FOREIGN KEY (CHAVE_PERMISSAO) REFERENCES PERMISSOES(CHAVE)
);

/* Liga cada usuário a um perfil. */
ALTER TABLE USUARIOS ADD ID_PERFIL INTEGER;

/* -------------------------------------------------------------------------
   LICENÇA / BLOQUEIO (o "boleto vencido bloqueia o sistema")
   ------------------------------------------------------------------------- */
CREATE TABLE LICENCA (
  ID               INTEGER     NOT NULL PRIMARY KEY,
  CLIENTE          VARCHAR(80),
  DATA_VENCIMENTO  DATE        NOT NULL,   /* vencimento do boleto/mensalidade */
  BLOQUEADO        CHAR(1)     DEFAULT 'N',/* 'S' força bloqueio manual */
  MENSAGEM_BLOQUEIO VARCHAR(200)
);

/* -------------------------------------------------------------------------
   PEDIDOS (para a tela de APROVAÇÃO DE PEDIDOS)
   ------------------------------------------------------------------------- */
CREATE TABLE PEDIDOS (
  ID             INTEGER       NOT NULL PRIMARY KEY,
  DATA_PEDIDO    TIMESTAMP     NOT NULL,
  ID_CLIENTE     INTEGER       NOT NULL,
  VALOR_TOTAL    NUMERIC(15,2) NOT NULL,
  STATUS         CHAR(1)       DEFAULT 'P',  /* P=Pendente A=Aprovado R=Reprovado */
  APROVADO_POR   INTEGER,                    /* id do usuário que aprovou/reprovou */
  DATA_APROVACAO TIMESTAMP,
  OBSERVACAO     VARCHAR(200),
  CONSTRAINT FK_PED_CLIENTE FOREIGN KEY (ID_CLIENTE) REFERENCES CLIENTES(ID)
);

CREATE GENERATOR GEN_PEDIDOS;
SET TERM ^ ;
CREATE TRIGGER TRG_PEDIDOS_BI FOR PEDIDOS ACTIVE BEFORE INSERT POSITION 0 AS
BEGIN
  IF (NEW.ID IS NULL) THEN NEW.ID = GEN_ID(GEN_PEDIDOS, 1);
END^
SET TERM ; ^

/* -------------------------------------------------------------------------
   DADOS INICIAIS
   ------------------------------------------------------------------------- */

/* Perfis */
INSERT INTO PERFIS (ID, NOME) VALUES (1, 'Administrador');
INSERT INTO PERFIS (ID, NOME) VALUES (2, 'Vendedor');
INSERT INTO PERFIS (ID, NOME) VALUES (3, 'Financeiro');

/* Árvore de permissões (pai primeiro, depois os filhos) */
INSERT INTO PERMISSOES VALUES ('FAT',          NULL,   'Faturamento');
INSERT INTO PERMISSOES VALUES ('FAT.CAD',      'FAT',  'Cadastros');
INSERT INTO PERMISSOES VALUES ('FAT.CAD.CLI',  'FAT.CAD', 'Clientes');
INSERT INTO PERMISSOES VALUES ('FAT.CAD.PRO',  'FAT.CAD', 'Produtos');
INSERT INTO PERMISSOES VALUES ('FAT.MOV',      'FAT',  'Movimento');
INSERT INTO PERMISSOES VALUES ('FAT.MOV.NF',   'FAT.MOV', 'Nota Fiscal');
INSERT INTO PERMISSOES VALUES ('FAT.MOV.PDV',  'FAT.MOV', 'PDV (Ponto de Venda)');
INSERT INTO PERMISSOES VALUES ('FAT.PED',      'FAT',  'Pedidos');
INSERT INTO PERMISSOES VALUES ('FAT.PED.APROVAR','FAT.PED', 'Aprovar pedidos');
INSERT INTO PERMISSOES VALUES ('FAT.FIS',      'FAT',  'Fiscal');
INSERT INTO PERMISSOES VALUES ('FAT.FIS.NFE',  'FAT.FIS', 'Painel NF-e');
INSERT INTO PERMISSOES VALUES ('FAT.FIS.CFG',  'FAT.FIS', 'Configuracao SEFAZ');
INSERT INTO PERMISSOES VALUES ('FAT.REL',      'FAT',  'Relatorios');
INSERT INTO PERMISSOES VALUES ('FAT.ADM',      'FAT',  'Administracao');
INSERT INTO PERMISSOES VALUES ('FAT.ADM.PERM', 'FAT.ADM', 'Gerenciar permissoes');
INSERT INTO PERMISSOES VALUES ('FAT.ADM.ROT',  'FAT.ADM', 'Rotinas (Jenkins)');

/* Administrador recebe TODAS as permissões (truque com SELECT) */
INSERT INTO PERFIL_PERMISSAO (ID_PERFIL, CHAVE_PERMISSAO)
  SELECT 1, CHAVE FROM PERMISSOES;

/* Vendedor: só cadastros, movimento e relatórios */
INSERT INTO PERFIL_PERMISSAO VALUES (2, 'FAT');
INSERT INTO PERFIL_PERMISSAO VALUES (2, 'FAT.CAD');
INSERT INTO PERFIL_PERMISSAO VALUES (2, 'FAT.CAD.CLI');
INSERT INTO PERFIL_PERMISSAO VALUES (2, 'FAT.CAD.PRO');
INSERT INTO PERFIL_PERMISSAO VALUES (2, 'FAT.MOV');
INSERT INTO PERFIL_PERMISSAO VALUES (2, 'FAT.MOV.NF');
INSERT INTO PERFIL_PERMISSAO VALUES (2, 'FAT.MOV.PDV');
INSERT INTO PERFIL_PERMISSAO VALUES (2, 'FAT.REL');

/* Financeiro: fiscal, pedidos (aprovar) e relatórios */
INSERT INTO PERFIL_PERMISSAO VALUES (3, 'FAT');
INSERT INTO PERFIL_PERMISSAO VALUES (3, 'FAT.FIS');
INSERT INTO PERFIL_PERMISSAO VALUES (3, 'FAT.FIS.NFE');
INSERT INTO PERFIL_PERMISSAO VALUES (3, 'FAT.PED');
INSERT INTO PERFIL_PERMISSAO VALUES (3, 'FAT.PED.APROVAR');
INSERT INTO PERFIL_PERMISSAO VALUES (3, 'FAT.REL');

/* Liga os usuários já existentes a um perfil */
UPDATE USUARIOS SET ID_PERFIL = 1 WHERE LOGIN = 'admin';
UPDATE USUARIOS SET ID_PERFIL = 2 WHERE LOGIN = 'joao';

/* Licença válida por 30 dias a partir de hoje (troque a data para testar bloqueio) */
INSERT INTO LICENCA (ID, CLIENTE, DATA_VENCIMENTO, BLOQUEADO, MENSAGEM_BLOQUEIO)
  VALUES (1, 'EMPRESA DE ESTUDO LTDA', DATEADD(30 DAY TO CURRENT_DATE), 'N',
          'Sistema bloqueado por falta de pagamento. Contate o suporte.');

/* Alguns pedidos pendentes para testar a aprovação */
INSERT INTO PEDIDOS (DATA_PEDIDO, ID_CLIENTE, VALOR_TOTAL, STATUS)
  VALUES (CURRENT_TIMESTAMP, 1, 1500.00, 'P');
INSERT INTO PEDIDOS (DATA_PEDIDO, ID_CLIENTE, VALOR_TOTAL, STATUS)
  VALUES (CURRENT_TIMESTAMP, 2, 320.50, 'P');

COMMIT;
