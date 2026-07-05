/* =========================================================================
   ATUALIZAÇÃO v2 do banco - campos e tabelas para as novas funções:
   NF-e (SEFAZ), PDV/TEF (cartão), e-mail e mobile.
   Rode este script DEPOIS do criar_banco.sql, no mesmo banco ERP.FDB.
   ========================================================================= */

/* --- Campos fiscais na nota (retorno da SEFAZ) --- */
ALTER TABLE NOTAS_FISCAIS ADD CHAVE_ACESSO VARCHAR(44);
ALTER TABLE NOTAS_FISCAIS ADD PROTOCOLO    VARCHAR(20);
ALTER TABLE NOTAS_FISCAIS ADD XML_NFE      BLOB SUB_TYPE TEXT;
ALTER TABLE NOTAS_FISCAIS ADD MODELO       CHAR(2) DEFAULT '55';  /* 55=NFe 65=NFCe */
/* SITUACAO agora: A=Aberta E=Emitida(autorizada) C=Cancelada R=Rejeitada */

/* --- Vendas do PDV (ponto de venda) --- */
CREATE TABLE VENDAS_PDV (
  ID           INTEGER       NOT NULL PRIMARY KEY,
  DATA_VENDA   TIMESTAMP     NOT NULL,
  ID_CLIENTE   INTEGER,
  VALOR_TOTAL  NUMERIC(15,2) NOT NULL,
  FORMA_PGTO   VARCHAR(20),   /* DINHEIRO, DEBITO, CREDITO, PIX */
  BANDEIRA     VARCHAR(20),   /* VISA, MASTER... (retorno da maquininha) */
  NSU          VARCHAR(20),   /* comprovante do TEF/cartão */
  AUTORIZACAO  VARCHAR(20),
  ID_NOTA      INTEGER,       /* nota fiscal gerada, se houver */
  CONSTRAINT FK_PDV_CLIENTE FOREIGN KEY (ID_CLIENTE) REFERENCES CLIENTES(ID),
  CONSTRAINT FK_PDV_NOTA    FOREIGN KEY (ID_NOTA)    REFERENCES NOTAS_FISCAIS(ID)
);

CREATE GENERATOR GEN_VENDAS_PDV;

SET TERM ^ ;
CREATE TRIGGER TRG_VENDAS_PDV_BI FOR VENDAS_PDV ACTIVE BEFORE INSERT POSITION 0 AS
BEGIN
  IF (NEW.ID IS NULL) THEN NEW.ID = GEN_ID(GEN_VENDAS_PDV, 1);
END^
SET TERM ; ^

COMMIT;
