unit EngineFileInterpreter;

interface
  uses
    Variants, Dialogs, sysutils, Windows, EngineUI, EngineAnimations, Forms;

function GetData(FilePath : string; Tag : string) : string;
procedure PGNResetTemp;
procedure PGNPlotPointMove(APoint, AOPoint: TPoint; AKind : integer);
procedure PGNPlotPointTake(APoint, AOPoint: TPoint; AKind : integer);
procedure PGNPlotPointTakePawn(APoint, AOPoint: TPoint; AKind : integer);
procedure PGNPrint(s : string);
procedure PGNBlankMove(ATurn : integer);
procedure PGNExport(APlayerNames : array of string; msgForm : TForm);

var
  numMoves : integer = 0;
  preNumMoves : integer = 0;
  tPGN : textfile;

const
  tempPGNFileName = '_TEMP.PGN';
  PGNPieceNotation : array[1..6] of string = ('', 'R', 'B', 'N', 'Q', 'K');
  PGNRow : array[1..8] of string = ('8','7','6','5','4','3','2','1');
  PGNColumn : array[1..8] of string = ('a','b','c','d','e','f','g','h');

implementation

function GetData(FilePath : string; Tag : string) : string;
var
  tS : TextFile;
  s : string;
begin
  if not fileExists(filepath) then
  begin
    result := 'default';
    exit;
  end;

  AssignFile(ts, FilePath);
  reset(ts);
  while (Pos(Tag, s) = 0) AND (not eof(tS)) do
    readln(ts, s);
  if eof(ts) then begin closeFile(tS); exit end;
  delete(s, 1, pos('[', s));
  Result := Copy(s, 1,  pos(']', s) - 1);
  closeFile(tS);
end;

/// PGN FILE GENERATOR ///
/// kingside castling is indicated by the sequence "O-O";
/// queenside castling is indicated by the sequence "O-O-O".

procedure PGNPrint(s : string);
begin
  AssignFile(tPGN, tempPGNFileName);
  append(tPGN);
  write(tPGN, s);
  closefile(tPGN);
end;

procedure PGNPlotPointTakePawn(APoint, AOPoint: TPoint; AKind : integer);
begin
  if AKind <> 0 then
  begin
  AssignFile(tPGN, tempPGNFileName);
  append(tPGN);
  if AKind > 0 then
  begin
    Inc(numMoves);
    write(tPGN, Format('%d.', [numMoves]));
  end;

  write(tPGN, PGNPieceNotation[abs(AKind)]); //Write the piece name moved
  write(tPGN, PGNColumn[AOPoint.x]);
  write(tPGN, PGNRow[AOPoint.y]);
  write(tPGN, 'x');
  write(tPGN, PGNColumn[APoint.x]);
  write(tPGN, PGNRow[APoint.y]);
  if not(((AKind = 1) or (AKind =-1)) AND ((apoint.y  = 8) or (apoint.y  = 1))) then
    write(tPGN, ' ');

  if ((numMoves mod 5) = 0) AND (AKind < 0) then
    write(tPGN, #13#10);

  closeFile(tPGN);
  end;

end;

procedure PGNPlotPointTake(APoint, AOPoint: TPoint; AKind : integer);
begin
  if AKind <> 0 then
  begin
  AssignFile(tPGN, tempPGNFileName);
  append(tPGN);
  if AKind > 0 then
  begin
    Inc(numMoves);
    write(tPGN, Format('%d.', [numMoves]));
  end;

  write(tPGN, PGNPieceNotation[abs(AKind)]); //Write the piece name moved
  write(tPGN, PGNColumn[AOPoint.x]);
  write(tPGN, PGNRow[AOPoint.y]);
  write(tPGN, 'x');
  write(tPGN, PGNColumn[APoint.x]);
  write(tPGN, PGNRow[APoint.y]);
  if not(((AKind = 1) or (AKind =-1)) AND ((apoint.y  = 8) or (apoint.y  = 1))) then
    write(tPGN, ' ');

  if ((numMoves mod 5) = 0) AND (AKind < 0) then
    write(tPGN, #13#10);

  closeFile(tPGN);
  end;

end;

procedure PGNBlankMove(ATurn : integer);
begin
  AssignFile(tPGN, tempPGNFileName);
  append(tPGN);
  if ATurn = 2 then
  begin
    Inc(numMoves);
    write(tPGN, Format('%d.', [numMoves]));
  end;
  closeFile(tPGN);

end;


procedure PGNPlotPointMove(APoint, AOPoint: TPoint; AKind : integer);
begin
  if AKind <> 0 then
  begin
  AssignFile(tPGN, tempPGNFileName);
  append(tPGN);
  if AKind > 0 then
  begin
    Inc(numMoves);
    write(tPGN, Format('%d.', [numMoves]));
  end;

  write(tPGN, PGNPieceNotation[abs(AKind)]); //Write the piece name moved
  write(tPGN, PGNColumn[AOPoint.x]);
  write(tPGN, PGNRow[AOPoint.y]);
  write(tPGN, PGNColumn[APoint.x]);
  write(tPGN, PGNRow[APoint.y]);
  if not(((AKind = 1) or (AKind =-1)) AND ((apoint.y  = 8) or (apoint.y  = 1))) then
    write(tPGN, ' ');

  if ((numMoves mod 5) = 0) AND (AKind < 0) then
    write(tPGN, #13#10);

  closeFile(tPGN);
  end;

end;

procedure PGNResetTemp;
begin
  AssignFile(tPGN, tempPGNFileName);
  rewrite(tPGN);
  CloseFile(tPGN);
  numMoves := 0;
end;

procedure PGNExport(APlayerNames : array of string; msgForm : TForm);
var
  saveFilePath : string;
  tEx : textfile;
  s : string;
  wday, wyear, wmonth : Word;
begin
  if promptforfilename(saveFilePath, 'Portable Game Notation (*.pgn)|*.pgn', '.pgn', 'Export game to .PGN', GetCurrentDir, true) then
  begin
    //Determine date
    DecodeDate(Now, wYear, wMonth, wDay);

    assignfile(tEx, saveFilePath);
    AssignFile(tPGN, tempPGNFileName);
    reset(tPGN);
    rewrite(tEX);
    writeln(tEx, Format('[Site "Daniel Wykerd Chess"]'#13#10'' +
                       '[Date "%04d.%02d.%02d"]'#13#10'' +
                       '[Event "Casual Game"]'#13#10'' +
                       '[White "%s"]'#13#10'' +
                       '[Black "%s"]'#13#10'' +
                       '[Result "*"]'#13#10'',
                       [wYear, wMonth, wDay, APlayerNames[0], APlayerNames[1]]));
    while not eof(tPGN) do
    begin
      readln(tPGN, s);
      writeln(tEx, s);
    end;
    closefile(tEx);
    closefile(tPGN);
    DropDownMsg('Export Complete', msgForm);
  end;
end;

end.
