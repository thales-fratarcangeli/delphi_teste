# ERP Modular em Delphi + Firebird

![Delphi](https://img.shields.io/badge/Delphi-Object%20Pascal-EE1F35?logo=delphi&logoColor=white) ![Firebird](https://img.shields.io/badge/Firebird-3.0%2B-F40F02?logo=firebird&logoColor=white) ![Flutter](https://img.shields.io/badge/mobile-Flutter-02569B?logo=flutter&logoColor=white)

Projeto de estudo que reproduz a arquitetura típica de um **ERP desktop modular**
brasileiro: um launcher com login que abre módulos independentes (cada um é um
`.exe`), telas MDI, cadastros, lançamento de notas fiscais e integrações fiscais,
de pagamento e de e-mail — tudo sobre **Firebird** com **FireDAC**.

O código é propositalmente **muito comentado**: cada arquivo explica o porquê
das decisões, para servir de referência de estudo sobre os padrões que aparecem
em ERPs reais escritos em Delphi.

---

## Funcionalidades

| Área | O que tem |
|---|---|
| **Launcher** | Login validado no banco, janela de módulos no canto da tela, bloqueio por licença vencida |
| **Faturamento (MDI)** | Menu com submenus, telas filhas sem duplicação, cadastros de clientes e produtos |
| **Nota fiscal** | Lançamento mestre-detalhe com itens em `TFDMemTable` e gravação em **transação** |
| **NF-e** | Cálculo da chave de acesso (44 dígitos, módulo 11) e montagem do XML *(assinatura/envio simulados)* |
| **PDV + TEF** | Venda no caixa com interface `ITEF` (padrão Strategy) *(maquininha simulada)* |
| **E-mail** | Envio do XML via Indy (`TIdSMTP`) com TLS |
| **Relatórios** | Geração em HTML com `JOIN`s no SQL |
| **Pedidos** | Fluxo de aprovação/reprovação condicionado a permissão |
| **Privilégios** | Árvore de permissões por perfil (Administrador, Vendedor, Financeiro) que mostra/esconde menus |
| **Logs** | Um arquivo de log por tela, com hora, usuário e mensagem |
| **Telemetria** | Serviço do Windows (`TService`) que monitora o uso do ERP |
| **Jenkins** | Disparo e consulta de rotinas (fechamento diário, backup) via API REST |
| **Assistente de IA** | "Bolinha" flutuante na tela principal que conversa com a API do Claude |
| **Mobile** | App em Flutter que consome uma API REST *(API ainda não implementada)* |

## Arquitetura

O sistema é um **conjunto de executáveis**, como em ERPs modulares de mercado:

| Projeto | Executável | Papel |
|---|---|---|
| `Launcher/Launcher.dpr` | `Launcher.exe` | Login e janela de módulos |
| `Faturamento/Faturamento.dpr` | `Faturamento.exe` | Módulo MDI de faturamento |
| `Telemetria/TelemetriaService.dpr` | `TelemetriaService.exe` | Serviço do Windows |

Dentro de cada módulo, o código é separado em **camadas**: as telas são "magras"
(só coletam dados e exibem resultados) e a regra de negócio fica nos serviços em
`Comum/Servicos`.

```
TELAS (Forms)        ->  SERVIÇOS (Comum/Servicos)     ->  BANCO / APIs externas
uFrmFiscal               uServicoNFe                       SEFAZ
uFrmPDV                  uServicoTEF                       maquininha
uFrmRelatorios           uRelatorios / uServicoEmail       Firebird / SMTP
uFrmAssistenteIA         uServicoIA                        API do Claude
```

Como cada módulo é um processo separado, a sessão não é herdada: o launcher
passa `/usuario=LOGIN` na linha de comando e o módulo recarrega o usuário e as
permissões ao iniciar (`DM.InicializarSessaoModulo`).

## Estrutura de pastas

```
├── ERP.groupproj             grupo com os 3 projetos (Build All)
├── config.ini                conexão e credenciais de integrações
├── banco/                    scripts de criação e atualização do ERP.FDB
├── Comum/                    código compartilhado entre os módulos
│   ├── uDM.pas               DataModule com a conexão FireDAC
│   ├── uSessao.pas           usuário logado
│   ├── uConfig.pas           leitura do config.ini
│   ├── uLicenca.pas          checagem de licença
│   ├── uLog.pas              logs por tela
│   └── Servicos/             NF-e, TEF, e-mail, relatórios, IA, Jenkins
├── Launcher/                 login + janela de módulos
├── Faturamento/              módulo MDI (cadastros, nota fiscal, PDV, fiscal...)
├── Telemetria/               serviço do Windows
└── MobileFlutter/            app mobile em Flutter
```

## Como rodar

**Pré-requisitos:** Delphi 10.4 ou superior (Community serve; FireDAC incluso) e
Firebird Server 3.0 ou superior.

1. **Banco:** rode `banco\criar_banco.bat`. Ele cria o `ERP.FDB` e aplica os
   scripts `criar_banco.sql`, `atualizar_v2.sql` e `atualizar_v3.sql`. Antes,
   confira a pasta do Firebird na linha `set FB=...` do `.bat`.
2. **Conexão:** ajuste `Database=` e a senha do `SYSDBA` no `config.ini` e
   copie o arquivo para junto de cada `.exe` compilado.
3. **Compilação:** abra `ERP.groupproj` no Delphi → botão direito no grupo →
   **Build All Projects**.
4. **Execução:** rode o `Launcher.exe` e entre com `admin` / `123`
   (perfil Administrador) ou `joao` / `123` (perfil Vendedor) para comparar
   as permissões.

Serviço de telemetria (Prompt de Comando como administrador):

```
TelemetriaService.exe /install
net start SrvTelemetria
```

App mobile: dentro de `MobileFlutter\`, rode `flutter pub get` e `flutter run`.

## Integrações simuladas

NF-e e TEF reais exigem certificado digital ICP-Brasil, credenciais da SEFAZ e
SDKs de cada adquirente. Por isso, nesses serviços **o fluxo e a estrutura são
reais** (inclusive a chave de acesso e o XML), mas as etapas de assinatura e
envio estão marcadas no código com `>>> AQUI ENTRARIA O REAL`. Em produção, o
caminho natural é substituir essa parte pelo **ACBr**, sem alterar as telas.

Jenkins e telemetria funcionam de verdade quando apontados para servidores reais
no `config.ini`. A **API REST do app mobile** ainda não foi implementada
(candidatas: Horse, DataSnap ou RAD Server).

> As credenciais ficam em texto puro no `config.ini` apenas para estudo. Em
> produção, o correto é usar um cofre de segredos ou criptografia.

## Roteiro de leitura do código

1. `Comum/uSessao.pas` — units, `record` e variável global
2. `Launcher/Launcher.dpr` — ponto de entrada e criação de forms
3. `Launcher/uFrmLogin.pas` — `TFDQuery` com parâmetros
4. `Comum/uDM.pas` — conexão FireDAC, `.ini` e generators
5. `Faturamento/uFrmPrincipal.pas` — MDI, menus e aplicação de permissões
6. `Faturamento/uFrmNotaFiscal.pas` — mestre-detalhe e transação
7. `Comum/Servicos/uServicoTEF.pas` — interfaces e padrão Strategy
8. `Comum/Servicos/uServicoNFe.pas` — chave de acesso, XML e transação

## Próximos passos

- [ ] API REST (Horse) para o app mobile
- [ ] NF-e real com ACBr
- [ ] Baixa de estoque na venda, dentro da mesma transação
- [ ] Tela de consulta de notas lançadas
