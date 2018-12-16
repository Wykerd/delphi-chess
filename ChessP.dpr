program ChessP;

uses
  Forms,
  PlayerU in 'PlayerU.pas' {ChessForm},
  EngineClasses in 'EngineClasses.pas',
  EngineAnimations in 'EngineAnimations.pas',
  Launcher in 'Launcher.pas' {frmLauncher},
  EngineUI in 'EngineUI.pas',
  EngineFileInterpreter in 'EngineFileInterpreter.pas',
  HelpU in 'HelpU.pas' {frmHelp};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmLauncher, frmLauncher);
  Application.CreateForm(TChessForm, ChessForm);
  Application.CreateForm(TfrmHelp, frmHelp);
  Application.Run;
end.
