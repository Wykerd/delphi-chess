unit EngineUI;

interface

uses
  ExtCtrls, Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Forms, Dialogs, Math, StdCtrls, pngimage;

function RequestSaveName : string;
function ChooseLoadDlg(loadFileName : string) : string;
function OverwriteRequest : boolean;
function InputBoxP(Prompt, Default : string):string;
function PickPawnPromotion : byte;

implementation

function PickPawnPromotion : byte;
var
  frm : TForm;
  rgn: HRGN;
  Done : boolean;
  lbl : TLabel;
  sR : array of string; //FilePaths ~~ R Stands for response
  i, y, i2 : integer;
  clickRegions : array of trect;
  rects : array of TShape;
begin
  ///  Slightly altered chooseloaddlg code  ///
  ///

  Done := false;

  frm := TForm.CreateNew(nil, 0);
  frm.BorderStyle := bsNone;
  frm.AlphaBlend := true;
  frm.AlphaBlendValue := 0;

  lbl := TLabel.Create(frm);
  lbl.Parent := frm;
  lbl.Caption := 'P R O M O T E   P A W N';
  lbl.Font.Name := 'Arial';
  lbl.Font.Size := 18;
  lbl.Font.Color := $5D2FFF;
  lbl.Font.Style := [fsBold];

  frm.ClientWidth := lbl.Width + 40;

  lbl.left := round((frm.ClientWidth/2) - (lbl.Width/2));
  lbl.Top := 20;

  i := 0;
  for i := 1 to 4 do
  begin
    SetLength(rects, i);
    SetLength(clickRegions, i);
    SetLength(sR, i);
    rects[i-1] := TShape.Create(frm);
    with rects[i-1] do
    begin
      Parent := frm;
      Width := frm.ClientWidth;
      brush.Color := $FFDD69;
      top := i*(height+5);
      pen.Style := psClear;
    end;
    case i of
      1: sr[i - 1] := 'ROOK';   //castle
      2: sr[i - 1] := 'BISHOP';
      3: sr[i - 1] := 'KNIGHT';    //horse
      4: sr[i - 1] := 'QUEEN';
    end;
    lbl := TLabel.Create(frm);
    with lbl do
    begin
      parent := frm;
      Font.Name := 'Arial';
      Font.Size := 18;
      Font.Color := rgb(105,97,225);
      Font.Style := [fsBold];
      Top := round(rects[i-1].Top + (rects[i-1].Height/2) - (Height/2)) ;
      Caption := sR[i-1];
      Left := round((frm.Width/2) - (lbl.Width/2));
    end;
  end;

  frm.ClientHeight := rects[i-2].Top + rects[i-2].Height + 20;
  frm.Position := poScreenCenter;

  rgn := CreateRoundRectRgn(0,  // x-coordinate of the region's upper-left corner
    0,                          // y-coordinate of the region's upper-left corner
    frm.ClientWidth,            // x-coordinate of the region's lower-right corner
    frm.ClientHeight,           // y-coordinate of the region's lower-right corner
    20,                         // height of ellipse for rounded corners
    20);                        // width of ellipse for rounded corners
  SetWindowRgn(frm.Handle, rgn, True);
  frm.Color := rgb(168,244,255);
  frm.DoubleBuffered := true;
  frm.Show;

  i2 := 0;
  while i2 < 250 do
  begin
    inc(i2, 2);
    frm.AlphaBlendValue := i2;
    sleep(1);
    Application.ProcessMessages;
  end;

  for y := 0 to i - 2 do
  begin
    clickRegions[y].Left := rects[y].ClientToScreen(point(0,0)).x;
    clickRegions[y].Top := rects[y].ClientToScreen(point(0,0)).y;
    clickRegions[y].Bottom := rects[y].ClientToScreen(point(0,0 + rects[y].height)).y;
    clickRegions[y].Right := rects[y].ClientToScreen(point(0 + rects[y].width,0)).x;
  end;

  while not done do
  begin
    frm.BringToFront;
    for Y := 0 to i - 2 do
    begin
      if (mouse.CursorPos.X >= clickRegions[y].Left) AND
        (mouse.CursorPos.X <= clickRegions[y].Right) AND
        (mouse.CursorPos.Y >= clickRegions[y].Top) AND
        (mouse.CursorPos.Y <= clickRegions[y].Bottom) then
      begin
        while GETGVALUE(rects[y].Brush.Color) > $BE do
        begin
          rects[y].Brush.Color := rects[y].Brush.Color - $000100;
          sleep(5);
          Application.ProcessMessages;
        end;
        if GetKeyState(VK_LBUTTON) < 0 then
          Done := True;
          case sR[y][1] of
            'R' : result := 2;
            'B' : result := 3;
            'K' : result := 4;
            'Q' : result := 5;
          end;
      end
      else
      begin
        while GETGVALUE(rects[y].Brush.Color) < $DD do
        begin
          rects[y].Brush.Color := rects[y].Brush.Color + $000100;
          sleep(5);
          Application.ProcessMessages;
        end;
      end;
      Application.ProcessMessages;
    end;
    Application.ProcessMessages;
  end;
  i2 := 250;
  while i2 > 2 do
  begin
    dec(i2, 2);
    frm.AlphaBlendValue := i2;
    sleep(1);
    Application.ProcessMessages;
  end;
  frm.Destroy;
end;


function InputBoxP(Prompt, Default : string):string;
var
  frm : TForm;
  rgn: HRGN;
  Text, sCaption : string;
  Done : boolean;
  lblText, lblDebug, lbl : TLabel;
  c : char;
  sqrSave, sqrCancel, line : TShape;
  I: byte;
begin
  Done := false;

  for I := 1 to Length(Prompt) do
    sCaption := sCaption + Prompt[i] + ' ';

  sCaption[Length(sCaption)] := #0; //remove last space;
  frm := TForm.CreateNew(Nil, 0);
  frm.AlphaBlend := true; // allow for blending with back
  frm.AlphaBlendValue := 0; //no visiblity;

  lbl := TLabel.Create(frm);
  lbl.Parent := frm;
  lbl.Caption := sCaption;
  lbl.Font.Name := 'Arial';
  lbl.Font.Size := 18;
  lbl.Font.Color := $5D2FFF;
  lbl.Font.Style := [fsBold];
  if lbl.Width > frm.ClientWidth - 40 then
    frm.ClientWidth := lbl.Width + 40;
  lbl.left := round((frm.ClientWidth/2) - (lbl.Width/2));
  lbl.Top := 20;

  frm.Position := poScreenCenter;
  frm.BorderStyle := bsNone;
  rgn := CreateRoundRectRgn(0,  // x-coordinate of the region's upper-left corner
    0,                          // y-coordinate of the region's upper-left corner
    frm.ClientWidth,            // x-coordinate of the region's lower-right corner
    frm.ClientHeight,           // y-coordinate of the region's lower-right corner
    20,                         // height of ellipse for rounded corners
    20);                        // width of ellipse for rounded corners
  SetWindowRgn(frm.Handle, rgn, True);
  frm.Color := rgb(168,244,255);
  frm.DoubleBuffered := true;

  sqrSave := TShape.Create(frm);
  sqrCancel := TShape.Create(frm);
  sqrSave.Pen.Style := psClear;
  sqrCancel.Pen.Style := psClear;
  sqrSave.Brush.Color := rgb(105, 221, 255);
  sqrCancel.Brush.Color := rgb(105, 221, 255);
  sqrSave.Parent := frm;
  sqrCancel.Parent := frm;
  sqrSave.Width := round(frm.Width/2) - 2;
  sqrCancel.Width := round(frm.Width/2) - 2;
  sqrSave.Top := frm.Height - sqrSave.Height;
  sqrCancel.Top := frm.Height - sqrSave.Height;
  sqrCancel.Left := frm.ClientWidth - sqrCancel.Width;

  lblText := TLabel.Create(frm);
  lblText.Parent := frm;
  lblText.Font.Color := $3A2FFF;
  lblText.Font.Name := 'Arial';
  lblText.Top := round((sqrSave.Top/2) - (lbltext.Height/2)) ;
  lblText.Font.Size := 24;
  //lblText.Caption := 'OOOOOOOOOOOO';  //LONGEST STRING POSSIBLE

  line := TShape.Create(frm);
  line.Pen.Style := psClear;
  line.Brush.color := $5D2FFF;
  line.Parent := frm;
  line.Height := 5;
  line.Width := frm.Width - 40;
  line.left := round((frm.ClientWidth/2) - (line.Width/2));
  line.Top := lbltext.Top + lblText.Height;

  lblDebug := TLabel.Create(frm);
  lblDebug.Parent := frm;

  lbl := TLabel.Create(frm);
  lbl.Parent := frm;
  lbl.Caption := 'O K';
  lbl.Font.Name := 'Arial';
  lbl.Font.Size := 18;
  lbl.Font.Color := rgb(105,97,225);
  lbl.Font.Style := [fsBold];
  lbl.Top := round(sqrSave.Top + (sqrSave.Height/2) - (lbl.Height/2));
  lbl.left := round((sqrsave.Width/2) - (lbl.Width/2));

  lbl := TLabel.Create(frm);
  lbl.Parent := frm;
  lbl.Caption := 'C A N C E L';
  lbl.Font.Name := 'Arial';
  lbl.Font.Size := 18;
  lbl.Font.Color := rgb(105,97,225);
  lbl.Font.Style := [fsBold];
  lbl.Top := round(sqrSave.Top + (sqrSave.Height/2) - (lbl.Height/2));
  lbl.left := round(sqrCancel.Left + (sqrCancel.Width/2) - (lbl.Width/2));

  frm.Show;
  i := 0;
  while i < 250 do           //Gives window a slight transparent glass look and fades in.
  begin
    inc(i, 2);
    frm.AlphaBlendValue := i;
    sleep(1);
    Application.ProcessMessages;
  end;


  while not Done do
  begin
    frm.BringToFront;
    lblText.Caption := Text;
    lblText.left := round((frm.ClientWidth/2) - (lblText.Width/2));
      {text entering}
      for c := 'A' to 'Z' do
      begin
        if GetKeyState(ord(c)) < 0 then
          Text := Text + c;
        while GetKeyState(ord(c)) < 0 do
          Application.ProcessMessages;
      end;
      for c := '0' to '9' do
      begin
        if GetKeyState(ord(c)) < 0 then
          Text := Text + c;
        while GetKeyState(ord(c)) < 0 do
          Application.ProcessMessages;
      end;
      if GetKeyState(VK_SPACE) < 0 then
        Text := Text + ' ';
      while GetKeyState(VK_SPACE) < 0 do
        Application.ProcessMessages;
    if GetKeyState(VK_BACK) < 0 then
      Delete(Text, Length(Text), 1);
    while GetKeyState(VK_BACK) < 0 do
      Application.ProcessMessages;

    {save button}
    if (mouse.CursorPos.X >= sqrSave.ClientToScreen(Point(0, 0)).X) AND
      (mouse.CursorPos.X <= sqrSave.ClientToScreen(Point(sqrSave.Width, 0)).X)
      AND (mouse.CursorPos.Y >= sqrSave.ClientToScreen(Point(0, 0)).Y) AND
      (mouse.CursorPos.Y <= sqrSave.ClientToScreen(Point(0, sqrSave.Height))
        .Y) then
    begin
      while GETGVALUE(sqrSave.Brush.Color) > $BE do
      begin
        sqrSave.Brush.Color := sqrSave.Brush.Color - $000100;
        sleep(5);
        Application.ProcessMessages;
      end;
      if GetKeyState(VK_LBUTTON) < 0 then
        Done := true;
    end
    else
    begin
      while GETGVALUE(sqrSave.Brush.Color) < $DD do
      begin
        sqrSave.Brush.Color := sqrSave.Brush.Color + $000100;
        sleep(5);
        Application.ProcessMessages;
      end;
    end;

    {cancel button}
    if (mouse.CursorPos.X >= sqrCancel.ClientToScreen(Point(0, 0)).X) AND
      (mouse.CursorPos.X <= sqrCancel.ClientToScreen(Point(sqrCancel.Width, 0)).X)
      AND (mouse.CursorPos.Y >= sqrCancel.ClientToScreen(Point(0, 0)).Y) AND
      (mouse.CursorPos.Y <= sqrCancel.ClientToScreen(Point(0, sqrCancel.Height))
        .Y) then
    begin
      while GETGVALUE(sqrCancel.Brush.Color) > $BE do
      begin
        sqrCancel.Brush.Color := sqrCancel.Brush.Color - $000100;
        sleep(5);
        Application.ProcessMessages;
      end;
      if GetKeyState(VK_LBUTTON) < 0 then
      begin
        Done := true;
        Text := Default;
      end;
    end
    else
    begin
      while GETGVALUE(sqrCancel.Brush.Color) < $DD do
      begin
        sqrCancel.Brush.Color := sqrCancel.Brush.Color + $000100;
        sleep(5);
        Application.ProcessMessages;
      end;
    end;
      //sqrSave.Brush.Color := rgb(105, 221, 255);
    Application.ProcessMessages;
    //lblDebug.Caption := Format('DEBUG: X: %04d; Y: %04d ~~ X: %04d' , [mouse.CursorPos.x, mouse.cursorpos.y, sqrSave.ClientToScreen(Point(0,0)).X]);

  end;
  i := 250;
  while i > 2 do
  begin
    dec(i, 2);
    frm.AlphaBlendValue := i;
    sleep(1);
    Application.ProcessMessages;
  end;
  frm.Destroy;
  result := text;
end;

function RequestSaveName : string;
var
  frm : TForm;
  rgn: HRGN;
  Text : string;
  Done : boolean;
  lblText, lblDebug, lbl : TLabel;
  c : char;
  i : byte;
  sqrSave, sqrCancel, line : TShape;
begin
  Done := false;

  frm := TForm.CreateNew(Nil, 0);
  frm.Position := poScreenCenter;
  frm.BorderStyle := bsNone;
  rgn := CreateRoundRectRgn(0,  // x-coordinate of the region's upper-left corner
    0,                          // y-coordinate of the region's upper-left corner
    frm.ClientWidth,            // x-coordinate of the region's lower-right corner
    frm.ClientHeight,           // y-coordinate of the region's lower-right corner
    20,                         // height of ellipse for rounded corners
    20);                        // width of ellipse for rounded corners
  SetWindowRgn(frm.Handle, rgn, True);
  frm.Color := rgb(168,244,255);
  frm.DoubleBuffered := true;
  frm.AlphaBlend := true;
  frm.AlphaBlendValue := 0;

  sqrSave := TShape.Create(frm);
  sqrCancel := TShape.Create(frm);
  sqrSave.Pen.Style := psClear;
  sqrCancel.Pen.Style := psClear;
  sqrSave.Brush.Color := rgb(105, 221, 255);
  sqrCancel.Brush.Color := rgb(105, 221, 255);
  sqrSave.Parent := frm;
  sqrCancel.Parent := frm;
  sqrSave.Width := round(frm.Width/2) - 2;
  sqrCancel.Width := round(frm.Width/2) - 2;
  sqrSave.Top := frm.Height - sqrSave.Height;
  sqrCancel.Top := frm.Height - sqrSave.Height;
  sqrCancel.Left := frm.ClientWidth - sqrCancel.Width;

  lblText := TLabel.Create(frm);
  lblText.Parent := frm;
  lblText.Font.Color := $3A2FFF;
  lblText.Font.Name := 'Arial';
  lblText.Top := round((sqrSave.Top/2) - (lbltext.Height/2)) ;
  lblText.Font.Size := 24;
  lblText.Caption := 'OOOOOOOOOOOO';  //LONGEST STRING POSSIBLE

  line := TShape.Create(frm);
  line.Pen.Style := psClear;
  line.Brush.color := $5D2FFF;
  line.Parent := frm;
  line.Height := 5;
  line.Width := lblText.Width;
  line.left := round((frm.ClientWidth/2) - (line.Width/2));
  line.Top := lbltext.Top + lblText.Height;

  lblDebug := TLabel.Create(frm);
  lblDebug.Parent := frm;

  lbl := TLabel.Create(frm);
  lbl.Parent := frm;
  lbl.Caption := 'S A V E';
  lbl.Font.Name := 'Arial';
  lbl.Font.Size := 18;
  lbl.Font.Color := rgb(105,97,225);
  lbl.Font.Style := [fsBold];
  lbl.Top := round(sqrSave.Top + (sqrSave.Height/2) - (lbl.Height/2));
  lbl.left := round((sqrsave.Width/2) - (lbl.Width/2));

  lbl := TLabel.Create(frm);
  lbl.Parent := frm;
  lbl.Caption := 'C A N C E L';
  lbl.Font.Name := 'Arial';
  lbl.Font.Size := 18;
  lbl.Font.Color := rgb(105,97,225);
  lbl.Font.Style := [fsBold];
  lbl.Top := round(sqrSave.Top + (sqrSave.Height/2) - (lbl.Height/2));
  lbl.left := round(sqrCancel.Left + (sqrCancel.Width/2) - (lbl.Width/2));

  lbl := TLabel.Create(frm);
  lbl.Parent := frm;
  lbl.Caption := 'S A V E   G A M E   T O';
  lbl.Font.Name := 'Arial';
  lbl.Font.Size := 18;
  lbl.Font.Color := $5D2FFF;
  lbl.Font.Style := [fsBold];
  lbl.left := round((frm.ClientWidth/2) - (lbl.Width/2));
  lbl.Top := 20;

  lbltext.Caption := '';
  frm.Show;
  i := 0;
  while i < 250 do
  begin
    inc(i, 2);
    frm.AlphaBlendValue := i;
    sleep(1);
    Application.ProcessMessages;
  end;


  while not Done do
  begin
    frm.BringToFront ;
    lblText.Caption := Text;
    lblText.left := round((frm.ClientWidth/2) - (lblText.Width/2));
    if Length(Text) <= 11 then
    begin
      {text entering}
      for c := 'A' to 'Z' do
      begin
        if GetKeyState(ord(c)) < 0 then
          Text := Text + c;
        while GetKeyState(ord(c)) < 0 do
          Application.ProcessMessages;
      end;
      for c := '0' to '9' do
      begin
        if GetKeyState(ord(c)) < 0 then
          Text := Text + c;
        while GetKeyState(ord(c)) < 0 do
          Application.ProcessMessages;
      end;
      if GetKeyState(VK_SPACE) < 0 then
        Text := Text + ' ';
      while GetKeyState(VK_SPACE) < 0 do
        Application.ProcessMessages;
    end;
    if GetKeyState(VK_BACK) < 0 then
      Delete(Text, Length(Text), 1);
    while GetKeyState(VK_BACK) < 0 do
      Application.ProcessMessages;

    //save button
    if (mouse.CursorPos.X >= sqrSave.ClientToScreen(Point(0, 0)).X) AND
      (mouse.CursorPos.X <= sqrSave.ClientToScreen(Point(sqrSave.Width, 0)).X)
      AND (mouse.CursorPos.Y >= sqrSave.ClientToScreen(Point(0, 0)).Y) AND
      (mouse.CursorPos.Y <= sqrSave.ClientToScreen(Point(0, sqrSave.Height))
        .Y) then
    begin
      while GETGVALUE(sqrSave.Brush.Color) > $BE do
      begin
        sqrSave.Brush.Color := sqrSave.Brush.Color - $000100;
        sleep(5);
        Application.ProcessMessages;
      end;
      if GetKeyState(VK_LBUTTON) < 0 then
        Done := true;
    end
    else
    begin
      while GETGVALUE(sqrSave.Brush.Color) < $DD do
      begin
        sqrSave.Brush.Color := sqrSave.Brush.Color + $000100;
        sleep(5);
        Application.ProcessMessages;
      end;
    end;

    //cancel button
    if (mouse.CursorPos.X >= sqrCancel.ClientToScreen(Point(0, 0)).X) AND
      (mouse.CursorPos.X <= sqrCancel.ClientToScreen(Point(sqrCancel.Width, 0)).X)
      AND (mouse.CursorPos.Y >= sqrCancel.ClientToScreen(Point(0, 0)).Y) AND
      (mouse.CursorPos.Y <= sqrCancel.ClientToScreen(Point(0, sqrCancel.Height))
        .Y) then
    begin
      while GETGVALUE(sqrCancel.Brush.Color) > $BE do
      begin
        sqrCancel.Brush.Color := sqrCancel.Brush.Color - $000100;
        sleep(5);
        Application.ProcessMessages;
      end;
      if GetKeyState(VK_LBUTTON) < 0 then
      begin
        Done := true;
        Text := '';
      end;
    end
    else
    begin
      while GETGVALUE(sqrCancel.Brush.Color) < $DD do
      begin
        sqrCancel.Brush.Color := sqrCancel.Brush.Color + $000100;
        sleep(5);
        Application.ProcessMessages;
      end;
    end;
      //sqrSave.Brush.Color := rgb(105, 221, 255);
    Application.ProcessMessages;
    //lblDebug.Caption := Format('DEBUG: X: %04d; Y: %04d ~~ X: %04d' , [mouse.CursorPos.x, mouse.cursorpos.y, sqrSave.ClientToScreen(Point(0,0)).X]);

  end;
  i := 250;
  while i > 2 do
  begin
    dec(i, 2);
    frm.AlphaBlendValue := i;
    sleep(1);
    Application.ProcessMessages;
  end;
  frm.Destroy;
  result := text;
end;

function OverwriteRequest : boolean;
var
  frm : TForm;
  rgn: HRGN;
  Done : boolean;
  lbl : TLabel;
  i : byte;
  sqrSave, sqrCancel : TShape;
begin
  Done := false;

  frm := TForm.CreateNew(Nil, 0);
  frm.BorderStyle := bsNone;
  frm.AlphaBlend := true;
  frm.AlphaBlendValue := 0;

  lbl := TLabel.Create(frm);
  lbl.Parent := frm;
  lbl.Caption := 'T H E   F I L E   E X I S T S ,   O V E R W R I T E ?';
  lbl.Font.Name := 'Arial';
  lbl.Font.Size := 18;
  lbl.Font.Color := $5D2FFF;
  lbl.Font.Style := [fsBold];

  frm.ClientWidth := lbl.Width + 40;

  lbl.left := round((frm.ClientWidth/2) - (lbl.Width/2));
  lbl.Top := 20;

  frm.ClientHeight := 65 + lbl.Top + lbl.Height + 20;

  sqrSave := TShape.Create(frm);
  sqrCancel := TShape.Create(frm);
  sqrSave.Pen.Style := psClear;
  sqrCancel.Pen.Style := psClear;
  sqrSave.Brush.Color := rgb(105, 221, 255);
  sqrCancel.Brush.Color := rgb(105, 221, 255);
  sqrSave.Parent := frm;
  sqrCancel.Parent := frm;
  sqrSave.Width := round(frm.Width/2) - 2;
  sqrCancel.Width := round(frm.Width/2) - 2;
  sqrSave.Top := frm.Height - sqrSave.Height;
  sqrCancel.Top := frm.Height - sqrSave.Height;
  sqrCancel.Left := frm.ClientWidth - sqrCancel.Width;

  lbl := TLabel.Create(frm);
  lbl.Parent := frm;
  lbl.Caption := 'S A V E';
  lbl.Font.Name := 'Arial';
  lbl.Font.Size := 18;
  lbl.Font.Color := rgb(105,97,225);
  lbl.Font.Style := [fsBold];
  lbl.Top := round(sqrSave.Top + (sqrSave.Height/2) - (lbl.Height/2));
  lbl.left := round((sqrsave.Width/2) - (lbl.Width/2));

  lbl := TLabel.Create(frm);
  lbl.Parent := frm;
  lbl.Caption := 'C A N C E L';
  lbl.Font.Name := 'Arial';
  lbl.Font.Size := 18;
  lbl.Font.Color := rgb(105,97,225);
  lbl.Font.Style := [fsBold];
  lbl.Top := round(sqrSave.Top + (sqrSave.Height/2) - (lbl.Height/2));
  lbl.left := round(sqrCancel.Left + (sqrCancel.Width/2) - (lbl.Width/2));

  frm.Position := poScreenCenter;

  rgn := CreateRoundRectRgn(0,  // x-coordinate of the region's upper-left corner
    0,                          // y-coordinate of the region's upper-left corner
    frm.ClientWidth,            // x-coordinate of the region's lower-right corner
    frm.ClientHeight,           // y-coordinate of the region's lower-right corner
    20,                         // height of ellipse for rounded corners
    20);                        // width of ellipse for rounded corners
  SetWindowRgn(frm.Handle, rgn, True);
  frm.Color := rgb(168,244,255);
  frm.DoubleBuffered := true;
  frm.Show;

  i := 0;
  while i < 250 do
  begin
    inc(i, 2);
    frm.AlphaBlendValue := i;
    sleep(1);
    Application.ProcessMessages;
  end;

  while not done do
  begin
    frm.BringToFront;
    if (mouse.CursorPos.X >= sqrSave.ClientToScreen(Point(0, 0)).X) AND
      (mouse.CursorPos.X <= sqrSave.ClientToScreen(Point(sqrSave.Width, 0)).X)
      AND (mouse.CursorPos.Y >= sqrSave.ClientToScreen(Point(0, 0)).Y) AND
      (mouse.CursorPos.Y <= sqrSave.ClientToScreen(Point(0, sqrSave.Height))
        .Y) then
    begin
      while GETGVALUE(sqrSave.Brush.Color) > $BE do
      begin
        sqrSave.Brush.Color := sqrSave.Brush.Color - $000100;
        sleep(5);
        Application.ProcessMessages;
      end;
      if GetKeyState(VK_LBUTTON) < 0 then
        Done := true;
        result := true;
    end
    else
    begin
      while GETGVALUE(sqrSave.Brush.Color) < $DD do
      begin
        sqrSave.Brush.Color := sqrSave.Brush.Color + $000100;
        sleep(5);
        Application.ProcessMessages;
      end;
    end;

    if (mouse.CursorPos.X >= sqrCancel.ClientToScreen(Point(0, 0)).X) AND
      (mouse.CursorPos.X <= sqrCancel.ClientToScreen(Point(sqrCancel.Width, 0)).X)
      AND (mouse.CursorPos.Y >= sqrCancel.ClientToScreen(Point(0, 0)).Y) AND
      (mouse.CursorPos.Y <= sqrCancel.ClientToScreen(Point(0, sqrCancel.Height))
        .Y) then
    begin
      while GETGVALUE(sqrCancel.Brush.Color) > $BE do
      begin
        sqrCancel.Brush.Color := sqrCancel.Brush.Color - $000100;
        sleep(5);
        Application.ProcessMessages;
      end;
      if GetKeyState(VK_LBUTTON) < 0 then
      begin
        Done := true;
        result := false;
      end;
    end
    else
    begin
      while GETGVALUE(sqrCancel.Brush.Color) < $DD do
      begin
        sqrCancel.Brush.Color := sqrCancel.Brush.Color + $000100;
        sleep(5);
        Application.ProcessMessages;
      end;
    end;
    Application.ProcessMessages;
  end;
  i := 250;
  while i > 2 do
  begin
    dec(i, 2);
    frm.AlphaBlendValue := i;
    sleep(1);
    Application.ProcessMessages;
  end;
  frm.Destroy;
end;

function ChooseLoadDlg(loadFileName : string) : string;
var
  frm : TForm;
  rgn: HRGN;
  Done : boolean;
  lbl : TLabel;
  sR : array of string; //FilePaths ~~ R Stands for response
  i, y, i2 : integer;
  clickRegions : array of trect;
  rects : array of TShape;
  tS : TextFile;
begin
  if not fileExists(loadFileName) then exit;

  AssignFile(tS, loadFileName);
  reset(tS);
  Done := false;

  frm := TForm.CreateNew(nil, 0);
  frm.BorderStyle := bsNone;
  frm.AlphaBlend := true;
  frm.AlphaBlendValue := 0;

  lbl := TLabel.Create(frm);
  lbl.Parent := frm;
  lbl.Caption := 'C H O O S E   G A M E   T O   L O A D';
  lbl.Font.Name := 'Arial';
  lbl.Font.Size := 18;
  lbl.Font.Color := $5D2FFF;
  lbl.Font.Style := [fsBold];

  frm.ClientWidth := lbl.Width + 40;

  lbl.left := round((frm.ClientWidth/2) - (lbl.Width/2));
  lbl.Top := 20;

  i := 0;
  while not eof(tS) do
  begin
    inc(i);
    SetLength(rects, i);
    SetLength(clickRegions, i);
    SetLength(sR, i);
    rects[i-1] := TShape.Create(frm);
    with rects[i-1] do
    begin
      Parent := frm;
      Width := frm.ClientWidth;
      brush.Color := $FFDD69;
      top := i*(height+5);
      pen.Style := psClear;
    end;
    readln(tS, sR[i - 1]);
    lbl := TLabel.Create(frm);
    with lbl do
    begin
      parent := frm;
      Font.Name := 'Arial';
      Font.Size := 18;
      Font.Color := rgb(105,97,225);
      Font.Style := [fsBold];
      Top := round(rects[i-1].Top + (rects[i-1].Height/2) - (Height/2)) ;
      Caption := sR[i-1];
      Left := round((frm.Width/2) - (lbl.Width/2));
    end;
  end;

  closefile(tS);

  frm.ClientHeight := rects[i-1].Top + rects[i-1].Height + 20;
  frm.Position := poScreenCenter;

  rgn := CreateRoundRectRgn(0,  // x-coordinate of the region's upper-left corner
    0,                          // y-coordinate of the region's upper-left corner
    frm.ClientWidth,            // x-coordinate of the region's lower-right corner
    frm.ClientHeight,           // y-coordinate of the region's lower-right corner
    20,                         // height of ellipse for rounded corners
    20);                        // width of ellipse for rounded corners
  SetWindowRgn(frm.Handle, rgn, True);
  frm.Color := rgb(168,244,255);
  frm.DoubleBuffered := true;
  frm.Show;

  i2 := 0;
  while i2 < 250 do
  begin
    inc(i2, 2);
    frm.AlphaBlendValue := i2;
    sleep(1);
    Application.ProcessMessages;
  end;

  for y := 0 to i - 1 do
  begin
    clickRegions[y].Left := rects[y].ClientToScreen(point(0,0)).x;
    clickRegions[y].Top := rects[y].ClientToScreen(point(0,0)).y;
    clickRegions[y].Bottom := rects[y].ClientToScreen(point(0,0 + rects[y].height)).y;
    clickRegions[y].Right := rects[y].ClientToScreen(point(0 + rects[y].width,0)).x;
  end;

  while not done do
  begin
    frm.BringToFront;
    for Y := 0 to i - 1 do
    begin
      if (mouse.CursorPos.X >= clickRegions[y].Left) AND
        (mouse.CursorPos.X <= clickRegions[y].Right) AND
        (mouse.CursorPos.Y >= clickRegions[y].Top) AND
        (mouse.CursorPos.Y <= clickRegions[y].Bottom) then
      begin
        while GETGVALUE(rects[y].Brush.Color) > $BE do
        begin
          rects[y].Brush.Color := rects[y].Brush.Color - $000100;
          sleep(5);
          Application.ProcessMessages;
        end;
        if GetKeyState(VK_LBUTTON) < 0 then
          Done := True;
          result := sR[y];
      end
      else
      begin
        while GETGVALUE(rects[y].Brush.Color) < $DD do
        begin
          rects[y].Brush.Color := rects[y].Brush.Color + $000100;
          sleep(5);
          Application.ProcessMessages;
        end;
      end;
      Application.ProcessMessages;
    end;
    Application.ProcessMessages;
  end;
  i2 := 250;
  while i2 > 2 do
  begin
    dec(i2, 2);
    frm.AlphaBlendValue := i2;
    sleep(1);
    Application.ProcessMessages;
  end;
  frm.Destroy;
end;

end.
