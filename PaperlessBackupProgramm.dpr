// VCL-Einstieg: Hauptformular zuerst erzeugen, damit es Besitzer und Bezugspunkt der Dialoge ist.
program PaperlessBackupProgramm;

uses
  System.SysUtils,
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Styles,
  AppConfig in 'AppConfig.pas',
  AppDialogs in 'AppDialogs.pas',
  AppLogger in 'AppLogger.pas',
  BackupRestoreServer in 'BackupRestoreServer.pas',
  Crypto in 'Crypto.pas',
  DockerComposeGenerator in 'DockerComposeGenerator.pas',
  ExternalStartupCheck in 'ExternalStartupCheck.pas',
  ExternPaperless in 'ExternPaperless.pas',
  Mainform in 'Mainform.pas' {MainformFrm},
  ScriptGenerator in 'ScriptGenerator.pas',
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
