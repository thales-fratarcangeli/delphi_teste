unit uFrmClientesOO;

{ ===========================================================================
  Tela de CLIENTES "orientada a objetos" (versão de ESTUDO).
  Faz o mesmo que a tela de Clientes original, mas de um jeito diferente para
  você comparar as duas abordagens:

    - Tela original (uFrmClientes): TFDQuery + DBGrid ligados direto (data-aware).
    - Esta tela: usa o DAO (uClienteDAO), recebe uma LISTA DE OBJETOS
      (TObjectList<TCliente>) e mostra numa TListView. O SQL fica escondido
      no DAO; a tela só trabalha com objetos.

  Também demonstra THREAD: o botão "Processar" roda uma tarefa demorada em
  segundo plano, sem travar a tela, atualizando uma barra de progresso.
  =========================================================================== }

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.Generics.Collections,
  Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Dialogs,
  uEntidades, uClienteDAO, uTarefaThread;

type
  TFrmClientesOO = class(TForm)
    pnlTopo: TPanel;
    btnAtualizar: TButton;
    btnNovo: TButton;
    btnExcluir: TButton;
    btnProcessar: TButton;
    Lista: TListView;
    Progresso: TProgressBar;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnAtualizarClick(Sender: TObject);
    procedure btnNovoClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure btnProcessarClick(Sender: TObject);
  private
    FDAO: TClienteDAO;
    procedure Carregar;
  end;

var
  FrmClientesOO: TFrmClientesOO;

implementation

{$R *.dfm}

procedure TFrmClientesOO.FormCreate(Sender: TObject);
begin
  FDAO := TClienteDAO.Create;   // o DAO vive enquanto a tela existir
  Carregar;
end;

procedure TFrmClientesOO.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FDAO.Free;
  Action := caFree;
end;

{ Pede a lista de clientes ao DAO (objetos) e joga na TListView. }
procedure TFrmClientesOO.Carregar;
var
  Clientes: TObjectList<TCliente>;
  C: TCliente;
  Item: TListItem;
begin
  Lista.Items.BeginUpdate;
  try
    Lista.Items.Clear;
    Clientes := FDAO.ListarTodos;   // recebe TObjectList<TCliente>
    try
      for C in Clientes do
      begin
        Item := Lista.Items.Add;
        Item.Caption := IntToStr(C.Id);   // 1ª coluna = Id
        Item.SubItems.Add(C.Nome);        // demais colunas
        Item.SubItems.Add(C.Cidade);
        Item.SubItems.Add(C.Uf);
      end;
    finally
      Clientes.Free;   // a lista é dona: libera todos os TCliente aqui
    end;
  finally
    Lista.Items.EndUpdate;
  end;
end;

procedure TFrmClientesOO.btnAtualizarClick(Sender: TObject);
begin
  Carregar;
end;

procedure TFrmClientesOO.btnNovoClick(Sender: TObject);
var
  C: TCliente;
  Nome, Cidade, Uf: string;
begin
  // InputQuery precisa de VARIÁVEIS (var), por isso coletamos em strings locais
  // e só depois passamos para o objeto.
  Nome := ''; Cidade := ''; Uf := '';
  if not InputQuery('Novo cliente', 'Nome:', Nome) then Exit;
  InputQuery('Novo cliente', 'Cidade:', Cidade);
  InputQuery('Novo cliente', 'UF (2 letras):', Uf);

  C := TCliente.Create;
  try
    C.Nome := Nome;
    C.Cidade := Cidade;
    C.Uf := Uf;
    FDAO.Inserir(C);   // o DAO valida e grava; se inválido, lança exceção
    Carregar;
  finally
    C.Free;
  end;
end;

procedure TFrmClientesOO.btnExcluirClick(Sender: TObject);
var
  Id: Integer;
begin
  if Lista.Selected = nil then
  begin
    ShowMessage('Selecione um cliente na lista.');
    Exit;
  end;
  Id := StrToInt(Lista.Selected.Caption);
  if MessageDlg('Excluir o cliente ' + IntToStr(Id) + '?',
       mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    FDAO.Excluir(Id);
    Carregar;
  end;
end;

{ Roda um trabalho demorado em SEGUNDO PLANO, sem travar a tela.
  Repare que a barra de progresso vai andando enquanto a janela continua
  respondendo (dá para mover, clicar, etc.). }
procedure TFrmClientesOO.btnProcessarClick(Sender: TObject);
var
  Tarefa: TTarefaLonga;
begin
  btnProcessar.Enabled := False;
  Progresso.Position := 0;

  Tarefa := TTarefaLonga.Create(100);
  // Callbacks (métodos anônimos) que a thread chama na thread principal:
  Tarefa.OnProgresso :=
    procedure(Pct: Integer)
    begin
      Progresso.Position := Pct;   // seguro: roda na thread principal (Queue)
    end;
  Tarefa.OnConcluida :=
    procedure
    begin
      btnProcessar.Enabled := True;
      ShowMessage('Processamento em segundo plano concluído!');
    end;
  Tarefa.Start;   // dispara a thread
end;

end.
