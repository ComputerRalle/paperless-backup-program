// --------------------------------------------------------------
// Paperless Backup Program / Paperless Backup Programm
//
// Copyright (C) 2025-2026 Ralf-Peter Kleinert (#ComputerRalle / DIGITAL-easy)
// Website: https://ralf-peter-kleinert.de
// Website: https://computerralle.de
// YouTube: https://www.youtube.com/@ComputerRalle
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <https://www.fsf.org/licenses/>
// or check LICENSE.txt in this repository.
// --------------------------------------------------------------

// Hauptoberfläche und Ablaufsteuerung für Backup, Restore, Einstellungen und Zeitplan. Docker-Befehle werden als PowerShell-Skripte erzeugt und über Prozess-Exitcodes überwacht.
unit Mainform;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.Math,
  Vcl.Graphics, Vcl.Imaging.pngimage, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, ShellAPI, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  System.IOUtils, Vcl.FileCtrl, Vcl.Samples.Spin, System.IniFiles, DateUtils, SetupForm, System.Generics.Collections, System.Generics.Defaults, Vcl.Menus,
  System.Net.URLClient, System.Net.HttpClient, System.Net.HttpClientComponent, ScriptGenerator, AppConfig, AppLogger, AppDialogs, Crypto, ExternPaperless, BackupRestoreServer;

type
  TMainformFrm = class(TForm)
    StatusBar1: TStatusBar;
    Panel2: TPanel;
    BackupRestorePan: TPanel;
    Panel3: TPanel;
    StartPaperlessBackupBtn: TButton;
    OpenManualBtn: TButton;
    RestorePaperlessBackupBtn: TButton;
    LoadServerBackupBtn: TButton;
    SendServerBackupBtn: TButton;
    LoadServerBackupHintPan: TPanel;
    SendServerBackupHintPan: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel1: TPanel;
    BuyMeACoffeBtn: TButton;
    ChangelogBtn: TButton;
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
    RetentionSavedLbl: TLabel;
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
    SettingsScrollBox: TScrollBox;
    InstallationModeRadioGroup: TRadioGroup;
    ExternalServerDividerPan: TPanel;
    ExternalServerTitleLbl: TLabel;
    ExternalHostLbl: TLabel;
    ExternalPortLbl: TLabel;
    ExternalWebPortLbl: TLabel;
    ExternalUserLbl: TLabel;
    ExternalPasswordLbl: TLabel;
    ExternalKeyLbl: TLabel;
    ExternalComposePathLbl: TLabel;
    ExternalComposeProjectLbl: TLabel;
    ExternalHostEdit: TEdit;
    ExternalPortEdit: TEdit;
    ExternalWebPortEdit: TEdit;
    ExternalUserEdit: TEdit;
    ExternalPasswordEdit: TEdit;
    ExternalKeyEdit: TEdit;
    ExternalComposePathEdit: TEdit;
    ExternalComposeProjectEdit: TEdit;
    ExternalBackupFolderLbl: TLabel;
    ExternalBackupFolderEdit: TEdit;
    CreateExternalBackupFolderBtn: TButton;
    ExternalAuthRadioGroup: TRadioGroup;
    ExternalKeyPassphraseLbl: TLabel;
    ExternalKeyPassphraseEdit: TEdit;
    SaveExternalServerBtn: TButton;
    InstallServerPaperlessBtn: TButton;
    TestExternalConnectionBtn: TButton;
    UseSavedSshCredentialCB: TCheckBox;
    ExternalConnectionStatusLbl: TLabel;
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
    // DFM: checked and disabled initially, above the backup confirmation.
    // DFM: anfangs angehakt und inaktiv, oberhalb der Backup-Bestätigung.
    OnlyPaperlessVersionCB: TCheckBox;
    // Settings panel: preserve existing scripts/Compose independently of version edit permission.
    // Einstellungen: vorhandene Skripte/Compose unabhängig von der Versionsfreigabe schützen.
    ProtectCustomFilesCB: TCheckBox;
    NetHTTPClient1: TNetHTTPClient;
    ProgramUpdateLbl: TLabel;
    ProgressBar1: TProgressBar;
    BusyWaitLbl: TLabel;
    Button1: TButton;
    procedure StartPaperlessBackupBtnClick(Sender: TObject);
    procedure LoadServerBackupBtnClick(Sender: TObject);
    procedure SendServerBackupBtnClick(Sender: TObject);
    procedure OpenManualBtnClick(Sender: TObject);
    procedure BuyMeACoffeeBtnClick(Sender: TObject);
    procedure StartCmdScript;
    procedure FormShow(Sender: TObject);
    procedure StartPaperlessBackupScriptBtnClick(Sender: TObject);
    procedure RestorePaperlessBackupBtnClick(Sender: TObject);
    procedure CreateRestoreScript(const ComposePath, BackupFolder, PreparedKey: string;
      const RestoreMailBytes: TBytes; const HasRestoreMail: Boolean);
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
    procedure ExternalAuthRadioGroupClick(Sender: TObject);
    procedure CreateExternalBackupFolderBtnClick(Sender: TObject);
    procedure SaveExternalServerBtnClick(Sender: TObject);
    procedure InstallServerPaperlessBtnClick(Sender: TObject);
    procedure TestExternalConnectionBtnClick(Sender: TObject);
    procedure ExternalConnectionSettingsChanged(Sender: TObject);
    procedure InstallationModeRadioGroupClick(Sender: TObject);
    procedure ProtectCustomFilesCBClick(Sender: TObject);
    procedure UpdateComposeProtectionControls;
    procedure WriteStandardVersionAfterInstallation();

    procedure LoadUpdateIniFile();
    function GetExeVersion: string;
    procedure ProgramUpdateLblClick(Sender: TObject);
    procedure ChangelogBtnClick(Sender: TObject);
    function TryCompareProgramVersions(const LeftVersion, RightVersion: string; out Comparison: Integer): Boolean;

  private
    FServerBackupCheckActive: Boolean;
    FServerBackupProgressActive: Boolean;
    FServerBackupAction: TServerBackupAction;
    FServerBackupStatusText: string;
    FServerWorkerProgressOffset: Int64;
    FServerBackupModeWasEnabled: Boolean;
    FServerBackupCheckHandle: THandle;
    FServerBackupCheckTimer: TTimer;
    FServerBackupCheckResultPath: string;
    FStartupCheckHandle: THandle;
    FStartupCheckTimer: TTimer;
    FStartupCheckResultPath: string;
    FStartupCheckOnce: Boolean;
    FStartupInstallHost: string;
    FStartupCheckInvalidated: Boolean;
    FExternalConnectionHeader: string;
    FExternalTestTimer: TTimer;
    FExternalTestResultPath: string;
    FExternalTestInvalidated: Boolean;
    FExternalTestStarted: Cardinal;
    FRestoreLegacyNames: Boolean;
    FVersionsReady: Boolean;
    FLocalStartupPending: Boolean;
    FChangingInstallationMode: Boolean;
    FVersionSnapshot: array[0..6] of string;
    // Suppress OnClick recursion during loading, cancellation and failure recovery.
    // OnClick-Rekursion beim Laden, Abbrechen und Zurücksetzen nach Fehlern unterdrücken.
    FLoadingCustomFileProtection: Boolean;
    FManualBackupSucceeded: Boolean;
    FLocalRestoreActive, FLocalRestoreSucceeded: Boolean;
    FLocalRestoreLogPath: string;
    FRetentionRestartChoice: Integer;
    FRetentionUpdateRequested: Boolean;
    FRetentionUpdateSucceeded: Boolean;
    procedure BeginServerBackupCheck(const BackupFolder: string = '';
      Action: TServerBackupAction = sbaCheckSpace; const LocalDownloadFolder: string = '');
    procedure EndServerBackupCheck;
    procedure ServerBackupCheckTimerTick(Sender: TObject);
    function ReadNextServerWorkerStatus(const ProgressPath: string): Boolean;
    function ConfirmServerRestore(const BackupFolder: string): Boolean;
    procedure CancelExternalStartupCheck;
    procedure BeginExternalStartupCheck(ConfirmFingerprint: Boolean = False;
      const InstallHost: string = '');
    procedure ConfirmServerInstallation(const Host: string);
    procedure StartupCheckTimerTick(Sender: TObject);
    procedure ExternalTestTimerTick(Sender: TObject);
    procedure LoadStoredInstallationMode;
    procedure LoadExternalServerSettings;
    procedure PrepareLocalAfterExternalStart;
    function LocalInstallationAvailable: Boolean;
    procedure UpdateServerBackupButtons;
    procedure UpdateInstallationModeHeaders;
    procedure CaptureVersionSnapshot;
    function VersionsChanged: Boolean;
    procedure LoadVersionsForMode(ExternalMode: Boolean);
    procedure SaveVersionsForMode(ExternalMode: Boolean);
    procedure CreateBackupScript(const ComposePath: string);
    function PowerShellQuote(const Value: string): string;
    function PrepareScriptOutputLog: string;
    function BuildPowerShellCommand(const ScriptPath, OutputLogPath: string): string;
    function ReadLastScriptOutputLine(const OutputLogPath, FallbackText: string): string;
    function ScriptFailureMessage(const OutputLogPath: string; ExitCode: DWORD): string;
    function ShortenScriptStatusText(const StatusText: string): string;
    function BuildInstallationStatusText(const StatusText: string): string;
    function EstimateInstallationProgressPercent(const StatusText: string; const CurrentPosition: Integer): Integer;
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
    function EncryptEmailEnvForBackup(out EncryptedMailPath: string): Boolean;
    function RestoreEmailEnvFromBackup(const SourceBackupPath: string; out MailBytes: TBytes; out HasMail: Boolean): Boolean;
    function ValidateRestoreBackupFolder(const BackupFolder: string): Boolean;
  public
    procedure CancelPaperlessInstallation;
    function SelectInstallationFolder: Boolean;
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
  InstallationPathReady, NoticeAcceptedBeforeInstallation: Boolean;
  LocalInstallationSelected, ExternalInstallationSelected: Boolean;
  ApplicationClosing: Boolean;
  ShouldWriteNewCompose: Boolean;
  IsAutostart: Boolean;
  InstallationCompletedFilePath: String;
  RestoreEstimateText: string;
  RestoreEstimatedSeconds: Integer;
  RestoreProgressStartTick: UInt64;
  InstallationProgressLastTick: UInt64;
  WantsInstall: Boolean;
  IsUpdate: Boolean;
  PaperlessUpdate: Boolean;
  IsRestoreApplyingSettings: Boolean;
  TrashRetentionDays: Integer;
  ScriptBusy: Boolean;
  ScriptBusyTabIndex: Integer;
  ScriptBusyControlStates: TDictionary<TControl, Boolean>;
  InstallCancelRequested: Boolean;
  RunningScriptProcessId: DWORD;


implementation

uses ExternalStartupCheck;
{$R *.dfm}
// Eine erzeugte Skriptdatei im Windows-Dateisystem als versteckt markieren.
procedure MarkGeneratedScriptHidden(const ScriptPath: string);
var
  // Preserve all other Windows attributes when changing hidden/read-only flags.
  // Alle anderen Windows-Attribute beim Ändern von Hidden/ReadOnly erhalten.
  Attributes: DWORD;
begin
  if (ScriptPath.Trim = '') or not FileExists(ScriptPath) then Exit;
  Attributes := Winapi.Windows.GetFileAttributes(PChar(ScriptPath));
  if Attributes <> INVALID_FILE_ATTRIBUTES then
    Winapi.Windows.SetFileAttributes(PChar(ScriptPath), Attributes or FILE_ATTRIBUTE_HIDDEN);
end;
// Ein erzeugtes Einmal-Skript nach seinem Lauf löschen.
procedure DeleteGeneratedScriptFile(const ScriptPath: string);
var
  // Preserve all other Windows attributes when changing hidden/read-only flags.
  // Alle anderen Windows-Attribute beim Ändern von Hidden/ReadOnly erhalten.
  Attributes: DWORD;
begin
  if (ScriptPath.Trim = '') or not FileExists(ScriptPath) then Exit;
  try
    Attributes := Winapi.Windows.GetFileAttributes(PChar(ScriptPath));
    if Attributes <> INVALID_FILE_ATTRIBUTES then
      Winapi.Windows.SetFileAttributes(PChar(ScriptPath), Attributes and not FILE_ATTRIBUTE_READONLY);
    if not DeleteFile(ScriptPath) then
      LogWarning('Generated script could not be deleted: ' + ScriptPath);
  except
    on E: Exception do
      LogWarning('Generated script cleanup failed for "' + ScriptPath + '": ' + E.Message);
  end;
end;
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
// True zurückgeben, wenn email-versand.env bereits Maildaten des Benutzers enthaelt.
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
// True zurückgeben, wenn die vorhandene E-Mail-Env-Datei erhalten bleiben muss.
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
// Die Gesamtgroesse eines Ordnerbaums zurückgeben. Nicht lesbare Dateien werden uebersprungen.
function GetDirectorySizeBytes(const FolderPath: string): Int64;
var
  FilePath, ChildFolder: string;
  FileInfo: TSearchRec;
begin
  Result := 0;
  if not System.SysUtils.DirectoryExists(FolderPath) then Exit;
  for FilePath in TDirectory.GetFiles(FolderPath) do
  begin
    if FindFirst(FilePath, faAnyFile, FileInfo) = 0 then
    begin
      try
        Result := Result + FileInfo.Size;
      finally
        FindClose(FileInfo);
      end;
    end;
  end;
  for ChildFolder in TDirectory.GetDirectories(FolderPath) do
    Result := Result + GetDirectorySizeBytes(ChildFolder);
end;
// Eine Byte-Anzahl für sichtbare Wiederherstellungs-Schaetzungen formatieren.
function FormatByteSize(const SizeBytes: Int64): string;
const
  KB = 1024.0;
  MB = KB * 1024.0;
  GB = MB * 1024.0;
begin
  if SizeBytes >= Trunc(GB) then
    Result := FormatFloat('0.0 GB', SizeBytes / GB)
  else if SizeBytes >= Trunc(MB) then
    Result := FormatFloat('0.0 MB', SizeBytes / MB)
  else if SizeBytes >= Trunc(KB) then
    Result := FormatFloat('0.0 KB', SizeBytes / KB)
  else
    Result := IntToStr(SizeBytes) + ' Bytes';
end;
// Eine vorsichtige Schaetzung der Wiederherstellungsdauer aus der Backupgroesse bauen.
function EstimateRestoreDurationSeconds(const SizeBytes: Int64): Integer;
var
  Minutes: Integer;
begin
  if SizeBytes <= 0 then
    Exit(0);
  // Restore includes archive extraction, database import, Docker startup, and migrations.
  // Wiederherstellung umfasst Entpacken, Datenbankimport, Docker-Start und Migrationen.
  Minutes := Ceil(SizeBytes / (350.0 * 1024.0 * 1024.0)) + 3;
  if Minutes < 5 then
    Minutes := 5;
  Result := Minutes * 60;
end;
// Die sichtbare Schaetzung der Wiederherstellungsdauer bauen.
function EstimateRestoreDurationText(const SizeBytes: Int64): string;
var
  Minutes: Integer;
begin
  Result := 'unbekannt';
  if SizeBytes <= 0 then Exit;
  Minutes := Ceil(EstimateRestoreDurationSeconds(SizeBytes) / 60.0);
  if Minutes < 60 then
    Result := 'ca. ' + IntToStr(Minutes) + ' Minuten'
  else
    Result := Format('ca. %d Std. %d Min.', [Minutes div 60, Minutes mod 60]);
end;
// Read only an unambiguous literal Compose key; do not interpret YAML or Compose interpolation.
// Nur einen eindeutigen literalen Compose-Schlüssel lesen; keine YAML- oder Compose-Ausdrücke interpretieren.
function ReadLiteralComposeSecretKey(const FileName: string): string;
var
  Lines: TStringList;
  Line, RawLine, Value: string;
  Count: Integer;
begin
  Result := '';
  Count := 0;
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(FileName, TEncoding.UTF8);
    for RawLine in Lines do
    begin
      Line := Trim(RawLine);
      if not Line.StartsWith('PAPERLESS_SECRET_KEY:') then Continue;
      Inc(Count);
      Value := Trim(Copy(Line, Length('PAPERLESS_SECRET_KEY:') + 1, MaxInt));
      if (Length(Value) >= 2) and (Value[1] = '"') and (Value[Length(Value)] = '"') then
        Value := Copy(Value, 2, Length(Value) - 2)
      else if (Length(Value) >= 2) and (Value[1] = '''') and (Value[Length(Value)] = '''') then
        Value := Copy(Value, 2, Length(Value) - 2);
      if (Value = '') or (Pos('$', Value) > 0) or (Pos('#', Value) > 0) or
         (Pos('"', Value) > 0) or (Pos('''', Value) > 0) or (Pos('\', Value) > 0) then Exit('');
      Result := Value;
    end;
    if Count <> 1 then Result := '';
  finally
    Lines.Free;
  end;
end;

// Prepare the restore key; protected Compose files remain authoritative.
// Restore-Schlüssel vorbereiten; bei Dateischutz ist die Compose-Datei maßgeblich.
function ApplyPaperlessSecretKeyForRestore(const BackupFolder, RestoreComposeFile: string; out Cancelled: Boolean; out PreparedKey: string): Boolean;
var
  SecretKey, ComposeKey, SecretKeyFilePath, ProtectedComposePath: string;
  ProtectedCompose, KeyProblem: Boolean;
begin
  Result := False;
  Cancelled := False;
  PreparedKey := '';
  SecretKeyFilePath := IncludeTrailingPathDelimiter(BackupFolder) + PaperlessSecretKeyFileName;
  try
    ProtectedComposePath := RestoreComposeFile;
    ProtectedCompose := CustomFileProtected(ProtectedComposePath);
    SecretKey := '';
    KeyProblem := not FileExists(SecretKeyFilePath);
    if not KeyProblem then
    begin
      try
        SecretKey := ReadPaperlessSecretKeyFromBackupFile(SecretKeyFilePath);
        KeyProblem := SecretKey = '';
      except
        KeyProblem := True;
      end;
    end;
    if KeyProblem then
    begin
      LogWarning('Paperless secret key backup file is missing or cannot be read.');
      if ProtectedCompose then
      begin
        if CenteredMessageDlg('Es gibt ein Problem mit der Schlüsseldatei. Das Backup kann dennoch wiederhergestellt werden.' +
          sLineBreak + sLineBreak + 'Die Compose-Datei ist geschützt. Es gilt deren Schlüssel.' +
          sLineBreak + 'Wollen Sie das Backup wiederherstellen?', mtWarning, [mbYes, mbNo], 0) <> mrYes then
        begin
          Cancelled := True;
          Exit;
        end;
      end
      else if CenteredMessageDlg('Es gibt ein Problem mit der Schlüsseldatei. Das Backup kann dennoch wiederhergestellt werden.' +
        sLineBreak + sLineBreak + 'Wollen Sie das Backup mit dem Legacy-Schlüssel wiederherstellen?',
        mtWarning, [mbYes, mbNo], 0) <> mrYes then
      begin
        Cancelled := True;
        Exit;
      end;
      SecretKey := LegacyPaperlessSecretKey;
    end;
    if ProtectedCompose then
    begin
      ComposeKey := ReadLiteralComposeSecretKey(ProtectedComposePath);
      if ComposeKey = '' then
      begin
        CenteredShowMessage('Der Schlüssel der geschützten Compose-Datei konnte nicht eindeutig gelesen werden. Die Datei bleibt unverändert; die Wiederherstellung wird fortgesetzt.');
        Exit;
      end;
      if ComposeKey <> '' then
      begin
        if (not KeyProblem) and (ComposeKey <> SecretKey) then
          if CenteredMessageDlg('Der Schlüssel aus dem Backup weicht vom Schlüssel der gesperrten Compose-Datei ab. Daher wird der Schlüssel aus der Compose-Datei verwendet.' +
            sLineBreak + sLineBreak + 'Wollen Sie das Backup wiederherstellen?', mtWarning, [mbYes, mbNo], 0) <> mrYes then
          begin
            Cancelled := True;
            Exit;
          end;
        SecretKey := ComposeKey;
      end;
    end;
    PreparedKey := SecretKey;
    Result := True;
    LogInfo('Paperless secret key prepared for restore.');
  except
    on E: Exception do
    begin
      LogWarning('Paperless secret key preparation failed.');
      if CenteredMessageDlg('Der Schlüssel konnte nicht vorbereitet werden. Die Wiederherstellung kann mit der vorhandenen Konfiguration fortgesetzt werden.' +
        sLineBreak + sLineBreak + 'Wollen Sie das Backup dennoch wiederherstellen?',
        mtWarning, [mbYes, mbNo], 0) <> mrYes then
        Cancelled := True;
      Result := False;
    end;
  end;
end;
procedure SaveRestoreSecretKey(const SecretKey: string);
var
  Ini: TAppSettingsIni;
begin
  Ini := TAppSettingsIni.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
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
end;
// Only report an update result for a successful HTTP response and valid version numbers.
// Den Updatestatus nur bei erfolgreicher HTTP-Antwort und gültigen Versionsnummern anzeigen.
procedure TMainformFrm.LoadUpdateIniFile();
var
  ResponseStream: TStringStream;
  Lines: TStringList;
  Response: IHTTPResponse;
  ProgramVersion, DownloadVersion: string;
  Comparison: Integer;
begin
  ProgramVersion := GetExeVersion;
  ProgramUpdateLbl.Caption := 'Update-Status unbekannt';
  LogInfo('Checking program update. Current version: ' + ProgramVersion);
  try
    ResponseStream := TStringStream.Create;
    try
      Response := NetHTTPClient1.Get(UpdateInfoUrl, ResponseStream);
      if (Response.StatusCode < 200) or (Response.StatusCode >= 300) then
        raise Exception.CreateFmt('HTTP-Status %d', [Response.StatusCode]);
      ResponseStream.Position := 0;
      Lines := TStringList.Create;
      try
        Lines.LoadFromStream(ResponseStream, TEncoding.UTF8);
        if Lines.Count = 0 then
          raise Exception.Create('Die Versionsdatei ist leer.');
        DownloadVersion := Trim(Lines[0]);
        if not TryCompareProgramVersions(DownloadVersion, ProgramVersion, Comparison) then
          raise Exception.Create('Ungültige Versionsangabe.');
      finally
        Lines.Free;
      end;
      ResponseStream.SaveToFile(IncludeTrailingPathDelimiter(AppDataFolder) + UpdateIniFileName);
    finally
      ResponseStream.Free;
    end;
  except
    on E: Exception do
    begin
      LogWarning('Program update check failed: ' + E.Message);
      Exit;
    end;
  end;

  ProgramUpdateLbl.ParentColor := False;
  ProgramUpdateLbl.StyleElements := StyleElements - [seFont];
  ProgramUpdateLbl.Font.Color := clYellow;
  if Comparison > 0 then
  begin
    ProgramUpdateLbl.Caption := 'Update vorhanden - hier klicken';
    ProgramUpdateLbl.Font.Style := [fsBold];
    LogInfo('Program update available: ' + DownloadVersion);
  end
  else
  begin
    ProgramUpdateLbl.Caption := 'Programm aktuell';
    LogInfo('Program is up to date.');
  end;
end;

// Speichert nach erfolgreichem Installationsskript die Standardversionen und einmalig den Installationstag.
// Spätere Bestätigungen des Hinweises verändern dieses Bezugsdatum nicht.
procedure TMainformFrm.WriteStandardVersionAfterInstallation();
var
  Ini: TAppSettingsIni;
  SettingsIniPath: string;
begin
  SettingsIniPath := IncludeTrailingPathDelimiter(Mainform.AppDataFolder) + SettingsFileName;
  Ini := TAppSettingsIni.Create(SettingsIniPath);
  try
    // Erst bei erfolgreichem Installationsskript den festen Bezugstag speichern.
    if Ini.ReadDateTime('Einrichtung', 'Installationsdatum', 0) = 0 then
      Ini.WriteDateTime('Einrichtung', 'Installationsdatum', Date);
    Ini.WriteString(IniSectionVersions, IniKeyPaperlessVersion, DefaultPaperlessVersion);
    Ini.WriteString(IniSectionVersions, IniKeyPostgresVersion, DefaultPostgresVersion);
    Ini.WriteString(IniSectionVersions, IniKeyRedisVersion, DefaultRedisVersion);
    Ini.WriteString(IniSectionVersions, IniKeyGotenbergVersion, DefaultGotenbergVersion);
    Ini.WriteString(IniSectionVersions, IniKeyTikaVersion, DefaultTikaVersion);
    Ini.WriteString(IniSectionVersions, IniKeyAlpineVersion, DefaultAlpineVersion);
    Ini.WriteString(IniSectionVersions, IniKeyBusyboxVersion, DefaultBusyboxVersion);
    Ini.WriteString('Einrichtung', 'Installation abgeschlossen', 'Ja');
    Ini.UpdateFile;
  finally
    Ini.Free;
  end;
end;

// Das generierte PowerShell-Skript in einem sichtbaren Konsolenfenster öffnen.
procedure TMainformFrm.StartCmdScript;
begin
  ShellExecute(0, 'open', 'powershell.exe',
    PChar('-NoProfile -ExecutionPolicy Bypass -File "' + CmdTargetPath + '"'),
    nil, SW_SHOWNORMAL);
end;
// Run setup-form compose generation even when the notice form is not open.
// Compose-Erzeugung über das Setup-Formular ausführen, auch wenn der Hinweisdialog nicht geöffnet ist.
procedure TMainformFrm.CreateDockerComposeWithSetupForm;
var
  CreatedSetupForm: Boolean;
begin
  if ApplicationClosing or Application.Terminated then Exit;
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
// Image-Versionen schreiben, auch wenn das Setup-Formular gerade nicht geöffnet ist.
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
// Die aktive Paperless-Installation abbrechen und bereits geladene Compose-Images entfernen.
procedure TMainformFrm.CancelPaperlessInstallation;
var
  ComposeFilePath, CleanupOutput: string;
  Ini: TAppSettingsIni;
begin
  if not IsPaperlessInstallation then Exit;
  InstallCancelRequested := True;
  LogWarning('Paperless installation cancellation requested by user.');
  Ini := TAppSettingsIni.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
  try
    Ini.WriteString('Einrichtung', 'Installation abgeschlossen', 'Nein');
    Ini.UpdateFile;
  finally
    Ini.Free;
  end;
  if Assigned(SetupFrm) then
  begin
    SetupFrm.InstallLbl.Visible := True;
    SetupFrm.InstallLbl.Caption := 'Installation wird abgebrochen. Bitte warten ...';
    SetupFrm.InstallationCancelBtn.Enabled := False;
    Application.ProcessMessages;
  end;
  if RunningScriptProcessId <> 0 then
  begin
    CleanupOutput := ExecuteShellCommand('taskkill', '/PID ' + IntToStr(RunningScriptProcessId) + ' /T /F');
    if CleanupOutput.Trim <> '' then
      LogInfo('Installation process termination output: ' + CleanupOutput);
  end;
  // Do not delete volumes or images from a cancelled or repeated setup.
  // Bei abgebrochener oder wiederholter Einrichtung Volumes und Images erhalten.
  ComposeFilePath := IncludeTrailingPathDelimiter(AppDataFolder) + DockerComposeFileName;
  if FileExists(ComposeFilePath) then
  begin
    CleanupOutput := ExecuteShellCommand('docker', 'compose -f "' + ComposeFilePath + '" stop');
    if CleanupOutput.Trim <> '' then
      LogInfo('Docker compose stop output: ' + CleanupOutput);
  end;
end;
// Interaktive Steuerelemente während eines laufenden Skripts merken und sperren.
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
// Hauptformular in einen nicht interaktiven Skriptmodus versetzen.
procedure TMainformFrm.BeginScriptBusyState;
begin
  if ScriptBusy then Exit;
  ProgramUpdateLbl.Hide;
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
  OpenManualBtn.Visible := not IsAutostart;
end;
// Einen Wert für die Verwendung in einer PowerShell-Befehlszeile quoten.
function TMainformFrm.PowerShellQuote(const Value: string): string;
begin
  Result := '''' + StringReplace(Value, '''', '''''', [rfReplaceAll]) + '''';
end;
// Leert die temporäre Statusdatei vor dem Skriptlauf, damit keine Zeile eines vorherigen Laufs angezeigt wird.
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
// Erzeugt den zweistufigen powershell.exe-Wrapper für die verdeckte Prozessausführung.
// Der Wrapper schreibt die Ausgabe über Add-Content nach PowerShellStatus.log; dessen UTF-16LE-Codierung ist mit dem Leser abgestimmt.
function TMainformFrm.BuildPowerShellCommand(const ScriptPath, OutputLogPath: string): string;
begin
  Result :=
    'powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& powershell.exe -NoProfile -ExecutionPolicy Bypass -File ' +
    PowerShellQuote(ScriptPath) +
    ' 2>&1 | ForEach-Object { $_; Set-Content -LiteralPath ' +
    PowerShellQuote(OutputLogPath) +
    ' -Value ([string]$_) -Encoding Unicode }; exit $LASTEXITCODE"';
end;
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
// Show only known, non-sensitive failure descriptions from the script marker.
// Nur bekannte, nicht vertrauliche Fehlerbeschreibungen aus der Skriptmarkierung anzeigen.
function TMainformFrm.ScriptFailureMessage(const OutputLogPath: string; ExitCode: DWORD): string;
const
  Marker = 'PAPERLESS_FEHLER: ';
  KnownErrors: array[0..29] of string = (
    'Fehler beim Sichern von data', 'Fehler beim Sichern von db_data',
    'Fehler beim Sichern von export', 'Fehler beim Sichern von media',
    'Fehler beim Wiederherstellen von data', 'Fehler beim Wiederherstellen von media',
    'Fehler beim Wiederherstellen von export', 'Fehler beim Erstellen des UTF-8-PostgreSQL-Dumps im Container.',
    'Fehler beim Kopieren des PostgreSQL-Dumps in den Backupordner.', 'Fehler beim Stoppen der Container.',
    'Fehler beim Starten der Container.', 'Fehler beim Starten von Datenbank und Broker.',
    'Fehler beim Zuruecksetzen des public Schemas.', 'Fehler beim Wiederherstellen der PostgreSQL-Datenbank.',
    'Migrationsstand konnte nicht gelesen werden.', 'Erforderlicher Migrationsstand nicht erreicht. Paperless bleibt gestoppt.',
    'Unbekannter Paperless-Migrationsstand. Abbruch.', 'Migration auf die Zielversion fehlgeschlagen.',
    'Fehler beim Bereinigen nicht verwendeter Volumes.', 'Fehler beim Bereinigen nicht verwendeter Docker-Images.',
    'Docker Engine ist nicht erreichbar.', 'Docker Compose ist nicht verfügbar.',
    'Die Compose-Konfiguration ist ungültig.', 'Benötigte Datei fehlt:',
    'Containerstart fehlgeschlagen.', 'Skript-Ausfuehrungsrechte konnten nicht gesetzt werden.',
    'Fehler beim Herunterladen aktualisierter Images.', 'Fehler beim Aktualisieren der PostgreSQL Collation Version.',
    'PostgreSQL wurde innerhalb von 120 Sekunden nicht bereit.', 'Fehler: Datenbank-Dump fehlt:');
var
  Line, Detail, Known: string;
begin
  Result := 'Der Vorgang ist fehlgeschlagen. Fehlercode: ' + IntToStr(ExitCode);
  Line := ReadLastScriptOutputLine(OutputLogPath, '');
  if not Line.StartsWith(Marker) then
    Exit(Result + sLineBreak + 'Die genaue Ursache konnte nicht ermittelt werden.');
  Detail := Copy(Line, Length(Marker) + 1, MaxInt);
  for Known in KnownErrors do
    if Detail.StartsWith(Known) then
    begin
      Result := Result + sLineBreak + sLineBreak + Known;
      if IsBackup or IsUpdate or PaperlessUpdate or IsRestoreApplyingSettings then
        Result := Result + sLineBreak + sLineBreak + 'Paperless ist möglicherweise gestoppt. Bitte prüfen Sie den Zustand der Container.';
      Exit;
    end;
  Result := Result + sLineBreak + 'Die genaue Ursache konnte nicht sicher ermittelt werden.';
end;
// Shorten long script status texts for the label.
// Lange Skriptstatus-Texte für das Label kuerzen.
function TMainformFrm.ShortenScriptStatusText(const StatusText: string): string;
const
  MaxStatusTextLength = 95;
begin
  Result := StatusText.Trim;
  if Length(Result) > MaxStatusTextLength then
    Result := Copy(Result, 1, MaxStatusTextLength - 3).TrimRight + '...';
end;
// Docker-Compose-Installationsausgabe für das Setup-Formular verstaendlich machen.
function TMainformFrm.BuildInstallationStatusText(const StatusText: string): string;
var
  Text: string;
begin
  Text := StatusText.Trim;
  if Text = '' then
    Exit('Installation läuft. Bitte warten ...');
  if Text.Contains('Pulling') or Text.Contains('Downloading') or Text.Contains('Extracting') or Text.Contains('Download complete') then
    Result := 'Docker-Images werden geladen: ' + Text
  else if Text.Contains('Pulled') or Text.Contains('Downloaded newer image') then
    Result := 'Docker-Image geladen: ' + Text
  else if Text.Contains('Creating') or Text.Contains('Created') then
    Result := 'Container werden erstellt: ' + Text
  else if Text.Contains('Starting') or Text.Contains('Started') or Text.Contains('Running') then
    Result := 'Container werden gestartet: ' + Text
  else
    Result := Text;
  Result := ShortenScriptStatusText(Result);
end;
// Estimate install progress from Docker Compose status lines.
// Installationsfortschritt aus Docker-Compose-Statuszeilen grob schaetzen.
function TMainformFrm.EstimateInstallationProgressPercent(const StatusText: string; const CurrentPosition: Integer): Integer;
var
  Text: string;
begin
  Text := AnsiLowerCase(StatusText).Trim;
  Result := CurrentPosition;
  if Result < 5 then
    Result := 5;
  if Text = '' then Exit;
  if Text.Contains('pulling') then
    Result := Max(Result, 12);
  if Text.Contains('waiting') then
    Result := Max(Result, 18);
  if Text.Contains('downloading') then
    Result := Max(Result, 30);
  if Text.Contains('extracting') then
    Result := Max(Result, 55);
  if Text.Contains('download complete') then
    Result := Max(Result, 62);
  if Text.Contains('pull complete') then
    Result := Max(Result, 68);
  if Text.Contains('pulled') then
    Result := Max(Result, 74);
  if Text.Contains('creating') then
    Result := Max(Result, 80);
  if Text.Contains('created') then
    Result := Max(Result, 85);
  if Text.Contains('starting') then
    Result := Max(Result, 90);
  if Text.Contains('started') or Text.Contains('running') then
    Result := Max(Result, 95);
  if Text.Contains('systeme starten') then
    Result := Max(Result, 96);
  if Result > 96 then
    Result := 96;
end;
// Einen ungefaehren Wiederherstellungsfortschritt anhand der geschaetzten Dauer zurückgeben.
function ApproximateRestoreProgressPercent: Integer;
var
  ElapsedSeconds: Double;
begin
  Result := 0;
  if (RestoreEstimatedSeconds <= 0) or (RestoreProgressStartTick = 0) then Exit;
  ElapsedSeconds := (GetTickCount64 - RestoreProgressStartTick) / 1000.0;
  Result := Floor((ElapsedSeconds / RestoreEstimatedSeconds) * 100.0);
  if Result < 0 then
    Result := 0
  else if Result > 95 then
    Result := 95;
end;
// Clear restore estimate state after a restore is done or failed.
// Restore-Schaetzzustand nach Abschluss oder Fehler zurücksetzen.
procedure ClearRestoreProgressState;
begin
  RestoreEstimateText := '';
  RestoreEstimatedSeconds := 0;
  RestoreProgressStartTick := 0;
end;
// Den Restore-Fortschrittsbalken vor der Abschlussmeldung sichtbar auffuellen.
procedure AnimateProgressBarToComplete(const ProgressBar: TProgressBar);
var
  TargetPosition: Integer;
begin
  if not Assigned(ProgressBar) then Exit;
  if ProgressBar.Position < 0 then
    ProgressBar.Position := 0;
  TargetPosition := ProgressBar.Position;
  while TargetPosition < ProgressBar.Max do
  begin
    Inc(TargetPosition);
    if TargetPosition > ProgressBar.Max then
      TargetPosition := ProgressBar.Max;
    ProgressBar.Position := TargetPosition;
    Application.ProcessMessages;
    Sleep(125);
  end;
end;
// Die Ueberschrift oberhalb der laufenden Skriptausgabe erzeugen.
function TMainformFrm.BuildBusyWaitText(const StatusText: string): string;
begin
  if FServerBackupProgressActive then
  begin
    if FServerBackupAction = sbaInstallPaperless then
      Result := 'Paperless wird auf dem Server installiert. Bitte warten ...'
    else if FServerBackupAction = sbaDownloadBackup then
      Result := 'Backup wird heruntergeladen. Bitte warten ...'
    else if FServerBackupAction = sbaUploadBackup then
      Result := 'Backup wird zum Server gesendet. Bitte warten ...'
    else if FServerBackupAction in [sbaListBackups, sbaListRestoreBackups] then
      Result := 'Server-Backups werden gesucht. Bitte warten ...'
    else if FServerBackupAction = sbaStartRestore then
      Result := 'Server-Wiederherstellung läuft. Bitte warten ...'
    else if FServerBackupAction = sbaWatchRestore then
      Result := 'Status der Server-Wiederherstellung wird abgefragt. Bitte warten ...'
    else
      Result := 'Server-Backup läuft. Bitte warten ...';
  end
  else if StatusText.Contains('Mail-Einstellungen') then
    Result := 'Mail-Einstellungen werden angewendet. Bitte warten ...'
  else if IsBackup then
    Result := 'Backup läuft. Bitte warten ...'
  else if IsRestoreApplyingSettings then
    Result := 'Wiederherstellung läuft. Bitte warten ...'
  else if IsUpdate or PaperlessUpdate or StatusText.Contains('Update') then
    // Show the update installation status for the settings update workflow.
    // Beim Update über die Einstellungen den passenden Installationsstatus anzeigen.
    Result := 'Update wird installiert. Bitte warten ...'
  else if IsPaperlessInstallation then
    Result := 'Installation läuft. Bitte warten ...'
  else if StatusText.Contains('Neustart') then
    Result := 'Neustart läuft. Bitte warten ...'
  else
    Result := 'Wiederherstellung läuft. Bitte warten ...';
end;
// Die Statusanzeige für laufende Skripte in der Anwendung vorbereiten.
procedure TMainformFrm.PrepareScriptProgress(const StatusText: string);
begin
  if not FServerBackupProgressActive and IsPaperlessInstallation and Assigned(SetupFrm) then
  begin
    SetupFrm.PaperlessInstallierenBtn.Enabled := False;
    SetupFrm.InstallLbl.Visible := True;
    SetupFrm.InstallLbl.AutoSize := False;
    SetupFrm.InstallLbl.Caption := BuildInstallationStatusText(StatusText);
    SetupFrm.ProgressBar2.Min := 0;
    SetupFrm.ProgressBar2.Max := 100;
    SetupFrm.ProgressBar2.Position := EstimateInstallationProgressPercent(StatusText, 0);
    InstallationProgressLastTick := GetTickCount64;
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
  BackupWiederherProgNeuStartLbl.Caption := StatusText.Trim;
  ProgressBar1.Min := 0;
  ProgressBar1.Max := 100;
  if not FServerBackupProgressActive and (RestoreEstimatedSeconds > 0) and
     ((RestoreEstimateText.Trim <> '') or IsRestoreApplyingSettings) then
  begin
    if RestoreProgressStartTick = 0 then
      RestoreProgressStartTick := GetTickCount64;
    ProgressBar1.Position := ApproximateRestoreProgressPercent;
  end
  else
    ProgressBar1.Position := 0;
  ProgressBar1.Visible := True;
  if not FServerBackupProgressActive then Application.ProcessMessages;
end;
// Das Statuslabel aktualisieren und die Fortschrittsanzeige während eines Skripts bewegen.
procedure TMainformFrm.UpdateScriptProgress(const StatusText: string);
var
  NewInstallProgress: Integer;
begin
  if not FServerBackupProgressActive and IsPaperlessInstallation and Assigned(SetupFrm) then
  begin
    SetupFrm.InstallLbl.Visible := True;
    SetupFrm.InstallLbl.Caption := BuildInstallationStatusText(StatusText);
    NewInstallProgress := EstimateInstallationProgressPercent(StatusText, SetupFrm.ProgressBar2.Position);
    if NewInstallProgress > SetupFrm.ProgressBar2.Position then
    begin
      SetupFrm.ProgressBar2.Position := NewInstallProgress;
      InstallationProgressLastTick := GetTickCount64;
    end
    else if (SetupFrm.ProgressBar2.Position < 96) and
            (GetTickCount64 - InstallationProgressLastTick >= 2500) then
    begin
      SetupFrm.ProgressBar2.Position := SetupFrm.ProgressBar2.Position + 1;
      InstallationProgressLastTick := GetTickCount64;
    end;
    Application.ProcessMessages;
    Exit;
  end;
  BackupWiederherProgNeuStartLbl.Visible := True;
  if not FServerBackupProgressActive and (RestoreEstimatedSeconds > 0) and
     ((RestoreEstimateText.Trim <> '') or IsRestoreApplyingSettings) then
  begin
    ProgressBar1.Position := ApproximateRestoreProgressPercent;
    BackupWiederherProgNeuStartLbl.Caption := StatusText.Trim;
  end
  else
  begin
    BackupWiederherProgNeuStartLbl.Caption := StatusText.Trim;
    if ProgressBar1.Position >= ProgressBar1.Max then
      ProgressBar1.Position := ProgressBar1.Min
    else
      ProgressBar1.Position := ProgressBar1.Position + 2;
  end;
  if not FServerBackupProgressActive then Application.ProcessMessages;
end;
// Die Statusanzeige für laufende Skripte abschliessen.
procedure TMainformFrm.FinishScriptProgress(const StatusText: string; const Success: Boolean);
var
  RestoreProgress: Boolean;
begin
  RestoreProgress := not FServerBackupProgressActive and (RestoreEstimatedSeconds > 0);
  if not FServerBackupProgressActive and IsPaperlessInstallation and Assigned(SetupFrm) then
  begin
    SetupFrm.PaperlessInstallierenBtn.Enabled := True;
    SetupFrm.InstallationCancelBtn.Visible := False;
    SetupFrm.InstallationCancelBtn.Enabled := False;
    SetupFrm.InstallLbl.Visible := True;
    SetupFrm.InstallLbl.Caption := ShortenScriptStatusText(StatusText);
    if Success then
      AnimateProgressBarToComplete(SetupFrm.ProgressBar2)
    else
      SetupFrm.ProgressBar2.Position := SetupFrm.ProgressBar2.Min;
    Application.ProcessMessages;
    Exit;
  end;
  if not FServerBackupProgressActive and not (Success and RestoreProgress) then
  begin
    EndScriptBusyState;
    StartPaperlessBackupBtn.Enabled := True;
    RestorePaperlessBackupBtn.Enabled := True;
  end;
  BackupWiederherProgNeuStartLbl.Visible := True;
  if Success and RestoreProgress then
    BackupWiederherProgNeuStartLbl.Caption := 'Wiederherstellung wird abgeschlossen. Bitte warten ...'
  else
    BackupWiederherProgNeuStartLbl.Caption := StatusText.Trim;
  if Success then
  begin
    if RestoreProgress then
    begin
      AnimateProgressBarToComplete(ProgressBar1);
      BackupWiederherProgNeuStartLbl.Caption := StatusText.Trim;
      EndScriptBusyState;
      StartPaperlessBackupBtn.Enabled := True;
      RestorePaperlessBackupBtn.Enabled := True;
    end
    else
      ProgressBar1.Position := ProgressBar1.Max;
  end
  else
    ProgressBar1.Position := ProgressBar1.Min;
  if not FServerBackupProgressActive then Application.ProcessMessages;
end;
// Wartet auf das Prozessende und aktualisiert die Oberfläche aus der letzten Statuszeile.
// Application.ProcessMessages hält die GUI bedienbar und erlaubt dabei Reentranz; Abschlussmeldungen benötigen weiterhin den Exitcode.
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
// Prepare a private mail snapshot for this run and refresh the scheduled copy atomically.
// Eine eigene Mailkopie für diesen Lauf vorbereiten und die geplante Kopie atomar ersetzen.
function TMainformFrm.EncryptEmailEnvForBackup(out EncryptedMailPath: string): Boolean;
var
  SourceEnvPath, LocalEncryptedPath, LocalStage, Password: string;
  PasswordResult: Integer;
begin
  EncryptedMailPath := '';
  Result := True;
  SourceEnvPath := IncludeTrailingPathDelimiter(AppDataFolder) + EmailEnvFileName;
  if not FileExists(SourceEnvPath) then Exit;
  PasswordResult := RequestPasswordDialog(
    'Mail-Einstellungen verschlüsseln',
    'Die Datei email-versand.env enthält Mailkontodaten und wird für das Backup verschlüsselt.' + sLineBreak + sLineBreak +
    'Bitte bewahren Sie Ihr Passwort sicher auf, z.B. in KeePass. Wenn Sie das Passwort verlieren, kann die Mail-Einstellungsdatei nicht wiederhergestellt werden.',
    True, Password, 'Backup ohne Mail-Einstellungen durchführen');
  if PasswordResult = mrIgnore then
  begin
    LogInfo('Encrypted email env backup skipped by user.');
    Exit;
  end;
  if PasswordResult <> mrOk then Exit(False);
  EncryptedMailPath := TPath.Combine(AppDataFolder, TPath.GetRandomFileName);
  LocalEncryptedPath := TPath.Combine(AppDataFolder, EmailEnvEncryptedFileName);
  LocalStage := TPath.Combine(AppDataFolder, TPath.GetRandomFileName);
  try
    try
      EncryptFileWithPassword(SourceEnvPath, EncryptedMailPath, Password);
      TFile.Copy(EncryptedMailPath, LocalStage, False);
      if not Winapi.Windows.MoveFileEx(PChar(LocalStage), PChar(LocalEncryptedPath),
        MOVEFILE_REPLACE_EXISTING or MOVEFILE_WRITE_THROUGH) then RaiseLastOSError;
    except
      on E: Exception do
      begin
        System.SysUtils.DeleteFile(EncryptedMailPath);
        EncryptedMailPath := '';
        Result := CenteredMessageDlg('Mail-Einstellungen konnten nicht verschlüsselt oder gespeichert werden: ' +
          E.Message + sLineBreak + 'Backup ohne Mail-Einstellungen fortsetzen?', mtWarning, [mbYes, mbNo], 0) = mrYes;
      end;
    end;
  finally
    if FileExists(LocalStage) then System.SysUtils.DeleteFile(LocalStage);
  end;
end;
// Verschluesselte Mail-Einstellungen aus dem Backup wiederherstellen, wenn der Benutzer das Passwort eingibt.
function TMainformFrm.RestoreEmailEnvFromBackup(const SourceBackupPath: string; out MailBytes: TBytes; out HasMail: Boolean): Boolean;
var
  SourceEncryptedPath, Password: string;
  PasswordResult: Integer;
begin
  Result := True;
  HasMail := False;
  MailBytes := nil;
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
    CenteredShowMessage('Wiederherstellung abgebrochen.');
    Exit(False);
  end;
  try
    MailBytes := DecryptBytesWithPassword(TFile.ReadAllBytes(SourceEncryptedPath), Password);
    HasMail := True;
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
      CenteredShowMessage('Wiederherstellung abgebrochen.');
      Result := False;
    end;
  end;
end;
// Prüft den vollständigen aktuellen Dateisatz; nur bei vollständigem Legacy-Satz wird nach Rückfrage auf alte Quellnamen umgeschaltet.
// Dateinamen belegen keine tatsächliche PostgreSQL-Version. FRestoreLegacyNames steuert nur die Auswahl der Backupquellen.
function TMainformFrm.ValidateRestoreBackupFolder(const BackupFolder: string): Boolean;
var
  MissingFiles: TStringList;
  BasePath: string;
  // Require one file inside the selected backup folder.
  // Eine Datei innerhalb des gewählten Backup-Ordners verlangen.
  procedure RequireFile(const FileName: string);
  begin
    if not FileExists(BasePath + FileName) then
      MissingFiles.Add(FileName);
  end;
begin
  Result := False;
  FRestoreLegacyNames := False;
  if not System.SysUtils.DirectoryExists(BackupFolder) then
  begin
    CenteredShowMessage('Der gewählte Backup-Ordner existiert nicht.');
    LogWarning('Restore precheck failed. Backup folder does not exist: ' + BackupFolder);
    Exit;
  end;
  BasePath := IncludeTrailingPathDelimiter(BackupFolder);
  MissingFiles := TStringList.Create;
  try
    RequireFile(ComposeProjectName + '-db-1_backup.sql');
    RequireFile(ComposeProjectName + '_data.tar.gz');
    RequireFile(ComposeProjectName + '_media.tar.gz');
    RequireFile(ComposeProjectName + '_export.tar.gz');
    if MissingFiles.Count > 0 then
    begin
      if FileExists(BasePath + 'paperless-ngx-db-1_backup.sql') and
         FileExists(BasePath + 'paperless-ngx_data.tar.gz') and
         FileExists(BasePath + 'paperless-ngx_media.tar.gz') and
         FileExists(BasePath + 'paperless-ngx_export.tar.gz') then
      begin
        if CenteredMessageDlg(
          'Dieses Backup stammt aus einer älteren Paperless-Version mit der PostgreSQL-Datenbank 17.' +
          sLineBreak + sLineBreak + 'Dennoch einspielen?',
          mtConfirmation, [mbYes, mbNo], 0) = mrYes then
        begin
          FRestoreLegacyNames := True;
          Result := True;
          LogInfo('Legacy backup filenames accepted for restore into PG18 project.');
        end;
        Exit;
      end;
      CenteredShowMessage('Der gewählte Backup-Ordner ist unvollständig. Die Wiederherstellung wurde nicht gestartet.' +
        sLineBreak + sLineBreak + 'Fehlende Dateien:' + sLineBreak + MissingFiles.Text);
      LogWarning('Restore precheck failed. Missing files in "' + BackupFolder + '": ' + StringReplace(MissingFiles.CommaText, ',', ', ', [rfReplaceAll]));
      Exit;
    end;
  finally
    MissingFiles.Free;
  end;
  Result := True;
end;
// Die Unterstützungsseite im Standardbrowser öffnen.
procedure TMainformFrm.BuyMeACoffeeBtnClick(Sender: TObject);
begin
  ProgramUpdateLbl.Hide;
  ShellExecute(0, 'open', BuyMeACoffeeUrl, nil, nil, SW_SHOWNORMAL);
end;

// Apply the Compose protection to the settings fields while keeping Save available.
// Compose-Schutz auf die Einstellungsfelder anwenden; Speichern bleibt verfügbar.
procedure TMainformFrm.UpdateComposeProtectionControls;
begin
  PapierkorbAufbewahrungEdit.Enabled := not ProtectCustomFilesCB.Checked;
  CheckBox1.Enabled := not ProtectCustomFilesCB.Checked;
  CheckBox1Click(nil);
end;

// Confirm enabling manual maintenance; on disabling, confirm and finish a backup first.
// Eigene Dateipflege beim Aktivieren bestätigen; beim Deaktivieren zuerst bestätigen und sichern.
procedure TMainformFrm.ProtectCustomFilesCBClick(Sender: TObject);
var
  BackupFolder: string;
begin
  if LocalInstallationSelected and FLocalStartupPending then
  begin
    CenteredShowMessage('Bitte das Programm neu starten, um die lokale Installation vorzubereiten.');
    Exit;
  end;
  // Ignore programmatic changes while restoring saved or rejected selections.
  // Programmatische Änderungen beim Laden oder Zurücksetzen der Auswahl ignorieren.
  if FLoadingCustomFileProtection then Exit;
  if not ProtectCustomFilesCB.Checked then
  begin
    // Explain the backup destination before unlocking or copying custom files.
    // Sicherungsziel vor dem Entsperren oder Kopieren eigener Dateien erläutern.
    if CenteredMessageDlg(
      'Beim Aufheben des Compose-Schutzes werden vorhandene Compose-Dateien, ' +
      'Skriptdateien im Installationsordner und der Ordner scripts gesichert.' +
      sLineBreak + sLineBreak +
      'Das Backup wird in einem eigenen Unterordner dieses Ordners abgelegt:' + sLineBreak +
      IncludeTrailingPathDelimiter(AppDataFolder) + 'Eigene Bearbeitungen Backup' +
      sLineBreak + sLineBreak +
      'Ältere Sicherungen bleiben erhalten.' +
      sLineBreak + sLineBreak +
      'Nach erfolgreicher Sicherung und „Einstellungen Speichern“ kann das Programm die ' +
      'Compose-Datei wieder überschreiben.' + sLineBreak + sLineBreak +
      'Möchten Sie die Dateien sichern und den Compose-Schutz aufheben?',
      mtWarning, [mbYes, mbNo], 0) <> mrYes then
    begin
      FLoadingCustomFileProtection := True;
      try
        ProtectCustomFilesCB.Checked := True;
      finally
        FLoadingCustomFileProtection := False;
      end;
      UpdateComposeProtectionControls;
      Exit;
    end;
    try
      // Finish the copy before saving settings can permit overwriting files.
      // Kopieren abschließen, bevor gespeicherte Einstellungen Überschreiben erlauben.
      BackupFolder := BackupCustomFiles(AppDataFolder);
    except
      on E: Exception do
      begin
        // Keep protection on after any copy failure; retain partial backups for inspection.
        // Nach jedem Kopierfehler Schutz erhalten; Teilsicherungen zur Prüfung behalten.
        FLoadingCustomFileProtection := True;
        try
          ProtectCustomFilesCB.Checked := True;
        finally
          FLoadingCustomFileProtection := False;
        end;
        UpdateComposeProtectionControls;
        CenteredMessageDlg('Die eigenen Bearbeitungen konnten nicht vollständig gesichert werden.' +
          sLineBreak + 'Die Sperre bleibt aktiviert.' + sLineBreak + sLineBreak + E.Message,
          mtError, [mbOK], 0);
        Exit;
      end;
    end;
    // Copying itself does not persist the unlocked state or start Docker.
    // Das Kopieren speichert die Freigabe noch nicht und startet Docker nicht.
    CenteredMessageDlg('Die vorhandenen Dateien wurden gesichert unter:' + sLineBreak +
      BackupFolder + sLineBreak + sLineBreak +
      'Mit „Einstellungen Speichern“ übernehmen Sie die aufgehobene Sperre.',
      mtInformation, [mbOK], 0);
    UpdateComposeProtectionControls;
    Exit;
  end;
  if CenteredMessageDlg(
    'Eine vorhandene Compose-Datei wird vom Programm nicht mehr überschrieben. ' +
    'Änderungen an Einstellungen und Imageversionen müssen Sie dort selbst eintragen.' +
    sLineBreak + sLineBreak +
    'Vom Programm erzeugte Skripte werden weiterhin aktualisiert. Vorhandene eigene ' +
    'Dateien im Ordner scripts bleiben wie bisher erhalten.' + sLineBreak + sLineBreak +
    'Beim Entfernen der Sperre werden Compose-Dateien, Skripte im Installationsordner ' +
    'und der Ordner scripts zunächst gesichert. Die Auswahl wird mit ' +
    '„Einstellungen Speichern“ übernommen.' + sLineBreak + sLineBreak +
    'Möchten Sie die Compose-Datei für eigene Bearbeitung sperren?',
    mtWarning, [mbYes, mbNo], 0) <> mrYes then
  begin
    // Declining activation is not an unlock and must not create a backup.
    // Abgelehnte Aktivierung ist kein Entsperren und erzeugt keine Sicherung.
    FLoadingCustomFileProtection := True;
    try
      ProtectCustomFilesCB.Checked := False;
    finally
      FLoadingCustomFileProtection := False;
    end;
  end;
  UpdateComposeProtectionControls;
end;

// Manuelle Bearbeitung der Docker-Image-Versionen aktivieren oder deaktivieren.
// Keep both selection flags consistent without changing either installation.
// Beide Auswahlvariablen synchron halten, ohne Installationen zu veraendern.
// The enabled panels display the hint even when Windows skips the disabled button.
// Die aktiven Rahmen zeigen den Hinweis auch dann, wenn Windows den deaktivierten Button überspringt.
procedure TMainformFrm.UpdateServerBackupButtons;
var
  LocalMode, ServerMode: Boolean;
begin
  LocalMode := LocalInstallationSelected and not ExternalInstallationSelected;
  ServerMode := ExternalInstallationSelected and not LocalInstallationSelected;
  LoadServerBackupBtn.Enabled := ServerMode and not ScriptBusy and not FServerBackupCheckActive;
  SendServerBackupBtn.Enabled := LoadServerBackupBtn.Enabled;
  InstallServerPaperlessBtn.Visible := ServerMode;
  InstallServerPaperlessBtn.Enabled := LoadServerBackupBtn.Enabled and (FStartupCheckHandle = 0);
  LoadServerBackupHintPan.ShowHint := LocalMode;
  SendServerBackupHintPan.ShowHint := LocalMode;
end;

// Update the headers without changing the selected profile.
// Die Kopfzeilen aktualisieren, ohne das Profil zu veraendern.
procedure TMainformFrm.UpdateInstallationModeHeaders;
var
  HeaderText: string;
begin
  UpdateServerBackupButtons;
  if ExternalInstallationSelected then
  begin
    HeaderText := 'Paperless Backup Programm - Server';
    if (FExternalConnectionHeader = 'verbunden') or
       (FExternalConnectionHeader = 'nicht verbunden') then
      HeaderText := HeaderText + ' ' + FExternalConnectionHeader
    else if FExternalConnectionHeader <> '' then
      HeaderText := HeaderText + ' - ' + FExternalConnectionHeader;
  end
  else
    HeaderText := 'Paperless Backup Programm - Lokal';
  Label1.Caption := HeaderText;
  Label8.Caption := HeaderText;
  Label5.Caption := HeaderText;
  Label2.Caption := HeaderText;
  Label27.Caption := HeaderText;
  Label25.Caption := HeaderText;
end;

// Load the selected profile before any installation-specific startup actions.
// Das ausgewaehlte Profil vor installationsbezogenen Startaktionen laden.
procedure TMainformFrm.LoadStoredInstallationMode;
var
  Ini: TAppSettingsIni;
  Mode: string;
begin
  if SameText(ParamStr(1), '/geplant') then Exit;
  Ini := TAppSettingsIni.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
  try
    Mode := Ini.ReadString('Paperless Extern', 'Betriebsart', 'Lokal');
  finally
    Ini.Free;
  end;
  if SameText(Mode, 'Extern') then
  begin
    InstallationModeRadioGroup.ItemIndex := 1;
    ExternalInstallationSelected := True;
    LocalInstallationSelected := False;
    FLocalStartupPending := True;
  end
  else if not SameText(Mode, 'Lokal') then
    raise Exception.Create('Unbekannte Betriebsart in der Einstellungen.ini.');
end;

// Check the registered local installation without starting Docker.
// Die registrierte lokale Installation ohne Dockerstart pruefen.
function TMainformFrm.LocalInstallationAvailable: Boolean;
var
  Ini: TAppSettingsIni;
  LocalCompose: string;
begin
  Result := False;
  if not InstallationPathReady or not DirectoryExists(AppDataFolder) then Exit;
  Ini := TAppSettingsIni.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
  try
    if not SameText(Ini.ReadString('Einrichtung', 'Installation abgeschlossen', ''), 'Ja') then Exit;
    LocalCompose := Ini.ReadString('Pfade', 'DockerComposePfad', '').Trim;
    Result := (LocalCompose <> '') and FileExists(LocalCompose);
  finally
    Ini.Free;
  end;
end;

// Prepare an existing local installation without starting Docker or running setup.
// Eine vorhandene lokale Installation ohne Dockerstart oder Setup vorbereiten.
procedure TMainformFrm.PrepareLocalAfterExternalStart;
var
  Ini: TAppSettingsIni;
  LocalCompose, Installed: string;
begin
  if not InstallationPathReady or not DirectoryExists(AppDataFolder) then
    raise Exception.Create('Der lokale Installationsordner ist nicht verfügbar.');
  Ini := TAppSettingsIni.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
  try
    Installed := Ini.ReadString('Einrichtung', 'Installation abgeschlossen', '');
    LocalCompose := Ini.ReadString('Pfade', 'DockerComposePfad', '').Trim;
  finally
    Ini.Free;
  end;
  if (Installed <> 'Ja') or
     FileExists(IncludeTrailingPathDelimiter(AppDataFolder) + ComposePathFileName) or
     FileExists(IncludeTrailingPathDelimiter(AppDataFolder) + BackupTargetFileName) or
     FileExists(IncludeTrailingPathDelimiter(AppDataFolder) + InstallationCompletedFileName) then
    raise Exception.Create('Die lokale Installation benoetigt eine gesonderte Startvorbereitung. Der Wechsel wurde abgebrochen.');
  if (LocalCompose = '') or not FileExists(LocalCompose) then
    raise Exception.Create('Die lokale Compose-Datei wurde nicht gefunden.');
  InitLogger(AppDataFolder);
  EnsurePaperlessScripts(AppDataFolder);
  if not DirectoryExists(PaperlessInput) and not ForceDirectories(PaperlessInput) then
    raise Exception.Create('Der lokale Eingabeordner konnte nicht angelegt werden.');
  DefaultFolder := IncludeTrailingPathDelimiter(GetEnvironmentVariable('USERPROFILE')) + 'Desktop\' + PaperlessBackupFolderName;
  if not DirectoryExists(DefaultFolder) and not ForceDirectories(DefaultFolder) then
    raise Exception.Create('Der lokale Backupordner konnte nicht angelegt werden.');
  SaveEmptyEnvFile;
  ComposePath := LocalCompose;
  NewComposePath := LocalCompose;
  ComposeName := ExtractFileName(ExcludeTrailingPathDelimiter(ComposePath));
  BackupTargetFilePath := IncludeTrailingPathDelimiter(AppDataFolder) + BackupTargetFileName;
  StartPaperlessBackupBtn.Enabled := True;
  RestorePaperlessBackupBtn.Enabled := True;
  BackupWiederherProgNeuStartLbl.Visible := False;
end;

procedure TMainformFrm.CaptureVersionSnapshot;
begin
  FVersionSnapshot[0] := paperless_version_edit.Text;
  FVersionSnapshot[1] := redis_version_edit.Text;
  FVersionSnapshot[2] := postgres_version_edit.Text;
  FVersionSnapshot[3] := gotenberg_version_edit.Text;
  FVersionSnapshot[4] := tika_version_edit.Text;
  FVersionSnapshot[5] := alpine_version_edit.Text;
  FVersionSnapshot[6] := busybox_version_edit.Text;
end;

function TMainformFrm.VersionsChanged: Boolean;
begin
  Result := (FVersionSnapshot[0] <> paperless_version_edit.Text) or
    (FVersionSnapshot[1] <> redis_version_edit.Text) or
    (FVersionSnapshot[2] <> postgres_version_edit.Text) or
    (FVersionSnapshot[3] <> gotenberg_version_edit.Text) or
    (FVersionSnapshot[4] <> tika_version_edit.Text) or
    (FVersionSnapshot[5] <> alpine_version_edit.Text) or
    (FVersionSnapshot[6] <> busybox_version_edit.Text);
end;

// External versions stay separate; unknown server versions have no assumed defaults.
// Externe Versionen bleiben getrennt; unbekannte Serverversionen erhalten keine Vorgaben.
procedure TMainformFrm.LoadVersionsForMode(ExternalMode: Boolean);
var
  Ini: TAppSettingsIni;
  Section: string;
  Values: array[0..6] of string;
begin
  Section := IniSectionVersions;
  if ExternalMode then Section := 'Versionen Extern';
  Ini := TAppSettingsIni.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
  try
    Values[0] := Ini.ReadString(Section, IniKeyPaperlessVersion, '');
    Values[1] := Ini.ReadString(Section, IniKeyRedisVersion, '');
    Values[2] := Ini.ReadString(Section, IniKeyPostgresVersion, '');
    Values[3] := Ini.ReadString(Section, IniKeyGotenbergVersion, '');
    Values[4] := Ini.ReadString(Section, IniKeyTikaVersion, '');
    Values[5] := Ini.ReadString(Section, IniKeyAlpineVersion, '');
    Values[6] := Ini.ReadString(Section, IniKeyBusyboxVersion, '');
  finally
    Ini.Free;
  end;
  if not ExternalMode then
  begin
    if Values[0] = '' then Values[0] := DefaultPaperlessVersion;
    if Values[1] = '' then Values[1] := DefaultRedisVersion;
    if Values[2] = '' then Values[2] := DefaultPostgresVersion;
    if Values[3] = '' then Values[3] := DefaultGotenbergVersion;
    if Values[4] = '' then Values[4] := DefaultTikaVersion;
    if Values[5] = '' then Values[5] := DefaultAlpineVersion;
    if Values[6] = '' then Values[6] := DefaultBusyboxVersion;
  end;
  paperless_version_edit.Text := Values[0];
  redis_version_edit.Text := Values[1];
  postgres_version_edit.Text := Values[2];
  gotenberg_version_edit.Text := Values[3];
  tika_version_edit.Text := Values[4];
  alpine_version_edit.Text := Values[5];
  busybox_version_edit.Text := Values[6];
  CaptureVersionSnapshot;
end;

procedure TMainformFrm.SaveVersionsForMode(ExternalMode: Boolean);
var
  Ini: TAppSettingsIni;
  Section: string;
begin
  Section := IniSectionVersions;
  if ExternalMode then Section := 'Versionen Extern';
  Ini := TAppSettingsIni.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
  try
    Ini.WriteString(Section, IniKeyPaperlessVersion, paperless_version_edit.Text);
    Ini.WriteString(Section, IniKeyRedisVersion, redis_version_edit.Text);
    Ini.WriteString(Section, IniKeyPostgresVersion, postgres_version_edit.Text);
    Ini.WriteString(Section, IniKeyGotenbergVersion, gotenberg_version_edit.Text);
    Ini.WriteString(Section, IniKeyTikaVersion, tika_version_edit.Text);
    Ini.WriteString(Section, IniKeyAlpineVersion, alpine_version_edit.Text);
    Ini.WriteString(Section, IniKeyBusyboxVersion, busybox_version_edit.Text);
  finally
    Ini.Free;
  end;
  CaptureVersionSnapshot;
end;

// Preserve unsaved version edits or cancel before switching profiles.
// Ungespeicherte Versionsaenderungen vor dem Profilwechsel behandeln.
procedure TMainformFrm.InstallationModeRadioGroupClick(Sender: TObject);
var
  NewExternal: Boolean;
  Choice: Integer;
  Ini: TAppSettingsIni;
  OldValues: array[0..6] of string;
  OldSnapshot: array[0..6] of string;
  I: Integer;
begin
  if FChangingInstallationMode then Exit;
  NewExternal := InstallationModeRadioGroup.ItemIndex = 1;
  if not FVersionsReady then
  begin
    ExternalInstallationSelected := NewExternal;
    LocalInstallationSelected := not NewExternal;
    Exit;
  end;
  if NewExternal = ExternalInstallationSelected then Exit;
  // Refuse a local switch before asking to save or changing any profile data.
  // Vor Speichern oder Profilwechsel eine fehlende lokale Installation abfangen.
  if not NewExternal then
  begin
    try
      if not LocalInstallationAvailable then
      begin
        FChangingInstallationMode := True;
        try
          InstallationModeRadioGroup.ItemIndex := 1;
        finally
          FChangingInstallationMode := False;
        end;
        CenteredMessageDlg('Es wurde keine vollständige lokale Installation mit Compose-Datei gefunden. Der Wechsel ist nicht möglich.', mtWarning, [mbOK], 0);
        Exit;
      end;
    except
      on E: Exception do
      begin
        FChangingInstallationMode := True;
        try
          InstallationModeRadioGroup.ItemIndex := 1;
        finally
          FChangingInstallationMode := False;
        end;
        CenteredMessageDlg('Die lokale Installation konnte nicht geprüft werden: ' + E.Message, mtWarning, [mbOK], 0);
        Exit;
      end;
    end;
  end;
  OldValues[0] := paperless_version_edit.Text;
  OldValues[1] := redis_version_edit.Text;
  OldValues[2] := postgres_version_edit.Text;
  OldValues[3] := gotenberg_version_edit.Text;
  OldValues[4] := tika_version_edit.Text;
  OldValues[5] := alpine_version_edit.Text;
  OldValues[6] := busybox_version_edit.Text;
  for I := 0 to 6 do OldSnapshot[I] := FVersionSnapshot[I];
  try
    if VersionsChanged then
    begin
      Choice := CenteredMessageDlg('Die Imageversionen wurden geändert. Vor dem Wechsel speichern?',
        mtConfirmation, [mbYes, mbNo, mbCancel], 0);
      if (Choice <> mrYes) and (Choice <> mrNo) then
      begin
        FChangingInstallationMode := True;
        try
          if ExternalInstallationSelected then InstallationModeRadioGroup.ItemIndex := 1
          else InstallationModeRadioGroup.ItemIndex := 0;
        finally
          FChangingInstallationMode := False;
        end;
        Exit;
      end;
      if Choice = mrYes then SaveVersionsForMode(ExternalInstallationSelected);
    end;
    if not NewExternal and FLocalStartupPending then
      PrepareLocalAfterExternalStart;
    LoadVersionsForMode(NewExternal);
    Ini := TAppSettingsIni.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
    try
      if NewExternal then Ini.WriteString('Paperless Extern', 'Betriebsart', 'Extern')
      else Ini.WriteString('Paperless Extern', 'Betriebsart', 'Lokal');
    finally
      Ini.Free;
    end;
    ExternalInstallationSelected := NewExternal;
    LocalInstallationSelected := not NewExternal;
    CancelExternalStartupCheck;
    FExternalConnectionHeader := 'nicht verbunden';
    if LocalInstallationSelected then FLocalStartupPending := False;
    UpdateInstallationModeHeaders;
    ProtectCustomFilesCB.Enabled := LocalInstallationSelected and not FLocalStartupPending;
    PapierkorbAufbewahrungEdit.Enabled := LocalInstallationSelected and not ProtectCustomFilesCB.Checked;
    CheckBox1.Enabled := ExternalInstallationSelected or not ProtectCustomFilesCB.Checked;
    CheckBox1Click(nil);
    CheckScheduleAllowed;
    SettingsSavedLbl.Visible := False;
    if LocalInstallationSelected and FLocalStartupPending then
      CenteredShowMessage('Bitte das Programm neu starten, um die lokale Installation vorzubereiten.');
  except
    on E: Exception do
    begin
      paperless_version_edit.Text := OldValues[0];
      redis_version_edit.Text := OldValues[1];
      postgres_version_edit.Text := OldValues[2];
      gotenberg_version_edit.Text := OldValues[3];
      tika_version_edit.Text := OldValues[4];
      alpine_version_edit.Text := OldValues[5];
      busybox_version_edit.Text := OldValues[6];
      for I := 0 to 6 do FVersionSnapshot[I] := OldSnapshot[I];
      FChangingInstallationMode := True;
      try
        if ExternalInstallationSelected then InstallationModeRadioGroup.ItemIndex := 1
        else InstallationModeRadioGroup.ItemIndex := 0;
      finally
        FChangingInstallationMode := False;
      end;
      CenteredShowMessage('Die Imageversionen konnten nicht gewechselt oder gespeichert werden: ' + E.Message);
    end;
  end;
end;

// Accept existing explicit YAML filenames while using the standard file for folders.
// Bestehende YAML-Dateinamen erhalten, bei Ordnern den Standarddateinamen ergaenzen.
function ExternalComposeDirectory(const Value: string): string;
const
  StandardName = 'docker-compose.yml';
var
  Suffix: string;
begin
  Result := Value;
  Suffix := '/' + StandardName;
  if (Length(Result) >= Length(Suffix)) and
     (Copy(Result, Length(Result) - Length(Suffix) + 1, Length(Suffix)) = Suffix) then
  begin
    Delete(Result, Length(Result) - Length(Suffix) + 1, Length(Suffix));
    if Result = '' then Result := '/';
  end;
end;

function ExternalComposeFile(const Value: string): string;
var
  LowerValue: string;
begin
  Result := Value;
  if Result = '' then Exit;
  LowerValue := LowerCase(Result);
  if (Copy(LowerValue, Length(LowerValue) - 3, 4) = '.yml') or
     (Copy(LowerValue, Length(LowerValue) - 4, 5) = '.yaml') then Exit;
  if Result[Length(Result)] <> '/' then Result := Result + '/';
  Result := Result + 'docker-compose.yml';
end;

// Ask the background check to stop before another prompt or saved-key change.
// Bei Profilaenderung oder Programmende keinen veralteten Test fortsetzen.
procedure TMainformFrm.CancelExternalStartupCheck;
begin
  FStartupCheckInvalidated := True;
  if (FStartupCheckHandle <> 0) and (FStartupCheckResultPath <> '') and
     (WaitForSingleObject(FStartupCheckHandle, 0) = WAIT_TIMEOUT) then
    try
      TFile.WriteAllText(FStartupCheckResultPath + '.cancel', '', TEncoding.UTF8);
    except
      // The result is still ignored if the temporary marker cannot be written.
      // Das Ergebnis wird auch ohne Abbruchdatei nicht mehr uebernommen.
    end;
end;

// Start one asynchronous SSH check using the loaded server profile.
// Eine asynchrone SSH-Pruefung mit dem geladenen Serverprofil starten.
procedure TMainformFrm.BeginExternalStartupCheck(ConfirmFingerprint: Boolean;
  const InstallHost: string);
var
  Ini: TAppSettingsIni;
  Host, UserName, KeyFile, SettingsPath, PortText: string;
  PortNumber: Integer;
  Ch: Char;
  UseKey: Boolean;
begin
  if ApplicationClosing or (FStartupCheckHandle <> 0) then Exit;
  if not ConfirmFingerprint then
  begin
    if FStartupCheckOnce or not ExternalInstallationSelected then Exit;
    FStartupCheckOnce := True;
  end;
  SettingsPath := IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName;
  // Verify the profile that the installer and SSH credential helper will actually use.
  // Das Profil prüfen, das Installation und SSH-Anmeldehelfer tatsächlich verwenden.
  Ini := TAppSettingsIni.Create(SettingsPath);
  try
    Host := Trim(Ini.ReadString('Paperless Extern', 'Host', ''));
    UserName := Trim(Ini.ReadString('Paperless Extern', 'Benutzer', ''));
    KeyFile := Trim(Ini.ReadString('Paperless Extern', 'SSH-Key-Datei', ''));
    PortText := Trim(Ini.ReadString('Paperless Extern', 'SSH-Port', ''));
    UseKey := SameText(Ini.ReadString('Paperless Extern', 'Anmeldung', 'Passwort'), 'SSH-Key');
  finally
    Ini.Free;
  end;
  if (Host = '') or (UserName = '') or (PortText = '') or
     (UseKey and (KeyFile = '')) or
     ((not UseKey) and (ReadServerSecret(SettingsPath, 'Passwort') = '')) then
  begin
    FExternalConnectionHeader := 'keine Verbindungsdaten';
    UpdateInstallationModeHeaders;
    if ConfirmFingerprint then
      CenteredShowMessage('Bitte zuerst die vollständigen SSH-Zugangsdaten speichern.');
    Exit;
  end;
  if not TryStrToInt(PortText, PortNumber) or
     (PortNumber < 1) or (PortNumber > 65535) then
  begin
    FExternalConnectionHeader := 'nicht verbunden';
    UpdateInstallationModeHeaders;
    CenteredShowMessage('Paperless extern: Der gespeicherte SSH-Port ist ungültig.');
    Exit;
  end;
  for Ch in Host do
    if not CharInSet(Ch, ['A'..'Z', 'a'..'z', '0'..'9', '.', '-', ':', '_']) then
    begin
      FExternalConnectionHeader := 'nicht verbunden';
      UpdateInstallationModeHeaders;
      CenteredShowMessage('Paperless extern: Der gespeicherte Host ist ungültig.');
      Exit;
    end;
  if Host[1] = '-' then
  begin
    FExternalConnectionHeader := 'nicht verbunden';
    UpdateInstallationModeHeaders;
    CenteredShowMessage('Paperless extern: Der gespeicherte Host ist ungültig.');
    Exit;
  end;
  for Ch in UserName do
    if not CharInSet(Ch, ['A'..'Z', 'a'..'z', '0'..'9', '.', '-', '_']) then
    begin
      FExternalConnectionHeader := 'nicht verbunden';
      UpdateInstallationModeHeaders;
      CenteredShowMessage('Paperless extern: Der gespeicherte Benutzername ist ungültig.');
      Exit;
    end;
  if UseKey and not FileExists(KeyFile) then
  begin
    FExternalConnectionHeader := 'nicht verbunden';
    UpdateInstallationModeHeaders;
    CenteredShowMessage('Paperless extern: Die SSH-Key-Datei wurde nicht gefunden.');
    Exit;
  end;
  try
    if FStartupCheckTimer = nil then
    begin
      FStartupCheckTimer := TTimer.Create(Self);
      FStartupCheckTimer.Enabled := False;
      FStartupCheckTimer.Interval := 500;
      FStartupCheckTimer.OnTimer := StartupCheckTimerTick;
    end;
    FStartupCheckInvalidated := False;
    FExternalConnectionHeader := 'Verbindung wird geprüft';
    UpdateInstallationModeHeaders;
    if ConfirmFingerprint then
      ExternalConnectionStatusLbl.Caption := 'SSH-Fingerabdruck wird abgefragt ...'
    else
      ExternalConnectionStatusLbl.Caption := 'Verbindung wird getestet ...';
    TestExternalConnectionBtn.Enabled := False;
    StartExternalStartupCheck(Host, UserName, PortNumber, KeyFile, SettingsPath,
      Application.ExeName, UseKey, ConfirmFingerprint, FStartupCheckHandle, FStartupCheckResultPath);
    FStartupInstallHost := InstallHost;
    SaveExternalServerBtn.Enabled := False;
    UpdateServerBackupButtons;
    FStartupCheckTimer.Enabled := True;
  except
    on E: Exception do
    begin
      if FStartupCheckHandle <> 0 then CloseHandle(FStartupCheckHandle);
      FStartupCheckHandle := 0;
      FExternalConnectionHeader := 'nicht verbunden';
      UpdateInstallationModeHeaders;
      TestExternalConnectionBtn.Enabled := True;
      ExternalConnectionStatusLbl.Caption := 'Verbindung fehlgeschlagen';
      CenteredShowMessage('Paperless extern: Der Verbindungstest konnte nicht gestartet werden. ' + E.Message);
    end;
  end;
end;

// Only apply a completed result to the same unchanged server profile.
// Ein Ergebnis nur fuer das unveraenderte Serverprofil uebernehmen.
procedure TMainformFrm.StartupCheckTimerTick(Sender: TObject);
var
  TestResult, InstallHost: string;
begin
  if FStartupCheckHandle = 0 then Exit;
  if WaitForSingleObject(FStartupCheckHandle, 0) <> WAIT_OBJECT_0 then Exit;
  FStartupCheckTimer.Enabled := False;
  CloseHandle(FStartupCheckHandle);
  FStartupCheckHandle := 0;
  InstallHost := FStartupInstallHost;
  FStartupInstallHost := '';
  TestExternalConnectionBtn.Enabled := True;
  SaveExternalServerBtn.Enabled := True;
  UpdateServerBackupButtons;
  TestResult := 'unknown';
  try
    if FileExists(FStartupCheckResultPath) then
      TestResult := Trim(TFile.ReadAllText(FStartupCheckResultPath, TEncoding.UTF8));
  except
    TestResult := 'unknown';
  end;
  if FileExists(FStartupCheckResultPath) then DeleteFile(FStartupCheckResultPath);
  if FileExists(FStartupCheckResultPath + '.cancel') then
    DeleteFile(FStartupCheckResultPath + '.cancel');
  FStartupCheckResultPath := '';
  if FStartupCheckInvalidated or ApplicationClosing then Exit;
  if (TestResult = 'success') or (TestResult = 'save_failed') then
  begin
    FExternalConnectionHeader := 'verbunden';
    ExternalConnectionStatusLbl.Caption := 'Verbindung hergestellt (SSH-Test)';
    UpdateInstallationModeHeaders;
    if TestResult = 'save_failed' then
      CenteredShowMessage('Die SSH-Verbindung wurde hergestellt, der Server-Fingerabdruck konnte aber nicht gespeichert werden.')
    else if (InstallHost <> '') and ExternalInstallationSelected then
      ConfirmServerInstallation(InstallHost);
    Exit;
  end;
  FExternalConnectionHeader := 'nicht verbunden';
  ExternalConnectionStatusLbl.Caption := 'Verbindung fehlgeschlagen';
  UpdateInstallationModeHeaders;
  if TestResult = 'cancelled' then
    ExternalConnectionStatusLbl.Caption := 'Verbindungsprüfung abgebrochen'
  else if TestResult = 'unreachable' then
    CenteredShowMessage('Paperless extern nicht erreichbar.')
  else if TestResult = 'auth' then
    CenteredShowMessage('Paperless extern erreichbar, Anmeldung abgelehnt. Bitte prüfen Sie die Zugangsdaten und die Anmeldeart.')
  else if TestResult = 'changed_host' then
    CenteredShowMessage('Der gespeicherte Server-Fingerabdruck hat sich geändert. Bitte prüfen Sie den Server-Schlüssel unabhängig. Die Verbindung wurde abgebrochen.')
  else if TestResult = 'fingerprint_tools' then
    CenteredShowMessage('Der SSH-Fingerabdruck kann nicht ausgewertet werden. Im Windows-OpenSSH-Client fehlt ssh-keygen.exe.')
  else if TestResult = 'fingerprint_scan' then
    CenteredShowMessage('Der SSH-Hostschlüssel konnte nicht abgerufen werden. Bitte Serveradresse, SSH-Port und Erreichbarkeit prüfen.')
  else if TestResult = 'fingerprint_unreadable' then
    CenteredShowMessage('Der SSH-Hostschlüssel wurde abgerufen, sein Fingerabdruck konnte aber nicht ausgewertet werden.')
  else if (TestResult = 'hostkey') or (TestResult = 'unknown_host') then
    CenteredShowMessage('Der Server-Fingerabdruck konnte nicht bestätigt werden. Bitte prüfen Sie den Server-Schlüssel.')
  else
    CenteredShowMessage('Paperless extern: Der SSH-Verbindungstest ist fehlgeschlagen.');
end;

// Read non-secret settings separately from the protected Windows credentials.
// Allgemeine Serverdaten und geschuetzte Zugangsdaten getrennt laden.
procedure TMainformFrm.LoadExternalServerSettings;
var
  Ini: TAppSettingsIni;
  SettingsPath, PasswordValue, PassphraseValue, Auth: string;
begin
  SettingsPath := IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName;
  SaveExternalServerBtn.Enabled := False;
  Ini := TAppSettingsIni.Create(SettingsPath);
  try
    ExternalHostEdit.Text := Ini.ReadString('Paperless Extern', 'Host', '');
    ExternalPortEdit.Text := Ini.ReadString('Paperless Extern', 'SSH-Port', '');
    ExternalWebPortEdit.Text := Ini.ReadString('Paperless Extern', IniKeyServerWebPort,
      IntToStr(ServerInstallWebPort));
    ExternalUserEdit.Text := Ini.ReadString('Paperless Extern', 'Benutzer', '');
    ExternalKeyEdit.Text := Ini.ReadString('Paperless Extern', 'SSH-Key-Datei', '');
    ExternalComposePathEdit.Text := ExternalComposeDirectory(Ini.ReadString('Paperless Extern', 'Compose-Datei', ''));
    if ExternalComposePathEdit.Text = '' then
      ExternalComposePathEdit.Text := ServerInstallFolder;
    ExternalComposeProjectEdit.Text := Ini.ReadString('Paperless Extern', 'Compose-Projekt', '');
    ExternalBackupFolderEdit.Text := Ini.ReadString('Paperless Extern', IniKeyServerBackupFolder, DefaultServerBackupFolder);
    Auth := Ini.ReadString('Paperless Extern', 'Anmeldung', 'Passwort');
  finally
    Ini.Free;
  end;
  if SameText(Auth, 'SSH-Key') then ExternalAuthRadioGroup.ItemIndex := 1
  else if SameText(Auth, 'Passwort') then ExternalAuthRadioGroup.ItemIndex := 0
  else raise Exception.Create('Unbekannte SSH-Anmeldeart in der Einstellungsdatei.');
  ExternalAuthRadioGroupClick(nil);
  PasswordValue := ReadServerSecret(SettingsPath, 'Passwort');
  PassphraseValue := ReadServerSecret(SettingsPath, 'Passphrase');
  ExternalPasswordEdit.Text := PasswordValue;
  ExternalKeyPassphraseEdit.Text := PassphraseValue;
  SaveExternalServerBtn.Enabled := True;
end;

// A successful test describes a completed SSH login, not a persistent connection.
// Ein erfolgreicher Test bestaetigt die SSH-Anmeldung, keine dauerhafte Verbindung.
procedure TMainformFrm.ExternalConnectionSettingsChanged(Sender: TObject);
begin
  FExternalTestInvalidated := True;
  CancelExternalStartupCheck;
  FExternalConnectionHeader := 'nicht verbunden';
  if not (csLoading in ComponentState) and Assigned(Label1) and Assigned(Label8) and
     Assigned(Label5) and Assigned(Label2) and Assigned(Label27) and Assigned(Label25) then
    UpdateInstallationModeHeaders;
  ExternalConnectionStatusLbl.Caption := 'Verbindung nicht getestet';
end;

// Read the result asynchronously so the visible SSH prompt remains usable.
// Ergebnis asynchron lesen, damit die sichtbare SSH-Abfrage bedienbar bleibt.
procedure TMainformFrm.ExternalTestTimerTick(Sender: TObject);
var
  TestResult: string;
begin
  if FExternalTestResultPath = '' then Exit;
  if Cardinal(GetTickCount - FExternalTestStarted) >= 300000 then
  begin
    FExternalTestTimer.Enabled := False;
    FExternalTestResultPath := '';
    TestExternalConnectionBtn.Enabled := True;
    ExternalConnectionStatusLbl.Caption := 'Kein Testergebnis - erneut testen';
    Exit;
  end;
  if not FileExists(FExternalTestResultPath) then Exit;
  try
    TestResult := Trim(TFile.ReadAllText(FExternalTestResultPath, TEncoding.UTF8));
    if (TestResult <> 'success') and (TestResult <> 'failure') then Exit;
    DeleteFile(FExternalTestResultPath);
    FExternalTestResultPath := '';
    FExternalTestTimer.Enabled := False;
    TestExternalConnectionBtn.Enabled := True;
    if FExternalTestInvalidated then
      ExternalConnectionStatusLbl.Caption := 'Serverdaten geändert - erneut testen'
    else if TestResult = 'success' then
    begin
      ExternalConnectionStatusLbl.Caption := 'Verbindung hergestellt (SSH-Test)';
      FExternalConnectionHeader := 'verbunden';
      UpdateInstallationModeHeaders;
    end
    else
    begin
      ExternalConnectionStatusLbl.Caption := 'Verbindung fehlgeschlagen';
      FExternalConnectionHeader := 'nicht verbunden';
      UpdateInstallationModeHeaders;
    end;
  except
    // A writer may still hold the result file; retry on the next tick.
    // Wenn die Datei noch geschrieben wird, beim naechsten Timer erneut lesen.
  end;
end;

// Save server settings without invoking the local settings or Docker workflows.
// Serverdaten ohne lokale Einstellungen oder Dockerablaeufe speichern.
// Use a visible OpenSSH window for authentication and read-only checks.
// OpenSSH zur Anmeldung und fuer lesende Pruefungen sichtbar starten.
procedure TMainformFrm.TestExternalConnectionBtnClick(Sender: TObject);
var
  Host, UserName, ComposeFile, KeyFile, RemotePath, RemoteCommand: string;
  ScriptPath, Params, ArgumentList, SettingsPath, ExpectedAuth, ResultPath: string;
  PortNumber: Integer;
  Ch: Char;
  Lines: TStringList;
  LaunchResult: HINST;
  Ini: TAppSettingsIni;
begin
  ProgramUpdateLbl.Hide;
  Host := Trim(ExternalHostEdit.Text);
  UserName := Trim(ExternalUserEdit.Text);
  ComposeFile := ExternalComposeFile(ExternalComposePathEdit.Text);
  KeyFile := Trim(ExternalKeyEdit.Text);
  if (Host = '') or (UserName = '') or (ComposeFile = '') or
     not TryStrToInt(Trim(ExternalPortEdit.Text), PortNumber) or
     (PortNumber < 1) or (PortNumber > 65535) then
  begin
    CenteredShowMessage('Bitte Host, SSH-Port (1 bis 65535), Benutzername und Compose-Ordner ausfüllen.');
    Exit;
  end;
  for Ch in Host do
    if not CharInSet(Ch, ['A'..'Z', 'a'..'z', '0'..'9', '.', '-', ':', '_']) then
    begin
      CenteredShowMessage('Host oder IP-Adresse enthält ungültige Zeichen.');
      Exit;
    end;
  if Host[1] = '-' then
  begin
    CenteredShowMessage('Der Host darf nicht mit einem Bindestrich beginnen.');
    Exit;
  end;
  for Ch in UserName do
    if not CharInSet(Ch, ['A'..'Z', 'a'..'z', '0'..'9', '.', '-', '_']) then
    begin
      CenteredShowMessage('Der Benutzername enthält ungültige Zeichen.');
      Exit;
    end;
  for Ch in ComposeFile do
    if Ord(Ch) < 32 then
    begin
      CenteredShowMessage('Der Compose-Dateipfad enthält ungültige Steuerzeichen.');
      Exit;
    end;
  if ComposeFile[1] <> '/' then
  begin
    CenteredShowMessage('Bitte den absoluten Pfad zum Compose-Ordner auf dem Server eingeben.');
    Exit;
  end;
  if (ExternalAuthRadioGroup.ItemIndex = 1) and
     ((KeyFile = '') or not FileExists(KeyFile)) then
  begin
    CenteredShowMessage('Bitte eine vorhandene SSH-Key-Datei angeben.');
    Exit;
  end;
  SettingsPath := IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName;
  if UseSavedSshCredentialCB.Checked then
  begin
    if ExternalAuthRadioGroup.ItemIndex = 1 then ExpectedAuth := 'SSH-Key'
    else ExpectedAuth := 'Passwort';
    try
      if ((ExternalAuthRadioGroup.ItemIndex = 0) and
          (ExternalPasswordEdit.Text <> ReadServerSecret(SettingsPath, 'Passwort'))) or
         ((ExternalAuthRadioGroup.ItemIndex = 1) and
          (ExternalKeyPassphraseEdit.Text <> ReadServerSecret(SettingsPath, 'Passphrase'))) then
      begin
        CenteredShowMessage('Bitte die aktuellen Zugangsdaten vor dem automatischen Test speichern.');
        Exit;
      end;
      Ini := TAppSettingsIni.Create(SettingsPath);
      try
        if (Host <> Trim(Ini.ReadString('Paperless Extern', 'Host', ''))) or
           (IntToStr(PortNumber) <> Trim(Ini.ReadString('Paperless Extern', 'SSH-Port', ''))) or
           (UserName <> Trim(Ini.ReadString('Paperless Extern', 'Benutzer', ''))) or
           (ComposeFile <> ExternalComposeFile(Ini.ReadString('Paperless Extern', 'Compose-Datei', ''))) or
           (ExternalComposeProjectEdit.Text <> Ini.ReadString('Paperless Extern', 'Compose-Projekt', '')) or
           not SameText(ExpectedAuth, Ini.ReadString('Paperless Extern', 'Anmeldung', 'Passwort')) or
           ((ExternalAuthRadioGroup.ItemIndex = 1) and
            (KeyFile <> Trim(Ini.ReadString('Paperless Extern', 'SSH-Key-Datei', '')))) then
        begin
          CenteredShowMessage('Bitte die aktuellen Serverdaten vor dem automatischen Test speichern.');
          Exit;
        end;
      finally
        Ini.Free;
      end;
    except
      on E: Exception do
      begin
        CenteredShowMessage('Die gespeicherten Serverdaten konnten nicht geprüft werden: ' + E.Message);
        Exit;
      end;
    end;
  end;

  // Quote the server path as a literal POSIX shell argument.
  // Den Serverpfad als woertliches POSIX-Shellargument quotieren.
  RemotePath := #39 + StringReplace(ComposeFile, #39, #39 + '"' + #39 + '"' + #39,
    [rfReplaceAll]) + #39;
  RemoteCommand := 'echo "SSH: verbunden"; ' +
    'if docker compose version >/dev/null 2>&1; then echo "Docker Compose: verfügbar"; ' +
    'else echo "Docker Compose: nicht verfügbar oder keine Berechtigung"; fi; ' +
    'if [ -f ' + RemotePath + ' ] && [ -r ' + RemotePath + ' ]; then ' +
    'echo "Compose-Datei: vorhanden und lesbar"; else ' +
    'echo "Compose-Datei: fehlt oder ist nicht lesbar"; fi';
  if UseSavedSshCredentialCB.Checked then
    ArgumentList := PowerShellQuote('-o') + ', ' + PowerShellQuote('StrictHostKeyChecking=yes')
  else
    ArgumentList := PowerShellQuote('-o') + ', ' + PowerShellQuote('StrictHostKeyChecking=ask');
  ArgumentList := ArgumentList +
    ', ' + PowerShellQuote('-p') + ', ' + PowerShellQuote(IntToStr(PortNumber)) +
    ', ' + PowerShellQuote('-l') + ', ' + PowerShellQuote(UserName);
  if ExternalAuthRadioGroup.ItemIndex = 1 then
    ArgumentList := ArgumentList + ', ' + PowerShellQuote('-o') + ', ' +
      PowerShellQuote('IdentitiesOnly=yes') + ', ' + PowerShellQuote('-i') + ', ' + PowerShellQuote(KeyFile)
  else if UseSavedSshCredentialCB.Checked then
    ArgumentList := ArgumentList + ', ' + PowerShellQuote('-o') + ', ' +
      PowerShellQuote('PreferredAuthentications=password') + ', ' +
      PowerShellQuote('-o') + ', ' + PowerShellQuote('PubkeyAuthentication=no') + ', ' +
      PowerShellQuote('-o') + ', ' + PowerShellQuote('NumberOfPasswordPrompts=1')
  else
    ArgumentList := ArgumentList + ', ' + PowerShellQuote('-o') + ', ' +
      PowerShellQuote('PreferredAuthentications=keyboard-interactive,password') + ', ' +
      PowerShellQuote('-o') + ', ' + PowerShellQuote('PubkeyAuthentication=no');
  ArgumentList := ArgumentList + ', ' + PowerShellQuote(Host) + ', ' + PowerShellQuote(RemoteCommand);
  try
    ScriptPath := ReserveTimestampedScript(TPath.GetTempPath);
    ResultPath := ScriptPath + '.result';
    Lines := TStringList.Create;
    try
      Lines.Add('$sshArgs = @(' + ArgumentList + ')');
      if UseSavedSshCredentialCB.Checked then
      begin
        Lines.Add('$env:PAPERLESS_SSH_HELPER = ''1''');
        Lines.Add('$env:PAPERLESS_SSH_SETTINGS = ' + PowerShellQuote(SettingsPath));
        if ExternalAuthRadioGroup.ItemIndex = 1 then
          Lines.Add('$env:PAPERLESS_SSH_AUTH = ''key''')
        else
          Lines.Add('$env:PAPERLESS_SSH_AUTH = ''password''');
        Lines.Add('$env:SSH_ASKPASS = ' + PowerShellQuote(Application.ExeName));
        Lines.Add('$env:SSH_ASKPASS_REQUIRE = ''force''');
        Lines.Add('$env:DISPLAY = ''paperless:0''');
        Lines.Add('Write-Host ''Automatisch nur bei bereits bestätigtem Server-Schlüssel. Bei unbekanntem Schlüssel zuerst ohne gespeicherte Zugangsdaten testen.''');
      end;
      Lines.Add('$testResult = ''failure''');
      Lines.Add('try {');
      Lines.Add('  Write-Host ''Den Server-Fingerabdruck vor der Bestätigung unabhängig vergleichen.''');
      Lines.Add('  $sshExe = Get-Command ssh.exe -ErrorAction Stop');
      Lines.Add('  & $sshExe.Source @sshArgs');
      Lines.Add('  if ($LASTEXITCODE -eq 0) { $testResult = ''success'' }');
      Lines.Add('  else { Write-Host (''SSH-Test fehlgeschlagen. Exitcode: '' + $LASTEXITCODE) }');
      Lines.Add('} catch { Write-Host (''SSH-Test konnte nicht gestartet werden: '' + $_.Exception.Message) }');
      Lines.Add('finally {');
      Lines.Add('  [System.IO.File]::WriteAllText(' + PowerShellQuote(ResultPath) + ', $testResult)');
      Lines.Add('  Remove-Item -LiteralPath $PSCommandPath -Force -ErrorAction SilentlyContinue');
      Lines.Add('  Read-Host ''Zum Schließen Eingabetaste drücken'' | Out-Null');
      Lines.Add('}');
      Lines.SaveToFile(ScriptPath, TEncoding.UTF8);
    finally
      Lines.Free;
    end;
    if FExternalTestTimer = nil then
    begin
      FExternalTestTimer := TTimer.Create(Self);
      FExternalTestTimer.Enabled := False;
      FExternalTestTimer.Interval := 500;
      FExternalTestTimer.OnTimer := ExternalTestTimerTick;
    end;
    FExternalTestResultPath := ResultPath;
    FExternalTestStarted := GetTickCount;
    FExternalTestInvalidated := False;
    ExternalConnectionStatusLbl.Caption := 'Verbindung wird getestet ...';
    TestExternalConnectionBtn.Enabled := False;
    Params := '-NoProfile -ExecutionPolicy Bypass -File "' + ScriptPath + '"';
    LaunchResult := ShellExecute(Handle, 'open', 'powershell.exe', PChar(Params), nil, SW_SHOWNORMAL);
    if NativeInt(LaunchResult) <= 32 then
      raise Exception.Create('Das Fenster für den SSH-Test konnte nicht gestartet werden.');
    FExternalTestTimer.Enabled := True;
  except
    on E: Exception do
    begin
      if FileExists(ScriptPath) then DeleteFile(ScriptPath);
      FExternalTestResultPath := '';
      TestExternalConnectionBtn.Enabled := True;
      ExternalConnectionStatusLbl.Caption := 'Verbindung fehlgeschlagen';
      CenteredShowMessage('Der Verbindungstest konnte nicht vorbereitet werden: ' + E.Message);
    end;
  end;
end;

procedure TMainformFrm.SaveExternalServerBtnClick(Sender: TObject);
var
  Ini: TAppSettingsIni;
  SettingsPath, Auth, BackupFolder: string;
  WebPort: Integer;
begin
  if FStartupCheckHandle <> 0 then Exit;
  ProgramUpdateLbl.Hide;
  if not TryStrToInt(Trim(ExternalWebPortEdit.Text), WebPort) or
     (WebPort < 1) or (WebPort > 65535) then
  begin
    CenteredShowMessage('Bitte einen Paperless-Webport zwischen 1 und 65535 eingeben.');
    Exit;
  end;
  ExternalConnectionSettingsChanged(Sender);
  SettingsPath := IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName;
  if ExternalAuthRadioGroup.ItemIndex = 1 then Auth := 'SSH-Key'
  else Auth := 'Passwort';
  try
    // Validate the backup path before persisting any server settings.
    // Den Backupordner vor dem Speichern der Servereinstellungen validieren.
    BackupFolder := NormalizeServerBackupFolder(ExternalBackupFolderEdit.Text);
    WriteServerSecret(SettingsPath, 'Passwort', ExternalPasswordEdit.Text);
    WriteServerSecret(SettingsPath, 'Passphrase', ExternalKeyPassphraseEdit.Text);
    Ini := TAppSettingsIni.Create(SettingsPath);
    try
      Ini.WriteString('Paperless Extern', 'Host', ExternalHostEdit.Text);
      Ini.WriteString('Paperless Extern', 'SSH-Port', ExternalPortEdit.Text);
      Ini.WriteString('Paperless Extern', IniKeyServerWebPort, IntToStr(WebPort));
      Ini.WriteString('Paperless Extern', 'Benutzer', ExternalUserEdit.Text);
      Ini.WriteString('Paperless Extern', 'SSH-Key-Datei', ExternalKeyEdit.Text);
      Ini.WriteString('Paperless Extern', 'Compose-Datei', ExternalComposePathEdit.Text);
      Ini.WriteString('Paperless Extern', 'Compose-Projekt', ExternalComposeProjectEdit.Text);
      Ini.WriteString('Paperless Extern', IniKeyServerBackupFolder, BackupFolder);
      Ini.WriteString('Paperless Extern', 'Anmeldung', Auth);
    finally
      Ini.Free;
    end;
  except
    on E: Exception do
    begin
      CenteredShowMessage('Serverdaten konnten nicht vollständig gespeichert werden. Einzelne Angaben können bereits gespeichert sein. ' + E.Message);
      Exit;
    end;
  end;
  // Confirm the fingerprint after every save, including an unchanged server address.
  // Den Fingerabdruck nach jedem Speichern bestätigen lassen, auch bei gleicher Serveradresse.
  BeginExternalStartupCheck(True);
end;

// Enable key fields only for SSH key authentication.
// SSH-Key-Felder nur bei Anmeldung mit SSH-Key aktivieren.
procedure TMainformFrm.ExternalAuthRadioGroupClick(Sender: TObject);
var
  KeyEnabled: Boolean;
begin
  ExternalConnectionSettingsChanged(Sender);
  KeyEnabled := ExternalAuthRadioGroup.ItemIndex = 1;
  ExternalKeyLbl.Enabled := KeyEnabled;
  ExternalKeyEdit.Enabled := KeyEnabled;
  ExternalKeyPassphraseLbl.Enabled := KeyEnabled;
  ExternalKeyPassphraseEdit.Enabled := KeyEnabled;
  ExternalPasswordLbl.Enabled := not KeyEnabled;
  ExternalPasswordEdit.Enabled := not KeyEnabled;
end;

procedure TMainformFrm.CheckBox1Click(Sender: TObject);
var
  AllVersionsEnabled: Boolean;
begin
  // Both checkboxes use this handler; confirmation is required for version editing.
  // Beide Checkboxen nutzen diesen Handler; die Bestätigung ist für Versionsänderungen erforderlich.
  OnlyPaperlessVersionCB.Enabled := CheckBox1.Checked and (ExternalInstallationSelected or not ProtectCustomFilesCB.Checked);
  // Checked restriction: edit only Paperless. Unchecked restriction: edit all seven versions.
  // Einschränkung angehakt: nur Paperless ändern. Einschränkung abgewählt: alle sieben Versionen ändern.
  AllVersionsEnabled := CheckBox1.Checked and not OnlyPaperlessVersionCB.Checked and
    (ExternalInstallationSelected or not ProtectCustomFilesCB.Checked);
  redis_version_edit.Enabled := AllVersionsEnabled;
  postgres_version_edit.Enabled := AllVersionsEnabled;
  gotenberg_version_edit.Enabled := AllVersionsEnabled;
  tika_version_edit.Enabled := AllVersionsEnabled;
  alpine_version_edit.Enabled := AllVersionsEnabled;
  busybox_version_edit.Enabled := AllVersionsEnabled;
  paperless_version_edit.Enabled := CheckBox1.Checked and (ExternalInstallationSelected or not ProtectCustomFilesCB.Checked);
end;

// Confirm the remote directory operation before starting any SSH commands.
// Das Anlegen des Serverordners bestätigen lassen, bevor SSH-Befehle starten.
procedure TMainformFrm.CreateExternalBackupFolderBtnClick(Sender: TObject);
var
  BackupFolder: string;
begin
  ProgramUpdateLbl.Hide;
  if FServerBackupCheckActive then Exit;
  try
    BackupFolder := NormalizeServerBackupFolder(ExternalBackupFolderEdit.Text);
  except
    on E: Exception do
    begin
      CenteredMessageDlg(E.Message, mtWarning, [mbOK], 0);
      Exit;
    end;
  end;

  // Only Yes authorizes the server operation; No and Cancel leave the dialog without starting it.
  // Nur Ja bestätigt den Servervorgang; Nein und Abbrechen schließen den Dialog ohne Start.
  if CenteredMessageDlg(
    'Wenn Sie auf Ja klicken, prüft das Programm zuerst den freien Speicherplatz auf dem entfernten Server. ' +
    'Anschließend legt es den Backupordner unter folgendem Pfad an:' + sLineBreak + sLineBreak +
    BackupFolder + sLineBreak + sLineBreak +
    'Der verfügbare Speicherplatz wird Ihnen angezeigt. Stellen Sie sicher, dass auf dem Server genügend Platz ' +
    'für Ihre Backups vorhanden ist.' + sLineBreak + sLineBreak +
    'Wenn das Root-Dateisystem (/) voll läuft, kann der Server beim nächsten Neustart möglicherweise nicht mehr starten.' + sLineBreak + sLineBreak +
    'Backupordner jetzt anlegen?',
    mtWarning, [mbYes, mbNo, mbCancel], 0) = mrYes then
    BeginServerBackupCheck(BackupFolder);
end;

// Confirm the saved host before changing Debian packages or server files.
// Vor Änderungen an Debian-Paketen oder Serverdateien den gespeicherten Host bestätigen.
// Use the saved root profile and require a fresh host-key confirmation before installation.
// Das gespeicherte root-Profil verwenden und vor der Installation den Hostschlüssel erneut bestätigen lassen.
procedure TMainformFrm.InstallServerPaperlessBtnClick(Sender: TObject);
var
  Ini: TAppSettingsIni;
  Host, UserName: string;
begin
  if not ExternalInstallationSelected or ScriptBusy or FServerBackupCheckActive or
     (FStartupCheckHandle <> 0) or ApplicationClosing then Exit;

  Ini := TAppSettingsIni.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
  try
    Host := Trim(Ini.ReadString('Paperless Extern', 'Host', ''));
    UserName := Trim(Ini.ReadString('Paperless Extern', 'Benutzer', ''));
  finally
    Ini.Free;
  end;
  if (Host = '') or (UserName <> 'root') then
  begin
    CenteredShowMessage('Bitte zuerst die Serverdaten mit dem SSH-Benutzer root speichern.');
    Exit;
  end;

  BeginExternalStartupCheck(True, Host);
end;

// The installation starts only after the fingerprint check and the target confirmation.
// Die Installation beginnt erst nach Fingerabdruckprüfung und Bestätigung des Zielservers.
// Ask for the installation itself after the fingerprint and SSH login have been checked.
// Den Installationsauftrag erst nach Fingerabdruckbestätigung und erfolgreicher SSH-Anmeldung bestätigen lassen.
procedure TMainformFrm.ConfirmServerInstallation(const Host: string);
begin
  if not ExternalInstallationSelected or ScriptBusy or FServerBackupCheckActive or
     ApplicationClosing then Exit;
  if CenteredMessageDlg('Paperless auf ' + Host + ' unter ' + ServerInstallFolder + ' installieren?' +
    sLineBreak + sLineBreak +
    'Das Programm aktualisiert die Debian-Pakete und richtet Docker, Paperless und die ' +
    'beschreibbare Samba-Gastfreigabe paperless-consume ein.',
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then Exit;
  TabControl1.TabIndex := 0;
  TabControl1Change(TabControl1);
  BeginServerBackupCheck('', sbaInstallPaperless);
end;

// Keep server actions unavailable until the operation and its dialogs have finished.
// Serveraktionen bis zum Abschluss des Vorgangs und seiner Dialoge sperren.
procedure TMainformFrm.BeginServerBackupCheck(const BackupFolder: string; Action: TServerBackupAction;
  const LocalDownloadFolder: string);
var
  ErrorCaption: string;
begin
  if ScriptBusy or FServerBackupCheckActive or ApplicationClosing then Exit;
  FServerBackupCheckActive := True;
  FServerBackupAction := Action;
  FServerWorkerProgressOffset := 0;
  FServerBackupProgressActive := Action <> sbaCheckSpace;
  try
    // Reuse the local backup display without setting the local IsBackup flag.
    // Die lokale Backupanzeige verwenden, ohne das lokale Flag IsBackup zu setzen.
    if FServerBackupProgressActive then
    begin
      case Action of
        sbaInstallPaperless:
          FServerBackupStatusText := 'SSH-Verbindung für die Paperless-Installation wird aufgebaut ...';
        sbaStartBackup:
          FServerBackupStatusText := 'Server-Backup wird vorbereitet. Bitte warten ...';
        sbaDownloadBackup:
          FServerBackupStatusText := 'Backup-Download wird vorbereitet. Bitte warten ...';
        sbaUploadBackup:
          FServerBackupStatusText := 'Speicherplatz auf dem Server wird geprüft. Bitte warten ...';
        sbaListBackups, sbaListRestoreBackups:
          FServerBackupStatusText := 'Gespeicherter Backupordner wird geprüft. Bitte warten ...';
        sbaStartRestore:
          FServerBackupStatusText := 'Server-Wiederherstellung wird vorbereitet. Bitte warten ...';
        sbaWatchRestore:
          FServerBackupStatusText := 'Status der Server-Wiederherstellung wird abgefragt. Bitte warten ...';
      else
        FServerBackupStatusText := 'Backupstatus wird abgefragt. Bitte warten ...';
      end;
      PrepareScriptProgress(FServerBackupStatusText);
    end
    else
    begin
      StartPaperlessBackupBtn.Enabled := False;
      CreateExternalBackupFolderBtn.Enabled := False;
      LoadServerBackupBtn.Enabled := False;
      SendServerBackupBtn.Enabled := False;
      FServerBackupModeWasEnabled := InstallationModeRadioGroup.Enabled;
      InstallationModeRadioGroup.Enabled := False;
      // Keep the check visible on the settings tab.
      // Die laufende Prüfung auf dem Einstellungstab anzeigen.
      StatusBar1.SimpleText := 'Bitte warten. Speicherplatzgrößen werden geprüft.';
      StatusBar1.SimplePanel := True;
    end;
    if FServerBackupCheckTimer = nil then
    begin
      FServerBackupCheckTimer := TTimer.Create(Self);
      FServerBackupCheckTimer.Enabled := False;
      FServerBackupCheckTimer.Interval := 250;
      FServerBackupCheckTimer.OnTimer := ServerBackupCheckTimerTick;
    end;
    StartServerBackup(FServerBackupCheckHandle, FServerBackupCheckResultPath, BackupFolder, Action,
      LocalDownloadFolder);
    FServerBackupCheckTimer.Enabled := True;
  except
    on E: Exception do
      try
        ErrorCaption := 'Server-Backup: Prüfung fehlgeschlagen';
        if Action in [sbaListRestoreBackups, sbaStartRestore, sbaWatchRestore] then
          ErrorCaption := 'Server-Wiederherstellung: Prüfung fehlgeschlagen';
        if Action = sbaInstallPaperless then
        begin
          ErrorCaption := 'Paperless-Installation konnte nicht gestartet werden';
          FinishScriptProgress(ErrorCaption, False);
        end
        else if Action = sbaDownloadBackup then
          FinishScriptProgress('Backup-Download konnte nicht gestartet werden.', False)
        else if Action = sbaUploadBackup then
          FinishScriptProgress('Backup konnte nicht zum Server gesendet werden.', False)
        else if Action in [sbaListBackups, sbaListRestoreBackups] then
          FinishScriptProgress('Server-Backups konnten nicht geprüft werden.', False)
        else if Action in [sbaStartRestore, sbaWatchRestore] then
          FinishScriptProgress('Server-Wiederherstellung konnte nicht gestartet oder abgefragt werden.', False)
        else if FServerBackupProgressActive then
          FinishScriptProgress('Server-Backup konnte nicht gestartet oder abgefragt werden.', False);
        CenteredMessageBox(E.Message, ErrorCaption, MB_OK or MB_ICONWARNING);
      finally
        EndServerBackupCheck;
      end;
  end;
end;

// Consume only complete UTF-8 lines so a concurrent append cannot split a message.
// Nur vollständige UTF-8-Zeilen lesen, damit ein gleichzeitiger Schreibzugriff keine Meldung teilt.
function TMainformFrm.ReadNextServerWorkerStatus(const ProgressPath: string): Boolean;
var
  Stream: TFileStream;
  Pending: TBytes;
  Available: Int64;
  Count, LineEnd: Integer;
begin
  Result := False;
  try
    Stream := TFileStream.Create(ProgressPath, fmOpenRead or fmShareDenyNone);
    try
      Available := Stream.Size - FServerWorkerProgressOffset;
      if Available <= 0 then Exit;
      SetLength(Pending, Available);
      Stream.Position := FServerWorkerProgressOffset;
      Count := Stream.Read(Pending[0], Length(Pending));
    finally
      Stream.Free;
    end;
    for LineEnd := 0 to Count - 1 do
      if Pending[LineEnd] = 10 then
      begin
        Inc(FServerWorkerProgressOffset, LineEnd + 1);
        FServerBackupStatusText := TEncoding.UTF8.GetString(Pending, 0, LineEnd).Trim;
        Exit(True);
      end;
  except
    on E: EStreamError do ;
  end;
end;

// Poll the hidden process without blocking the main window and keep the button locked during the modal dialog.
// Verdeckten Prozess ohne Blockieren des Hauptfensters abfragen und den Button auch im Meldungsdialog gesperrt lassen.
procedure TMainformFrm.ServerBackupCheckTimerTick(Sender: TObject);
var
  WaitResult, ExitCode: DWORD;
  ProgressPath, ProgressText, Caption, MessageText, SelectionCaption: string;
  CompletedBackupFolder, DownloadSourceFolder, DownloadTargetFolder, RestoreSourceFolder: string;
  AvailableBackupFolders, BackupNames: TArray<string>;
  I, SelectedIndex: Integer;
  Ini: TAppSettingsIni;
  OperationSucceeded, SelectableBackups, WorkerProgress: Boolean;
begin
  if FServerBackupCheckHandle = 0 then Exit;
  WaitResult := WaitForSingleObject(FServerBackupCheckHandle, 0);
  ProgressPath := FServerBackupCheckResultPath + '.progress';
  WorkerProgress := FServerBackupAction in ServerWorkerActions;
  // Show one queued status per timer tick. Drain the final batch before showing the result dialog.
  // Pro Timer-Takt eine vorgemerkte Meldung anzeigen. Die Meldungen der letzten Abfrage vor dem Ergebnisdialog ausgeben.
  if WorkerProgress and ((WaitResult = WAIT_TIMEOUT) or (WaitResult = WAIT_OBJECT_0)) and
     ReadNextServerWorkerStatus(ProgressPath) then
  begin
    UpdateScriptProgress(FServerBackupStatusText);
    Exit;
  end;
  if WaitResult = WAIT_TIMEOUT then
  begin
    if FServerBackupProgressActive then
    begin
      // Keep the last server status while PowerShell updates the progress file.
      // Den letzten Serverstatus beibehalten, während PowerShell die Fortschrittsdatei aktualisiert.
      if not WorkerProgress and FileExists(ProgressPath) then
        try
          ProgressText := TFile.ReadAllText(ProgressPath, TEncoding.UTF8).Trim;
          if ProgressText <> '' then FServerBackupStatusText := ProgressText;
        except
          on E: EStreamError do ;
        end;
      UpdateScriptProgress(FServerBackupStatusText);
    end;
    Exit;
  end;
  FServerBackupCheckTimer.Enabled := False;
  DownloadSourceFolder := '';
  DownloadTargetFolder := '';
  RestoreSourceFolder := '';
  try
    try
      ExitCode := 0;
      if (WaitResult <> WAIT_OBJECT_0) or
         not GetExitCodeProcess(FServerBackupCheckHandle, ExitCode) then
        RaiseLastOSError;
      OperationSucceeded := ReadServerBackupResult(FServerBackupCheckResultPath, ExitCode, Caption, MessageText,
        CompletedBackupFolder, AvailableBackupFolders);
      if FServerBackupAction = sbaInstallPaperless then
      begin
        if OperationSucceeded then
        begin
          // Point subsequent backup and restore operations at the new Compose project.
          // Anschließende Sicherungen und Wiederherstellungen auf das neue Compose-Projekt richten.
          // Save the installed web port alongside the project for subsequent browser launches.
          // Den installierten Webport mit dem Projekt für spätere Browseraufrufe speichern.
          try
            Ini := TAppSettingsIni.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
            try
              Ini.WriteString('Paperless Extern', 'Compose-Datei', ServerInstallFolder);
              Ini.WriteString('Paperless Extern', 'Compose-Projekt', ComposeProjectName);
              Ini.WriteString('Paperless Extern', IniKeyServerWebPort, IntToStr(ServerInstallWebPort));
              Ini.UpdateFile;
            finally
              Ini.Free;
            end;
            ExternalComposePathEdit.Text := ServerInstallFolder;
            ExternalComposeProjectEdit.Text := ComposeProjectName;
            ExternalWebPortEdit.Text := IntToStr(ServerInstallWebPort);
          except
            MessageText := MessageText + sLineBreak + sLineBreak +
              'Die Serverdaten konnten lokal nicht aktualisiert werden. Bitte den Compose-Ordner ' +
              ServerInstallFolder + ', das Compose-Projekt ' + ComposeProjectName +
              ' und den Paperless-Webport ' + IntToStr(ServerInstallWebPort) + ' speichern.';
          end;
        end
        else if not Caption.StartsWith('Paperless') then
          Caption := 'Paperless-Installation fehlgeschlagen';
      end;
      SelectableBackups := (FServerBackupAction in [sbaListBackups, sbaListRestoreBackups]) and OperationSucceeded and
        (Length(AvailableBackupFolders) > 0);
      if FServerBackupProgressActive then
        FinishScriptProgress(Caption, OperationSucceeded);
      if not OperationSucceeded then
        CenteredMessageBox(MessageText, Caption, MB_OK or MB_ICONWARNING)
      else if not SelectableBackups then
        CenteredMessageBox(MessageText, Caption, MB_OK or MB_ICONINFORMATION);
    except
      on E: Exception do
      begin
        Caption := 'Server-Backup: Prüfung fehlgeschlagen';
        if FServerBackupAction in [sbaListRestoreBackups, sbaStartRestore, sbaWatchRestore] then
          Caption := 'Server-Wiederherstellung: Prüfung fehlgeschlagen';
        if FServerBackupAction = sbaInstallPaperless then
        begin
          Caption := 'Paperless-Installation: Ergebnis nicht verfügbar';
          FinishScriptProgress(Caption, False);
        end
        else if FServerBackupAction = sbaDownloadBackup then
          FinishScriptProgress('Backup-Download: Ergebnis nicht verfügbar.', False)
        else if FServerBackupAction = sbaUploadBackup then
          FinishScriptProgress('Backup-Upload: Ergebnis nicht verfügbar.', False)
        else if FServerBackupAction in [sbaListBackups, sbaListRestoreBackups] then
          FinishScriptProgress('Server-Backups: Prüfergebnis nicht verfügbar.', False)
        else if FServerBackupAction in [sbaStartRestore, sbaWatchRestore] then
          FinishScriptProgress('Server-Wiederherstellung: Ergebnis nicht verfügbar.', False)
        else if FServerBackupProgressActive then
          FinishScriptProgress('Server-Backup: Ergebnis nicht verfügbar.', False);
        CenteredMessageBox('Der Servervorgang konnte nicht ausgewertet werden.' +
          sLineBreak + E.Message, Caption, MB_OK or MB_ICONWARNING);
        Exit;
      end;
    end;

    if not ApplicationClosing then
      try
        if SelectableBackups then
        begin
          // Display backup names and keep the canonical paths for the selected server operation.
          // Backupnamen anzeigen und die kanonischen Pfade für die gewählte Serveraktion behalten.
          if FServerBackupAction = sbaListRestoreBackups then
            SelectionCaption := 'Backup auf dem Server wiederherstellen'
          else
            SelectionCaption := 'Backup vom Server laden';
          SetLength(BackupNames, Length(AvailableBackupFolders));
          for I := 0 to High(AvailableBackupFolders) do
            BackupNames[I] := Copy(AvailableBackupFolders[I],
              LastDelimiter('/', AvailableBackupFolders[I]) + 1, MaxInt);
          if CenteredSelectListItem(SelectionCaption, 'Backup auswählen:', BackupNames, SelectedIndex) then
          begin
            if FServerBackupAction = sbaListRestoreBackups then
            begin
              if ConfirmServerRestore(AvailableBackupFolders[SelectedIndex]) then
                RestoreSourceFolder := AvailableBackupFolders[SelectedIndex];
            end
            else
              DownloadSourceFolder := AvailableBackupFolders[SelectedIndex];
          end;
        end
        else if (FServerBackupAction in [sbaStartBackup, sbaWatchBackup]) and OperationSucceeded and
          (CompletedBackupFolder <> '') then
        begin
          if CenteredMessageBox('Wollen Sie das Backup auf diesen Windows-Computer herunterladen?',
            'Backup herunterladen', MB_YESNO or MB_ICONQUESTION or MB_DEFBUTTON2) = IDYES then
            DownloadSourceFolder := CompletedBackupFolder;
        end;

        if (DownloadSourceFolder <> '') and not ApplicationClosing then
          CenteredSelectDirectory('Zielordner für den Backup-Download auswählen', DownloadTargetFolder);
      except
        on E: Exception do
        begin
          DownloadTargetFolder := '';
          if FServerBackupAction = sbaListRestoreBackups then
            CenteredMessageBox('Das Backup für die Wiederherstellung konnte nicht ausgewählt werden.' +
              sLineBreak + E.Message, 'Server-Wiederherstellung', MB_OK or MB_ICONWARNING)
          else
            CenteredMessageBox('Backup oder Zielordner konnte nicht ausgewählt werden.' + sLineBreak + E.Message,
              'Backup herunterladen', MB_OK or MB_ICONWARNING);
        end;
      end;
  finally
    EndServerBackupCheck;
  end;

  // Release the listing before starting the next server operation in the same progress UI.
  // Die Auflistung freigeben und die nächste Serveraktion in derselben Fortschrittsanzeige starten.
  if RestoreSourceFolder <> '' then
    BeginServerBackupCheck(RestoreSourceFolder, sbaStartRestore)
  else if DownloadTargetFolder <> '' then
    BeginServerBackupCheck(DownloadSourceFolder, sbaDownloadBackup, DownloadTargetFolder);
end;

// Confirm the backup, saved server and overwrite before the worker can start.
// Backup, gespeicherten Server und Überschreiben bestätigen, bevor der Restore-Container starten kann.
function TMainformFrm.ConfirmServerRestore(const BackupFolder: string): Boolean;
var
  Ini: TAppSettingsIni;
  Host: string;
begin
  Ini := TAppSettingsIni.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
  try
    Host := Ini.ReadString('Paperless Extern', 'Host', '').Trim;
  finally
    Ini.Free;
  end;
  Result := CenteredMessageBox(
    'Wollen Sie dieses Backup auf dem Server wiederherstellen?' + sLineBreak + sLineBreak +
    'Server: ' + Host + sLineBreak +
    'Backup: ' + BackupFolder + sLineBreak + sLineBreak +
    'Die aktuelle Paperless-Datenbank und die Ordner data, media und export werden überschrieben. ' +
    'Paperless übernimmt den Schlüssel aus dem Backup. Fehlt er, wird der Legacy-Schlüssel des Programms verwendet. ' +
    'Paperless ist während der Wiederherstellung vorübergehend nicht erreichbar.' + sLineBreak + sLineBreak +
    'Bestätigen Sie nur, wenn das Backup aus einer vertrauenswürdigen Quelle stammt. ' +
    'Der SQL-Dump wird mit den Rechten des Datenbankbenutzers ausgeführt.',
    'Server-Wiederherstellung starten?', MB_YESNO or MB_ICONWARNING or MB_DEFBUTTON2) = IDYES;
end;

// Release the process and the temporary result before accepting another check.
// Prozesshandle und temporäres Ergebnis freigeben, bevor eine weitere Prüfung möglich ist.
procedure TMainformFrm.EndServerBackupCheck;
begin
  if not FServerBackupCheckActive then Exit;
  if Assigned(FServerBackupCheckTimer) then FServerBackupCheckTimer.Enabled := False;
  if FServerBackupCheckHandle <> 0 then
  begin
    CloseHandle(FServerBackupCheckHandle);
    FServerBackupCheckHandle := 0;
  end;
  if FServerBackupCheckResultPath <> '' then
  begin
    DeleteFile(FServerBackupCheckResultPath + '.progress');
    DeleteFile(FServerBackupCheckResultPath);
    FServerBackupCheckResultPath := '';
  end;
  // Restore the shared busy state only after closing the server result dialog.
  // Die gemeinsame Bedienungssperre erst nach dem Schließen des Serverdialogs aufheben.
  if not ApplicationClosing then
  begin
    if FServerBackupProgressActive then
      EndScriptBusyState
    else
    begin
      StatusBar1.SimplePanel := False;
      InstallationModeRadioGroup.Enabled := FServerBackupModeWasEnabled;
      StartPaperlessBackupBtn.Enabled := True;
      CreateExternalBackupFolderBtn.Enabled := True;
    end;
  end;
  FServerBackupStatusText := '';
  FServerBackupAction := sbaCheckSpace;
  FServerBackupProgressActive := False;
  FServerBackupCheckActive := False;
  if not ApplicationClosing then UpdateServerBackupButtons;
end;

// Check the saved server folder before offering any backup for download.
// Den gespeicherten Serverordner prüfen, bevor ein Backup zum Download angeboten wird.
procedure TMainformFrm.LoadServerBackupBtnClick(Sender: TObject);
begin
  ProgramUpdateLbl.Hide;
  if ExternalInstallationSelected and not LocalInstallationSelected then
    BeginServerBackupCheck('', sbaListBackups);
end;

// Confirm the selected local backup and the persisted server destination before starting the upload.
// Das gewählte lokale Backup und das gespeicherte Serverziel vor dem Senden bestätigen lassen.
procedure TMainformFrm.SendServerBackupBtnClick(Sender: TObject);
var
  Ini: TAppSettingsIni;
  LocalBackupFolder, BackupName, ServerBackupFolder: string;
begin
  ProgramUpdateLbl.Hide;
  if not ExternalInstallationSelected or LocalInstallationSelected or ScriptBusy or
     FServerBackupCheckActive or ApplicationClosing then Exit;

  LocalBackupFolder := '';
  if not CenteredSelectDirectory('Lokalen Backupordner zum Senden auswählen', LocalBackupFolder) then Exit;
  BackupName := ExtractFileName(ExcludeTrailingPathDelimiter(LocalBackupFolder));
  if BackupName = '' then BackupName := LocalBackupFolder;

  try
    Ini := TAppSettingsIni.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
    try
      ServerBackupFolder := NormalizeServerBackupFolder(
        Ini.ReadString('Paperless Extern', IniKeyServerBackupFolder, DefaultServerBackupFolder));
    finally
      Ini.Free;
    end;
  except
    on E: Exception do
    begin
      CenteredMessageDlg('Der gespeicherte Server-Backupordner konnte nicht gelesen werden.' +
        sLineBreak + E.Message, mtWarning, [mbOK], 0);
      Exit;
    end;
  end;

  if CenteredMessageDlg('Wollen Sie das Backup „' + BackupName +
    '“ auf den Server in den gespeicherten Ordner „' + ServerBackupFolder + '“ kopieren?',
    mtConfirmation, [mbYes, mbNo, mbCancel], 0) = mrYes then
    BeginServerBackupCheck('', sbaUploadBackup, LocalBackupFolder);
end;

// Den Backup-Zielordner auswählen, speichern und die Backup-Skripte erstellen.
procedure TMainformFrm.StartPaperlessBackupBtnClick(Sender: TObject);
var
  FolderDialog: TFileOpenDialog;
  Ini:TAppSettingsIni;
  StoredPath: string;
  TextFilePath: string;
  PathChoice: Integer;
begin
  ProgramUpdateLbl.Hide;
  if ScriptBusy or FServerBackupCheckActive or ApplicationClosing then Exit;
  if LocalInstallationSelected = ExternalInstallationSelected then
  begin
    CenteredShowMessage('Die Betriebsart ist nicht eindeutig. Bitte die Einstellungen prüfen.');
    Exit;
  end;
  if LocalInstallationSelected and FLocalStartupPending then
  begin
    CenteredShowMessage('Bitte das Programm neu starten, um die lokale Installation vorzubereiten.');
    Exit;
  end;
  if ExternalInstallationSelected then
  begin
    // Allow reconnection to the server job without authorizing a second run.
    // Einen laufenden Serverjob erneut beobachten, ohne einen zweiten Lauf zu bestätigen.
    PathChoice := CenteredMessageDlg(
      'Ja: Server-Backup mit den gespeicherten Einstellungen starten. Paperless ist während der Sicherung vorübergehend nicht erreichbar.' +
      sLineBreak + sLineBreak +
      'Nein: Status des letzten oder laufenden Backups auf dem Server anzeigen.' + sLineBreak +
      'Abbrechen: Dialog schließen.',
      mtConfirmation, [mbYes, mbNo, mbCancel], 0);
    case PathChoice of
      mrYes: BeginServerBackupCheck('', sbaStartBackup);
      mrNo: BeginServerBackupCheck('', sbaWatchBackup);
    end;
    Exit;
  end;
  if System.SysUtils.DirectoryExists(ComposePath) then
    ComposePath := TPath.Combine(ComposePath, DockerComposeFileName);
  if not FileExists(ComposePath) then
  begin
    CenteredShowMessage('Bitte zuerst den Paperless-Ordner auswählen.');
    Exit;
  end;
  StartPaperlessBackupBtn.Enabled := False;
  RestorePaperlessBackupBtn.Enabled := False;
  try
    try
      IsPaperlessInstallation := False;

      Ini := TAppSettingsIni.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
      try
        Ini.WriteString('Pfade', 'DockerComposePfad', ComposePath);
        Ini.UpdateFile; // Write immediately.
        // Sofort schreiben.
      finally
        Ini.Free;
      end;

      IsBackup := True;

      DefaultFolder := IncludeTrailingPathDelimiter(GetEnvironmentVariable('USERPROFILE')) + 'Desktop\' + PaperlessBackupFolderName;
      if not System.SysUtils.DirectoryExists(DefaultFolder) then System.SysUtils.ForceDirectories(DefaultFolder);

      // Migrate the old backup target text file into the INI file.
      // Die alte Textdatei mit dem Backup-Ziel in die INI-Datei migrieren.
      TextFilePath := IncludeTrailingPathDelimiter(AppDataFolder) + BackupTargetFileName;
      if FileExists(TextFilePath) then
      begin
        StoredPath := TFile.ReadAllText(TextFilePath, TEncoding.UTF8).Trim;
        Ini := TAppSettingsIni.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
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
      Ini := TAppSettingsIni.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
      try
        LastBackupFolder := Ini.ReadString('Pfade', 'BackupZiel', '').Trim;
      finally
        Ini.Free;
      end;

      Sleep(500);

      if LastBackupFolder <> '' then
      begin
        PathChoice := mrYes;
        if not IsAutostart then
          PathChoice := CenteredMessageDlg('Es wurde folgender voreingestellter Pfad gefunden:' + sLineBreak + LastBackupFolder + sLineBreak + sLineBreak +
                       'Soll das Backup hier gespeichert werden?', mtConfirmation, [mbYes, mbNo], 0);
        if (PathChoice <> mrYes) and (PathChoice <> mrNo) then
        begin
          StartPaperlessBackupBtn.Enabled := True;
          RestorePaperlessBackupBtn.Enabled := True;
          Exit;
        end;
        if PathChoice = mrYes then
        begin
          BackupPath := IncludeTrailingPathDelimiter(LastBackupFolder) + FormatDateTime(BackupTimestampFormat, Now);
        end
        else
        begin
          FolderDialog := TFileOpenDialog.Create(nil);
          try
            FolderDialog.Options := [fdoPickFolders];
            FolderDialog.Title := 'Wählen Sie einen Backup-Ziel-Ordner aus.';
            FolderDialog.DefaultFolder := DefaultFolder;
            if CenteredFolderDialogExecute(FolderDialog) then
            begin
              BackupPath := IncludeTrailingPathDelimiter(FolderDialog.FileName) + FormatDateTime(BackupTimestampFormat, Now);



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
          if CenteredFolderDialogExecute(FolderDialog) then
          begin
            BackupPath := IncludeTrailingPathDelimiter(FolderDialog.FileName) + FormatDateTime(BackupTimestampFormat, Now);
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

      Ini := TAppSettingsIni.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
      try
        Ini.WriteString('Pfade', 'BackupZiel', ExtractFileDir(BackupPath));
        Ini.UpdateFile; // Write immediately.
        // Sofort schreiben.
      finally
        Ini.Free;
      end;

      CreateBackupScript(ComposePath);
      if FManualBackupSucceeded then
      begin
        if not SameText(ExcludeTrailingPathDelimiter(ExtractFilePath(BackupPath)),
          ExcludeTrailingPathDelimiter(DefaultFolder)) then
        begin
          try
            TFile.AppendAllText(IncludeTrailingPathDelimiter(DefaultFolder) + 'Wo ist mein Paperless Backup.txt',
              'Backup gespeichert in: ' + BackupPath + sLineBreak);
          except
            on E: Exception do LogWarning('Backup location note could not be written: ' + E.Message);
          end;
        end;
        CreateBackupPlanScript(ComposePath);
      end;
      // Delete the old marker file if it still exists.
      // Die alte Markerdatei löschen, falls sie noch existiert.
      TextFilePath := IncludeTrailingPathDelimiter(AppDataFolder) + ComposePathFileName;
      if FileExists(TextFilePath) then DeleteFile(TextFilePath);
    except
      on E: Exception do
      begin
        LogWarning('Backup could not be prepared: ' + E.Message);
        CenteredShowMessage('Das Backup konnte nicht vorbereitet werden: ' + E.Message);
      end;
    end;
  finally
    StartPaperlessBackupBtn.Enabled := True;
    RestorePaperlessBackupBtn.Enabled := True;
  end;
end;

// Create the manual worker without pre-creating the final backup directory.
// Den manuellen Worker erstellen, ohne den endgültigen Backupordner vorzeitig anzulegen.
procedure TMainformFrm.CreateBackupScript(const ComposePath: string);
var
  EncryptedMailPath, WorkerPath: string;
begin
  FManualBackupSucceeded := False;
  if not FileExists(ComposePath) then
  begin
    CenteredShowMessage('Fehler: Die gespeicherte Compose-Datei wurde nicht gefunden.');
    Exit;
  end;
  if not EncryptEmailEnvForBackup(EncryptedMailPath) then Exit;
  WorkerPath := '';
  try
    WorkerPath := ReserveTimestampedScript(ExtractFilePath(ComposePath));
    CreateManualBackupCmdScript(WorkerPath, ComposePath, BackupPath, AppDataFolder, EncryptedMailPath,
      KeepBackupsSpE.Value);
    CmdTargetPath := WorkerPath;
    StartAndMonitorCmdScript;
  finally
    if WorkerPath <> '' then DeleteGeneratedScriptFile(WorkerPath);
    if EncryptedMailPath <> '' then System.SysUtils.DeleteFile(EncryptedMailPath);
  end;
end;

// Die Anwendung vom Hauptformular aus schließen.
procedure TMainformFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if ScriptBusy and IsBackup then
  begin
    Action := caNone;
    CenteredShowMessage('Das Backup läuft noch. Bitte warten Sie auf das Ergebnis.');
    Exit;
  end;
  if FLocalRestoreActive then
  begin
    Action := caNone;
    CenteredShowMessage('Die lokale Wiederherstellung läuft noch. Bitte warten Sie auf das Ergebnis.');
    Exit;
  end;
  // Keep the installer connected until the server reports its final status.
  // Die Installationsverbindung bis zum abschließenden Serverstatus offen halten.
  if FServerBackupCheckActive and (FServerBackupAction = sbaInstallPaperless) and
     (FServerBackupCheckHandle <> 0) and
     (WaitForSingleObject(FServerBackupCheckHandle, 0) = WAIT_TIMEOUT) then
  begin
    Action := caNone;
    CenteredShowMessage('Die Serverinstallation läuft noch. Bitte warten Sie auf das Ergebnis.');
    Exit;
  end;
  ApplicationClosing := True;
  EndServerBackupCheck;
  CancelExternalStartupCheck;
  if FStartupCheckHandle <> 0 then
  begin
    CloseHandle(FStartupCheckHandle);
    FStartupCheckHandle := 0;
  end;
  WantsInstall := False;
  ShouldOpenPaperless := False;
  FreeAndNil(ScriptBusyControlStates);
  Action := caNone;         // Stop default close handling.
  // Die Standard-Schließbehandlung stoppen.
  PostQuitMessage(0);       // End the message loop.
  // Die Nachrichtenschleife beenden.
  Application.Terminate;
end;

// Fragt bei fehlender gültiger Pfadwahl den Installationsort ab, prüft Schreibzugriff und übernimmt die Laufzeitpfade.
// Ein übergeordneter Ordner muss nicht leer sein; der feste PG18-Unterordner bleibt erhalten. Abbruch oder Schließen liefert False.
function TMainformFrm.SelectInstallationFolder: Boolean;
var
  Folder, SourcePath, TargetPath, ProbePath: string;
  Ini: TAppSettingsIni;
  Names: array[0..2] of string;
  Name: string;
  PathChoice: Integer;
begin
  Result := False;
  if ApplicationClosing or Application.Terminated then Exit;
  if InstallationPathReady then Exit(True);
  Folder := DefaultInstallationFolder;
  PathChoice := CenteredMessageDlg(
    'Das Paperless Backup Programm wird standardmäßig in Ihrem Benutzerverzeichnis installiert.' + #13#10 +
    'Dadurch sind die Programmdateien normalerweise vor dem Zugriff anderer Benutzer geschützt.' + #13#10 +
    'Administratoren können weiterhin darauf zugreifen.' + #13#10 + #13#10 +
    'Sie können auch einen anderen Installationspfad wählen.' + #13#10 + #13#10 +
    'Möchten Sie den Installationspfad ändern?', mtConfirmation, [mbYes, mbNo], 0);
  if (PathChoice <> mrYes) and (PathChoice <> mrNo) then Exit;
  if PathChoice = mrYes then
  begin
    Folder := ExtractFileDir(AppDataFolder);
    if not CenteredSelectDirectory('Übergeordneten Installationsordner auswählen', Folder) then Exit;
    Folder := InstallationFolderUnderParent(Folder);
  end;
  if ApplicationClosing or Application.Terminated then Exit;
  Folder := ExcludeTrailingPathDelimiter(ExpandFileName(Folder));
  try
    if not System.SysUtils.DirectoryExists(Folder) and not System.SysUtils.ForceDirectories(Folder) then
      raise Exception.Create('Der Installationsordner kann nicht erstellt werden.');
    ProbePath := IncludeTrailingPathDelimiter(Folder) + TGUID.NewGuid.ToString + '.tmp';
    TFile.WriteAllText(ProbePath, '', TEncoding.UTF8);
    TFile.Delete(ProbePath);
    if LocalInstallationSelected and not SameFileName(Folder, AppDataFolder) then
    begin
      Names[0] := SettingsFileName;
      Names[1] := EmailEnvFileName;
      Names[2] := EmailEnvEncryptedFileName;
      for Name in Names do
      begin
        SourcePath := IncludeTrailingPathDelimiter(AppDataFolder) + Name;
        TargetPath := IncludeTrailingPathDelimiter(Folder) + Name;
        if FileExists(SourcePath) and not FileExists(TargetPath) then
          TFile.Copy(SourcePath, TargetPath, False);
      end;
    end;
    Ini := TAppSettingsIni.Create(IncludeTrailingPathDelimiter(Folder) + SettingsFileName);
    try
      if LocalInstallationSelected then
        Ini.WriteString('Pfade', 'DockerComposePfad', IncludeTrailingPathDelimiter(Folder) + DockerComposeFileName);
      if ExternalInstallationSelected then
        Ini.WriteString('Paperless Extern', 'Betriebsart', 'Extern')
      else
        Ini.WriteString('Paperless Extern', 'Betriebsart', 'Lokal');
      if NoticeAcceptedBeforeInstallation then
      begin
        Ini.WriteString('Einrichtung', 'Hinweis verstanden', 'Ja');
        Ini.WriteDateTime('Einrichtung', 'Hinweis zuletzt verstanden', Now);
      end;
      Ini.UpdateFile;
    finally
      Ini.Free;
    end;
    SaveInstallationFolder(Folder);
    AppDataFolder := Folder;
    InstallationPathReady := True;
    NoticeAcceptedBeforeInstallation := False;
    ComposePath := IncludeTrailingPathDelimiter(Folder) + DockerComposeFileName;
    NewComposePath := ComposePath;
    BackupTargetFilePath := IncludeTrailingPathDelimiter(Folder) + BackupTargetFileName;
    NoticeFilePath := IncludeTrailingPathDelimiter(Folder) + NoticeAcceptedFileName;
    InstallationCompletedFilePath := IncludeTrailingPathDelimiter(Folder) + InstallationCompletedFileName;
    CmdTargetPath := '';
    if LocalInstallationSelected then
    begin
      InitLogger(Folder);
      SaveEmptyEnvFile;
    end;
    Result := True;
  except
    on E: Exception do
      CenteredShowMessage('Installationspfad konnte nicht übernommen werden: ' + E.Message);
  end;
end;
// Lädt den gewählten Installationspfad und initialisiert Laufzeitstatus und Fortschrittsanzeige.
// Logger erst bei bestätigtem, existierendem Ziel initialisieren; vor der Pfadwahl keine Laufzeitdateien anlegen.
procedure TMainformFrm.FormCreate(Sender: TObject);
var
  Ini: TAppSettingsIni;
begin
  ApplicationClosing := False;
  FVersionsReady := False;
  InstallationModeRadioGroup.ItemIndex := 0;
  InstallationModeRadioGroupClick(nil);
  AppDataFolder := LoadInstallationFolder;
  NoticeAcceptedBeforeInstallation := False;
  InstallationPathReady := FileExists(InstallationPathIniFile) or
    FileExists(IncludeTrailingPathDelimiter(AppDataFolder) + InstallationCompletedFileName);
  if not InstallationPathReady then
  begin
    Ini := TAppSettingsIni.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
    try
      InstallationPathReady := Ini.ReadString('Einrichtung', 'Installation abgeschlossen', '') = 'Ja';
    finally
      Ini.Free;
    end;
  end;
  // Existing installations keep their selected path, including external folders.
  // Bestehende Installationen behalten ihren gewählten Pfad, auch außerhalb des Benutzerprofils.
  InstallationPathReady := InstallationPathReady and
    System.SysUtils.DirectoryExists(AppDataFolder);
  // Load mode before local runtime files are touched.
  // Betriebsart vor lokalen Dateizugriffen laden.
  if InstallationPathReady then LoadStoredInstallationMode;
  UpdateInstallationModeHeaders;
  // Do not create a runtime folder or log before the first path selection.
  // Vor der ersten Pfadwahl weder Laufzeitordner noch Log anlegen.
  if InstallationPathReady and LocalInstallationSelected then
  begin
    if not System.SysUtils.DirectoryExists(AppDataFolder) then System.SysUtils.ForceDirectories(AppDataFolder);
    InitLogger(AppDataFolder);
    LogInfo('Application started.');
    // Repair missing scripts at startup after the installation path is confirmed.
    // Fehlende Skripte beim Start nach bestätigtem Installationspfad ergänzen.
    EnsurePaperlessScripts(AppDataFolder);
  end;
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
  IsRestoreApplyingSettings := False;
  ClearRestoreProgressState;
  InstallationProgressLastTick := 0;
  TrashRetentionDays := 365;
  ScriptBusy := False;
  ScriptBusyTabIndex := 0;
  ScriptBusyControlStates := nil;
  InstallCancelRequested := False;
  RunningScriptProcessId := 0;
  BusyWaitLbl.Visible := False;
  ProgressBar1.Visible := False;
  ProgressBar1.Position := 0;
end;

// Bereitet gespeicherte Einstellungen und Oberfläche vor; kann Hinweis, Pfadwahl und Installation auslösen.
// Die Erinnerung prüft feste 30-Tage-Intervalle ab Installationsdatum beim Anzeigen des Hauptfensters; es gibt keinen laufenden Erinnerungstimer.
procedure TMainformFrm.FormShow(Sender: TObject);
var
  StartParameter: string;
  Ini: TAppSettingsIni;
  Value: string;
  SettingsPath: string;
  LastNoticeAccepted: TDateTime;
  InstallationDate: TDateTime;
  ComposePathTextFile: string;
  OldPath: string;
  StoredPath: string;
  TextFilePath: String;
  FirstModeChoice: Integer;
begin
  if ApplicationClosing or Application.Terminated then Exit;
  Label38.Caption := 'Valkey-Version:';
  Label3.Caption := 'Paperles-ngx v3';
  Label6.Caption := 'Paperles-ngx v3';
  Label9.Caption := 'Paperles-ngx v3';
  Label14.Caption := 'Paperles-ngx v3';
  Label28.Caption := 'Paperles-ngx v3';
  Label29.Caption := 'Paperles-ngx v3';

  AppDataFolder := LoadInstallationFolder;

  // Choose the first operating mode before local setup or Docker checks.
  // Die erste Betriebsart vor lokaler Einrichtung und Dockerpruefung auswaehlen.
  if not InstallationPathReady then
  begin
    FirstModeChoice := CenteredMessageDlg(
      'Soll Paperless lokal installiert werden?' + sLineBreak + sLineBreak +
      'Ja: lokale Installation mit Docker Desktop.' + sLineBreak +
      'Nein: vorhandene Paperless-Installation auf einem Server verwenden.',
      mtConfirmation, [mbYes, mbNo, mbCancel], 0);
    if (FirstModeChoice <> mrYes) and (FirstModeChoice <> mrNo) then
    begin
      Application.Terminate;
      Exit;
    end;
    ExternalInstallationSelected := FirstModeChoice = mrNo;
    LocalInstallationSelected := not ExternalInstallationSelected;
    if ExternalInstallationSelected then
    begin
      InstallationModeRadioGroup.ItemIndex := 1;
      FLocalStartupPending := True;
    end
    else
      InstallationModeRadioGroup.ItemIndex := 0;
    UpdateInstallationModeHeaders;
  end;

  // Create the desktop consume folder if it does not exist.
  // Den Consume-Ordner auf dem Desktop erstellen, falls er nicht existiert.
  PaperlessInput := IncludeTrailingPathDelimiter(GetEnvironmentVariable('USERPROFILE')) + 'Desktop\' + PaperlessInputFolderName;
  if InstallationPathReady and LocalInstallationSelected then
  begin
    if not System.SysUtils.DirectoryExists(PaperlessInput) then System.SysUtils.ForceDirectories(PaperlessInput);
    SaveEmptyEnvFile();
  end;

  if LocalInstallationSelected then
  begin
  // Check whether the user already accepted the notice.
  // Prüfen, ob der Benutzer den Hinweis bereits akzeptiert hat.
  SettingsPath := IncludeTrailingPathDelimiter(Mainform.AppDataFolder) + SettingsFileName;
  Ini := TAppSettingsIni.Create(SettingsPath);
  try
    Value := Ini.ReadString('Einrichtung', 'Hinweis verstanden', '');
    LastNoticeAccepted := Ini.ReadDateTime('Einrichtung', 'Hinweis zuletzt verstanden', 0);
    InstallationDate := Ini.ReadDateTime('Einrichtung', 'Installationsdatum', 0);
    if (InstallationDate = 0) and (Value = 'Ja') and InstallationPathReady and
       FileExists(SettingsPath) then
    begin
      // Für ältere Installationen fehlt ein genaues Datum: Dateierstellung einmalig als Näherung speichern.
      InstallationDate := Trunc(TFile.GetCreationTime(SettingsPath));
      Ini.WriteDateTime('Einrichtung', 'Installationsdatum', InstallationDate);
    end;
  finally
    Ini.Free;
  end;
  if Value = 'Ja' then
  begin
    NoticeFilePath := IncludeTrailingPathDelimiter(Mainform.AppDataFolder) + NoticeAcceptedFileName;
    // Delete the old notice file after the INI value exists.
    // Die alte Hinweisdatei löschen, nachdem der INI-Wert vorhanden ist.
    if InstallationPathReady and FileExists(NoticeFilePath) then DeleteFile(NoticeFilePath);

    // Feste Intervalle ab Installation; eine spätere Bestätigung verschiebt den nächsten Termin nicht.
    if NoticeReminderDue(InstallationDate, LastNoticeAccepted, Date) then
    begin
      SetupFrm := TSetupFrm.Create(Self);
      try
        NoticeReminderMode := True;
        SetupFrm.ShowModal;
      finally
        NoticeReminderMode := False;
        SetupFrm.Free;
        SetupFrm := nil;
      end;
      if ApplicationClosing or Application.Terminated then Exit;
    end;
  end else
    begin
      SetupFrm := TSetupFrm.Create(Self);
      try
        NoticeReminderMode := False;
        SetupFrm.ShowModal;
      finally
        SetupFrm.Free;
        SetupFrm := nil;
      end;
      if ApplicationClosing or Application.Terminated then Exit;
  end;



  end;

  if ApplicationClosing or Application.Terminated then Exit;
  // A notice can be accepted before the install button is used.
  // Nach dem Hinweis erst den Pfad bestätigen, dann Einstellungen vorbereiten.
  if not InstallationPathReady then
  begin
    if not SelectInstallationFolder then
    begin
      Application.Terminate;
      Exit;
    end;
    if LocalInstallationSelected and not System.SysUtils.DirectoryExists(PaperlessInput) then System.SysUtils.ForceDirectories(PaperlessInput);
  end;
  // Create the section after the installation path is ready.
  // Den Abschnitt erst nach bestaetigtem Installationspfad anlegen.
  EnsureExternalPaperlessSection(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
  try
    LoadExternalServerSettings;
    BeginExternalStartupCheck;
  except
    on E: Exception do
      CenteredShowMessage('Serverdaten konnten nicht geladen werden. Speichern bleibt gesperrt. ' + E.Message);
  end;
  if LocalInstallationSelected then
  begin
  TextFilePath := IncludeTrailingPathDelimiter(AppDataFolder) + ComposePathFileName;
  if FileExists(TextFilePath) then
  begin
    // Read the old path from the text file.
    // Den alten Pfad aus der Textdatei lesen.
    OldPath := TFile.ReadAllText(TextFilePath, TEncoding.UTF8).Trim;

    // Store it in the INI file.
    // Den Wert in der INI-Datei speichern.
    Ini := TAppSettingsIni.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
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

  end;

  IsBackup := True;

  if LocalInstallationSelected then
  begin
  DefaultFolder := IncludeTrailingPathDelimiter(GetEnvironmentVariable('USERPROFILE')) + 'Desktop\' + PaperlessBackupFolderName;
  if not System.SysUtils.DirectoryExists(DefaultFolder) then System.SysUtils.ForceDirectories(DefaultFolder);

  // Migrate the old backup target text file into the INI file.
  // Die alte Textdatei mit dem Backup-Ziel in die INI-Datei migrieren.
  TextFilePath := IncludeTrailingPathDelimiter(AppDataFolder) + BackupTargetFileName;
  if FileExists(TextFilePath) then
  begin
    StoredPath := TFile.ReadAllText(TextFilePath, TEncoding.UTF8).Trim;
    Ini := TAppSettingsIni.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
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

  end;

  // Read the last backup folder from the INI file.
  // Den letzten Backup-Ordner aus der INI-Datei lesen.
  Ini := TAppSettingsIni.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
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

  if LocalInstallationSelected then
  begin
  ComposePathTextFile := IncludeTrailingPathDelimiter(AppDataFolder) + ComposePathFileName;
  if FileExists(ComposePathTextFile) then
    begin
      // Read the old path from the text file.
      // Den alten Pfad aus der Textdatei lesen.
      OldPath := TFile.ReadAllText(ComposePathTextFile, TEncoding.UTF8);

      // Store it in the INI file.
      // Den Wert in der INI-Datei speichern.
      Ini := TAppSettingsIni.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
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

  Ini := TAppSettingsIni.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
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
      Ini := TAppSettingsIni.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
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
  Ini := TAppSettingsIni.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
  try
    Value := Ini.ReadString('Einrichtung', 'Installation abgeschlossen', '');
  finally
    Ini.Free;
  end;

  if Value <> 'Ja' then
  begin
    NewComposePath := IncludeTrailingPathDelimiter(AppDataFolder) + DockerComposeFileName;

    if not (ApplicationClosing or Application.Terminated) then
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
    NewComposePath := IncludeTrailingPathDelimiter(AppDataFolder) + DockerComposeFileName;
    ComposePath := NewComposePath;
  end else
    begin
      ComposePath := IncludeTrailingPathDelimiter(AppDataFolder) + DockerComposeFileName;
    end;

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

  Ini := TAppSettingsIni.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
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
    OpenManualBtn.Visible := False;
    BackupWiederherProgNeuStartLbl.Visible:=False;
    TabControl1.Enabled:=False;
    IsAutostart := True;
    RunAutostartBackup();
  end else
    begin
    end;

   // Read trash retention from the INI file and show it in the edit field.
   // Papierkorb-Aufbewahrung aus der INI-Datei lesen und im Eingabefeld anzeigen.
   Ini := TAppSettingsIni.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
   try
    try
      TrashRetentionDays := Ini.ReadInteger('Einstellungen', 'Papierkorb Aufbewahrungszeit in Tagen', 365);
    except
      TrashRetentionDays := 365;
    end;
    PapierkorbAufbewahrungEdit.Text := IntToStr(TrashRetentionDays);
    // Restore the saved checkmark without showing the activation warning at startup.
    // Gespeicherten Haken beim Start ohne erneute Aktivierungswarnung laden.
    FLoadingCustomFileProtection := True;
    try
      ProtectCustomFilesCB.Checked := Ini.ReadBool('Einstellungen', IniKeyProtectCustomFiles, False);
    finally
      FLoadingCustomFileProtection := False;
    end;
    UpdateComposeProtectionControls;
   finally
    Ini.Free;
   end;

   if LocalInstallationSelected then
     WriteComposeContainerAndVolumeInfo(ExtractFilePath(ComposePath));


  Ini := TAppSettingsIni.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
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

    // Preserve saved custom tags; missing values use Gotenberg 8 and Tika 3.2.3.0.
    // Gespeicherte Tags behalten; fehlende Werte erhalten Gotenberg 8 und Tika 3.2.3.0.
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
  if ExternalInstallationSelected then
  begin
    LoadVersionsForMode(True);
    ProtectCustomFilesCB.Enabled := False;
    PapierkorbAufbewahrungEdit.Enabled := False;
    CheckBox1.Enabled := True;
    CheckBox1Click(nil);
  end
  else
    CaptureVersionSnapshot;
  FVersionsReady := True;

  LoadUpdateIniFile();
end;

// Ein Backup starten, wenn das Programm von der Windows-Aufgabenplanung gestartet wurde.
procedure TMainformFrm.RunAutostartBackup();
begin
  // Kept as a small wrapper for scheduled starts.
  // Als kleiner Wrapper für geplante Starts beibehalten.
  StartPaperlessBackupBtn.Click;
end;

// Das manuelle Backup-Skript für den aktuellen Compose-Pfad neu erstellen und ausführen.
procedure TMainformFrm.StartPaperlessBackupScriptBtnClick(Sender: TObject);
begin
  if LocalInstallationSelected and FLocalStartupPending then
  begin
    CenteredShowMessage('Bitte das Programm neu starten, um die lokale Installation vorzubereiten.');
    Exit;
  end;
  if ExternalInstallationSelected then
  begin
    CenteredShowMessage('Externe Serveraktionen sind noch nicht verfügbar.');
    Exit;
  end;
  CreateBackupScript(ComposePath);
end;

// Switch between the main panels and refresh panel-specific settings.
// Zwischen den Hauptbereichen wechseln und bereichsspezifische Einstellungen aktualisieren.
procedure TMainformFrm.TabControl1Change(Sender: TObject);
var
  Ini: TAppSettingsIni;
begin
  ProgramUpdateLbl.Hide;
  if ScriptBusy then
  begin
    TabControl1.TabIndex := ScriptBusyTabIndex;
    Exit;
  end;
  // Clear the save confirmation when switching tabs.
  // Die Speicherbestätigung beim Tabwechsel ausblenden.
  RetentionSavedLbl.Visible := False;
  if LocalInstallationSelected then
  begin
  Ini := TAppSettingsIni.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
    try
      Ini.WriteString('Pfade', 'DockerComposePfad', IncludeTrailingPathDelimiter(ExtractFilePath(ComposePath)) + DockerComposeFileName);
      Ini.UpdateFile; // Write immediately.
      // Sofort schreiben.
    finally
      Ini.Free;
    end;

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
  Ini: TAppSettingsIni;
  ComposeFile, ComposeDir, PlannedScript, BackupBase: string;
begin
  ProgramUpdateLbl.Hide;
  if LocalInstallationSelected and FLocalStartupPending then
  begin
    CenteredShowMessage('Bitte das Programm neu starten, um die lokale Installation vorzubereiten.');
    Exit;
  end;
  if ExternalInstallationSelected then
  begin
    CenteredShowMessage('Externe Serveraktionen sind noch nicht verfügbar.');
    Exit;
  end;
  FRetentionRestartChoice := CenteredMessageDlg(
    'Paperless muss neu gestartet werden, um die Einstellungen zu übernehmen. Möchten Sie Paperless neu starten?',
    mtConfirmation, [mbYes, mbNo], 0);
  if (FRetentionRestartChoice <> mrYes) and (FRetentionRestartChoice <> mrNo) then Exit;
  Ini := TAppSettingsIni.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
  try
    // Save the retention setting.
    // Die Aufbewahrungseinstellung speichern.
    Ini.WriteInteger('Zeitplan', 'BackupsBehalten', KeepBackupsSpE.Value);
    ComposeFile := Ini.ReadString('Pfade', 'DockerComposePfad', '').Trim;
    BackupBase := Ini.ReadString('Pfade', 'BackupZiel', '').Trim;
    // Write immediately.
    // Sofort schreiben.
    Ini.UpdateFile;
  finally
    Ini.Free;
  end;
  // Reuse the settings save action, including its restart confirmation.
  // Die Einstellungen-Speichern-Funktion mit ihrer Neustartfrage verwenden.
  FRetentionUpdateRequested := True;
  FRetentionUpdateSucceeded := False;
  try
    SaveSettingsBtnClick(SaveSettingsBtn);
  finally
    FRetentionUpdateRequested := False;
  end;
  // Update only the existing planned script, without running retention here.
  // Nur das vorhandene geplante Skript aktualisieren, ohne hier aufzuräumen.
  if (ComposeFile <> '') and System.SysUtils.DirectoryExists(ComposeFile) then
    ComposeFile := IncludeTrailingPathDelimiter(ComposeFile) + DockerComposeFileName;
  if (ComposeFile <> '') and FileExists(ComposeFile) then
  begin
    ComposeDir := ExtractFilePath(ComposeFile);
    PlannedScript := IncludeTrailingPathDelimiter(ComposeDir) + 'paperless-backup-geplant.ps1';
    if FileExists(PlannedScript) then
    begin
      if BackupBase = '' then
        BackupBase := IncludeTrailingPathDelimiter(GetEnvironmentVariable('USERPROFILE')) + 'Desktop\FallbackBackup\';
      try
        CreatePlannedBackupCmdScript(PlannedScript, ComposeFile, BackupBase, AppDataFolder, KeepBackupsSpE.Value);
      except
        on E: Exception do
          CenteredShowMessage('Die Anzahl wurde gespeichert. Das geplante Backup-Skript konnte nicht aktualisiert werden: ' + E.Message);
      end;
    end;
  end;
  // Show confirmation only after the settings were saved successfully.
  // Bestätigung erst nach erfolgreichem Speichern der Einstellungen anzeigen.
  RetentionSavedLbl.Visible := True;
  // Show the label only when all backups are kept.
  // Die Beschriftung nur anzeigen, wenn alle Backups behalten werden.
  if KeepBackupsSpE.Value = 0 then
  AllBackupsAreRetainedLbl.Visible := True else
  AllBackupsAreRetainedLbl.Visible := False;
  if FRetentionUpdateSucceeded and not ApplicationClosing and not Application.Terminated then
  begin
    TabControl1.TabIndex := 2;
    TabControl1Change(TabControl1);
    RetentionSavedLbl.Visible := True;
  end;
  FRetentionUpdateSucceeded := False;
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
  Ini: TAppSettingsIni;
begin
  Ini := TAppSettingsIni.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
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

// Die Windows-Aufgabe für automatische Backups entfernen.
procedure TMainformFrm.DeleteBackupPlanBtnClick(Sender: TObject);
var
  ShellExecuteInfo: TShellExecuteInfo;
  CmdTargetPath: string;
  Ini: TAppSettingsIni;
  ExitCode: DWORD;
begin
  ProgramUpdateLbl.Hide;
  if LocalInstallationSelected and FLocalStartupPending then
  begin
    CenteredShowMessage('Bitte das Programm neu starten, um die lokale Installation vorzubereiten.');
    Exit;
  end;
  if ExternalInstallationSelected then
  begin
    CenteredShowMessage('Externe Serveraktionen sind noch nicht verfügbar.');
    Exit;
  end;
  // Create a script that removes the scheduled task.
  // Ein Skript erstellen, das die geplante Aufgabe entfernt.
  CmdTargetPath := IncludeTrailingPathDelimiter(AppDataFolder) + 'Backup-Zeitplan-Entfernen.ps1';
  CreateDeleteBackupScheduleCmdScript(CmdTargetPath);
  try
    // Run the script silently in the background.
    // Das Skript still im Hintergrund ausführen.
    FillChar(ShellExecuteInfo, SizeOf(ShellExecuteInfo), 0);
    ShellExecuteInfo.cbSize := SizeOf(ShellExecuteInfo);
    ShellExecuteInfo.fMask := SEE_MASK_NOCLOSEPROCESS;
    ShellExecuteInfo.Wnd := 0;
    ShellExecuteInfo.lpFile := PChar('powershell.exe');
    ShellExecuteInfo.lpParameters := PChar('-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "' + CmdTargetPath + '"');
    ShellExecuteInfo.nShow := SW_HIDE;
    if ShellExecuteEx(@ShellExecuteInfo) then
    begin
      if ShellExecuteInfo.hProcess <> 0 then
      begin
        WaitForSingleObject(ShellExecuteInfo.hProcess, INFINITE);
        ExitCode := 1;
        GetExitCodeProcess(ShellExecuteInfo.hProcess, ExitCode);
        CloseHandle(ShellExecuteInfo.hProcess);
        if ExitCode <> 0 then
          CenteredShowMessage('Der geplante Backup-Zeitplan konnte nicht vollständig entfernt werden.');
      end;
    end
    else
      CenteredShowMessage('Zeitplan-Entfernen-Skript konnte nicht gestartet werden.');
  finally
    DeleteGeneratedScriptFile(CmdTargetPath);
  end;

  // Reset the checkbox.
  // Die Checkbox zurücksetzen.
  AutoBackupCB.Checked := False;
  // Disable related controls and save the setting.
  // Zugehörige Steuerelemente deaktivieren und die Einstellung speichern.
  AutoBackupCBClick(nil);
  // Make sure the INI value is set to False.
  // Sicherstellen, dass der INI-Wert auf False gesetzt ist.
  Ini := TAppSettingsIni.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
  try
    Ini.WriteBool('Zeitplan', 'Backup nach diesem Zeitplan', False);
  finally
    Ini.Free;
  end;
  CenteredShowMessage('Der geplante Backup-Zeitplan wurde entfernt.');
end;

// Gespeicherte Zeitplaneinstellungen in die Formularsteuerelemente laden.
procedure TMainformFrm.LoadScheduleSettings;
var
  Ini: TAppSettingsIni;
  ComposeFile, PlannedScript: string;
begin
  Ini := TAppSettingsIni.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
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
    ComposeFile := Ini.ReadString('Pfade', 'DockerComposePfad', '').Trim;
  finally
    Ini.Free;
  end;

  // Upgrade an existing generated task script in place before its next scheduled run.
  // Ein vorhandenes Aufgabenskript vor dem nächsten geplanten Lauf am selben Pfad aktualisieren.
  if LocalInstallationSelected and not ExternalInstallationSelected and InstallationPathReady then
  begin
    if System.SysUtils.DirectoryExists(ComposeFile) then
      ComposeFile := TPath.Combine(ComposeFile, DockerComposeFileName);
    if FileExists(ComposeFile) then
    begin
      PlannedScript := TPath.Combine(ExtractFilePath(ComposeFile), 'paperless-backup-geplant.ps1');
      try
        if FileExists(PlannedScript) and not TFile.ReadAllText(PlannedScript, TEncoding.UTF8).StartsWith(LocalBackupScriptMarker) then
          CreateBackupPlanScript(ComposeFile);
      except
        on E: Exception do
        begin
          LogWarning('Planned backup script could not be refreshed: ' + E.Message);
          CenteredShowMessage('Das vorhandene Aufgabenskript konnte nicht aktualisiert werden: ' + E.Message);
        end;
      end;
    end;
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

// Die Windows-Aufgabe für automatische Backups erstellen oder aktualisieren.
procedure TMainformFrm.CreateBackupPlanBtnClick(Sender: TObject);
var
  Weekdays: string;
  Hour, Minute: string;
  ScriptPath, ComposePath, TargetCmdPath: string;
  ShellExecuteInfo: TShellExecuteInfo;
  ExitCode: DWORD;
  Ini: TAppSettingsIni;
  ComposePathFromIni: string;
  ComposePathTextFile: string;
  OriginalButtonText: string;
begin
  ProgramUpdateLbl.Hide;
  if LocalInstallationSelected and FLocalStartupPending then
  begin
    CenteredShowMessage('Bitte das Programm neu starten, um die lokale Installation vorzubereiten.');
    Exit;
  end;
  if ExternalInstallationSelected then
  begin
    CenteredShowMessage('Externe Serveraktionen sind noch nicht verfügbar.');
    Exit;
  end;
  ScriptPath := '';
  OriginalButtonText := CreateBackupPlanBtn.Caption;
  CreateBackupPlanBtn.Caption := 'Bitte warten ...';
  CreateBackupPlanBtn.Enabled := False;
  try
  SaveScheduleSettings;
  // Check prerequisites.
  // Voraussetzungen prüfen.
  // Read the docker-compose path from the INI file.
  // Den docker-compose-Pfad aus der INI-Datei lesen.
  Ini := TAppSettingsIni.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
  try
    ComposePathFromIni := Ini.ReadString('Pfade', 'DockerComposePfad', '').Trim;
  finally
    Ini.Free;
  end;
  if (ComposePathFromIni <> '') and System.SysUtils.DirectoryExists(ComposePathFromIni) then
    ComposePathFromIni := IncludeTrailingPathDelimiter(ComposePathFromIni) + DockerComposeFileName;
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
    Ini := TAppSettingsIni.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
    try
      ComposePath := Ini.ReadString('Pfade', 'DockerComposePfad', '').Trim;
    finally
      Ini.Free;
    end;
    if (ComposePath <> '') and System.SysUtils.DirectoryExists(ComposePath) then
      ComposePath := IncludeTrailingPathDelimiter(ComposePath) + DockerComposeFileName;
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
  // The scheduled task starts the planned backup PowerShell script.
  // Die geplante Aufgabe startet das geplante Backup-PowerShell-Skript.
  CreateBackupScheduleCmdScript(ScriptPath, TargetCmdPath, Weekdays, Hour, Minute);
  // Run the script silently in the background.
  // Das Skript still im Hintergrund ausführen.
  FillChar(ShellExecuteInfo, SizeOf(ShellExecuteInfo), 0);
  ShellExecuteInfo.cbSize := SizeOf(ShellExecuteInfo);
  ShellExecuteInfo.fMask := SEE_MASK_NOCLOSEPROCESS;
  ShellExecuteInfo.Wnd := 0;
  ShellExecuteInfo.lpFile := PChar('powershell.exe');
  ShellExecuteInfo.lpParameters := PChar('-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "' + ScriptPath + '"');
  ShellExecuteInfo.nShow := SW_HIDE;
  if ShellExecuteEx(@ShellExecuteInfo) then
  begin
    if ShellExecuteInfo.hProcess <> 0 then
    begin
      WaitForSingleObject(ShellExecuteInfo.hProcess, INFINITE);
      ExitCode := 1;
      GetExitCodeProcess(ShellExecuteInfo.hProcess, ExitCode);
      CloseHandle(ShellExecuteInfo.hProcess);
      if ExitCode = 0 then
        CenteredShowMessage('Geplantes Backup wurde erfolgreich angelegt.')
      else
        CenteredShowMessage('Geplantes Backup konnte nicht angelegt werden.');
    end
    else
      CenteredShowMessage('Geplantes Backup konnte nicht angelegt werden.');
  end
  else
    CenteredShowMessage('Zeitplan-Anlegen-Skript konnte nicht gestartet werden.');
  finally
    DeleteGeneratedScriptFile(ScriptPath);
    CreateBackupPlanBtn.Caption := OriginalButtonText;
    CreateBackupPlanBtn.Enabled := True;
  end;
end;

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
        // Copy saved values into the edit fields without starting setup actions.
        // Gespeicherte Werte in die Eingabefelder uebernehmen, ohne Einrichtungsaktionen zu starten.
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
  Ini: TAppSettingsIni;
  RestartChoice: Integer;
begin
  ProgramUpdateLbl.Hide;
  if LocalInstallationSelected and FLocalStartupPending then
  begin
    CenteredShowMessage('Bitte das Programm neu starten, um die lokale Installation vorzubereiten.');
    Exit;
  end;
  // External saves must not update local settings or start local containers.
  // Externes Speichern darf lokale Einstellungen und Container nicht veraendern.
  if ExternalInstallationSelected then
  begin
    try
      SaveVersionsForMode(True);
      SettingsSavedLbl.Visible := True;
    except
      on E: Exception do
        CenteredShowMessage('Externe Imageversionen konnten nicht gespeichert werden: ' + E.Message);
    end;
    Exit;
  end;
  RestartChoice := mrYes;
  if FRetentionUpdateRequested then
    RestartChoice := FRetentionRestartChoice
  else if Sender <> nil then
  begin
    RestartChoice := CenteredMessageDlg(
      'Paperless muss neu gestartet werden, um die Einstellungen zu übernehmen. ' +
      'Möchten Sie Paperless neu starten?', mtConfirmation, [mbYes, mbNo], 0);
    if (RestartChoice <> mrYes) and (RestartChoice <> mrNo) then Exit;
  end;
  Ini := TAppSettingsIni.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
  try
    // --------------------------------------------------------------
    // Section 1: Save general settings.
    // Abschnitt 1: Allgemeine Einstellungen speichern.
    // --------------------------------------------------------------
    // Save protection before Compose and script generation can run.
    // Schutz vor einer möglichen Compose- und Skripterzeugung speichern.
    Ini.WriteBool('Einstellungen', IniKeyProtectCustomFiles, ProtectCustomFilesCB.Checked);
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
    CaptureVersionSnapshot;

  finally
    Ini.Free;
  end;

  // --------------------------------------------------------------
  // Section 3: Ask whether Paperless should be restarted.
  // Abschnitt 3: Fragen, ob Paperless neu gestartet werden soll.
  // --------------------------------------------------------------
  // Run automatically when called after a restore; ask only for direct button clicks.
  // Nach einer Wiederherstellung automatisch ausführen; nur bei direktem Button-Klick nachfragen.
  if RestartChoice = mrYes then
  begin
    // Clear stale backup state before starting the settings update.
    // Vor dem Einstellungsupdate alten Backup-Zustand löschen, damit der Statustext stimmt.
    IsBackup := False;
    IsUpdate := True;
    if not IsRestoreApplyingSettings then
      CenteredMessageBox(
        'Paperless wird heruntergefahren und es wird nach Updates gesucht. ' + #13#10 +
        'Sollten Updates vorliegen, werden diese installiert.' + #13#10 +
        'Geben Sie Paperless nach dem Neustart Zeit.',
        'Info', MB_OK or MB_ICONINFORMATION or MB_TOPMOST);
    TabControl1.TabIndex := 0;
    TabControl1Change(TabControl1);
    // Revoke version edit permission after the tab switch; saved values remain intact.
    // Nach dem Tabwechsel Versionsbearbeitung sperren; gespeicherte Werte bleiben erhalten.
    CheckBox1.Checked := False;
    // Apply the lock explicitly, even if confirmation was already unchecked.
    // Sperre ausdrücklich anwenden, auch wenn die Bestätigung bereits abgewählt war.
    CheckBox1Click(nil);
    Application.ProcessMessages;
    PaperlessUpdate := True;
    IsUpdate := True;
    CreateDockerComposeWithSetupForm;
  end;
end;


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
  if not System.SysUtils.DirectoryExists(AppDataFolder) then
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
    if Trim(SMTPPortEdit.Text) = '' then
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
      EnvList.Add('PAPERLESS_EMAIL_USE_TLS=false');
      EnvList.Add('PAPERLESS_EMAIL_USE_SSL=false');
    end;

    // Save the file.
    // Die Datei speichern.
    EnvList.SaveToFile(EnvFilePath, TEncoding.UTF8);
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
  ProgramUpdateLbl.Hide;
  if LocalInstallationSelected and FLocalStartupPending then
  begin
    CenteredShowMessage('Bitte das Programm neu starten, um die lokale Installation vorzubereiten.');
    Exit;
  end;
  if ExternalInstallationSelected then
  begin
    CenteredShowMessage('Externe Serveraktionen sind noch nicht verfügbar.');
    Exit;
  end;
  SettingsSaved := False;
  // Build the full path to the file.
  // Den vollständigen Pfad zur Datei erstellen.
  EnvFilePath := IncludeTrailingPathDelimiter(AppDataFolder) + EmailEnvFileName;

  // Make sure the app data folder exists.
  // Sicherstellen, dass der AppData-Ordner existiert.
  if not System.SysUtils.DirectoryExists(AppDataFolder) then
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
  if CenteredMessageDlg(
    'Paperless muss neu gestartet werden, um die Einstellungen zu übernehmen. ' +
    'Möchten Sie die E-Mail-Einstellungen speichern und Paperless neu starten?',
    mtConfirmation,
    [mbOk, mbCancel],
    0) <> mrOk then
  begin
    CenteredShowMessage('Der Vorgang wurde abgebrochen.');
    Exit;
  end;
  // Build the .env file content.
  // Den Inhalt der .env-Datei zusammenbauen.
  EnvList := TStringList.Create;
  try
    // Add mail settings to email-versand.env.
    // E-Mail-Einstellungen zu email-versand.env hinzufügen.
    EnvList.Add('PAPERLESS_EMAIL_HOST=' + SMTPServerEdit.Text);
    if Trim(SMTPPortEdit.Text) = '' then
      EnvList.Add('PAPERLESS_EMAIL_PORT=25')
    else
      EnvList.Add('PAPERLESS_EMAIL_PORT=' + Trim(SMTPPortEdit.Text));
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
      EnvList.Add('PAPERLESS_EMAIL_USE_TLS=false');
      EnvList.Add('PAPERLESS_EMAIL_USE_SSL=false');
    end;

    // Save the file.
    // Die Datei speichern.
    EnvList.SaveToFile(EnvFilePath, TEncoding.UTF8);
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
    TabControl1.TabIndex := 0;
    TabControl1Change(TabControl1);
    Application.ProcessMessages;
    SaveEmailSettingsBtn.Enabled:=False;
    IsApplyingEmailSettings := True;
    CreateRestartScript(ExtractFilePath(ComposePath));
    IsApplyingEmailSettings := False;
end;

// Erstellt Maildefaults oder repariert ausschließlich fehlende/leere Port-, TLS- und SSL-Werte in der vorhandenen UTF-8-Datei.
// Gesetzte Werte bleiben erhalten. Numerische/boolsche Einstellungen dürfen für Paperless nicht leer definiert sein.
procedure TMainformFrm.SaveEmptyEnvFile();
var
  EnvList: TStringList;
  EnvFilePath: string;
  SettingsChanged: Boolean;
begin
  // Build the full path to the file.
  // Den vollständigen Pfad zur Datei erstellen.
  EnvFilePath := IncludeTrailingPathDelimiter(AppDataFolder) + EmailEnvFileName;

  // Make sure the app data folder exists.
  // Sicherstellen, dass der AppData-Ordner existiert.
  if not System.SysUtils.DirectoryExists(AppDataFolder) then
  begin
    CenteredShowMessage('Der angegebene AppData-Ordner existiert nicht.');
    Exit;
  end;

  // Repair empty SMTP port and TLS/SSL flags without changing configured values.
  // Leeren SMTP-Port und TLS-/SSL-Werte reparieren; gesetzte Werte erhalten.
  if FileExists(EnvFilePath) then
  begin
    EnvList := TStringList.Create;
    try
      EnvList.LoadFromFile(EnvFilePath);
      SettingsChanged := False;
      if Trim(EnvList.Values['PAPERLESS_EMAIL_PORT']) = '' then
      begin
        EnvList.Values['PAPERLESS_EMAIL_PORT'] := '25';
        SettingsChanged := True;
      end;
      if Trim(EnvList.Values['PAPERLESS_EMAIL_USE_TLS']) = '' then
      begin
        EnvList.Values['PAPERLESS_EMAIL_USE_TLS'] := 'false';
        SettingsChanged := True;
      end;
      if Trim(EnvList.Values['PAPERLESS_EMAIL_USE_SSL']) = '' then
      begin
        EnvList.Values['PAPERLESS_EMAIL_USE_SSL'] := 'false';
        SettingsChanged := True;
      end;
      if SettingsChanged then
      begin
        EnvList.SaveToFile(EnvFilePath, TEncoding.UTF8);
        LogInfo('Empty email port or TLS/SSL settings repaired using defaults.');
      end;
    finally
      EnvList.Free;
    end;
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
      EnvList.Add('PAPERLESS_EMAIL_PORT=25');
      EnvList.Add('PAPERLESS_EMAIL_HOST_USER=');
      EnvList.Add('PAPERLESS_EMAIL_HOST_PASSWORD=');
      EnvList.Add('PAPERLESS_EMAIL_FROM=');
      EnvList.Add('PAPERLESS_EMAIL_USE_TLS=false');
      EnvList.Add('PAPERLESS_EMAIL_USE_SSL=false');
      // Save the file.
      // Die Datei speichern.
      EnvList.SaveToFile(EnvFilePath, TEncoding.UTF8);
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

// Erzeugt das geplante PS1-Skript aus gespeicherten Einstellungen und führt die lokale Aufbewahrungsbereinigung aus.
// Zusätzlich bereinigt das geplante Skript nach erfolgreichem Lauf.
procedure TMainformFrm.CreateBackupPlanScript(const ComposePath: string);
var
  Ini: TAppSettingsIni;
  ScriptPath, BackupBase: string;
begin
  if not FileExists(ComposePath) then Exit;
  Ini := TAppSettingsIni.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
  try
    BackupBase := Ini.ReadString('Pfade', 'BackupZiel', '').Trim;
  finally
    Ini.Free;
  end;
  if BackupBase = '' then
    BackupBase := IncludeTrailingPathDelimiter(GetEnvironmentVariable('USERPROFILE')) + 'Desktop\FallbackBackup\';
  ScriptPath := IncludeTrailingPathDelimiter(ExtractFilePath(ComposePath)) + 'paperless-backup-geplant.ps1';
  try
    CreatePlannedBackupCmdScript(ScriptPath, ComposePath, BackupBase, AppDataFolder, KeepBackupsSpE.Value);
  except
    on E: Exception do
      CenteredShowMessage('Das geplante Backup-Skript konnte nicht aktualisiert werden: ' + E.Message);
  end;
end;

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
  MarkGeneratedScriptHidden(CmdPath);
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
  Ini: TAppSettingsIni;
  RestoreDefaultFolder: string;
  BackupSizeBytes: Int64;
  RestoreEstimateLogText: string;
  KeyPreparationCancelled, KeyPrepared, HasRestoreMail: Boolean;
  PreparedKey: string;
  RestoreMailBytes: TBytes;
begin
  ProgramUpdateLbl.Hide;
  if ScriptBusy or FLocalRestoreActive or FServerBackupCheckActive or ApplicationClosing then Exit;
  if LocalInstallationSelected = ExternalInstallationSelected then
  begin
    CenteredShowMessage('Die Betriebsart ist nicht eindeutig. Bitte die Einstellungen prüfen.');
    Exit;
  end;
  if LocalInstallationSelected and FLocalStartupPending then
  begin
    CenteredShowMessage('Bitte das Programm neu starten, um die lokale Installation vorzubereiten.');
    Exit;
  end;
  if ExternalInstallationSelected then
  begin
    // Keep the server mode out of the local restore and folder picker.
    // Im Servermodus die lokale Wiederherstellung und Ordnerauswahl überspringen.
    CenteredMessageBox(
      'Wenn Sie lokale Backups wiederherstellen möchten, müssen Sie diese zunächst mit ' +
      '„Backup zum Server senden“ in den gespeicherten Backupordner auf dem Server kopieren.',
      'Backup auf dem Server wiederherstellen', MB_OK or MB_ICONINFORMATION);
    case CenteredMessageDlg(
      'Ja: Ein Backup aus dem gespeicherten Serverordner zur Wiederherstellung auswählen.' +
      sLineBreak + sLineBreak +
      'Nein: Den Status der letzten oder laufenden Server-Wiederherstellung abfragen.' + sLineBreak +
      'Abbrechen: Dialog schließen.',
      mtConfirmation, [mbYes, mbNo, mbCancel], 0) of
      mrYes: BeginServerBackupCheck('', sbaListRestoreBackups);
      mrNo: BeginServerBackupCheck('', sbaWatchRestore);
    end;
    Exit;
  end;
  ClearRestoreProgressState;
  StartPaperlessBackupBtn.Enabled := False;
  RestorePaperlessBackupBtn.Enabled := False;
  try
    try
      IsBackup := False;
      IsPaperlessInstallation := False;
      // Clear stale update state before a new restore run starts.
      // Veralteten Update-Zustand vor einer neuen Wiederherstellung zurücksetzen.
      IsUpdate := False;
      PaperlessUpdate := False;
      IsRestoreApplyingSettings := False;
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
      Ini := TAppSettingsIni.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
      try
        LastBackupFolder := Ini.ReadString('Pfade', 'BackupZiel', '').Trim;
        if (LastBackupFolder <> '') and System.SysUtils.DirectoryExists(LastBackupFolder) then
          RestoreDefaultFolder := LastBackupFolder;
      finally
        Ini.Free;
      end;
      FolderDialog := TFileOpenDialog.Create(nil);
      try
        FolderDialog.Options := [fdoPickFolders];
        FolderDialog.Title := 'Bitte den Ordner mit Ihrem Paperless-Backup auswählen.';
        FolderDialog.DefaultFolder := RestoreDefaultFolder;
        if CenteredFolderDialogExecute(FolderDialog) then
        begin
          BackupFolder := FolderDialog.FileName;
          BackupWiederherProgNeuStartLbl.Visible := True;
          BackupWiederherProgNeuStartLbl.Caption := 'Backup wird geprüft. Bitte warten ...';
          Application.ProcessMessages;
          BackupSizeBytes := GetDirectorySizeBytes(BackupFolder);
          RestoreEstimatedSeconds := EstimateRestoreDurationSeconds(BackupSizeBytes);
          RestoreEstimateText := 'Restore estimate available';
          RestoreEstimateLogText := Format('Backup-Größe: %s. Geschätzte Wiederherstellungsdauer: %s.',
            [FormatByteSize(BackupSizeBytes), EstimateRestoreDurationText(BackupSizeBytes)]);
          BackupWiederherProgNeuStartLbl.Caption := 'Wiederherstellung wird vorbereitet. Bitte warten ...';
          LogInfo('Restore estimate for "' + BackupFolder + '": ' + RestoreEstimateLogText);
          Application.ProcessMessages;
          if ValidateRestoreBackupFolder(BackupFolder) then
          begin
            if CenteredMessageDlg(
              'Verwenden Sie nur ein Backup, dessen Herkunft Sie kennen und dem Sie vertrauen. ' +
              'Die enthaltene SQL-Datei wird von PostgreSQL ausgeführt.' + sLineBreak + sLineBreak +
              'Paperless wird während der Wiederherstellung angehalten. Jetzt fortfahren?',
              mtWarning, [mbYes, mbNo], 0) <> mrYes then
            begin
              ClearRestoreProgressState;
              Exit;
            end;
            KeyPrepared := ApplyPaperlessSecretKeyForRestore(BackupFolder, ComposePath, KeyPreparationCancelled, PreparedKey);
            if not KeyPreparationCancelled then
              KeyPreparationCancelled := not RestoreEmailEnvFromBackup(BackupFolder, RestoreMailBytes, HasRestoreMail);
            if KeyPreparationCancelled then
            begin
              ClearRestoreProgressState;
              BackupWiederherProgNeuStartLbl.Caption := 'Wiederherstellung abgebrochen.';
              StartPaperlessBackupBtn.Enabled := True;
              RestorePaperlessBackupBtn.Enabled := True;
              Exit;
            end;
            if not KeyPrepared then PreparedKey := '';
            CreateRestoreScript(ComposePath, BackupFolder, PreparedKey, RestoreMailBytes, HasRestoreMail);
          end
          else
          begin
            ClearRestoreProgressState;
            BackupWiederherProgNeuStartLbl.Visible := True;
            BackupWiederherProgNeuStartLbl.Caption := 'Wiederherstellung abgebrochen.';
          end;
        end
        else
        begin
          CenteredShowMessage('Wiederherstellung abgebrochen – kein Backup-Ordner gewählt.');
        end;
      finally
        FolderDialog.Free;
      end;
    except
      on E: Exception do
      begin
        ClearRestoreProgressState;
        LogWarning('Local restore could not be started: ' + E.Message);
        CenteredShowMessage('Die Wiederherstellung konnte nicht gestartet werden: ' + E.Message);
      end;
    end;
  finally
    StartPaperlessBackupBtn.Enabled := True;
    RestorePaperlessBackupBtn.Enabled := True;
  end;
end;

// Den E-Mail-Speichern-Button aktivieren, nachdem der Benutzer den abgeschlossenen Update-Schritt bestätigt hat.
procedure TMainformFrm.UpdateDoneCbClick(Sender: TObject);
begin
  if HabeUpdaetGemachtCb.State = cbUnchecked then
  PaperlessUpdateBtn.Enabled := False else
  PaperlessUpdateBtn.Enabled := True;
end;
// Open the PDF manual in the default browser.
// Die PDF-Anleitung im Standardbrowser öffnen.
procedure TMainformFrm.OpenManualBtnClick(Sender: TObject);
begin
  ProgramUpdateLbl.Hide;
  ShellExecute(Handle, 'open', PChar(ProgramManualUrl), nil, nil, SW_SHOWNORMAL);
end;

// Open Paperless at the local address or at the saved server web endpoint.
// Paperless unter der lokalen Adresse oder der gespeicherten Server-Webadresse öffnen.
procedure TMainformFrm.OpenPaperlessBrowserLblClick(Sender: TObject);
var
  Ini: TAppSettingsIni;
  BrowserUrl, Host, WebPortText: string;
  WebPort: Integer;
begin
  ProgramUpdateLbl.Hide;
  BrowserUrl := PaperlessLocalUrlWithSlash;
  if ExternalInstallationSelected then
  begin
    Ini := TAppSettingsIni.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
    try
      Host := Trim(Ini.ReadString('Paperless Extern', 'Host', ''));
      WebPortText := Trim(Ini.ReadString('Paperless Extern', IniKeyServerWebPort,
        IntToStr(ServerInstallWebPort)));
    finally
      Ini.Free;
    end;
    if not IsValidHost(Host) or not TryStrToInt(WebPortText, WebPort) or
       (WebPort < 1) or (WebPort > 65535) then
    begin
      CenteredShowMessage('Bitte zuerst eine gültige Serveradresse und einen Paperless-Webport speichern.');
      Exit;
    end;
    // Bracket an IPv6 host before appending the web port to the URL.
    // Eine IPv6-Adresse vor dem Anhängen des Webports in eckige Klammern setzen.
    if Pos(':', Host) > 0 then
      Host := '[' + Host + ']';
    BrowserUrl := Format('http://%s:%d/', [Host, WebPort]);
  end;
  if NativeInt(ShellExecute(Handle, 'open', PChar(BrowserUrl), nil, nil, SW_SHOWNORMAL)) <= 32 then
    CenteredShowMessage('Paperless konnte nicht im Browser geöffnet werden.');
end;
// Stage key and mail files separately; the worker applies them inside the restore lock.
// Schlüssel und Maildatei vorbereiten. Der Worker übernimmt sie innerhalb der Wiederherstellungssperre.
procedure TMainformFrm.CreateRestoreScript(const ComposePath, BackupFolder, PreparedKey: string;
  const RestoreMailBytes: TBytes; const HasRestoreMail: Boolean);
var
  WorkDir, KeyPath, MailPath, LogFolder: string;
  ApplyKey: Boolean;
begin
  WorkDir := TPath.Combine(TPath.GetTempPath, 'Paperless-Restore-' + TGUID.NewGuid.ToString);
  TDirectory.CreateDirectory(WorkDir);
  KeyPath := TPath.Combine(WorkDir, 'requested-key.txt');
  MailPath := TPath.Combine(WorkDir, 'requested-mail.env');
  ApplyKey := (PreparedKey <> '') and not CustomFileProtected(ComposePath);
  FLocalRestoreLogPath := '';
  FLocalRestoreActive := True;
  FLocalRestoreSucceeded := False;
  try
    if ApplyKey then TFile.WriteAllText(KeyPath, PreparedKey, TEncoding.UTF8);
    if HasRestoreMail then TFile.WriteAllBytes(MailPath, RestoreMailBytes);
    LogFolder := TPath.Combine(AppDataFolder, 'Logs');
    TDirectory.CreateDirectory(LogFolder);
    CmdTargetPath := ReserveTimestampedScript(ExtractFilePath(ComposePath), LogFolder);
    FLocalRestoreLogPath := TPath.Combine(LogFolder, ChangeFileExt(ExtractFileName(CmdTargetPath), '.log'));
    try
      CreateRestoreCmdScript(CmdTargetPath, ComposePath, BackupFolder, WorkDir, FLocalRestoreLogPath,
        ApplyKey, HasRestoreMail, FRestoreLegacyNames);
      StartAndMonitorCmdScript;
    finally
      DeleteGeneratedScriptFile(CmdTargetPath);
    end;
    if FLocalRestoreSucceeded then
    begin
      if PreparedKey <> '' then
        try
          SaveRestoreSecretKey(PreparedKey);
        except
          on E: Exception do
          begin
            LogWarning('Restore completed, but the key could not be saved in the settings.');
            CenteredShowMessage('Paperless wurde wiederhergestellt. Der Schlüssel konnte nicht zusätzlich ' +
              'in der Einstellungen.ini gespeichert werden. Bitte prüfen Sie dies vor dem nächsten Update.');
          end;
        end;
      if HasRestoreMail then LoadEmailSettings;
      CenteredShowMessage('Wiederherstellung abgeschlossen. Die Paperless-Weboberfläche ist erreichbar.' +
        sLineBreak + sLineBreak + 'Logdatei: ' + FLocalRestoreLogPath);
    end;
  finally
    FLocalRestoreActive := False;
    if FileExists(KeyPath) then System.SysUtils.DeleteFile(KeyPath);
    if FileExists(MailPath) then System.SysUtils.DeleteFile(MailPath);
    // Retain diagnostics and recovery files when the worker could not complete.
    // Diagnose- und Rückfalldateien bei einem Fehler aufbewahren.
    System.SysUtils.RemoveDir(WorkDir);
  end;
end;

// Startet das erzeugte Skript verdeckt, verfolgt Status und Exitcode und führt die passende Erfolgs-/Fehlerauswertung aus.
// Die Erfolgspfade unterscheiden Installation, Backup und Restore. Einmal-Skripte werden nach Ausführung entfernt.
procedure TMainformFrm.StartAndMonitorCmdScript;
var
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  Cmd: string;
  RunningStatus: string;
  OutputLogPath: string;
  SuccessStatus: string;
  ExitCode: DWORD;
begin
  if ApplicationClosing or Application.Terminated then Exit;
  try
    FillChar(StartupInfo, SizeOf(TStartupInfo), 0);
    StartupInfo.cb := SizeOf(TStartupInfo);
    StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
    StartupInfo.wShowWindow := SW_HIDE;
    OutputLogPath := PrepareScriptOutputLog;
    MarkGeneratedScriptHidden(CmdTargetPath);
    Cmd := BuildPowerShellCommand(CmdTargetPath, OutputLogPath); // Script path.
    // Skriptpfad.
    if IsRestoreApplyingSettings then
      RunningStatus := 'Wiederherstellung wird abgeschlossen. Bitte warten ...'
    else if IsUpdate then
      RunningStatus := 'Update wird gestartet. Bitte warten ...'
    else if IsPaperlessInstallation then
      RunningStatus := 'Paperless-Installation wird gestartet. Bitte warten ...'
    else if IsBackup then
      RunningStatus := 'Backup wird gestartet. Bitte warten ...'
    else if RestoreEstimateText.Trim <> '' then
      RunningStatus := 'Wiederherstellung wird gestartet. Bitte warten ...'
    else
      RunningStatus := 'Wiederherstellung wird gestartet. Bitte warten ...';
    if IsPaperlessInstallation then
    begin
      InstallCancelRequested := False;
      RunningScriptProcessId := 0;
    end;
    PrepareScriptProgress(RunningStatus);
    if CreateProcess(nil, PChar(Cmd), nil, nil, False, CREATE_NO_WINDOW, nil, nil, StartupInfo, ProcessInfo) then
    begin
      if IsPaperlessInstallation then
        RunningScriptProcessId := ProcessInfo.dwProcessId;
      UpdateScriptProgress(RunningStatus);
      Sleep(1500);
      if IsUpdate = False then
      begin
        // Wait for the process to finish.
        // Warten, bis der Prozess beendet ist.
        WaitForScriptWithProgress(ProcessInfo.hProcess, RunningStatus, OutputLogPath);
        // Check the exit code.
        // Den Exit-Code prüfen.
        if not GetExitCodeProcess(ProcessInfo.hProcess, ExitCode) then
          ExitCode := High(DWORD);
        CloseHandle(ProcessInfo.hProcess);
        CloseHandle(ProcessInfo.hThread);
        Sleep(1000);
        if ExitCode = 0 then
        begin
          if IsPaperlessInstallation = True then
            SuccessStatus := 'Paperless-Installation abgeschlossen.'
          else if IsBackup = True then
            SuccessStatus := 'Backupvorgang abgeschlossen.'
          else
            SuccessStatus := 'Wiederherstellung abgeschlossen.';
          if (SuccessStatus <> 'Wiederherstellung abgeschlossen.') and not IsRestoreApplyingSettings then
            FinishScriptProgress(SuccessStatus, True);
          if IsPaperlessInstallation = True then
          begin
            WriteStandardVersionAfterInstallation;
            CenteredMessageBox('Paperless wurde erfolgreich installiert und gestartet.' + #13#10 +
              'Nach Bestätigung wird die ComputerRalle-Website im Browser geöffnet (https://computerralle.de).' + #13#10 +
              'Paperless erreichen Sie unter http://localhost:8001. Geben Sie Paperless ein wenig Zeit zum Starten.',
              'Installation abgeschlossen', MB_OK or MB_ICONINFORMATION or MB_TOPMOST);
            if not ApplicationClosing and not Application.Terminated then
              ShellExecute(0, 'open', ComputerRalleSetupUrl, nil, nil, SW_SHOWNORMAL);
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
            SetupFrm.InstallationCancelBtn.Visible := False;
            SetupFrm.HinweisVerstandenBtn.Enabled := True;
          end
          else if IsBackup = True then
          begin
            FManualBackupSucceeded := True;
            if not IsAutostart then
            begin
              CenteredMessageBox('Backup abgeschlossen. Sie können das Programm jetzt schließen.' + #13#10 +
              'Bitte geben Sie Paperless Zeit zum starten.',
              'Info', MB_OK or MB_ICONINFORMATION or MB_TOPMOST);
            end;
            try
              WriteImageVersionWithSetupForm(BackupPath);
            except
              on E: Exception do LogWarning('Backup image versions could not be written: ' + E.Message);
            end;
          end
          else if FLocalRestoreActive then
          begin
            FLocalRestoreSucceeded := True;
            FinishScriptProgress('Wiederherstellung abgeschlossen.', True);
          end;
        end
        else
        begin
          if InstallCancelRequested and IsPaperlessInstallation then
          begin
            FinishScriptProgress('Installation abgebrochen.', False);
            if Assigned(SetupFrm) then
              SetupFrm.HinweisVerstandenBtn.Enabled := True;
            CenteredShowMessage('Installation wurde abgebrochen. Vorhandene Docker-Volumes und Images wurden erhalten.');
            IsPaperlessInstallation := False;
            InstallCancelRequested := False;
          end
          else
          begin
            FinishScriptProgress('Vorgang fehlgeschlagen.', False);
            if FLocalRestoreActive and FileExists(FLocalRestoreLogPath) then
              CenteredShowMessage('Wiederherstellung fehlgeschlagen. Das Protokoll enthält das Ergebnis ' +
                'der Rückkehr und gegebenenfalls den Pfad zu den Rückfalldateien.' +
                sLineBreak + sLineBreak + 'Logdatei: ' + FLocalRestoreLogPath)
            else if IsBackup then
              CenteredShowMessage(ScriptFailureMessage(OutputLogPath, ExitCode) + sLineBreak + sLineBreak +
                'Backup-Protokoll: ' + TPath.Combine(AppDataFolder, 'Backup.log'))
            else
              CenteredShowMessage(ScriptFailureMessage(OutputLogPath, ExitCode));
          end;
          ClearRestoreProgressState;
        end;
      end
      else
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
          if FRetentionUpdateRequested then
            FRetentionUpdateSucceeded := True;
          if IsRestoreApplyingSettings then
            FinishScriptProgress('Wiederherstellung abgeschlossen.', True)
          else
            FinishScriptProgress('Update abgeschlossen.', True);
          SaveBlankEmailSettings();
          if IsRestoreApplyingSettings then
          begin
            CenteredMessageBox('Wiederherstellung abgeschlossen.', 'Info', MB_OK or MB_ICONINFORMATION or MB_TOPMOST);
            IsRestoreApplyingSettings := False;
            ClearRestoreProgressState;
          end
          else
            CenteredMessageBox('Paperless wurde erfolgreich aktualisiert' + #13#10 +
            'Sie können Paperless nun im Browser öffnen (http://localhost:8001). Geben Sie Paperless ein wenig Zeit zum starten.',
            'Installation abgeschlossen', MB_OK or MB_ICONINFORMATION or MB_TOPMOST);
          IsUpdate := False;
          PaperlessUpdate := False;
        end
        else
        begin
          FinishScriptProgress('Paperless-Update fehlgeschlagen.', False);
          CenteredShowMessage(ScriptFailureMessage(OutputLogPath, ExitCode));
          IsUpdate := False;
          PaperlessUpdate := False;
          IsRestoreApplyingSettings := False;
          ClearRestoreProgressState;
        end;
      end;
    end
    else
    begin
      FinishScriptProgress('Skript konnte nicht gestartet werden.', False);
      CenteredShowMessage('Fehler beim Starten des Skripts.');
      IsUpdate := False;
      PaperlessUpdate := False;
      IsRestoreApplyingSettings := False;
      ClearRestoreProgressState;
    end;
    ActiveControl := nil;
    RunningScriptProcessId := 0;
    if IsAutostart = True then
    Application.Terminate;
  finally
    DeleteGeneratedScriptFile(CmdTargetPath);
  end;
end;

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
  try
    WasApplyingEmailSettings := IsApplyingEmailSettings;
    FillChar(StartupInfo, SizeOf(TStartupInfo), 0);
    StartupInfo.cb := SizeOf(TStartupInfo);
    StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
    StartupInfo.wShowWindow := SW_HIDE;
    OutputLogPath := PrepareScriptOutputLog;
    MarkGeneratedScriptHidden(CmdTargetPath);
    Cmd := BuildPowerShellCommand(CmdTargetPath, OutputLogPath); // Script path.
    // Skriptpfad.
    if WasApplyingEmailSettings then
      RunningStatus := 'Mail-Einstellungen werden angewendet. Bitte warten ...'
    else if PaperlessUpdate then
      RunningStatus := 'Update wird gestartet. Bitte warten ...'
    else
      RunningStatus := 'Neustart wird gestartet. Bitte warten ...';
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
          CenteredShowMessage(ScriptFailureMessage(OutputLogPath, ExitCode));
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
          CenteredShowMessage(ScriptFailureMessage(OutputLogPath, ExitCode));
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
  finally
    DeleteGeneratedScriptFile(CmdTargetPath);
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

// Die Einstellungsseite anzeigen, auf der Image-Versionen und Update-Einstellungen bearbeitet werden.
procedure TMainformFrm.PaperlessUpdateBtnClick(Sender: TObject);
begin
  ProgramUpdateLbl.Hide;
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
  Ini: TAppSettingsIni;
  ComposePathFromIni, BackupTargetFromIni: string;
begin
  // Read required paths from the INI file.
  // Benötigte Pfade aus der INI-Datei lesen.
  Ini := TAppSettingsIni.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
  try
    ComposePathFromIni := Ini.ReadString('Pfade', 'DockerComposePfad', '').Trim;
    BackupTargetFromIni := Ini.ReadString('Pfade', 'BackupZiel', '').Trim;
  finally
    Ini.Free;
  end;

  // Scheduling is allowed only when compose file and backup target exist.
  // Zeitplanung ist nur erlaubt, wenn Compose-Datei und Backup-Ziel existieren.
  if FileExists(ComposePathFromIni) and System.SysUtils.DirectoryExists(BackupTargetFromIni) then
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
      if Line.StartsWith(ComposeProjectName + '_') then
      SL.Add(Line);
    end;

    SL.SaveToFile(InfoPath, TEncoding.UTF8);
  finally
    SL.Free;
    ContainerLines.Free;
    VolumeLines.Free;
  end;
end;

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
// Open the legal notice page.
// Die Impressumsseite oeffnen.
procedure TMainformFrm.ImprintLblClick(Sender: TObject);
begin
  ShellExecute(0, 'open', ImprintUrl, nil, nil, SW_SHOWNORMAL);
end;
// Die Paperless-Video-Playlist oeffnen.
procedure TMainformFrm.PaperlessPlaylistLblClick(Sender: TObject);
begin
  ShellExecute(0, 'open', PaperlessPlaylistUrl, nil, nil, SW_SHOWNORMAL);
end;
// Den YouTube-Kanal oeffnen.
procedure TMainformFrm.MyYouTubeChannelLblClick(Sender: TObject);
begin
 ShellExecute(0, 'open', YouTubeChannelUrl, nil, nil, SW_SHOWNORMAL);
end;
// Die Anleitung zum Backup-Programm oeffnen.
procedure TMainformFrm.BackupProgramGuideLblClick(Sender: TObject);
begin
 ShellExecute(0, 'open', BackupGuideUrl, nil, nil, SW_SHOWNORMAL);
end;
// Die Haupt-Webseite von ComputerRalle oeffnen.
procedure TMainformFrm.Web1LblClick(Sender: TObject);
begin
 ShellExecute(0, 'open', ComputerRalleUrl, nil, nil, SW_SHOWNORMAL);
end;
// Den ComputerRalle-Blog oeffnen.
procedure TMainformFrm.Web2LblClick(Sender: TObject);
begin
 ShellExecute(0, 'open', BlogUrl, nil, nil, SW_SHOWNORMAL);
end;
// Die Newsletter-Anmeldeseite oeffnen.
procedure TMainformFrm.NewsletterLblClick(Sender: TObject);
begin
  ShellExecute(0, 'open', NewsletterUrl, nil, nil, SW_SHOWNORMAL);
end;
// Den Changelog im Browser öffnen.
procedure TMainformFrm.ChangelogBtnClick(Sender: TObject);
begin
  ProgramUpdateLbl.Hide;
  if NativeInt(ShellExecute(Handle, 'open', PChar(ChangelogUrl), nil, nil, SW_SHOWNORMAL)) <= 32 then
    CenteredShowMessage('Der Changelog konnte nicht im Browser geöffnet werden.');
end;

// Die Programm-Downloadseite oeffnen, wenn ein Update verfügbar ist.
procedure TMainformFrm.ProgramUpdateLblClick(Sender: TObject);
begin
  ProgramUpdateLbl.Hide;
  ShellExecute(0, 'open', ProgramDownloadUrl, nil, nil, SW_SHOWNORMAL);
end;

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

// Compare up to four numeric components. Omitted trailing components are zero.
// Bis zu vier numerische Segmente vergleichen. Fehlende Endsegmente zählen als null.
function TMainformFrm.TryCompareProgramVersions(const LeftVersion, RightVersion: string;
  out Comparison: Integer): Boolean;
type
  TVersionParts = array[0..3] of Integer;
var
  LeftParts, RightParts: TVersionParts;
  Index: Integer;

  function Parse(const Value: string; out Parts: TVersionParts): Boolean;
  var
    Segments: TArray<string>;
    Segment: string;
    Ch: Char;
    I: Integer;
  begin
    Result := False;
    Parts := Default(TVersionParts);
    Segments := Trim(Value).Split(['.']);
    if (Length(Segments) = 0) or (Length(Segments) > Length(Parts)) then Exit;
    for I := 0 to High(Segments) do
    begin
      Segment := Segments[I];
      if Segment = '' then Exit;
      for Ch in Segment do
        if not CharInSet(Ch, ['0'..'9']) then Exit;
      if not TryStrToInt(Segment, Parts[I]) or (Parts[I] > High(Word)) then Exit;
    end;
    Result := True;
  end;

begin
  Comparison := 0;
  Result := Parse(LeftVersion, LeftParts) and Parse(RightVersion, RightParts);
  if not Result then Exit;
  for Index := Low(LeftParts) to High(LeftParts) do
    if LeftParts[Index] <> RightParts[Index] then
    begin
      Comparison := LeftParts[Index] - RightParts[Index];
      Exit;
    end;
end;
end.
