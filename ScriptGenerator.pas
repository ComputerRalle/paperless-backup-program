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

unit ScriptGenerator;

interface

type
  // Docker volume names used by the backup and restore scripts.
  // Docker-Volume-Namen, die von den Backup- und Wiederherstellungsskripten verwendet werden.
  TDockerVolumeNames = record
    Data: string;
    DbData: string;
    ExportData: string;
    Media: string;
  end;

procedure CreateManualBackupCmdScript(
  const TargetPath, ComposePath, BackupPath, AppDataFolder, DatabaseContainerName: string;
  const Volumes: TDockerVolumeNames);

procedure CreatePlannedBackupCmdScript(
  const TargetPath, ComposePath, BackupBasePath, AppDataFolder, DatabaseContainerName: string;
  const Volumes: TDockerVolumeNames);

procedure CreateRestoreCmdScript(
  const TargetPath, ComposePath, BackupFolder, DatabaseContainerName: string;
  const Volumes: TDockerVolumeNames);

procedure CreateRestartCmdScript(const TargetPath, ComposePath: string);
procedure CreateDeleteBackupScheduleCmdScript(const TargetPath: string);
procedure CreateBackupScheduleCmdScript(
  const TargetPath, ProgramPath, Weekdays, Hour, Minute: string);

implementation

uses
  System.Classes, System.SysUtils;

function PsQuote(const Value: string): string;
begin
  Result := '''' + StringReplace(Value, '''', '''''', [rfReplaceAll]) + '''';
end;

procedure AddPsHeader(const Lines: TStringList);
begin
  Lines.Add('$ErrorActionPreference = ''Stop''');
  Lines.Add('');
  Lines.Add('function Invoke-DockerStep {');
  Lines.Add('  param([scriptblock]$Command, [string]$ErrorMessage)');
  Lines.Add('  & $Command');
  Lines.Add('  if ($LASTEXITCODE -ne 0) { throw "$ErrorMessage (ExitCode $LASTEXITCODE)" }');
  Lines.Add('}');
  Lines.Add('');
  Lines.Add('function Wait-Countdown {');
  Lines.Add('  param([int]$Seconds)');
  Lines.Add('  for ($i = $Seconds; $i -ge 1; $i--) { Write-Host $i; Start-Sleep -Seconds 1 }');
  Lines.Add('}');
  Lines.Add('');
end;

procedure AddPsFooter(const Lines: TStringList);
begin
  Lines.Add('');
  Lines.Add('} catch {');
  Lines.Add('  Write-Host ""');
  Lines.Add('  Write-Host $_.Exception.Message -ForegroundColor Red');
  Lines.Add('  Read-Host "Fehler. Zum Schliessen ENTER druecken"');
  Lines.Add('  exit 1');
  Lines.Add('}');
  Lines.Add('');
  Lines.Add('exit 0');
end;

procedure SavePsScript(const Lines: TStringList; const TargetPath: string);
begin
  Lines.SaveToFile(TargetPath, TEncoding.UTF8);
end;

procedure AddVolumeBackup(const Lines: TStringList; const VolumeName, DisplayName: string);
begin
  Lines.Add(Format('  Write-Host "Backup: %s"', [DisplayName]));
  Lines.Add('  Write-Host "Bitte warten, Backup kann sehr lange dauern."');
  Lines.Add(Format('  Invoke-DockerStep { docker run --rm -v "%s:/data" -v "$BackupDir`:/backup" alpine tar czvf "/backup/%s.tar.gz" -C /data . } "Fehler beim Sichern von %s"', [VolumeName, VolumeName, DisplayName]));
  Lines.Add('');
end;

procedure AddVolumeRestore(const Lines: TStringList; const VolumeName, DisplayName: string);
begin
  Lines.Add(Format('  Write-Host "Wiederherstellen Volume: %s."', [DisplayName]));
  Lines.Add('  Write-Host "Bitte warten, Wiederherstellung kann sehr lange dauern."');
  Lines.Add(Format('  $Archive = Join-Path $BackupDir %s', [PsQuote(VolumeName + '.tar.gz')]));
  Lines.Add('  if (-not (Test-Path -LiteralPath $Archive)) { throw "Fehler: Archiv fehlt: $Archive" }');
  Lines.Add(Format('  Invoke-DockerStep { docker run --rm -v "%s:/data" -v "$BackupDir`:/backup" alpine sh -c "rm -rf /data/* && tar xzvf /backup/%s.tar.gz -C /data" } "Fehler beim Wiederherstellen von %s"', [VolumeName, VolumeName, DisplayName]));
  Lines.Add('');
end;

procedure CreateManualBackupCmdScript(
  const TargetPath, ComposePath, BackupPath, AppDataFolder, DatabaseContainerName: string;
  const Volumes: TDockerVolumeNames);
var
  Lines: TStringList;
begin
  Lines := TStringList.Create;
  try
    AddPsHeader(Lines);
    Lines.Add('try {');
    Lines.Add('  Write-Host "PowerShell Backup-Skript wird gestartet... Bitte warten"');
    Lines.Add(Format('  $ComposeDir = %s', [PsQuote(ExtractFilePath(ComposePath))]));
    Lines.Add(Format('  $BackupDir = %s', [PsQuote(BackupPath)]));
    Lines.Add(Format('  $DatabaseContainer = %s', [PsQuote(DatabaseContainerName)]));
    Lines.Add(Format('  $BackupLog = %s', [PsQuote(IncludeTrailingPathDelimiter(AppDataFolder) + 'Backup.log')]));
    Lines.Add('  Set-Location -LiteralPath $ComposeDir');
    Lines.Add('  if (-not (Test-Path -LiteralPath $BackupDir)) { New-Item -ItemType Directory -Path $BackupDir | Out-Null }');
    Lines.Add('  $DumpFile = Join-Path $BackupDir ($DatabaseContainer + "_backup.sql")');
    Lines.Add('  Write-Host "PostgreSQL-Dump wird erstellt..."');
    Lines.Add('  docker exec $DatabaseContainer pg_dump -U paperless paperless | Out-File -FilePath $DumpFile -Encoding utf8');
    Lines.Add('  if ($LASTEXITCODE -ne 0) { throw "Fehler beim PostgreSQL-Dump. Abbruch. (ExitCode $LASTEXITCODE)" }');
    Lines.Add('  Write-Host "Stoppe Docker-Container..."');
    Lines.Add('  Invoke-DockerStep { docker compose down } "Fehler beim Stoppen der Container. Abbruch."');
    Lines.Add('');
    AddVolumeBackup(Lines, Volumes.Data, 'data');
    AddVolumeBackup(Lines, Volumes.DbData, 'db_data');
    AddVolumeBackup(Lines, Volumes.ExportData, 'export');
    AddVolumeBackup(Lines, Volumes.Media, 'media');
    Lines.Add('  Write-Host "Starte Docker-Container neu..."');
    Lines.Add('  Invoke-DockerStep { docker compose up -d } "Fehler beim Starten der Container. Manuell pruefen."');
    Lines.Add('  Write-Host "Nicht mehr verwendete Volumes werden geloescht"');
    Lines.Add('  Wait-Countdown 3');
    Lines.Add('  Invoke-DockerStep { docker volume prune -f } "Fehler beim Bereinigen nicht verwendeter Volumes."');
    Lines.Add('  Wait-Countdown 3');
    Lines.Add('  Write-Host "-----------------------------------------"');
    Lines.Add('  Write-Host "Backup abgeschlossen: $(Get-Date)"');
    Lines.Add('  Write-Host "Dateien gespeichert in: $BackupDir"');
    Lines.Add('  Add-Content -LiteralPath $BackupLog -Value ("Backup abgeschlossen: " + (Get-Date))');
    Lines.Add('  Add-Content -LiteralPath $BackupLog -Value ("Backup-Ziel: " + $BackupDir)');
    Lines.Add('  Write-Host "Systeme starten. Fenster wird gleich geschlossen ..."');
    Lines.Add('  Wait-Countdown 10');
    AddPsFooter(Lines);
    SavePsScript(Lines, TargetPath);
  finally
    Lines.Free;
  end;
end;

procedure CreatePlannedBackupCmdScript(
  const TargetPath, ComposePath, BackupBasePath, AppDataFolder, DatabaseContainerName: string;
  const Volumes: TDockerVolumeNames);
var
  Lines: TStringList;
begin
  Lines := TStringList.Create;
  try
    AddPsHeader(Lines);
    Lines.Add('try {');
    Lines.Add(Format('  $ComposeDir = %s', [PsQuote(ExtractFilePath(ComposePath))]));
    Lines.Add(Format('  $BackupBase = %s', [PsQuote(BackupBasePath)]));
    Lines.Add(Format('  $DatabaseContainer = %s', [PsQuote(DatabaseContainerName)]));
    Lines.Add(Format('  $PlannedLog = %s', [PsQuote(IncludeTrailingPathDelimiter(AppDataFolder) + 'GeplanterBackup.log')]));
    Lines.Add('  $BackupDir = Join-Path $BackupBase (Get-Date -Format "yyyy-MM-dd_HH-mm-ss")');
    Lines.Add('  Set-Location -LiteralPath $ComposeDir');
    Lines.Add('  if (-not (Test-Path -LiteralPath $BackupDir)) { New-Item -ItemType Directory -Path $BackupDir | Out-Null }');
    Lines.Add('  Invoke-DockerStep { docker exec -i paperless-ngx-paperless-1 python3 manage.py migrate contenttypes } "Fehler bei Django ContentType-Migration."');
    Lines.Add('  $DumpFile = Join-Path $BackupDir ($DatabaseContainer + "_backup.sql")');
    Lines.Add('  docker exec $DatabaseContainer pg_dump -U paperless paperless | Out-File -FilePath $DumpFile -Encoding utf8');
    Lines.Add('  if ($LASTEXITCODE -ne 0) { throw "Fehler beim PostgreSQL-Dump. Abbruch. (ExitCode $LASTEXITCODE)" }');
    Lines.Add('  Invoke-DockerStep { docker compose down } "Fehler beim Stoppen der Container."');
    AddVolumeBackup(Lines, Volumes.Data, 'data');
    AddVolumeBackup(Lines, Volumes.Media, 'media');
    AddVolumeBackup(Lines, Volumes.ExportData, 'export');
    Lines.Add('  Invoke-DockerStep { docker compose up -d } "Fehler beim Starten der Container."');
    Lines.Add('  Invoke-DockerStep { docker volume prune -f } "Fehler beim Bereinigen nicht verwendeter Volumes."');
    Lines.Add('  Add-Content -LiteralPath $PlannedLog -Value ("Backup abgeschlossen: " + (Get-Date))');
    Lines.Add('  Add-Content -LiteralPath $PlannedLog -Value ("Backup-Ziel: " + $BackupDir)');
    AddPsFooter(Lines);
    SavePsScript(Lines, TargetPath);
  finally
    Lines.Free;
  end;
end;

procedure CreateRestoreCmdScript(
  const TargetPath, ComposePath, BackupFolder, DatabaseContainerName: string;
  const Volumes: TDockerVolumeNames);
var
  Lines: TStringList;
begin
  Lines := TStringList.Create;
  try
    AddPsHeader(Lines);
    Lines.Add('try {');
    Lines.Add(Format('  $ComposeDir = %s', [PsQuote(ExtractFilePath(ComposePath))]));
    Lines.Add(Format('  $BackupDir = %s', [PsQuote(BackupFolder)]));
    Lines.Add(Format('  $DatabaseContainer = %s', [PsQuote(DatabaseContainerName)]));
    Lines.Add('  Set-Location -LiteralPath $ComposeDir');
    Lines.Add('  Write-Host "Stoppe Container..."');
    Lines.Add('  Invoke-DockerStep { docker compose down } "Fehler beim Stoppen der Container."');
    AddVolumeRestore(Lines, Volumes.Data, 'data');
    AddVolumeRestore(Lines, Volumes.Media, 'media');
    AddVolumeRestore(Lines, Volumes.ExportData, 'export');
    Lines.Add('  Write-Host "Starte Container..."');
    Lines.Add('  Invoke-DockerStep { docker compose up -d } "Fehler beim Starten der Container."');
    Lines.Add('  Write-Host "Wiederherstellen der PostgreSQL-Datenbank. Bitte haben Sie Geduld..."');
    Lines.Add('  Start-Sleep -Seconds 3');
    Lines.Add('  Invoke-DockerStep { docker exec -i paperless-ngx-paperless-1 python3 manage.py migrate contenttypes } "Fehler bei Django ContentType-Migration."');
    Lines.Add('  Start-Sleep -Seconds 3');
    Lines.Add('  Write-Host "Wiederherstellen der PostgreSQL-Datenbank (Datenbank wird gestartet) ..."');
    Lines.Add('  Wait-Countdown 15');
    Lines.Add('  Invoke-DockerStep { docker exec -i $DatabaseContainer psql -U paperless paperless -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;" } "Fehler beim Zuruecksetzen des public Schemas."');
    Lines.Add('  $DumpFile = Join-Path $BackupDir ($DatabaseContainer + "_backup.sql")');
    Lines.Add('  if (-not (Test-Path -LiteralPath $DumpFile)) { throw "Fehler: Datenbank-Dump fehlt: $DumpFile" }');
    Lines.Add('  Get-Content -LiteralPath $DumpFile | docker exec -i $DatabaseContainer psql -U paperless paperless');
    Lines.Add('  if ($LASTEXITCODE -ne 0) { throw "Fehler beim Wiederherstellen der PostgreSQL-Datenbank. (ExitCode $LASTEXITCODE)" }');
    Lines.Add('  Write-Host "Nicht mehr verwendete Volumes werden geloescht"');
    Lines.Add('  Wait-Countdown 3');
    Lines.Add('  Invoke-DockerStep { docker volume prune -f } "Fehler beim Bereinigen nicht verwendeter Volumes."');
    Lines.Add('  Wait-Countdown 3');
    Lines.Add('  Write-Host "-----------------------------------------"');
    Lines.Add('  Write-Host "Wiederherstellung abgeschlossen: $(Get-Date)"');
    Lines.Add('  Write-Host "Dateien aus: $BackupDir"');
    Lines.Add('  Write-Host "Bitte geben Sie Paperless Zeit, seine Dienste zu starten. Das kann Minuten dauern."');
    Lines.Add('  Write-Host "-----------------------------------------"');
    Lines.Add('  Write-Host "Systeme starten. Fenster wird gleich geschlossen ..."');
    Lines.Add('  Wait-Countdown 10');
    AddPsFooter(Lines);
    SavePsScript(Lines, TargetPath);
  finally
    Lines.Free;
  end;
end;

procedure CreateRestartCmdScript(const TargetPath, ComposePath: string);
var
  Lines: TStringList;
begin
  Lines := TStringList.Create;
  try
    AddPsHeader(Lines);
    Lines.Add('try {');
    Lines.Add(Format('  $ComposeDir = %s', [PsQuote(ExtractFilePath(ComposePath))]));
    Lines.Add('  Set-Location -LiteralPath $ComposeDir');
    Lines.Add('  Write-Host "Bitte warten, Paperless wird heruntergefahren."');
    Lines.Add('  Wait-Countdown 3');
    Lines.Add('  Invoke-DockerStep { docker compose down } "Fehler beim Stoppen der Container."');
    Lines.Add('  Write-Host "Bitte warten, Paperless wird neu gestartet."');
    Lines.Add('  Wait-Countdown 3');
    Lines.Add('  Invoke-DockerStep { docker compose up -d } "Fehler beim Starten der Container."');
    Lines.Add('  Write-Host "Nicht mehr verwendete Volumes werden geloescht"');
    Lines.Add('  Wait-Countdown 3');
    Lines.Add('  Invoke-DockerStep { docker volume prune -f } "Fehler beim Bereinigen nicht verwendeter Volumes."');
    Lines.Add('  Wait-Countdown 3');
    Lines.Add('  Start-Sleep -Seconds 3');
    Lines.Add('  Invoke-DockerStep { docker exec -i paperless-ngx-paperless-1 python3 manage.py migrate contenttypes } "Fehler bei Django ContentType-Migration."');
    Lines.Add('  Start-Sleep -Seconds 3');
    AddPsFooter(Lines);
    SavePsScript(Lines, TargetPath);
  finally
    Lines.Free;
  end;
end;

procedure CreateDeleteBackupScheduleCmdScript(const TargetPath: string);
var
  Lines: TStringList;
begin
  Lines := TStringList.Create;
  try
    AddPsHeader(Lines);
    Lines.Add('try {');
    Lines.Add('  Write-Host "Backup-Aufgabe wird aus der Aufgabenplanung entfernt"');
    Lines.Add('  Invoke-DockerStep { schtasks /delete /tn "PaperlessBackup" /f } "Fehler beim Entfernen der Backup-Aufgabe."');
    Lines.Add('  Write-Host "Fertig"');
    AddPsFooter(Lines);
    SavePsScript(Lines, TargetPath);
  finally
    Lines.Free;
  end;
end;

procedure CreateBackupScheduleCmdScript(
  const TargetPath, ProgramPath, Weekdays, Hour, Minute: string);
var
  Lines: TStringList;
begin
  Lines := TStringList.Create;
  try
    AddPsHeader(Lines);
    Lines.Add('try {');
    Lines.Add('  Write-Host "=== Backup-Aufgabe wird in die Aufgabenplanung eingetragen ==="');
    Lines.Add(Format('  $TaskCommand = ''"%s" /geplant''', [StringReplace(ProgramPath, '''', '''''', [rfReplaceAll])]));
    Lines.Add(Format('  Invoke-DockerStep { schtasks /create /tn "PaperlessBackup" /tr $TaskCommand /sc weekly /d %s /st %s:%s /f } "Fehler beim Eintragen der Backup-Aufgabe."', [Weekdays, Hour, Minute]));
    Lines.Add('  Write-Host "=== Fertig ==="');
    AddPsFooter(Lines);
    SavePsScript(Lines, TargetPath);
  finally
    Lines.Free;
  end;
end;

end.
