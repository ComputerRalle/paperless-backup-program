// --------------------------------------------------------------
// Original author: Ralf-Peter Kleinert - 2025
// Alias: #ComputerRalle / DIGITAL-easy
// Project: Paperless Backup Program / Paperless Backup Programm
// Website: https://ralf-peter-kleinert.de
// YouTube: https://www.youtube.com/@ralf-peter-kleinert
// Copyright (c) 2025 Ralf-Peter Kleinert
// MIT License - see LICENSE file in the repository
// --------------------------------------------------------------

unit Mainform;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, ShellAPI, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  System.IOUtils, Vcl.Samples.Spin, System.IniFiles, DateUtils, HinweisForm, System.Generics.Collections, System.Generics.Defaults, Vcl.Menus,
  System.Net.URLClient, System.Net.HttpClient, System.Net.HttpClientComponent, ScriptGenerator;

type
  TMainformFrm = class(TForm)
    StatusBar1: TStatusBar;
    Panel2: TPanel;
    BackupRestorePan: TPanel;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    Panel3: TPanel;
    ScriptSavedLbl: TLabel;
    StartPaperlessBackupBtn: TButton;
    RestorePaperlessBackupBtn: TButton;
    CanStartBackupSTxt: TStaticText;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel1: TPanel;
    BuyMeACoffeBtn: TButton;
    StaticText4: TStaticText;
    RestoreCanStartSTxt: TStaticText;
    Panel7: TPanel;
    Label1: TLabel;
    Image1: TImage;
    StaticText5: TStaticText;
    BackupWiederherProgNeuStartLbl: TLabel;
    Label3: TLabel;
    AutostartLbl: TLabel;
    TabControl1: TTabControl;
    BackupPlanPan: TPanel;
    Panel9: TPanel;
    AutoBackupCB: TCheckBox;
    Panel13: TPanel;
    Panel14: TPanel;
    Label8: TLabel;
    Label9: TLabel;
    MondayCB: TCheckBox;
    TuesdayCB: TCheckBox;
    WednesdayCB: TCheckBox;
    ThursdayCB: TCheckBox;
    FridayCB: TCheckBox;
    SaturdayCB: TCheckBox;
    SundayCB: TCheckBox;
    Panel10: TPanel;
    WeekDaysPan: TPanel;
    TimePlanPan: TPanel;
    HourSpE: TSpinEdit;
    MinuteSpE: TSpinEdit;
    HourLbl: TLabel;
    MinuteLbl: TLabel;
    CreateBackupPlanBtn: TButton;
    RetentionPan: TPanel;
    KeepBackupsSpE: TSpinEdit;
    Label4: TLabel;
    Panel6: TPanel;
    Label5: TLabel;
    Label6: TLabel;
    SaveRetentionBtn: TButton;
    Label7: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    DeleteBackupPlanBtn: TButton;
    Panel8: TPanel;
    AllBackupsAreRetainedLbl: TLabel;
    UhrzeitLbl: TLabel;
    PaperlessUpdateBtn: TButton;
    EMailSettingsPan: TPanel;
    Panel11: TPanel;
    Label2: TLabel;
    Label14: TLabel;
    SMTPServerEdit: TEdit;
    SMTPPortEdit: TEdit;
    UserNameEdit: TEdit;
    MailAccountPasswordEdit: TEdit;
    EMailSentFromEdit: TEdit;
    EMailHostLbl: TLabel;
    EMailPortLbl: TLabel;
    EMailHostUserLbl: TLabel;
    EMailHostPWLbl: TLabel;
    EMailFromLbl: TLabel;
    SaveEmailSettingsBtn: TButton;
    SSLoTLSRg: TRadioGroup;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    HabeUpdaetGemachtCb: TCheckBox;
    Label18: TLabel;
    SettingsPan: TPanel;
    Label26: TLabel;
    Panel15: TPanel;
    Label27: TLabel;
    Label28: TLabel;
    SaveSettingsBtn: TButton;
    PapierkorbAufbewahrungEdit: TEdit;
    Label19: TLabel;
    OnlyIntegerAllowedLbl: TLabel;
    SettingsSavedLbl: TLabel;
    Label20: TLabel;
    HelpPan: TPanel;
    Label21: TLabel;
    Panel16: TPanel;
    Label25: TLabel;
    Label29: TLabel;
    Label22: TLabel;
    ImpressumLbl: TLabel;
    PaplerlessPlayListLbl: TLabel;
    MeinYouTubeKanalLbl: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    BackupProgrammAnleitungLbl: TLabel;
    Label30: TLabel;
    Web1Lbl: TLabel;
    Web2Lbl: TLabel;
    Label31: TLabel;
    NewsletterLbl: TLabel;
    Label32: TLabel;
    Label33: TLabel;
    Label34: TLabel;
    Label35: TLabel;
    Label36: TLabel;
    Label37: TLabel;
    redis_version_edit: TEdit;
    postgres_version_edit: TEdit;
    Label38: TLabel;
    Label39: TLabel;
    Label40: TLabel;
    Label41: TLabel;
    Label42: TLabel;
    Label43: TLabel;
    Label44: TLabel;
    paperless_version_edit: TEdit;
    gotenberg_version_edit: TEdit;
    tika_version_edit: TEdit;
    alpine_version_edit: TEdit;
    busybox_version_edit: TEdit;
    Memo1: TMemo;
    CheckBox1: TCheckBox;
    NetHTTPClient1: TNetHTTPClient;
    ProgramUpdateLbl: TLabel;
    procedure StartPaperlessBackupBtnClick(Sender: TObject);
    procedure BuyMeACoffeeBtnClick(Sender: TObject);
    procedure StartCmdScript;
    procedure FormShow(Sender: TObject);
    procedure StartPaperlessBackupScriptBtnClick(Sender: TObject);
    procedure RestorePaperlessBackupBtnClick(Sender: TObject);
    procedure CreateRestoreScript(const ComposePath, BackupFolder: string);
    procedure StartAndMonitorCmdScript;
    procedure ConsoleToFront(PID: DWORD);
    procedure TabControl1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SaveScheduleSettings;
    procedure CreateBackupPlanBtnClick(Sender: TObject);
    procedure CreateBackupPlanScript(const ComposePath: string);
    procedure CreateRestartScript(const ComposePath: string);
    procedure StartBackupPlanScriptSilent;
    procedure LoadScheduleSettings;
    procedure AutoBackupCBClick(Sender: TObject);
    procedure SaveRetentionBtnClick(Sender: TObject);
    procedure DeleteBackupPlanBtnClick(Sender: TObject);
    procedure CheckScheduleAllowed;
    procedure WriteComposeContainerAndVolumeInfo(const ComposePath: string);
    function ExecuteShellCommand(const Command, Params: string): string;
    procedure PaperlessUpdateBtnClick(Sender: TObject);
    function GetFileVersion(const FilePath: string): string;
    procedure ReadContainerNamesFromFile;
    procedure RunAutostartBackup();
    procedure LoadEmailSettings;
    procedure SaveEmailSettingsBtnClick(Sender: TObject);
    procedure SaveEmptyEnvFile();
    procedure RequireCompletedSettings;
    procedure StartAndMonitorRestart;
    procedure SaveBlankEmailSettings();
    procedure UpdateDoneCbClick(Sender: TObject);
    procedure TrashRetentionEditChange(Sender: TObject);
    procedure SaveSettingsBtnClick(Sender: TObject);
    procedure ImprintLblClick(Sender: TObject);
    procedure PaperlessPlaylistLblClick(Sender: TObject);
    procedure MyYouTubeChannelLblClick(Sender: TObject);
    procedure BackupProgramGuideLblClick(Sender: TObject);
    procedure Web1LblClick(Sender: TObject);
    procedure Web2LblClick(Sender: TObject);
    procedure NewsletterLblClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure StaticText1Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure WriteStandardVersionAfterInstallation();

    procedure LoadUpdateIniFile();
    function GetExeVersion: string;
    procedure ProgramUpdateLblClick(Sender: TObject);
    function VersionToInt(const V: string): string;

  private
    procedure CreateBackupScript(const ComposePath: string);
  public
  end;

var
  MainformFrm: TMainformFrm;
  // Main paths used by backup, restore, and generated CMD scripts.
  BackupPath, ComposePath, ComposeName, CmdTargetPath, LastBackupFolder: String;
  AppDataFolder, BackupTargetFilePath, DefaultFolder, PaperlessInput, NoticeFilePath : String;
  // Runtime mode flags. They decide which script is created and what happens after it finishes.
  IsBackup: Boolean;
  IsPaperlessInstallation, ShouldOpenPaperless: Boolean;
  InternalName, FileVersion: string;
  // Docker container and volume names detected from the current compose project.
  PaperlessDBName, PaperlessCTName, PaperlessBrokerName, PaperlessTikaName, PaperlessGotenbergName: String;
  Volume_data, Volume_db_data, Volume_export, Volume_media: String;
  NewComposePath: String;
  ShouldWriteNewCompose: Boolean;
  IsAutostart: Boolean;
  InstallationCompletedFilePath: String;
  WantsInstall: Boolean;
  IsUpdate: Boolean;
  PaperlessUpdate: Boolean;
  TrashRetentionDays: Integer;
  CurrentTestedPaperlessVersion: String;


implementation

{$R *.dfm}

// Load update.ini from the web server and show whether a program update is available.
procedure TMainformFrm.LoadUpdateIniFile();
var
  Ss: TStringStream;
  Sl: TStringList;
  ProgramVersion: String;
  VersionInIni: String;
  test1, test2 : String;
begin

  ProgramVersion := GetExeVersion;

  if not FileExists(AppDataFolder + '\update.ini') then
  VersionInIni := ProgramVersion;

  try
    Ss := TStringStream.Create;
    try
      NetHTTPClient1.Get('https://ralf-peter-kleinert.de/paperless-backup-programm-update/update.ini', Ss);
      Ss.SaveToFile(AppDataFolder + '\update.ini');
    finally
      Ss.Free;
    end;
  except
    VersionInIni := ProgramVersion; // No update check result when the server is unavailable.
    Exit;
  end;

  if FileExists(AppDataFolder + '\update.ini') then
    begin
      Sl := TStringList.Create;
      try
        Sl.LoadFromFile(AppDataFolder + '\update.ini');
        VersionInIni := Trim(Sl[0]);
      finally
        Sl.Free;
      end;
    end;


  if VersionToInt(VersionInIni) > VersionToInt(ProgramVersion) then
  begin
    ProgramUpdateLbl.ParentColor := False;
    ProgramUpdateLbl.Caption := 'Update vorhanden - hier klicken';
    ProgramUpdateLbl.StyleElements := StyleElements - [seFont];
    ProgramUpdateLbl.Font.Color := clYellow;
    ProgramUpdateLbl.Font.Style := [fsBold];
  end else
  begin
    ProgramUpdateLbl.ParentColor := False;
    ProgramUpdateLbl.Caption := 'Programm aktuell';
    ProgramUpdateLbl.StyleElements := StyleElements - [seFont];
    ProgramUpdateLbl.Font.Color := clYellow;
  end;
end;

// Store the default versions of all Docker components in the settings INI file.
procedure TMainformFrm.WriteStandardVersionAfterInstallation();
var
  Ini: TIniFile;
  SettingsIniPath: string;
begin
  SettingsIniPath := IncludeTrailingPathDelimiter(Mainform.AppDataFolder) + 'Einstellungen.ini';
  Ini := TIniFile.Create(SettingsIniPath);
  try
    Ini.WriteString('Versionen', 'Paperless-Version', '2.20.15');
    Ini.WriteString('Versionen', 'Postgres-Version', '17');
    Ini.WriteString('Versionen', 'Redis-Version', '8');
    Ini.WriteString('Versionen', 'Gotenberg-Version', '8.25');
    Ini.WriteString('Versionen', 'Tika-Version', 'latest');
    Ini.WriteString('Versionen', 'Alpine-Version', '3');
    Ini.WriteString('Versionen', 'Busybox-Version', '1');
    Ini.UpdateFile;
  finally
    Ini.Free;
  end;
end;

// Open the generated CMD script in a visible console window.
procedure TMainformFrm.StartCmdScript;
begin
  ShellExecute(0, 'open', PChar(CmdTargetPath), nil, nil, SW_SHOWNORMAL);
end;

// Open the support page in the default browser.
procedure TMainformFrm.BuyMeACoffeeBtnClick(Sender: TObject);
begin
 ShellExecute(0, 'open', 'https://buymeacoffee.com/computerralle', nil, nil, SW_SHOWNORMAL);
end;

// Enable or disable manual Docker image version editing.
procedure TMainformFrm.CheckBox1Click(Sender: TObject);
begin
  if CheckBox1.State = cbUnchecked then
  begin
    redis_version_edit.Enabled := False;
    postgres_version_edit.Enabled := False;
    gotenberg_version_edit.Enabled := False;
    tika_version_edit.Enabled := False;
    alpine_version_edit.Enabled := False;
    busybox_version_edit.Enabled := False;
    paperless_version_edit.Enabled := False;
  end else
  begin
    redis_version_edit.Enabled := True;
    postgres_version_edit.Enabled := True;
    gotenberg_version_edit.Enabled := True;
    tika_version_edit.Enabled := True;
    alpine_version_edit.Enabled := True;
    busybox_version_edit.Enabled := True;
    paperless_version_edit.Enabled := True;
  end;
end;

// Choose the backup target folder, save it, and create the backup scripts.
procedure TMainformFrm.StartPaperlessBackupBtnClick(Sender: TObject);
var
  FolderDialog: TFileOpenDialog;
  Ini:TIniFile;
  StoredPath: string;
  TextFilePath: string;
begin
  WriteComposeContainerAndVolumeInfo(ComposePath);
  StartPaperlessBackupBtn.Enabled := False;
  RestorePaperlessBackupBtn.Enabled := False;
  AutostartLbl.Visible := False;
  ReadContainerNamesFromFile;
  IsPaperlessInstallation := False;

  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + 'Einstellungen.ini');
  try
    Ini.WriteString('Pfade', 'DockerComposePfad', ExtractFilePath(ComposePath));
    Ini.UpdateFile; // Write immediately.
  finally
    Ini.Free;
  end;

  IsBackup := True;

  DefaultFolder := IncludeTrailingPathDelimiter(GetEnvironmentVariable('USERPROFILE')) + 'Desktop\Paperless-Backup';
  if not DirectoryExists(DefaultFolder) then ForceDirectories(DefaultFolder);

  // Migrate the old backup target text file into the INI file.
  TextFilePath := IncludeTrailingPathDelimiter(AppDataFolder) + 'BackupZiel.txt';
  if FileExists(TextFilePath) then
  begin
    StoredPath := TFile.ReadAllText(TextFilePath, TEncoding.UTF8).Trim;
    Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + 'Einstellungen.ini');
    try
      Ini.WriteString('Pfade', 'BackupZiel', StoredPath);
      Ini.UpdateFile; // Write immediately.
      // Read the value back from the INI file.
      StoredPath := Ini.ReadString('Pfade', 'BackupZiel', '').Trim;
    finally
      Ini.Free;
    end;
    // Delete the old text file after a successful migration.
    if StoredPath <> '' then DeleteFile(TextFilePath);
  end;

  // Read the last backup folder from the INI file.
  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + 'Einstellungen.ini');
  try
    LastBackupFolder := Ini.ReadString('Pfade', 'BackupZiel', '').Trim;
  finally
    Ini.Free;
  end;

  Sleep(500);

  if LastBackupFolder <> '' then
  begin
    if IsAutostart or
       (MessageDlg('Es wurde folgender voreingestellter Pfad gefunden:' + sLineBreak + LastBackupFolder + sLineBreak + sLineBreak +
                   'Soll das Backup hier gespeichert werden?', mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
    begin
      BackupPath := IncludeTrailingPathDelimiter(LastBackupFolder) + FormatDateTime('yyyy-mm-dd_hh-mm-ss', Now);
    end
    else
    begin
      FolderDialog := TFileOpenDialog.Create(nil);
      try
        FolderDialog.Options := [fdoPickFolders];
        FolderDialog.Title := 'Wählen Sie einen Backup-Ziel-Ordner aus.';
        FolderDialog.DefaultFolder := DefaultFolder;
        if FolderDialog.Execute then
        begin
          BackupPath := IncludeTrailingPathDelimiter(FolderDialog.FileName) + FormatDateTime('yyyy-mm-dd_hh-mm-ss', Now);



          if not SameText(FolderDialog.FileName, DefaultFolder) then
          begin
            TFile.AppendAllText(
              IncludeTrailingPathDelimiter(DefaultFolder) + 'Wo ist mein Paperless Backup.txt',
              'Backup am ' + FormatDateTime('dd.mm.yyyy "um" hh:nn:ss', Now) +
              ' wurde in folgendem Ordner gespeichert:' + sLineBreak +
              BackupPath + sLineBreak + sLineBreak);
          end;
        end
        else
        begin
          ShowMessage('Es wurde kein Ordner gewählt. Backupvorgang abgebrochen.');
          Exit;
        end;
      finally
        FolderDialog.Free;
      end;
    end;
  end
  else
  begin
    FolderDialog := TFileOpenDialog.Create(nil);
    try
      FolderDialog.Options := [fdoPickFolders];
      FolderDialog.Title := 'Wählen Sie einen Backup-Ziel-Ordner aus.';
      FolderDialog.DefaultFolder := DefaultFolder;
      if FolderDialog.Execute then
      begin
        BackupPath := IncludeTrailingPathDelimiter(FolderDialog.FileName) + FormatDateTime('yyyy-mm-dd_hh-mm-ss', Now);
        if not SameText(FolderDialog.FileName, DefaultFolder) then
        begin
          TFile.AppendAllText(
            IncludeTrailingPathDelimiter(DefaultFolder) + 'Wo ist mein Paperless Backup.txt',
            'Backup am ' + FormatDateTime('dd.mm.yyyy "um" hh:nn:ss', Now) +
            ' wurde in folgendem Ordner gespeichert:' + sLineBreak +
            BackupPath + sLineBreak + sLineBreak);
        end;
      end
      else
      begin
        BackupPath := IncludeTrailingPathDelimiter(DefaultFolder) + FormatDateTime('yyyy-mm-dd_hh-mm-ss', Now);
        ShowMessage('Es wurde kein Ordner gewählt. Der Standardordner wird verwendet: ' + sLineBreak + BackupPath);
      end;
    finally
      FolderDialog.Free;
    end;
  end;

  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + 'Einstellungen.ini');
  try
    Ini.WriteString('Pfade', 'BackupZiel', ExtractFileDir(BackupPath));
    Ini.UpdateFile; // Write immediately.
  finally
    Ini.Free;
  end;

  CreateBackupScript(ExtractFilePath(ComposePath));
  CreateBackupPlanScript(ExtractFilePath(ComposePath));

  StartPaperlessBackupBtn.Enabled := True;
  RestorePaperlessBackupBtn.Enabled := True;
  CanStartBackupSTxt.Visible := True;
  StaticText5.Visible := True;
  RestoreCanStartSTxt.Visible := False;

  // Delete the old marker file if it still exists.
  TextFilePath := IncludeTrailingPathDelimiter(AppDataFolder) + 'DockerComposePfad.txt';
  if FileExists(TextFilePath) then DeleteFile(TextFilePath);
end;
// Create paperless-backup.cmd for a manual backup.
// The script dumps PostgreSQL first, then archives the Docker volumes.
procedure TMainformFrm.CreateBackupScript(const ComposePath: string);
var
  Volumes: TDockerVolumeNames;
begin
  if ComposePath.Trim = '' then
  begin
    ShowMessage('Fehler: Es wurde kein gültiger Compose-Pfad gewählt.');
    Exit;
  end;

  if not DirectoryExists(BackupPath) then ForceDirectories(BackupPath);
  CmdTargetPath := IncludeTrailingPathDelimiter(ComposePath) + 'paperless-backup.cmd';
  Volumes.Data := Volume_data;
  Volumes.DbData := Volume_db_data;
  Volumes.ExportData := Volume_export;
  Volumes.Media := Volume_media;
  CreateManualBackupCmdScript(CmdTargetPath, ComposePath, BackupPath, AppDataFolder, PaperlessDBName, Volumes);
  ScriptSavedLbl.Caption := 'Backup-Skript wurde erstellt: ' + CmdTargetPath;
  StartAndMonitorCmdScript;
end;

// Close the application from the main form.
procedure TMainformFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caNone;         // Stop default close handling.
  PostQuitMessage(0);       // End the message loop.
  Application.Terminate;
end;

// Prepare global paths and default runtime state.
procedure TMainformFrm.FormCreate(Sender: TObject);
begin

  AppDataFolder := IncludeTrailingPathDelimiter(GetEnvironmentVariable('USERPROFILE')) + 'Paperless Backup Programm';
  // Create the user data folder if it does not exist.
  if not DirectoryExists(AppDataFolder) then ForceDirectories(AppDataFolder);

  // Initialize runtime state.
  IsAutostart := False;
  ShouldWriteNewCompose := False;
  IsBackup := False;
  IsPaperlessInstallation := False;
  ShouldOpenPaperless := False;
  IsUpdate := False;
  PaperlessUpdate := False;
  TrashRetentionDays := 365;
end;

// Load saved settings, migrate old text files, and prepare the visible form state.
procedure TMainformFrm.FormShow(Sender: TObject);
var
  StartParameter: string;
  Ini: TIniFile;
  Value: string;
  ComposePathTextFile: string;
  OldPath: string;
  StoredPath: string;
  TextFilePath: String;
begin
  CurrentTestedPaperlessVersion := 'v2.20.15';
  Label3.Caption :=  'Getestet mit: Paperless-ngx ' + CurrentTestedPaperlessVersion;
  Label6.Caption :=  'Getestet mit: Paperless-ngx ' + CurrentTestedPaperlessVersion;
  Label9.Caption :=  'Getestet mit: Paperless-ngx ' + CurrentTestedPaperlessVersion;
  Label14.Caption := 'Getestet mit: Paperless-ngx ' + CurrentTestedPaperlessVersion;
  Label28.Caption := 'Getestet mit: Paperless-ngx ' + CurrentTestedPaperlessVersion;
  Label29.Caption := 'Getestet mit: Paperless-ngx ' + CurrentTestedPaperlessVersion;

  AppDataFolder := IncludeTrailingPathDelimiter(GetEnvironmentVariable('USERPROFILE')) + 'Paperless Backup Programm';

  // Create the desktop consume folder if it does not exist.
  PaperlessInput := IncludeTrailingPathDelimiter(GetEnvironmentVariable('USERPROFILE')) + 'Desktop\Paperless-Input';
  if not DirectoryExists(PaperlessInput) then ForceDirectories(PaperlessInput);
  SaveEmptyEnvFile();

  // Check whether the user already accepted the notice.
  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(Mainform.AppDataFolder) + 'Einstellungen.ini');
  try
    Value := Ini.ReadString('Einrichtung', 'Hinweis verstanden', '');
  finally
    Ini.Free;
  end;

  if Value = 'Ja' then
  begin
    NoticeFilePath := IncludeTrailingPathDelimiter(Mainform.AppDataFolder) + 'HinweisVerstanden.txt';
    // Delete the old notice file after the INI value exists.
    if FileExists(NoticeFilePath) then DeleteFile(NoticeFilePath);

    // Show the notice again after 30 days.
    if DaysBetween(Now, FileDateToDateTime(FileAge(IncludeTrailingPathDelimiter(Mainform.AppDataFolder) + 'Einstellungen.ini'))) > 30 then
    begin
      HinweisFrm := THinweisFrm.Create(Self);
      try
        HinweisFrm.ShowModal;
      finally
        HinweisFrm.Free;
      end;
    end;
  end else
    begin
      HinweisFrm := THinweisFrm.Create(Self);
      try
        HinweisFrm.ShowModal;
      finally
        HinweisFrm.Free;
      end;
  end;



  TextFilePath := IncludeTrailingPathDelimiter(AppDataFolder) + 'DockerComposePfad.txt';
  if FileExists(TextFilePath) then
  begin
    // Read the old path from the text file.
    OldPath := TFile.ReadAllText(TextFilePath, TEncoding.UTF8).Trim;

    // Store it in the INI file.
    Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + 'Einstellungen.ini');
    try
      Ini.WriteString('Pfade', 'DockerComposePfad', OldPath);
        Ini.UpdateFile; // Write immediately.
    finally
      Ini.Free;
    end;

  // Delete the migrated text file.
  DeleteFile(TextFilePath);
  end;

  IsBackup := True;

  DefaultFolder := IncludeTrailingPathDelimiter(GetEnvironmentVariable('USERPROFILE')) + 'Desktop\Paperless-Backup';
  if not DirectoryExists(DefaultFolder) then ForceDirectories(DefaultFolder);

  // Migrate the old backup target text file into the INI file.
  TextFilePath := IncludeTrailingPathDelimiter(AppDataFolder) + 'BackupZiel.txt';
  if FileExists(TextFilePath) then
  begin
    StoredPath := TFile.ReadAllText(TextFilePath, TEncoding.UTF8).Trim;
    Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + 'Einstellungen.ini');
    try
      Ini.WriteString('Pfade', 'BackupZiel', StoredPath);
      Ini.UpdateFile; // Write immediately.
      // Read the value back from the INI file.
      StoredPath := Ini.ReadString('Pfade', 'BackupZiel', '').Trim;
    finally
      Ini.Free;
    end;
    // Delete the old text file after a successful migration.
    if StoredPath <> '' then DeleteFile(TextFilePath);
  end;

  // Read the last backup folder from the INI file.
  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + 'Einstellungen.ini');
  try
    LastBackupFolder := Ini.ReadString('Pfade', 'BackupZiel', '').Trim;
  finally
    Ini.Free;
  end;

   CheckScheduleAllowed;

  LoadScheduleSettings;

  StatusBar1.Panels.Clear;
  StatusBar1.Height:= 25;
  StatusBar1.Font.Size:= 10;
  StatusBar1.Font.Style:= [fsBold];
  StatusBar1.Panels.Add.Text := ' ' + ' #ComputerRalle - Paperless Backup Programm ' + GetFileVersion(Application.ExeName);
  TabControl1.TabIndex := 0;

  if TabControl1.TabIndex = 0 then
   begin
   BackupRestorePan.Visible := True;
   BackupPlanPan.Visible := False;
   RetentionPan.Visible := False;
   EMailSettingsPan.Visible := False;
   SettingsPan.Visible := False;
   HelpPan.Visible := False;
   end;
   if TabControl1.TabIndex = 1 then
   begin
   BackupRestorePan.Visible := False;
   BackupPlanPan.Visible := True;
   RetentionPan.Visible := False;
   EMailSettingsPan.Visible := False;
   SettingsPan.Visible := False;
   HelpPan.Visible := False;
   end;
  if TabControl1.TabIndex = 2 then
  begin
   BackupRestorePan.Visible := False;
   BackupPlanPan.Visible := False;
   RetentionPan.Visible := True;
   EMailSettingsPan.Visible := False;
   SettingsPan.Visible := False;
   HelpPan.Visible := False;
   end;
  if TabControl1.TabIndex = 3 then
   begin
   BackupRestorePan.Visible := False;
   BackupPlanPan.Visible := False;
   RetentionPan.Visible := False;
   EMailSettingsPan.Visible := True;
   SettingsPan.Visible := False;
   HelpPan.Visible := False;
   end;
  if TabControl1.TabIndex = 4 then
   begin
   BackupRestorePan.Visible := False;
   BackupPlanPan.Visible := False;
   RetentionPan.Visible := False;
   EMailSettingsPan.Visible := False;
   SettingsPan.Visible := True;
   HelpPan.Visible := False;
   LoadEmailSettings;
   end;
  if TabControl1.TabIndex = 5 then
   begin
   BackupRestorePan.Visible := False;
   BackupPlanPan.Visible := False;
   RetentionPan.Visible := False;
   EMailSettingsPan.Visible := False;
   SettingsPan.Visible := False;
   HelpPan.Visible := True;
   LoadEmailSettings;
   end;

  BackupTargetFilePath := IncludeTrailingPathDelimiter(AppDataFolder) + 'BackupZiel.txt';

  ComposePathTextFile := IncludeTrailingPathDelimiter(AppDataFolder) + 'DockerComposePfad.txt';
  if FileExists(ComposePathTextFile) then
    begin
      // Read the old path from the text file.
      OldPath := TFile.ReadAllText(ComposePathTextFile, TEncoding.UTF8);

      // Store it in the INI file.
      Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + 'Einstellungen.ini');
      try
        Ini.WriteString('Pfade', 'DockerComposePfad', OldPath);
        Ini.UpdateFile; // Write immediately.
      finally
        Ini.Free;
      end;

      // Delete the migrated text file.
      DeleteFile(ComposePathTextFile);
  end;

  // Prepare the default compose path.
  NewComposePath := IncludeTrailingPathDelimiter(AppDataFolder);

  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + 'Einstellungen.ini');
  try
    Value := Ini.ReadString('Einrichtung', 'Installation abgeschlossen', '');
  finally
    Ini.Free;
  end;

  // Migrate the old installation-completed text file into the INI file.
  InstallationCompletedFilePath := IncludeTrailingPathDelimiter(AppDataFolder) + 'InstallationAbgeschlossen.txt';
  if FileExists(InstallationCompletedFilePath) then
    begin
      Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + 'Einstellungen.ini');
      try
        Ini.WriteString('Einrichtung', 'Installation abgeschlossen', 'Ja');
        Ini.UpdateFile;
      finally
        Ini.Free;
      end;

      // Delete the migrated text file.
      DeleteFile(InstallationCompletedFilePath);
    end;

  // Read the INI value again after possible migration.
  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + 'Einstellungen.ini');
  try
    Value := Ini.ReadString('Einrichtung', 'Installation abgeschlossen', '');
  finally
    Ini.Free;
  end;

  if Value <> 'Ja' then
  begin
    NewComposePath := IncludeTrailingPathDelimiter(AppDataFolder) + 'docker-compose.yml';

    if not FileExists(NewComposePath) then
    begin
      Application.MessageBox(
        'Bitte beachten: Es wird nun eine neue, für das Programm optimierte docker-compose.yml angelegt.' + #13#10 +
        'Ein manuelles Wählen der Datei wird dadurch unnötig und vereinfacht die Nutzung des Programmes.' + #13#10 + #13#10 +
        'Im nächsten Schritt fragt die Software, ob Paperless installiert werden soll.' + #13#10 + #13#10 +
        'Bestätigen Sie diese Frage mit "Ja".' + #13#10 + #13#10 +
        'Es werden dann weitere wichtige Einstellungen und Pfade erzeugt, um die neue Version verwendbar zu machen.' + #13#10 + #13#10 +
        'Bitte machen Sie nach der erfolgten Installation ein neues Backup, mit dem "Paperless Backup Starten"-Button' + #13#10 +
        'damit das Programm die benötigten Skripte und Einstellungen neu erzeugen und optimieren kann.',
        'Hinweis',
        MB_OK or MB_ICONINFORMATION or MB_TOPMOST
      );

      ShouldWriteNewCompose := True;
      HinweisFrm.CreateDockerComposeFile;
      HinweisFrm.InstallPaperlessBtnClick(Self);
    end;

    ComposePath := NewComposePath;
  end else
    begin
      ComposePath := IncludeTrailingPathDelimiter(AppDataFolder) + 'docker-compose.yml';
    end;

  Panel6.ParentBackground := False;
  Panel6.StyleElements := Panel6.StyleElements - [seClient];
  Panel6.Color := $00234D11;

  Panel7.ParentBackground := False;
  Panel7.StyleElements := Panel7.StyleElements - [seClient];
  Panel7.Color := $00234D11;

  Panel11.ParentBackground := False;
  Panel11.StyleElements := Panel7.StyleElements - [seClient];
  Panel11.Color := $00234D11;

  Panel14.ParentBackground := False;
  Panel14.StyleElements := Panel14.StyleElements - [seClient];
  Panel14.Color := $00234D11;

  Panel15.ParentBackground := False;
  Panel15.StyleElements := Panel15.StyleElements - [seClient];
  Panel15.Color := $00234D11;

  Panel16.ParentBackground := False;
  Panel16.StyleElements := Panel16.StyleElements - [seClient];
  Panel16.Color := $00234D11;

  StaticText3.Caption := '';
  ScriptSavedLbl.Caption := '';
  StaticText3.Caption := '';

  // Load the backup path if it exists.
  if FileExists(BackupTargetFilePath) then BackupPath := TFile.ReadAllText(BackupTargetFilePath).Trim;

  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + 'Einstellungen.ini');
  try
    StoredPath := Ini.ReadString('Pfade', 'DockerComposePfad', '').Trim;
  finally
    Ini.Free;
  end;

  // Load the last valid compose path and backup target from the INI file.
  if StoredPath <> '' then
  begin
    ComposePath := StoredPath;
    ComposeName := ExtractFileName(ExcludeTrailingPathDelimiter(ComposePath));
    StaticText2.Caption := 'Aktuell ist folgender Pfad ausgewählt, in dem die docker-compose.yml Datei liegt: ';
    StaticText3.Caption := ComposePath;
    StartPaperlessBackupBtn.Enabled := True;
    RestorePaperlessBackupBtn.Enabled := True;
    CanStartBackupSTxt.Visible := True;
    RestoreCanStartSTxt.Visible := True;
    StaticText5.Visible := True;
    BackupWiederherProgNeuStartLbl.Visible := False;
  end;

  StartParameter := ParamStr(1);

  if StartParameter = '/geplant' then
  begin
    RestorePaperlessBackupBtn.Visible:=False;
    StartPaperlessBackupBtn.Visible:=False;
    StaticText2.Visible:=False;
    StaticText3.Visible:=False;
    CanStartBackupSTxt.Visible:=False;
    BackupWiederherProgNeuStartLbl.Visible:=False;
    StaticText5.Visible:=False;
    RestoreCanStartSTxt.Visible:=False;
    AutostartLbl.Visible:=True;
    TabControl1.Enabled:=False;
    IsAutostart := True;
    RunAutostartBackup();
  end else
    begin
    end;

   // Read trash retention from the INI file and show it in the edit field.
   Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + 'Einstellungen.ini');
   try
    try
      TrashRetentionDays := Ini.ReadInteger('Einstellungen', 'Papierkorb Aufbewahrungszeit in Tagen', 365);
    except
      TrashRetentionDays := 365;
    end;
    PapierkorbAufbewahrungEdit.Text := IntToStr(TrashRetentionDays);
   finally
    Ini.Free;
   end;

   WriteComposeContainerAndVolumeInfo(ExtractFilePath(ComposePath));


  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + 'Einstellungen.ini');
  // Read image versions from the INI file and apply defaults when empty.
  try
    redis_version_edit.Text := Ini.ReadString('Versionen', 'Redis-Version', '');
    if redis_version_edit.Text = '' then
    redis_version_edit.Text := '7';

    paperless_version_edit.Text := Ini.ReadString('Versionen', 'Paperless-Version', '');
    if paperless_version_edit.Text = '' then
    paperless_version_edit.Text := '2.19.1';

    postgres_version_edit.Text := Ini.ReadString('Versionen', 'Postgres-Version', '');
    if postgres_version_edit.Text = '' then
    postgres_version_edit.Text := '17';

    gotenberg_version_edit.Text := Ini.ReadString('Versionen', 'Gotenberg-Version', '');
    if gotenberg_version_edit.Text = '' then
    gotenberg_version_edit.Text := '8';

    tika_version_edit.Text := Ini.ReadString('Versionen', 'Tika-Version', '');
    if tika_version_edit.Text = '' then
    tika_version_edit.Text := 'latest';

    alpine_version_edit.Text := Ini.ReadString('Versionen', 'Alpine-Version', '');
    if alpine_version_edit.Text = '' then
    alpine_version_edit.Text := '3';

    busybox_version_edit.Text := Ini.ReadString('Versionen', 'Busybox-Version', '');
    if busybox_version_edit.Text = '' then
    busybox_version_edit.Text := '1';

    redis_version := redis_version_edit.Text;
    paperless_ngx_version := paperless_version_edit.Text;
    postgresql_version := postgres_version_edit.Text;
    gotenberg_version := gotenberg_version_edit.Text;
    tika_version := tika_version_edit.Text;
    alpine_version := alpine_version_edit.Text;
    busybox_version := busybox_version_edit.Text;
  finally
    ini.Free;
  end;


  LoadUpdateIniFile();
end;

// Start a backup when the program was launched by the Windows task scheduler.
procedure TMainformFrm.RunAutostartBackup();
begin
  // Kept as a small wrapper for scheduled starts.
  StartPaperlessBackupBtn.Click;
end;

// Recreate and run the manual backup script for the current compose path.
procedure TMainformFrm.StartPaperlessBackupScriptBtnClick(Sender: TObject);
begin
  CreateBackupScript(ExtractFilePath(ComposePath));
end;

// Switch between the main panels and refresh panel-specific settings.
procedure TMainformFrm.TabControl1Change(Sender: TObject);
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + 'Einstellungen.ini');
    try
      Ini.WriteString('Pfade', 'DockerComposePfad', IncludeTrailingPathDelimiter(ExtractFilePath(ComposePath)) + 'docker-compose.yml');
      Ini.UpdateFile; // Write immediately.
    finally
      Ini.Free;
    end;


  if TabControl1.TabIndex = 0 then
   begin
   BackupRestorePan.Visible := True;
   BackupPlanPan.Visible := False;
   RetentionPan.Visible := False;
   EMailSettingsPan.Visible := False;
   SettingsPan.Visible := False;
   HelpPan.Visible := False;
   end;
   if TabControl1.TabIndex = 1 then
   begin
   BackupRestorePan.Visible := False;
   BackupPlanPan.Visible := True;
   RetentionPan.Visible := False;
   EMailSettingsPan.Visible := False;
   SettingsPan.Visible := False;
   HelpPan.Visible := False;
   end;
  if TabControl1.TabIndex = 2 then
  begin
   BackupRestorePan.Visible := False;
   BackupPlanPan.Visible := False;
   RetentionPan.Visible := True;
   EMailSettingsPan.Visible := False;
   SettingsPan.Visible := False;
   HelpPan.Visible := False;
   end;
  if TabControl1.TabIndex = 3 then
   begin
   BackupRestorePan.Visible := False;
   BackupPlanPan.Visible := False;
   RetentionPan.Visible := False;
   EMailSettingsPan.Visible := True;
   SettingsPan.Visible := False;
   HelpPan.Visible := False;
   LoadEmailSettings;
   if SMTPServerEdit.Enabled = True then
   SMTPServerEdit.SetFocus;
   end;
  if TabControl1.TabIndex = 4 then
   begin
   BackupRestorePan.Visible := False;
   BackupPlanPan.Visible := False;
   RetentionPan.Visible := False;
   EMailSettingsPan.Visible := False;
   SettingsPan.Visible := True;
   HelpPan.Visible := False;
   SettingsSavedLbl.Visible:=False;
   end;
  if TabControl1.TabIndex = 5 then
   begin
   BackupRestorePan.Visible := False;
   BackupPlanPan.Visible := False;
   RetentionPan.Visible := False;
   EMailSettingsPan.Visible := False;
   SettingsPan.Visible := False;
   HelpPan.Visible := True;
   SettingsSavedLbl.Visible:=False;

    with ImpressumLbl do
    begin
      StyleElements := StyleElements - [seFont];
      Transparent := True;
      Font.Color := clYellow;
    end;

    with PaplerlessPlayListLbl do
    begin
      StyleElements := StyleElements - [seFont];
      Transparent := True;
      Font.Color := clYellow;
    end;

    with MeinYouTubeKanalLbl do
    begin
      StyleElements := StyleElements - [seFont];
      Transparent := True;
      Font.Color := clYellow;
    end;

    with BackupProgrammAnleitungLbl do
    begin
      StyleElements := StyleElements - [seFont];
      Transparent := True;
      Font.Color := clYellow;
    end;

    with Web1Lbl do
    begin
      StyleElements := StyleElements - [seFont];
      Transparent := True;
      Font.Color := clYellow;
    end;

    with Web2Lbl do
    begin
      StyleElements := StyleElements - [seFont];
      Transparent := True;
      Font.Color := clYellow;
    end;

    with NewsletterLbl do
    begin
      StyleElements := StyleElements - [seFont];
      Transparent := True;
      Font.Color := clYellow;
    end;

   end;

   AutostartLbl.Visible:=False;
   CheckScheduleAllowed;
end;

// --------------------------------------------------------------
// Schedule
// --------------------------------------------------------------
// Validate the trash-retention input while the user types.
procedure TMainformFrm.TrashRetentionEditChange(Sender: TObject);
var
  i: Integer;
  s: string;
  istGanzzahl: Boolean;
begin
  s := PapierkorbAufbewahrungEdit.Text;
  istGanzzahl := True;

  // Allow only whole numbers.
  for i := 1 to Length(s) do
    if not CharInSet(s[i], ['0'..'9']) then
    begin
      istGanzzahl := False;
      Break;
    end;

  if istGanzzahl = False then
  begin
    OnlyIntegerAllowedLbl.Visible := True;
    SaveSettingsBtn.Enabled:=False;
  end else
  begin
    OnlyIntegerAllowedLbl.Visible := False;
    SaveSettingsBtn.Enabled := True;
  end;
end;



// Save how many scheduled backup folders should be kept.
procedure TMainformFrm.SaveRetentionBtnClick(Sender: TObject);
var
  Ini: TIniFile;
  MaxBackupFolders: Integer;
begin
  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + 'Einstellungen.ini');
  try
    // Save the retention setting.
    Ini.WriteInteger('Zeitplan', 'BackupsBehalten', KeepBackupsSpE.Value);
    // Write immediately.
    Ini.UpdateFile;
    // Read the value back safely.
    try
      MaxBackupFolders := Ini.ReadInteger('Zeitplan', 'BackupsBehalten', 0);
    except
      MaxBackupFolders := 0;
    end;
  finally
    Ini.Free;
  end;
  // Show the label only when all backups are kept.
  if KeepBackupsSpE.Value = 0 then
  AllBackupsAreRetainedLbl.Visible := True else
  AllBackupsAreRetainedLbl.Visible := False;
end;

// Enable or disable all controls that belong to automatic backups.
procedure TMainformFrm.AutoBackupCBClick(Sender: TObject);
begin
  // Enable or disable schedule controls.
  if AutoBackupCB.Checked = True then
   begin
     WeekDaysPan.Enabled := True;
     TimePlanPan.Enabled := True;
    MondayCB.Enabled := True;
    TuesdayCB.Enabled := True;
    WednesdayCB.Enabled := True;
    ThursdayCB.Enabled := True;
    FridayCB.Enabled := True;
    SaturdayCB.Enabled := True;
    SundayCB.Enabled := True;
    HourSpE.Enabled := True;
    MinuteSpE.Enabled := True;
    KeepBackupsSpE.Enabled := True;
    HourLbl.Enabled := True;
    MinuteLbl.Enabled := True;
    UhrzeitLbl.Enabled := True;
   end else
   begin
     WeekDaysPan.Enabled := False;
     TimePlanPan.Enabled := False;
    MondayCB.Enabled := False;
    TuesdayCB.Enabled := False;
    WednesdayCB.Enabled := False;
    ThursdayCB.Enabled := False;
    FridayCB.Enabled := False;
    SaturdayCB.Enabled := False;
    SundayCB.Enabled := False;
    HourSpE.Enabled := False;
    MinuteSpE.Enabled := False;
    KeepBackupsSpE.Enabled := True;
    HourLbl.Enabled := False;
    MinuteLbl.Enabled := False;
    UhrzeitLbl.Enabled := False;
   end;
end;

// Save the selected weekdays and time for the Windows scheduled task.
procedure TMainformFrm.SaveScheduleSettings;
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + 'Einstellungen.ini');
  try
    Ini.WriteBool('Zeitplan', 'Backup nach diesem Zeitplan',   AutoBackupCB.Checked);
    Ini.WriteBool('Zeitplan', 'Montag',   MondayCB.Checked);
    Ini.WriteBool('Zeitplan', 'Dienstag', TuesdayCB.Checked);
    Ini.WriteBool('Zeitplan', 'Mittwoch', WednesdayCB.Checked);
    Ini.WriteBool('Zeitplan', 'Donnerstag', ThursdayCB.Checked);
    Ini.WriteBool('Zeitplan', 'Freitag',  FridayCB.Checked);
    Ini.WriteBool('Zeitplan', 'Samstag',  SaturdayCB.Checked);
    Ini.WriteBool('Zeitplan', 'Sonntag',  SundayCB.Checked);
    Ini.WriteInteger('Zeitplan', 'Stunde', HourSpE.Value);
    Ini.WriteInteger('Zeitplan', 'Minute', MinuteSpE.Value);
  finally
    Ini.Free;
  end;
end;

// Remove the Windows scheduled task for automatic backups.
procedure TMainformFrm.DeleteBackupPlanBtnClick(Sender: TObject);
var
  ShellExecuteInfo: TShellExecuteInfo;
  CmdTargetPath: string;
  Ini: TIniFile;
begin
  // Create a script that removes the scheduled task.
  CmdTargetPath := IncludeTrailingPathDelimiter(AppDataFolder) + 'Backup-Zeitplan-Entfernen.cmd';
  CreateDeleteBackupScheduleCmdScript(CmdTargetPath);
  ScriptSavedLbl.Caption := 'Skript gespeichert: ' + CmdTargetPath;

  // Run the script silently in the background.
  FillChar(ShellExecuteInfo, SizeOf(ShellExecuteInfo), 0);
  ShellExecuteInfo.cbSize := SizeOf(ShellExecuteInfo);
  ShellExecuteInfo.fMask := SEE_MASK_NOCLOSEPROCESS;
  ShellExecuteInfo.Wnd := 0;
  ShellExecuteInfo.lpFile := PChar('cmd.exe');
  ShellExecuteInfo.lpParameters := PChar('/c "' + CmdTargetPath + '"');
  ShellExecuteInfo.nShow := SW_HIDE;
  ShellExecuteEx(@ShellExecuteInfo);

  // Reset the checkbox.
  AutoBackupCB.Checked := False;
  // Disable related controls and save the setting.
  AutoBackupCBClick(nil);
  // Make sure the INI value is set to False.
  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + 'Einstellungen.ini');
  try
    Ini.WriteBool('Zeitplan', 'Backup nach diesem Zeitplan', False);
  finally
    Ini.Free;
  end;
  ShowMessage('Der geplante Backup-Zeitplan wurde entfernt.');
end;

// Load saved schedule settings into the form controls.
procedure TMainformFrm.LoadScheduleSettings;
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + 'Einstellungen.ini');
  try
    AutoBackupCB.Checked := Ini.ReadBool('Zeitplan', 'Backup nach diesem Zeitplan', False);
    MondayCB.Checked     := Ini.ReadBool('Zeitplan', 'Montag', False);
    TuesdayCB.Checked   := Ini.ReadBool('Zeitplan', 'Dienstag', False);
    WednesdayCB.Checked   := Ini.ReadBool('Zeitplan', 'Mittwoch', False);
    ThursdayCB.Checked := Ini.ReadBool('Zeitplan', 'Donnerstag', False);
    FridayCB.Checked    := Ini.ReadBool('Zeitplan', 'Freitag', False);
    SaturdayCB.Checked    := Ini.ReadBool('Zeitplan', 'Samstag', False);
    SundayCB.Checked    := Ini.ReadBool('Zeitplan', 'Sonntag', False);

    try
      HourSpE.Value := Ini.ReadInteger('Zeitplan', 'Stunde', 2);
    except
      HourSpE.Value := 2;
    end;

    try
      MinuteSpE.Value := Ini.ReadInteger('Zeitplan', 'Minute', 0);
    except
      MinuteSpE.Value := 0;
    end;

    try
      KeepBackupsSpE.Value := Ini.ReadInteger('Zeitplan', 'BackupsBehalten', 0);
    except
      KeepBackupsSpE.Value := 0;
    end;

  finally
    Ini.Free;
  end;

  // Update the UI after loading settings.
  AutoBackupCBClick(nil);

  Label12.Visible := True;
  Label11.Visible := True;

  if KeepBackupsSpE.Value = 0 then
  AllBackupsAreRetainedLbl.Visible := True else
  AllBackupsAreRetainedLbl.Visible := False;
end;

// Create or update the Windows scheduled task for automatic backups.
procedure TMainformFrm.CreateBackupPlanBtnClick(Sender: TObject);
var
  Weekdays: string;
  Hour, Minute: string;
  ScriptPath, ComposePath, TargetCmdPath: string;
  ShellExecuteInfo: TShellExecuteInfo;
  ProgramPath: String;
  Ini: TIniFile;
  ComposePathFromIni: string;
  ComposePathTextFile: string;
begin
  // Get the executable path.
  ProgramPath := ParamStr(0);
  SaveScheduleSettings;
  // Check prerequisites.
  // Read the docker-compose path from the INI file.
  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + 'Einstellungen.ini');
  try
    ComposePathFromIni := Ini.ReadString('Pfade', 'DockerComposePfad', '').Trim;
  finally
    Ini.Free;
  end;
  // Stop when the compose path is missing.
  if (ComposePathFromIni = '') or
     not FileExists(ComposePathFromIni) then
  begin
    ShowMessage('Fehlender Docker-Compose-Pfad.' + sLineBreak +
                'Bitte führen Sie zuerst ein reguläres Backup durch,' + sLineBreak +
                'damit der Speicherort festgelegt werden kann.');
    Exit;
  end;

  // Build the scheduled start time.
  Hour := Format('%.2d', [HourSpE.Value]);
  Minute := Format('%.2d', [MinuteSpE.Value]);
  // Build the weekday list for schtasks.
  if MondayCB.Checked then Weekdays := Weekdays + 'MON,';
  if TuesdayCB.Checked then Weekdays := Weekdays + 'TUE,';
  if WednesdayCB.Checked then Weekdays := Weekdays + 'WED,';
  if ThursdayCB.Checked then Weekdays := Weekdays + 'THU,';
  if FridayCB.Checked then Weekdays := Weekdays + 'FRI,';
  if SaturdayCB.Checked then Weekdays := Weekdays + 'SAT,';
  if SundayCB.Checked then Weekdays := Weekdays + 'SUN,';
  if Weekdays = '' then
  begin
    ShowMessage('Bitte wählen Sie mindestens einen Wochentag aus.');
    Exit;
  end;
  Delete(Weekdays, Length(Weekdays), 1);
  // Build the path to the planned backup CMD file.
  try
    Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + 'Einstellungen.ini');
    try
      ComposePath := Ini.ReadString('Pfade', 'DockerComposePfad', '').Trim;
    finally
      Ini.Free;
    end;

    if ComposePath = '' then
    begin
      ShowMessage('Fehler: Kein Docker-Compose-Pfad in der INI gespeichert.');
      Exit;
    end;

    // Delete the old marker file if it still exists.
    ComposePathTextFile := IncludeTrailingPathDelimiter(AppDataFolder) + 'DockerComposePfad.txt';
    if FileExists(ComposePathTextFile) then DeleteFile(ComposePathTextFile);

    TargetCmdPath := IncludeTrailingPathDelimiter(ExtractFilePath(ComposePath)) + 'paperless-backup-geplant.cmd';
  except
    ShowMessage('Fehler beim Lesen des Compose-Pfads.');
    Exit;
  end;


  TargetCmdPath := IncludeTrailingPathDelimiter(ExtractFilePath(ComposePath)) + 'paperless-backup-geplant.cmd';
  if not FileExists(TargetCmdPath) then
  begin
    ShowMessage('Das geplante Backup-Skript wurde nicht gefunden:' + sLineBreak + TargetCmdPath + sLineBreak + 'Bitte erzeugen Sie es zuerst.');
    Exit;
  end;
  // Write the scheduler setup script.
  ScriptPath := IncludeTrailingPathDelimiter(AppDataFolder) + 'Backup-Zeitplan-Anlegen.cmd';
  // The scheduled task starts this program with the /geplant parameter.
  CreateBackupScheduleCmdScript(ScriptPath, ProgramPath, Weekdays, Hour, Minute);

  ShowMessage('Die geplante Backup-Aufgabe wurde als Aufgabe eingetragen und als Skript gespeichert:' + sLineBreak + ScriptPath);
  // Run the script silently in the background.
  FillChar(ShellExecuteInfo, SizeOf(ShellExecuteInfo), 0);
  ShellExecuteInfo.cbSize := SizeOf(ShellExecuteInfo);
  ShellExecuteInfo.fMask := SEE_MASK_NOCLOSEPROCESS;
  ShellExecuteInfo.Wnd := 0;
  ShellExecuteInfo.lpFile := PChar('cmd.exe');
  ShellExecuteInfo.lpParameters := PChar('/c "' + ScriptPath + '"');
  ShellExecuteInfo.nShow := SW_HIDE;
  ShellExecuteEx(@ShellExecuteInfo);
end;

// Load saved Paperless email settings from email-versand.env.
procedure TMainformFrm.LoadEmailSettings;
var
  EnvFilePath: string;
  EnvList: TStringList;
begin
  // Path to the .env file in the app data folder.
  EnvFilePath := IncludeTrailingPathDelimiter(AppDataFolder) + 'email-versand.env';

  // Load settings only when the file exists.
  if FileExists(EnvFilePath) then
  begin
    // Use a string list to read the .env file.
    EnvList := TStringList.Create;
    try
      // Read the .env file.
      EnvList.LoadFromFile(EnvFilePath);

      // Check whether setup is still pending.
      if EnvList.Values['Eingerichtet'] = 'Nein' then
      begin
        RequireCompletedSettings;
      end
      else
      begin
        // Copy saved values into the edit fields.
        SMTPServerEdit.Text := EnvList.Values['PAPERLESS_EMAIL_HOST'];
        SMTPPortEdit.Text := EnvList.Values['PAPERLESS_EMAIL_PORT'];
        UserNameEdit.Text := EnvList.Values['PAPERLESS_EMAIL_HOST_USER'];
        MailAccountPasswordEdit.Text := EnvList.Values['PAPERLESS_EMAIL_HOST_PASSWORD'];
        EMailSentFromEdit.Text := EnvList.Values['PAPERLESS_EMAIL_FROM'];

        // Restore the SSL/TLS selection.
        if EnvList.Values['PAPERLESS_EMAIL_USE_SSL'] = 'true' then
        begin
          SSLoTLSRg.ItemIndex := 0;  // SSL
        end
        else if EnvList.Values['PAPERLESS_EMAIL_USE_TLS'] = 'true' then
        begin
          SSLoTLSRg.ItemIndex := 1;  // TLS
        end
        else
        begin
          // No SSL/TLS option is selected.
          SSLoTLSRg.ItemIndex := -1;
        end;

        // Empty values also mean no selection.
        if (EnvList.Values['PAPERLESS_EMAIL_USE_SSL'] = '') and (EnvList.Values['PAPERLESS_EMAIL_USE_TLS'] = '') then
        begin
          SSLoTLSRg.ItemIndex := -1;
        end;
      end;

    except
      on E: Exception do
        ShowMessage('Fehler beim Laden der Konfiguration: ' + E.Message);
    end;
  end
  else
  begin
    ShowMessage('Die Datei "email-versand.env" existiert nicht.');
  end;
end;

// Prepare the compose file before email settings can be completed.
procedure TMainformFrm.RequireCompletedSettings;
var
  Response: Integer;
begin
  IsUpdate:= True;

  // Ask before changing the compose file and restarting Paperless.
  Response := MessageDlg('E-Mail-Einstellungen stehen aus. Dazu muss Paperless gestoppt werden.' + sLineBreak +
                        'Es werden einige Einstellungen angepasst, eine neue docker-compose-Datei'  + sLineBreak +
                        'erzeugt und Paperless dann neu gestartet.' + sLineBreak + sLineBreak +
                        'Wenn dieser Vorgang abgeschlossen ist, können Sie ihre Mail-Server-Daten ins Formular eintragen.'  + sLineBreak +
                        'Danach ist Paperless in der Lage, Dokumente via Mail zu versenden' + sLineBreak + sLineBreak +
                        'Möchten Sie fortfahren?', mtConfirmation, [mbOk, mbCancel], 0);

  // Continue when the user confirms.
  if Response = mrOk then
  begin
    // Write a new docker-compose.yml file.
     HinweisFrm.CreateDockerComposeFile;
  end
  else
  begin
    // Stop when the user cancels.
    ShowMessage('Der Vorgang wurde abgebrochen.');
  end;
end;

// --------------------------------------------------------------
// This procedure saves the current settings and version information
// into the settings INI file. The routine is divided into two main sections:
// 1. General settings (e.g., trash retention time)
// 2. Versions of Docker components (Paperless, Redis, PostgreSQL, etc.)
// After saving, the user is asked whether to restart Paperless
// to apply the new configuration.
// --------------------------------------------------------------
procedure TMainformFrm.SaveSettingsBtnClick(Sender: TObject);
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + 'Einstellungen.ini');
  try
    // --------------------------------------------------------------
    // Section 1: Save general settings.
    // --------------------------------------------------------------
    Ini.WriteInteger('Einstellungen', 'Papierkorb Aufbewahrungszeit in Tagen',
      StrToIntDef(PapierkorbAufbewahrungEdit.Text, 0));
    Ini.UpdateFile; // Write immediately.

    SettingsSavedLbl.Visible := True; // Show confirmation.

    // Read the saved value back safely.
    try
      TrashRetentionDays :=
        Ini.ReadInteger('Einstellungen', 'Papierkorb Aufbewahrungszeit in Tagen', 0);
    except
      TrashRetentionDays := 365; // Default fallback.
    end;

    // --------------------------------------------------------------
    // Section 2: Save version information.
    // --------------------------------------------------------------
    Ini.WriteString('Versionen', 'Paperless-Version', paperless_version_edit.Text);
    Ini.WriteString('Versionen', 'Redis-Version', redis_version_edit.Text);
    Ini.WriteString('Versionen', 'Postgres-Version', postgres_version_edit.Text);
    Ini.WriteString('Versionen', 'Gotenberg-Version', gotenberg_version_edit.Text);
    Ini.WriteString('Versionen', 'Tika-Version', tika_version_edit.Text);
    Ini.WriteString('Versionen', 'Alpine-Version', alpine_version_edit.Text);
    Ini.WriteString('Versionen', 'Busybox-Version', busybox_version_edit.Text);
    Ini.UpdateFile;

  finally
    Ini.Free;
  end;

  // --------------------------------------------------------------
  // Section 3: Ask whether Paperless should be restarted.
  // --------------------------------------------------------------
  if MessageDlg(
    'Paperless muss neu gestartet werden, um die Einstellungen zu übernehmen. ' +
    'Möchten Sie Paperless neu starten?',
    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    IsUpdate := True;
    Application.MessageBox(
      'Paperless wird heruntergefahren und es wird nach Updates gesucht. ' + #13#10 +
      'Sollten Updates vorliegen, werden diese installiert.' + #13#10 +
      'Geben Sie Paperless nach dem Neustart Zeit.',
      'Info', MB_OK or MB_ICONINFORMATION or MB_TOPMOST);
    PaperlessUpdate := True;
    IsUpdate := True;
    HinweisFrm.CreateDockerComposeFile;
  end;
end;


// Save the current email fields without triggering a Paperless restart.
procedure TMainformFrm.SaveBlankEmailSettings();
var
  EnvList: TStringList;
  EnvFilePath: string;
begin
  // Build the full path to the file.
  EnvFilePath := IncludeTrailingPathDelimiter(AppDataFolder) + 'email-versand.env';

  // Make sure the app data folder exists.
  if not DirectoryExists(AppDataFolder) then
  begin
    ShowMessage('Der angegebene AppData-Ordner existiert nicht.');
    Exit;
  end;

  // Build the .env file content.
  EnvList := TStringList.Create;
  try
    // Add mail settings to email-versand.env.
    EnvList.Add('PAPERLESS_EMAIL_HOST=' + SMTPServerEdit.Text);
    if SMTPPortEdit.Text = '' then
    EnvList.Add('PAPERLESS_EMAIL_PORT=25') else
    EnvList.Add('PAPERLESS_EMAIL_PORT=' + SMTPPortEdit.Text);
    EnvList.Add('PAPERLESS_EMAIL_HOST_USER=' + UserNameEdit.Text);
    EnvList.Add('PAPERLESS_EMAIL_HOST_PASSWORD=' + MailAccountPasswordEdit.Text);
    EnvList.Add('PAPERLESS_EMAIL_FROM=' + EMailSentFromEdit.Text);

    // Save the SSL/TLS selection.
    if SSLoTLSRg.ItemIndex = 0 then
    begin
      EnvList.Add('PAPERLESS_EMAIL_USE_TLS=false');
      EnvList.Add('PAPERLESS_EMAIL_USE_SSL=true');
    end else
    if SSLoTLSRg.ItemIndex = 1 then
    begin
      EnvList.Add('PAPERLESS_EMAIL_USE_TLS=true');
      EnvList.Add('PAPERLESS_EMAIL_USE_SSL=false');
    end else
    if SSLoTLSRg.ItemIndex = -1 then
    begin
      EnvList.Add('PAPERLESS_EMAIL_USE_TLS=');
      EnvList.Add('PAPERLESS_EMAIL_USE_SSL=');
    end;

    // Save the file.
    EnvList.SaveToFile(EnvFilePath, TEncoding.ANSI);
  except
    on E: Exception do
      ShowMessage('Fehler beim Speichern der Datei: ' + E.Message);
  end;
  // Clean up.
  EnvList.Free;
end;

// Save email settings and restart Paperless so the new values are used.
procedure TMainformFrm.SaveEmailSettingsBtnClick(Sender: TObject);
var
  EnvList: TStringList;
  EnvFilePath: string;
begin
  // Build the full path to the file.
  EnvFilePath := IncludeTrailingPathDelimiter(AppDataFolder) + 'email-versand.env';

  // Make sure the app data folder exists.
  if not DirectoryExists(AppDataFolder) then
  begin
    ShowMessage('Der angegebene AppData-Ordner existiert nicht.');
    Exit;
  end;

  // Build the .env file content.
  EnvList := TStringList.Create;
  try
    // Add mail settings to email-versand.env.
    EnvList.Add('PAPERLESS_EMAIL_HOST=' + SMTPServerEdit.Text);
    EnvList.Add('PAPERLESS_EMAIL_PORT=' + SMTPPortEdit.Text);
    EnvList.Add('PAPERLESS_EMAIL_HOST_USER=' + UserNameEdit.Text);
    EnvList.Add('PAPERLESS_EMAIL_HOST_PASSWORD=' + MailAccountPasswordEdit.Text);
    EnvList.Add('PAPERLESS_EMAIL_FROM=' + EMailSentFromEdit.Text);

    // Save the SSL/TLS selection.
    if SSLoTLSRg.ItemIndex = 0 then
    begin
      EnvList.Add('PAPERLESS_EMAIL_USE_TLS=false');
      EnvList.Add('PAPERLESS_EMAIL_USE_SSL=true');
    end else
    if SSLoTLSRg.ItemIndex = 1 then
    begin
      EnvList.Add('PAPERLESS_EMAIL_USE_TLS=true');
      EnvList.Add('PAPERLESS_EMAIL_USE_SSL=false');
    end else
    if SSLoTLSRg.ItemIndex = -1 then
    begin
      EnvList.Add('PAPERLESS_EMAIL_USE_TLS=');
      EnvList.Add('PAPERLESS_EMAIL_USE_SSL=');
    end;

    // Save the file.
    EnvList.SaveToFile(EnvFilePath, TEncoding.ANSI);

    // Show confirmation when no restart is pending.
    if IsUpdate = False then
  except
    on E: Exception do
      ShowMessage('Fehler beim Speichern der Datei: ' + E.Message);
  end;

  // Clean up.
  EnvList.Free;

    // Restart after changing email settings.
     Application.MessageBox('Paperless muss neu gestartet werden, um die Einstellungen zu übernehmen.', 'Information',
     MB_OK or MB_ICONINFORMATION or MB_TOPMOST);
    SaveEmailSettingsBtn.Enabled:=False;
    CreateRestartScript(ExtractFilePath(ComposePath));
end;

// Create the default email-versand.env file when it is missing.
procedure TMainformFrm.SaveEmptyEnvFile();
var
  EnvList: TStringList;
  EnvFilePath: string;
begin
  // Build the full path to the file.
  EnvFilePath := IncludeTrailingPathDelimiter(AppDataFolder) + 'email-versand.env';

  // Make sure the app data folder exists.
  if not DirectoryExists(AppDataFolder) then
  begin
    ShowMessage('Der angegebene AppData-Ordner existiert nicht.');
    Exit;
  end;

  // Create an empty .env file when it does not exist yet.
  if not FileExists(IncludeTrailingPathDelimiter(AppDataFolder) + 'email-versand.env') then
  begin
    // Build the default .env content.
    EnvList := TStringList.Create;
    try
      // Add default email settings.
      EnvList.Add('Eingerichtet=Nein');
       EnvList.Add('PAPERLESS_EMAIL_HOST=');
      EnvList.Add('PAPERLESS_EMAIL_PORT=');
      EnvList.Add('PAPERLESS_EMAIL_HOST_USER=');
      EnvList.Add('PAPERLESS_EMAIL_HOST_PASSWORD=');
      EnvList.Add('PAPERLESS_EMAIL_FROM=');
      EnvList.Add('PAPERLESS_EMAIL_USE_TLS=');
      EnvList.Add('PAPERLESS_EMAIL_USE_SSL=');
      // Save the file.
      EnvList.SaveToFile(EnvFilePath);
      // Show save errors.
      except
        on E: Exception do
          ShowMessage('Fehler beim Speichern der Datei: ' + E.Message);
    end;
    // Clean up.
    EnvList.Free;
  end;
end;

// Create the CMD file that is called by the Windows scheduled task.
procedure TMainformFrm.CreateBackupPlanScript(const ComposePath: string);
var
  BackupFolderList: TArray<string>;
  MaxBackupFolders: Integer;
  Ini: TIniFile;
  Volumes: TDockerVolumeNames;
begin
  // Stop when no compose path was provided.
  if ComposePath.Trim = '' then
  begin
    ShowMessage('Fehler: Es wurde kein gültiger Compose-Pfad gewählt.');
    Exit;
  end;

  // Prepare a compose name without spaces.
  ComposeName := StringReplace(
                   ExtractFileName(ExcludeTrailingPathDelimiter(ComposePath)),
                   ' ', '-', [rfReplaceAll]);

  // Build the path for the planned backup CMD file.
  CmdTargetPath := IncludeTrailingPathDelimiter(ComposePath) +
                 'paperless-backup-geplant.cmd';
  // Use the saved backup folder, or fall back to Desktop\FallbackBackup.
  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + 'Einstellungen.ini');
  try
    LastBackupFolder := Ini.ReadString('Pfade', 'BackupZiel', '').Trim;
  finally
    Ini.Free;
  end;
  if LastBackupFolder = '' then
    BackupPath := IncludeTrailingPathDelimiter(GetEnvironmentVariable('USERPROFILE')) + 'Desktop\FallbackBackup\'
  else
    BackupPath := IncludeTrailingPathDelimiter(LastBackupFolder);
  Volumes.Data := Volume_data;
  Volumes.DbData := Volume_db_data;
  Volumes.ExportData := Volume_export;
  Volumes.Media := Volume_media;
  CreatePlannedBackupCmdScript(CmdTargetPath, ComposePath, BackupPath, AppDataFolder, PaperlessDBName, Volumes);
  ScriptSavedLbl.Caption := 'Plan gespeichert: ' + CmdTargetPath;
  // Delete old backup folders when a retention limit is set.
  MaxBackupFolders := KeepBackupsSpE.Value;
  if (MaxBackupFolders > 0) and DirectoryExists(BackupPath) then
  begin
    BackupFolderList := TDirectory.GetDirectories(BackupPath);
    TArray.Sort<string>(BackupFolderList, TComparer<string>.Construct(
      function(const L, R: string): Integer
      var
        DL, DR: TDateTime;
        function FolderNameToDateTime(const Folder: string): TDateTime;
        var
          Name: string;
          Year, Month, Day, Hour, Minute, Second: Word;
        begin
          Result := 0;
          Name := ExtractFileName(Folder);
          try
            Year   := StrToInt(Copy(Name, 1, 4));
            Month  := StrToInt(Copy(Name, 6, 2));
            Day    := StrToInt(Copy(Name, 9, 2));
            Hour := StrToInt(Copy(Name, 12, 2));
            Minute := StrToInt(Copy(Name, 15, 2));
            Second:= StrToInt(Copy(Name, 18, 2));
            Result := EncodeDateTime(Year, Month, Day, Hour, Minute, Second, 0);
          except
            Result := 0;
          end;
        end;
      begin
        DL := FolderNameToDateTime(L);
        DR := FolderNameToDateTime(R);
        Result := CompareDateTime(DL, DR); // Ascending: oldest first.
      end));
    if Length(BackupFolderList) > MaxBackupFolders then
    begin
      for var i := 0 to Length(BackupFolderList) - MaxBackupFolders - 1 do
      begin
        TDirectory.Delete(BackupFolderList[i], True); // Delete oldest folders.
      end;
    end;
  end;
end;

// Run the planned backup script without showing a console window.
procedure TMainformFrm.StartBackupPlanScriptSilent;
var
  SI: TStartupInfo;
  PI: TProcessInformation;
  CmdPath: string;
begin
  CmdPath := IncludeTrailingPathDelimiter(AppDataFolder) + 'GeplanterBackupTaskSkript.cmd';
  if not FileExists(CmdPath) then
  begin
    ShowMessage('Das geplante Backup-Skript wurde nicht gefunden: ' + CmdPath);
    Exit;
  end;
  ZeroMemory(@SI, SizeOf(SI));
  SI.cb := SizeOf(SI);
  SI.dwFlags := STARTF_USESHOWWINDOW;
  SI.wShowWindow := SW_HIDE;
  if CreateProcess(nil, PChar('"' + CmdPath + '"'), nil, nil, False,
     CREATE_NO_WINDOW, nil, nil, SI, PI) then
  begin
    CloseHandle(PI.hThread);
    CloseHandle(PI.hProcess);
  end
  else
    ShowMessage('Geplantes Backup-Skript konnte nicht gestartet werden.');
end;

// Reserved click handler for the static text control.
procedure TMainformFrm.StaticText1Click(Sender: TObject);
begin

end;

// --------------------------------------------------------------
// Restore
// --------------------------------------------------------------
// Let the user select a backup folder and create the restore script.
procedure TMainformFrm.RestorePaperlessBackupBtnClick(Sender: TObject);
var
  BackupFolder: string;
  FolderDialog: TFileOpenDialog;
begin
  WriteComposeContainerAndVolumeInfo(ExtractFilePath(ComposePath));
  StartPaperlessBackupBtn.Enabled := False;
  RestorePaperlessBackupBtn.Enabled := False;
  AutostartLbl.Visible:=False;
  ReadContainerNamesFromFile;
  IsBackup := False;
  IsPaperlessInstallation := False;
  if ComposePath = '' then
  begin
    ShowMessage('Bitte zuerst den Paperless-Ordner auswählen.');
    Exit;
  end;
  FolderDialog := TFileOpenDialog.Create(nil);
  try
    FolderDialog.Options := [fdoPickFolders];
    FolderDialog.Title := 'Bitte den Ordner mit Ihrem Paperless-Backup auswählen.';
    FolderDialog.DefaultFolder := GetEnvironmentVariable('USERPROFILE');
    if FolderDialog.Execute then
    begin
      BackupFolder := FolderDialog.FileName;
      CreateRestoreScript(ComposePath, BackupFolder);
    end
    else
    begin
      ShowMessage('Wiederherstellung abgebrochen – kein Backup-Ordner gewählt.');
    end;
  finally
    FolderDialog.Free;
  end;
  // Update the form state.
  StartPaperlessBackupBtn.Enabled := True;
  RestorePaperlessBackupBtn.Enabled := True;
  CanStartBackupSTxt.Visible := False;
  StaticText5.Visible := False;
  RestoreCanStartSTxt.Visible := True;
end;

// Enable the email save button after the user confirms that the update step is done.
procedure TMainformFrm.UpdateDoneCbClick(Sender: TObject);
begin
  if HabeUpdaetGemachtCb.State = cbUnchecked then
  PaperlessUpdateBtn.Enabled := False else
  PaperlessUpdateBtn.Enabled := True;
end;

// Create paperless-restore.cmd for the selected backup folder.
// The script restores the database dump and all Paperless Docker volumes.
procedure TMainformFrm.CreateRestoreScript(const ComposePath, BackupFolder: string);
var
  Volumes: TDockerVolumeNames;
begin
  // Stop when no compose path was provided.
  if ComposePath.Trim = '' then
  begin
    ShowMessage('Fehler: Es wurde kein gültiger Compose-Pfad gewählt.');
    Exit;
  end;
  CmdTargetPath := IncludeTrailingPathDelimiter(ExtractFilePath(ComposePath)) + 'paperless-restore.cmd';
  Volumes.Data := Volume_data;
  Volumes.DbData := Volume_db_data;
  Volumes.ExportData := Volume_export;
  Volumes.Media := Volume_media;
  CreateRestoreCmdScript(CmdTargetPath, ComposePath, BackupFolder, PaperlessDBName, Volumes);
  ScriptSavedLbl.Caption := 'Restore-Skript wurde erstellt: ' + CmdTargetPath;
  StartAndMonitorCmdScript;
end;

// Run the current CMD script, wait for it, and show success or failure.
procedure TMainformFrm.StartAndMonitorCmdScript;
var
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  Cmd: string;
  ExitCode: DWORD;
  ShouldWait: Boolean;
begin
  ShouldWait := False;
  FillChar(StartupInfo, SizeOf(TStartupInfo), 0);
  StartupInfo.cb := SizeOf(TStartupInfo);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := SW_SHOWNORMAL;

  Cmd := 'cmd.exe /C "' + CmdTargetPath + '"'; // Script path.

  if CreateProcess(nil, PChar(Cmd), nil, nil, False, CREATE_NEW_CONSOLE, nil, nil, StartupInfo, ProcessInfo) then
  begin
    ShouldWait := True;
    Sleep(1500);

    if IsUpdate = False then
    begin
        if ShouldWait then
        begin
          // Bring the CMD window to the front.
          ConsoleToFront(ProcessInfo.dwProcessId);

          // Wait for the process to finish.
          WaitForSingleObject(ProcessInfo.hProcess, INFINITE);

          // Check the exit code.
          GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);
          CloseHandle(ProcessInfo.hProcess);
          CloseHandle(ProcessInfo.hThread);
          Sleep(1000);
          if ExitCode = 0 then
          begin
            if IsPaperlessInstallation = True then
            begin
              WriteStandardVersionAfterInstallation;
              Application.MessageBox('Paperless wurde erfolgreich installiert und gestartet.' + #13#10 +
                'Sie können Paperless nun im Browser öffnen (http://localhost:8000). Geben Sie Paperless ein wenig Zeit zum starten.',
                'Installation abgeschlossen', MB_OK or MB_ICONINFORMATION or MB_TOPMOST);

              HinweisFrm.DockerGefundenLbl.Caption := 'Paperless erfolgreich installiert.';
              HinweisFrm.PaperlessInstallierenBtn.Enabled := False;
              HinweisFrm.BitteBestaetigenLbl.Visible := True;

              HinweisFrm.HinweisMemo.Lines.Clear;
              HinweisFrm.HinweisMemo.Lines.Add('Ihr Paperless wurde erfolgreich installiert.');
              HinweisFrm.HinweisMemo.Lines.Add(' ');
              HinweisFrm.HinweisMemo.Lines.Add('Nun können Sie Paperless starten, indem Sie Ihren Browser öffnen');
              HinweisFrm.HinweisMemo.Lines.Add('und folgende Adresse eingeben oder kopieren und einfügen, oder oben den gelben Link klicken:');
              HinweisFrm.HinweisMemo.Lines.Add(' ');
              HinweisFrm.HinweisMemo.Lines.Add('http://localhost:8000');
              HinweisFrm.HinweisMemo.Lines.Add(' ');
              HinweisFrm.HinweisMemo.Lines.Add('Bitte geben Sie dem System ein wenig Zeit, bevor Sie die Seite aufrufen.');
              HinweisFrm.HinweisMemo.Lines.Add(' ');
              HinweisFrm.HinweisMemo.Lines.Add('Nach dem Öffnen von Paperless werden Sie gebeten einen Benutzernamen und ein Passwort zu vergeben. Speichern Sie diese Zugangsdaten in einem Passwortmanager wie KeePassXC!');
              HinweisFrm.LinkKlickLbl.Caption := 'http://localhost:8080';
              HinweisFrm.Label1.Caption := 'Paperless öffnen:';
              HinweisFrm.SieBenoetigenDockerLbl.Caption := 'Alles installiert.';
              HinweisFrm.KeePassXCLbl.Visible := True;
              HinweisFrm.Label1.Visible := True;
              HinweisFrm.LinkKlickLbl.Visible := True;
              HinweisFrm.WillkommenLbl.Visible := False;
              HinweisFrm.ComputerRalleLbl.Visible := False;
              IsPaperlessInstallation := False;
            end
            else if IsBackup = True then
            begin
              if not IsAutostart then
              begin
                Application.MessageBox('Backup abgeschlossen. Sie können das Programm jetzt schließen.' + #13#10 +
                'Bitte geben Sie Paperless Zeit zum starten.',
                'Info', MB_OK or MB_ICONINFORMATION or MB_TOPMOST);
              end;

              HinweisFrm.WriteImageVersion(BackupPath);

            end
            else
            begin
              if not IsAutostart = True then
              begin
                if IsUpdate = True then
                begin
                  Application.MessageBox('Update abgeschlossen. Sie können das Programm jetzt schließen.' + #13#10 +
                  'Bitte geben Sie Paperless Zeit zum starten.',
                  'Info', MB_OK or MB_ICONINFORMATION or MB_TOPMOST);
                end else
                begin
                  Application.MessageBox('Wiederherstellung abgeschlossen. Sie können das Programm jetzt schließen.' + #13#10 +
                  'Bitte geben Sie Paperless Zeit zum starten.',
                  'Info', MB_OK or MB_ICONINFORMATION or MB_TOPMOST);
                end;
              end;
            end;
          end
          else
          begin
            ShowMessage('Vorgang fehlgeschlagen. Fehlercode: ' + IntToStr(ExitCode));
          end;
        end else
        ShowMessage('Fehler beim Starten des Skripts.');
    end else
        begin
          // Bring the CMD window to the front.
          ConsoleToFront(ProcessInfo.dwProcessId);
          // Wait for the process to finish.
          WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
          // Check the exit code.
          GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);
          CloseHandle(ProcessInfo.hProcess);
          CloseHandle(ProcessInfo.hThread);
          if ExitCode = 0 then
          begin
            SaveBlankEmailSettings();
            Application.MessageBox('Paperless wurde erfolgreich aktualisiert' + #13#10 +
            'Sie können Paperless nun im Browser öffnen (http://localhost:8000). Geben Sie Paperless ein wenig Zeit zum starten.',
            'Installation abgeschlossen', MB_OK or MB_ICONINFORMATION or MB_TOPMOST);
            IsUpdate := False;
          end;
        end;
  end;
  ActiveControl := nil;

  if IsAutostart = True then
  Application.Terminate;

end;

// Run the restart or update script and show the final result to the user.
procedure TMainformFrm.StartAndMonitorRestart;
var
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  Cmd: string;
  ExitCode: DWORD;
begin
  FillChar(StartupInfo, SizeOf(TStartupInfo), 0);
  StartupInfo.cb := SizeOf(TStartupInfo);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := SW_SHOWNORMAL;
  Cmd := 'cmd.exe /C "' + CmdTargetPath + '"'; // Script path.

  if PaperlessUpdate = False then
  begin
    // Start the process.
    if CreateProcess(nil, PChar(Cmd), nil, nil, False, CREATE_NEW_CONSOLE, nil, nil, StartupInfo, ProcessInfo) then
    begin
      Sleep(1000);
      // Bring the CMD window to the front.
      ConsoleToFront(ProcessInfo.dwProcessId);
      // Wait for the process to finish.
      WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
      // Check the exit code.
      GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);
      CloseHandle(ProcessInfo.hProcess);
      CloseHandle(ProcessInfo.hThread);

      // Exit code 0 means success.
      if ExitCode = 0 then
      begin
        Application.MessageBox('Neustart abgeschlossen. Sie können das Programm jetzt schließen.' + #13#10 +
          'Bitte geben Sie den Paperless Komponenten Zeit zum starten.',
          'Info', MB_OK or MB_ICONINFORMATION or MB_TOPMOST);
      end
      else
      begin
        // Show a failure message when the process returns an error.
        ShowMessage('Der Vorgang ist fehlgeschlagen. Fehlercode: ' + IntToStr(ExitCode));
      end;
    end
    else
    begin
      ShowMessage('Fehler beim Starten des Prozesses.');
    end;
    ActiveControl := nil; // Remove focus from the current control.
  end;

  if PaperlessUpdate = true then
  begin
    // Start the process.
    if CreateProcess(nil, PChar(Cmd), nil, nil, False, CREATE_NEW_CONSOLE, nil, nil, StartupInfo, ProcessInfo) then
    begin
      Sleep(1000);
      // Bring the CMD window to the front.
      ConsoleToFront(ProcessInfo.dwProcessId);
      // Wait for the process to finish.
      WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
      // Check the exit code.
      GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);
      CloseHandle(ProcessInfo.hProcess);
      CloseHandle(ProcessInfo.hThread);

      // Exit code 0 means success.
      if ExitCode = 0 then
      begin
        Application.MessageBox('Neustart und Updatesuche abgeschlossen. Sie können das Programm jetzt schließen.' + #13#10 +
          'Bitte geben Sie den Paperless Komponenten Zeit zum starten.' + #13#10 +
          'Lagen Updates vor, wurden diese installiert.',
          'Info', MB_OK or MB_ICONINFORMATION or MB_TOPMOST);
      end
      else
      begin
        // Show a failure message when the process returns an error.
        ShowMessage('Der Vorgang ist fehlgeschlagen. Fehlercode: ' + IntToStr(ExitCode));
      end;
    end
    else
    begin
      ShowMessage('Fehler beim Starten des Prozesses.');
    end;
    ActiveControl := nil; // Remove focus from the current control.
  end;
end;

// Create paperless-neustart.cmd to stop and start Paperless again.
procedure TMainformFrm.CreateRestartScript(const ComposePath: string);
begin
  // Stop when no compose path was provided.
  if ComposePath.Trim = '' then
  begin
    ShowMessage('Fehler: Es wurde kein gültiger Compose-Pfad gewählt.');
    Exit;
  end;
  ComposeName := StringReplace(ExtractFileName(ExcludeTrailingPathDelimiter(ComposePath)), ' ', '-', [rfReplaceAll]);
  CmdTargetPath := IncludeTrailingPathDelimiter(ComposePath) + 'paperless-neustart.cmd';
  CreateRestartCmdScript(CmdTargetPath, ComposePath);
  ScriptSavedLbl.Caption := 'Backup-Skript wurde erstellt: ' + CmdTargetPath;
  StartAndMonitorRestart;
end;

// Bring the console window of a started process to the front.
procedure TMainformFrm.ConsoleToFront(PID: DWORD);
var
  hConsoleWnd: HWND;
begin
  // Bring the CMD window to the front.
  AttachConsole(PID);
  hConsoleWnd := GetConsoleWindow;
  if hConsoleWnd <> 0 then
    begin
      ShowWindow(hConsoleWnd, SW_SHOWNORMAL);
      SetForegroundWindow(hConsoleWnd);
    end;
  FreeConsole;
end;

// Show the settings page where image versions and update settings are edited.
procedure TMainformFrm.PaperlessUpdateBtnClick(Sender: TObject);
begin
  TabControl1.TabIndex := 4;
  BackupRestorePan.Visible := False;
  BackupPlanPan.Visible := False;
  RetentionPan.Visible := False;
  EMailSettingsPan.Visible := False;
  SettingsPan.Visible := True;
  HelpPan.Visible := False;
  SettingsSavedLbl.Visible:=False;
end;
// Enable scheduling only after compose file and backup target are known.
procedure TMainformFrm.CheckScheduleAllowed;
var
  Ini: TIniFile;
  ComposePathFromIni, BackupTargetFromIni: string;
begin
  // Read required paths from the INI file.
  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + 'Einstellungen.ini');
  try
    ComposePathFromIni := Ini.ReadString('Pfade', 'DockerComposePfad', '').Trim;
    BackupTargetFromIni := Ini.ReadString('Pfade', 'BackupZiel', '').Trim;
  finally
    Ini.Free;
  end;

  // Scheduling is allowed only when compose file and backup target exist.
  if FileExists(ComposePathFromIni) and DirectoryExists(BackupTargetFromIni) then
  begin
    // Enable scheduling controls.
    BackupPlanPan.Enabled := True;
    RetentionPan.Enabled := True;
    CreateBackupPlanBtn.Enabled := True;
    SaveRetentionBtn.Enabled := True;
    DeleteBackupPlanBtn.Enabled := True;
    Label13.Caption := 'Beachten Sie, dass bei einem Plan die Paperless-Container gestoppt werden.';
    Label20.Caption := 'Beachten Sie die Laufwerksgröße.';
  end
  else
  begin
    // Disable scheduling controls.
    BackupPlanPan.Enabled := False;
    RetentionPan.Enabled := False;
    CreateBackupPlanBtn.Enabled := False;
    SaveRetentionBtn.Enabled := False;
    DeleteBackupPlanBtn.Enabled := False;
    Label13.Caption := 'Vor der Planung muss ein Backup erstellt werden.';
    Label20.Caption := 'Vor der Einrichtung muss ein Backup erstellt werden.';
  end;
end;


// Detect container and volume names and write them to a small helper text file.
procedure TMainformFrm.WriteComposeContainerAndVolumeInfo(const ComposePath: string);
var
  SL, ContainerLines, VolumeLines: TStringList;
  ComposeYmlPath, CmdOutput, InfoPath, Line: string;
  i: Integer;
begin
  ComposeYmlPath := IncludeTrailingPathDelimiter(AppDataFolder) + 'docker-compose.yml';
  InfoPath := IncludeTrailingPathDelimiter(AppDataFolder) + 'ContainerUndVolumesInfo.txt';

  if not FileExists(ComposeYmlPath) then
  begin
    ShowMessage('Fehler: docker-compose.yml wurde im gewählten Ordner nicht gefunden.');
    Exit;
  end;

  SL := TStringList.Create;
  ContainerLines := TStringList.Create;
  VolumeLines := TStringList.Create;
  try
    SL.Add('Container aus der ComputerRalle Paperless docker-compose.yml');
    SL.Add('Programm: ' + ExtractFileName(Application.ExeName) + ' – Version: ' + GetFileVersion(Application.ExeName));
    SL.Add('');

    CmdOutput := ExecuteShellCommand('docker', 'compose -f "' + ComposeYmlPath + '" ps --format "{{.Name}}"');
    ContainerLines.Text := Trim(CmdOutput);
    SL.AddStrings(ContainerLines);

    SL.Add('');
    SL.Add('Volumes aus der ComputerRalle Paperless docker-compose.yml');

    CmdOutput := ExecuteShellCommand('docker', 'volume ls --format "{{.Name}}"');
    VolumeLines.Text := Trim(CmdOutput);

     for i := 0 to VolumeLines.Count - 1 do
    begin
      Line := Trim(VolumeLines[i]);
      if Line.StartsWith('paperless-ngx_') then
      SL.Add(Line);
    end;

    SL.SaveToFile(InfoPath, TEncoding.UTF8);
  finally
    SL.Free;
    ContainerLines.Free;
    VolumeLines.Free;
  end;
end;

// Run a shell command hidden and return its text output.
function TMainformFrm.ExecuteShellCommand(const Command, Params: string): string;
var
  SA: TSecurityAttributes;
  SI: TStartupInfo;
  PI: TProcessInformation;
  StdOutRead, StdOutWrite: THandle;
  Buffer: array[0..4095] of AnsiChar;
  BytesRead: DWORD;
  Output: AnsiString;
begin
  ZeroMemory(@SA, SizeOf(SA));
  SA.nLength := SizeOf(SA);
  SA.bInheritHandle := True;

  if not CreatePipe(StdOutRead, StdOutWrite, @SA, 0) then
    Exit('');

  ZeroMemory(@SI, SizeOf(SI));
  SI.cb := SizeOf(SI);
  SI.dwFlags := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;
  SI.hStdOutput := StdOutWrite;
  SI.hStdError := StdOutWrite;
  SI.wShowWindow := SW_HIDE;

  if not CreateProcess(nil, PChar(Command + ' ' + Params), nil, nil, True,
    CREATE_NO_WINDOW, nil, nil, SI, PI) then
  begin
    CloseHandle(StdOutWrite);
    CloseHandle(StdOutRead);
    Exit('');
  end;

  CloseHandle(StdOutWrite);

  Output := '';
  repeat
    BytesRead := 0;
    ReadFile(StdOutRead, Buffer, SizeOf(Buffer), BytesRead, nil);
    if BytesRead > 0 then
      Output := Output + Copy(Buffer, 1, BytesRead);
  until BytesRead = 0;

  CloseHandle(StdOutRead);
  CloseHandle(PI.hProcess);
  CloseHandle(PI.hThread);

  Result := string(Output);
end;

// Read the file version from a Windows executable or DLL.
function TMainformFrm.GetFileVersion(const FilePath: string): string;
var
  InfoSize, Handle: DWORD;
  InfoData: Pointer;
  VerValue: Pointer;
  VerLen: UINT;
  Version: TVSFixedFileInfo;
begin
  Result := '';
  InfoSize := GetFileVersionInfoSize(PChar(FilePath), Handle);
  if InfoSize = 0 then Exit;

  GetMem(InfoData, InfoSize);
  try
    if GetFileVersionInfo(PChar(FilePath), 0, InfoSize, InfoData) then
    begin
      if VerQueryValue(InfoData, '\', VerValue, VerLen) then
      begin
        Version := TVSFixedFileInfo(VerValue^);
        Result := Format('%d.%d.%d.%d',
          [HiWord(Version.dwFileVersionMS), LoWord(Version.dwFileVersionMS),
           HiWord(Version.dwFileVersionLS), LoWord(Version.dwFileVersionLS)]);
      end;
    end;
  finally
    FreeMem(InfoData);
  end;
end;

// Read container and volume names from ContainerUndVolumesInfo.txt.
procedure TMainformFrm.ReadContainerNamesFromFile;
var
  FilePath: string;
  SL: TStringList;
  i: Integer;
  Line: string;
  InVolumeSection: Boolean;
begin
  FilePath := IncludeTrailingPathDelimiter(AppDataFolder) + 'ContainerUndVolumesInfo.txt';

  if not FileExists(FilePath) then
    Exit;

  SL := TStringList.Create;
  try
    SL.LoadFromFile(FilePath);
    InVolumeSection := False;

    for i := 0 to SL.Count - 1 do
    begin
      Line := Trim(SL[i]);

      if Line = '' then Continue;

      if Line.StartsWith('Volumes aus') then
      begin
        InVolumeSection := True;
        Continue;
      end;

      if not InVolumeSection then
      begin
        if Line.StartsWith('Container aus') then Continue;
        if Line.StartsWith('Programm:') then Continue;

        if Line.Contains('-db-') then
          PaperlessDBName := Line
        else if Line.Contains('-paperless-') then
          PaperlessCTName := Line
        else if Line.Contains('-broker-') then
          PaperlessBrokerName := Line
        else if Line.Contains('-tika-') then
          PaperlessTikaName := Line
        else if Line.Contains('-gotenberg-') then
          PaperlessGotenbergName := Line;
      end
      else
      begin
        if Line.Contains('_db_data') then
          Volume_db_data := Line
        else if Line.Contains('_data') then
          Volume_data := Line
        else if Line.Contains('_export') then
          Volume_export := Line
        else if Line.Contains('_media') then
          Volume_media := Line;
      end;
    end;
  finally
    SL.Free;
  end;
  TFile.WriteAllText(IncludeTrailingPathDelimiter(AppDataFolder) + 'BackupPfadeLog.txt', 'Beim Backup verwendete Variablen:' + sLineBreak + 'PaperlessDBName=' + PaperlessDBName + sLineBreak + 'PaperlessCTName=' + PaperlessCTName + sLineBreak + 'PaperlessBrokerName=' + PaperlessBrokerName + sLineBreak + 'PaperlessTikaName=' + PaperlessTikaName + sLineBreak + 'PaperlessGotenbergName=' + PaperlessGotenbergName + sLineBreak + 'Volume_data=' + Volume_data + sLineBreak + 'Volume_db_data=' + Volume_db_data + sLineBreak + 'Volume_export=' + Volume_export + sLineBreak + 'Volume_media=' + Volume_media, TEncoding.UTF8);
end;

// --------------------------------------------------------------
// Help links
// --------------------------------------------------------------
procedure TMainformFrm.ImprintLblClick(Sender: TObject);
begin
  ShellExecute(0, 'open', 'https://ralf-peter-kleinert.de/impressum.html', nil, nil, SW_SHOWNORMAL);
end;

procedure TMainformFrm.PaperlessPlaylistLblClick(Sender: TObject);
begin
  ShellExecute(0, 'open', 'https://www.youtube.com/playlist?list=PL0CRlqUkwGBm4wl1wYWen3L6jHIXhq3T7', nil, nil, SW_SHOWNORMAL);
end;

procedure TMainformFrm.MyYouTubeChannelLblClick(Sender: TObject);
begin
 ShellExecute(0, 'open', 'https://www.youtube.com/@ralf-peter-kleinert', nil, nil, SW_SHOWNORMAL);
end;

procedure TMainformFrm.BackupProgramGuideLblClick(Sender: TObject);
begin
 ShellExecute(0, 'open', 'https://ralf-peter-kleinert.de/linux-os/paperless-backup-programm.html', nil, nil, SW_SHOWNORMAL);
end;

procedure TMainformFrm.Web1LblClick(Sender: TObject);
begin
 ShellExecute(0, 'open', 'https://ralf-peter-kleinert.de', nil, nil, SW_SHOWNORMAL);
end;
procedure TMainformFrm.Web2LblClick(Sender: TObject);
begin
 ShellExecute(0, 'open', 'https://blog.ralf-peter-kleinert.de', nil, nil, SW_SHOWNORMAL);
end;

procedure TMainformFrm.NewsletterLblClick(Sender: TObject);
begin
  ShellExecute(0, 'open', 'https://dashboard.mailerlite.com/forms/1051644/128840345310988026/share', nil, nil, SW_SHOWNORMAL);
end;

procedure TMainformFrm.ProgramUpdateLblClick(Sender: TObject);
begin
  ShellExecute(0, 'open', 'https://downloads.ralf-peter-kleinert.de/software/paperless-backup-programm.html', nil, nil, SW_SHOWNORMAL);
end;

// Return the version of the running executable as a string.
function TMainformFrm.GetExeVersion: string;
var
  Size, Handle: DWORD;
  Buffer: Pointer;
  FileInfo: PVSFixedFileInfo;
begin
  Result := '';
  Size := GetFileVersionInfoSize(PChar(ParamStr(0)), Handle);
  if Size > 0 then
  begin
    GetMem(Buffer, Size);
    try
      if GetFileVersionInfo(PChar(ParamStr(0)), Handle, Size, Buffer) and
         VerQueryValue(Buffer, '\', Pointer(FileInfo), Size) then
        Result :=
          IntToStr(FileInfo.dwFileVersionMS shr 16) + '.' +
          IntToStr(FileInfo.dwFileVersionMS and $FFFF) + '.' +
          IntToStr(FileInfo.dwFileVersionLS shr 16) + '.' +
          IntToStr(FileInfo.dwFileVersionLS and $FFFF);
    finally
      FreeMem(Buffer);
    end;
  end;
end;

// Convert dotted version (x.x.x.x) into a fixed-width sortable string.
function TMainformFrm.VersionToInt(const V: string): string;
var
  P: TArray<string>;
begin
  P := V.Split(['.']);
  Result :=
    IntToStr(StrToIntDef(P[0], 0)) +
    Format('%.3d', [StrToIntDef(P[1], 0)]) +
    Format('%.3d', [StrToIntDef(P[2], 0)]) +
    Format('%.3d', [StrToIntDef(P[3], 0)]);
end;
end.
