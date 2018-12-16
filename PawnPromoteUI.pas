unit PawnPromoteUI;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfrmPawnPromote = class(TForm)
    cbxPromote: TComboBox;
    btnPromote: TButton;
    procedure btnPromoteClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmPawnPromote: TfrmPawnPromote;
  Ans : integer;

implementation

{$R *.dfm}

procedure TfrmPawnPromote.btnPromoteClick(Sender: TObject);
begin
  if cbxPromote.ItemIndex < 0 then cbxPromote.ItemIndex := 3;
  ModalResult := cbxPromote.ItemIndex + 2;
end;

end.
