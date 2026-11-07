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

// Erzeugt PowerShell-Skripte für Backup, Restore, Neustart und Aufgabenplanung. Die Cmd-Namen sind historisch; alle erzeugten Dateien sind PS1 für powershell.exe.
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
  const Volumes: TDockerVolumeNames; MaxBackupFolders: Integer);

procedure CreateRestoreCmdScript(
  const TargetPath, ComposePath, BackupFolder, DatabaseContainerName: string;
  const Volumes: TDockerVolumeNames; const UseLegacyBackupNames: Boolean = False);

procedure CreateRestartCmdScript(const TargetPath, ComposePath: string);
procedure CreateDeleteBackupScheduleCmdScript(const TargetPath: string);
procedure CreateBackupScheduleCmdScript(
  const TargetPath, BackupScriptPath, Weekdays, Hour, Minute: string);

implementation

uses
  System.Classes, System.SysUtils, Winapi.Windows, AppConfig;

// Einen Wert sicher als einfach gequotete PowerShell-Zeichenkette schreiben.
function PsQuote(const Value: string): string;
begin
  Result := '''' + StringReplace(Value, '''', '''''', [rfReplaceAll]) + '''';
end;

// Erzeugt gemeinsame PS-Helfer: terminierende PowerShell-Fehler und ausdrückliche Prüfung nativer Docker-Exitcodes.
// ErrorActionPreference allein erkennt einen fehlgeschlagenen Docker-Prozess nicht zuverlässig.
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

// Den gemeinsamen PowerShell-catch-Block und den Erfolgs-Exitcode hinzufügen.
procedure AddPsFooter(const Lines: TStringList);
begin
  Lines.Add('');
  Lines.Add('} catch {');
  Lines.Add('  Write-Host ""');
  Lines.Add('  Write-Host (''PAPERLESS_FEHLER: '' + $_.Exception.Message) -ForegroundColor Red');
  Lines.Add('  exit 1');
  Lines.Add('}');
  Lines.Add('');
  Lines.Add('exit 0');
end;

// Save PS1 as UTF-8 with BOM and mark them hidden.
// PS1 als UTF-8 mit BOM speichern und verstecken.
// Clear Hidden/ReadOnly on existing targets before replacement.
// Bei vorhandenen Zielen vor dem Ersetzen Hidden/ReadOnly entfernen.
procedure SavePsScript(const Lines: TStringList; const TargetPath: string);
var
  // Preserve all other Windows attributes when changing hidden/read-only flags.
  // Alle anderen Windows-Attribute beim Ändern von Hidden/ReadOnly erhalten.
  Attributes: DWORD;
begin
  if FileExists(TargetPath) then
  begin
    Attributes := Winapi.Windows.GetFileAttributes(PChar(TargetPath));
    if Attributes <> INVALID_FILE_ATTRIBUTES then
      Winapi.Windows.SetFileAttributes(PChar(TargetPath), Attributes and not FILE_ATTRIBUTE_HIDDEN and not FILE_ATTRIBUTE_READONLY);
    System.SysUtils.DeleteFile(TargetPath);
  end;
  Lines.SaveToFile(TargetPath, TEncoding.UTF8);
  Attributes := Winapi.Windows.GetFileAttributes(PChar(TargetPath));
  if Attributes <> INVALID_FILE_ATTRIBUTES then
    Winapi.Windows.SetFileAttributes(PChar(TargetPath), Attributes or FILE_ATTRIBUTE_HIDDEN);
end;

// Befehle hinzufügen, die ein Docker-Volume in den Backup-Ordner archivieren.
procedure AddVolumeBackup(const Lines: TStringList; const VolumeName, DisplayName: string);
begin
  Lines.Add(Format('  Write-Host "Backup: %s"', [DisplayName]));
  Lines.Add('  Write-Host "Bitte warten, Backup kann sehr lange dauern."');
  Lines.Add(Format('  Invoke-DockerStep { docker run --rm -v "%s:/data" -v "$BackupDir`:/backup" alpine tar czvf "/backup/%s.tar.gz" -C /data . } "Fehler beim Sichern von %s"', [VolumeName, VolumeName, DisplayName]));
  Lines.Add('');
end;

// Trennt PG18-Zielvolume und Archivnamen, damit alte Backups ohne Umbenennen der Quelldateien eingespielt werden.
// Das erzeugte rm -rf /data/* entfernt keine Dotfiles; dieser bestehende Ablauf wird hier nicht geändert.
procedure AddVolumeRestore(const Lines: TStringList; const VolumeName, DisplayName, ArchiveVolumeName: string);
begin
  Lines.Add(Format('  Write-Host "Wiederherstellen Volume: %s."', [DisplayName]));
  Lines.Add('  Write-Host "Bitte warten, Wiederherstellung kann sehr lange dauern."');
  Lines.Add(Format('  $Archive = Join-Path $BackupDir %s', [PsQuote(ArchiveVolumeName + '.tar.gz')]));
  Lines.Add('  if (-not (Test-Path -LiteralPath $Archive)) { throw "Fehler: Archiv fehlt: $Archive" }');
  Lines.Add(Format('  Invoke-DockerStep { docker run --rm -v "%s:/data" -v "$BackupDir`:/backup" alpine sh -c "rm -rf /data/* && tar xzvf /backup/%s.tar.gz -C /data" } "Fehler beim Wiederherstellen von %s"', [VolumeName, ArchiveVolumeName, DisplayName]));
  Lines.Add('');
end;

// Einen Best-Effort-Kopierschritt für die verschluesselte E-Mail-Einstellungsdatei hinzufügen.
procedure AddEncryptedEmailEnvBackup(const Lines: TStringList);
begin
  Lines.Add('  $EncryptedEmailEnvFile = Join-Path $ComposeDir "email-versand.env.enc"');
  Lines.Add('  if (Test-Path -LiteralPath $EncryptedEmailEnvFile) {');
  Lines.Add('    Copy-Item -LiteralPath $EncryptedEmailEnvFile -Destination (Join-Path $BackupDir "email-versand.env.enc") -Force');
  Lines.Add('    Write-Host "Verschluesselte email-versand.env wurde ins Backup kopiert."');
  Lines.Add('  } else {');
  Lines.Add('    Write-Host "Hinweis: Verschluesselte email-versand.env nicht vorhanden. Schritt wird uebersprungen."');
  Lines.Add('  }');
  Lines.Add('');
end;

// Einen nicht-fatalen Django-Migrationsschritt hinzufügen, damit Skripte weiterlaufen, wenn Paperless noch nicht bereit ist.
procedure AddBestEffortDjangoMigration(const Lines: TStringList);
begin
  Lines.Add('  Write-Host "Aktualisiere Django-Datenbankstruktur..."');
  Lines.Add('  docker compose exec -T paperless python3 manage.py migrate');
  Lines.Add('  if ($LASTEXITCODE -ne 0) {');
  Lines.Add('    Write-Host "Hinweis: Django-Datenbankmigration konnte jetzt nicht abgeschlossen werden. Das Skript laeuft weiter." -ForegroundColor Yellow');
  Lines.Add('    $global:LASTEXITCODE = 0');
  Lines.Add('  }');
end;

// Erzeugt docker image prune -f für unreferenzierte Images. Die Bereinigung gilt engineweit, nicht nur für dieses Compose-Projekt.
procedure AddDanglingImagePrune(const Lines: TStringList);
begin
  Lines.Add('  Write-Host "Nicht mehr verwendete Docker-Images werden geloescht"');
  Lines.Add('  Wait-Countdown 3');
  Lines.Add('  Invoke-DockerStep { docker image prune -f } "Fehler beim Bereinigen nicht verwendeter Docker-Images."');
  Lines.Add('');
end;

// Keep the UTF-8 dump bytes outside the PowerShell text pipeline.
// UTF-8-Dumpbytes außerhalb der PowerShell-Textpipeline unverändert kopieren.
procedure AddUtf8DatabaseDump(const Lines: TStringList);
begin
  // Use a unique container-local file outside the database volume.
  // Eindeutige temporäre Datei im Container außerhalb des Datenbankvolumes verwenden.
  Lines.Add('  $ContainerDumpFile = "/tmp/paperless-backup-" + [Guid]::NewGuid().ToString("N") + ".sql"');
  Lines.Add('  try {');
  // pg_dump writes UTF-8 directly; docker cp preserves bytes without an Out-File BOM.
  // pg_dump schreibt UTF-8 direkt; docker cp erhält die Bytes ohne Out-File-BOM.
  Lines.Add('    Invoke-DockerStep { docker exec $DatabaseContainer pg_dump -U paperless --encoding=UTF8 -f $ContainerDumpFile paperless } "Fehler beim Erstellen des UTF-8-PostgreSQL-Dumps im Container."');
  Lines.Add('    Invoke-DockerStep { docker cp ("${DatabaseContainer}:" + $ContainerDumpFile) $DumpFile } "Fehler beim Kopieren des PostgreSQL-Dumps in den Backupordner."');
  // Always attempt cleanup; a cleanup warning must not hide the original dump/copy error.
  // Aufräumen immer versuchen; eine Warnung darf den ursprünglichen Dump-/Kopierfehler nicht verdecken.
  Lines.Add('  } finally {');
  Lines.Add('    docker exec $DatabaseContainer rm -f $ContainerDumpFile');
  Lines.Add('    if ($LASTEXITCODE -ne 0) { Write-Warning "Temporäre SQL-Datei im Container konnte nicht entfernt werden (ExitCode $LASTEXITCODE): $ContainerDumpFile" }');
  Lines.Add('  }');
end;

// Save the key configured in the running Paperless container.
// Den Schlüssel aus dem laufenden Paperless-Container sichern.
procedure AddActivePaperlessSecretKeyBackup(const Lines: TStringList);
begin
  Lines.Add('  try {');
  Lines.Add('    $PaperlessContainer = @(docker compose ps -q paperless)');
  Lines.Add('    if ($LASTEXITCODE -ne 0 -or $PaperlessContainer.Count -ne 1 -or [string]::IsNullOrWhiteSpace($PaperlessContainer[0])) { throw "Paperless-Container nicht gefunden." }');
  Lines.Add('    $KeyLines = @(docker inspect --format ''{{range .Config.Env}}{{println .}}{{end}}'' $PaperlessContainer[0] | Where-Object { $_.StartsWith("PAPERLESS_SECRET_KEY=") })');
  Lines.Add('    if ($LASTEXITCODE -ne 0 -or $KeyLines.Count -ne 1 -or $KeyLines[0].Length -le "PAPERLESS_SECRET_KEY=".Length) { throw "Secret Key nicht gefunden." }');
  Lines.Add('    [IO.File]::WriteAllText((Join-Path $BackupDir ''paperless_secret_key.txt''), ($KeyLines[0] + [Environment]::NewLine), (New-Object System.Text.UTF8Encoding($true)))');
  Lines.Add('  } catch { Write-Warning "Secret Key konnte nicht gesichert werden. Das Backup wird fortgesetzt." }');
end;

// Erzeugt SQL-Dump vor compose down, danach Archive einschließlich DB-Volume und den anschließenden Neustart.
// Imageversions-Metadaten ergänzt die Delphi-Erfolgsauswertung. Bei Abbruch nach down ist kein garantierter Neustart vorgesehen.
procedure CreateManualBackupCmdScript(
  const TargetPath, ComposePath, BackupPath, AppDataFolder, DatabaseContainerName: string;
  const Volumes: TDockerVolumeNames);
var
  Lines: TStringList;
begin
  Lines := TStringList.Create;
  try
    // Decode native console output as UTF-8 in Windows PowerShell 5.1.
    // Native Konsolenausgaben in Windows PowerShell 5.1 als UTF-8 lesen.
    Lines.Add('[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false)');
    AddPsHeader(Lines);
    Lines.Add('try {');
    Lines.Add('  Write-Host "PowerShell Backup-Skript wird gestartet... Bitte warten"');
    Lines.Add(Format('  $ComposeDir = %s', [PsQuote(ExtractFilePath(ComposePath))]));
    Lines.Add(Format('  $BackupDir = %s', [PsQuote(BackupPath)]));
    Lines.Add(Format('  $DatabaseContainer = %s', [PsQuote(DatabaseContainerName)]));
    Lines.Add(Format('  $BackupLog = %s', [PsQuote(IncludeTrailingPathDelimiter(AppDataFolder) + 'Backup.log')]));
    Lines.Add('  Set-Location -LiteralPath $ComposeDir');
    Lines.Add('  if (-not (Test-Path -LiteralPath $BackupDir)) { New-Item -ItemType Directory -Path $BackupDir | Out-Null }');
    AddActivePaperlessSecretKeyBackup(Lines);
    Lines.Add('  $DumpFile = Join-Path $BackupDir ($DatabaseContainer + "_backup.sql")');
    Lines.Add('  Write-Host "PostgreSQL-Dump wird erstellt..."');
    AddUtf8DatabaseDump(Lines);
    Lines.Add('  Write-Host "Stoppe Docker-Container..."');
    Lines.Add('  Invoke-DockerStep { docker compose down } "Fehler beim Stoppen der Container. Abbruch."');
    Lines.Add('');
    AddVolumeBackup(Lines, Volumes.Data, 'data');
    AddVolumeBackup(Lines, Volumes.DbData, 'db_data');
    AddVolumeBackup(Lines, Volumes.ExportData, 'export');
    AddVolumeBackup(Lines, Volumes.Media, 'media');
    AddEncryptedEmailEnvBackup(Lines);
    Lines.Add('  Write-Host "Starte Docker-Container neu..."');
    Lines.Add('  Invoke-DockerStep { docker compose up -d } "Fehler beim Starten der Container. Manuell pruefen."');
    Lines.Add('  Write-Host "Nicht mehr verwendete Volumes werden geloescht"');
    Lines.Add('  Wait-Countdown 3');
    Lines.Add('  Invoke-DockerStep { docker volume prune -f } "Fehler beim Bereinigen nicht verwendeter Volumes."');
    Lines.Add('  Wait-Countdown 3');
    AddDanglingImagePrune(Lines);
    Lines.Add('  Write-Host "-----------------------------------------"');
    Lines.Add('  Write-Host "Backup abgeschlossen: $(Get-Date)"');
    Lines.Add('  Write-Host "Dateien gespeichert in: $BackupDir"');
    // Write new log entries as UTF-8; existing legacy log bytes are not converted.
    // Neue Logeinträge als UTF-8 schreiben; vorhandene alte Logbytes werden nicht konvertiert.
    Lines.Add('  Add-Content -LiteralPath $BackupLog -Encoding UTF8 -Value ("Backup abgeschlossen: " + (Get-Date))');
    Lines.Add('  Add-Content -LiteralPath $BackupLog -Encoding UTF8 -Value ("Backup-Ziel: " + $BackupDir)');
    Lines.Add('  Write-Host "Systeme starten. Fenster wird gleich geschlossen ..."');
    Lines.Add('  Wait-Countdown 10');
    AddPsFooter(Lines);
    SavePsScript(Lines, TargetPath);
  finally
    Lines.Free;
  end;
end;

// Erzeugt das direkt von der Aufgabenplanung ausgeführte Backup: SQL-Dump sowie data-, media- und export-Archive.
// Kein physisches DB-Volume-Archiv und keine Imageversions-Metadaten.
procedure CreatePlannedBackupCmdScript(
  const TargetPath, ComposePath, BackupBasePath, AppDataFolder, DatabaseContainerName: string;
  const Volumes: TDockerVolumeNames; MaxBackupFolders: Integer);
var
  Lines: TStringList;
begin
  Lines := TStringList.Create;
  try
    // Decode native console output as UTF-8 in Windows PowerShell 5.1.
    // Native Konsolenausgaben in Windows PowerShell 5.1 als UTF-8 lesen.
    Lines.Add('[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false)');
    AddPsHeader(Lines);
    Lines.Add('try {');
    Lines.Add(Format('  $ComposeDir = %s', [PsQuote(ExtractFilePath(ComposePath))]));
    Lines.Add(Format('  $BackupBase = %s', [PsQuote(BackupBasePath)]));
    Lines.Add(Format('  $DatabaseContainer = %s', [PsQuote(DatabaseContainerName)]));
    Lines.Add(Format('  $PlannedLog = %s', [PsQuote(IncludeTrailingPathDelimiter(AppDataFolder) + 'GeplanterBackup.log')]));
    Lines.Add('  $BackupDir = Join-Path $BackupBase (Get-Date -Format "yyyy-MM-dd_HH-mm-ss")');
    Lines.Add('  Set-Location -LiteralPath $ComposeDir');
    Lines.Add('  if (-not (Test-Path -LiteralPath $BackupDir)) { New-Item -ItemType Directory -Path $BackupDir | Out-Null }');
    AddActivePaperlessSecretKeyBackup(Lines);
    AddBestEffortDjangoMigration(Lines);
    Lines.Add('  $DumpFile = Join-Path $BackupDir ($DatabaseContainer + "_backup.sql")');
    AddUtf8DatabaseDump(Lines);
    Lines.Add('  Invoke-DockerStep { docker compose down } "Fehler beim Stoppen der Container."');
    AddVolumeBackup(Lines, Volumes.Data, 'data');
    AddVolumeBackup(Lines, Volumes.Media, 'media');
    AddVolumeBackup(Lines, Volumes.ExportData, 'export');
    AddEncryptedEmailEnvBackup(Lines);
    Lines.Add('  Invoke-DockerStep { docker compose up -d } "Fehler beim Starten der Container."');
    Lines.Add('  Invoke-DockerStep { docker volume prune -f } "Fehler beim Bereinigen nicht verwendeter Volumes."');
    AddDanglingImagePrune(Lines);
    // Write new log entries as UTF-8; existing legacy log bytes are not converted.
    // Neue Logeinträge als UTF-8 schreiben; vorhandene alte Logbytes werden nicht konvertiert.
    Lines.Add('  Add-Content -LiteralPath $PlannedLog -Encoding UTF8 -Value ("Backup abgeschlossen: " + (Get-Date))');
    Lines.Add('  Add-Content -LiteralPath $PlannedLog -Encoding UTF8 -Value ("Backup-Ziel: " + $BackupDir)');
    // Apply retention only after a successful backup; preserve the current folder.
    // Aufbewahrung erst nach erfolgreichem Backup anwenden; aktuellen Ordner erhalten.
    Lines.Add(Format('  $MaxBackupFolders = %d', [MaxBackupFolders]));
    Lines.Add('  if ($MaxBackupFolders -gt 0) {');
    Lines.Add('    try {');
    Lines.Add('      $folders = @(Get-ChildItem -LiteralPath $BackupBase -Directory -ErrorAction Stop | Where-Object {');
    Lines.Add('        $date = [datetime]::MinValue');
    Lines.Add('        -not ($_.Attributes -band [IO.FileAttributes]::ReparsePoint) -and [datetime]::TryParseExact($_.Name, ''yyyy-MM-dd_HH-mm-ss'', [Globalization.CultureInfo]::InvariantCulture, [Globalization.DateTimeStyles]::None, [ref]$date)');
    Lines.Add('      } | Sort-Object Name -Descending)');
    Lines.Add('      $folders | Select-Object -Skip $MaxBackupFolders | Where-Object { $_.FullName -ne $BackupDir } | ForEach-Object {');
    Lines.Add('        try { Remove-Item -LiteralPath $_.FullName -Recurse -Force -ErrorAction Stop }');
    Lines.Add('        catch { Write-Warning ("Aufräumen fehlgeschlagen: " + $_.Exception.Message) }');
    Lines.Add('      }');
    Lines.Add('    } catch { Write-Warning ("Aufräumen fehlgeschlagen: " + $_.Exception.Message) }');
    Lines.Add('  }');
    AddPsFooter(Lines);
    SavePsScript(Lines, TargetPath);
  finally
    Lines.Free;
  end;
end;

// Erzeugt Restore für alte oder neue Quelldateinamen; die Ziele bleiben stets die übergebenen PG18-Container und -Volumes.
// Startet zunächst DB/Broker, wartet auf pg_isready und importiert SQL mit UTF-8-Pipe und ON_ERROR_STOP.
// Erkennt den Django-Migrationsstand, migriert Legacy-Daten nötigenfalls über Paperless 2.20.15 und danach auf die Zielversion.
// Paperless startet erst nach erfolgreicher Migration. Das alte physische PostgreSQL-Volume wird nicht zurückgespielt.
procedure CreateRestoreCmdScript(
  const TargetPath, ComposePath, BackupFolder, DatabaseContainerName: string;
  const Volumes: TDockerVolumeNames; const UseLegacyBackupNames: Boolean);
var
  Lines: TStringList;
  ArchiveVolumes: TDockerVolumeNames;
  DumpContainerName: string;
begin
  // Nur die Quellnamen anpassen; Zielcontainer und Zielvolumes bleiben PG18.
  ArchiveVolumes := Volumes;
  DumpContainerName := DatabaseContainerName;
  if UseLegacyBackupNames then
  begin
    ArchiveVolumes.Data := StringReplace(Volumes.Data, '-pg18', '', []);
    ArchiveVolumes.Media := StringReplace(Volumes.Media, '-pg18', '', []);
    ArchiveVolumes.ExportData := StringReplace(Volumes.ExportData, '-pg18', '', []);
    DumpContainerName := StringReplace(DatabaseContainerName, '-pg18', '', []);
  end;
  Lines := TStringList.Create;
  try
    AddPsHeader(Lines);
    Lines.Add('try {');
    Lines.Add(Format('  $ComposeDir = %s', [PsQuote(ExtractFilePath(ComposePath))]));
    Lines.Add(Format('  $BackupDir = %s', [PsQuote(BackupFolder)]));
    Lines.Add(Format('  $DatabaseContainer = %s', [PsQuote(DatabaseContainerName)]));
    Lines.Add(Format('  $DumpFile = Join-Path $BackupDir %s', [PsQuote(DumpContainerName + '_backup.sql')]));
    Lines.Add('  if (-not (Test-Path -LiteralPath $DumpFile)) { throw "Fehler: Datenbank-Dump fehlt: $DumpFile" }');
    Lines.Add('  Set-Location -LiteralPath $ComposeDir');
    Lines.Add('  Write-Host "Stoppe Container..."');
    Lines.Add('  Invoke-DockerStep { docker compose down } "Fehler beim Stoppen der Container."');
    AddVolumeRestore(Lines, Volumes.Data, 'data', ArchiveVolumes.Data);
    AddVolumeRestore(Lines, Volumes.Media, 'media', ArchiveVolumes.Media);
    AddVolumeRestore(Lines, Volumes.ExportData, 'export', ArchiveVolumes.ExportData);
    Lines.Add(Format('  $ComposeFile = %s', [PsQuote(ComposePath)]));
    Lines.Add('  Write-Host "Starte Datenbank und Broker; Paperless bleibt bis nach der Migration gestoppt."');
    Lines.Add('  Invoke-DockerStep { docker compose -f $ComposeFile up -d db broker } "Fehler beim Starten von Datenbank und Broker."');
    // SQL-Reset/Import erst nach erfolgreicher Bereitschaftsprüfung ausführen.
    Lines.Add('  $DatabaseReady = $false');
    Lines.Add('  for ($Attempt = 0; $Attempt -lt 60; $Attempt++) {');
    Lines.Add('    docker exec $DatabaseContainer pg_isready -U paperless -d paperless | Out-Null');
    Lines.Add('    if ($LASTEXITCODE -eq 0) { $DatabaseReady = $true; break }');
    Lines.Add('    Start-Sleep -Seconds 2');
    Lines.Add('  }');
    Lines.Add('  if (-not $DatabaseReady) { throw "PostgreSQL wurde innerhalb von 120 Sekunden nicht bereit." }');
    Lines.Add('  Invoke-DockerStep { docker exec $DatabaseContainer psql -U paperless -d paperless -v ON_ERROR_STOP=1 -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;" } "Fehler beim Zuruecksetzen des public Schemas."');
    Lines.Add('  $OutputEncoding = New-Object System.Text.UTF8Encoding($false)');
    Lines.Add('  Get-Content -LiteralPath $DumpFile -Encoding UTF8 | docker exec -i $DatabaseContainer psql -U paperless -d paperless -v ON_ERROR_STOP=1');
    Lines.Add('  if ($LASTEXITCODE -ne 0) { throw "Fehler beim Wiederherstellen der PostgreSQL-Datenbank. (ExitCode $LASTEXITCODE)" }');
    // Dateinamen bestimmen nicht den Migrationsweg: Maßgeblich sind die importierten Django-Marker.
    Lines.Add('  $MigrationQuery = "SELECT CASE WHEN EXISTS (SELECT 1 FROM django_migrations WHERE app=''documents'' ' +
      'AND name IN (''1075_workflowaction_order'',''0001_squashed'',''0002_squashed'')) THEN ''ready'' ' +
      'WHEN EXISTS (SELECT 1 FROM django_migrations WHERE app=''documents'') THEN ''legacy'' ELSE ''unknown'' END;"');
    Lines.Add('  $MigrationState = docker exec $DatabaseContainer psql -U paperless -d paperless -v ON_ERROR_STOP=1 -At -c $MigrationQuery');
    Lines.Add('  if ($LASTEXITCODE -ne 0) { throw "Migrationsstand konnte nicht gelesen werden." }');
    Lines.Add('  $MigrationState = ($MigrationState -join '''').Trim()');
    Lines.Add('  if ($MigrationState -eq ''legacy'') {');
    Lines.Add('    Write-Host "Altes Backup: Zwischenmigration mit Paperless 2.20.15 erforderlich."');
    Lines.Add('    $MigrationOverride = [IO.Path]::GetTempFileName()');
    Lines.Add('    try {');
    Lines.Add('      [IO.File]::WriteAllText($MigrationOverride, "services:`n  paperless:`n    image: ghcr.io/paperless-ngx/paperless-ngx:2.20.15`n", [Text.Encoding]::UTF8)');
    Lines.Add('      Invoke-DockerStep { docker compose -f $ComposeFile -f $MigrationOverride pull paperless } "Paperless 2.20.15 konnte nicht geladen werden."');
    Lines.Add('      Invoke-DockerStep { docker compose -f $ComposeFile -f $MigrationOverride run --rm --no-deps -T --entrypoint python3 paperless /usr/src/paperless/src/manage.py migrate --noinput } "Zwischenmigration mit Paperless 2.20.15 fehlgeschlagen."');
    Lines.Add('    } finally { Remove-Item -LiteralPath $MigrationOverride -Force }');
    Lines.Add('    $MigrationState = docker exec $DatabaseContainer psql -U paperless -d paperless -v ON_ERROR_STOP=1 -At -c $MigrationQuery');
    Lines.Add('    if ($LASTEXITCODE -ne 0 -or ($MigrationState -join '''').Trim() -ne ''ready'') { throw "Erforderlicher Migrationsstand nicht erreicht. Paperless bleibt gestoppt." }');
    Lines.Add('  } elseif ($MigrationState -eq ''ready'') {');
    Lines.Add('    Write-Host "Datenbank bereits kompatibel: Zwischenmigration wird uebersprungen."');
    Lines.Add('  } else { throw "Unbekannter Paperless-Migrationsstand. Abbruch." }');
    Lines.Add('  Write-Host "Migration auf die konfigurierte Paperless-Zielversion..."');
    Lines.Add('  Invoke-DockerStep { docker compose -f $ComposeFile run --rm --no-deps -T --entrypoint python3 paperless /usr/src/paperless/src/manage.py migrate --noinput } "Migration auf die Zielversion fehlgeschlagen."');
    Lines.Add('  Invoke-DockerStep { docker compose -f $ComposeFile up -d } "Fehler beim Starten der Container."');
    Lines.Add('  Write-Host "Nicht mehr verwendete Volumes werden geloescht"');
    Lines.Add('  Wait-Countdown 3');
    Lines.Add('  Invoke-DockerStep { docker volume prune -f } "Fehler beim Bereinigen nicht verwendeter Volumes."');
    Lines.Add('  Wait-Countdown 3');
    AddDanglingImagePrune(Lines);
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

// Erzeugt compose down/up und anschließende Wartung. Die enthaltene Django-Migration ist hier weiterhin nichtfatal.
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
    AddDanglingImagePrune(Lines);
    Lines.Add('  Start-Sleep -Seconds 3');
    AddBestEffortDjangoMigration(Lines);
    Lines.Add('  Start-Sleep -Seconds 3');
    AddPsFooter(Lines);
    SavePsScript(Lines, TargetPath);
  finally
    Lines.Free;
  end;
end;

// Das PowerShell-Skript erstellen, das die geplante Backup-Aufgabe entfernt.
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

// Das PowerShell-Skript erstellen, das die geplante Backup-Aufgabe eintraegt oder aktualisiert.
procedure CreateBackupScheduleCmdScript(
  const TargetPath, BackupScriptPath, Weekdays, Hour, Minute: string);
var
  Lines: TStringList;
begin
  Lines := TStringList.Create;
  try
    AddPsHeader(Lines);
    Lines.Add('try {');
    Lines.Add('  Write-Host "=== Backup-Aufgabe wird in die Aufgabenplanung eingetragen ==="');
    Lines.Add(Format('  $BackupScriptPath = %s', [PsQuote(BackupScriptPath)]));
    Lines.Add(Format('  $Weekdays = %s', [PsQuote(Weekdays)]));
    Lines.Add(Format('  $StartTime = %s', [PsQuote(Hour + ':' + Minute)]));
    Lines.Add('  $DaysOfWeek = $Weekdays.Split('','') | ForEach-Object {');
    Lines.Add('    switch ($_) {');
    Lines.Add('      ''MON'' { ''Monday'' }');
    Lines.Add('      ''TUE'' { ''Tuesday'' }');
    Lines.Add('      ''WED'' { ''Wednesday'' }');
    Lines.Add('      ''THU'' { ''Thursday'' }');
    Lines.Add('      ''FRI'' { ''Friday'' }');
    Lines.Add('      ''SAT'' { ''Saturday'' }');
    Lines.Add('      ''SUN'' { ''Sunday'' }');
    Lines.Add('    }');
    Lines.Add('  }');
    // Hide the PowerShell window when the scheduled task starts.
    // Das PowerShell-Fenster beim Start der geplanten Aufgabe ausblenden.
    Lines.Add('  $Action = New-ScheduledTaskAction -Execute ''powershell.exe'' -Argument (''-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "'' + $BackupScriptPath + ''"'')');
    Lines.Add('  $Trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek $DaysOfWeek -At $StartTime');
    Lines.Add('  Register-ScheduledTask -TaskName ''PaperlessBackup'' -Action $Action -Trigger $Trigger -Force | Out-Null');
    Lines.Add('  Write-Host "=== Fertig ==="');
    AddPsFooter(Lines);
    SavePsScript(Lines, TargetPath);
  finally
    Lines.Free;
  end;
end;

end.
