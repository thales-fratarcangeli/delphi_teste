/* =========================================================================
   ERP DIDÁTICO - Script de criação do banco de dados Firebird
   -------------------------------------------------------------------------
   Como usar (usando a ferramenta ISQL que vem com o Firebird):

     1) Crie o arquivo .FDB (uma vez só):
        isql -user SYSDBA -password masterkey
        SQL> CREATE DATABASE 'C:\Users\sigma\Documents\delphi\banco\ERP.FDB'
             page_size 8192 DEFAULT CHARACTER SET WIN1252;
        SQL> QUIT;

     2) Rode este script dentro do banco:
        isql -user SYSDBA -password masterkey C:\...\banco\ERP.FDB -i criar_banco.sql

   Obs.: senha padrão do Firebird instalado localmente costuma ser "masterkey".
   ========================================================================= */

/* -------------------------------------------------------------------------
   TABELAS
   ------------------------------------------------------------------------- */

CREATE TABLE USUARIOS (
  ID     INTEGER      NOT NULL PRIMARY KEY,
  LOGIN  VARCHAR(30)  NOT NULL,
  SENHA  VARCHAR(30)  NOT NULL,
  NOME   VARCHAR(60),
  ATIVO  CHAR(1)      DEFAULT 'S'
);

CREATE TABLE CLIENTES (
  ID        INTEGER      NOT NULL PRIMARY KEY,
  NOME      VARCHAR(80)  NOT NULL,
  CPF_CNPJ  VARCHAR(18),
  CIDADE    VARCHAR(60),
  UF        CHAR(2),
  TELEFONE  VARCHAR(20),
  EMAIL     VARCHAR(80)
);

CREATE TABLE PRODUTOS (
  ID           INTEGER       NOT NULL PRIMARY KEY,
  DESCRICAO    VARCHAR(80)   NOT NULL,
  UNIDADE      VARCHAR(6),
  PRECO_VENDA  NUMERIC(15,2) DEFAULT 0,
  ESTOQUE      NUMERIC(15,3) DEFAULT 0
);

CREATE TABLE NOTAS_FISCAIS (
  ID            INTEGER       NOT NULL PRIMARY KEY,
  NUMERO        INTEGER       NOT NULL,
  DATA_EMISSAO  DATE          NOT NULL,
  ID_CLIENTE    INTEGER       NOT NULL,
  VALOR_TOTAL   NUMERIC(15,2) DEFAULT 0,
  SITUACAO      CHAR(1)       DEFAULT 'A',  /* A=Aberta  F=Faturada  C=Cancelada */
  CONSTRAINT FK_NF_CLIENTE FOREIGN KEY (ID_CLIENTE) REFERENCES CLIENTES(ID)
);

CREATE TABLE ITENS_NOTA_FISCAL (
  ID           INTEGER       NOT NULL PRIMARY KEY,
  ID_NOTA      INTEGER       NOT NULL,
  ID_PRODUTO   INTEGER       NOT NULL,
  QUANTIDADE   NUMERIC(15,3) NOT NULL,
  PRECO_UNIT   NUMERIC(15,2) NOT NULL,
  VALOR_TOTAL  NUMERIC(15,2) NOT NULL,
  CONSTRAINT FK_ITEM_NOTA FOREIGN KEY (ID_NOTA)    REFERENCES NOTAS_FISCAIS(ID),
  CONSTRAINT FK_ITEM_PROD FOREIGN KEY (ID_PRODUTO) REFERENCES PRODUTOS(ID)
);

/* -------------------------------------------------------------------------
   GENERATORS (sequências) - o Firebird usa "generators" para gerar IDs.
   ------------------------------------------------------------------------- */

CREATE GENERATOR GEN_USUARIOS;
CREATE GENERATOR GEN_CLIENTES;
CREATE GENERATOR GEN_PRODUTOS;
CREATE GENERATOR GEN_NOTAS_FISCAIS;
CREATE GENERATOR GEN_ITENS_NOTA_FISCAL;

/* -------------------------------------------------------------------------
   TRIGGERS "BEFORE INSERT" - preenchem o ID automaticamente SE vier nulo.
   Assim funciona tanto deixando o banco gerar quanto o Delphi informar o ID.
   ------------------------------------------------------------------------- */

SET TERM ^ ;

CREATE TRIGGER TRG_USUARIOS_BI FOR USUARIOS ACTIVE BEFORE INSERT POSITION 0 AS
BEGIN
  IF (NEW.ID IS NULL) THEN NEW.ID = GEN_ID(GEN_USUARIOS, 1);
END^

CREATE TRIGGER TRG_CLIENTES_BI FOR CLIENTES ACTIVE BEFORE INSERT POSITION 0 AS
BEGIN
  IF (NEW.ID IS NULL) THEN NEW.ID = GEN_ID(GEN_CLIENTES, 1);
END^

CREATE TRIGGER TRG_PRODUTOS_BI FOR PRODUTOS ACTIVE BEFORE INSERT POSITION 0 AS
BEGIN
  IF (NEW.ID IS NULL) THEN NEW.ID = GEN_ID(GEN_PRODUTOS, 1);
END^

CREATE TRIGGER TRG_NF_BI FOR NOTAS_FISCAIS ACTIVE BEFORE INSERT POSITION 0 AS
BEGIN
  IF (NEW.ID IS NULL) THEN NEW.ID = GEN_ID(GEN_NOTAS_FISCAIS, 1);
END^

CREATE TRIGGER TRG_ITEM_BI FOR ITENS_NOTA_FISCAL ACTIVE BEFORE INSERT POSITION 0 AS
BEGIN
  IF (NEW.ID IS NULL) THEN NEW.ID = GEN_ID(GEN_ITENS_NOTA_FISCAL, 1);
END^

SET TERM ; ^

/* -------------------------------------------------------------------------
   DADOS INICIAIS (para o sistema já abrir com algo cadastrado)
   ------------------------------------------------------------------------- */

INSERT INTO USUARIOS (LOGIN, SENHA, NOME) VALUES ('admin', '123', 'Administrador');
INSERT INTO USUARIOS (LOGIN, SENHA, NOME) VALUES ('joao',  '123', 'João Suporte');

INSERT INTO CLIENTES (NOME, CPF_CNPJ, CIDADE, UF, TELEFONE, EMAIL)
  VALUES ('Comercial Silva LTDA', '12.345.678/0001-90', 'São Paulo', 'SP', '(11) 3333-4444', 'contato@silva.com');
INSERT INTO CLIENTES (NOME, CPF_CNPJ, CIDADE, UF, TELEFONE, EMAIL)
  VALUES ('Maria Souza ME', '98.765.432/0001-10', 'Campinas', 'SP', '(19) 2222-1111', 'maria@souza.com');

INSERT INTO PRODUTOS (DESCRICAO, UNIDADE, PRECO_VENDA, ESTOQUE)
  VALUES ('Caneta Azul', 'UN', 2.50, 1000);
INSERT INTO PRODUTOS (DESCRICAO, UNIDADE, PRECO_VENDA, ESTOQUE)
  VALUES ('Caderno 96 folhas', 'UN', 12.90, 300);
INSERT INTO PRODUTOS (DESCRICAO, UNIDADE, PRECO_VENDA, ESTOQUE)
  VALUES ('Resma de Papel A4', 'CX', 24.00, 150);

COMMIT;
