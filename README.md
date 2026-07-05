# ERP Didático em Delphi + Firebird

Projeto de estudo que **reconstrói a arquitetura de um ERP modular** parecido com o que
você descreveu, para você ler o código e aprender Delphi visando a vaga de programador
júnior. É propositalmente simples e **muito comentado** — cada arquivo explica o "porquê".

> ⚠️ Este projeto **não é o ERP da sua empresa** — é uma reconstrução dos padrões que
> você descreveu (launcher, login, módulos MDI, cadastro de notas fiscais em Firebird).
> Serve para você reconhecer esses mesmos padrões quando abrir o código real lá.

---

## 1. Como o projeto mapeia o que você descreveu

| O que você descreveu | Onde está no projeto |
|---|---|
| "Um launcher que abre uma telinha no canto com os módulos" | `Launcher/` → `uFrmModulos` (janela no canto da tela) |
| "Coloca login e senha, só depois aparecem os módulos" | `Launcher/uFrmLogin` (valida na tabela `USUARIOS`) |
| "Clica no módulo e abre a tela" | `uFrmModulos` chama `Faturamento.exe` |
| "Barra no topo com opções que abrem mais opções" | `Faturamento/uFrmPrincipal` → `TMainMenu` (menu com submenus) |
| "Tela vazia no meio, telas abrem dentro (área de trabalho)" | `uFrmPrincipal` é MDI (`FormStyle = fsMDIForm`); as telas são MDI Child |
| "Espaços onde se cadastram notas fiscais" | `Faturamento/uFrmNotaFiscal` (cabeçalho + itens) |
| "Banco Firebird (.FDB)" | `banco/criar_banco.sql` cria o `ERP.FDB` |

---

## 2. Estrutura das pastas

```
delphi/
├── README.md                 ← este guia
├── config.ini                ← dados de conexão (caminho do .FDB, usuário, senha)
├── banco/
│   └── criar_banco.sql       ← cria tabelas, generators, triggers e dados de exemplo
├── Comum/                    ← código compartilhado entre TODOS os módulos
│   ├── uSessao.pas           ← guarda o usuário logado (variável global)
│   └── uDM.pas / .dfm        ← DataModule: a conexão FireDAC com o Firebird
├── Launcher/                 ← programa 1: login + janela de módulos
│   ├── Launcher.dpr          ← arquivo do PROJETO (o "main")
│   ├── uFrmLogin.pas/.dfm    ← tela de login
│   └── uFrmModulos.pas/.dfm  ← janelinha com os botões dos módulos
└── Faturamento/              ← programa 2: módulo MDI de faturamento
    ├── Faturamento.dpr
    ├── uFrmPrincipal.pas/.dfm ← janela MDI com o menu (área de trabalho)
    ├── uFrmClientes.pas/.dfm  ← cadastro de clientes (grade)
    ├── uFrmProdutos.pas/.dfm  ← cadastro de produtos (grade)
    └── uFrmNotaFiscal.pas/.dfm← lançamento de nota fiscal (mestre-detalhe)
```

**Cada tela em Delphi são 2 arquivos que andam juntos:**
- `.pas` → o **código** (Object Pascal): a lógica, os eventos dos botões.
- `.dfm` → o **desenho** da tela (posição dos botões, campos, etc.). É o que você vê no
  Form Designer do Delphi. Dá para abrir no bloco de notas — é texto.

---

## 3. Pré-requisitos para rodar

1. **Delphi** (Community Edition serve — é grátis para estudo). Versão 10.4/11/12.
   O FireDAC já vem incluso.
2. **Firebird Server** instalado (3.0 ou superior). Baixe em firebirdsql.org.
3. O `fbclient.dll` do Firebird acessível (vem com a instalação do Firebird).

---

## 4. Passo a passo para colocar para rodar

### 4.1 Criar o banco de dados
1. Abra o **ISQL** (vem com o Firebird) ou uma ferramenta como **FlameRobin** / **DBeaver**.
2. Crie o arquivo do banco (uma vez só):
   ```sql
   CREATE DATABASE 'C:\Users\sigma\Documents\delphi\banco\ERP.FDB'
     page_size 8192 DEFAULT CHARACTER SET WIN1252;
   ```
3. Rode o script `banco/criar_banco.sql` dentro desse banco (ele cria as tabelas e já
   insere um usuário `admin` / senha `123`, além de clientes e produtos de exemplo).

### 4.2 Ajustar a conexão
Abra `config.ini` e confira o caminho em `Database=` e a senha do `SYSDBA`
(o padrão da instalação local costuma ser `masterkey`).

### 4.3 Compilar no Delphi
1. Abra `Launcher/Launcher.dpr` no Delphi (File → Open) e mande **Build** (Ctrl+F9).
2. Abra `Faturamento/Faturamento.dpr` e mande **Build** também.
   > Ao abrir um `.dpr`, o Delphi gera automaticamente o `.dproj` (arquivo de projeto).

### 4.4 O detalhe do `config.ini`
O programa procura o `config.ini` **na mesma pasta do `.exe`**. Ao compilar, o `.exe`
costuma ir para uma subpasta tipo `Win32\Debug\`. Então **copie o `config.ini` para junto
de cada `.exe` gerado** (ou ajuste a pasta de saída do projeto nas opções do Delphi).

### 4.5 Rodar
- Rode o **Launcher**. Faça login com `admin` / `123`.
- Clique em **Faturamento**. Vai abrir a janela MDI com o menu.
- Menu **Cadastros → Clientes / Produtos**: use a barrinha de navegação (`+` inclui,
  o "check" grava, `-` exclui).
- Menu **Movimento → Nota Fiscal**: escolha o cliente, adicione itens e clique
  **Salvar nota**.

---

## 5. Roteiro de estudo sugerido (ordem de leitura)

Leia os arquivos **nesta ordem**, porque a dificuldade vai aumentando:

1. **`Comum/uSessao.pas`** — o mais simples. Aprende `unit`, `interface`,
   `implementation`, `record` e variável global.
2. **`Launcher/Launcher.dpr`** — como um programa Delphi começa (`begin..end`),
   criação de forms, `ShowModal`.
3. **`Launcher/uFrmLogin.pas`** — eventos de botão, `TFDQuery`, parâmetros de SQL
   (`:login`), leitura de campos (`FieldByName`).
4. **`Comum/uDM.pas`** — o DataModule e a conexão FireDAC; leitura de `.ini`;
   generators do Firebird (`ProximoId`).
5. **`Launcher/uFrmModulos.pas`** — como um módulo chama outro `.exe` (`ShellExecute`).
6. **`Faturamento/uFrmPrincipal.pas`** — MDI, menus, abrir janelas filhas sem duplicar.
7. **`Faturamento/uFrmClientes.pas`** e **`uFrmProdutos.pas`** — o padrão de cadastro
   (DBGrid + DataSource + DBNavigator). Repare que são quase iguais.
8. **`Faturamento/uFrmNotaFiscal.pas`** — o mais rico: mestre-detalhe, tabela em
   memória, e principalmente **transação** (`StartTransaction` / `Commit` / `Rollback`).

---

## 6. Mini-glossário Delphi (para os termos que aparecem no código)

- **unit**: um arquivo `.pas`. Tem uma parte `interface` (o que é público) e uma
  `implementation` (o código de fato).
- **uses**: lista de outras units que este arquivo precisa (como `import` em outras
  linguagens).
- **Form**: uma janela/tela. Toda tela é uma classe que herda de `TForm`.
- **DataModule**: um "form invisível" só para componentes não-visuais (conexão, queries).
- **Componente**: um objeto arrastado na tela (botão `TButton`, grade `TDBGrid`, etc.).
- **Evento**: um procedimento chamado quando algo acontece (ex.: `OnClick` do botão).
- **`TFDConnection`**: a conexão com o banco (FireDAC).
- **`TFDQuery`**: executa comandos SQL e guarda o resultado.
- **`TDataSource`**: a "ponte" entre uma query e os componentes visuais.
- **`TFDMemTable`**: uma tabela que existe só na memória (usada para os itens da nota
  antes de gravar).
- **MDI** (*Multiple Document Interface*): janela-mãe que contém janelas-filhas dentro
  dela — é a "área de trabalho" com telas abertas dentro.
- **Generator / Sequence** (Firebird): um contador do banco usado para gerar IDs únicos.
- **Trigger**: código que o banco executa automaticamente (aqui, para preencher o ID).
- **Transação**: um bloco "tudo ou nada". Ou grava tudo (`Commit`) ou desfaz tudo
  (`Rollback`).

---

## 7. Ideias para você praticar (exercícios)

Depois de entender o código, tente fazer sozinho:

1. Na tela de **Clientes**, impedir gravar se o `NOME` estiver vazio
   (dica: usar o evento `BeforePost` e `Abort`).
2. Criar uma tela de **consulta de notas fiscais já lançadas** (menu Movimento →
   Consultar Notas), com um `DBGrid` mostrando `NOTAS_FISCAIS` + nome do cliente
   (usando `JOIN` no SQL).
3. Ao salvar a nota, **baixar o estoque** dos produtos (subtrair a quantidade vendida
   de `PRODUTOS.ESTOQUE`) — dentro da mesma transação!
4. Fazer o módulo **Faturamento** também exigir login (hoje ele confia no launcher).
5. Trocar a mensagem de "Módulo em desenvolvimento" por um módulo de **Estoque** real.

---

## 8. Observações honestas

- Este código prioriza **clareza para estudo**, não performance nem todas as boas
  práticas de produção. Em sistemas reais você verá camadas extras (regras de negócio
  separadas da tela, frameworks, etc.).
- Não incluí os arquivos `.dproj` (configuração de projeto) porque o Delphi os gera ao
  abrir o `.dpr`. Se algum componente do `.dfm` não existir na sua versão, o Delphi avisa
  e é fácil ajustar.
- Se quiser, eu posso **expandir** qualquer parte: mais módulos, tela de consulta de
  notas, relatórios, ou explicar linha por linha um arquivo específico. É só pedir.

---

# PARTE 2 — Integrações e módulos avançados

Esta parte cobre o que foi adicionado depois: SEFAZ, PDV/cartão, e-mail,
relatórios, mobile e a IA. **Leia antes um aviso importante.**

## 9. Aviso de honestidade (leia!)

SEFAZ (NF-e) e TEF (maquininha) **de verdade** exigem coisas que não dá para
entregar num projeto de estudo sem certificado digital, credenciais e SDKs:

- **NF-e real**: assinatura digital do XML com certificado A1/A3 (ICP-Brasil) +
  envio SOAP/HTTPS para o webservice da SEFAZ da sua UF. No mercado, quase todo
  mundo usa o **projeto ACBr** (gratuito) em vez de fazer isso do zero.
- **TEF/cartão real**: cada maquininha (PayGo, SiTef, Stone, Cielo...) tem seu
  próprio SDK/DLL.

Então aqui os serviços estão em **modo SIMULADO**: a **estrutura e o fluxo são
reais e corretos** (inclusive o cálculo da chave de acesso de 44 dígitos e a
montagem do XML), mas as etapas de assinar/enviar estão marcadas no código com
`>>> AQUI ENTRARIA O REAL`. Isso é ótimo para estudar **como se organiza** a
integração; quando for para valer, troca-se a parte simulada pela biblioteca
certificada, sem mexer no resto.

## 10. Arquitetura em CAMADAS (o conceito mais importante daqui)

Repare na separação:

```
TELAS (Forms)  ->  SERVIÇOS (Comum\Servicos)  ->  BANCO / APIs externas
uFrmFiscal          uServicoNFe                    SEFAZ
uFrmPDV             uServicoTEF                     maquininha
uFrmRelatorios      uRelatorios / uServicoEmail     Firebird / SMTP
uFrmAssistenteIA    uServicoIA                       API do Claude
```

A **tela é "magra"**: ela só coleta dados e chama o serviço. A **regra pesada
mora no serviço**. Vantagens: dá para trocar a tela sem mexer na regra, testar o
serviço isolado, e reaproveitar o mesmo serviço em vários lugares. Isso é o que
separa código júnior "tudo no OnClick" de código organizado.

## 11. O que cada novidade faz e onde estudar

| Recurso | Serviço (a regra) | Tela (o uso) | Conceitos-chave |
|---|---|---|---|
| **NF-e / SEFAZ** | `Comum\Servicos\uServicoNFe.pas` | `Faturamento\uFrmFiscal.pas` | Chave de acesso (mód. 11), montagem de XML, transação |
| **Config SEFAZ** | `Comum\uConfig.pas` | `Faturamento\uFrmConfigNFe.pas` | Ler/gravar `.ini`, campos genéricos de credencial |
| **E-mail do XML** | `Comum\Servicos\uServicoEmail.pas` | `uFrmFiscal` (botão) | Indy `TIdSMTP`, anexo, TLS |
| **PDV + cartão** | `Comum\Servicos\uServicoTEF.pas` | `Faturamento\uFrmPDV.pas` | **Interface** `ITEF`, padrão Strategy, "fábrica" |
| **Relatórios** | `Comum\Servicos\uRelatorios.pas` | `Faturamento\uFrmRelatorios.pas` | Gerar HTML, `ShellExecute`, `JOIN` no SQL |
| **IA (bolinha)** | `Comum\Servicos\uServicoIA.pas` | `Faturamento\uFrmAssistenteIA.pas` | `THTTPClient`, JSON, API do Claude |
| **Mobile** | (chama API REST) | `MobileFlutter\lib\main.dart` | Flutter/Dart, HTTP GET (ver Parte 3) |

### Detalhes que valem estudo

- **`uServicoTEF` usa uma `interface` (`ITEF`)** — o "contrato" da maquininha.
  Hoje só existe `TTEFSimulado`, mas amanhã bastaria criar `TTEFStone` e mudar
  só a função `CriarTEF`. Esse é o padrão **Strategy** e é muito usado em ERP.
- **A "bolinha" de IA** (`uFrmPrincipal`): ela é um `TPanel` recortado em círculo
  com `CreateEllipticRgn` + `SetWindowRgn`. O clique abre a janela de chat, que
  chama de verdade a API do Claude (configure a `ApiKey` em `[IA]` do config.ini).
- **Mobile não acessa o banco direto.** Um celular fala com uma **API REST** que
  fica no servidor e é quem acessa o Firebird. O app só faz HTTP. Para o app
  funcionar de ponta a ponta você precisaria criar essa API (em Delphi dá para
  fazer com **RAD Server**, **DataSnap** ou a lib **Horse**). O app já está
  pronto para consumir; falta o servidor.

## 12. Configuração das credenciais

Tudo fica no `config.ini`, em seções separadas: `[SEFAZ]`, `[Email]`, `[TEF]`,
`[IA]`, `[APIRest]`. Os campos estão **genéricos e vazios** de propósito — você
preenche com os dados reais quando tiver. Enquanto estiverem vazios, os serviços
rodam em modo simulado (menos a IA, que precisa da `ApiKey` para responder).

> ⚠ Em produção **nunca** se guarda senha em texto puro num `.ini`. Aqui está
> assim só para estudo. O certo é usar cofre de segredos / criptografia.

## 13. Banco: rode a atualização v2

Antes de usar os módulos novos, rode `banco/atualizar_v2.sql` no mesmo `ERP.FDB`.
Ele adiciona os campos fiscais na nota (`CHAVE_ACESSO`, `PROTOCOLO`, `XML_NFE`) e
cria a tabela `VENDAS_PDV`.

## 14. Roteiro de estudo da Parte 2 (ordem sugerida)

1. `Comum\uConfig.pas` — como centralizar configuração em records.
2. `Comum\Servicos\uServicoTEF.pas` — o mais didático sobre **interface**.
3. `Comum\Servicos\uServicoEmail.pas` — enviar e-mail com Indy.
4. `Comum\Servicos\uRelatorios.pas` — buscar dados e "imprimir".
5. `Comum\Servicos\uServicoIA.pas` — consumir uma API HTTP + JSON.
6. `Comum\Servicos\uServicoNFe.pas` — o mais denso: chave, XML, transação.
7. As telas correspondentes (`uFrmFiscal`, `uFrmPDV`, etc.).
8. `MobileFlutter\lib\main.dart` — o app mobile em Flutter (ver Parte 3).

## 15. Dependências extras que talvez o Delphi peça

- **Indy** (e-mail): já vem com o Delphi.
- **OpenSSL** (TLS do e-mail e HTTPS): pode precisar das DLLs `libeay32.dll` /
  `ssleay32.dll` (ou `libssl`/`libcrypto` nas versões novas) ao lado do `.exe`.
- **Mobile:** o app é em **Flutter** (pasta `MobileFlutter\`), não em Delphi.
  Precisa do SDK do Flutter instalado (ver Parte 3).

## 16. Próximos passos que eu posso fazer por você

- Criar a **API REST** (Horse/DataSnap) para o mobile funcionar de ponta a ponta.
- Integrar de verdade com o **ACBr** para NF-e real.
- Explicar **linha por linha** qualquer um desses serviços.
- Baixar estoque na venda, numeração automática de nota, tela de caixa completa.

É só pedir.

---

# PARTE 3 — Telemetria, licença, privilégios, logs, Jenkins e mobile Flutter

## 17. "Cadê o arquivo .FDB?" (sua pergunta)

Instalar o Firebird instala só o **servidor** — ele **não cria** o seu banco.
O arquivo `.FDB` nasce quando você roda o comando `CREATE DATABASE`. Você tem
dois caminhos:

**Caminho fácil (recomendado):** rode o `banco\criar_banco.bat`. Ele cria o
`ERP.FDB` e aplica todos os scripts (criar + v2 + v3) de uma vez. Antes, abra o
`.bat` e confirme a pasta do Firebird na linha `set FB=...` (veja em
`C:\Program Files\Firebird\` se é `Firebird_3_0`, `_4_0` ou `_5_0`).

**Caminho manual:** use um programa visual (**FlameRobin** ou **DBeaver**),
crie o banco em `C:\Users\sigma\Documents\delphi\banco\ERP.FDB` e rode os
scripts `00_criar_database.sql`, `criar_banco.sql`, `atualizar_v2.sql`,
`atualizar_v3.sql` nessa ordem.

Depois de criado, o `ERP.FDB` fica em `banco\ERP.FDB` — é esse o "arquivo do
banco". O caminho dele está no `config.ini`.

## 18. "Compilo qual arquivo? um ou vários?" (sua pergunta)

**São VÁRIOS executáveis** — cada `.dpr` vira um `.exe` separado. Este ERP tem 3
projetos Delphi:

| Projeto (.dpr) | Vira o executável | O que é |
|---|---|---|
| `Launcher\Launcher.dpr` | `Launcher.exe` | login + janelinha de módulos |
| `Faturamento\Faturamento.dpr` | `Faturamento.exe` | módulo MDI |
| `Telemetria\TelemetriaService.dpr` | `TelemetriaService.exe` | serviço Windows |

Isso é **normal** em ERP modular: o sistema é um conjunto de programas, não um
executável gigante. Você tem duas formas de compilar:

- **Uma de cada vez:** File → Open → abra o `.dpr`, e dê **Build** (Ctrl+F9).
  Repita para cada projeto.
- **Todos de uma vez (melhor):** abra o `ERP.groupproj` (File → Open). Ele já
  lista os 3 projetos. Clique com o botão direito no grupo → **Build All
  Projects**. *(Se algum projeto aparecer faltando, é porque o `.dproj` ainda
  não existe: abra aquele `.dpr` uma vez para o Delphi gerar o `.dproj`.)*

Para **rodar/estudar**, o que você executa é o `Launcher.exe`. Ele que chama o
`Faturamento.exe`. O serviço de telemetria é instalado à parte (ver seção 20).

> Dica: no Delphi, o projeto em **negrito** no Project Manager é o "ativo" (o que
> roda com F9). Dê duplo-clique no que quiser tornar ativo.

## 19. "O mobile é Flutter" (sua correção)

Você tem razão — refiz o app em **Flutter** (linguagem **Dart**), na pasta
`MobileFlutter\`. Removi a versão anterior (que eu tinha feito em FireMonkey por
suposição). Diferença de mentalidade:

- **Delphi/desktop:** você *desenha* a tela (`.dfm`) e programa em Object Pascal.
- **Flutter:** a tela é *escrita em código*, montando "widgets" (tudo é widget).

Igual aos módulos desktop, **o celular não acessa o Firebird direto** — ele fala
com uma **API REST**. O app já está pronto para consumir (`lib\main.dart`); falta
existir o servidor da API. Para rodar: instale o Flutter, entre em
`MobileFlutter\` e rode `flutter pub get` e depois `flutter run`.

## 20. Telemetria (serviço do Windows)

`Telemetria\` é um **Windows Service** (`TService`): roda no fundo, sem janela,
mesmo sem ninguém logado. Ele verifica de tempos em tempos se o ERP está aberto
(procurando os processos `Launcher.exe`/`Faturamento.exe`) e grava em
`telemetria.log`. No mundo real, ele **enviaria** esse uso a um servidor central
(o ponto exato está comentado no código com `>>>`).

Instalar/remover (Prompt de Comando como **Administrador**):
```
TelemetriaService.exe /install
net start SrvTelemetria
TelemetriaService.exe /uninstall
```

## 21. Bloqueio por licença (boleto vencido)

`Comum\uLicenca.pas` + tabela `LICENCA`. No **login**, o sistema checa o
vencimento; se estiver vencido (ou `BLOQUEADO='S'`), **não deixa entrar** e mostra
a mensagem de bloqueio. Para **testar o bloqueio**, edite a `DATA_VENCIMENTO`
para uma data passada na tabela `LICENCA` (ou ponha `BLOQUEADO='S'`).

> Na vida real, essa checagem bate num servidor da empresa (senão o cliente só
> mudaria a data no próprio banco). Aqui é local, mas o conceito é o mesmo.

## 22. Logs por tela

`Comum\uLog.pas`. Cada tela grava seu próprio arquivo em `logs\`, com nome e
data — ex.: `logs\TFrmNotaFiscal_20260701.log`. Uso dentro de qualquer form:
```pascal
TLog.Registrar(ClassName, 'Nota salva com sucesso.');
```
Já deixei chamadas de log no login, na aprovação de pedidos, nas rotinas e na
edição de privilégios, para você ver o padrão. Cada linha registra hora, usuário
e mensagem.

## 23. Aprovação de pedidos + Árvore de privilégios

- **Aprovação de pedidos:** menu Pedidos → Aprovar. Lista pedidos pendentes
  (tabela `PEDIDOS`) e permite Aprovar/Reprovar. Os botões só ficam ativos se o
  usuário tiver a permissão `FAT.PED.APROVAR`.
- **Árvore de privilégios:** menu Administração → Privilégios por Perfil. Você
  escolhe um perfil e marca as permissões. A árvore vem da tabela `PERMISSOES`
  (cada chave sabe seu "pai"). Perfis prontos: **Administrador** (vê tudo),
  **Vendedor** (cadastros/movimento/relatórios), **Financeiro** (fiscal/pedidos).

**Como as permissões afetam a tela:** ao abrir o Faturamento,
`AplicarPermissoes` mostra/esconde cada menu conforme o perfil. Faça login com
`admin/123` (Administrador) e depois com `joao/123` (Vendedor) e compare os
menus — é o mesmo `.exe`, mudando só o perfil.

> Detalhe técnico importante: como o `Faturamento.exe` é um processo separado do
> launcher, a sessão não é herdada automaticamente. O launcher passa
> `/usuario=LOGIN` na linha de comando e o módulo **recarrega** o usuário e as
> permissões no início (`DM.InicializarSessaoModulo`). Se você rodar o
> Faturamento direto pela IDE (sem parâmetro), ele assume `admin` para facilitar.

## 24. Jenkins (rotinas do sistema)

`Comum\Servicos\uServicoJenkins.pas` + tela Administração → Rotinas. Dispara
"jobs" do Jenkins (ex.: `fechamento-diario`, `backup-banco`) e consulta o status
via API REST do Jenkins. Configure `[Jenkins]` no `config.ini` (URL, usuário e
API Token). Sem configurar, os botões explicam o que aconteceria.

## 25. Ordem para deixar tudo rodando (resumão)

1. Rode `banco\criar_banco.bat` (cria o `ERP.FDB`).
2. Confira os caminhos no `config.ini` e copie o `config.ini` para junto de cada
   `.exe` compilado.
3. Abra `ERP.groupproj` no Delphi e faça **Build All**.
4. Rode o `Launcher.exe`. Login: `admin` / `123`.
5. (Opcional) Instale o serviço de telemetria.

## 26. O que ainda é "simulado" (honestidade)

Continuam como esqueleto didático (estrutura real, execução simulada):
**NF-e/SEFAZ**, **TEF/cartão**, e agora **Jenkins** e **telemetria** funcionam de
verdade *se* você apontar para um servidor real no `config.ini`; sem isso, rodam
em modo demonstração. A **API REST do mobile** ainda precisa ser criada para o
app Flutter funcionar de ponta a ponta.

Posso, se quiser: criar a **API REST** (com a lib Horse) para o mobile funcionar,
integrar NF-e real com **ACBr**, ou explicar **linha por linha** qualquer um
desses módulos novos.

---

Bons estudos! 🚀
