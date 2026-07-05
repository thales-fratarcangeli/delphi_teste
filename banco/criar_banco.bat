@echo off
REM ===========================================================================
REM  Cria e popula o banco ERP.FDB automaticamente.
REM
REM  ANTES DE RODAR: confirme o caminho do Firebird na variavel FB abaixo.
REM  Pastas comuns:  Firebird_3_0 , Firebird_4_0 , Firebird_5_0
REM  (olhe em "C:\Program Files\Firebird\" qual pasta existe na sua maquina)
REM ===========================================================================

set FB=C:\Program Files\Firebird\Firebird_4_0
set ISQL="%FB%\isql.exe"
set PASTA=%~dp0

echo.
echo === 1/3 Criando o arquivo ERP.FDB ===
%ISQL% -user SYSDBA -password masterkey -i "%PASTA%00_criar_database.sql"

echo.
echo === 2/3 Criando tabelas e dados iniciais ===
%ISQL% -user SYSDBA -password masterkey "C:\Users\sigma\Documents\delphi\banco\ERP.FDB" -i "%PASTA%criar_banco.sql"

echo.
echo === 3/3 Aplicando atualizacoes v2 e v3 ===
%ISQL% -user SYSDBA -password masterkey "C:\Users\sigma\Documents\delphi\banco\ERP.FDB" -i "%PASTA%atualizar_v2.sql"
%ISQL% -user SYSDBA -password masterkey "C:\Users\sigma\Documents\delphi\banco\ERP.FDB" -i "%PASTA%atualizar_v3.sql"

echo.
echo === PRONTO! O arquivo ERP.FDB foi criado em: ===
echo     C:\Users\sigma\Documents\delphi\banco\ERP.FDB
echo.
pause
