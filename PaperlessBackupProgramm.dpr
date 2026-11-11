// VCL-Einstieg: Hauptformular zuerst erzeugen, damit es Besitzer und Bezugspunkt der Dialoge ist.
program PaperlessBackupProgramm;

uses
  System.SysUtils,
  Vcl.Forms,
  MainForm in 'MainForm.pas' {Form1},
  Vcl.Themes,
  Vcl.Styles,
  AppConfig in 'AppConfig.pas',
  ExternPaperless in 'ExternPaperless.pas',
  ExternalStartupCheck in 'ExternalStartupCheck.pas',
  BackupRestoreServer in 'BackupRestoreServer.pas',
  AppLogger in 'AppLogger.pas',
  AppDialogs in 'AppDialogs.pas',
  Crypto in 'Crypto.pas',
  ScriptGenerator in 'ScriptGenerator.pas',
  DockerComposeGenerator in 'DockerComposeGenerator.pas',
  SetupForm in 'SetupForm.pas' {SetupFrm};

{$R *.res}

begin
  // The helper must exit before any forms or installation code run.
  // Der Helfer beendet sich vor Formularen oder Installationsablaeufen.
  if GetEnvironmentVariable('PAPERLESS_SSH_HELPER') = '1' then
  begin
    try
      Halt(RunServerAskPass);
    except
      Halt(1);
    end;
  end;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Windows Modern Dark SE');
  Application.CreateForm(TMainformFrm, MainformFrm);
  Application.CreateForm(TSetupFrm, SetupFrm);
  // Die Nachrichtenschleife zeigt das Hauptfenster; dessen OnShow kann Einrichtungsschritte auslösen.
  Application.Run;
end.
