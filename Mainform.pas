// --------------------------------------------------------------
// Original author: Ralf-Peter Kleinert - 2025
// Ursprünglicher Autor: Ralf-Peter Kleinert - 2025
// Alias: #ComputerRalle / DIGITAL-easy
// Künstlername: #ComputerRalle / DIGITAL-easy
// Project: Paperless Backup Program / Paperless Backup Programm
// Projekt: Paperless Backup Program / Paperless Backup Programm
// Website: https://ralf-peter-kleinert.de
// Webseite: https://ralf-peter-kleinert.de
// YouTube: https://www.youtube.com/@ralf-peter-kleinert
// YouTube-Kanal: https://www.youtube.com/@ralf-peter-kleinert
// Copyright (C) 2026 Ralf-Peter Kleinert / ComputerRalle
// Urheberrecht (C) 2026 Ralf-Peter Kleinert / ComputerRalle
// GNU General Public License v3 - see LICENSE.txt in the repository
// GNU General Public License v3 - siehe LICENSE.txt im Repository
// --------------------------------------------------------------

unit Mainform;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, ShellAPI, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  System.IOUtils, Vcl.Samples.Spin, System.IniFiles, DateUtils, SetupForm, System.Generics.Collections, System.Generics.Defaults, Vcl.Menus,
  System.Net.URLClient, System.Net.HttpClient, System.Net.HttpClientComponent, ScriptGenerator, AppConfig, AppLogger, AppDialogs, Crypto;

type
  TMainformFrm = class(TForm)
    StatusBar1: TStatusBar;
    Panel2: TPanel;
    BackupRestorePan: TPanel;
    Panel3: TPanel;
    StartPaperlessBackupBtn: TButton;
    RestorePaperlessBackupBtn: TButton;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel1: TPanel;
    BuyMeACoffeBtn: TButton;
    StaticText4: TStaticText;
    Panel7: TPanel;
    Label1: TLabel;
    Image1: TImage;
    BackupWiederherProgNeuStartLbl: TLabel;
    Label3: TLabel;
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
    ProgressBar1: TProgressBar;
    BusyWaitLbl: TLabel;
    Button1: TButton;
    Label32: TLabel;
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
    procedure OpenPaperlessBrowserLblClick(Sender: TObject);
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
    function PowerShellQuote(const Value: string): string;
    function PrepareScriptOutputLog: string;
    function BuildPowerShellCommand(const ScriptPath, OutputLogPath: string): string;
    function ReadLastScriptOutputLine(const OutputLogPath, FallbackText: string): string;
    function ShortenScriptStatusText(const StatusText: string): string;
    function BuildBusyWaitText(const StatusText: string): string;
    procedure PrepareScriptProgress(const StatusText: string);
    procedure UpdateScriptProgress(const StatusText: string);
    procedure FinishScriptProgress(const StatusText: string; const Success: Boolean);
    procedure WaitForScriptWithProgress(const ProcessHandle: THandle; const StatusText, OutputLogPath: string);
    procedure CreateDockerComposeWithSetupForm;
    procedure WriteImageVersionWithSetupForm(const TargetPath: string);
    procedure BeginScriptBusyState;
    procedure EndScriptBusyState;
    procedure SaveAndDisableInteractiveControls(const ParentControl: TWinControl);
    procedure HideWelcomeLabel;
    procedure EncryptEmailEnvForBackup(const TargetBackupPath: string);
    procedure RestoreEmailEnvFromBackup(const SourceBackupPath, TargetComposePath: string);
  public
  end;

var
  MainformFrm: TMainformFrm;
  // Main paths used by backup, restore, and generated PowerShell scripts.
  // Hauptpfade für Backup, Wiederherstellung und generierte PowerShell-Skripte.
  BackupPath, ComposePath, ComposeName, CmdTargetPath, LastBackupFolder: String;
  AppDataFolder, BackupTargetFilePath, DefaultFolder, PaperlessInput, NoticeFilePath : String;
  // Runtime mode flags. They decide which script is created and what happens after it finishes.
  // Laufzeitmodus-Flags. Sie entscheiden, welches Skript erstellt wird und was nach dessen Ende passiert.
  IsBackup: Boolean;
  IsPaperlessInstallation, ShouldOpenPaperless: Boolean;
  IsApplyingEmailSettings: Boolean;
  InternalName, FileVersion: string;
  // Docker container and volume names detected from the current compose project.
  // Docker-Container- und Volume-Namen, die aus dem aktuellen Compose-Projekt erkannt wurden.
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
  ScriptBusy: Boolean;
  ScriptBusyTabIndex: Integer;
  ScriptBusyControlStates: TDictionary<TControl, Boolean>;


implementation
{$R *.dfm}
// Read PAPERLESS_SECRET_KEY from a backup metadata file.
// PAPERLESS_SECRET_KEY aus einer Backup-Metadatendatei lesen.
function ReadPaperlessSecretKeyFromBackupFile(const SecretKeyFilePath: string): string;
var
  Lines: TStringList;
  I, SeparatorPos: Integer;
  Line: string;
begin
  Result := '';
  if not FileExists(SecretKeyFilePath) then Exit;
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(SecretKeyFilePath, TEncoding.UTF8);
    for I := 0 to Lines.Count - 1 do
    begin
      Line := Trim(Lines[I]);
      if Line.StartsWith('PAPERLESS_SECRET_KEY=') then
      begin
        SeparatorPos := Pos('=', Line);
        Result := Trim(Copy(Line, SeparatorPos + 1, MaxInt));
        Result := StringReplace(Result, '"', '', [rfReplaceAll]);
        Exit;
      end;
    end;
  finally
    Lines.Free;
  end;
end;
// Return true when email-versand.env already contains user mail settings.
// True zurueckgeben, wenn email-versand.env bereits Maildaten des Benutzers enthaelt.
function EmailEnvHasConfiguredValues(const EnvList: TStrings): Boolean;
begin
  Result :=
    (Trim(EnvList.Values['PAPERLESS_EMAIL_HOST']) <> '') or
    (Trim(EnvList.Values['PAPERLESS_EMAIL_PORT']) <> '') or
    (Trim(EnvList.Values['PAPERLESS_EMAIL_HOST_USER']) <> '') or
    (Trim(EnvList.Values['PAPERLESS_EMAIL_HOST_PASSWORD']) <> '') or
    (Trim(EnvList.Values['PAPERLESS_EMAIL_FROM']) <> '') or
    (Trim(EnvList.Values['PAPERLESS_EMAIL_USE_TLS']) <> '') or
    (Trim(EnvList.Values['PAPERLESS_EMAIL_USE_SSL']) <> '');
end;
// Return true when the existing email env file must be preserved.
// True zurueckgeben, wenn die vorhandene E-Mail-Env-Datei erhalten bleiben muss.
function ExistingEmailEnvIsConfigured(const EnvFilePath: string): Boolean;
var
  EnvList: TStringList;
begin
  Result := False;
  if not FileExists(EnvFilePath) then Exit;
  EnvList := TStringList.Create;
  try
    EnvList.LoadFromFile(EnvFilePath);
    Result := EmailEnvHasConfiguredValues(EnvList);
  finally
    EnvList.Free;
  end;
end;
// Apply the restore key from the backup file or use the legacy key for older backups.
// Den Wiederherstellungs-Key aus der Backup-Datei anwenden oder bei alten Backups den Legacy-Key nutzen.
function ApplyPaperlessSecretKeyForRestore(const BackupFolder: string): Boolean;
var
  Ini: TIniFile;
  SecretKey, SecretKeyFilePath, SettingsIniPath: string;
begin
  Result := True;
  SecretKeyFilePath := IncludeTrailingPathDelimiter(BackupFolder) + PaperlessSecretKeyFileName;
  if not FileExists(SecretKeyFilePath) then
  begin
    SecretKey := LegacyPaperlessSecretKey;
    LogWarning('No Paperless secret key backup file found. Legacy key will be used for restore.');
  end
  else
  begin
    SecretKey := ReadPaperlessSecretKeyFromBackupFile(SecretKeyFilePath);
    if SecretKey = '' then
    begin
      Result := False;
      LogWarning('Paperless secret key backup file exists but contains no readable key.');
      Exit;
    end;
  end;
  SettingsIniPath := IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName;
  Ini := TIniFile.Create(SettingsIniPath);
  try
    if SecretKey = LegacyPaperlessSecretKey then
    begin
      Ini.WriteString(IniSectionSecurity, IniKeyLegacyPaperlessSecretKey, SecretKey);
      Ini.DeleteKey(IniSectionSecurity, IniKeyPaperlessSecretKey);
    end
    else
    begin
      Ini.WriteString(IniSectionSecurity, IniKeyPaperlessSecretKey, SecretKey);
      Ini.DeleteKey(IniSectionSecurity, IniKeyLegacyPaperlessSecretKey);
    end;
    Ini.UpdateFile;
  finally
    Ini.Free;
  end;
  LogInfo('Paperless secret key prepared for restore.');
end;
// Load update.ini from the web server and show whether a program update is available.
// update.ini vom Webserver laden und anzeigen, ob ein Programmupdate verfügbar ist.
procedure TMainformFrm.LoadUpdateIniFile();
var
  Ss: TStringStream;
  Sl: TStringList;
  ProgramVersion: String;
  VersionInIni: String;
  test1, test2 : String;
begin
  ProgramVersion := GetExeVersion;
  LogInfo('Checking program update. Current version: ' + ProgramVersion);
  if not FileExists(IncludeTrailingPathDelimiter(AppDataFolder) + UpdateIniFileName) then
  VersionInIni := ProgramVersion;

  try
    Ss := TStringStream.Create;
    try
      NetHTTPClient1.Get(UpdateInfoUrl, Ss);
      Ss.SaveToFile(IncludeTrailingPathDelimiter(AppDataFolder) + UpdateIniFileName);
    finally
      Ss.Free;
    end;
  except
    VersionInIni := ProgramVersion; // No update check result when the server is unavailable.
    // Kein Ergebnis der Update-Prüfung, wenn der Server nicht erreichbar ist.
    LogWarning('Update check failed. Server update.ini could not be loaded.');
    Exit;
  end;

  if FileExists(IncludeTrailingPathDelimiter(AppDataFolder) + UpdateIniFileName) then
    begin
      Sl := TStringList.Create;
      try
        Sl.LoadFromFile(IncludeTrailingPathDelimiter(AppDataFolder) + UpdateIniFileName);
        VersionInIni := Trim(Sl[0]);
        LogInfo('Update version read from update.ini: ' + VersionInIni);
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
    LogInfo('Program update available.');
  end else
  begin
    ProgramUpdateLbl.ParentColor := False;
    ProgramUpdateLbl.Caption := 'Programm aktuell';
    ProgramUpdateLbl.StyleElements := StyleElements - [seFont];
    ProgramUpdateLbl.Font.Color := clYellow;
    LogInfo('Program is up to date.');
  end;
end;

// Store the default versions of all Docker components in the settings INI file.
// Die Standardversionen aller Docker-Komponenten in der Einstellungs-INI speichern.
procedure TMainformFrm.WriteStandardVersionAfterInstallation();
var
  Ini: TIniFile;
  SettingsIniPath: string;
begin
  SettingsIniPath := IncludeTrailingPathDelimiter(Mainform.AppDataFolder) + SettingsFileName;
  Ini := TIniFile.Create(SettingsIniPath);
  try
    Ini.WriteString(IniSectionVersions, IniKeyPaperlessVersion, DefaultPaperlessVersion);
    Ini.WriteString(IniSectionVersions, IniKeyPostgresVersion, DefaultPostgresVersion);
    Ini.WriteString(IniSectionVersions, IniKeyRedisVersion, DefaultRedisVersion);
    Ini.WriteString(IniSectionVersions, IniKeyGotenbergVersion, DefaultGotenbergVersion);
    Ini.WriteString(IniSectionVersions, IniKeyTikaVersion, DefaultTikaVersion);
    Ini.WriteString(IniSectionVersions, IniKeyAlpineVersion, DefaultAlpineVersion);
    Ini.WriteString(IniSectionVersions, IniKeyBusyboxVersion, DefaultBusyboxVersion);
    Ini.UpdateFile;
  finally
    Ini.Free;
  end;
end;

// Open the generated PowerShell script in a visible console window.
// Das generierte PowerShell-Skript in einem sichtbaren Konsolenfenster öffnen.
procedure TMainformFrm.StartCmdScript;
begin
  ShellExecute(0, 'open', 'powershell.exe',
    PChar('-NoProfile -ExecutionPolicy Bypass -File "' + CmdTargetPath + '"'),
    nil, SW_SHOWNORMAL);
end;
// Run setup-form compose generation even when the notice form is not open.
// Compose-Erzeugung ueber das Setup-Formular ausfuehren, auch wenn der Hinweisdialog nicht geoeffnet ist.
procedure TMainformFrm.CreateDockerComposeWithSetupForm;
var
  CreatedSetupForm: Boolean;
begin
  CreatedSetupForm := not Assigned(SetupFrm);
  if CreatedSetupForm then
    SetupFrm := TSetupFrm.Create(Self);
  try
    SetupFrm.CreateDockerComposeFile;
  finally
    if CreatedSetupForm then
    begin
      SetupFrm.Free;
      SetupFrm := nil;
    end;
  end;
end;
// Write image-version metadata even when the setup form is not currently open.
// Image-Versionen schreiben, auch wenn das Setup-Formular gerade nicht geoeffnet ist.
procedure TMainformFrm.WriteImageVersionWithSetupForm(const TargetPath: string);
var
  CreatedSetupForm: Boolean;
begin
  CreatedSetupForm := not Assigned(SetupFrm);
  if CreatedSetupForm then
    SetupFrm := TSetupFrm.Create(Self);
  try
    SetupFrm.WriteImageVersion(TargetPath);
  finally
    if CreatedSetupForm then
    begin
      SetupFrm.Free;
      SetupFrm := nil;
    end;
  end;
end;
// Store and disable interactive controls while a script is running.
// Interaktive Steuerelemente waehrend eines laufenden Skripts merken und sperren.
procedure TMainformFrm.SaveAndDisableInteractiveControls(const ParentControl: TWinControl);
var
  I: Integer;
  ChildControl: TControl;
  ChildWinControl: TWinControl;
  ShouldDisable: Boolean;
begin
  for I := 0 to ParentControl.ControlCount - 1 do
  begin
    ChildControl := ParentControl.Controls[I];
    ChildWinControl := nil;
    if ChildControl is TWinControl then
      ChildWinControl := TWinControl(ChildControl);
    ShouldDisable :=
      (ChildControl is TButton) or
      (ChildControl is TCheckBox) or
      (ChildControl is TEdit) or
      (ChildControl is TSpinEdit) or
      (ChildControl is TRadioGroup);
    if ShouldDisable and (ChildControl <> BuyMeACoffeBtn) then
    begin
      if not ScriptBusyControlStates.ContainsKey(ChildControl) then
        ScriptBusyControlStates.Add(ChildControl, ChildControl.Enabled);
      ChildControl.Enabled := False;
    end;
    if Assigned(ChildWinControl) then
      SaveAndDisableInteractiveControls(ChildWinControl);
  end;
end;
// Put the main form into a non-interactive script-running state.
// Hauptformular in einen nicht interaktiven Skriptmodus versetzen.
procedure TMainformFrm.BeginScriptBusyState;
begin
  if ScriptBusy then Exit;
  ScriptBusy := True;
  ScriptBusyTabIndex := TabControl1.TabIndex;
  if not Assigned(ScriptBusyControlStates) then
    ScriptBusyControlStates := TDictionary<TControl, Boolean>.Create
  else
    ScriptBusyControlStates.Clear;
  SaveAndDisableInteractiveControls(Self);
  BuyMeACoffeBtn.Enabled := True;
  BusyWaitLbl.Visible := True;
end;
// Restore the main form after a script has finished.
// Hauptformular nach einem Skriptlauf wiederherstellen.
procedure TMainformFrm.EndScriptBusyState;
var
  ControlState: TPair<TControl, Boolean>;
begin
  if not ScriptBusy then Exit;
  if Assigned(ScriptBusyControlStates) then
  begin
    for ControlState in ScriptBusyControlStates do
      if Assigned(ControlState.Key) then
        ControlState.Key.Enabled := ControlState.Value;
    ScriptBusyControlStates.Clear;
  end;
  BuyMeACoffeBtn.Enabled := True;
  BusyWaitLbl.Visible := False;
  ScriptBusy := False;
end;
// Quote a value for use inside a PowerShell command string.
// Einen Wert fuer die Verwendung in einer PowerShell-Befehlszeile quoten.
function TMainformFrm.PowerShellQuote(const Value: string): string;
begin
  Result := '''' + StringReplace(Value, '''', '''''', [rfReplaceAll]) + '''';
end;
// Prepare the temporary file that mirrors the visible PowerShell output.
// Die temporaere Datei vorbereiten, die die sichtbare PowerShell-Ausgabe spiegelt.
function TMainformFrm.PrepareScriptOutputLog: string;
begin
  Result := IncludeTrailingPathDelimiter(AppDataFolder) + 'PowerShellStatus.log';
  try
    TFile.WriteAllText(Result, '', TEncoding.Unicode);
  except
    on E: Exception do
      LogError('Could not prepare PowerShell status log: ' + E.Message);
  end;
end;
// Build a visible PowerShell command that also writes its output to a log file.
// Eine sichtbare PowerShell-Befehlszeile bauen, die ihre Ausgabe zusaetzlich in eine Logdatei schreibt.
function TMainformFrm.BuildPowerShellCommand(const ScriptPath, OutputLogPath: string): string;
begin
  Result :=
    'powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& powershell.exe -NoProfile -ExecutionPolicy Bypass -File ' +
    PowerShellQuote(ScriptPath) +
    ' 2>&1 | ForEach-Object { $_; Set-Content -LiteralPath ' +
    PowerShellQuote(OutputLogPath) +
    ' -Value ([string]$_) -Encoding Unicode }; exit $LASTEXITCODE"';
end;
// Read the last non-empty line from the mirrored PowerShell output.
// Die letzte nicht leere Zeile aus der gespiegelten PowerShell-Ausgabe lesen.
function TMainformFrm.ReadLastScriptOutputLine(const OutputLogPath, FallbackText: string): string;
var
  Stream: TFileStream;
  Lines: TStringList;
  I: Integer;
begin
  Result := FallbackText;
  if OutputLogPath.Trim = '' then Exit;
  if not FileExists(OutputLogPath) then Exit;
  Lines := TStringList.Create;
  try
    try
      Stream := TFileStream.Create(OutputLogPath, fmOpenRead or fmShareDenyNone);
      try
        Lines.LoadFromStream(Stream, TEncoding.Unicode);
      finally
        Stream.Free;
      end;
      for I := Lines.Count - 1 downto 0 do
      begin
        if Lines[I].Trim <> '' then
          Exit(Lines[I].Trim);
      end;
    except
      on E: Exception do
      begin
        // The status file can be touched by PowerShell at the same moment. Keep the last known status.
        // Die Statusdatei kann im gleichen Moment von PowerShell geschrieben werden. Den letzten bekannten Status behalten.
      end;
    end;
  finally
    Lines.Free;
  end;
end;
// Shorten long script status texts for the label.
// Lange Skriptstatus-Texte fuer das Label kuerzen.
function TMainformFrm.ShortenScriptStatusText(const StatusText: string): string;
const
  MaxStatusTextLength = 95;
begin
  Result := StatusText.Trim;
  if Length(Result) > MaxStatusTextLength then
    Result := Copy(Result, 1, MaxStatusTextLength - 3).TrimRight + '...';
end;
// Build the headline shown above the live script output.
// Die Ueberschrift oberhalb der laufenden Skriptausgabe erzeugen.
function TMainformFrm.BuildBusyWaitText(const StatusText: string): string;
begin
  if StatusText.Contains('Mail-Einstellungen') then
    Result := 'Mail-Einstellungen werden angewendet. Bitte warten ...'
  else if IsBackup then
    Result := 'Backup läuft. Bitte warten ...'
  else if IsUpdate or PaperlessUpdate or StatusText.Contains('Update') then
    Result := 'Update läuft. Bitte warten ...'
  else if StatusText.Contains('Neustart') then
    Result := 'Neustart läuft. Bitte warten ...'
  else
    Result := 'Wiederherstellung läuft. Bitte warten ...';
end;
// Prepare the in-application script status display.
// Die Statusanzeige fuer laufende Skripte in der Anwendung vorbereiten.
procedure TMainformFrm.PrepareScriptProgress(const StatusText: string);
begin
  if IsPaperlessInstallation and Assigned(SetupFrm) then
  begin
    SetupFrm.PaperlessInstallierenBtn.Enabled := False;
    SetupFrm.InstallLbl.Visible := True;
    SetupFrm.InstallLbl.AutoSize := False;
    SetupFrm.InstallLbl.Caption := ShortenScriptStatusText(StatusText);
    SetupFrm.ProgressBar2.Min := 0;
    SetupFrm.ProgressBar2.Max := 100;
    SetupFrm.ProgressBar2.Position := 0;
    SetupFrm.ProgressBar2.Visible := True;
    Application.ProcessMessages;
    Exit;
  end;
  BeginScriptBusyState;
  StartPaperlessBackupBtn.Enabled := False;
  RestorePaperlessBackupBtn.Enabled := False;
  BusyWaitLbl.Visible := True;
  BusyWaitLbl.Caption := BuildBusyWaitText(StatusText);
  BackupWiederherProgNeuStartLbl.Visible := True;
  BackupWiederherProgNeuStartLbl.Caption := ShortenScriptStatusText(StatusText);
  ProgressBar1.Min := 0;
  ProgressBar1.Max := 100;
  ProgressBar1.Position := 0;
  ProgressBar1.Visible := True;
  Application.ProcessMessages;
end;
// Update the status label and move the progress bar while a script is running.
// Das Statuslabel aktualisieren und die Fortschrittsanzeige waehrend eines Skripts bewegen.
procedure TMainformFrm.UpdateScriptProgress(const StatusText: string);
begin
  if IsPaperlessInstallation and Assigned(SetupFrm) then
  begin
    SetupFrm.InstallLbl.Visible := True;
    SetupFrm.InstallLbl.Caption := ShortenScriptStatusText(StatusText);
    if SetupFrm.ProgressBar2.Position >= SetupFrm.ProgressBar2.Max then
      SetupFrm.ProgressBar2.Position := SetupFrm.ProgressBar2.Min
    else
      SetupFrm.ProgressBar2.Position := SetupFrm.ProgressBar2.Position + 2;
    Application.ProcessMessages;
    Exit;
  end;
  BackupWiederherProgNeuStartLbl.Visible := True;
  BackupWiederherProgNeuStartLbl.Caption := ShortenScriptStatusText(StatusText);
  if ProgressBar1.Position >= ProgressBar1.Max then
    ProgressBar1.Position := ProgressBar1.Min
  else
    ProgressBar1.Position := ProgressBar1.Position + 2;
  Application.ProcessMessages;
end;
// Finish the in-application script status display.
// Die Statusanzeige fuer laufende Skripte abschliessen.
procedure TMainformFrm.FinishScriptProgress(const StatusText: string; const Success: Boolean);
begin
  if IsPaperlessInstallation and Assigned(SetupFrm) then
  begin
    SetupFrm.PaperlessInstallierenBtn.Enabled := True;
    SetupFrm.InstallLbl.Visible := True;
    SetupFrm.InstallLbl.Caption := ShortenScriptStatusText(StatusText);
    if Success then
      SetupFrm.ProgressBar2.Position := SetupFrm.ProgressBar2.Max
    else
      SetupFrm.ProgressBar2.Position := SetupFrm.ProgressBar2.Min;
    Application.ProcessMessages;
    Exit;
  end;
  EndScriptBusyState;
  StartPaperlessBackupBtn.Enabled := True;
  RestorePaperlessBackupBtn.Enabled := True;
  BackupWiederherProgNeuStartLbl.Visible := True;
  BackupWiederherProgNeuStartLbl.Caption := ShortenScriptStatusText(StatusText);
  if Success then
    ProgressBar1.Position := ProgressBar1.Max
  else
    ProgressBar1.Position := ProgressBar1.Min;
  Application.ProcessMessages;
end;
// Wait for a visible PowerShell process while keeping the form status alive.
// Auf einen sichtbaren PowerShell-Prozess warten und die Formularanzeige aktuell halten.
procedure TMainformFrm.WaitForScriptWithProgress(const ProcessHandle: THandle; const StatusText, OutputLogPath: string);
var
  LastStatusText: string;
  CurrentStatusText: string;
begin
  LastStatusText := StatusText;
  CurrentStatusText := StatusText;
  while WaitForSingleObject(ProcessHandle, 200) = WAIT_TIMEOUT do
  begin
    LastStatusText := ReadLastScriptOutputLine(OutputLogPath, LastStatusText);
    if LastStatusText <> CurrentStatusText then
    begin
      CurrentStatusText := LastStatusText;
      UpdateScriptProgress(CurrentStatusText);
    end
    else
      UpdateScriptProgress(CurrentStatusText);
  end;
end;
// Hide the intro headline after the user starts interacting with the program.
// Die Willkommensueberschrift nach der ersten Benutzeraktion ausblenden.
procedure TMainformFrm.HideWelcomeLabel;
begin
  if Assigned(Label32) then
    Label32.Visible := False;
end;
procedure TMainformFrm.EncryptEmailEnvForBackup(const TargetBackupPath: string);
var
  SourceEnvPath, TargetEncryptedPath, LocalEncryptedPath, Password: string;
begin
  SourceEnvPath := IncludeTrailingPathDelimiter(AppDataFolder) + EmailEnvFileName;
  if not FileExists(SourceEnvPath) then
    Exit;
  if not RequestPasswordDialog(
    'Mail-Einstellungen verschlüsseln',
    'Die Datei email-versand.env enthält Mailkontodaten und wird für das Backup verschlüsselt.' + sLineBreak + sLineBreak +
    'Bitte bewahren Sie Ihr Passwort sicher auf, z.B. in KeePass. Wenn Sie das Passwort verlieren, kann die Mail-Einstellungsdatei nicht wiederhergestellt werden.',
    True,
    Password) then
  begin
    CenteredShowMessage('Mail-Einstellungen werden nicht ins Backup aufgenommen.');
    Exit;
  end;
  TargetEncryptedPath := IncludeTrailingPathDelimiter(TargetBackupPath) + EmailEnvEncryptedFileName;
  LocalEncryptedPath := IncludeTrailingPathDelimiter(AppDataFolder) + EmailEnvEncryptedFileName;
  try
    EncryptFileWithPassword(SourceEnvPath, TargetEncryptedPath, Password);
    EncryptFileWithPassword(SourceEnvPath, LocalEncryptedPath, Password);
    LogInfo('Encrypted email env file written to backup.');
  except
    on E: Exception do
    CenteredShowMessage('Mail-Einstellungen konnten nicht verschlüsselt werden: ' + E.Message);
  end;
end;
procedure TMainformFrm.RestoreEmailEnvFromBackup(const SourceBackupPath, TargetComposePath: string);
var
  SourceEncryptedPath, TargetEnvPath, Password: string;
  PasswordResult: Integer;
begin
  SourceEncryptedPath := IncludeTrailingPathDelimiter(SourceBackupPath) + EmailEnvEncryptedFileName;
  if not FileExists(SourceEncryptedPath) then
  begin
    LogInfo('No encrypted email env file found in backup. Restore step skipped.');
    Exit;
  end;
  PasswordResult := RequestPasswordOrSkipDialog(
    'Mail-Einstellungen wiederherstellen',
    'Im Backup wurde eine verschlüsselte Mail-Einstellungsdatei gefunden.' + sLineBreak + sLineBreak +
    'Bitte geben Sie das Passwort ein. Wenn Sie das Passwort verlieren, kann die Mail-Einstellungsdatei nicht wiederhergestellt werden.',
    'Ohne Mail wiederherstellen',
    Password);
  if PasswordResult = mrIgnore then
  begin
    CenteredShowMessage('Wiederherstellung wird ohne Mail-Einstellungen fortgesetzt.');
    LogInfo('Encrypted email env restore skipped by user.');
    Exit;
  end;
  if PasswordResult <> mrOk then
  begin
    CenteredShowMessage('Mail-Einstellungen wurden nicht wiederhergestellt.');
    Exit;
  end;
  TargetEnvPath := IncludeTrailingPathDelimiter(ExtractFilePath(TargetComposePath)) + EmailEnvFileName;
  try
    DecryptFileWithPassword(SourceEncryptedPath, TargetEnvPath, Password);
    LogInfo('Encrypted email env file restored.');
  except
    on E: Exception do
    begin
      LogWarning('Encrypted email env restore failed: ' + E.Message);
      if CenteredMessageDlg(
        'Passwort falsch. Paperless ohne Maileinstellungen wiederherstellen?',
        mtConfirmation,
        [mbYes, mbNo],
        0) = mrYes then
      begin
        CenteredShowMessage('Wiederherstellung wird ohne Mail-Einstellungen fortgesetzt.');
        Exit;
      end;
      CenteredShowMessage('Mail-Einstellungen wurden nicht wiederhergestellt.');
    end;
  end;
end;
// Open the support page in the default browser.
// Die Unterstützungsseite im Standardbrowser öffnen.
procedure TMainformFrm.BuyMeACoffeeBtnClick(Sender: TObject);
begin
  HideWelcomeLabel;
  ShellExecute(0, 'open', BuyMeACoffeeUrl, nil, nil, SW_SHOWNORMAL);
end;

// Enable or disable manual Docker image version editing.
// Manuelle Bearbeitung der Docker-Image-Versionen aktivieren oder deaktivieren.
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
// Den Backup-Zielordner auswählen, speichern und die Backup-Skripte erstellen.
procedure TMainformFrm.StartPaperlessBackupBtnClick(Sender: TObject);
var
  FolderDialog: TFileOpenDialog;
  Ini:TIniFile;
  StoredPath: string;
  TextFilePath: string;
begin
  HideWelcomeLabel;
  if ComposePath.Trim = '' then
  begin
    CenteredShowMessage('Bitte zuerst den Paperless-Ordner auswählen.');
    Exit;
  end;
  WriteComposeContainerAndVolumeInfo(ComposePath);
  StartPaperlessBackupBtn.Enabled := False;
  RestorePaperlessBackupBtn.Enabled := False;
  ReadContainerNamesFromFile;
  IsPaperlessInstallation := False;

  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
  try
    Ini.WriteString('Pfade', 'DockerComposePfad', ExtractFilePath(ComposePath));
    Ini.UpdateFile; // Write immediately.
    // Sofort schreiben.
  finally
    Ini.Free;
  end;

  IsBackup := True;

  DefaultFolder := IncludeTrailingPathDelimiter(GetEnvironmentVariable('USERPROFILE')) + 'Desktop\Paperless-Backup';
  if not DirectoryExists(DefaultFolder) then ForceDirectories(DefaultFolder);

  // Migrate the old backup target text file into the INI file.
  // Die alte Textdatei mit dem Backup-Ziel in die INI-Datei migrieren.
  TextFilePath := IncludeTrailingPathDelimiter(AppDataFolder) + BackupTargetFileName;
  if FileExists(TextFilePath) then
  begin
    StoredPath := TFile.ReadAllText(TextFilePath, TEncoding.UTF8).Trim;
    Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
    try
      Ini.WriteString('Pfade', 'BackupZiel', StoredPath);
      Ini.UpdateFile; // Write immediately.
      // Sofort schreiben.
      // Read the value back from the INI file.
      // Den Wert wieder aus der INI-Datei lesen.
      StoredPath := Ini.ReadString('Pfade', 'BackupZiel', '').Trim;
    finally
      Ini.Free;
    end;
    // Delete the old text file after a successful migration.
    // Die alte Textdatei nach erfolgreicher Migration löschen.
    if StoredPath <> '' then DeleteFile(TextFilePath);
  end;

  // Read the last backup folder from the INI file.
  // Den letzten Backup-Ordner aus der INI-Datei lesen.
  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
  try
    LastBackupFolder := Ini.ReadString('Pfade', 'BackupZiel', '').Trim;
  finally
    Ini.Free;
  end;

  Sleep(500);

  if LastBackupFolder <> '' then
  begin
    if IsAutostart or
       (CenteredMessageDlg('Es wurde folgender voreingestellter Pfad gefunden:' + sLineBreak + LastBackupFolder + sLineBreak + sLineBreak +
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
        if FolderDialog.Execute(Handle) then
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
          CenteredShowMessage('Es wurde kein Ordner gewählt. Backupvorgang abgebrochen.');
          StartPaperlessBackupBtn.Enabled := True;
          RestorePaperlessBackupBtn.Enabled := True;
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
      if FolderDialog.Execute(Handle) then
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
        CenteredShowMessage('Es wurde kein Ordner gewählt. Der Standardordner wird verwendet: ' + sLineBreak + BackupPath);
      end;
    finally
      FolderDialog.Free;
    end;
  end;

  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
  try
    Ini.WriteString('Pfade', 'BackupZiel', ExtractFileDir(BackupPath));
    Ini.UpdateFile; // Write immediately.
    // Sofort schreiben.
  finally
    Ini.Free;
  end;

  CreateBackupScript(ExtractFilePath(ComposePath));
  CreateBackupPlanScript(ExtractFilePath(ComposePath));
  StartPaperlessBackupBtn.Enabled := True;
  RestorePaperlessBackupBtn.Enabled := True;
  // Delete the old marker file if it still exists.
  // Die alte Markerdatei löschen, falls sie noch existiert.
  TextFilePath := IncludeTrailingPathDelimiter(AppDataFolder) + ComposePathFileName;
  if FileExists(TextFilePath) then DeleteFile(TextFilePath);
end;
// Create paperless-backup.ps1 for a manual backup.
// paperless-backup.ps1 für ein manuelles Backup erstellen.
// The script dumps PostgreSQL first, then archives the Docker volumes.
// Das Skript erstellt zuerst einen PostgreSQL-Dump und archiviert danach die Docker-Volumes.
procedure TMainformFrm.CreateBackupScript(const ComposePath: string);
var
  Volumes: TDockerVolumeNames;
begin
  if ComposePath.Trim = '' then
  begin
    CenteredShowMessage('Fehler: Es wurde kein gültiger Compose-Pfad gewählt.');
    Exit;
  end;

  if not DirectoryExists(BackupPath) then ForceDirectories(BackupPath);
  EncryptEmailEnvForBackup(BackupPath);
  CmdTargetPath := IncludeTrailingPathDelimiter(ComposePath) + 'paperless-backup.ps1';
  Volumes.Data := Volume_data;
  Volumes.DbData := Volume_db_data;
  Volumes.ExportData := Volume_export;
  Volumes.Media := Volume_media;
  CreateManualBackupCmdScript(CmdTargetPath, ComposePath, BackupPath, AppDataFolder, PaperlessDBName, Volumes);
  StartAndMonitorCmdScript;
end;

// Close the application from the main form.
// Die Anwendung vom Hauptformular aus schließen.
procedure TMainformFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  LogInfo('Application closing.');
  FreeAndNil(ScriptBusyControlStates);
  Action := caNone;         // Stop default close handling.
  // Die Standard-Schließbehandlung stoppen.
  PostQuitMessage(0);       // End the message loop.
  // Die Nachrichtenschleife beenden.
  Application.Terminate;
end;

// Prepare global paths and default runtime state.
// Globale Pfade und Standard-Laufzeitzustand vorbereiten.
procedure TMainformFrm.FormCreate(Sender: TObject);
begin

  AppDataFolder := IncludeTrailingPathDelimiter(GetEnvironmentVariable('USERPROFILE')) + AppDataFolderName;
  // Create the user data folder if it does not exist.
  // Den Benutzerdatenordner erstellen, falls er nicht existiert.
  if not DirectoryExists(AppDataFolder) then ForceDirectories(AppDataFolder);
  InitLogger(AppDataFolder);
  LogInfo('Application started.');
  // Initialize runtime state.
  // Den Laufzeitzustand initialisieren.
  IsAutostart := False;
  ShouldWriteNewCompose := False;
  IsBackup := False;
  IsPaperlessInstallation := False;
  ShouldOpenPaperless := False;
  IsApplyingEmailSettings := False;
  IsUpdate := False;
  PaperlessUpdate := False;
  TrashRetentionDays := 365;
  ScriptBusy := False;
  ScriptBusyTabIndex := 0;
  ScriptBusyControlStates := nil;
  BusyWaitLbl.Visible := False;
  ProgressBar1.Visible := False;
  ProgressBar1.Position := 0;
end;

// Load saved settings, migrate old text files, and prepare the visible form state.
// Gespeicherte Einstellungen laden, alte Textdateien migrieren und den sichtbaren Formularzustand vorbereiten.
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

  AppDataFolder := IncludeTrailingPathDelimiter(GetEnvironmentVariable('USERPROFILE')) + AppDataFolderName;

  // Create the desktop consume folder if it does not exist.
  // Den Consume-Ordner auf dem Desktop erstellen, falls er nicht existiert.
  PaperlessInput := IncludeTrailingPathDelimiter(GetEnvironmentVariable('USERPROFILE')) + 'Desktop\Paperless-Input';
  if not DirectoryExists(PaperlessInput) then ForceDirectories(PaperlessInput);
  SaveEmptyEnvFile();

  // Check whether the user already accepted the notice.
  // Prüfen, ob der Benutzer den Hinweis bereits akzeptiert hat.
  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(Mainform.AppDataFolder) + SettingsFileName);
  try
    Value := Ini.ReadString('Einrichtung', 'Hinweis verstanden', '');
  finally
    Ini.Free;
  end;

  if Value = 'Ja' then
  begin
    NoticeFilePath := IncludeTrailingPathDelimiter(Mainform.AppDataFolder) + NoticeAcceptedFileName;
    // Delete the old notice file after the INI value exists.
    // Die alte Hinweisdatei löschen, nachdem der INI-Wert vorhanden ist.
    if FileExists(NoticeFilePath) then DeleteFile(NoticeFilePath);

    // Show the notice again after 30 days.
    // Den Hinweis nach 30 Tagen erneut anzeigen.
    if DaysBetween(Now, FileDateToDateTime(FileAge(IncludeTrailingPathDelimiter(Mainform.AppDataFolder) + SettingsFileName))) > 30 then
    begin
      SetupFrm := TSetupFrm.Create(Self);
      try
        SetupFrm.ShowModal;
      finally
        SetupFrm.Free;
        SetupFrm := nil;
      end;
      if Application.Terminated then Exit;
    end;
  end else
    begin
      SetupFrm := TSetupFrm.Create(Self);
      try
        SetupFrm.ShowModal;
      finally
        SetupFrm.Free;
        SetupFrm := nil;
      end;
      if Application.Terminated then Exit;
  end;



  TextFilePath := IncludeTrailingPathDelimiter(AppDataFolder) + ComposePathFileName;
  if FileExists(TextFilePath) then
  begin
    // Read the old path from the text file.
    // Den alten Pfad aus der Textdatei lesen.
    OldPath := TFile.ReadAllText(TextFilePath, TEncoding.UTF8).Trim;

    // Store it in the INI file.
    // Den Wert in der INI-Datei speichern.
    Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
    try
      Ini.WriteString('Pfade', 'DockerComposePfad', OldPath);
        Ini.UpdateFile; // Write immediately.
        // Sofort schreiben.
    finally
      Ini.Free;
    end;

  // Delete the migrated text file.
  // Die migrierte Textdatei löschen.
  DeleteFile(TextFilePath);
  end;

  IsBackup := True;

  DefaultFolder := IncludeTrailingPathDelimiter(GetEnvironmentVariable('USERPROFILE')) + 'Desktop\Paperless-Backup';
  if not DirectoryExists(DefaultFolder) then ForceDirectories(DefaultFolder);

  // Migrate the old backup target text file into the INI file.
  // Die alte Textdatei mit dem Backup-Ziel in die INI-Datei migrieren.
  TextFilePath := IncludeTrailingPathDelimiter(AppDataFolder) + BackupTargetFileName;
  if FileExists(TextFilePath) then
  begin
    StoredPath := TFile.ReadAllText(TextFilePath, TEncoding.UTF8).Trim;
    Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
    try
      Ini.WriteString('Pfade', 'BackupZiel', StoredPath);
      Ini.UpdateFile; // Write immediately.
      // Sofort schreiben.
      // Read the value back from the INI file.
      // Den Wert wieder aus der INI-Datei lesen.
      StoredPath := Ini.ReadString('Pfade', 'BackupZiel', '').Trim;
    finally
      Ini.Free;
    end;
    // Delete the old text file after a successful migration.
    // Die alte Textdatei nach erfolgreicher Migration löschen.
    if StoredPath <> '' then DeleteFile(TextFilePath);
  end;

  // Read the last backup folder from the INI file.
  // Den letzten Backup-Ordner aus der INI-Datei lesen.
  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
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
  StatusBar1.Panels.Add.Text := ' ' + AppStatusTitle + GetFileVersion(Application.ExeName);
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

  BackupTargetFilePath := IncludeTrailingPathDelimiter(AppDataFolder) + BackupTargetFileName;

  ComposePathTextFile := IncludeTrailingPathDelimiter(AppDataFolder) + ComposePathFileName;
  if FileExists(ComposePathTextFile) then
    begin
      // Read the old path from the text file.
      // Den alten Pfad aus der Textdatei lesen.
      OldPath := TFile.ReadAllText(ComposePathTextFile, TEncoding.UTF8);

      // Store it in the INI file.
      // Den Wert in der INI-Datei speichern.
      Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
      try
        Ini.WriteString('Pfade', 'DockerComposePfad', OldPath);
        Ini.UpdateFile; // Write immediately.
        // Sofort schreiben.
      finally
        Ini.Free;
      end;

      // Delete the migrated text file.
      // Die migrierte Textdatei löschen.
      DeleteFile(ComposePathTextFile);
  end;

  // Prepare the default compose path.
  // Den Standard-Compose-Pfad vorbereiten.
  NewComposePath := IncludeTrailingPathDelimiter(AppDataFolder);

  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
  try
    Value := Ini.ReadString('Einrichtung', 'Installation abgeschlossen', '');
  finally
    Ini.Free;
  end;

  // Migrate the old installation-completed text file into the INI file.
  // Die alte Textdatei für abgeschlossene Installation in die INI-Datei migrieren.
  InstallationCompletedFilePath := IncludeTrailingPathDelimiter(AppDataFolder) + InstallationCompletedFileName;
  if FileExists(InstallationCompletedFilePath) then
    begin
      Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
      try
        Ini.WriteString('Einrichtung', 'Installation abgeschlossen', 'Ja');
        Ini.UpdateFile;
      finally
        Ini.Free;
      end;

      // Delete the migrated text file.
      // Die migrierte Textdatei löschen.
      DeleteFile(InstallationCompletedFilePath);
    end;

  // Read the INI value again after possible migration.
  // Den INI-Wert nach einer möglichen Migration erneut lesen.
  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
  try
    Value := Ini.ReadString('Einrichtung', 'Installation abgeschlossen', '');
  finally
    Ini.Free;
  end;

  if Value <> 'Ja' then
  begin
    NewComposePath := IncludeTrailingPathDelimiter(AppDataFolder) + DockerComposeFileName;

    if not FileExists(NewComposePath) then
    begin
      CenteredMessageBox(
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
      try
        CreateDockerComposeWithSetupForm;
      finally
        ShouldWriteNewCompose := False;
      end;
      SetupFrm := TSetupFrm.Create(Self);
      try
        SetupFrm.InstallPaperlessBtnClick(Self);
      finally
        SetupFrm.Free;
        SetupFrm := nil;
      end;
      if not WantsInstall then
      begin
        CenteredShowMessage('Paperless-Installation wurde abgebrochen. Das Programm wird beendet.');
        Application.Terminate;
        Exit;
      end;
    end;
    ComposePath := NewComposePath;
  end else
    begin
      ComposePath := IncludeTrailingPathDelimiter(AppDataFolder) + DockerComposeFileName;
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

  // Load the backup path if it exists.
  // Den Backup-Pfad laden, falls er existiert.
  if FileExists(BackupTargetFilePath) then BackupPath := TFile.ReadAllText(BackupTargetFilePath).Trim;

  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
  try
    StoredPath := Ini.ReadString('Pfade', 'DockerComposePfad', '').Trim;
  finally
    Ini.Free;
  end;

  // Load the last valid compose path and backup target from the INI file.
  // Den letzten gültigen Compose-Pfad und das Backup-Ziel aus der INI-Datei laden.
  if StoredPath <> '' then
  begin
    ComposePath := StoredPath;
    ComposeName := ExtractFileName(ExcludeTrailingPathDelimiter(ComposePath));
    StartPaperlessBackupBtn.Enabled := True;
    RestorePaperlessBackupBtn.Enabled := True;
    BackupWiederherProgNeuStartLbl.Visible := False;
  end;

  StartParameter := ParamStr(1);

  if StartParameter = '/geplant' then
  begin
    RestorePaperlessBackupBtn.Visible:=False;
    StartPaperlessBackupBtn.Visible:=False;
    BackupWiederherProgNeuStartLbl.Visible:=False;
    TabControl1.Enabled:=False;
    IsAutostart := True;
    RunAutostartBackup();
  end else
    begin
    end;

   // Read trash retention from the INI file and show it in the edit field.
   // Papierkorb-Aufbewahrung aus der INI-Datei lesen und im Eingabefeld anzeigen.
   Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
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


  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
  // Read image versions from the INI file and apply defaults when empty.
  // Image-Versionen aus der INI-Datei lesen und bei leeren Werten Standardwerte verwenden.
  try
    redis_version_edit.Text := Ini.ReadString(IniSectionVersions, IniKeyRedisVersion, '');
    if redis_version_edit.Text = '' then
    redis_version_edit.Text := DefaultRedisVersion;

    paperless_version_edit.Text := Ini.ReadString(IniSectionVersions, IniKeyPaperlessVersion, '');
    if paperless_version_edit.Text = '' then
    paperless_version_edit.Text := DefaultPaperlessVersion;

    postgres_version_edit.Text := Ini.ReadString(IniSectionVersions, IniKeyPostgresVersion, '');
    if postgres_version_edit.Text = '' then
    postgres_version_edit.Text := DefaultPostgresVersion;

    gotenberg_version_edit.Text := Ini.ReadString(IniSectionVersions, IniKeyGotenbergVersion, '');
    if gotenberg_version_edit.Text = '' then
    gotenberg_version_edit.Text := DefaultGotenbergVersion;

    tika_version_edit.Text := Ini.ReadString(IniSectionVersions, IniKeyTikaVersion, '');
    if tika_version_edit.Text = '' then
    tika_version_edit.Text := DefaultTikaVersion;

    alpine_version_edit.Text := Ini.ReadString(IniSectionVersions, IniKeyAlpineVersion, '');
    if alpine_version_edit.Text = '' then
    alpine_version_edit.Text := DefaultAlpineVersion;

    busybox_version_edit.Text := Ini.ReadString(IniSectionVersions, IniKeyBusyboxVersion, '');
    if busybox_version_edit.Text = '' then
    busybox_version_edit.Text := DefaultBusyboxVersion;

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
// Ein Backup starten, wenn das Programm von der Windows-Aufgabenplanung gestartet wurde.
procedure TMainformFrm.RunAutostartBackup();
begin
  // Kept as a small wrapper for scheduled starts.
  // Als kleiner Wrapper für geplante Starts beibehalten.
  StartPaperlessBackupBtn.Click;
end;

// Recreate and run the manual backup script for the current compose path.
// Das manuelle Backup-Skript für den aktuellen Compose-Pfad neu erstellen und ausführen.
procedure TMainformFrm.StartPaperlessBackupScriptBtnClick(Sender: TObject);
begin
  CreateBackupScript(ExtractFilePath(ComposePath));
end;

// Switch between the main panels and refresh panel-specific settings.
// Zwischen den Hauptbereichen wechseln und bereichsspezifische Einstellungen aktualisieren.
procedure TMainformFrm.TabControl1Change(Sender: TObject);
var
  Ini: TIniFile;
begin
  HideWelcomeLabel;
  if ScriptBusy then
  begin
    TabControl1.TabIndex := ScriptBusyTabIndex;
    Exit;
  end;
  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
    try
      Ini.WriteString('Pfade', 'DockerComposePfad', IncludeTrailingPathDelimiter(ExtractFilePath(ComposePath)) + DockerComposeFileName);
      Ini.UpdateFile; // Write immediately.
      // Sofort schreiben.
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

   CheckScheduleAllowed;
end;

// --------------------------------------------------------------
// Schedule
// Zeitplan
// --------------------------------------------------------------
// Validate the trash-retention input while the user types.
// Die Eingabe zur Papierkorb-Aufbewahrung während der Eingabe prüfen.
procedure TMainformFrm.TrashRetentionEditChange(Sender: TObject);
var
  i: Integer;
  s: string;
  istGanzzahl: Boolean;
begin
  s := PapierkorbAufbewahrungEdit.Text;
  istGanzzahl := True;

  // Allow only whole numbers.
  // Nur ganze Zahlen erlauben.
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
// Speichern, wie viele geplante Backup-Ordner behalten werden sollen.
procedure TMainformFrm.SaveRetentionBtnClick(Sender: TObject);
var
  Ini: TIniFile;
begin
  HideWelcomeLabel;
  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
  try
    // Save the retention setting.
    // Die Aufbewahrungseinstellung speichern.
    Ini.WriteInteger('Zeitplan', 'BackupsBehalten', KeepBackupsSpE.Value);
    // Write immediately.
    // Sofort schreiben.
    Ini.UpdateFile;
  finally
    Ini.Free;
  end;
  // Show the label only when all backups are kept.
  // Die Beschriftung nur anzeigen, wenn alle Backups behalten werden.
  if KeepBackupsSpE.Value = 0 then
  AllBackupsAreRetainedLbl.Visible := True else
  AllBackupsAreRetainedLbl.Visible := False;
end;

// Enable or disable all controls that belong to automatic backups.
// Alle Steuerelemente für automatische Backups aktivieren oder deaktivieren.
procedure TMainformFrm.AutoBackupCBClick(Sender: TObject);
begin
  // Enable or disable schedule controls.
  // Zeitplan-Steuerelemente aktivieren oder deaktivieren.
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
// Ausgewählte Wochentage und Uhrzeit für die Windows-Aufgabe speichern.
procedure TMainformFrm.SaveScheduleSettings;
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
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
// Die Windows-Aufgabe für automatische Backups entfernen.
procedure TMainformFrm.DeleteBackupPlanBtnClick(Sender: TObject);
var
  ShellExecuteInfo: TShellExecuteInfo;
  CmdTargetPath: string;
  Ini: TIniFile;
begin
  // Create a script that removes the scheduled task.
  // Ein Skript erstellen, das die geplante Aufgabe entfernt.
  CmdTargetPath := IncludeTrailingPathDelimiter(AppDataFolder) + 'Backup-Zeitplan-Entfernen.ps1';
  CreateDeleteBackupScheduleCmdScript(CmdTargetPath);

  // Run the script silently in the background.
  // Das Skript still im Hintergrund ausführen.
  FillChar(ShellExecuteInfo, SizeOf(ShellExecuteInfo), 0);
  ShellExecuteInfo.cbSize := SizeOf(ShellExecuteInfo);
  ShellExecuteInfo.fMask := SEE_MASK_NOCLOSEPROCESS;
  ShellExecuteInfo.Wnd := 0;
  ShellExecuteInfo.lpFile := PChar('powershell.exe');
  ShellExecuteInfo.lpParameters := PChar('-NoProfile -ExecutionPolicy Bypass -File "' + CmdTargetPath + '"');
  ShellExecuteInfo.nShow := SW_SHOWNORMAL;
  if ShellExecuteEx(@ShellExecuteInfo) then
  begin
    if ShellExecuteInfo.hProcess <> 0 then
      CloseHandle(ShellExecuteInfo.hProcess);
  end
  else
    CenteredShowMessage('Zeitplan-Entfernen-Skript konnte nicht gestartet werden.');

  // Reset the checkbox.
  // Die Checkbox zurücksetzen.
  AutoBackupCB.Checked := False;
  // Disable related controls and save the setting.
  // Zugehörige Steuerelemente deaktivieren und die Einstellung speichern.
  AutoBackupCBClick(nil);
  // Make sure the INI value is set to False.
  // Sicherstellen, dass der INI-Wert auf False gesetzt ist.
  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
  try
    Ini.WriteBool('Zeitplan', 'Backup nach diesem Zeitplan', False);
  finally
    Ini.Free;
  end;
  CenteredShowMessage('Der geplante Backup-Zeitplan wurde entfernt.');
end;

// Load saved schedule settings into the form controls.
// Gespeicherte Zeitplaneinstellungen in die Formularsteuerelemente laden.
procedure TMainformFrm.LoadScheduleSettings;
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
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
  // Die Oberfläche nach dem Laden der Einstellungen aktualisieren.
  AutoBackupCBClick(nil);

  Label12.Visible := True;
  Label11.Visible := True;

  if KeepBackupsSpE.Value = 0 then
  AllBackupsAreRetainedLbl.Visible := True else
  AllBackupsAreRetainedLbl.Visible := False;
end;

// Create or update the Windows scheduled task for automatic backups.
// Die Windows-Aufgabe für automatische Backups erstellen oder aktualisieren.
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
  // Den Pfad zur ausführbaren Datei ermitteln.
  ProgramPath := ParamStr(0);
  SaveScheduleSettings;
  // Check prerequisites.
  // Voraussetzungen prüfen.
  // Read the docker-compose path from the INI file.
  // Den docker-compose-Pfad aus der INI-Datei lesen.
  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
  try
    ComposePathFromIni := Ini.ReadString('Pfade', 'DockerComposePfad', '').Trim;
  finally
    Ini.Free;
  end;
  // Stop when the compose path is missing.
  // Abbrechen, wenn der Compose-Pfad fehlt.
  if (ComposePathFromIni = '') or
     not FileExists(ComposePathFromIni) then
  begin
    CenteredShowMessage('Fehlender Docker-Compose-Pfad.' + sLineBreak +
                'Bitte führen Sie zuerst ein reguläres Backup durch,' + sLineBreak +
                'damit der Speicherort festgelegt werden kann.');
    Exit;
  end;

  // Build the scheduled start time.
  // Die geplante Startzeit zusammensetzen.
  Hour := Format('%.2d', [HourSpE.Value]);
  Minute := Format('%.2d', [MinuteSpE.Value]);
  // Build the weekday list for schtasks.
  // Die Wochentagsliste für schtasks zusammensetzen.
  if MondayCB.Checked then Weekdays := Weekdays + 'MON,';
  if TuesdayCB.Checked then Weekdays := Weekdays + 'TUE,';
  if WednesdayCB.Checked then Weekdays := Weekdays + 'WED,';
  if ThursdayCB.Checked then Weekdays := Weekdays + 'THU,';
  if FridayCB.Checked then Weekdays := Weekdays + 'FRI,';
  if SaturdayCB.Checked then Weekdays := Weekdays + 'SAT,';
  if SundayCB.Checked then Weekdays := Weekdays + 'SUN,';
  if Weekdays = '' then
  begin
    CenteredShowMessage('Bitte wählen Sie mindestens einen Wochentag aus.');
    Exit;
  end;
  Delete(Weekdays, Length(Weekdays), 1);
  // Build the path to the planned backup PowerShell file.
  // Den Pfad zur geplanten Backup-PowerShell-Datei erstellen.
  try
    Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
    try
      ComposePath := Ini.ReadString('Pfade', 'DockerComposePfad', '').Trim;
    finally
      Ini.Free;
    end;

    if ComposePath = '' then
    begin
      CenteredShowMessage('Fehler: Kein Docker-Compose-Pfad in der INI gespeichert.');
      Exit;
    end;

    // Delete the old marker file if it still exists.
    // Die alte Markerdatei löschen, falls sie noch existiert.
    ComposePathTextFile := IncludeTrailingPathDelimiter(AppDataFolder) + ComposePathFileName;
    if FileExists(ComposePathTextFile) then DeleteFile(ComposePathTextFile);

    TargetCmdPath := IncludeTrailingPathDelimiter(ExtractFilePath(ComposePath)) + 'paperless-backup-geplant.ps1';
  except
    CenteredShowMessage('Fehler beim Lesen des Compose-Pfads.');
    Exit;
  end;


  TargetCmdPath := IncludeTrailingPathDelimiter(ExtractFilePath(ComposePath)) + 'paperless-backup-geplant.ps1';
  if not FileExists(TargetCmdPath) then
  begin
    CenteredShowMessage('Das geplante Backup-Skript wurde nicht gefunden:' + sLineBreak + TargetCmdPath + sLineBreak + 'Bitte erzeugen Sie es zuerst.');
    Exit;
  end;
  // Write the scheduler setup script.
  // Das Skript zum Einrichten der Aufgabenplanung schreiben.
  ScriptPath := IncludeTrailingPathDelimiter(AppDataFolder) + 'Backup-Zeitplan-Anlegen.ps1';
  // The scheduled task starts this program with the /geplant parameter.
  // Die geplante Aufgabe startet dieses Programm mit dem Parameter /geplant.
  CreateBackupScheduleCmdScript(ScriptPath, ProgramPath, Weekdays, Hour, Minute);

  CenteredShowMessage('Die geplante Backup-Aufgabe wurde als Aufgabe eingetragen und als Skript gespeichert:' + sLineBreak + ScriptPath);
  // Run the script silently in the background.
  // Das Skript still im Hintergrund ausführen.
  FillChar(ShellExecuteInfo, SizeOf(ShellExecuteInfo), 0);
  ShellExecuteInfo.cbSize := SizeOf(ShellExecuteInfo);
  ShellExecuteInfo.fMask := SEE_MASK_NOCLOSEPROCESS;
  ShellExecuteInfo.Wnd := 0;
  ShellExecuteInfo.lpFile := PChar('powershell.exe');
  ShellExecuteInfo.lpParameters := PChar('-NoProfile -ExecutionPolicy Bypass -File "' + ScriptPath + '"');
  ShellExecuteInfo.nShow := SW_SHOWNORMAL;
  if ShellExecuteEx(@ShellExecuteInfo) then
  begin
    if ShellExecuteInfo.hProcess <> 0 then
      CloseHandle(ShellExecuteInfo.hProcess);
  end
  else
    CenteredShowMessage('Zeitplan-Anlegen-Skript konnte nicht gestartet werden.');
end;

// Load saved Paperless email settings from email-versand.env.
// Gespeicherte Paperless-E-Mail-Einstellungen aus email-versand.env laden.
procedure TMainformFrm.LoadEmailSettings;
var
  EnvFilePath: string;
  EnvList: TStringList;
begin
  // Path to the .env file in the app data folder.
  // Pfad zur .env-Datei im AppData-Ordner.
  EnvFilePath := IncludeTrailingPathDelimiter(AppDataFolder) + EmailEnvFileName;

  // Load settings only when the file exists.
  // Einstellungen nur laden, wenn die Datei existiert.
  if FileExists(EnvFilePath) then
  begin
    // Use a string list to read the .env file.
    // Eine Stringliste zum Lesen der .env-Datei verwenden.
    EnvList := TStringList.Create;
    try
      try
        // Read the .env file.
        // Die .env-Datei lesen.
        EnvList.LoadFromFile(EnvFilePath);
        // Check whether setup is still pending.
        // Prüfen, ob die Einrichtung noch aussteht.
        if (EnvList.Values['Eingerichtet'] = 'Nein') and not EmailEnvHasConfiguredValues(EnvList) then
        begin
          RequireCompletedSettings;
        end
        else
        begin
          // Copy saved values into the edit fields.
          // Gespeicherte Werte in die Eingabefelder übernehmen.
          SMTPServerEdit.Text := EnvList.Values['PAPERLESS_EMAIL_HOST'];
          SMTPPortEdit.Text := EnvList.Values['PAPERLESS_EMAIL_PORT'];
          UserNameEdit.Text := EnvList.Values['PAPERLESS_EMAIL_HOST_USER'];
          MailAccountPasswordEdit.Text := EnvList.Values['PAPERLESS_EMAIL_HOST_PASSWORD'];
          EMailSentFromEdit.Text := EnvList.Values['PAPERLESS_EMAIL_FROM'];
          // Restore the SSL/TLS selection.
          // Die SSL/TLS-Auswahl wiederherstellen.
          if EnvList.Values['PAPERLESS_EMAIL_USE_SSL'] = 'true' then
          begin
            SSLoTLSRg.ItemIndex := 0;  // SSL
            // SSL
          end
          else if EnvList.Values['PAPERLESS_EMAIL_USE_TLS'] = 'true' then
          begin
            SSLoTLSRg.ItemIndex := 1;  // TLS
            // TLS
          end
          else
          begin
            // No SSL/TLS option is selected.
            // Keine SSL/TLS-Option ist ausgewählt.
            SSLoTLSRg.ItemIndex := -1;
          end;
          // Empty values also mean no selection.
          // Leere Werte bedeuten ebenfalls keine Auswahl.
          if (EnvList.Values['PAPERLESS_EMAIL_USE_SSL'] = '') and (EnvList.Values['PAPERLESS_EMAIL_USE_TLS'] = '') then
          begin
            SSLoTLSRg.ItemIndex := -1;
          end;
        end;
      except
        on E: Exception do
          CenteredShowMessage('Fehler beim Laden der Konfiguration: ' + E.Message);
      end;
    finally
      EnvList.Free;
    end;
  end
  else
  begin
    CenteredShowMessage('Die Datei "email-versand.env" existiert nicht.');
  end;
end;

// Prepare the compose file before email settings can be completed.
// Die Compose-Datei vorbereiten, bevor E-Mail-Einstellungen abgeschlossen werden können.
procedure TMainformFrm.RequireCompletedSettings;
var
  Response: Integer;
begin
  IsUpdate:= True;

  // Ask before changing the compose file and restarting Paperless.
  // Vor dem Ändern der Compose-Datei und dem Neustart von Paperless nachfragen.
  Response := CenteredMessageDlg('E-Mail-Einstellungen stehen aus. Dazu muss Paperless gestoppt werden.' + sLineBreak +
                        'Es werden einige Einstellungen angepasst, eine neue docker-compose-Datei'  + sLineBreak +
                        'erzeugt und Paperless dann neu gestartet.' + sLineBreak + sLineBreak +
                        'Wenn dieser Vorgang abgeschlossen ist, können Sie ihre Mail-Server-Daten ins Formular eintragen.'  + sLineBreak +
                        'Danach ist Paperless in der Lage, Dokumente via Mail zu versenden' + sLineBreak + sLineBreak +
                        'Möchten Sie fortfahren?', mtConfirmation, [mbOk, mbCancel], 0);

  // Continue when the user confirms.
  // Fortfahren, wenn der Benutzer bestätigt.
  if Response = mrOk then
  begin
    // Write a new docker-compose.yml file.
    // Eine neue docker-compose.yml-Datei schreiben.
     CreateDockerComposeWithSetupForm;
  end
  else
  begin
    // Stop when the user cancels.
    // Abbrechen, wenn der Benutzer abbricht.
    CenteredShowMessage('Der Vorgang wurde abgebrochen.');
  end;
end;

// --------------------------------------------------------------
// This procedure saves the current settings and version information
// Diese Prozedur speichert die aktuellen Einstellungen und Versionsinformationen
// into the settings INI file. The routine is divided into two main sections:
// in die Einstellungs-INI-Datei. Die Routine ist in zwei Hauptbereiche aufgeteilt:
// 1. General settings (e.g., trash retention time)
// 1. Allgemeine Einstellungen (z. B. Papierkorb-Aufbewahrungszeit)
// 2. Versions of Docker components (Paperless, Redis, PostgreSQL, etc.)
// 2. Versionen der Docker-Komponenten (Paperless, Redis, PostgreSQL usw.)
// After saving, the user is asked whether to restart Paperless
// Nach dem Speichern wird der Benutzer gefragt, ob Paperless neu gestartet werden soll
// to apply the new configuration.
// um die neue Konfiguration zu übernehmen.
// --------------------------------------------------------------
procedure TMainformFrm.SaveSettingsBtnClick(Sender: TObject);
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
  try
    // --------------------------------------------------------------
    // Section 1: Save general settings.
    // Abschnitt 1: Allgemeine Einstellungen speichern.
    // --------------------------------------------------------------
    Ini.WriteInteger('Einstellungen', 'Papierkorb Aufbewahrungszeit in Tagen',
      StrToIntDef(PapierkorbAufbewahrungEdit.Text, 0));
    Ini.UpdateFile; // Write immediately.
    // Sofort schreiben.

    SettingsSavedLbl.Visible := True; // Show confirmation.
    // Bestätigung anzeigen.

    // Read the saved value back safely.
    // Den gespeicherten Wert sicher zurücklesen.
    try
      TrashRetentionDays :=
        Ini.ReadInteger('Einstellungen', 'Papierkorb Aufbewahrungszeit in Tagen', 0);
    except
      TrashRetentionDays := 365; // Default fallback.
      // Standard-Rückfallwert.
    end;

    // --------------------------------------------------------------
    // Section 2: Save version information.
    // Abschnitt 2: Versionsinformationen speichern.
    // --------------------------------------------------------------
    Ini.WriteString(IniSectionVersions, IniKeyPaperlessVersion, paperless_version_edit.Text);
    Ini.WriteString(IniSectionVersions, IniKeyRedisVersion, redis_version_edit.Text);
    Ini.WriteString(IniSectionVersions, IniKeyPostgresVersion, postgres_version_edit.Text);
    Ini.WriteString(IniSectionVersions, IniKeyGotenbergVersion, gotenberg_version_edit.Text);
    Ini.WriteString(IniSectionVersions, IniKeyTikaVersion, tika_version_edit.Text);
    Ini.WriteString(IniSectionVersions, IniKeyAlpineVersion, alpine_version_edit.Text);
    Ini.WriteString(IniSectionVersions, IniKeyBusyboxVersion, busybox_version_edit.Text);
    Ini.UpdateFile;

  finally
    Ini.Free;
  end;

  // --------------------------------------------------------------
  // Section 3: Ask whether Paperless should be restarted.
  // Abschnitt 3: Fragen, ob Paperless neu gestartet werden soll.
  // --------------------------------------------------------------
  // Run automatically when called after a restore; ask only for direct button clicks.
  // Nach einer Wiederherstellung automatisch ausführen; nur bei direktem Button-Klick nachfragen.
  if (Sender = nil) or
     (CenteredMessageDlg(
       'Paperless muss neu gestartet werden, um die Einstellungen zu übernehmen. ' +
       'Möchten Sie Paperless neu starten?',
       mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
  begin
    IsUpdate := True;
    CenteredMessageBox(
      'Paperless wird heruntergefahren und es wird nach Updates gesucht. ' + #13#10 +
      'Sollten Updates vorliegen, werden diese installiert.' + #13#10 +
      'Geben Sie Paperless nach dem Neustart Zeit.',
      'Info', MB_OK or MB_ICONINFORMATION or MB_TOPMOST);
    TabControl1.TabIndex := 0;
    TabControl1Change(TabControl1);
    Application.ProcessMessages;
    PaperlessUpdate := True;
    IsUpdate := True;
    CreateDockerComposeWithSetupForm;
  end;
end;


// Save the current email fields without triggering a Paperless restart.
// Die aktuellen E-Mail-Felder speichern, ohne einen Paperless-Neustart auszulösen.
procedure TMainformFrm.SaveBlankEmailSettings();
var
  EnvList: TStringList;
  EnvFilePath: string;
begin
  // Build the full path to the file.
  // Den vollständigen Pfad zur Datei erstellen.
  EnvFilePath := IncludeTrailingPathDelimiter(AppDataFolder) + EmailEnvFileName;

  // Make sure the app data folder exists.
  // Sicherstellen, dass der AppData-Ordner existiert.
  if not DirectoryExists(AppDataFolder) then
  begin
    CenteredShowMessage('Der angegebene AppData-Ordner existiert nicht.');
    Exit;
  end;
  if ExistingEmailEnvIsConfigured(EnvFilePath) then
  begin
    LoadEmailSettings;
    LogInfo('Existing configured email-versand.env preserved.');
    Exit;
  end;
  // Build the .env file content.
  // Den Inhalt der .env-Datei zusammenbauen.
  EnvList := TStringList.Create;
  try
    // Add mail settings to email-versand.env.
    // E-Mail-Einstellungen zu email-versand.env hinzufügen.
    EnvList.Add('PAPERLESS_EMAIL_HOST=' + SMTPServerEdit.Text);
    if SMTPPortEdit.Text = '' then
    EnvList.Add('PAPERLESS_EMAIL_PORT=25') else
    EnvList.Add('PAPERLESS_EMAIL_PORT=' + SMTPPortEdit.Text);
    EnvList.Add('PAPERLESS_EMAIL_HOST_USER=' + UserNameEdit.Text);
    EnvList.Add('PAPERLESS_EMAIL_HOST_PASSWORD=' + MailAccountPasswordEdit.Text);
    EnvList.Add('PAPERLESS_EMAIL_FROM=' + EMailSentFromEdit.Text);

    // Save the SSL/TLS selection.
    // Die SSL/TLS-Auswahl speichern.
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
    // Die Datei speichern.
    EnvList.SaveToFile(EnvFilePath, TEncoding.ANSI);
  except
    on E: Exception do
      CenteredShowMessage('Fehler beim Speichern der Datei: ' + E.Message);
  end;
  // Clean up.
  // Aufräumen.
  EnvList.Free;
end;

// Save email settings and restart Paperless so the new values are used.
// E-Mail-Einstellungen speichern und Paperless neu starten, damit die neuen Werte verwendet werden.
procedure TMainformFrm.SaveEmailSettingsBtnClick(Sender: TObject);
var
  EnvList: TStringList;
  EnvFilePath: string;
  SettingsSaved: Boolean;
begin
  HideWelcomeLabel;
  SettingsSaved := False;
  // Build the full path to the file.
  // Den vollständigen Pfad zur Datei erstellen.
  EnvFilePath := IncludeTrailingPathDelimiter(AppDataFolder) + EmailEnvFileName;

  // Make sure the app data folder exists.
  // Sicherstellen, dass der AppData-Ordner existiert.
  if not DirectoryExists(AppDataFolder) then
  begin
    CenteredShowMessage('Der angegebene AppData-Ordner existiert nicht.');
    Exit;
  end;
  if ExistingEmailEnvIsConfigured(EnvFilePath) and
     (Trim(SMTPServerEdit.Text) = '') and
     (Trim(SMTPPortEdit.Text) = '') and
     (Trim(UserNameEdit.Text) = '') and
     (Trim(MailAccountPasswordEdit.Text) = '') and
     (Trim(EMailSentFromEdit.Text) = '') and
     (SSLoTLSRg.ItemIndex = -1) then
  begin
    LoadEmailSettings;
    CenteredShowMessage('Vorhandene Mail-Einstellungen wurden geladen und nicht überschrieben.');
    Exit;
  end;
  // Build the .env file content.
  // Den Inhalt der .env-Datei zusammenbauen.
  EnvList := TStringList.Create;
  try
    // Add mail settings to email-versand.env.
    // E-Mail-Einstellungen zu email-versand.env hinzufügen.
    EnvList.Add('PAPERLESS_EMAIL_HOST=' + SMTPServerEdit.Text);
    EnvList.Add('PAPERLESS_EMAIL_PORT=' + SMTPPortEdit.Text);
    EnvList.Add('PAPERLESS_EMAIL_HOST_USER=' + UserNameEdit.Text);
    EnvList.Add('PAPERLESS_EMAIL_HOST_PASSWORD=' + MailAccountPasswordEdit.Text);
    EnvList.Add('PAPERLESS_EMAIL_FROM=' + EMailSentFromEdit.Text);

    // Save the SSL/TLS selection.
    // Die SSL/TLS-Auswahl speichern.
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
    // Die Datei speichern.
    EnvList.SaveToFile(EnvFilePath, TEncoding.ANSI);
    SettingsSaved := True;
  except
    on E: Exception do
      CenteredShowMessage('Fehler beim Speichern der Datei: ' + E.Message);
  end;

  // Clean up.
  // Aufräumen.
  EnvList.Free;
  if not SettingsSaved then Exit;
    // Restart after changing email settings.
    // Nach Änderung der E-Mail-Einstellungen neu starten.
     CenteredMessageBox('Paperless muss neu gestartet werden, um die Einstellungen zu übernehmen.', 'Information',
     MB_OK or MB_ICONINFORMATION or MB_TOPMOST);
    TabControl1.TabIndex := 0;
    TabControl1Change(TabControl1);
    Application.ProcessMessages;
    SaveEmailSettingsBtn.Enabled:=False;
    IsApplyingEmailSettings := True;
    CreateRestartScript(ExtractFilePath(ComposePath));
    IsApplyingEmailSettings := False;
end;

// Create the default email-versand.env file when it is missing.
// Die Standarddatei email-versand.env erstellen, wenn sie fehlt.
procedure TMainformFrm.SaveEmptyEnvFile();
var
  EnvList: TStringList;
  EnvFilePath: string;
begin
  // Build the full path to the file.
  // Den vollständigen Pfad zur Datei erstellen.
  EnvFilePath := IncludeTrailingPathDelimiter(AppDataFolder) + EmailEnvFileName;

  // Make sure the app data folder exists.
  // Sicherstellen, dass der AppData-Ordner existiert.
  if not DirectoryExists(AppDataFolder) then
  begin
    CenteredShowMessage('Der angegebene AppData-Ordner existiert nicht.');
    Exit;
  end;

  // Create an empty .env file when it does not exist yet.
  // Eine leere .env-Datei erstellen, wenn sie noch nicht existiert.
  if not FileExists(IncludeTrailingPathDelimiter(AppDataFolder) + EmailEnvFileName) then
  begin
    // Build the default .env content.
    // Den Standardinhalt der .env-Datei zusammenbauen.
    EnvList := TStringList.Create;
    try
      // Add default email settings.
      // Standard-E-Mail-Einstellungen hinzufügen.
      EnvList.Add('Eingerichtet=Nein');
       EnvList.Add('PAPERLESS_EMAIL_HOST=');
      EnvList.Add('PAPERLESS_EMAIL_PORT=');
      EnvList.Add('PAPERLESS_EMAIL_HOST_USER=');
      EnvList.Add('PAPERLESS_EMAIL_HOST_PASSWORD=');
      EnvList.Add('PAPERLESS_EMAIL_FROM=');
      EnvList.Add('PAPERLESS_EMAIL_USE_TLS=');
      EnvList.Add('PAPERLESS_EMAIL_USE_SSL=');
      // Save the file.
      // Die Datei speichern.
      EnvList.SaveToFile(EnvFilePath);
      // Show save errors.
      // Speicherfehler anzeigen.
      except
        on E: Exception do
          CenteredShowMessage('Fehler beim Speichern der Datei: ' + E.Message);
    end;
    // Clean up.
    // Aufräumen.
    EnvList.Free;
  end;
end;

// Create the PowerShell file that is called by the Windows scheduled task.
// Die PowerShell-Datei erstellen, die von der Windows-Aufgabe aufgerufen wird.
procedure TMainformFrm.CreateBackupPlanScript(const ComposePath: string);
var
  BackupFolderList: TArray<string>;
  MaxBackupFolders: Integer;
  Ini: TIniFile;
  Volumes: TDockerVolumeNames;
begin
  // Stop when no compose path was provided.
  // Abbrechen, wenn kein Compose-Pfad übergeben wurde.
  if ComposePath.Trim = '' then
  begin
    CenteredShowMessage('Fehler: Es wurde kein gültiger Compose-Pfad gewählt.');
    Exit;
  end;

  // Prepare a compose name without spaces.
  // Einen Compose-Namen ohne Leerzeichen vorbereiten.
  ComposeName := StringReplace(
                   ExtractFileName(ExcludeTrailingPathDelimiter(ComposePath)),
                   ' ', '-', [rfReplaceAll]);

  // Build the path for the planned backup PowerShell file.
  // Den Pfad zur geplanten Backup-PowerShell-Datei erstellen.
  CmdTargetPath := IncludeTrailingPathDelimiter(ComposePath) +
                 'paperless-backup-geplant.ps1';
  // Use the saved backup folder, or fall back to Desktop\FallbackBackup.
  // Den gespeicherten Backup-Ordner verwenden oder auf Desktop\FallbackBackup zurückfallen.
  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
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
  // Delete old backup folders when a retention limit is set.
  // Alte Backup-Ordner löschen, wenn eine Aufbewahrungsgrenze gesetzt ist.
  MaxBackupFolders := KeepBackupsSpE.Value;
  if (MaxBackupFolders > 0) and DirectoryExists(BackupPath) then
  begin
    try
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
          // Aufsteigend: älteste zuerst.
        end));
      if Length(BackupFolderList) > MaxBackupFolders then
      begin
        for var i := 0 to Length(BackupFolderList) - MaxBackupFolders - 1 do
        begin
          try
            TDirectory.Delete(BackupFolderList[i], True); // Delete oldest folders.
            // Die ältesten Ordner löschen.
          except
            on E: Exception do
              LogWarning('Could not delete old planned backup folder "' + BackupFolderList[i] + '": ' + E.Message);
          end;
        end;
      end;
    except
      on E: Exception do
        LogWarning('Could not clean planned backup folders: ' + E.Message);
    end;
  end;
end;

// Run the planned backup script without showing a console window.
// Das geplante Backup-Skript ohne sichtbares Konsolenfenster ausführen.
procedure TMainformFrm.StartBackupPlanScriptSilent;
var
  SI: TStartupInfo;
  PI: TProcessInformation;
  CmdPath: string;
begin
  CmdPath := IncludeTrailingPathDelimiter(AppDataFolder) + 'GeplanterBackupTaskSkript.ps1';
  if not FileExists(CmdPath) then
  begin
    CenteredShowMessage('Das geplante Backup-Skript wurde nicht gefunden: ' + CmdPath);
    Exit;
  end;
  ZeroMemory(@SI, SizeOf(SI));
  SI.cb := SizeOf(SI);
  SI.dwFlags := STARTF_USESHOWWINDOW;
  SI.wShowWindow := SW_HIDE;
  if CreateProcess(nil, PChar('powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' + CmdPath + '"'), nil, nil, False,
     CREATE_NO_WINDOW, nil, nil, SI, PI) then
  begin
    CloseHandle(PI.hThread);
    CloseHandle(PI.hProcess);
  end
  else
    CenteredShowMessage('Geplantes Backup-Skript konnte nicht gestartet werden.');
end;

// Reserved click handler for the static text control.
// Reservierter Klick-Handler für das StaticText-Steuerelement.
procedure TMainformFrm.StaticText1Click(Sender: TObject);
begin

end;

// --------------------------------------------------------------
// Restore
// Wiederherstellung
// --------------------------------------------------------------
// Let the user select a backup folder and create the restore script.
// Den Benutzer einen Backup-Ordner auswählen lassen und das Wiederherstellungsskript erstellen.
procedure TMainformFrm.RestorePaperlessBackupBtnClick(Sender: TObject);
var
  BackupFolder: string;
  FolderDialog: TFileOpenDialog;
  Ini: TIniFile;
  RestoreDefaultFolder: string;
begin
  HideWelcomeLabel;
  WriteComposeContainerAndVolumeInfo(ExtractFilePath(ComposePath));
  StartPaperlessBackupBtn.Enabled := False;
  RestorePaperlessBackupBtn.Enabled := False;
  ReadContainerNamesFromFile;
  IsBackup := False;
  IsPaperlessInstallation := False;
  if ComposePath = '' then
  begin
    CenteredShowMessage('Bitte zuerst den Paperless-Ordner auswählen.');
    StartPaperlessBackupBtn.Enabled := True;
    RestorePaperlessBackupBtn.Enabled := True;
    Exit;
  end;
  // Start the restore folder picker in the last known backup target folder.
  // Die Ordnerauswahl für die Wiederherstellung im zuletzt bekannten Backup-Zielordner starten.
  RestoreDefaultFolder := GetEnvironmentVariable('USERPROFILE');
  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
  try
    LastBackupFolder := Ini.ReadString('Pfade', 'BackupZiel', '').Trim;
    if (LastBackupFolder <> '') and DirectoryExists(LastBackupFolder) then
      RestoreDefaultFolder := LastBackupFolder;
  finally
    Ini.Free;
  end;
  FolderDialog := TFileOpenDialog.Create(nil);
  try
    FolderDialog.Options := [fdoPickFolders];
    FolderDialog.Title := 'Bitte den Ordner mit Ihrem Paperless-Backup auswählen.';
    FolderDialog.DefaultFolder := RestoreDefaultFolder;
    if FolderDialog.Execute(Handle) then
    begin
      BackupFolder := FolderDialog.FileName;
      if ApplyPaperlessSecretKeyForRestore(BackupFolder) then
      begin
        ShouldWriteNewCompose := True;
        try
          CreateDockerComposeWithSetupForm;
        finally
          ShouldWriteNewCompose := False;
        end;
      end;
      RestoreEmailEnvFromBackup(BackupFolder, ComposePath);
      CreateRestoreScript(ComposePath, BackupFolder);
    end
    else
    begin
      CenteredShowMessage('Wiederherstellung abgebrochen – kein Backup-Ordner gewählt.');
    end;
  finally
    FolderDialog.Free;
  end;
  // Update the form state.
  // Den Formularzustand aktualisieren.
  StartPaperlessBackupBtn.Enabled := True;
  RestorePaperlessBackupBtn.Enabled := True;
end;

// Enable the email save button after the user confirms that the update step is done.
// Den E-Mail-Speichern-Button aktivieren, nachdem der Benutzer den abgeschlossenen Update-Schritt bestätigt hat.
procedure TMainformFrm.UpdateDoneCbClick(Sender: TObject);
begin
  if HabeUpdaetGemachtCb.State = cbUnchecked then
  PaperlessUpdateBtn.Enabled := False else
  PaperlessUpdateBtn.Enabled := True;
end;
// Open the local Paperless installation in the default browser.
// Die lokale Paperless-Installation im Standardbrowser oeffnen.
procedure TMainformFrm.OpenPaperlessBrowserLblClick(Sender: TObject);
begin
  HideWelcomeLabel;
  ShellExecute(0, 'open', PaperlessLocalUrlWithSlash, nil, nil, SW_SHOWNORMAL);
end;
// Create paperless-restore.ps1 for the selected backup folder.
// paperless-restore.ps1 für den ausgewählten Backup-Ordner erstellen.
// The script restores the database dump and all Paperless Docker volumes.
// Das Skript stellt den Datenbank-Dump und alle Paperless-Docker-Volumes wieder her.
procedure TMainformFrm.CreateRestoreScript(const ComposePath, BackupFolder: string);
var
  Volumes: TDockerVolumeNames;
begin
  // Stop when no compose path was provided.
  // Abbrechen, wenn kein Compose-Pfad übergeben wurde.
  if ComposePath.Trim = '' then
  begin
    CenteredShowMessage('Fehler: Es wurde kein gültiger Compose-Pfad gewählt.');
    Exit;
  end;
  CmdTargetPath := IncludeTrailingPathDelimiter(ExtractFilePath(ComposePath)) + 'paperless-restore.ps1';
  Volumes.Data := Volume_data;
  Volumes.DbData := Volume_db_data;
  Volumes.ExportData := Volume_export;
  Volumes.Media := Volume_media;
  CreateRestoreCmdScript(CmdTargetPath, ComposePath, BackupFolder, PaperlessDBName, Volumes);
  StartAndMonitorCmdScript;
end;

// Run the current PowerShell script, wait for it, and show success or failure.
// Das aktuelle PowerShell-Skript ausführen, darauf warten und Erfolg oder Fehler anzeigen.
procedure TMainformFrm.StartAndMonitorCmdScript;
var
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  Cmd: string;
  RunningStatus: string;
  OutputLogPath: string;
  SuccessStatus: string;
  ExitCode: DWORD;
  ShouldWait: Boolean;
begin
  ShouldWait := False;
  FillChar(StartupInfo, SizeOf(TStartupInfo), 0);
  StartupInfo.cb := SizeOf(TStartupInfo);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := SW_HIDE;
  OutputLogPath := PrepareScriptOutputLog;
  Cmd := BuildPowerShellCommand(CmdTargetPath, OutputLogPath); // Script path.
  // Skriptpfad.
  if IsUpdate then
    RunningStatus := 'Update wird gestartet...'
  else if IsPaperlessInstallation then
    RunningStatus := 'Paperless-Installation wird gestartet...'
  else if IsBackup then
    RunningStatus := 'Backup wird gestartet...'
  else
    RunningStatus := 'Wiederherstellung wird gestartet...';
  PrepareScriptProgress(RunningStatus);
  if CreateProcess(nil, PChar(Cmd), nil, nil, False, CREATE_NO_WINDOW, nil, nil, StartupInfo, ProcessInfo) then
  begin
    ShouldWait := True;
    UpdateScriptProgress(RunningStatus);
    Sleep(1500);
    if IsUpdate = False then
    begin
        if ShouldWait then
        begin
          // Wait for the process to finish.
          // Warten, bis der Prozess beendet ist.
          WaitForScriptWithProgress(ProcessInfo.hProcess, RunningStatus, OutputLogPath);
          // Check the exit code.
          // Den Exit-Code prüfen.
          GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);
          CloseHandle(ProcessInfo.hProcess);
          CloseHandle(ProcessInfo.hThread);
          Sleep(1000);
          if ExitCode = 0 then
          begin
            if IsPaperlessInstallation = True then
              SuccessStatus := 'Paperless-Installation abgeschlossen.'
            else if IsBackup = True then
              SuccessStatus := 'Backupvorgang abgeschlossen.'
            else if IsUpdate = True then
              SuccessStatus := 'Update abgeschlossen.'
            else
              SuccessStatus := 'Wiederherstellung abgeschlossen.';
            FinishScriptProgress(SuccessStatus, True);
            if IsPaperlessInstallation = True then
            begin
              WriteStandardVersionAfterInstallation;
              CenteredMessageBox('Paperless wurde erfolgreich installiert und gestartet.' + #13#10 +
                'Sie können Paperless nun im Browser öffnen (http://localhost:8000). Geben Sie Paperless ein wenig Zeit zum starten.',
                'Installation abgeschlossen', MB_OK or MB_ICONINFORMATION or MB_TOPMOST);

              SetupFrm.DockerGefundenLbl.Caption := 'Paperless erfolgreich installiert.';
              SetupFrm.PaperlessInstallierenBtn.Enabled := False;
              SetupFrm.BitteBestaetigenLbl.Visible := True;

              SetupFrm.HinweisMemo.Lines.Clear;
              SetupFrm.HinweisMemo.Lines.Add('Ihr Paperless wurde erfolgreich installiert.');
              SetupFrm.HinweisMemo.Lines.Add(' ');
              SetupFrm.HinweisMemo.Lines.Add('Nun können Sie Paperless starten, indem Sie Ihren Browser öffnen');
              SetupFrm.HinweisMemo.Lines.Add('und folgende Adresse eingeben oder kopieren und einfügen, oder oben den gelben Link klicken:');
              SetupFrm.HinweisMemo.Lines.Add(' ');
              SetupFrm.HinweisMemo.Lines.Add(PaperlessLocalUrl);
              SetupFrm.HinweisMemo.Lines.Add(' ');
              SetupFrm.HinweisMemo.Lines.Add('Bitte geben Sie dem System ein wenig Zeit, bevor Sie die Seite aufrufen.');
              SetupFrm.HinweisMemo.Lines.Add(' ');
              SetupFrm.HinweisMemo.Lines.Add('Nach dem Öffnen von Paperless werden Sie gebeten einen Benutzernamen und ein Passwort zu vergeben. Speichern Sie diese Zugangsdaten in einem Passwortmanager wie KeePassXC!');
              SetupFrm.LinkKlickLbl.Caption := PaperlessFallbackLocalUrl;
              SetupFrm.Label1.Caption := 'Paperless öffnen:';
              SetupFrm.SieBenoetigenDockerLbl.Caption := 'Alles installiert.';
              SetupFrm.KeePassXCLbl.Visible := True;
              SetupFrm.Label1.Visible := True;
              SetupFrm.LinkKlickLbl.Visible := True;
              SetupFrm.WillkommenLbl.Visible := False;
              SetupFrm.ComputerRalleLbl.Visible := False;
              IsPaperlessInstallation := False;
            end
            else if IsBackup = True then
            begin
              if not IsAutostart then
              begin
                CenteredMessageBox('Backup abgeschlossen. Sie können das Programm jetzt schließen.' + #13#10 +
                'Bitte geben Sie Paperless Zeit zum starten.',
                'Info', MB_OK or MB_ICONINFORMATION or MB_TOPMOST);
              end;

              WriteImageVersionWithSetupForm(BackupPath);

            end
            else
            begin
              if not IsAutostart = True then
              begin
                if IsUpdate = True then
                begin
                  CenteredMessageBox('Update abgeschlossen. Sie können das Programm jetzt schließen.' + #13#10 +
                  'Bitte geben Sie Paperless Zeit zum starten.',
                  'Info', MB_OK or MB_ICONINFORMATION or MB_TOPMOST);
                end else
                begin
                  CenteredMessageBox('Wiederherstellung abgeschlossen.' + #13#10 +
                  'Die Einstellungen werden jetzt neu angewendet, damit die Datenbank-Collation geprüft wird.',
                  'Info', MB_OK or MB_ICONINFORMATION or MB_TOPMOST);
                  SaveSettingsBtnClick(nil);
                end;
              end;
            end;
          end
          else
          begin
            FinishScriptProgress('Vorgang fehlgeschlagen.', False);
            CenteredShowMessage('Vorgang fehlgeschlagen. Fehlercode: ' + IntToStr(ExitCode));
          end;
        end else
        begin
          FinishScriptProgress('Skript konnte nicht gestartet werden.', False);
          CenteredShowMessage('Fehler beim Starten des Skripts.');
        end;
    end else
        begin
          // Wait for the process to finish.
          // Warten, bis der Prozess beendet ist.
          WaitForScriptWithProgress(ProcessInfo.hProcess, RunningStatus, OutputLogPath);
          // Check the exit code.
          // Den Exit-Code prüfen.
          GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);
          CloseHandle(ProcessInfo.hProcess);
          CloseHandle(ProcessInfo.hThread);
          if ExitCode = 0 then
          begin
            FinishScriptProgress('Update abgeschlossen.', True);
            SaveBlankEmailSettings();
            CenteredMessageBox('Paperless wurde erfolgreich aktualisiert' + #13#10 +
            'Sie können Paperless nun im Browser öffnen (http://localhost:8000). Geben Sie Paperless ein wenig Zeit zum starten.',
            'Installation abgeschlossen', MB_OK or MB_ICONINFORMATION or MB_TOPMOST);
            IsUpdate := False;
          end
          else
          begin
            FinishScriptProgress('Paperless-Update fehlgeschlagen.', False);
            CenteredShowMessage('Vorgang fehlgeschlagen. Fehlercode: ' + IntToStr(ExitCode));
          end;
        end;
  end
  else
  begin
    FinishScriptProgress('Skript konnte nicht gestartet werden.', False);
    CenteredShowMessage('Fehler beim Starten des Skripts.');
  end;
  ActiveControl := nil;

  if IsAutostart = True then
  Application.Terminate;

end;

// Run the restart or update script and show the final result to the user.
// Das Neustart- oder Update-Skript ausführen und dem Benutzer das Ergebnis anzeigen.
procedure TMainformFrm.StartAndMonitorRestart;
var
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  Cmd: string;
  RunningStatus: string;
  OutputLogPath: string;
  ExitCode: DWORD;
  WasApplyingEmailSettings: Boolean;
begin
  WasApplyingEmailSettings := IsApplyingEmailSettings;
  FillChar(StartupInfo, SizeOf(TStartupInfo), 0);
  StartupInfo.cb := SizeOf(TStartupInfo);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := SW_HIDE;
  OutputLogPath := PrepareScriptOutputLog;
  Cmd := BuildPowerShellCommand(CmdTargetPath, OutputLogPath); // Script path.
  // Skriptpfad.
  if WasApplyingEmailSettings then
    RunningStatus := 'Mail-Einstellungen werden angewendet...'
  else if PaperlessUpdate then
    RunningStatus := 'Update wird gestartet...'
  else
    RunningStatus := 'Neustart wird gestartet...';
  PrepareScriptProgress(RunningStatus);
  if PaperlessUpdate = False then
  begin
    // Start the process.
    // Den Prozess starten.
    if CreateProcess(nil, PChar(Cmd), nil, nil, False, CREATE_NO_WINDOW, nil, nil, StartupInfo, ProcessInfo) then
    begin
      UpdateScriptProgress(RunningStatus);
      Sleep(1000);
      // Wait for the process to finish.
      // Warten, bis der Prozess beendet ist.
      WaitForScriptWithProgress(ProcessInfo.hProcess, RunningStatus, OutputLogPath);
      // Check the exit code.
      // Den Exit-Code prüfen.
      GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);
      CloseHandle(ProcessInfo.hProcess);
      CloseHandle(ProcessInfo.hThread);

      // Exit code 0 means success.
      // Exit-Code 0 bedeutet Erfolg.
      if ExitCode = 0 then
      begin
        if WasApplyingEmailSettings then
        begin
          FinishScriptProgress('Mail-Einstellungen angewendet.', True);
          CenteredMessageBox('Mail-Einstellungen wurden angewendet. Sie können das Programm jetzt schließen.' + #13#10 +
            'Bitte geben Sie den Paperless Komponenten Zeit zum starten.',
            'Info', MB_OK or MB_ICONINFORMATION or MB_TOPMOST);
        end
        else
        begin
          FinishScriptProgress('Neustart abgeschlossen.', True);
          CenteredMessageBox('Neustart abgeschlossen. Sie können das Programm jetzt schließen.' + #13#10 +
            'Bitte geben Sie den Paperless Komponenten Zeit zum starten.',
            'Info', MB_OK or MB_ICONINFORMATION or MB_TOPMOST);
        end;
      end
      else
      begin
        FinishScriptProgress('Neustart fehlgeschlagen.', False);
        // Show a failure message when the process returns an error.
        // Eine Fehlermeldung anzeigen, wenn der Prozess einen Fehler zurückgibt.
        CenteredShowMessage('Der Vorgang ist fehlgeschlagen. Fehlercode: ' + IntToStr(ExitCode));
      end;
    end
    else
    begin
      FinishScriptProgress('Skript konnte nicht gestartet werden.', False);
      CenteredShowMessage('Fehler beim Starten des Prozesses.');
    end;
    ActiveControl := nil; // Remove focus from the current control.
    // Den Fokus vom aktuellen Steuerelement entfernen.
    if WasApplyingEmailSettings then
      IsApplyingEmailSettings := False;
  end;

  if PaperlessUpdate = true then
  begin
    // Start the process.
    // Den Prozess starten.
    if CreateProcess(nil, PChar(Cmd), nil, nil, False, CREATE_NO_WINDOW, nil, nil, StartupInfo, ProcessInfo) then
    begin
      UpdateScriptProgress(RunningStatus);
      Sleep(1000);
      // Wait for the process to finish.
      // Warten, bis der Prozess beendet ist.
      WaitForScriptWithProgress(ProcessInfo.hProcess, RunningStatus, OutputLogPath);
      // Check the exit code.
      // Den Exit-Code prüfen.
      GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);
      CloseHandle(ProcessInfo.hProcess);
      CloseHandle(ProcessInfo.hThread);

      // Exit code 0 means success.
      // Exit-Code 0 bedeutet Erfolg.
      if ExitCode = 0 then
      begin
        FinishScriptProgress('Update abgeschlossen.', True);
        CenteredMessageBox('Neustart und Updatesuche abgeschlossen. Sie können das Programm jetzt schließen.' + #13#10 +
          'Bitte geben Sie den Paperless Komponenten Zeit zum starten.' + #13#10 +
          'Lagen Updates vor, wurden diese installiert.',
          'Info', MB_OK or MB_ICONINFORMATION or MB_TOPMOST);
      end
      else
      begin
        FinishScriptProgress('Neustart und Updatesuche fehlgeschlagen.', False);
        // Show a failure message when the process returns an error.
        // Eine Fehlermeldung anzeigen, wenn der Prozess einen Fehler zurückgibt.
        CenteredShowMessage('Der Vorgang ist fehlgeschlagen. Fehlercode: ' + IntToStr(ExitCode));
      end;
    end
    else
    begin
      FinishScriptProgress('Skript konnte nicht gestartet werden.', False);
      CenteredShowMessage('Fehler beim Starten des Prozesses.');
    end;
    ActiveControl := nil; // Remove focus from the current control.
    // Den Fokus vom aktuellen Steuerelement entfernen.
  end;
end;

// Create paperless-neustart.ps1 to stop and start Paperless again.
// paperless-neustart.ps1 erstellen, um Paperless zu stoppen und neu zu starten.
procedure TMainformFrm.CreateRestartScript(const ComposePath: string);
begin
  // Stop when no compose path was provided.
  // Abbrechen, wenn kein Compose-Pfad übergeben wurde.
  if ComposePath.Trim = '' then
  begin
    CenteredShowMessage('Fehler: Es wurde kein gültiger Compose-Pfad gewählt.');
    Exit;
  end;
  ComposeName := StringReplace(ExtractFileName(ExcludeTrailingPathDelimiter(ComposePath)), ' ', '-', [rfReplaceAll]);
  CmdTargetPath := IncludeTrailingPathDelimiter(ComposePath) + 'paperless-neustart.ps1';
  CreateRestartCmdScript(CmdTargetPath, ComposePath);
  StartAndMonitorRestart;
end;

// Bring the console window of a started process to the front.
// Das Konsolenfenster eines gestarteten Prozesses in den Vordergrund bringen.
procedure TMainformFrm.ConsoleToFront(PID: DWORD);
var
  hConsoleWnd: HWND;
begin
  // Bring the PowerShell window to the front.
  // Das PowerShell-Fenster in den Vordergrund bringen.
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
// Die Einstellungsseite anzeigen, auf der Image-Versionen und Update-Einstellungen bearbeitet werden.
procedure TMainformFrm.PaperlessUpdateBtnClick(Sender: TObject);
begin
  HideWelcomeLabel;
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
// Zeitplanung erst aktivieren, wenn Compose-Datei und Backup-Ziel bekannt sind.
procedure TMainformFrm.CheckScheduleAllowed;
var
  Ini: TIniFile;
  ComposePathFromIni, BackupTargetFromIni: string;
begin
  // Read required paths from the INI file.
  // Benötigte Pfade aus der INI-Datei lesen.
  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
  try
    ComposePathFromIni := Ini.ReadString('Pfade', 'DockerComposePfad', '').Trim;
    BackupTargetFromIni := Ini.ReadString('Pfade', 'BackupZiel', '').Trim;
  finally
    Ini.Free;
  end;

  // Scheduling is allowed only when compose file and backup target exist.
  // Zeitplanung ist nur erlaubt, wenn Compose-Datei und Backup-Ziel existieren.
  if FileExists(ComposePathFromIni) and DirectoryExists(BackupTargetFromIni) then
  begin
    // Enable scheduling controls.
    // Zeitplan-Steuerelemente aktivieren.
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
    // Zeitplan-Steuerelemente deaktivieren.
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
// Container- und Volume-Namen erkennen und in eine kleine Hilfsdatei schreiben.
procedure TMainformFrm.WriteComposeContainerAndVolumeInfo(const ComposePath: string);
var
  SL, ContainerLines, VolumeLines: TStringList;
  ComposeYmlPath, CmdOutput, InfoPath, Line: string;
  i: Integer;
begin
  ComposeYmlPath := IncludeTrailingPathDelimiter(AppDataFolder) + DockerComposeFileName;
  InfoPath := IncludeTrailingPathDelimiter(AppDataFolder) + ContainerVolumeInfoFileName;

  if not FileExists(ComposeYmlPath) then
  begin
    CenteredShowMessage('Fehler: docker-compose.yml wurde im gewählten Ordner nicht gefunden.');
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
// Einen Shell-Befehl versteckt ausführen und seine Textausgabe zurückgeben.
function TMainformFrm.ExecuteShellCommand(const Command, Params: string): string;
const
  CommandTimeoutMs = 120000;
var
  SA: TSecurityAttributes;
  SI: TStartupInfo;
  PI: TProcessInformation;
  StdOutRead, StdOutWrite: THandle;
  Buffer: array[0..4095] of AnsiChar;
  BytesRead, BytesAvailable, ReadSize: DWORD;
  WaitResult: DWORD;
  StartTick: UInt64;
  Output, Chunk: AnsiString;
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
  StdOutWrite := 0;
  Output := '';
  StartTick := GetTickCount64;
  repeat
    WaitResult := WaitForSingleObject(PI.hProcess, 50);
    repeat
      BytesAvailable := 0;
      if not PeekNamedPipe(StdOutRead, nil, 0, nil, @BytesAvailable, nil) then
        Break;
      if BytesAvailable = 0 then
        Break;
      BytesRead := 0;
      if BytesAvailable > SizeOf(Buffer) then
        ReadSize := SizeOf(Buffer)
      else
        ReadSize := BytesAvailable;
      if ReadFile(StdOutRead, Buffer, ReadSize, BytesRead, nil) and (BytesRead > 0) then
      begin
        SetString(Chunk, PAnsiChar(@Buffer[0]), BytesRead);
        Output := Output + Chunk;
      end
      else
        Break;
    until False;
    if (WaitResult = WAIT_TIMEOUT) and (GetTickCount64 - StartTick > CommandTimeoutMs) then
      Break;
  until WaitResult <> WAIT_TIMEOUT;
  if WaitResult <> WAIT_OBJECT_0 then
  begin
    TerminateProcess(PI.hProcess, DWORD(-1));
    CloseHandle(PI.hProcess);
    CloseHandle(PI.hThread);
    CloseHandle(StdOutRead);
    Exit('');
  end;
  repeat
    BytesRead := 0;
    ReadFile(StdOutRead, Buffer, SizeOf(Buffer), BytesRead, nil);
    if BytesRead > 0 then
    begin
      SetString(Chunk, PAnsiChar(@Buffer[0]), BytesRead);
      Output := Output + Chunk;
    end;
  until BytesRead = 0;

  CloseHandle(StdOutRead);
  CloseHandle(PI.hProcess);
  CloseHandle(PI.hThread);

  Result := string(Output);
end;

// Read the file version from a Windows executable or DLL.
// Die Dateiversion aus einer Windows-EXE oder DLL lesen.
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
// Container- und Volume-Namen aus ContainerUndVolumesInfo.txt lesen.
procedure TMainformFrm.ReadContainerNamesFromFile;
var
  FilePath: string;
  SL: TStringList;
  i: Integer;
  Line: string;
  InVolumeSection: Boolean;
begin
  FilePath := IncludeTrailingPathDelimiter(AppDataFolder) + ContainerVolumeInfoFileName;

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
// Hilfelinks
// --------------------------------------------------------------
procedure TMainformFrm.ImprintLblClick(Sender: TObject);
begin
  ShellExecute(0, 'open', ImprintUrl, nil, nil, SW_SHOWNORMAL);
end;

procedure TMainformFrm.PaperlessPlaylistLblClick(Sender: TObject);
begin
  ShellExecute(0, 'open', PaperlessPlaylistUrl, nil, nil, SW_SHOWNORMAL);
end;

procedure TMainformFrm.MyYouTubeChannelLblClick(Sender: TObject);
begin
 ShellExecute(0, 'open', YouTubeChannelUrl, nil, nil, SW_SHOWNORMAL);
end;

procedure TMainformFrm.BackupProgramGuideLblClick(Sender: TObject);
begin
 ShellExecute(0, 'open', BackupGuideUrl, nil, nil, SW_SHOWNORMAL);
end;

procedure TMainformFrm.Web1LblClick(Sender: TObject);
begin
 ShellExecute(0, 'open', ComputerRalleUrl, nil, nil, SW_SHOWNORMAL);
end;
procedure TMainformFrm.Web2LblClick(Sender: TObject);
begin
 ShellExecute(0, 'open', BlogUrl, nil, nil, SW_SHOWNORMAL);
end;

procedure TMainformFrm.NewsletterLblClick(Sender: TObject);
begin
  ShellExecute(0, 'open', NewsletterUrl, nil, nil, SW_SHOWNORMAL);
end;

procedure TMainformFrm.ProgramUpdateLblClick(Sender: TObject);
begin
  ShellExecute(0, 'open', ProgramDownloadUrl, nil, nil, SW_SHOWNORMAL);
end;

// Return the version of the running executable as a string.
// Die Version der laufenden EXE als Zeichenkette zurückgeben.
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
// Eine gepunktete Version (x.x.x.x) in eine sortierbare Zeichenkette fester Breite umwandeln.
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
