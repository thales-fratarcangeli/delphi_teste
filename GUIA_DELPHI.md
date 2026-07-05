# Guia de Estudo — Delphi para Programador Júnior

Este guia é o **mapa** do que estudar neste ERP para você chegar como dev júnior
sabendo o suficiente. Ele lista os conceitos de Delphi, diz **onde cada um
aparece no projeto** e o que praticar. Use junto com o `README.md` (que explica
o funcionamento do sistema).

> Como usar: vá descendo a lista. Para cada tópico, abra o arquivo indicado, leia
> o código com os comentários, e tente **reescrever de memória**. Marque o
> checklist quando se sentir confortável.

---

## 1. Fundamentos da linguagem Object Pascal

Arquivo de referência: [`Comum/uExemplosLinguagem.pas`](Comum/uExemplosLinguagem.pas)
(um arquivo só com exemplos comentados — dá pra rodar pelo menu **Exemplos →
Recursos da linguagem**).

| Conceito | Onde estudar |
|---|---|
| `unit`, `interface`, `implementation`, `uses` | qualquer `.pas`; comece por `Comum/uSessao.pas` |
| Variáveis, tipos (`Integer`, `string`, `Double`, `Boolean`, `Currency`) | `uExemplosLinguagem.pas` |
| `if`, `case`, `for`, `while`, `repeat` | `uServicoNFe.pas` (loops), `uFrmNotaFiscal.pas` |
| `for ... in` (loop em coleções/strings) | `uExemplosLinguagem.pas` |
| Tipos enumerados (`enum`) e conjuntos (`set`) | `uExemplosLinguagem.pas`, `uServicoTEF.pas` |
| `record` (registro) com métodos | `uExemplosLinguagem.pas`, `uConfig.pas` |
| Exceções: `try/except`, `try/finally`, `raise` | `uServicoIA.pas`, `uFrmNotaFiscal.pas` (transação) |
| Formatação: `Format`, `FormatFloat`, `FormatDateTime` | `uRelatorios.pas`, `uServicoNFe.pas` |

☐ Sei declarar uma unit, criar variáveis e usar os laços
☐ Entendo a diferença entre `try/except` (tratar erro) e `try/finally` (liberar)
☐ Sei usar `record`, `enum` e `set`

---

## 2. Programação Orientada a Objetos (POO)

Coração do Delphi. Estude nesta ordem:

| Conceito | Onde estudar |
|---|---|
| Classe, `constructor`, `destructor`, `Free` | `uServicoNFe.pas`, `uEntidades.pas` |
| Campos privados + `property` (propriedades) | [`Comum/Dominio/uEntidades.pas`](Comum/Dominio/uEntidades.pas) |
| Herança (`class(Pai)`) | `uEntidades.pas` (`TCliente` herda de `TEntidadeBase`) |
| Métodos `virtual` / `abstract` / `override` | `uEntidades.pas`, `uExemplosLinguagem.pas` |
| Polimorfismo | `uExemplosLinguagem.pas` (animais), tela **Clientes OO** |
| Classe abstrata | `uEntidades.pas` (`TEntidadeBase = class abstract`) |
| `interface` + `TInterfacedObject` | [`Comum/Servicos/uServicoTEF.pas`](Comum/Servicos/uServicoTEF.pas) (`ITEF`) |
| Variáveis/métodos de classe (`class var`, `class function`) | `uLog.pas`, `uPermissoes.pas`, `uConfig.pas` |
| `class constructor` / `class destructor` | `uLog.pas`, `uPermissoes.pas` |

☐ Sei criar uma classe com propriedades e um construtor
☐ Entendo herança, `virtual`/`override` e polimorfismo
☐ Sei o que é uma interface e quando usar
☐ Sei que todo objeto criado com `.Create` precisa de `.Free` (ou dono/interface)

---

## 3. Generics e coleções

| Conceito | Onde estudar |
|---|---|
| `TStringList` (lista de strings) | `uLog.pas`, `uFrmPermissoes.pas` |
| `TList<T>` (lista tipada) | `uExemplosLinguagem.pas` |
| `TObjectList<T>` (lista que é "dona" dos objetos) | `uClienteDAO.pas`, `uExemplosLinguagem.pas` |
| `TDictionary<K,V>` (chave→valor) | `uExemplosLinguagem.pas` |
| Métodos anônimos (`TFunc`, `TProc`, `reference to`) | `uExemplosLinguagem.pas`, `uTarefaThread.pas` |

☐ Sei usar `TObjectList<T>` e entendo o parâmetro `OwnsObjects`
☐ Entendo o que é um método anônimo e onde ele aparece

---

## 4. VCL — Telas e componentes visuais

| Conceito | Onde estudar |
|---|---|
| Form (`TForm`), o par `.pas` + `.dfm` | qualquer tela |
| Eventos (`OnClick`, `OnCreate`, `OnClose`) | todas as telas |
| MDI (janela-mãe + filhas) | [`Faturamento/uFrmPrincipal.pas`](Faturamento/uFrmPrincipal.pas) |
| Menus (`TMainMenu`, submenus) | `uFrmPrincipal.pas` |
| Componentes: `TButton`, `TEdit`, `TComboBox`, `TPanel`, `TLabel` | telas de login e nota fiscal |
| `TDateTimePicker`, `TCheckListBox`, `TListView`, `TProgressBar` | nota fiscal, permissões, clientes OO |
| Diálogos: `ShowMessage`, `InputQuery`, `MessageDlg` | `uFrmClientesOO.pas`, `uFrmFiscal.pas` |
| Janela modal (`ShowModal`, `ModalResult`) | `Launcher/uFrmLogin.pas` |
| Desenhar região (janela redonda) | `uFrmPrincipal.pas` (a "bolinha" da IA) |

☐ Sei criar uma tela, colocar botões e escrever o evento do clique
☐ Entendo MDI e como uma tela abre "dentro" de outra
☐ Sei abrir uma tela modal e pegar o resultado

---

## 5. Banco de dados (FireDAC + Firebird)

| Conceito | Onde estudar |
|---|---|
| Conexão (`TFDConnection`) + DataModule | [`Comum/uDM.pas`](Comum/uDM.pas) |
| Consultas (`TFDQuery`), abrir e ler campos (`FieldByName`) | `uFrmLogin.pas`, todas as telas |
| Parâmetros na SQL (`:id`) — evita SQL Injection | `uFrmLogin.pas`, `uClienteDAO.pas` |
| Executar comandos (`ExecSQL`, `ExecSQLScalar`) | `uDM.pas`, `uFrmNotaFiscal.pas` |
| Data-aware: `TDataSource` + `TDBGrid` + `TDBNavigator` | `uFrmClientes.pas`, `uFrmProdutos.pas` |
| Tabela em memória (`TFDMemTable`) | `uFrmNotaFiscal.pas`, `uFrmPDV.pas` |
| **Transação** (`StartTransaction`/`Commit`/`Rollback`) | `uFrmNotaFiscal.pas`, `uFrmPermissoes.pas` |
| Master-detail (mestre + itens) | `uFrmNotaFiscal.pas` |
| SQL: `SELECT`, `INSERT`, `UPDATE`, `DELETE`, `JOIN` | `uRelatorios.pas`, `uFrmFiscal.pas` |
| Generators e triggers (Firebird) | `banco/criar_banco.sql`, `uDM.ProximoId` |

☐ Sei abrir uma query com parâmetro e ler os campos
☐ Sei a diferença entre query (SELECT) e ExecSQL (INSERT/UPDATE/DELETE)
☐ Entendo transação: tudo ou nada
☐ Sei fazer um `JOIN` entre duas tabelas

---

## 6. Arquitetura e padrões (o que separa júnior de estagiário)

| Conceito | Onde estudar |
|---|---|
| Camada de serviços (regra separada da tela) | `Comum/Servicos/*` |
| Camada de domínio (entidades como classes) | `Comum/Dominio/uEntidades.pas` |
| **DAO / Repository** (acesso a dados isolado) | `Comum/Dominio/uClienteDAO.pas` |
| Padrão **Strategy** (trocar implementação por interface) | `uServicoTEF.pas` (`ITEF` + `CriarTEF`) |
| Configuração centralizada | `Comum/uConfig.pas` |
| Estado compartilhado (sessão do usuário) | `Comum/uSessao.pas` |
| Sistema de permissões por perfil | `Comum/uPermissoes.pas` + `uFrmPermissoes.pas` |
| Log por tela | `Comum/uLog.pas` |

☐ Entendo por que a regra não deve ficar toda no `OnClick` do botão
☐ Sei o que é um DAO e por que isolar o SQL
☐ Consigo explicar o padrão Strategy com o exemplo do TEF

---

## 7. Recursos avançados

| Conceito | Onde estudar |
|---|---|
| **Threads** (processar sem travar a tela) | [`Comum/uTarefaThread.pas`](Comum/uTarefaThread.pas) + tela Clientes OO |
| `Synchronize` / `Queue` (atualizar a tela pela thread) | `uTarefaThread.pas` |
| Consumir API HTTP (`THTTPClient`) | `uServicoIA.pas`, `uServicoJenkins.pas` |
| Ler/gerar **JSON** (`System.JSON`) | `uServicoIA.pas` |
| Enviar e-mail (Indy `TIdSMTP`) | `uServicoEmail.pas` |
| Serviço do Windows (`TService`) | `Telemetria/uServicoTelemetria.pas` |
| Ler processos do Windows (API `TlHelp32`) | `uServicoTelemetria.pas` |
| Arquivos e pastas (`TFile`, `TDirectory`, `TIniFile`) | `uLog.pas`, `uConfig.pas` |

☐ Entendo por que uma tarefa demorada deve ir para uma thread
☐ Sei fazer uma chamada HTTP e ler um JSON de resposta

---

## 8. Roteiro sugerido (4 semanas de estudo)

- **Semana 1 — Linguagem + POO:** `uExemplosLinguagem.pas`, `uEntidades.pas`,
  `uSessao.pas`, `uConfig.pas`. Objetivo: escrever classes de olhos fechados.
- **Semana 2 — Telas VCL:** login, `uFrmClientes`, `uFrmProdutos`,
  `uFrmPrincipal` (MDI/menu). Objetivo: montar telas e eventos.
- **Semana 3 — Banco:** `uDM.pas`, `uFrmNotaFiscal.pas` (transação/master-detail),
  `uClienteDAO.pas`. Objetivo: dominar FireDAC + SQL + transação.
- **Semana 4 — Arquitetura + avançado:** serviços, permissões, threads,
  telemetria. Objetivo: enxergar o sistema como camadas.

---

## 9. Perguntas típicas de entrevista júnior (saiba responder)

1. Qual a diferença entre `try/except` e `try/finally`?
2. Todo objeto criado com `Create` precisa de `Free`? Quando NÃO precisa?
   (resposta: quando tem um **dono** que libera, ou é **interface**/record)
3. O que é uma propriedade (`property`) e por que não usar campo público direto?
4. Para que serve `virtual`/`override`? O que é polimorfismo?
5. O que é uma transação de banco e quando usar?
6. Por que usar parâmetros (`:id`) em vez de concatenar valores na SQL?
7. O que acontece se uma tarefa demorada roda na thread principal?
8. Qual a diferença entre `TFDQuery` e `TFDMemTable`?
9. O que é MDI?
10. O que é uma interface e como o padrão Strategy a usa?

---

## 10. O que praticar ALÉM deste projeto (para ir mais longe)

Estes temas são comuns em ERPs reais e valem estudar depois (não estão 100% aqui
para não inflar o projeto — mas agora você tem base para pegá-los rápido):

- **Herança visual de formulários** (um form base de cadastro que outros herdam).
- **`TActionList`** (compartilhar ações entre menu, toolbar e botões).
- **`TFrame`** (pedaços de tela reutilizáveis).
- **Relatórios com FastReport** (padrão de mercado; aqui usamos HTML por não ser
  incluído na sua edição Starter).
- **Testes com DUnitX** (testar suas classes automaticamente).
- **Controles data-aware avançados** (`TDBLookupComboBox` para chaves estrangeiras).
- **RTTI e atributos** (mais avançado).

Quando quiser, me peça para adicionar qualquer um destes com o mesmo estilo
comentado. Bons estudos — você está no caminho certo! 🚀
