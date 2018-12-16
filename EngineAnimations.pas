unit EngineAnimations;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

procedure DropDownMsg(AMsg : string; {AFont : TFont;} Sender : TWinControl);

var
  AnimationsCanShow : boolean = true;

implementation

procedure DropDownMsg(AMsg : string; {AFont : TFont;} Sender : TWinControl);
var
  lblMessage : TLabel;
  i, y: integer;
begin
  if AnimationsCanShow then
  begin
  Animationscanshow := false;
  lblMessage := TLabel.Create(Sender);
  with lblMessage do
  begin
    Parent := Sender;
    Font.size := 50;
    Font.Style := [fsBold];
    Font.Color := rgb(255,0,0);
    Caption := AMsg;
    Top := 0 - Sender.ClientHeight;
    Left := round((Sender.Clientwidth / 2) - (Width/2));
    for i := 1 to 90 do
    begin
      top := round(sin(PI/(180/i))*height) - Height;
      sleep(1);
      lblMessage.Refresh;
    end;
    Sleep(1500);
    for i := 90 to 180 do
    begin
      top := round(sin(PI/(180/i))*height) - Height;
      sleep(1);
      lblMessage.Refresh;
    end;
  end;
  lblMessage.Destroy;
  animationscanshow := true;
  end;
end;

end.
