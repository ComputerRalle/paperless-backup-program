// VCL-Einstieg: Hauptformular zuerst erzeugen, damit es Besitzer und Bezugspunkt der Dialoge ist.
program PaperlessBackupProgramm;

uses
  Vcl.Forms,
  MainForm in 'MainForm.pas' {Form1},
  Vcl.Themes,
  Vcl.Styles,
  AppConfig in 'AppConfig.pas',
  AppLogger in 'AppLogger.pas',
  AppDialogs in 'AppDialogs.pas',
  Crypto in 'Crypto.pas',
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
  // Die Nachrichtenschleife zeigt das Hauptfenster; dessen OnShow kann Einrichtungsschritte auslösen.
  Application.Run;
end.
