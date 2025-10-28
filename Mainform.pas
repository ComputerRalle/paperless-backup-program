// --------------------------------------------------------------
//  Project: Paperless Backup Program / Paperless Backup Programm
//  Author: Ralf-Peter Kleinert - 2025
//  Alias: ComputerRalle / DIGITAL-easy
//  Website: https://ralf-peter-kleinert.de
//  YouTube: https://www.youtube.com/@ralf-peter-kleinert
//  Copyright (c) Ralf-Peter Kleinert
//  All rights reserved.
//
// --------------------------------------------------------------
//  Beschreibung:
//  Dieses Programm wurde von Ralf-Peter Kleinert (alias ComputerRalle / DIGITAL-easy)
//  entwickelt. Es dient zur Sicherung und Wiederherstellung von Paperless-Daten,
//  inklusive Versionsverwaltung, Backup-Planung und automatisierten Prüfungen.
//
//  Hinweis:
//  Dieses Projekt befindet sich in aktiver Entwicklung. Eine finale Lizenz
//  (Open Source oder proprietär) wird erst bei der offiziellen Veröffentlichung festgelegt.
//
//  Diese Lizenz- und Copyright-Informationen werden nach der Entscheidung,
//  welches Lizenzmodell infrage kommt, entsprechend angepasst.
//
// --------------------------------------------------------------
//  Description:
//  This program was developed by Ralf-Peter Kleinert (alias ComputerRalle / DIGITAL-easy).
//  It provides backup and restore functionality for Paperless data,
//  including version tracking, scheduled backups, and automated verification.
//
//  Note:
//  This project is currently under active development. A final license
//  (open-source or proprietary) will be defined upon official release.
//
//  These license and copyright details will be updated once
//  the final licensing model has been determined.
// --------------------------------------------------------------
unit Mainform;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, ShellAPI, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  System.IOUtils, Vcl.Samples.Spin, System.IniFiles, DateUtils, HinweisForm, System.Generics.Collections, System.Generics.Defaults, Vcl.Menus,
  System.Net.URLClient, System.Net.HttpClient, System.Net.HttpClientComponent;

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
    DigitalEasyLbl: TLabel;
    ComputerRalleLbl: TLabel;
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
    procedure PaperlessBackupStartenBtnClick(Sender: TObject);
    //procedure ComposeOrdnerWaehlenBtnClick(Sender: TObject);
    procedure BuyMeACoffeBtnClick(Sender: TObject);
    procedure cmdSkriptStarten;
    procedure FormShow(Sender: TObject);
    procedure PaperlessBackupStartenSpBtnClick(Sender: TObject);
    procedure RestorePaperlessBackupBtnClick(Sender: TObject);
    procedure ErzeugeRestoreScript(const ComposePfad, BackupOrdner: string);
    procedure CmdSkriptStartenUndUeberwachen;
    procedure ConsoleToFront(PID: DWORD);
    procedure TabControl1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SpeichereZeitplanEinstellungen;
    procedure CreateBackupPlanBtnClick(Sender: TObject);
    procedure ErzeugeBackupPlanScript(const ComposePfad: string);
    procedure ErzeugeNeustartScript(const ComposePfad: string);
    procedure StarteBackupPlanScriptStill;
    procedure LadeZeitplanEinstellungen;
    procedure AutoBackupCBClick(Sender: TObject);
    procedure SaveRetentionBtnClick(Sender: TObject);
    procedure DeleteBackupPlanBtnClick(Sender: TObject);
    procedure PruefeObPlanungErlaubt;
    procedure SchreibeComposeContainerUndVolumesInfo(const ComposePfad: string);
    function ExecuteShellCommand(const Command, Params: string): string;
    procedure PaperlessUpdateBtnClick(Sender: TObject);
    function HoleDateiVersion(const DateiPfad: string): string;
    procedure LeseContainerNamenAusDatei;
    procedure AutostartBackup();
    procedure EmailEinstellungenLesen;
    procedure SaveEmailSettingsBtnClick(Sender: TObject);
    procedure SpeichereLeereEnvDatei();
    procedure EinstellungenMussAbgeschlossenWerden;
    procedure NeuStartStartenUndUeberwachen;
    procedure EMailBlankoEinstellungenSpeichern();
    procedure HabeUpdaetGemachtCbClick(Sender: TObject);
    procedure PapierkorbAufbewahrungEditChange(Sender: TObject);
    procedure SaveSettingsBtnClick(Sender: TObject);   //
    procedure ImpressumLblClick(Sender: TObject);
    procedure PaplerlessPlayListLblClick(Sender: TObject);
    procedure MeinYouTubeKanalLblClick(Sender: TObject);
    procedure BackupProgrammAnleitungLblClick(Sender: TObject);
    procedure DigitalEasyLblClick(Sender: TObject);
    procedure ComputerRalleLblClick(Sender: TObject);
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
    procedure ErzeugeBackupScript(const ComposePfad: string);
  public
  end;

var
  MainformFrm: TMainformFrm;
  BackupPfad, ComposePfad, ComposeName, CmdZielPfad, DatumZeit, LetzterBackupOrdner: String;
  AppDataFolder, PfadBackupZiel, PfadCompose, StandardOrdner, PaperlessInput, HinweisDatei : String;
  IstEsBackup: Boolean;
  IstEsPaperlessInstallation, PaperlessOefnnen: Boolean;
  DateiDatum: TDateTime;
  InternalName, FileVersion: string;
  PaperlessDBName, PaperlessCTName, PaperlessBrokerName, PaperlessTikaName, PaperlessGotenbergName: String;
  Volume_data, Volume_db_data, Volume_export, Volume_media: String;
  NeuerComposePfad: String;
  NeueComposeSchreiben: Boolean;
  IstEsAutostart: Boolean;
  PfadInstallationAbgeschlossen: String;
  WillInstallieren: Boolean;
  IstEsUpdate: Boolean;
  PaperlessNeustart: Boolean;
  PaperlessUpdate: Boolean;
  PapierkorbAufbewahrung: Integer;
  AktuellGestestetPaperlessVersion: String;


implementation

{$R *.dfm}

// Load update.ini from web server, display update available
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
  	VersionInIni := ProgramVersion; // no Update if Server down
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

  //Test
  //ShowMessage(ProgramVersion);
  //ShowMessage(VersionInIni);
  //ShowMessage(VersionToInt(VersionInIni) + ' ' + VersionToInt(ProgramVersion));

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

// Stores the default versions of all Docker components immediately in "Einstellungen.ini".
procedure TMainformFrm.WriteStandardVersionAfterInstallation();
var
  Ini: TIniFile;
  Pfad: string;
begin
  Pfad := IncludeTrailingPathDelimiter(Mainform.AppDataFolder) + 'Einstellungen.ini';
  Ini := TIniFile.Create(Pfad);
  try
    Ini.WriteString('Versionen', 'Paperless-Version', '2.19.2');
    Ini.WriteString('Versionen', 'Postgres-Version', '17');
    Ini.WriteString('Versionen', 'Redis-Version', '7');
    Ini.WriteString('Versionen', 'Gotenberg-Version', '8');
    Ini.WriteString('Versionen', 'Tika-Version', 'latest');
    Ini.WriteString('Versionen', 'Alpine-Version', '3');
    Ini.WriteString('Versionen', 'Busybox-Version', '1');
    Ini.UpdateFile;
  finally
    Ini.Free;
  end;
end;

procedure TMainformFrm.cmdSkriptStarten;
begin
  ShellExecute(0, 'open', PChar(CmdZielPfad), nil, nil, SW_SHOWNORMAL);
end;

procedure TMainformFrm.BuyMeACoffeBtnClick(Sender: TObject);
begin
 ShellExecute(0, 'open', 'https://buymeacoffee.com/computerralle', nil, nil, SW_SHOWNORMAL);
end;

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

procedure TMainformFrm.PaperlessBackupStartenBtnClick(Sender: TObject);
var
  FolderDialog: TFileOpenDialog;
  Ini:TIniFile;
  GespeicherterPfad: string;
  TxtPfad: string;
begin
  SchreibeComposeContainerUndVolumesInfo(ComposePfad);
  StartPaperlessBackupBtn.Enabled := False;
  RestorePaperlessBackupBtn.Enabled := False;
  AutostartLbl.Visible := False;
  LeseContainerNamenAusDatei;
  IstEsPaperlessInstallation := False;

  //TFile.WriteAllText(IncludeTrailingPathDelimiter(AppDataOrdner) + 'DockerComposePfad.txt', ExtractFilePath(ComposePfad));

	Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + 'Einstellungen.ini');
  try
    Ini.WriteString('Pfade', 'DockerComposePfad', ExtractFilePath(ComposePfad));
    Ini.UpdateFile; // sofortiges Schreiben erzwingen
  finally
    Ini.Free;
  end;

  IstEsBackup := True;

  StandardOrdner := IncludeTrailingPathDelimiter(GetEnvironmentVariable('USERPROFILE')) + 'Desktop\Paperless-Backup';
  if not DirectoryExists(StandardOrdner) then ForceDirectories(StandardOrdner);

  // Wenn alte TXT vorhanden, Pfad lesen und in INI schreiben
  TxtPfad := IncludeTrailingPathDelimiter(AppDataFolder) + 'BackupZiel.txt';
  if FileExists(TxtPfad) then
  begin
    GespeicherterPfad := TFile.ReadAllText(TxtPfad, TEncoding.UTF8).Trim;
    Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + 'Einstellungen.ini');
    try
      Ini.WriteString('Pfade', 'BackupZiel', GespeicherterPfad);
      Ini.UpdateFile; // sofort speichern
      // Direkt aus der INI wieder lesen
      GespeicherterPfad := Ini.ReadString('Pfade', 'BackupZiel', '').Trim;
    finally
      Ini.Free;
    end;
    // Wenn aus INI erfolgreich gelesen, TXT löschen
    if GespeicherterPfad <> '' then DeleteFile(TxtPfad);
  end;

	// Wert aus INI lesen
	Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + 'Einstellungen.ini');
	try
  	LetzterBackupOrdner := Ini.ReadString('Pfade', 'BackupZiel', '').Trim;
	finally
  	Ini.Free;
	end;

  Sleep(500);

  if LetzterBackupOrdner <> '' then
  begin
    if IstEsAutostart or
       (MessageDlg('Es wurde folgender voreingestellter Pfad gefunden:' + sLineBreak + LetzterBackupOrdner + sLineBreak + sLineBreak +
                   'Soll das Backup hier gespeichert werden?', mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
    begin
      BackupPfad := IncludeTrailingPathDelimiter(LetzterBackupOrdner) + FormatDateTime('yyyy-mm-dd_hh-mm-ss', Now);
    end
    else
    begin
      FolderDialog := TFileOpenDialog.Create(nil);
      try
        FolderDialog.Options := [fdoPickFolders];
        FolderDialog.Title := 'Wählen Sie einen Backup-Ziel-Ordner aus.';
        FolderDialog.DefaultFolder := StandardOrdner;
        if FolderDialog.Execute then
        begin
          BackupPfad := IncludeTrailingPathDelimiter(FolderDialog.FileName) + FormatDateTime('yyyy-mm-dd_hh-mm-ss', Now);



          if not SameText(FolderDialog.FileName, StandardOrdner) then
          begin
            TFile.AppendAllText(
              IncludeTrailingPathDelimiter(StandardOrdner) + 'Wo ist mein Paperless Backup.txt',
              'Backup am ' + FormatDateTime('dd.mm.yyyy "um" hh:nn:ss', Now) +
              ' wurde in folgendem Ordner gespeichert:' + sLineBreak +
              BackupPfad + sLineBreak + sLineBreak);
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
      FolderDialog.DefaultFolder := StandardOrdner;
      if FolderDialog.Execute then
      begin
        BackupPfad := IncludeTrailingPathDelimiter(FolderDialog.FileName) + FormatDateTime('yyyy-mm-dd_hh-mm-ss', Now);
        if not SameText(FolderDialog.FileName, StandardOrdner) then
        begin
          TFile.AppendAllText(
            IncludeTrailingPathDelimiter(StandardOrdner) + 'Wo ist mein Paperless Backup.txt',
            'Backup am ' + FormatDateTime('dd.mm.yyyy "um" hh:nn:ss', Now) +
            ' wurde in folgendem Ordner gespeichert:' + sLineBreak +
            BackupPfad + sLineBreak + sLineBreak);
        end;
      end
      else
      begin
        BackupPfad := IncludeTrailingPathDelimiter(StandardOrdner) + FormatDateTime('yyyy-mm-dd_hh-mm-ss', Now);
        ShowMessage('Es wurde kein Ordner gewählt. Der Standardordner wird verwendet: ' + sLineBreak + BackupPfad);
      end;
    finally
      FolderDialog.Free;
    end;
  end;

  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + 'Einstellungen.ini');
  try
    Ini.WriteString('Pfade', 'BackupZiel', ExtractFileDir(BackupPfad));
    Ini.UpdateFile; // sofort speichern
  finally
    Ini.Free;
  end;

  ErzeugeBackupScript(ExtractFilePath(ComposePfad));
  ErzeugeBackupPlanScript(ExtractFilePath(ComposePfad));

  StartPaperlessBackupBtn.Enabled := True;
  RestorePaperlessBackupBtn.Enabled := True;
  CanStartBackupSTxt.Visible := True;
  StaticText5.Visible := True;
  RestoreCanStartSTxt.Visible := False;

  //Falls txt vorhanden, löschen
  TxtPfad := IncludeTrailingPathDelimiter(AppDataFolder) + 'DockerComposePfad.txt';
  if FileExists(TxtPfad) then DeleteFile(TxtPfad);
end;


procedure TMainformFrm.ErzeugeBackupScript(const ComposePfad: string);
//Diese Prozedur verwendet die Variablen der Volumen und CT Namen
var
  CmdDatei: TStringList;
  Ausgabe: string;
begin
  if ComposePfad.Trim = '' then
  begin
    ShowMessage('Fehler: Es wurde kein gültiger Compose-Pfad gewählt.');
    Exit;
  end;

  if not DirectoryExists(BackupPfad) then ForceDirectories(BackupPfad);

  DatumZeit := DateTimeToStr(Now);
  CmdDatei := TStringList.Create;
  try
    CmdZielPfad := IncludeTrailingPathDelimiter(ComposePfad) + 'paperless-backup.cmd';
    CmdDatei.Add('@echo off');
    CmdDatei.Add('setlocal');
    CmdDatei.Add('echo CDM Skript wird gestartet... Bitte warten');
    CmdDatei.Add('');
    CmdDatei.Add('::===  Verzeichnisse festlegen ===');
    CmdDatei.Add(Format('set "COMPOSE_DIR=%s"', [ExtractFilePath(ComposePfad)]));
    CmdDatei.Add(Format('set "BACKUP_DIR=%s"', [BackupPfad]));
    CmdDatei.Add('');
    CmdDatei.Add('::=== In Compose-Verzeichnis wechseln ===');
    CmdDatei.Add('cd /d "%COMPOSE_DIR%"');
    CmdDatei.Add('if errorlevel 1 (');
    CmdDatei.Add('    echo Fehler: Konnte nicht ins Compose-Verzeichnis wechseln.');
    CmdDatei.Add('    pause');
    CmdDatei.Add('    exit /b 1');
    CmdDatei.Add(')');
    CmdDatei.Add('');
    CmdDatei.Add('::=== Backup-Verzeichnis erstellen, falls nicht vorhanden ===');
    CmdDatei.Add('if not exist "%BACKUP_DIR%" (');
    CmdDatei.Add('    echo Erstelle Backup-Ordner: %BACKUP_DIR%');
    CmdDatei.Add('    mkdir "%BACKUP_DIR%"');
    CmdDatei.Add(')');
    CmdDatei.Add('');
    CmdDatei.Add('::=== PostgreSQL-Dump zuerst (Container läuft noch) ===');
    CmdDatei.Add('echo PostgreSQL-Dump wird erstellt...');
    CmdDatei.Add(Format('docker exec %s pg_dump -U paperless paperless > "%%BACKUP_DIR%%\%s_backup.sql"', [PaperlessDBName, PaperlessDBName]));
    CmdDatei.Add('if errorlevel 1 (');
    CmdDatei.Add('    echo Fehler beim PostgreSQL-Dump. Abbruch.');
    CmdDatei.Add('    pause');
    CmdDatei.Add('    exit /b 1');
    CmdDatei.Add(')');
    CmdDatei.Add('');
    CmdDatei.Add('::=== Container stoppen ===');
    CmdDatei.Add('echo Stoppe Docker-Container...');
    CmdDatei.Add('docker compose down');
    CmdDatei.Add('if errorlevel 1 (');
    CmdDatei.Add('    echo Fehler beim Stoppen der Container. Abbruch.');
    CmdDatei.Add('    pause');
    CmdDatei.Add('    exit /b 1');
    CmdDatei.Add(')');
    CmdDatei.Add('');
    CmdDatei.Add('::=== Volume-Backups ===');
    CmdDatei.Add('echo Backup: data');
    CmdDatei.Add('echo Bitte warten, Backup kann sehr lange dauern.');
    CmdDatei.Add('echo ...');
    CmdDatei.Add('echo ......');
    CmdDatei.Add('echo .........');
    CmdDatei.Add(Format('docker run --rm -v %s:/data -v "%%BACKUP_DIR%%":/backup alpine tar czvf /backup/%s.tar.gz -C /data .', [Volume_data, Volume_data]));
    CmdDatei.Add('if errorlevel 1 (');
    CmdDatei.Add('    echo Fehler beim Sichern von ''data''. Abbruch.');
    CmdDatei.Add('    pause');
    CmdDatei.Add('    exit /b 1');
    CmdDatei.Add(')');
    CmdDatei.Add('');
    CmdDatei.Add('echo Backup: db_data');
    CmdDatei.Add('echo Bitte warten, Backup kann sehr lange dauern.');
    CmdDatei.Add('echo ...');
    CmdDatei.Add('echo ......');
    CmdDatei.Add('echo .........');
    CmdDatei.Add(Format('docker run --rm -v %s:/data -v "%%BACKUP_DIR%%":/backup alpine tar czvf /backup/%s.tar.gz -C /data .', [Volume_db_data, Volume_db_data]));
    CmdDatei.Add('if errorlevel 1 (');
    CmdDatei.Add('    echo Fehler beim Sichern von ''db_data''. Abbruch.');
    CmdDatei.Add('    pause');
    CmdDatei.Add('    exit /b 1');
    CmdDatei.Add(')');
    CmdDatei.Add('');
    CmdDatei.Add('echo Backup: export');
    CmdDatei.Add('echo Bitte warten, Backup kann sehr lange dauern.');
    CmdDatei.Add('echo ...');
    CmdDatei.Add('echo ......');
    CmdDatei.Add('echo .........');
    CmdDatei.Add(Format('docker run --rm -v %s:/data -v "%%BACKUP_DIR%%":/backup alpine tar czvf /backup/%s.tar.gz -C /data .', [Volume_export, Volume_export]));
    CmdDatei.Add('if errorlevel 1 (');
    CmdDatei.Add('    echo Fehler beim Sichern von ''export''. Abbruch.');
    CmdDatei.Add('    pause');
    CmdDatei.Add('    exit /b 1');
    CmdDatei.Add(')');
    CmdDatei.Add('');
    CmdDatei.Add('echo Backup: media');
    CmdDatei.Add('echo Bitte warten, Backup kann sehr lange dauern.');
    CmdDatei.Add('echo ...');
    CmdDatei.Add('echo ......');
    CmdDatei.Add('echo .........');
    CmdDatei.Add(Format('docker run --rm -v %s:/data -v "%%BACKUP_DIR%%":/backup alpine tar czvf /backup/%s.tar.gz -C /data .', [Volume_media, Volume_media]));
    CmdDatei.Add('if errorlevel 1 (');
    CmdDatei.Add('    echo Fehler beim Sichern von ''media''. Abbruch.');
    CmdDatei.Add('    pause');
    CmdDatei.Add('    exit /b 1');
    CmdDatei.Add(')');
    CmdDatei.Add('');
    CmdDatei.Add('::=== Container wieder starten ===');
    CmdDatei.Add('echo Starte Docker-Container neu...');
    CmdDatei.Add('docker compose up -d');
    CmdDatei.Add('if errorlevel 1 (');
    CmdDatei.Add('    echo Fehler beim Starten der Container. Manuell pruefen.');
    CmdDatei.Add('    pause');
    CmdDatei.Add('    exit /b 1');
    CmdDatei.Add(')');
    CmdDatei.Add('');
    CmdDatei.Add('echo Nicht mehr verwendete Volumes werden geloescht');
    CmdDatei.Add('for /L %%i in (3,-1,1) do (echo %%i & timeout /t 1 >nul)');
    CmdDatei.Add('docker volume prune -f');
    CmdDatei.Add('for /L %%i in (3,-1,1) do (echo %%i & timeout /t 1 >nul)');
    CmdDatei.Add('echo -----------------------------------------');
    CmdDatei.Add('echo Backup abgeschlossen: %DATE% %TIME%');
    CmdDatei.Add('echo Dateien gespeichert in: %BACKUP_DIR%');
    CmdDatei.Add('echo -----------------------------------------');
    CmdDatei.Add('echo Systeme starten. Fenster wird gleich geschlossen ...');
		CmdDatei.Add('echo Backup.log wurde gespeichert unter: "' + IncludeTrailingPathDelimiter(AppDataFolder) + 'Backup.log"');
    CmdDatei.Add('echo Backup abgeschlossen: %DATE% %TIME% >> "' + IncludeTrailingPathDelimiter(AppDataFolder) + 'Backup.log"');
    CmdDatei.Add('echo Backup-Ziel: %BACKUP_DIR% >> "' + IncludeTrailingPathDelimiter(AppDataFolder) + 'Backup.log"');
    CmdDatei.Add('for /L %%i in (10,-1,1) do (echo %%i & timeout /t 1 >nul)');
    CmdDatei.Add('endlocal');
    CmdDatei.Add('exit');
    CmdDatei.SaveToFile(CmdZielPfad, TEncoding.ANSI);
    ScriptSavedLbl.Caption := 'Backup-Skript wurde erstellt: ' + CmdZielPfad;
    CmdSkriptStartenUndUeberwachen;
  finally
    CmdDatei.Free;
  end;
end;

procedure TMainformFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caNone;         // verhindert weitere Verarbeitung
  PostQuitMessage(0);       // beendet die MessageLoop
	Application.Terminate;
end;

procedure TMainformFrm.FormCreate(Sender: TObject);
begin

	AppDataFolder := IncludeTrailingPathDelimiter(GetEnvironmentVariable('USERPROFILE')) + 'Paperless Backup Programm';
  //Erzeugen des Windows /Benutzer/"Paperless Backup Programm" Ordners wenn nicht vorhanden
  if not DirectoryExists(AppDataFolder) then ForceDirectories(AppDataFolder);

  //Variablen Initialisieren
  IstEsAutostart := False;
  NeueComposeSchreiben := False;
  IstEsBackup := False;
  IstEsPaperlessInstallation := False;
  PaperlessOefnnen := False;
  IstEsUpdate := False;
  PaperlessNeustart := False;
  PaperlessUpdate := False;
  PapierkorbAufbewahrung := 365;
end;

procedure TMainformFrm.FormShow(Sender: TObject);
var
  //PfadInstallationAbgeschlossen: String;
  StartParameter: string;
  Ini: TIniFile;
  Wert: string;
  PfadComposeTxt: string;
  AlterPfad: string;
  GespeicherterPfad: string;
  TxtPfad: String;
begin
  AktuellGestestetPaperlessVersion := 'v2.19.2';
  Label3.Caption :=  'Getestet mit: Paperless-ngx ' + AktuellGestestetPaperlessVersion;
	Label6.Caption :=  'Getestet mit: Paperless-ngx ' + AktuellGestestetPaperlessVersion;
	Label9.Caption :=  'Getestet mit: Paperless-ngx ' + AktuellGestestetPaperlessVersion;
	Label14.Caption := 'Getestet mit: Paperless-ngx ' + AktuellGestestetPaperlessVersion;
	Label28.Caption := 'Getestet mit: Paperless-ngx ' + AktuellGestestetPaperlessVersion;
	Label29.Caption := 'Getestet mit: Paperless-ngx ' + AktuellGestestetPaperlessVersion;

  AppDataFolder := IncludeTrailingPathDelimiter(GetEnvironmentVariable('USERPROFILE')) + 'Paperless Backup Programm';

  //In die ini verlegt
  //HinweisDatei := IncludeTrailingPathDelimiter(AppDataOrdner) + 'HinweisVerstanden.txt';

  //Ordner Paperless-Input auf Desktop abfragen, und bei nichtvorhandensein anlegen
  //Variable PaperlessInput für compose Neuerzeugung befüllen
  PaperlessInput := IncludeTrailingPathDelimiter(GetEnvironmentVariable('USERPROFILE')) + 'Desktop\Paperless-Input';
  if not DirectoryExists(PaperlessInput) then ForceDirectories(PaperlessInput);
  SpeichereLeereEnvDatei();

  //Hinweis verstanden in ini suchen
  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(Mainform.AppDataFolder) + 'Einstellungen.ini');
  try
    Wert := Ini.ReadString('Einrichtung', 'Hinweis verstanden', '');
  finally
    Ini.Free;
  end;

	if Wert = 'Ja' then
	begin
  	HinweisDatei := IncludeTrailingPathDelimiter(Mainform.AppDataFolder) + 'HinweisVerstanden.txt';
    //Wenn ini Eintrag sicher vorhanden ist, Hinweisdatei löschen
  	if FileExists(HinweisDatei) then DeleteFile(HinweisDatei);

  	// Nach 30 Tagen Hinweis anzeigen
  	if DaysBetween(Now, FileDateToDateTime(FileAge(IncludeTrailingPathDelimiter(Mainform.AppDataFolder) + 'Einstellungen.ini'))) > 30 then
  	begin
    	HinweisFrm := THinweisFrm.Create(Self);
    	try
      	HinweisFrm.ShowModal;
      	//if not WillInstallieren then
    	finally
      	HinweisFrm.Free;
    	end;
  	end;
  end else
		begin
  		HinweisFrm := THinweisFrm.Create(Self);
  		try
    		HinweisFrm.ShowModal;
    		//if not WillInstallieren then
  		finally
    		HinweisFrm.Free;
  		end;
	end;



	TxtPfad := IncludeTrailingPathDelimiter(AppDataFolder) + 'DockerComposePfad.txt';
	if FileExists(TxtPfad) then
	begin
  	// Pfad aus TXT lesen
  	AlterPfad := TFile.ReadAllText(TxtPfad, TEncoding.UTF8).Trim;

  	// In INI schreiben
  	Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + 'Einstellungen.ini');
  	try
    	Ini.WriteString('Pfade', 'DockerComposePfad', AlterPfad);
   	 	Ini.UpdateFile; // sofortiges Schreiben erzwingen
  	finally
    	Ini.Free;
  	end;

  // TXT löschen
  DeleteFile(TxtPfad);
	end;

  IstEsBackup := True;

  StandardOrdner := IncludeTrailingPathDelimiter(GetEnvironmentVariable('USERPROFILE')) + 'Desktop\Paperless-Backup';
  if not DirectoryExists(StandardOrdner) then ForceDirectories(StandardOrdner);

  // Wenn alte TXT vorhanden, Pfad lesen und in INI schreiben
  TxtPfad := IncludeTrailingPathDelimiter(AppDataFolder) + 'BackupZiel.txt';
  if FileExists(TxtPfad) then
  begin
    GespeicherterPfad := TFile.ReadAllText(TxtPfad, TEncoding.UTF8).Trim;
    Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + 'Einstellungen.ini');
    try
      Ini.WriteString('Pfade', 'BackupZiel', GespeicherterPfad);
      Ini.UpdateFile; // sofort speichern
      // Direkt aus der INI wieder lesen
      GespeicherterPfad := Ini.ReadString('Pfade', 'BackupZiel', '').Trim;
    finally
      Ini.Free;
    end;
    // Wenn aus INI erfolgreich gelesen, TXT löschen
    if GespeicherterPfad <> '' then DeleteFile(TxtPfad);
  end;

	// Wert aus INI lesen
	Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + 'Einstellungen.ini');
	try
  	LetzterBackupOrdner := Ini.ReadString('Pfade', 'BackupZiel', '').Trim;
	finally
  	Ini.Free;
	end;

 	PruefeObPlanungErlaubt;

  LadeZeitplanEinstellungen;

  StatusBar1.Panels.Clear;
  StatusBar1.Height:= 25;
  StatusBar1.Font.Size:= 10;
  StatusBar1.Font.Style:= [fsBold];
  StatusBar1.Panels.Add.Text := ' ' + ' #ComputerRalle - Paperless Backup Programm ' + HoleDateiVersion(Application.ExeName);
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
   EmailEinstellungenLesen;
 	end;
	if TabControl1.TabIndex = 5 then
 	begin
   BackupRestorePan.Visible := False;
   BackupPlanPan.Visible := False;
   RetentionPan.Visible := False;
   EMailSettingsPan.Visible := False;
   SettingsPan.Visible := False;
   HelpPan.Visible := True;
   EmailEinstellungenLesen;
 	end;

  PfadBackupZiel := IncludeTrailingPathDelimiter(AppDataFolder) + 'BackupZiel.txt';

	PfadComposeTxt := IncludeTrailingPathDelimiter(AppDataFolder) + 'DockerComposePfad.txt';
	if FileExists(PfadComposeTxt) then
  	begin
    	// Pfad aus TXT lesen
    	AlterPfad := TFile.ReadAllText(PfadComposeTxt, TEncoding.UTF8);

    	// In INI schreiben
    	Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + 'Einstellungen.ini');
    	try
      	Ini.WriteString('Pfade', 'DockerComposePfad', AlterPfad);
      	Ini.UpdateFile; // sofort speichern
    	finally
      	Ini.Free;
    	end;

    	// TXT löschen, da jetzt in INI gespeichert
    	DeleteFile(PfadComposeTxt);
  end;

  //Prüfen ob der neue ComposePfad bereits vorhanden ist
  NeuerComposePfad := IncludeTrailingPathDelimiter(AppDataFolder);

  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + 'Einstellungen.ini');
  try
    Wert := Ini.ReadString('Einrichtung', 'Installation abgeschlossen', '');
  finally
    Ini.Free;
  end;

  //ist die InstallationAbgeschlossen.txt vorhanden, in die ini übernehmen
  PfadInstallationAbgeschlossen := IncludeTrailingPathDelimiter(AppDataFolder) + 'InstallationAbgeschlossen.txt';
	if FileExists(PfadInstallationAbgeschlossen) then
  	begin
    	Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + 'Einstellungen.ini');
    	try
      	Ini.WriteString('Einrichtung', 'Installation abgeschlossen', 'Ja');
        Ini.UpdateFile;
    	finally
      	Ini.Free;
    	end;

    	// Alte TXT löschen, da jetzt in der INI gespeichert
    	DeleteFile(PfadInstallationAbgeschlossen);
  	end;

  //Ini ein weiteres mal auslesen
  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + 'Einstellungen.ini');
  try
    Wert := Ini.ReadString('Einrichtung', 'Installation abgeschlossen', '');
  finally
    Ini.Free;
  end;

	if Wert <> 'Ja' then
	begin
  	NeuerComposePfad := IncludeTrailingPathDelimiter(AppDataFolder) + 'docker-compose.yml';

  	if not FileExists(NeuerComposePfad) then
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

    	NeueComposeSchreiben := True;
    	HinweisFrm.ErzeugeDockerComposeDatei;
    	HinweisFrm.PaperlessInstallierenBtnClick(Self);
  	end;

  	ComposePfad := NeuerComposePfad;
	end else
		begin
  		ComposePfad := IncludeTrailingPathDelimiter(AppDataFolder) + 'docker-compose.yml';
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

  // BackupPfad laden, falls vorhanden
  if FileExists(PfadBackupZiel) then BackupPfad := TFile.ReadAllText(PfadBackupZiel).Trim;

  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + 'Einstellungen.ini');
  try
    GespeicherterPfad := Ini.ReadString('Pfade', 'DockerComposePfad', '').Trim;
  finally
    Ini.Free;
  end;

  // ComposePfad aus ini laden, falls vorhanden   Es wird letzter gültiger Compose-Ordner und Backup-Zielordner übernommen
  if GespeicherterPfad <> '' then
  begin
    ComposePfad := GespeicherterPfad;
    ComposeName := ExtractFileName(ExcludeTrailingPathDelimiter(ComposePfad));
    StaticText2.Caption := 'Aktuell ist folgender Pfad ausgewählt, in dem die docker-compose.yml Datei liegt: ';
    StaticText3.Caption := ComposePfad;
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
  	//ShowMessage('Gestartet durch Aufgabenplanung.');
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
    IstEsAutostart := True;
    AutostartBackup();
	end else
		begin
  		//ShowMessage('Normal gestartet.');
		end;

   // INI auslesen und ins Editfeld schreiben / Papierkorb Aufbewahrung
   Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + 'Einstellungen.ini');
   try
    try
      PapierkorbAufbewahrung := Ini.ReadInteger('Einstellungen', 'Papierkorb Aufbewahrungszeit in Tagen', 365);
    except
      PapierkorbAufbewahrung := 365;
    end;
    PapierkorbAufbewahrungEdit.Text := IntToStr(PapierkorbAufbewahrung);
   finally
    Ini.Free;
   end;

   SchreibeComposeContainerUndVolumesInfo(ExtractFilePath(ComposePfad));


  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + 'Einstellungen.ini');
  //Versionen der Images auslesen, wenn leer Standard
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

procedure TMainformFrm.AutostartBackup();
begin
  //Als einzelne Routune, falls mir noch was einfällt
  StartPaperlessBackupBtn.Click;
end;

procedure TMainformFrm.PaperlessBackupStartenSpBtnClick(Sender: TObject);
begin
  ErzeugeBackupScript(ExtractFilePath(ComposePfad));
end;

procedure TMainformFrm.TabControl1Change(Sender: TObject);
var
  EMailVersandEingerichtet: string;
  Ini: TIniFile;
begin
	Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + 'Einstellungen.ini');
		try
  		Ini.WriteString('Pfade', 'DockerComposePfad', IncludeTrailingPathDelimiter(ExtractFilePath(ComposePfad)) + 'docker-compose.yml');
  		Ini.UpdateFile; // sofortiges Schreiben erzwingen
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
   EmailEinstellungenLesen;
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

  	with DigitalEasyLbl do
		begin
  		StyleElements := StyleElements - [seFont];
  		Transparent := True;
  		Font.Color := clYellow;
		end;

  	with ComputerRalleLbl do
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
 	PruefeObPlanungErlaubt;
end;

///////////////////////////////////////////
//Zeitplan
///////////////////////////////////////////

procedure TMainformFrm.PapierkorbAufbewahrungEditChange(Sender: TObject);
var
  i: Integer;
  s: string;
  istGanzzahl: Boolean;
begin
  s := PapierkorbAufbewahrungEdit.Text;
  istGanzzahl := True;

  //Check if it is Integer
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



procedure TMainformFrm.SaveRetentionBtnClick(Sender: TObject);
var
  Ini: TIniFile;
  MaxBackupOrdner: Integer;
begin
  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + 'Einstellungen.ini');
  try
    // In die INI schreiben
    Ini.WriteInteger('Zeitplan', 'BackupsBehalten', KeepBackupsSpE.Value);
    // stellt sicher, dass es sofort geschrieben wird
    Ini.UpdateFile;
    // Danach sofort wieder lesen, aber abgesichert
    try
      MaxBackupOrdner := Ini.ReadInteger('Zeitplan', 'BackupsBehalten', 0);
    except
      MaxBackupOrdner := 0;
    end;
  finally
    Ini.Free;
  end;
  // Anzeige des Labels nur bei 0
  if KeepBackupsSpE.Value = 0 then
  AllBackupsAreRetainedLbl.Visible := True else
  AllBackupsAreRetainedLbl.Visible := False;
end;

procedure TMainformFrm.AutoBackupCBClick(Sender: TObject);
begin
  //Checkboxen, Labels und Elemente einschalten / ausschalten
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

procedure TMainformFrm.SpeichereZeitplanEinstellungen;
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

procedure TMainformFrm.DeleteBackupPlanBtnClick(Sender: TObject);
var
  Sei: TShellExecuteInfo;
  CmdZielPfad: string;
  CmdDatei: TStringList;
  Ini: TIniFile;
begin
  // Task aus Aufgabenplanung entfernen
  CmdZielPfad := IncludeTrailingPathDelimiter(AppDataFolder) + 'Backup-Zeitplan-Entfernen.cmd';
  CmdDatei := TStringList.Create;
  try
    CmdDatei.Add('@echo off');
    CmdDatei.Add('setlocal');
    CmdDatei.Add('echo Backup-Aufgabe wird aus der Aufgabenplanung entfernt');
    CmdDatei.Add('schtasks /delete /tn "PaperlessBackup" /f');
    CmdDatei.Add('echo Fertig');
    CmdDatei.Add('endlocal');
    CmdDatei.Add('exit');

    CmdDatei.SaveToFile(CmdZielPfad, TEncoding.ANSI);
    ScriptSavedLbl.Caption := 'Skript gespeichert: ' + CmdZielPfad;
  finally
    CmdDatei.Free;
  end;

  // Startet das Skript still im Hintergrund
  FillChar(Sei, SizeOf(Sei), 0);
  Sei.cbSize := SizeOf(Sei);
  Sei.fMask := SEE_MASK_NOCLOSEPROCESS;
  Sei.Wnd := 0;
  Sei.lpFile := PChar('cmd.exe');
  Sei.lpParameters := PChar('/c "' + CmdZielPfad + '"');
  Sei.nShow := SW_HIDE;
  ShellExecuteEx(@Sei);

  // Checkbox zurücksetzen
  AutoBackupCB.Checked := False;
  // Checkboxen deaktivieren und Einstellungen speichern
  AutoBackupCBClick(nil);
  // Sicherstellen, dass Ini-Datei auf False steht
  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + 'Einstellungen.ini');
  try
    Ini.WriteBool('Zeitplan', 'Backup nach diesem Zeitplan', False);
  finally
    Ini.Free;
  end;
  ShowMessage('Der geplante Backup-Zeitplan wurde entfernt.');
end;

procedure TMainformFrm.LadeZeitplanEinstellungen;
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

  // Nach dem Laden die Oberfläche anpassen
  AutoBackupCBClick(nil);

  Label12.Visible := True;
  Label11.Visible := True;

  if KeepBackupsSpE.Value = 0 then
  AllBackupsAreRetainedLbl.Visible := True else
  AllBackupsAreRetainedLbl.Visible := False;
end;

procedure TMainformFrm.CreateBackupPlanBtnClick(Sender: TObject);
var
  Weekdays: string;
  Hour, Minute: string;
  CmdDatei: TStringList;
  SkriptPfad, ComposePfad, ZielCmdPfad: string;
  Sei: TShellExecuteInfo;
  ProgrammPfad: String;
  Ini: TIniFile;
  ComposePfadIni: string;
  PfadComposeTxt: string;
begin
  //exe Pfad ermitteln
  ProgrammPfad := ParamStr(0);
	SpeichereZeitplanEinstellungen;
  // Vorbedingungen prüfen

// DockerComposePfad aus der INI lesen
Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + 'Einstellungen.ini');
try
  ComposePfadIni := Ini.ReadString('Pfade', 'DockerComposePfad', '').Trim;
finally
  Ini.Free;
end;

// Prüfen, ob Backup-Ziel oder Compose-Pfad fehlen
if (ComposePfadIni = '') or
   not FileExists(ComposePfadIni) then
begin
  ShowMessage('Fehlender Docker-Compose-Pfad.' + sLineBreak +
              'Bitte führen Sie zuerst ein reguläres Backup durch,' + sLineBreak +
              'damit der Speicherort festgelegt werden kann.');
  Exit;
end;

  (**
  // DockerComposePfad aus der INI lesen
  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataOrdner) + 'Einstellungen.ini');
  try
    ComposePfadIni := Ini.ReadString('Pfade', 'DockerComposePfad', '').Trim;
  finally
    Ini.Free;
  end;

  // Prüfen, ob Backup-Ziel oder Compose-Pfad fehlen
  if (ComposePfadIni = '') or
     not FileExists(IncludeTrailingPathDelimiter(ComposePfadIni) + 'docker-compose.yml') then
  begin
    ShowMessage('Fehlender Docker-Compose-Pfad.' + sLineBreak +
                'Bitte führen Sie zuerst ein reguläres Backup durch,' + sLineBreak +
                'damit der Speicherort festgelegt werden kann.');
    Exit;
  end;  **)

  //if not FileExists(PfadBackupZiel) then
  //begin
  //  ShowMessage('Fehlende Pfade.' + sLineBreak + 'Bitte führen Sie zuerst ein reguläres Backup durch,' + sLineBreak + 'damit die Speicherorte festgelegt werden können.');
  //  Exit;
  //end;


  // Uhrzeit holen
  Hour := Format('%.2d', [HourSpE.Value]);
  Minute := Format('%.2d', [MinuteSpE.Value]);
  // Wochentage zusammensetzen
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
  // Pfad zur geplanten CMD-Datei aus Compose-Pfad erzeugen
  try
    Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + 'Einstellungen.ini');
    try
      ComposePfad := Ini.ReadString('Pfade', 'DockerComposePfad', '').Trim;
    finally
      Ini.Free;
    end;

    if ComposePfad = '' then
    begin
      ShowMessage('Fehler: Kein Docker-Compose-Pfad in der INI gespeichert.');
      Exit;
    end;

    // TXT löschen, wenn vorhanden
    PfadComposeTxt := IncludeTrailingPathDelimiter(AppDataFolder) + 'DockerComposePfad.txt';
    if FileExists(PfadComposeTxt) then DeleteFile(PfadComposeTxt);

    ZielCmdPfad := IncludeTrailingPathDelimiter(ExtractFilePath(ComposePfad)) + 'paperless-backup-geplant.cmd';
  except
    ShowMessage('Fehler beim Lesen des Compose-Pfads.');
    Exit;
  end;


  ZielCmdPfad := IncludeTrailingPathDelimiter(ExtractFilePath(ComposePfad)) + 'paperless-backup-geplant.cmd';
  if not FileExists(ZielCmdPfad) then
  begin
    ShowMessage('Das geplante Backup-Skript wurde nicht gefunden:' + sLineBreak + ZielCmdPfad + sLineBreak + 'Bitte erzeugen Sie es zuerst.');
    Exit;
  end;
  // Aufgabenplanungs-Skript schreiben
  SkriptPfad := IncludeTrailingPathDelimiter(AppDataFolder) + 'Backup-Zeitplan-Anlegen.cmd';
	CmdDatei := TStringList.Create;
	try
  	CmdDatei.Add('@echo off');
  	CmdDatei.Add('echo === Backup-Aufgabe wird in die Aufgabenplanung eingetragen ===');
    //hier soll der Programmpfad in den Tsk geschrieben werden, und das Programm gestartet werden
		CmdDatei.Add(Format(
  	'schtasks /create /tn "PaperlessBackup" /tr "\"%s\" /geplant" /sc weekly /d %s /st %s:%s /f',
  	[ProgrammPfad, Weekdays, Hour, Minute]
		));
  	CmdDatei.Add('echo === Fertig ===');
  	CmdDatei.SaveToFile(SkriptPfad, TEncoding.ANSI);
	finally
  	CmdDatei.Free;
	end;

  ShowMessage('Die geplante Backup-Aufgabe wurde als Aufgabe eingetragen und als Skript gespeichert:' + sLineBreak + SkriptPfad);
  // Startet das Skript still im Hintergrund
  FillChar(Sei, SizeOf(Sei), 0);
  Sei.cbSize := SizeOf(Sei);
  Sei.fMask := SEE_MASK_NOCLOSEPROCESS;
  Sei.Wnd := 0;
  Sei.lpFile := PChar('cmd.exe');
  Sei.lpParameters := PChar('/c "' + SkriptPfad + '"');
  Sei.nShow := SW_HIDE;
  ShellExecuteEx(@Sei);
end;

procedure TMainformFrm.EmailEinstellungenLesen;
var
  EnvFilePath: string;
  EnvList: TStringList;
begin
  // Pfad zur .env Datei im AppDataOrdner
  EnvFilePath := IncludeTrailingPathDelimiter(AppDataFolder) + 'email-versand.env';

  // Überprüfen, ob die Datei existiert
  if FileExists(EnvFilePath) then
  begin
    // Erstellen der TStringList-Instanz zum Einlesen der Datei
    EnvList := TStringList.Create;
    try
      // Die .env-Datei einlesen
      EnvList.LoadFromFile(EnvFilePath);

      // Überprüfen, ob die Einrichtung noch aussteht
      if EnvList.Values['Eingerichtet'] = 'Nein' then
      begin
        EinstellungenMussAbgeschlossenWerden;
      end
      else
      begin
        // Die Werte aus der Datei in die Eingabefelder setzen
        SMTPServerEdit.Text := EnvList.Values['PAPERLESS_EMAIL_HOST'];
        SMTPPortEdit.Text := EnvList.Values['PAPERLESS_EMAIL_PORT'];
        UserNameEdit.Text := EnvList.Values['PAPERLESS_EMAIL_HOST_USER'];
        MailAccountPasswordEdit.Text := EnvList.Values['PAPERLESS_EMAIL_HOST_PASSWORD'];
        EMailSentFromEdit.Text := EnvList.Values['PAPERLESS_EMAIL_FROM'];

        // SSL/TLS-Auswahl basierend auf den gespeicherten Werten
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
          // Wenn weder SSL noch TLS ausgewählt wurde, keine Auswahl
          SSLoTLSRg.ItemIndex := -1;  // Keine Auswahl
        end;

        // Falls beide Werte leer sind, keine Auswahl treffen
        if (EnvList.Values['PAPERLESS_EMAIL_USE_SSL'] = '') and (EnvList.Values['PAPERLESS_EMAIL_USE_TLS'] = '') then
        begin
          SSLoTLSRg.ItemIndex := -1; // Keine Auswahl
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

procedure TMainformFrm.EinstellungenMussAbgeschlossenWerden;
var
  Antwort: Integer;
begin
  IstEsUpdate:= True;

  // Zeige eine MessageBox mit OK und Abbruch
  Antwort := MessageDlg('E-Mail-Einstellungen stehen aus. Dazu muss Paperless gestoppt werden.' + sLineBreak +
                        'Es werden einige Einstellungen angepasst, eine neue docker-compose-Datei'  + sLineBreak +
                        'erzeugt und Paperless dann neu gestartet.' + sLineBreak + sLineBreak +
                        'Wenn dieser Vorgang abgeschlossen ist, können Sie ihre Mail-Server-Daten ins Formular eintragen.'  + sLineBreak +
                        'Danach ist Paperless in der Lage, Dokumente via Mail zu versenden' + sLineBreak + sLineBreak +
                        'Möchten Sie fortfahren?', mtConfirmation, [mbOk, mbCancel], 0);

  // Wenn der Benutzer auf OK klickt, fahre fort
  if Antwort = mrOk then
  begin
    // Neue Compose Datei "docker-compose.yml" schreiben
 		HinweisFrm.ErzeugeDockerComposeDatei;
  end
  else
  begin
    // Wenn der Benutzer auf Abbruch klickt
    ShowMessage('Der Vorgang wurde abgebrochen.');
  end;
end;

// --------------------------------------------------------------
// Diese Prozedur speichert die aktuellen Einstellungen und Versionsinformationen
// in die Datei "Einstellungen.ini". Die Routine ist in zwei Hauptabschnitte unterteilt:
// 1. Allgemeine Einstellungen (z. B. Papierkorb-Aufbewahrungszeit)
// 2. Versionen der Docker-Komponenten (Paperless, Redis, PostgreSQL usw.)
// Nach dem Speichern wird der Benutzer gefragt, ob Paperless neu gestartet werden soll,
// damit die Änderungen übernommen werden.
//
// This procedure saves the current settings and version information
// into the "Einstellungen.ini" file. The routine is divided into two main sections:
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
    // Abschnitt 1: Allgemeine Einstellungen speichern / Save general settings
    // --------------------------------------------------------------
    Ini.WriteInteger('Einstellungen', 'Papierkorb Aufbewahrungszeit in Tagen',
      StrToIntDef(PapierkorbAufbewahrungEdit.Text, 0));
    Ini.UpdateFile; // Sofortiges Schreiben erzwingen / force immediate write

    SettingsSavedLbl.Visible := True; // Anzeige: Speichern erfolgreich / show confirmation

    // Gespeicherte Werte wieder einlesen / re-read stored value safely
    try
      PapierkorbAufbewahrung :=
        Ini.ReadInteger('Einstellungen', 'Papierkorb Aufbewahrungszeit in Tagen', 0);
    except
      PapierkorbAufbewahrung := 365; // Fallback auf Standardwert / fallback default
    end;

    // --------------------------------------------------------------
    // Abschnitt 2: Versionsinformationen speichern / Save version information
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
  // Abschnitt 3: Benutzerinteraktion / User interaction
  // --------------------------------------------------------------
  if MessageDlg(
    'Paperless muss neu gestartet werden, um die Einstellungen zu übernehmen. ' +
    'Möchten Sie Paperless neu starten?',
    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    IstEsUpdate := True;
    Application.MessageBox(
      'Paperless wird heruntergefahren und es wird nach Updates gesucht. ' + #13#10 +
      'Sollten Updates vorliegen, werden diese installiert.' + #13#10 +
      'Geben Sie Paperless nach dem Neustart Zeit.',
      'Info', MB_OK or MB_ICONINFORMATION or MB_TOPMOST);
    PaperlessUpdate := True;
    IstEsUpdate := True;
    HinweisFrm.ErzeugeDockerComposeDatei;
  end;
end;


procedure TMainformFrm.EMailBlankoEinstellungenSpeichern();
var
  EnvList: TStringList;
  EnvFilePath: string;
begin
	// Erstellen des vollständigen Pfades zur Datei
  EnvFilePath := IncludeTrailingPathDelimiter(AppDataFolder) + 'email-versand.env';

  // Überprüfen, ob der Ordner existiert
  if not DirectoryExists(AppDataFolder) then
  begin
    ShowMessage('Der angegebene AppData-Ordner existiert nicht.');
    Exit;
  end;

  // Erstellen der TStringList-Instanz
  EnvList := TStringList.Create;
  try
    // Hinzufügen der Konfigurationen in die email-versand.env
    EnvList.Add('PAPERLESS_EMAIL_HOST=' + SMTPServerEdit.Text);
    if SMTPPortEdit.Text = '' then
    EnvList.Add('PAPERLESS_EMAIL_PORT=25') else
    EnvList.Add('PAPERLESS_EMAIL_PORT=' + SMTPPortEdit.Text);
    EnvList.Add('PAPERLESS_EMAIL_HOST_USER=' + UserNameEdit.Text);
    EnvList.Add('PAPERLESS_EMAIL_HOST_PASSWORD=' + MailAccountPasswordEdit.Text);
    EnvList.Add('PAPERLESS_EMAIL_FROM=' + EMailSentFromEdit.Text);

		// Speichern der SSL/TLS-Auswahl
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

    // Speichern der Datei
    EnvList.SaveToFile(EnvFilePath, TEncoding.ANSI);
  except
    on E: Exception do
      ShowMessage('Fehler beim Speichern der Datei: ' + E.Message);
  end;
  // Aufräumen
  EnvList.Free;
end;

procedure TMainformFrm.SaveEmailSettingsBtnClick(Sender: TObject);
var
  EnvList: TStringList;
  EnvFilePath: string;
begin
	// Erstellen des vollständigen Pfades zur Datei
  EnvFilePath := IncludeTrailingPathDelimiter(AppDataFolder) + 'email-versand.env';

  // Überprüfen, ob der Ordner existiert
  if not DirectoryExists(AppDataFolder) then
  begin
    ShowMessage('Der angegebene AppData-Ordner existiert nicht.');
    Exit;
  end;

  // Erstellen der TStringList-Instanz
  EnvList := TStringList.Create;
  try
    // Hinzufügen der Konfigurationen in die email-versand.env
    EnvList.Add('PAPERLESS_EMAIL_HOST=' + SMTPServerEdit.Text);
    EnvList.Add('PAPERLESS_EMAIL_PORT=' + SMTPPortEdit.Text);
    EnvList.Add('PAPERLESS_EMAIL_HOST_USER=' + UserNameEdit.Text);
    EnvList.Add('PAPERLESS_EMAIL_HOST_PASSWORD=' + MailAccountPasswordEdit.Text);
    EnvList.Add('PAPERLESS_EMAIL_FROM=' + EMailSentFromEdit.Text);

		// Speichern der SSL/TLS-Auswahl
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

    // Speichern der Datei
    EnvList.SaveToFile(EnvFilePath, TEncoding.ANSI);

    // Bestätigung anzeigen
    if IstEsUpdate = False then
    //ShowMessage('Die E-Mail-Versand-Konfiguration wurde in "email-versand.env" im Ordner: Paperless Backup Programm gespeichert.');
  except
    on E: Exception do
      ShowMessage('Fehler beim Speichern der Datei: ' + E.Message);
  end;

  // Aufräumen
  EnvList.Free;

    //Neustart nach Emaileinstellungen ändern
   	Application.MessageBox('Paperless muss neu gestartet werden, um die Einstellungen zu übernehmen.', 'Information',
   	MB_OK or MB_ICONINFORMATION or MB_TOPMOST);
    SaveEmailSettingsBtn.Enabled:=False;
    ErzeugeNeustartScript(ExtractFilePath(ComposePfad));
end;

procedure TMainformFrm.SpeichereLeereEnvDatei();
var
  EnvList: TStringList;
  EnvFilePath: string;
begin
  // Erstellen des vollständigen Pfades zur Datei
  EnvFilePath := IncludeTrailingPathDelimiter(AppDataFolder) + 'email-versand.env';

  // Überprüfen, ob der Ordner existiert
  if not DirectoryExists(AppDataFolder) then
  begin
    ShowMessage('Der angegebene AppData-Ordner existiert nicht.');
    Exit;
  end;

  // Überprüfen ob env Datei existiert  / wenn nicht leere Datei anlegen
	if not FileExists(IncludeTrailingPathDelimiter(AppDataFolder) + 'email-versand.env') then
	begin
  	// Erstellen der TStringList-Instanz
  	EnvList := TStringList.Create;
  	try
    	// Hinzufügen der allgemeinen E-Mail-Einstellungen
      EnvList.Add('Eingerichtet=Nein');
     	EnvList.Add('PAPERLESS_EMAIL_HOST=');
    	EnvList.Add('PAPERLESS_EMAIL_PORT=');
    	EnvList.Add('PAPERLESS_EMAIL_HOST_USER=');
    	EnvList.Add('PAPERLESS_EMAIL_HOST_PASSWORD=');
    	EnvList.Add('PAPERLESS_EMAIL_FROM=');
      EnvList.Add('PAPERLESS_EMAIL_USE_TLS=');
      EnvList.Add('PAPERLESS_EMAIL_USE_SSL=');
    	// Speichern der Datei
    	EnvList.SaveToFile(EnvFilePath);
      //Fehlerbehandlung
  		except
    		on E: Exception do
    	  	ShowMessage('Fehler beim Speichern der Datei: ' + E.Message);
    end;
  	// Aufräumen
  	EnvList.Free;
  end;
end;

procedure TMainformFrm.ErzeugeBackupPlanScript(const ComposePfad: string);
var
  CmdDatei: TStringList;
  BackupOrdnerListe: TArray<string>;
  MaxBackupOrdner: Integer;
  Ini: TIniFile;
begin
  // Fehlerbehandlung: kein Pfad angegeben
  if ComposePfad.Trim = '' then
  begin
    ShowMessage('Fehler: Es wurde kein gültiger Compose-Pfad gewählt.');
    Exit;
  end;

  // Compose-Namen aufbereiten (Leerzeichen -> Bindestrich)
  ComposeName := StringReplace(
                   ExtractFileName(ExcludeTrailingPathDelimiter(ComposePfad)),
                   ' ', '-', [rfReplaceAll]);

  // Pfad für die geplante Backup-CMD
  CmdZielPfad := IncludeTrailingPathDelimiter(ComposePfad) +
                 'paperless-backup-geplant.cmd';

  CmdDatei := TStringList.Create;
  try
    // Backup-Pfad ermitteln: entweder gespeicherter letzter Backup-Ordner,
    // oder Fallback auf Desktop\FallbackBackup

		// Wert aus INI lesen
		Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + 'Einstellungen.ini');
		try
  		LetzterBackupOrdner := Ini.ReadString('Pfade', 'BackupZiel', '').Trim;
		finally
  		Ini.Free;
		end;
		// Wenn kein Wert gesetzt, Fallback nehmen
		if LetzterBackupOrdner = '' then
  		BackupPfad := IncludeTrailingPathDelimiter(GetEnvironmentVariable('USERPROFILE')) + 'Desktop\FallbackBackup\'
		else
  		BackupPfad := IncludeTrailingPathDelimiter(LetzterBackupOrdner);

    // Skriptzeilen erzeugen
    CmdDatei.Add('@echo off');
    CmdDatei.Add('setlocal');
    CmdDatei.Add(Format('set "COMPOSE_DIR=%s"', [ExtractFilePath(ComposePfad)]));
    CmdDatei.Add(Format('set "BACKUP_BASE=%s"', [BackupPfad]));
    CmdDatei.Add('');
    CmdDatei.Add('for /f %%i in (''wmic os get LocalDateTime ^| find "."'') do set "DATUMZEIT=%%i"');
    CmdDatei.Add('set "DATUMZEIT=%DATUMZEIT:~0,4%-%DATUMZEIT:~4,2%-%DATUMZEIT:~6,2%_%DATUMZEIT:~8,2%-%DATUMZEIT:~10,2%-%DATUMZEIT:~12,2%"');
    CmdDatei.Add('set "BACKUP_DIR=%BACKUP_BASE%\%DATUMZEIT%"');
    CmdDatei.Add('');
    CmdDatei.Add('docker exec -i paperless-ngx-paperless-1 python3 manage.py migrate contenttypes');
    CmdDatei.Add('cd /d "%COMPOSE_DIR%"');
    CmdDatei.Add('if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"');
    CmdDatei.Add(Format('docker exec %s pg_dump -U paperless paperless > "%%BACKUP_DIR%%\%s_backup.sql"',
                        [PaperlessDBName, PaperlessDBName]));
    CmdDatei.Add('docker compose down');
    CmdDatei.Add(Format('docker run --rm -v %s:/data -v "%%BACKUP_DIR%%":/backup alpine tar czf /backup/%s.tar.gz -C /data .',
                        [Volume_data, Volume_data]));
    CmdDatei.Add(Format('docker run --rm -v %s:/data -v "%%BACKUP_DIR%%":/backup alpine tar czf /backup/%s.tar.gz -C /data .',
                        [Volume_media, Volume_media]));
    CmdDatei.Add(Format('docker run --rm -v %s:/data -v "%%BACKUP_DIR%%":/backup alpine tar czf /backup/%s.tar.gz -C /data .',
                        [Volume_export, Volume_export]));
    CmdDatei.Add('docker compose up -d');
    CmdDatei.Add('docker volume prune -f');
    CmdDatei.Add('echo Backup abgeschlossen: %DATE% %TIME% >> "' +
                 IncludeTrailingPathDelimiter(AppDataFolder) + 'GeplanterBackup.log"');
    CmdDatei.Add('echo Backup-Ziel: %BACKUP_DIR% >> "' +
                 IncludeTrailingPathDelimiter(AppDataFolder) + 'GeplanterBackup.log"');
    CmdDatei.Add('endlocal');
    CmdDatei.Add('exit');

    // Skript speichern
    CmdDatei.SaveToFile(CmdZielPfad, TEncoding.ANSI);
    ScriptSavedLbl.Caption := 'Plan gespeichert: ' + CmdZielPfad;

    // Backup-Ordner bereinigen (älteste löschen)
    MaxBackupOrdner := KeepBackupsSpE.Value;
		if LetzterBackupOrdner = '' then
  		BackupPfad := IncludeTrailingPathDelimiter(GetEnvironmentVariable('USERPROFILE')) + 'Desktop\FallbackBackup\'
		else
  		BackupPfad := IncludeTrailingPathDelimiter(LetzterBackupOrdner);

    if (MaxBackupOrdner > 0) and DirectoryExists(BackupPfad) then
    begin
      BackupOrdnerListe := TDirectory.GetDirectories(BackupPfad);

      TArray.Sort<string>(BackupOrdnerListe, TComparer<string>.Construct(
        function(const L, R: string): Integer
        var
          DL, DR: TDateTime;

          function OrdnerNameZuDateTime(const Ordner: string): TDateTime;
          var
            Name: string;
            Jahr, Monat, Tag, Stunde, Minute, Sekunde: Word;
          begin
            Result := 0;
            Name := ExtractFileName(Ordner);
            try
              Jahr   := StrToInt(Copy(Name, 1, 4));
              Monat  := StrToInt(Copy(Name, 6, 2));
              Tag    := StrToInt(Copy(Name, 9, 2));
              Stunde := StrToInt(Copy(Name, 12, 2));
              Minute := StrToInt(Copy(Name, 15, 2));
              Sekunde:= StrToInt(Copy(Name, 18, 2));
              Result := EncodeDateTime(Jahr, Monat, Tag, Stunde, Minute, Sekunde, 0);
            except
              Result := 0;
            end;
          end;

        begin
          DL := OrdnerNameZuDateTime(L);
          DR := OrdnerNameZuDateTime(R);
          Result := CompareDateTime(DL, DR); // aufsteigend: älteste zuerst
        end));

      if Length(BackupOrdnerListe) > MaxBackupOrdner then
      begin
        for var i := 0 to Length(BackupOrdnerListe) - MaxBackupOrdner - 1 do
        begin
          TDirectory.Delete(BackupOrdnerListe[i], True); // älteste löschen
        end;
      end;
    end;

  finally
    CmdDatei.Free;
  end;
end;



(**

procedure THauptFormularFrm.ErzeugeBackupPlanScript(const ComposePfad: string);
var
  CmdDatei: TStringList;
  BackupOrdnerListe: TArray<string>;
  MaxBackupOrdner: Integer;
begin
  //Fehlerbehandlung kein Pfad
  if ComposePfad.Trim = '' then
	begin
  	ShowMessage('Fehler: Es wurde kein gültiger Compose-Pfad gewählt.');
  	Exit;
	end;

  ComposeName := StringReplace(ExtractFileName(ExcludeTrailingPathDelimiter(ComposePfad)), ' ', '-', [rfReplaceAll]);
	CmdZielPfad := IncludeTrailingPathDelimiter(ComposePfad) + 'paperless-backup-geplant.cmd';
  CmdDatei := TStringList.Create;
  if FileExists(PfadBackupZiel) then
  begin
    LetzterBackupOrdner := TFile.ReadAllText(PfadBackupZiel).Trim;
    BackupPfad := IncludeTrailingPathDelimiter(LetzterBackupOrdner);
  end
  else
  begin
    BackupPfad := IncludeTrailingPathDelimiter(GetEnvironmentVariable('USERPROFILE')) + 'Desktop\FallbackBackup\';
  end;
  try
  CmdDatei.Add('@echo off');
  CmdDatei.Add('setlocal');
  CmdDatei.Add(Format('set "COMPOSE_DIR=%s"', [ExtractFilePath(ComposePfad)]));
  CmdDatei.Add(Format('set "BACKUP_BASE=%s"', [BackupPfad]));
  CmdDatei.Add('');
  CmdDatei.Add('!!!!!!!!!!!!!!!!! DIESES SKRIPT WIRD IM AUGENBLICK NICHT VERWENDET !!!!!!!!!!!!!!!!!');
  CmdDatei.Add('for /f %%i in (''wmic os get LocalDateTime ^| find "."'') do set "DATUMZEIT=%%i"');
  CmdDatei.Add('set "DATUMZEIT=%DATUMZEIT:~0,4%-%DATUMZEIT:~4,2%-%DATUMZEIT:~6,2%_%DATUMZEIT:~8,2%-%DATUMZEIT:~10,2%-%DATUMZEIT:~12,2%"');
  CmdDatei.Add('set "BACKUP_DIR=%BACKUP_BASE%\%DATUMZEIT%"');
  CmdDatei.Add('');
  CmdDatei.Add('cd /d "%COMPOSE_DIR%"');
  CmdDatei.Add('if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"');
  CmdDatei.Add(Format('docker exec %s pg_dump -U paperless paperless > "%%BACKUP_DIR%%\%s_backup.sql"', [PaperlessDBName, PaperlessDBName]));
  CmdDatei.Add('docker compose down');
  CmdDatei.Add(Format('docker run --rm -v %s:/data -v "%%BACKUP_DIR%%":/backup alpine tar czf /backup/%s.tar.gz -C /data .', [Volume_data, Volume_data]));
	CmdDatei.Add(Format('docker run --rm -v %s:/data -v "%%BACKUP_DIR%%":/backup alpine tar czf /backup/%s.tar.gz -C /data .', [Volume_media, Volume_media]));
	CmdDatei.Add(Format('docker run --rm -v %s:/data -v "%%BACKUP_DIR%%":/backup alpine tar czf /backup/%s.tar.gz -C /data .', [Volume_export, Volume_export]));
  CmdDatei.Add('docker compose up -d');
  CmdDatei.Add('docker volume prune -f');
  CmdDatei.Add('echo Backup abgeschlossen: %DATE% %TIME% >> "' + IncludeTrailingPathDelimiter(AppDataOrdner) + 'GeplanterBackup.log"');
  CmdDatei.Add('echo Backup-Ziel: %BACKUP_DIR% >> "' + IncludeTrailingPathDelimiter(AppDataOrdner) + 'GeplanterBackup.log"');
  CmdDatei.Add('endlocal');
  CmdDatei.Add('exit');
  CmdDatei.SaveToFile(CmdZielPfad, TEncoding.ANSI);
  SkriptGespeichertLbl.Caption := 'Plan gespeichert: ' + CmdZielPfad;

    //Backup-Ordner bereinigen  Aufebewahrung alte Backups Löschen
    MaxBackupOrdner := BackupsBehaltenSpE.Value;

    BackupPfad := IncludeTrailingPathDelimiter(LetzterBackupOrdner);

		if (MaxBackupOrdner > 0) and DirectoryExists(BackupPfad) then
		begin
  	BackupOrdnerListe := TDirectory.GetDirectories(BackupPfad);

  	TArray.Sort<string>(BackupOrdnerListe, TComparer<string>.Construct(
    	function(const L, R: string): Integer
    	var
      	DL, DR: TDateTime;

      	function OrdnerNameZuDateTime(const Ordner: string): TDateTime;
      	var
        	Name: string;
        	Jahr, Monat, Tag, Stunde, Minute, Sekunde: Word;
      	begin
        	Result := 0;
        	Name := ExtractFileName(Ordner);
        	try
          	Jahr   := StrToInt(Copy(Name, 1, 4));
          	Monat  := StrToInt(Copy(Name, 6, 2));
          	Tag    := StrToInt(Copy(Name, 9, 2));
          	Stunde := StrToInt(Copy(Name, 12, 2));
          	Minute := StrToInt(Copy(Name, 15, 2));
          	Sekunde:= StrToInt(Copy(Name, 18, 2));
          	Result := EncodeDateTime(Jahr, Monat, Tag, Stunde, Minute, Sekunde, 0);
        	except
          	Result := 0;
        	end;
      	end;

    	begin
      	DL := OrdnerNameZuDateTime(L);
      	DR := OrdnerNameZuDateTime(R);
      	Result := CompareDateTime(DL, DR);
    	end));

  	if Length(BackupOrdnerListe) > MaxBackupOrdner then
  	begin
    	for var i := 0 to Length(BackupOrdnerListe) - MaxBackupOrdner - 1 do
    	begin
      	TDirectory.Delete(BackupOrdnerListe[i], True);
    	end;
  	end;
		end;

  finally
    CmdDatei.Free;
  end;
end;  **)

procedure TMainformFrm.StarteBackupPlanScriptStill;
var
  SI: TStartupInfo;
  PI: TProcessInformation;
  CmdPfad: string;
begin
  CmdPfad := IncludeTrailingPathDelimiter(AppDataFolder) + 'GeplanterBackupTaskSkript.cmd';
  if not FileExists(CmdPfad) then
  begin
    ShowMessage('Das geplante Backup-Skript wurde nicht gefunden: ' + CmdPfad);
    Exit;
  end;
  ZeroMemory(@SI, SizeOf(SI));
  SI.cb := SizeOf(SI);
  SI.dwFlags := STARTF_USESHOWWINDOW;
  SI.wShowWindow := SW_HIDE;
  if CreateProcess(nil, PChar('"' + CmdPfad + '"'), nil, nil, False,
     CREATE_NO_WINDOW, nil, nil, SI, PI) then
  begin
    CloseHandle(PI.hThread);
    CloseHandle(PI.hProcess);
  end
  else
    ShowMessage('Geplantes Backup-Skript konnte nicht gestartet werden.');
end;

procedure TMainformFrm.StaticText1Click(Sender: TObject);
begin

end;

///////////////////////////////////////////
//Restore
///////////////////////////////////////////

procedure TMainformFrm.RestorePaperlessBackupBtnClick(Sender: TObject);
var
  BackupOrdner: string;
  FolderDialog: TFileOpenDialog;
begin
	SchreibeComposeContainerUndVolumesInfo(ExtractFilePath(ComposePfad));
  StartPaperlessBackupBtn.Enabled := False;
  RestorePaperlessBackupBtn.Enabled := False;
  AutostartLbl.Visible:=False;
  LeseContainerNamenAusDatei;
  IstEsBackup := False;
  IstEsPaperlessInstallation := False;
  if ComposePfad = '' then
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
      BackupOrdner := FolderDialog.FileName;
      ErzeugeRestoreScript(ComposePfad, BackupOrdner);
    end
    else
    begin
      ShowMessage('Wiederherstellung abgebrochen – kein Backup-Ordner gewählt.');
    end;
  finally
    FolderDialog.Free;
  end;
  // Texte auf dem Formular / Programm
  StartPaperlessBackupBtn.Enabled := True;
  RestorePaperlessBackupBtn.Enabled := True;
  CanStartBackupSTxt.Visible := False;
  StaticText5.Visible := False;
  RestoreCanStartSTxt.Visible := True;
  //BackupWiederherProgNeuStartLbl.Visible := True;
end;

procedure TMainformFrm.HabeUpdaetGemachtCbClick(Sender: TObject);
begin                 //Update Fehler
  if HabeUpdaetGemachtCb.State = cbUnchecked then
  PaperlessUpdateBtn.Enabled := False else
  PaperlessUpdateBtn.Enabled := True;
end;

procedure TMainformFrm.ErzeugeRestoreScript(const ComposePfad, BackupOrdner: string);
//Diese Prozedur verwendet die Variablen der Volumen und CT Namen
var
  CmdDatei: TStringList;
begin
	//Fehlerbehandlung kein Pfad
  if ComposePfad.Trim = '' then
  begin
    ShowMessage('Fehler: Es wurde kein gültiger Compose-Pfad gewählt.');
    Exit;
  end;

  CmdZielPfad := IncludeTrailingPathDelimiter(ExtractFilePath(ComposePfad)) + 'paperless-restore.cmd';
  CmdDatei := TStringList.Create;
  try
    CmdDatei.Add('@echo off');
    CmdDatei.Add('setlocal');
    CmdDatei.Add('');
    CmdDatei.Add(':: === Verzeichnisse ===');
    CmdDatei.Add(Format('set "COMPOSE_DIR=%s"', [ExtractFilePath(ComposePfad)]));
    CmdDatei.Add(Format('set "BACKUP_DIR=%s"', [BackupOrdner]));
    CmdDatei.Add('');
    CmdDatei.Add('cd /d "%COMPOSE_DIR%"');
    CmdDatei.Add('if errorlevel 1 ( echo Fehler beim Wechsel in Compose-Verzeichnis & exit /b 1 )');
    CmdDatei.Add('');
    CmdDatei.Add('echo Stoppe Container...');
    CmdDatei.Add('docker compose down');
    CmdDatei.Add('');

    CmdDatei.Add('echo Wiederherstellen Volume: data.');
    CmdDatei.Add('echo Bitte warten, Wiederherstellung kann sehr lange dauern.');
    CmdDatei.Add('echo ...');
    CmdDatei.Add('echo ......');
    CmdDatei.Add('echo .........');
    CmdDatei.Add(Format(
      'if exist "%%BACKUP_DIR%%\%0:s.tar.gz" (' +
      ' docker run --rm -v %0:s:/data -v "%%BACKUP_DIR%%":/backup alpine sh -c "rm -rf /data/* && tar xzvf /backup/%0:s.tar.gz -C /data"' +
      ' ) else ( echo Fehler: %0:s.tar.gz fehlt! & pause & exit /b 1 )',
      [Volume_data]));

    CmdDatei.Add('');
    CmdDatei.Add('echo Wiederherstellen Volume: media.');
    CmdDatei.Add('echo Bitte warten, Wiederherstellung kann sehr lange dauern.');
    CmdDatei.Add('echo ...');
    CmdDatei.Add('echo ......');
    CmdDatei.Add('echo .........');
    CmdDatei.Add(Format(
      'if exist "%%BACKUP_DIR%%\%0:s.tar.gz" (' +
      ' docker run --rm -v %0:s:/data -v "%%BACKUP_DIR%%":/backup alpine sh -c "rm -rf /data/* && tar xzvf /backup/%0:s.tar.gz -C /data"' +
      ' ) else ( echo Fehler: %0:s.tar.gz fehlt! & pause & exit /b 1 )',
      [Volume_media]));

    CmdDatei.Add('');
    CmdDatei.Add('echo Wiederherstellen Volume: export.');
    CmdDatei.Add('echo Bitte warten, Wiederherstellung kann sehr lange dauern.');
    CmdDatei.Add('echo ...');
    CmdDatei.Add('echo ......');
    CmdDatei.Add('echo .........');
    CmdDatei.Add(Format(
      'if exist "%%BACKUP_DIR%%\%0:s.tar.gz" (' +
      ' docker run --rm -v %0:s:/data -v "%%BACKUP_DIR%%":/backup alpine sh -c "rm -rf /data/* && tar xzvf /backup/%0:s.tar.gz -C /data"' +
      ' ) else ( echo Fehler: %0:s.tar.gz fehlt! & pause & exit /b 1 )',
      [Volume_export]));

    CmdDatei.Add('');
    CmdDatei.Add('echo Starte Container...');
    CmdDatei.Add('docker compose up -d');
    CmdDatei.Add('echo Wiederherstellen der PostgreSQL-Datenbank. Bitte haben Sie Geduld...');
    CmdDatei.Add('timeout /t 3 >nul');
    CmdDatei.Add('docker exec -i paperless-ngx-paperless-1 python3 manage.py migrate contenttypes');
    CmdDatei.Add('timeout /t 3 >nul');
    CmdDatei.Add('');
    CmdDatei.Add('echo Wiederherstellen der PostgreSQL-Datenbank (Datenbank wird gestartet) ...');
    CmdDatei.Add('for /L %%i in (15,-1,1) do (echo %%i & timeout /t 1 >nul)');
    CmdDatei.Add(Format('docker exec -i %s psql -U paperless paperless -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"', [PaperlessDBName]));
    CmdDatei.Add(Format('docker exec -i %s psql -U paperless paperless < "%%BACKUP_DIR%%\\%s_backup.sql"', [PaperlessDBName, PaperlessDBName]));
    CmdDatei.Add('');
    CmdDatei.Add('echo Nicht mehr verwendete Volumes werden geloescht');
    CmdDatei.Add('for /L %%i in (3,-1,1) do (echo %%i & timeout /t 1 >nul)');
    CmdDatei.Add('docker volume prune -f');
    CmdDatei.Add('for /L %%i in (3,-1,1) do (echo %%i & timeout /t 1 >nul)');
    CmdDatei.Add('echo -----------------------------------------');
    CmdDatei.Add('echo Wiederherstellung abgeschlossen: %DATE% %TIME%');
    CmdDatei.Add('echo Dateien aus: %BACKUP_DIR%');
    CmdDatei.Add('echo Bitte geben Sie Paperless Zeit, seine Dienste zu starten. Das kann Minuten dauern.');
    CmdDatei.Add('echo -----------------------------------------');
    CmdDatei.Add('echo Systeme starten. Fenster wird gleich geschlossen ...');
    CmdDatei.Add('for /L %%i in (10,-1,1) do (echo %%i & timeout /t 1 >nul)');
    CmdDatei.Add('endlocal');
    CmdDatei.Add('exit');
    CmdDatei.SaveToFile(CmdZielPfad, TEncoding.ANSI);
    ScriptSavedLbl.Caption := 'Restore-Skript wurde erstellt: ' + CmdZielPfad;
    CmdSkriptStartenUndUeberwachen;
  finally
    CmdDatei.Free;
  end;
end;

procedure TMainformFrm.CmdSkriptStartenUndUeberwachen;
var
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  Cmd: string;
  ExitCode: DWORD;
  Warten: Boolean;
begin
  Warten := False;
  FillChar(StartupInfo, SizeOf(TStartupInfo), 0);
  StartupInfo.cb := SizeOf(TStartupInfo);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := SW_SHOWNORMAL;

  Cmd := 'cmd.exe /C "' + CmdZielPfad + '"'; // Pfad zum Skript

  if CreateProcess(nil, PChar(Cmd), nil, nil, False, CREATE_NEW_CONSOLE, nil, nil, StartupInfo, ProcessInfo) then
  begin
    Warten := True;
    Sleep(1500);

    if IstEsUpdate = False then
    begin
        if Warten then
        begin
          // CMD-Fenster in den Vordergrund holen
          ConsoleToFront(ProcessInfo.dwProcessId);

          // Auf Beendigung warten
          WaitForSingleObject(ProcessInfo.hProcess, INFINITE);

          // ExitCode prüfen
          GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);
          CloseHandle(ProcessInfo.hProcess);
          CloseHandle(ProcessInfo.hThread);
          Sleep(1000);
          if ExitCode = 0 then
          begin
            if IstEsPaperlessInstallation = True then
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
              IstEsPaperlessInstallation := False;
            end
            else if IstEsBackup = True then
            begin
              if not IstEsAutostart then
              begin
                Application.MessageBox('Backup abgeschlossen. Sie können das Programm jetzt schließen.' + #13#10 +
                'Bitte geben Sie Paperless Zeit zum starten.',
                'Info', MB_OK or MB_ICONINFORMATION or MB_TOPMOST);
              end;

              HinweisFrm.WriteImageVersion(BackupPfad);

            end
            else
            begin
              if not IstEsAutostart = True then
              begin
                if IstEsUpdate = True then
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
        	// CMD-Fenster in den Vordergrund holen
          ConsoleToFront(ProcessInfo.dwProcessId);
          // Auf Beendigung warten
          WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
          // ExitCode prüfen
          GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);
          CloseHandle(ProcessInfo.hProcess);
          CloseHandle(ProcessInfo.hThread);
        	if ExitCode = 0 then
          begin
            EMailBlankoEinstellungenSpeichern();
          	Application.MessageBox('Paperless wurde erfolgreich aktualisiert' + #13#10 +
          	'Sie können Paperless nun im Browser öffnen (http://localhost:8000). Geben Sie Paperless ein wenig Zeit zum starten.',
            'Installation abgeschlossen', MB_OK or MB_ICONINFORMATION or MB_TOPMOST);
            IstEsUpdate := False;
          end;
        end;
  end;
  ActiveControl := nil;

  if IstEsAutostart = True then
  Application.Terminate;

end;

procedure TMainformFrm.NeuStartStartenUndUeberwachen;
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
  Cmd := 'cmd.exe /C "' + CmdZielPfad + '"'; // Pfad zum Skript

  if PaperlessUpdate = False then
  begin
    // Process starten
    if CreateProcess(nil, PChar(Cmd), nil, nil, False, CREATE_NEW_CONSOLE, nil, nil, StartupInfo, ProcessInfo) then
    begin
      Sleep(1000);
      // CMD-Fenster in den Vordergrund holen
      ConsoleToFront(ProcessInfo.dwProcessId);
      // Auf Beendigung warten
      WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
      // ExitCode prüfen
      GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);
      CloseHandle(ProcessInfo.hProcess);
      CloseHandle(ProcessInfo.hThread);

      // Wenn der ExitCode 0 ist, war alles erfolgreich
      if ExitCode = 0 then
      begin
        Application.MessageBox('Neustart abgeschlossen. Sie können das Programm jetzt schließen.' + #13#10 +
          'Bitte geben Sie den Paperless Komponenten Zeit zum starten.',
          'Info', MB_OK or MB_ICONINFORMATION or MB_TOPMOST);
      end
      else
      begin
        // Fehlerbehandlung, falls der Prozess mit einem Fehlercode beendet wurde
        ShowMessage('Der Vorgang ist fehlgeschlagen. Fehlercode: ' + IntToStr(ExitCode));
      end;
    end
    else
    begin
      ShowMessage('Fehler beim Starten des Prozesses.');
    end;
    ActiveControl := nil; // Entfernt den Fokus vom aktuellen Steuerelement (optional)
  end;

  if PaperlessUpdate = true then
  begin
    // Process starten
    if CreateProcess(nil, PChar(Cmd), nil, nil, False, CREATE_NEW_CONSOLE, nil, nil, StartupInfo, ProcessInfo) then
    begin
      Sleep(1000);
      // CMD-Fenster in den Vordergrund holen
      ConsoleToFront(ProcessInfo.dwProcessId);
      // Auf Beendigung warten
      WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
      // ExitCode prüfen
      GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);
      CloseHandle(ProcessInfo.hProcess);
      CloseHandle(ProcessInfo.hThread);

      // Wenn der ExitCode 0 ist, war alles erfolgreich
      if ExitCode = 0 then
      begin
        Application.MessageBox('Neustart und Updatesuche abgeschlossen. Sie können das Programm jetzt schließen.' + #13#10 +
          'Bitte geben Sie den Paperless Komponenten Zeit zum starten.' + #13#10 +
          'Lagen Updates vor, wurden diese installiert.',
          'Info', MB_OK or MB_ICONINFORMATION or MB_TOPMOST);
      end
      else
      begin
        // Fehlerbehandlung, falls der Prozess mit einem Fehlercode beendet wurde
        ShowMessage('Der Vorgang ist fehlgeschlagen. Fehlercode: ' + IntToStr(ExitCode));
      end;
    end
    else
    begin
      ShowMessage('Fehler beim Starten des Prozesses.');
    end;
    ActiveControl := nil; // Entfernt den Fokus vom aktuellen Steuerelement (optional)
  end;
end;

procedure TMainformFrm.ErzeugeNeustartScript(const ComposePfad: string);
var
  CmdDatei: TStringList;
  BackupOrdnerListe: TArray<string>;
  MaxBackupOrdner: Integer;
begin
  //Fehlerbehandlung kein Pfad
  if ComposePfad.Trim = '' then
	begin
  	ShowMessage('Fehler: Es wurde kein gültiger Compose-Pfad gewählt.');
  	Exit;
	end;
  ComposeName := StringReplace(ExtractFileName(ExcludeTrailingPathDelimiter(ComposePfad)), ' ', '-', [rfReplaceAll]);
	CmdZielPfad := IncludeTrailingPathDelimiter(ComposePfad) + 'paperless-neustart.cmd';
  CmdDatei := TStringList.Create;
  try
  	CmdDatei.Add('@echo off');
  	CmdDatei.Add('setlocal');
  	CmdDatei.Add(Format('set "COMPOSE_DIR=%s"', [ExtractFilePath(ComposePfad)]));
  	CmdDatei.Add('');
  	CmdDatei.Add('');
  	CmdDatei.Add('cd /d "%COMPOSE_DIR%"');
  	CmdDatei.Add('echo Bitte warten, Paperless wird heruntergefahren.');
  	CmdDatei.Add('for /L %%i in (3,-1,1) do (echo %%i & timeout /t 1 >nul)');
  	CmdDatei.Add('docker compose down');
  	CmdDatei.Add('echo Bitte warten, Paperless wird neu gestartet.');
  	CmdDatei.Add('for /L %%i in (3,-1,1) do (echo %%i & timeout /t 1 >nul)');
  	CmdDatei.Add('docker compose up -d');
    CmdDatei.Add('echo Nicht mehr verwendete Volumes werden geloescht');
    CmdDatei.Add('for /L %%i in (3,-1,1) do (echo %%i & timeout /t 1 >nul)');
    CmdDatei.Add('docker volume prune -f');
    CmdDatei.Add('for /L %%i in (3,-1,1) do (echo %%i & timeout /t 1 >nul)');
    CmdDatei.Add('timeout /t 3 >nul');
    CmdDatei.Add('docker exec -i paperless-ngx-paperless-1 python3 manage.py migrate contenttypes');
    CmdDatei.Add('timeout /t 3 >nul');
  	CmdDatei.Add('endlocal');
  	CmdDatei.Add('exit');
  	CmdDatei.SaveToFile(CmdZielPfad, TEncoding.ANSI);
  	ScriptSavedLbl.Caption := 'Plan gespeichert: ' + CmdZielPfad;
  	CmdDatei.SaveToFile(CmdZielPfad, TEncoding.ANSI);
  	ScriptSavedLbl.Caption := 'Backup-Skript wurde erstellt: ' + CmdZielPfad;
  	NeuStartStartenUndUeberwachen;
  finally
    CmdDatei.Free;
  end;
end;

procedure TMainformFrm.ConsoleToFront(PID: DWORD);
var
  hConsoleWnd: HWND;
begin
  //CMD Fenster in den Vordergrund holen
  AttachConsole(PID);
  hConsoleWnd := GetConsoleWindow;
  if hConsoleWnd <> 0 then
  	begin
      ShowWindow(hConsoleWnd, SW_SHOWNORMAL);
      SetForegroundWindow(hConsoleWnd);
    end;
  FreeConsole;
end;

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
  (**  in die Einstellungen gewandert

	IstEsUpdate := True;
	Application.MessageBox('Paperles wird heruntergefahren und es wird nach Updates gesucht. Sollten Updates vorliegen,' + #13#10 +
  'werden diese installiert' + #13#10 +
  'Geben Sie Paperless nach dem Neustart Zeit.',
  'Info', MB_OK or MB_ICONINFORMATION or MB_TOPMOST);
  PaperlessUpdate := True;
  IstEsUpdate := True;
  HinweisFrm.ErzeugeDockerComposeDatei;   **)

  //ErzeugeNeustartScript(ExtractFilePath(ComposePfad));

  //SchreibeComposeContainerUndVolumesInfo(ExtractFilePath(ComposePfad));
  //LeseContainerNamenAusDatei;
end;

(**
procedure THauptFormularFrm.PruefeObPlanungErlaubt;
var
  Ini: TIniFile;
  ComposePfadIni, BackupZielIni: string;
begin
  // Prüfung, ob alle nötigen Dateien vorhanden sind
  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataOrdner) + 'Einstellungen.ini');
  try
    ComposePfadIni := Ini.ReadString('Pfade', 'DockerComposePfad', '').Trim;
    BackupZielIni := Ini.ReadString('Pfade', 'BackupZiel', '').Trim;
  finally
    Ini.Free;
  end;

  // Prüfung, ob alle nötigen Dateien vorhanden sind
	if FileExists(IncludeTrailingPathDelimiter(ComposePfadIni) + 'docker-compose.yml') and (BackupZielIni <> '') then
  begin
    // Alles da Elemente aktivieren
    BackupPlanPan.Enabled := True;
    AufbewahrungPan.Enabled := True;
    BackupPlanAnlegenBtn.Enabled := True;
    AufbewahrungSpeichernBtn.Enabled := True;
    BackupPlanLoeschenBtn.Enabled := True;
    Label13.Caption := 'Beachten Sie, das bei einem Plan die Paperless-Container gestoppt werden.';
    Label20.Caption := 'Beachten Sie die Laufwerksgröße.';
  end
  else
  begin
    // Noch nicht alle Voraussetzungen erfüllt → alles deaktivieren
    BackupPlanPan.Enabled := False;
    AufbewahrungPan.Enabled := False;
    BackupPlanAnlegenBtn.Enabled := False;
    AufbewahrungSpeichernBtn.Enabled := False;
    BackupPlanLoeschenBtn.Enabled := False;
    Label13.Caption := 'Vor der Planung muss ein Backup erstellt werden.';
    Label20.Caption := 'Vor der Einrichtung muss ein Backup erstellt werden.';
  end;
end;
   **)

procedure TMainformFrm.PruefeObPlanungErlaubt;
var
  Ini: TIniFile;
  ComposePfadIni, BackupZielIni: string;
begin
  // Einstellungen einlesen
  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + 'Einstellungen.ini');
  try
    ComposePfadIni := Ini.ReadString('Pfade', 'DockerComposePfad', '').Trim;
    BackupZielIni := Ini.ReadString('Pfade', 'BackupZiel', '').Trim;
  finally
    Ini.Free;
  end;

  // Prüfung, ob Compose-Datei und Backup-Ziel vorhanden sind
  if FileExists(ComposePfadIni) and DirectoryExists(BackupZielIni) then
  begin
    // Voraussetzungen erfüllt → Elemente aktivieren
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
    // Voraussetzungen fehlen → alles deaktivieren
    BackupPlanPan.Enabled := False;
    RetentionPan.Enabled := False;
    CreateBackupPlanBtn.Enabled := False;
    SaveRetentionBtn.Enabled := False;
    DeleteBackupPlanBtn.Enabled := False;
    Label13.Caption := 'Vor der Planung muss ein Backup erstellt werden.';
    Label20.Caption := 'Vor der Einrichtung muss ein Backup erstellt werden.';
  end;
end;


procedure TMainformFrm.SchreibeComposeContainerUndVolumesInfo(const ComposePfad: string);
var
  SL, ContainerZeilen, VolumeZeilen: TStringList;
  ComposeYML, CmdOutput, InfoPfad, Zeile: string;
  i: Integer;
begin
  //ShowMessage(AppDataOrdner);

  ComposeYML := IncludeTrailingPathDelimiter(AppDataFolder) + 'docker-compose.yml';
  InfoPfad := IncludeTrailingPathDelimiter(AppDataFolder) + 'ContainerUndVolumesInfo.txt';

  if not FileExists(ComposeYML) then
  begin
    ShowMessage('Fehler: docker-compose.yml wurde im gewählten Ordner nicht gefunden.');
    Exit;
  end;

  SL := TStringList.Create;
  ContainerZeilen := TStringList.Create;
  VolumeZeilen := TStringList.Create;
  try
    SL.Add('Container aus der ComputerRalle Paperless docker-compose.yml');
    SL.Add('Programm: ' + ExtractFileName(Application.ExeName) + ' – Version: ' + HoleDateiVersion(Application.ExeName));
    SL.Add('');

    CmdOutput := ExecuteShellCommand('docker', 'compose -f "' + ComposeYML + '" ps --format "{{.Name}}"');
    ContainerZeilen.Text := Trim(CmdOutput);
    SL.AddStrings(ContainerZeilen);

    SL.Add('');
    SL.Add('Volumes aus der ComputerRalle Paperless docker-compose.yml');

    CmdOutput := ExecuteShellCommand('docker', 'volume ls --format "{{.Name}}"');
    VolumeZeilen.Text := Trim(CmdOutput);

 		for i := 0 to VolumeZeilen.Count - 1 do
		begin
  		Zeile := Trim(VolumeZeilen[i]);
  		if Zeile.StartsWith('paperless-ngx_') then
    	SL.Add(Zeile);
		end;

    SL.SaveToFile(InfoPfad, TEncoding.UTF8);
  finally
    SL.Free;
    ContainerZeilen.Free;
    VolumeZeilen.Free;
  end;
end;

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

function TMainformFrm.HoleDateiVersion(const DateiPfad: string): string;
var
  InfoSize, Handle: DWORD;
  InfoData: Pointer;
  VerValue: Pointer;
  VerLen: UINT;
  Version: TVSFixedFileInfo;
begin
  Result := '';
  InfoSize := GetFileVersionInfoSize(PChar(DateiPfad), Handle);
  if InfoSize = 0 then Exit;

  GetMem(InfoData, InfoSize);
  try
    if GetFileVersionInfo(PChar(DateiPfad), 0, InfoSize, InfoData) then
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

procedure TMainformFrm.LeseContainerNamenAusDatei;
var
  DateiPfad: string;
  SL: TStringList;
  i: Integer;
  Zeile: string;
  InVolumeAbschnitt: Boolean;
begin
  DateiPfad := IncludeTrailingPathDelimiter(AppDataFolder) + 'ContainerUndVolumesInfo.txt';

  if not FileExists(DateiPfad) then
    Exit;

  SL := TStringList.Create;
  try
    SL.LoadFromFile(DateiPfad);
    InVolumeAbschnitt := False;

    for i := 0 to SL.Count - 1 do
    begin
      Zeile := Trim(SL[i]);

      if Zeile = '' then Continue;

      if Zeile.StartsWith('Volumes aus') then
      begin
        InVolumeAbschnitt := True;
        Continue;
      end;

      if not InVolumeAbschnitt then
      begin
        if Zeile.StartsWith('Container aus') then Continue;
        if Zeile.StartsWith('Programm:') then Continue;

        if Zeile.Contains('-db-') then
          PaperlessDBName := Zeile
        else if Zeile.Contains('-paperless-') then
          PaperlessCTName := Zeile
        else if Zeile.Contains('-broker-') then
          PaperlessBrokerName := Zeile
        else if Zeile.Contains('-tika-') then
          PaperlessTikaName := Zeile
        else if Zeile.Contains('-gotenberg-') then
          PaperlessGotenbergName := Zeile;
      end
      else
      begin
        if Zeile.Contains('_db_data') then
          Volume_db_data := Zeile
        else if Zeile.Contains('_data') then
          Volume_data := Zeile
        else if Zeile.Contains('_export') then
          Volume_export := Zeile
        else if Zeile.Contains('_media') then
          Volume_media := Zeile;
      end;
    end;
  finally
    SL.Free;
  end;
  TFile.WriteAllText(IncludeTrailingPathDelimiter(AppDataFolder) + 'BackupPfadeLog.txt', 'Beim Backup verwendete Variablen:' + sLineBreak + 'PaperlessDBName=' + PaperlessDBName + sLineBreak + 'PaperlessCTName=' + PaperlessCTName + sLineBreak + 'PaperlessBrokerName=' + PaperlessBrokerName + sLineBreak + 'PaperlessTikaName=' + PaperlessTikaName + sLineBreak + 'PaperlessGotenbergName=' + PaperlessGotenbergName + sLineBreak + 'Volume_data=' + Volume_data + sLineBreak + 'Volume_db_data=' + Volume_db_data + sLineBreak + 'Volume_export=' + Volume_export + sLineBreak + 'Volume_media=' + Volume_media, TEncoding.UTF8);
end;

// --------------------------------------------------------------
//Help Links / Website Links / Web
// --------------------------------------------------------------
procedure TMainformFrm.ImpressumLblClick(Sender: TObject);
begin
	ShellExecute(0, 'open', 'https://ralf-peter-kleinert.de/impressum.html', nil, nil, SW_SHOWNORMAL);
end;

procedure TMainformFrm.PaplerlessPlayListLblClick(Sender: TObject);
begin
  ShellExecute(0, 'open', 'https://www.youtube.com/playlist?list=PL0CRlqUkwGBm4wl1wYWen3L6jHIXhq3T7', nil, nil, SW_SHOWNORMAL);
end;

procedure TMainformFrm.MeinYouTubeKanalLblClick(Sender: TObject);
begin
 ShellExecute(0, 'open', 'https://www.youtube.com/@ralf-peter-kleinert', nil, nil, SW_SHOWNORMAL);
end;

procedure TMainformFrm.BackupProgrammAnleitungLblClick(Sender: TObject);
begin
 ShellExecute(0, 'open', 'https://ralf-peter-kleinert.de/linux-os/paperless-backup-programm.html', nil, nil, SW_SHOWNORMAL);
end;

procedure TMainformFrm.DigitalEasyLblClick(Sender: TObject);
begin
 ShellExecute(0, 'open', 'https://digital-easy.de', nil, nil, SW_SHOWNORMAL);
end;

procedure TMainformFrm.ComputerRalleLblClick(Sender: TObject);
begin
 ShellExecute(0, 'open', 'https://computerralle.de', nil, nil, SW_SHOWNORMAL);
end;

procedure TMainformFrm.NewsletterLblClick(Sender: TObject);
begin
  ShellExecute(0, 'open', 'https://dashboard.mailerlite.com/forms/1051644/128840345310988026/share', nil, nil, SW_SHOWNORMAL);
end;

procedure TMainformFrm.ProgramUpdateLblClick(Sender: TObject);
begin
  ShellExecute(0, 'open', 'https://downloads.ralf-peter-kleinert.de/software/paperless-backup-programm.html', nil, nil, SW_SHOWNORMAL);
end;

// Returns the version of the running executable as string
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

// Converts dotted version (x.x.x.x) into a fixed-width sortable string for correct version comparison
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
