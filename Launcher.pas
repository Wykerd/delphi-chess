unit Launcher;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, pngimage, ExtCtrls, PlayerU, EngineUI, Spin,
  engineFileInterpreter, engineclasses, math, helpU;

type
  TfrmLauncher = class(TForm)
    Image1: TImage;
    sedMonitor: TSpinEdit;
    Label1: TLabel;
    Label2: TLabel;
    sedWidth: TSpinEdit;
    cbxWindowed: TCheckBox;
    lblHeight: TLabel;
    shpPlay: TShape;
    shpDisplaySettings: TShape;
    Label3: TLabel;
    Label4: TLabel;
    tmr: TTimer;
    Label5: TLabel;
    shpClose: TShape;
    Image2: TImage;
    procedure Button2Click(Sender: TObject);
    procedure LaunchGame;
    procedure FormCreate(Sender: TObject);
    procedure sedWidthChange(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure tmrTimer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmLauncher: TfrmLauncher;
  showingSettings : boolean = false;
  iHeight : integer = 360;
  rectPlay, rectSettings : TShape;

const
  heightWOSettings = 335;
  heightWSettings = 460;

implementation

{$R *.dfm}

procedure TfrmLauncher.LaunchGame;
begin
  ChessForm.PlayerRefresh.Enabled := false;
  ChessForm.WindowState := wsNormal;
  ChessForm.Show;
  if not cbxWindowed.checked then
  begin
    ChessForm.Top := screen.Monitors[sedMonitor.Value - 1].Top;
    ChessForm.Left := screen.Monitors[sedMonitor.Value - 1].Left;
    gameHeight := screen.Monitors[sedMonitor.Value - 1].Height;
    gameWidth := screen.Monitors[sedMonitor.Value - 1].Width;
    ChessForm.WindowState := wsMaximized;
  end
  else
  begin
    ChessForm.Top := screen.Monitors[sedMonitor.Value - 1].Top;
    ChessForm.Left := screen.Monitors[sedMonitor.Value - 1].Left;
    gameHeight := iHeight;
    gameWidth := sedWidth.Value;
    ChessForm.ClientHeight := gameHeight;
    ChessForm.ClientWidth := gameWidth;
    ChessForm.roundEdges;
  end;
  ChessForm.reloadGame;
end;

procedure TfrmLauncher.Button2Click(Sender: TObject);
begin
  if showingSettings then
    ClientHeight := heightWOSettings
  else
    ClientHeight := heightWSettings;

  showingSettings := NOT showingSettings;
end;

procedure TfrmLauncher.FormCreate(Sender: TObject);
var
  rgn : HRGN;
begin
  sedMonitor.MaxValue := screen.MonitorCount;
  if screen.MonitorCount = 1 then
    sedMonitor.Enabled := false;
  sedWidth.MaxValue := screen.Width;
  lblHeight.Caption := format('X %d', [iHeight]);
  color := rgb(168,244,255);
  shpDisplaySettings.SendToBack;
  rgn := CreateRoundRectRgn(0,  // x-coordinate of the region's upper-left corner
    0,                          // y-coordinate of the region's upper-left corner
    ClientWidth,            // x-coordinate of the region's lower-right corner
    ClientHeight,           // y-coordinate of the region's lower-right corner
    20,                         // height of ellipse for rounded corners
    20);                        // width of ellipse for rounded corners
  SetWindowRgn(Handle, rgn, True);
end;


procedure TfrmLauncher.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
const
  SC_DRAGMOVE = $F012;
begin
  if WindowState = wsNormal then
    if Button = mbLeft then
    begin
      ReleaseCapture;
      Perform(WM_SYSCOMMAND, SC_DRAGMOVE, 0);
    end;
end;

//Maintain the aspect ratio
procedure TfrmLauncher.sedWidthChange(Sender: TObject);
begin
  if sedWidth.Text <> '' then
    iHeight := ceil(sedWidth.value/(16/9));
  lblHeight.Caption := format('X %d', [iHeight]);
end;

procedure TfrmLauncher.tmrTimer(Sender: TObject);
begin
  
  //Play Game
  if (mouse.CursorPos.X >= shpPlay.ClientToScreen(Point(0, 0)).X) AND
    (mouse.CursorPos.X <= shpPlay.ClientToScreen(Point(shpPlay.Width, 0)).X)
    AND (mouse.CursorPos.Y >= shpPlay.ClientToScreen(Point(0, 0)).Y) AND
    (mouse.CursorPos.Y <= shpPlay.ClientToScreen(Point(0, shpPlay.Height)).Y)
    then
  begin
    while GETGVALUE(shpPlay.Brush.color) > $BE do
    begin
      shpPlay.Brush.color := shpPlay.Brush.color - $000100;
      sleep(5);
      Application.ProcessMessages;
    end;
    if GetKeyState(VK_LBUTTON) < 0 then
    begin
      tmr.Enabled := false;
      hide;
      LaunchGame;
    end;
  end
  else
  begin
    while GETGVALUE(shpPlay.Brush.color) < $DD do
    begin
      shpPlay.Brush.color := shpPlay.Brush.color + $000100;
      sleep(5);
      Application.ProcessMessages;
    end;
  end;

  //DisplaySettings
  if (mouse.CursorPos.X >= shpDisplaySettings.ClientToScreen(Point(0, 0)).X) AND
    (mouse.CursorPos.X <= shpDisplaySettings.ClientToScreen(Point(shpDisplaySettings.Width, 0)).X)
    AND (mouse.CursorPos.Y >= shpDisplaySettings.ClientToScreen(Point(0, 0)).Y) AND
    (mouse.CursorPos.Y <= shpDisplaySettings.ClientToScreen(Point(0, shpDisplaySettings.Height)).Y)
    then
  begin
    while GETGVALUE(shpDisplaySettings.Brush.color) > $BE do
    begin
      shpDisplaySettings.Brush.color := shpDisplaySettings.Brush.color - $000100;
      sleep(5);
      Application.ProcessMessages;
      cbxWindowed.Color := shpDisplaySettings.Brush.Color;
    end;
  end
  else
  begin
    while GETGVALUE(shpDisplaySettings.Brush.color) < $DD do
    begin
      shpDisplaySettings.Brush.color := shpDisplaySettings.Brush.color + $000100;
      sleep(5);
      Application.ProcessMessages;
      cbxWindowed.Color := shpDisplaySettings.Brush.Color;
    end;
  end;

  //Close
  if (mouse.CursorPos.X >= shpClose.ClientToScreen(Point(0, 0)).X) AND
    (mouse.CursorPos.X <= shpClose.ClientToScreen(Point(shpClose.Width, 0)).X)
    AND (mouse.CursorPos.Y >= shpClose.ClientToScreen(Point(0, 0)).Y) AND
    (mouse.CursorPos.Y <= shpClose.ClientToScreen(Point(0, shpClose.Height)).Y)
    then
  begin
    while GETGVALUE(shpClose.Brush.color) > $BE do
    begin
      shpClose.Brush.color := shpClose.Brush.color - $000100;
      sleep(5);
      Application.ProcessMessages;
    end;
    if GetKeyState(VK_LBUTTON) < 0 then
    begin
      tmr.Enabled := false;
      Application.Terminate;
    end;
  end
  else
  begin
    while GETGVALUE(shpClose.Brush.color) < $DD do
    begin
      shpClose.Brush.color := shpClose.Brush.color + $000100;
      sleep(5);
      Application.ProcessMessages;
    end;
  end;
  
end;

end.
