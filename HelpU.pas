unit HelpU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, pngimage, StdCtrls;

type
  TfrmHelp = class(TForm)
    _1: TShape;
    _2: TShape;
    _3: TShape;
    _4: TShape;
    _5: TShape;
    _6: TShape;
    Shape7: TShape;
    imgHelp: TImage;
    img1: TImage;
    img2: TImage;
    img3: TImage;
    img4: TImage;
    img5: TImage;
    L1: TLabel;
    L2: TLabel;
    L3: TLabel;
    L4: TLabel;
    L5: TLabel;
    L6: TLabel;
    procedure _1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormHide(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmHelp: TfrmHelp;

implementation

{$R *.dfm}

procedure TfrmHelp.FormActivate(Sender: TObject);
var
  i : byte;
begin
  i := 0;
  while i < 250 do
  begin
    inc(i, 2);
    AlphaBlendValue := i;
    sleep(1);
    Application.ProcessMessages;
  end;
end;

procedure TfrmHelp.FormCreate(Sender: TObject);
var
  rgn : HRGN;
begin
  rgn := CreateRoundRectRgn(0,  // x-coordinate of the region's upper-left corner
    0,                          // y-coordinate of the region's upper-left corner
    ClientWidth,            // x-coordinate of the region's lower-right corner
    ClientHeight,           // y-coordinate of the region's lower-right corner
    20,                         // height of ellipse for rounded corners
    20);                        // width of ellipse for rounded corners
  SetWindowRgn(Handle, rgn, True);
end;

procedure TfrmHelp.FormHide(Sender: TObject);
var
  i : byte;
begin
  i := 250;
  while i > 2 do
  begin
    dec(i, 2);
    AlphaBlendValue := i;
    sleep(1);
    Application.ProcessMessages;
  end;
end;

procedure TfrmHelp._1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  _1.Brush.Color := $00FFDD69;
  _2.Brush.Color := $00FFDD69;
  _3.Brush.Color := $00FFDD69;
  _4.Brush.Color := $00FFDD69;
  _5.Brush.Color := $00FFDD69;
  _6.Brush.Color := $00FFDD69;
  case TComponent(Sender).Name[2] of
    '1':
      begin
        imgHelp.Picture := img1.Picture;
        _1.Brush.Color := $00FFBE69
      end;
    '2':
      begin
        imgHelp.Picture := img2.Picture;
        _2.Brush.Color := $00FFBE69
      end;
    '3':
      begin
        imgHelp.Picture := img3.Picture;
        _3.Brush.Color := $00FFBE69
      end;
    '4':
      begin
        imgHelp.Picture := img4.Picture;
        _4.Brush.Color := $00FFBE69
      end;
    '5':
      begin
        imgHelp.Picture := img5.Picture;
        _5.Brush.Color := $00FFBE69
      end;
    '6': ModalResult := mrOk;
  end;
end;

end.
