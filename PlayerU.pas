unit PlayerU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, EngineClasses, jpeg, math, StdCtrls, ImgList, ExtCtrls, pngimage,
  Menus, ActnList, EngineAnimations, EngineUI, EngineFileInterpreter, HelpU;

type
  TChessForm = class(TForm)
    AssetsList: TImageList;
    PlayerRefresh: TTimer;
    lblWhiteTitle: TLabel;
    lblBlackTitle: TLabel;
    lblWPiecesTook: TLabel;
    lblBPiecesTook: TLabel;
    highlightblock: TImage;
    imgClose: TImage;
    imgHelp: TImage;
    imgSettings: TImage;
    imgCloseHover: TImage;
    imgHelpHover: TImage;
    imgSettingsHover: TImage;
    imgCloseDef: TImage;
    imgHelpDef: TImage;
    imgSettingsDef: TImage;
    imgSave: TImage;
    imgSaveHover: TImage;
    imgSaveDef: TImage;
    clDlg: TColorDialog;
    Settings: TActionList;
    setWhiteColor: TAction;
    setBlackColor: TAction;
    setOutlineColor: TAction;
    PopupMenu1: TPopupMenu;
    setBackColor: TAction;
    Eggs1: TMenuItem;
    WhitePiece1: TMenuItem;
    BlackColor1: TMenuItem;
    OutlineColor1: TMenuItem;
    autoDeselect: TAction;
    saveDirSet: TAction;
    BackgroundColor1: TMenuItem;
    AutoDeselect1: TMenuItem;
    SaveDirectory1: TMenuItem;
    saveSettings: TAction;
    SaveCurrentSettings1: TMenuItem;
    showDebug: TAction;
    ShowDebug1: TMenuItem;
    resetSettings: TAction;
    ResetSettings1: TMenuItem;
    setAssetsPath: TAction;
    AssetsPack1: TMenuItem;
    setUIScale: TAction;
    ChangeUIScale1: TMenuItem;
    imgLoad: TImage;
    imgLoadHover: TImage;
    imgLoadDef: TImage;
    imgExport: TImage;
    imgExportHover: TImage;
    imgExportDef: TImage;
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure PlayerRefreshTimer(Sender: TObject);
    procedure imgCloseClick(Sender: TObject);
    procedure imgCloseMouseEnter(Sender: TObject);
    procedure imgCloseMouseLeave(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure setWhiteColorExecute(Sender: TObject);
    procedure imgSettingsClick(Sender: TObject);
    procedure setBlackColorExecute(Sender: TObject);
    procedure setOutlineColorExecute(Sender: TObject);
    procedure setBackColorExecute(Sender: TObject);
    procedure autoDeselectExecute(Sender: TObject);
    procedure saveDirSetExecute(Sender: TObject);
    procedure SetSettings;
    procedure saveSettingsExecute(Sender: TObject);
    procedure showDebugExecute(Sender: TObject);
    procedure resetSettingsExecute(Sender: TObject);
    procedure reloadGame;
    procedure setAssetsPathExecute(Sender: TObject);
    procedure roundEdges;
    procedure ScaleComponents;
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure imgSaveClick(Sender: TObject);
    procedure setUIScaleExecute(Sender: TObject);
    procedure imgHelpClick(Sender: TObject);
    procedure imgHelpMouseEnter(Sender: TObject);
    procedure imgHelpMouseLeave(Sender: TObject);
    procedure imgSettingsMouseEnter(Sender: TObject);
    procedure imgSettingsMouseLeave(Sender: TObject);
    procedure imgSaveMouseEnter(Sender: TObject);
    procedure imgSaveMouseLeave(Sender: TObject);
    procedure lblWhiteTitleClick(Sender: TObject);
    procedure lblBlackTitleClick(Sender: TObject);
    procedure imgLoadClick(Sender: TObject);
    procedure imgExportClick(Sender: TObject);
    procedure imgLoadMouseEnter(Sender: TObject);
    procedure imgLoadMouseLeave(Sender: TObject);
    procedure imgExportMouseEnter(Sender: TObject);
    procedure imgExportMouseLeave(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ChessForm: TChessForm;
  BoardMannager: TBoardMannager;
  highlightblock: TImage;
  SaveManager: TSaveManager;
  AssetPath: string = 'default';
  turnColor : TColor;
  selectColor : TColor;
  scaleMultplier : real = 1;
  // WindowToggles : TWindowToggles;

implementation

{$R *.dfm}

procedure TChessForm.autoDeselectExecute(Sender: TObject);
begin
  BoardMannager.autoDeselect := not BoardMannager.autoDeselect;
  autoDeselect.Checked := BoardMannager.autoDeselect
end;

procedure TChessForm.FormCreate(Sender: TObject);
var
  tempbm: TBitmap;
  settingDat: string;
begin
  settingDat := getdata('_SETTINGS.DWCS', 'AssetsDir');
  if DirectoryExists(settingDat) then
    AssetPath := settingDat
  else
    AssetPath := 'default';
  if AssetPath <> 'default' then
    imageSize := StrToInt(getdata(AssetPath + '\_SETUP.DWCS', 'ImageSize'))
  else
    imageSize := 32;

  tempbm := TBitmap.Create;
  with tempbm do
  begin
    PixelFormat := pf32bit;
    Height := imageSize;
    Width := Height;
  end;

  BoardMannager := TBoardMannager.Create(Self);
  // Setup save manager;
  SaveManager := TSaveManager.Create(Self);
  SaveManager.LinkedBoard := BoardMannager;
  if not DirectoryExists('SAVES') then
    CreateDir('SAVES');
  SaveManager.rootDir := 'SAVES';

  color := rgb(102, 202, 255); // sets background color

  SetSettings;

  if AssetPath <> 'default' then
    // Load the bitmaps
    try
      tempbm.LoadFromFile(AssetPath + '\bishop.bmp');
      BoardMannager.Bishop.Canvas.Draw(0, 0, tempbm);
      tempbm.LoadFromFile(AssetPath + '\castle.bmp');
      BoardMannager.Castle.Canvas.Draw(0, 0, tempbm);
      tempbm.LoadFromFile(AssetPath + '\horse.bmp');
      BoardMannager.horse.Canvas.Draw(0, 0, tempbm);
      tempbm.LoadFromFile(AssetPath + '\king.bmp');
      BoardMannager.king.Canvas.Draw(0, 0, tempbm);
      tempbm.LoadFromFile(AssetPath + '\pawn.bmp');
      BoardMannager.pawn.Canvas.Draw(0, 0, tempbm);
      tempbm.LoadFromFile(AssetPath + '\queen.bmp');
      BoardMannager.queen.Canvas.Draw(0, 0, tempbm);
    finally
      BoardMannager.Orientation := orTop_Bottom;
      BoardMannager.InitialDraw;
    end
  else
    try
      AssetsList.Draw(BoardMannager.Bishop.Canvas, 0, 0, 0, true);
      AssetsList.Draw(BoardMannager.Castle.Canvas, 0, 0, 1, true);
      AssetsList.Draw(BoardMannager.horse.Canvas, 0, 0, 2, true);
      AssetsList.Draw(BoardMannager.king.Canvas, 0, 0, 3, true);
      AssetsList.Draw(BoardMannager.pawn.Canvas, 0, 0, 4, true);
      AssetsList.Draw(BoardMannager.queen.Canvas, 0, 0, 5, true);
    finally
      // Free the blank assets from memory
      // FreeAndNil(AssetsList);             //Do not free to allow reset
      BoardMannager.Orientation := orTop_Bottom;
      BoardMannager.InitialDraw;
    end;
  scalecomponents;

  autoDeselect.Checked := BoardMannager.autoDeselect;
  showDebug.Checked := BoardMannager.debug.Visible;

end;

procedure TChessForm.FormDestroy(Sender: TObject);
begin
  BoardMannager.destroy;
end;

procedure TChessForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case key of
    VK_ESCAPE:
    begin
      if boardmannager.selected then
      begin
      boardmannager.selected := false;
      if boardmannager.Turn = 1 then
        boardmannager.turn := 2
      else
        boardmannager.turn := 1;

      boardmannager.debug.println('Deselected - turn reverted to ' + IntToStr(boardmannager.Turn) + nl);
      end;
    end;
    VK_END:
    begin
      BoardMannager.Clear;
      BoardMannager.InitialDraw;
    end;
    ord('S'):
    begin
      Savemanager.SaveRequest;
    end;
    ord('L'):
    begin
      Savemanager.LoadRequest;
    end;
  end;
end;

procedure TChessForm.FormMouseDown(Sender: TObject; Button: TMouseButton;
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

procedure TChessForm.imgCloseClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TChessForm.imgCloseMouseEnter(Sender: TObject);
begin
  imgClose.Picture := imgCloseHover.Picture;
end;

procedure TChessForm.imgCloseMouseLeave(Sender: TObject);
begin
  imgClose.Picture := imgCloseDef.Picture;
end;

procedure TChessForm.imgExportClick(Sender: TObject);
begin
  PGNExport([Boardmannager.PlayerNameWhite, BoardMannager.Playernameblack], self);
end;

procedure TChessForm.imgExportMouseEnter(Sender: TObject);
begin
  imgExport.Picture := imgExportHover.Picture;
end;

procedure TChessForm.imgExportMouseLeave(Sender: TObject);
begin
  imgExport.Picture := imgExportDef.Picture;
end;

procedure TChessForm.imgHelpClick(Sender: TObject);
var
  i : byte;
begin
  frmHelp.showmodal;
end;

procedure TChessForm.imgHelpMouseEnter(Sender: TObject);
begin
  imgHelp.Picture := imgHelpHover.Picture;
end;

procedure TChessForm.imgHelpMouseLeave(Sender: TObject);
begin
  imgHelp.Picture := imgHelpDef.Picture;
end;

procedure TChessForm.imgLoadClick(Sender: TObject);
begin
  SaveManager.LoadRequest;
end;

procedure TChessForm.imgLoadMouseEnter(Sender: TObject);
begin
  imgLoad.Picture := imgLoadHover.Picture;
end;

procedure TChessForm.imgLoadMouseLeave(Sender: TObject);
begin
  imgLoad.Picture := imgLoadDef.Picture;
end;

procedure TChessForm.imgSaveClick(Sender: TObject);
begin
  SaveManager.SaveRequest;
end;

procedure TChessForm.imgSaveMouseEnter(Sender: TObject);
begin
  imgSave.Picture := imgSaveHover.Picture;
end;

procedure TChessForm.imgSaveMouseLeave(Sender: TObject);
begin
  imgSave.Picture := imgSaveDef.Picture;
end;

procedure TChessForm.imgSettingsClick(Sender: TObject);
begin
  PopupMenu1.Popup(imgSettings.ClientToScreen(point(0,0)).x, imgSettings.ClientToScreen(point(0,0)).y);
end;

procedure TChessForm.imgSettingsMouseEnter(Sender: TObject);
begin
  imgSettings.Picture := imgSettingsHover.Picture;
end;

procedure TChessForm.imgSettingsMouseLeave(Sender: TObject);
begin
  imgSettings.Picture := imgSettingsDef.Picture;
end;

procedure TChessForm.lblBlackTitleClick(Sender: TObject);
begin
  BoardMannager.PlayerNameBlack := InputBoxP('SET PLAYER NAME', TLabel(Sender).Caption);
end;

procedure TChessForm.lblWhiteTitleClick(Sender: TObject);
begin
  BoardMannager.PlayerNameWhite := InputBoxP('SET PLAYER NAME', TLabel(Sender).Caption);
end;

procedure TChessForm.PlayerRefreshTimer(Sender: TObject);
var
  sWPT, sBPT : string;
  I: Integer; //caption of pieces took;
  y, x, newKind: Integer;
begin
  //Simple algorithm to get color for turn and selected
  turnColor := RGB(GetGValue(Color), GetBValue(Color), GetRValue(Color));
  selectColor := RGB(GetBValue(Color), GetRValue(Color), GetGValue(Color));

  lblWhiteTitle.Caption := BoardMannager.PlayerNameWhite;
  lblBlackTitle.Caption := BoardMannager.PlayerNameBlack;

  for I := 0 to boardmannager.getBlackTooklength  do
  begin
    case boardMannager.BlackPiecesTook[i] of
      0: ;
      1: sBPT := sBPT + 'Pawn' + nl;
      2: sBPT := sBPT + 'Rook' + nl;   //castle
      3: sBPT := sBPT + 'Bishop' + nl;
      4: sBPT := sBPT + 'Knight' + nl;    //horse
      5: sBPT := sBPT + 'Queen' + nl;
      else
      sBPT := sBPT + 'Unknown, This message should not appear (' + IntToStr(boardmannager.BlackPiecesTook[i]) + ')' + nl;
    end;
  end;

  for I := 0 to boardmannager.getWhiteTooklength  do
  begin
    case boardMannager.WhitePiecesTook[i] of
      0: ;
      1: sWPT := sWPT + 'Pawn' + nl;
      2: sWPT := sWPT + 'Rook' + nl;
      3: sWPT := sWPT + 'Bishop' + nl;
      4: sWPT := sWPT + 'Knight' + nl;
      5: sWPT := sWPT + 'Queen' + nl;
      else
      sWPT := sWPT + 'Unknown, This message should not appear (' + IntToStr(boardmannager.WhitePiecesTook[i]) + ')' + nl;
    end;
  end;

  lblWPiecesTook.caption := sWPT;
  lblBPiecesTook.Caption := sBPT;

  if (BoardMannager.turn = 1) AND (Not BoardMannager.Selected) then
  begin
    lblWhiteTitle.font.Color := turncolor;
    lblBlackTitle.font.Color := clblack;
  end
  else if (BoardMannager.turn = 2) AND (Not BoardMannager.Selected) then
  begin
    lblWhiteTitle.font.Color := clblack;
    lblBlackTitle.font.Color := turncolor;
  end
  else if (BoardMannager.turn = 2) AND (BoardMannager.Selected) then
  begin
    lblWhiteTitle.font.Color := selectcolor;
    lblBlackTitle.font.Color := clblack;
  end
  else if (BoardMannager.turn = 1) AND (BoardMannager.Selected) then
  begin
    lblWhiteTitle.font.Color := clblack;
    lblBlackTitle.font.Color := selectcolor;
  end;

  //Checks for pawn at end of board to change to queen.
  with boardmannager do
  begin
    if Orientation = orTop_Bottom then
    begin
    for y := 1 to 2 do
      for x := 1 to 8 do
        if (board[x, y * 7 -6].kind = 1) then
        begin
          board[x, y * 7 -6].Kind := 0;
          newKind := pickpawnpromotion;
          SetSquareTo(point(x, y* 7 -6), newKind);
          PGNPrint('=' + pgnpieceNotation[newKind] + ' ');
        end
        else if (board[x, y * 7 -6].kind = -1) then
        begin
          board[x, y * 7 -6].Kind := 0;
          newKind := pickpawnpromotion;
          SetSquareTo(point(x, y* 7 -6), -1 * newKind);
          PGNPrint('='+ pgnpieceNotation[newKind] + ' ');
          if ((numMoves mod 5) = 0) then
            PGNPrint(#13#10);
        end;
    end
    else
    begin
    for x := 1 to 2 do
      for y := 1 to 8 do
        if board[x * 7 -6, y].kind = 1 then
        begin
          board[x * 7 -6, y].Kind := 0;
          newKind := pickpawnpromotion;
          SetSquareTo(point(x * 7 -6, y), newKind);
        end
        else if board[x * 7 -6, y].kind = -1 then
        begin
          board[x * 7 -6, y].Kind := 0;
          newKind := pickpawnpromotion;
          SetSquareTo(point(x * 7 -6, y), -1 * newKind);
        end;
    end; //end else ( if orLeft_Right or invalid(default to Left Right) )

  end; //end with
  if boardmannager.selected then
  begin
    highlightblock.Visible := true;
    highlightblock.Top := boardmannager.SelectedSqr.Top;
    highlightblock.Left := boardmannager.SelectedSqr.left;
  end
  else
    highlightblock.Visible := false;
end;

procedure TChessForm.reloadGame;
begin
  animationscanshow := false; //Disable dropdown messages ~~ Speeds up refresh!
  SaveManager.SaveToFileOverwrite('_RESETTEMP.DWCS');
  PlayerRefresh.Enabled := false; //Disable the timer teporarily during reset
  BoardMannager.destroy;
  BoardMannager := nil;
  SaveManager.Destroy;
  FormCreate(nil);
  SaveManager.LoadFromFile('_RESETTEMP.DWCS');
  DeleteFile('_RESETTEMP.DWCS');
  DeleteFile('_RESETTEMP.PGN');
  animationscanshow := true;
  PlayerRefresh.Enabled := true;
end;

procedure TChessForm.resetSettingsExecute(Sender: TObject);
var
  tS : textfile;
begin
  assignfile(ts, '_SETTINGS.DWCS');
  rewrite(ts);
  write(tS, 'WhiteColor=[default]'#13#10'BlackColor=[default]'#13#10'OutlineColor=[default]'#13#10'BackColor=[default]'#13#10'SaveDir=[default]'#13#10'AutoDeselect=[default]'#13#10'ShowDebug=[default]'#13#10'AssetsDir=[default]'#13#10'END');
  closefile(tS);
  reloadGame;
end;

procedure TChessForm.roundEdges;
var
  rgn : HRGN;
begin
  rgn := CreateRoundRectRgn(0,  // x-coordinate of the region's upper-left corner
    0,                          // y-coordinate of the region's upper-left corner
    chessform.ClientWidth,            // x-coordinate of the region's lower-right corner
    chessform.ClientHeight,           // y-coordinate of the region's lower-right corner
    40,                         // height of ellipse for rounded corners
    40);                        // width of ellipse for rounded corners
  SetWindowRgn(chessform.Handle, rgn, True);
end;

procedure TChessForm.saveDirSetExecute(Sender: TObject);
begin
  SaveManager.rootDir := InputBox('Set the Save Directory', 'Enter the path:', SaveManager.rootDir);
end;

procedure TChessForm.saveSettingsExecute(Sender: TObject);
var
 tS : textFile;
 showDebug, autoDeselect : string;
begin
  if NOT BoardMannager.Debug.Visible then
    showdebug := 'false'
  else
    showdebug := 'true';
  if NOT BoardMannager.AutoDeselect then
    autoDeselect := 'false'
  else
    autoDeselect := 'true';
  assignfile(ts, '_SETTINGS.DWCS');
  rewrite(ts);
  write(tS, format(
      'WhiteColor=[%d]'#13#10'BlackColor=[%d]'#13#10'OutlineColor=[%d]'#13#10''
       + 'BackColor=[%d]'#13#10'SaveDir=[%s]'#13#10'AutoDeselect=[%s]'#13#10'ShowDebug=[%s]'#13#10'AssetsDir=[%s]'#13#10'END',
       [rgb(GetBValue(BoardMannager.WhiteColor), GetGValue(BoardMannager.WhiteColor),GetRValue(BoardMannager.WhiteColor)),
        rgb(GetBValue(BoardMannager.BlackColor), GetGValue(BoardMannager.BlackColor),GetRValue(BoardMannager.BlackColor)),
        rgb(GetBValue(BoardMannager.OutlineColor), GetGValue(BoardMannager.OutlineColor),GetRValue(BoardMannager.OutlineColor)),
        color, savemanager.rootDir, autoDeselect, showdebug, assetPath]));

  closefile(tS);
end;

procedure TChessForm.ScaleComponents;
begin
  lblWhiteTitle.Top := 8;
  lblWhiteTitle.Font.Size := Ceil((20 / (1080/ClientHeight)) * scaleMultplier);
  lblWhiteTitle.Left := 8;
  lblBPiecesTook.Left := 8;
  lblBPiecesTook.Top := lblWhiteTitle.Top + lblWhiteTitle.Height + 8;
  lblBlackTitle.Top := 8;
  lblBPiecesTook.Font.Size := Ceil((12 / (1080/ClientHeight))* scaleMultplier);
  lblBlackTitle.Font.Size := Ceil((20 / (1080/ClientHeight))* scaleMultplier);
  lblBlackTitle.Left := BoardMannager.getLastSquareLeft +
    BoardMannager.getSquareHeightWidth + 8;
  lblWPiecesTook.Top := lblBlackTitle.Top + lblBlackTitle.Height + 8;
  lblWPiecesTook.Font.Size := Ceil((12 / (1080/ClientHeight))* scaleMultplier);
  lblWPiecesTook.Left := BoardMannager.getLastSquareLeft +
    BoardMannager.getSquareHeightWidth + 8;
  // The new highlighted block is created to be infront of the other images!
  highlightblock.BringToFront;
  highlightblock.Parent := Self;
  highlightblock.Stretch := true;
  highlightblock.Visible := false;
  highlightblock.Height := BoardMannager.Board[1, 1].Height;
  highlightblock.Width := BoardMannager.Board[1, 1].Width;
  // setup buttons;
  imgClose.Width := Ceil((45 / (1080/ClientHeight))* scaleMultplier);
  imgClose.Height := Ceil((45 / (1080/ClientHeight))* scaleMultplier);
  imgClose.Left := chessform.Width - imgClose.Width - 8;
  imgHelp.Height := Ceil((45 / (1080/ClientHeight))* scaleMultplier);
  imghelp.Width := Ceil((45 / (1080/ClientHeight))* scaleMultplier);
  imgHelp.Left := chessform.Width - imgHelp.Width - 8;
  imgHelp.Top := imgClose.Top + imgClose.Height + 8;
  imgSettings.Height := Ceil((45 / (1080/ClientHeight))* scaleMultplier);
  imgSettings.Width := Ceil((45 / (1080/ClientHeight))* scaleMultplier);
  imgSettings.Left := chessform.Width - imgSettings.Width - 8;
  imgSettings.Top := imgHelp.Top + imgHelp.Height + 8;
  imgSave.Height := Ceil((45 / (1080/ClientHeight))* scaleMultplier);
  imgSave.Width := Ceil((45 / (1080/ClientHeight))* scaleMultplier);
  imgSave.Left := chessform.Width - imgSettings.Width - 8;
  imgSave.Top := imgSettings.Top + imgSettings.Height + 8;

  imgLoad.Height := Ceil((45 / (1080/ClientHeight))* scaleMultplier);
  imgLoad.Width := Ceil((45 / (1080/ClientHeight))* scaleMultplier);
  imgLoad.Left := chessform.Width - imgLoad.Width - 8;
  imgLoad.Top := imgSave.Top + imgSave.Height + 8;

  imgExport.Height := Ceil((45 / (1080/ClientHeight))* scaleMultplier);
  imgExport.Width := Ceil((45 / (1080/ClientHeight))* scaleMultplier);
  imgExport.Left := chessform.Width - imgExport.Width - 8;
  imgExport.Top := imgLoad.Top + imgLoad.Height + 8;

  BoardMannager.Debug.Font.Size := Ceil((10 / (1080/ClientHeight))* scaleMultplier);
end;

procedure TChessForm.setAssetsPathExecute(Sender: TObject);
var
  prePath : string;
  accept : integer;
begin
  prePath := AssetPath;
  AssetPath := InputBox('Use Custom Assets', 'Enter the folder path of the assets:', AssetPath);
  if prePath <> AssetPath then
    accept := MessageDlg('This action requires saving the current settings, Continue?' , mtConfirmation, [mbYes, mbNo], 0);
  if accept = mrYes then
  begin
    saveSettingsExecute(nil);
    reloadGame;
  end;
end;

procedure TChessForm.setBackColorExecute(Sender: TObject);
begin
  cldlg.Color := color;
  clDlg.Execute();
  Color := clDlg.Color;
end;

procedure TChessForm.setBlackColorExecute(Sender: TObject);
begin
  //Invert R and B elements.
  clDlg.Color := rgb(GetBValue(BoardMannager.BlackColor), GetGValue(BoardMannager.BlackColor),GetRValue(BoardMannager.BlackColor));
  clDlg.Execute();
  if clDlg.Color = $000000 then
    clDlg.Color := $000001; //Color can not be pure black !
  if clDlg.Color = $FFFFFF then
    clDlg.Color := $FFFFFE; //Color can not be pure white!
  BoardMannager.BlackColor := clDlg.Color;
  //Reload the game to have changes take effect
  animationscanshow := false; //Disable dropdown messages ~~ Speeds up refresh!
  SaveManager.SaveToFileOverwrite(SaveManager.rootDir + '\_TEMPSAVE.DWCS');
  SaveManager.LoadFromFile(SaveManager.rootDir + '\_TEMPSAVE.DWCS');
  deleteFile(SaveManager.rootDir + '\_TEMPSAVE.DWCS');
  deletefile(SaveManager.rootDir + '\_TEMPSAVE.PGN');
  animationscanshow := true;
end;

procedure TChessForm.setOutlineColorExecute(Sender: TObject);
begin
  clDlg.Color := rgb(GetBValue(BoardMannager.OutlineColor), GetGValue(BoardMannager.OutlineColor),GetRValue(BoardMannager.OutlineColor));
  clDlg.Execute();
  if clDlg.Color = $000000 then
    clDlg.Color := $000001; //Color can not be pure black !
  if clDlg.Color = $FFFFFF then
    clDlg.Color := $FFFFFE; //Color can not be pure white!
  BoardMannager.OutlineColor := clDlg.Color;
  //Reload the game to have changes take effect
  animationscanshow := false; //Disable dropdown messages ~~ Speeds up refresh!
  SaveManager.SaveToFileOverwrite(SaveManager.rootDir + '\_TEMPSAVE.DWCS');
  SaveManager.LoadFromFile(SaveManager.rootDir + '\_TEMPSAVE.DWCS');
  deleteFile(SaveManager.rootDir + '\_TEMPSAVE.DWCS');
  deletefile(SaveManager.rootDir + '\_TEMPSAVE.PGN');
  animationscanshow := true;
end;

procedure TChessForm.SetSettings;
var
  settingDat : string;
begin
  {Load the file data to settings}
  if fileexists('_SETTINGS.DWCS') then
  begin
    settingDat := getdata('_SETTINGS.DWCS', 'WhiteColor');
    if settingDat <> 'default' then
      BoardMannager.WhiteColor := StrToInt(settingDat);

    settingDat := getdata('_SETTINGS.DWCS', 'BlackColor');
    if settingDat <> 'default' then
      BoardMannager.BlackColor := StrToInt(settingDat);

    settingDat := getdata('_SETTINGS.DWCS', 'OutlineColor');
    if settingDat <> 'default' then
      BoardMannager.OutlineColor := StrToInt(settingDat);

    settingDat := getdata('_SETTINGS.DWCS', 'BackColor');
    if settingDat <> 'default' then
      chessForm.Color := StrToInt(settingDat);

    settingDat := getdata('_SETTINGS.DWCS', 'SaveDir');
    if settingDat <> 'default' then
      SaveManager.rootDir := settingDat;

    settingDat := getdata('_SETTINGS.DWCS', 'ShowDebug');
      if settingDat <> 'default' then
        if settingDat = 'false' then
          BoardMannager.Debug.Visible := false;

    settingDat := getdata('_SETTINGS.DWCS', 'AutoDeselect');
    if settingDat <> 'default' then
      if settingDat = 'false' then
        BoardMannager.AutoDeselect := false;
  end;
end;

procedure TChessForm.setUIScaleExecute(Sender: TObject);
var
  newScaleM : real;
begin
  newScaleM := strtofloat(inputbox('Set new UI Scale', 'Enter a scale multiplier [Any real number]', FloatToStr(scaleMultplier)));
  scaleMultplier := newscaleM;
  ScaleComponents;
end;

procedure TChessForm.setWhiteColorExecute(Sender: TObject);
begin
  clDlg.Color := rgb(GetBValue(BoardMannager.WhiteColor), GetGValue(BoardMannager.WhiteColor),GetRValue(BoardMannager.WhiteColor));
  clDlg.Execute();
  if clDlg.Color = $000000 then
    clDlg.Color := $000001; //Color can not be pure black !
  if clDlg.Color = $FFFFFF then
    clDlg.Color := $FFFFFE; //Color can not be pure white!
  BoardMannager.WhiteColor := clDlg.Color;
  //Reload the game to have changes take effect
  animationscanshow := false; //Disable dropdown messages ~~ Speeds up refresh!
  SaveManager.SaveToFileOverwrite(SaveManager.rootDir + '\_TEMPSAVE.DWCS');
  SaveManager.LoadFromFile(SaveManager.rootDir + '\_TEMPSAVE.DWCS');
  deleteFile(SaveManager.rootDir + '\_TEMPSAVE.DWCS');
  deletefile(SaveManager.rootDir + '\_TEMPSAVE.PGN');
  animationscanshow := true;
end;

procedure TChessForm.showDebugExecute(Sender: TObject);
begin
  BoardMannager.Debug.Visible := not BoardMannager.Debug.Visible;
  showDebug.Checked :=  BoardMannager.Debug.Visible
end;

end.
