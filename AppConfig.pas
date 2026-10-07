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

// Zentrale Namen, Standardversionen und Installationspfade. UTF-8-INI-Zugriffe und die reine Berechnung der 30-Tage-Erinnerung sind hier gebündelt.
unit AppConfig;

interface

uses System.IniFiles;

type
  // UTF-8 settings preserve Unicode installation paths; writes remain immediate.
  TAppSettingsIni = class(TMemIniFile)
  public
    constructor Create(const FileName: string);
    procedure WriteString(const Section, Ident, Value: string); override;
    procedure DeleteKey(const Section, Ident: string); override;
    procedure EraseSection(const Section: string); override;
  end;

const
  // Application names and folders.
  // Anwendungsnamen und Ordner.
  AppDisplayName = 'Paperless Backup Programm';
  AppStatusTitle = '#ComputerRalle - Paperless Backup Programm ';
  AppDataFolderName = 'Paperless Backup Programm PG18';
  ComposeProjectName = 'paperless-ngx-pg18';
  PaperlessInputFolderName = 'Paperless-Input-PG18';
  PaperlessBackupFolderName = 'Paperless-Backup-PG18';

  // Runtime file names.
  // Dateinamen zur Laufzeit.
  SettingsFileName = 'Einstellungen.ini';
  BackupTargetFileName = 'BackupZiel.txt';
  ComposePathFileName = 'DockerComposePfad.txt';
  InstallationCompletedFileName = 'InstallationAbgeschlossen.txt';
  NoticeAcceptedFileName = 'HinweisVerstanden.txt';
  DockerComposeFileName = 'docker-compose.yml';
  EmailEnvFileName = 'email-versand.env';
  EmailEnvEncryptedFileName = 'email-versand.env.enc';
  ContainerVolumeInfoFileName = 'ContainerUndVolumesInfo.txt';
  ImageVersionsFileName = 'image_versionen.txt';
  PaperlessSecretKeyFileName = 'paperless_secret_key.txt';
  UpdateIniFileName = 'update.ini';
  ApplicationLogFileName = 'PaperlessBackupProgram.log';

  // INI sections and keys.
  // INI-Abschnitte und Schlüssel.
  IniSectionVersions = 'Versionen';
  IniSectionSecurity = 'Sicherheit';
  IniKeyPaperlessVersion = 'Paperless-Version';
  IniKeyPostgresVersion = 'Postgres-Version';
  IniKeyRedisVersion = 'Valkey-Version';
  IniKeyGotenbergVersion = 'Gotenberg-Version';
  IniKeyTikaVersion = 'Tika-Version';
  IniKeyAlpineVersion = 'Alpine-Version';
  IniKeyBusyboxVersion = 'Busybox-Version';
  IniKeyPaperlessSecretKey = 'Paperless-Secret-Key';
  IniKeyLegacyPaperlessSecretKey = 'Legacy-Paperless-Secret-Key';

  // Default Docker image versions.
  // Standardversionen der Docker-Images.
  DefaultPaperlessVersion = '3.2.1';
  DefaultPostgresVersion = '18';
  DefaultRedisVersion = '9-alpine';
  // Follow the Gotenberg 8 release series instead of pinning a minor version.
  // Der Gotenberg-8-Versionsreihe folgen, statt eine Unterversion festzuschreiben.
  DefaultGotenbergVersion = '8';
  // Use Tika's latest tag; images are downloaded during the existing pull workflow.
  // Für Tika latest verwenden; Images werden im vorhandenen Pull-Ablauf geladen.
  DefaultTikaVersion = 'latest';
  DefaultAlpineVersion = '3';
  DefaultBusyboxVersion = '1';
  LegacyPaperlessSecretKey = 'aksjdfhs87H/(&986jlkhgiu87659zol';

  // External links.
  // Externe Links.
  UpdateInfoUrl = 'https://ralf-peter-kleinert.de/paperless-backup-programm-update/update.ini';
  DockerDesktopUrl = 'https://www.docker.com/products/docker-desktop/';
  PaperlessLocalUrl = 'http://localhost:8001';
  PaperlessLocalUrlWithSlash = 'http://localhost:8001/';
  PaperlessFallbackLocalUrl = PaperlessLocalUrl;
  ComputerRalleUrl = 'https://ralf-peter-kleinert.de';
  ComputerRalleSetupUrl = 'https://computerralle.de';
  BuyMeACoffeeUrl = 'https://buymeacoffee.com/computerralle';
  KeePassHelpVideoUrl = 'https://www.youtube.com/watch?v=j4DWjU9XucI';
  ImprintUrl = 'https://ralf-peter-kleinert.de/impressum.html';
  PaperlessPlaylistUrl = 'https://www.youtube.com/playlist?list=PL0CRlqUkwGBm4wl1wYWen3L6jHIXhq3T7';
  YouTubeChannelUrl = 'https://www.youtube.com/@ComputerRalle';
  // PDF manual opened by the main form's manual button.
  // PDF-Anleitung für den Anleitungsbutton im Hauptformular.
  ProgramManualUrl = 'https://ralf-peter-kleinert.de/paperless-backup-programm-anleitung/Anleitung-Paperless-Backup-Programm.pdf';
  BackupGuideUrl = 'https://ralf-peter-kleinert.de/paperless-backup-programm-anleitung/Anleitung-Paperless-Backup-Programm.pdf';
  BlogUrl = 'https://blog.ralf-peter-kleinert.de';
  NewsletterUrl = 'https://dashboard.mailerlite.com/forms/1051644/128840345310988026/share';
  ProgramDownloadUrl = 'https://downloads.ralf-peter-kleinert.de/software/paperless-backup-programm.html';

function InstallationFolderUnderParent(const ParentFolder: string): string;
function DefaultInstallationFolder: string;
function InstallationPathIniFile: string;
function LoadInstallationFolder: string;
procedure SaveInstallationFolder(const Folder: string);
function NoticeReminderDue(const InstallationDate, LastAccepted, Today: TDateTime): Boolean;

implementation

uses System.SysUtils, System.IOUtils, Winapi.Windows;

// Prüft feste Kalendertage ab Installation: Tag 30, 60, 90 usw. Uhrzeitanteile des Installationsdatums werden ignoriert.
// Eine Bestätigung innerhalb des aktuellen Intervalls verhindert Wiederholungen. Versäumte Intervalle ergeben einen Hinweis; der nächste Termin bleibt fest.
// Ohne Installationsdatum oder vor Tag 30 ist nichts fällig. Diese Funktion liest und schreibt keine Dateien.
function NoticeReminderDue(const InstallationDate, LastAccepted, Today: TDateTime): Boolean;
var
  ElapsedDays, CurrentPeriod: Integer;
  PeriodStart: TDateTime;
begin
  Result := False;
  if InstallationDate <= 0 then Exit;
  ElapsedDays := Trunc(Today) - Trunc(InstallationDate);
  if ElapsedDays < 30 then Exit;
  CurrentPeriod := ElapsedDays div 30;
  PeriodStart := Trunc(InstallationDate) + CurrentPeriod * 30;
  Result := LastAccepted < PeriodStart;
end;

// Liest vorhandene UTF-8-Dateien strikt; für ältere Dateien bleibt BOM-/ANSI-Erkennung als Rückfall erhalten.
// Weitere Schreibzugriffe verwenden UTF-8. Der Konstruktor legt den Laufzeitordner nicht selbst an.
constructor TAppSettingsIni.Create(const FileName: string);
var
  Bytes: TBytes;
  InputEncoding: TEncoding;
begin
  InputEncoding := TEncoding.UTF8;
  if FileExists(FileName) then
  begin
    Bytes := TFile.ReadAllBytes(FileName);
    if (Length(Bytes) > 0) and
       (MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS,
         PAnsiChar(@Bytes[0]), Length(Bytes), nil, 0) = 0) then
      InputEncoding := nil; // Detect an existing BOM or use the legacy ANSI codepage.
  end;
  inherited Create(FileName, InputEncoding);
  Encoding := TEncoding.UTF8;
end;

// Schreibt den INI-Wert und speichert sofort, damit Einstellungen auch vor einem späteren Programmabbruch erhalten bleiben.
procedure TAppSettingsIni.WriteString(const Section, Ident, Value: string);
begin
  inherited;
  UpdateFile;
end;

// Entfernt einen einzelnen INI-Schlüssel und speichert die Änderung sofort als UTF-8.
procedure TAppSettingsIni.DeleteKey(const Section, Ident: string);
begin
  inherited;
  UpdateFile;
end;

// Entfernt den angeforderten INI-Abschnitt und speichert die Änderung sofort als UTF-8.
procedure TAppSettingsIni.EraseSection(const Section: string);
begin
  inherited;
  UpdateFile;
end;

// Bildet aus dem gewählten übergeordneten Pfad stets den festen PG18-Unterordner. Erstellt keine Verzeichnisse.
function InstallationFolderUnderParent(const ParentFolder: string): string;
begin
  Result := IncludeTrailingPathDelimiter(ExpandFileName(ParentFolder)) + AppDataFolderName;
end;

// Liefert den PG18-Laufzeitordner unter USERPROFILE, solange kein anderer Installationspfad gespeichert ist.
function DefaultInstallationFolder: string;
begin
  Result := InstallationFolderUnderParent(GetEnvironmentVariable('USERPROFILE'));
end;

// Liefert die benutzerbezogene Pfadregistrierung unter LOCALAPPDATA, unabhängig vom gewählten Laufzeitordner.
function InstallationPathIniFile: string;
begin
  Result := IncludeTrailingPathDelimiter(GetEnvironmentVariable('LOCALAPPDATA')) +
    AppDataFolderName + '\Installationspfad.ini';
end;

// Lädt den gespeicherten absoluten Windows-/UNC-Pfad; ohne Registrierung gilt der Standardordner.
// Ungültige gespeicherte Pfade lösen eine Exception aus. Ein fehlender Zielordner wird hier nicht angelegt.
function LoadInstallationFolder: string;
var
  Ini: TMemIniFile;
  Folder: string;
begin
  Result := DefaultInstallationFolder;
  if not FileExists(InstallationPathIniFile) then Exit;
  Ini := TMemIniFile.Create(InstallationPathIniFile, TEncoding.UTF8);
  try
    Folder := Ini.ReadString('Pfade', 'Installationspfad', '').Trim;
    if (Folder = '') or not TPath.IsPathRooted(Folder) or
       not ((Copy(Folder, 2, 2) = ':\') or (Copy(Folder, 1, 2) = '\\')) then
      raise Exception.Create('Der gespeicherte Installationspfad ist ungültig.');
    Result := ExcludeTrailingPathDelimiter(Folder);
  finally
    Ini.Free;
  end;
end;

// Speichert den ausgewählten Laufzeitpfad als UTF-8 in der separaten Pfadregistrierung.
// Erstellt nur deren übergeordnetes Verzeichnis; vorhandene Installationen werden nicht verschoben.
procedure SaveInstallationFolder(const Folder: string);
var
  Ini: TMemIniFile;
begin
  if not ForceDirectories(ExtractFilePath(InstallationPathIniFile)) then
    raise Exception.Create('Der Installationspfad kann nicht gespeichert werden.');
  Ini := TMemIniFile.Create(InstallationPathIniFile, TEncoding.UTF8);
  try
    Ini.WriteString('Pfade', 'Installationspfad', Folder);
    Ini.UpdateFile;
  finally
    Ini.Free;
  end;
end;

end.
