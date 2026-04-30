program PaperlessBackupProgram;

uses
  Vcl.Forms,
  MainForm in 'MainForm.pas' {Form1},
  Vcl.Themes,
  Vcl.Styles,
  AppConfig in 'AppConfig.pas',
  AppLogger in 'AppLogger.pas',
  ScriptGenerator in 'ScriptGenerator.pas',
  DockerComposeGenerator in 'DockerComposeGenerator.pas',
  SetupForm in 'SetupForm.pas' {SetupFrm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Windows11 Modern Dark');
  Application.CreateForm(TMainformFrm, MainformFrm);
  Application.CreateForm(TSetupFrm, SetupFrm);
  Application.Run;
end.
