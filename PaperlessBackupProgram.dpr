program PaperlessBackupProgram;

uses
  Vcl.Forms,
  MainForm in 'MainForm.pas' {Form1},
  Vcl.Themes,
  Vcl.Styles,
  HinweisForm in 'HinweisForm.pas' {HinweisFrm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Windows10 Dark');
  Application.CreateForm(TMainformFrm, MainformFrm);
  Application.CreateForm(THinweisFrm, HinweisFrm);
  Application.Run;
end.
