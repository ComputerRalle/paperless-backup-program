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

uses System.Classes;

type
  // Docker volume names used by the backup and restore scripts.
  // Docker-Volume-Namen, die von den Backup- und Wiederherstellungsskripten verwendet werden.
  TDockerVolumeNames = record
    Data: string;
    DbData: string;
    ExportData: string;
    Media: string;
  end;

const
  LocalBackupScriptMarker = '# Paperless local backup v2';

procedure AddLocalOperationLock(const Lines: TStrings);
procedure CreateManualBackupCmdScript(
  const TargetPath, ComposePath, BackupPath, AppDataFolder, MailFile: string; MaxBackupFolders: Integer);

procedure CreatePlannedBackupCmdScript(
  const TargetPath, ComposePath, BackupBasePath, AppDataFolder: string; MaxBackupFolders: Integer);

procedure CreateRestoreCmdScript(
  const TargetPath, ComposePath, BackupFolder, WorkDir, LogPath: string;
  const ApplyKey, ApplyMail, UseLegacyBackupNames: Boolean);

procedure CreateRestartCmdScript(const TargetPath, ComposePath: string);
procedure CreateDeleteBackupScheduleCmdScript(const TargetPath: string);
procedure CreateBackupScheduleCmdScript(
  const TargetPath, BackupScriptPath, Weekdays, Hour, Minute: string);

implementation

uses
  System.SysUtils, Winapi.Windows, AppConfig;

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
  Lines.Add('$OperationLock = $null');
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

// Wait for an HTTP response inside the running Paperless container.
// Auf eine HTTP-Antwort im gestarteten Paperless-Container warten.
procedure AddLocalPaperlessReadiness(const Lines: TStringList);
begin
  Lines.Add('function Wait-LocalPaperless([string]$id) {');
  Lines.Add('  $probe = "import http.client,sys; c=http.client.HTTPConnection(''127.0.0.1'',8000,timeout=3); c.request(''GET'',''/''); r=c.getresponse(); sys.exit(0 if 200 <= r.status < 400 or r.status in (401,403) else 1)"');
  Lines.Add('  $deadline = [DateTime]::UtcNow.AddMinutes(3)');
  Lines.Add('  $oldPreference = $ErrorActionPreference');
  Lines.Add('  $ErrorActionPreference = ''Continue''');
  Lines.Add('  try {');
  Lines.Add('    do {');
  Lines.Add('      docker exec $id python3 -c $probe 2>$null | Out-Null');
  Lines.Add('      if ($LASTEXITCODE -eq 0) { return }');
  Lines.Add('      Start-Sleep -Seconds 2');
  Lines.Add('    } while ([DateTime]::UtcNow -lt $deadline)');
  Lines.Add('  } finally { $ErrorActionPreference = $oldPreference }');
  Lines.Add('  throw ''Die Paperless-Weboberfläche wurde nicht bereit.''');
  Lines.Add('}');
end;

// Check the archive format before backup publication and before a restore.
// Das Archivformat vor der Backupfreigabe und vor dem Restore prüfen.
procedure AddLocalArchiveValidation(const Lines: TStringList);
begin
  Lines.Add('function Assert-PaperlessBackupArchives([string]$CheckDir, [string]$Image, [string]$SqlName, [string[]]$ArchiveNames) {');
  Lines.Add('  $validator = @''');
  Lines.Add('import gzip');
  Lines.Add('import pathlib');
  Lines.Add('import sys');
  Lines.Add('import tarfile');
  Lines.Add('');
  Lines.Add('root = pathlib.Path("/paperless-check")');
  Lines.Add('for archive_name in sys.argv[2:]:');
  Lines.Add('    with gzip.open(root / archive_name, "rb") as compressed:');
  Lines.Add('        with tarfile.open(fileobj=compressed, mode="r|") as archive:');
  Lines.Add('            for member in archive:');
  Lines.Add('                name = pathlib.PurePosixPath(member.name)');
  Lines.Add('                if name.is_absolute() or ".." in name.parts or not (member.isfile() or member.isdir()):');
  Lines.Add('                    raise ValueError(f"Unsafe archive member in {archive_name}")');
  Lines.Add('        while compressed.read(1024 * 1024):');
  Lines.Add('            pass');
  Lines.Add('with open(root / sys.argv[1], encoding="utf-8-sig") as dump:');
  Lines.Add('    if not dump.read(4096).strip():');
  Lines.Add('        raise ValueError("Empty SQL dump")');
  Lines.Add('    while dump.read(1024 * 1024):');
  Lines.Add('        pass');
  Lines.Add('''@');
  Lines.Add('  $validatorName = ''.paperless-check-'' + [guid]::NewGuid().ToString(''N'') + ''.py''');
  Lines.Add('  $validatorPath = Join-Path $CheckDir $validatorName');
  Lines.Add('  try {');
  Lines.Add('    [IO.File]::WriteAllText($validatorPath, $validator, [Text.UTF8Encoding]::new($false))');
  Lines.Add('    Invoke-DockerStep { docker run --rm --network none --read-only --cap-drop ALL --security-opt no-new-privileges -v "$($CheckDir):/paperless-check:ro" --entrypoint python3 $Image "/paperless-check/$validatorName" $SqlName @ArchiveNames } ''Die Sicherungsdateien sind nicht vollständig lesbar oder enthalten nicht unterstützte Archiveinträge.''');
  Lines.Add('  } finally {');
  Lines.Add('    if ([IO.File]::Exists($validatorPath)) { [IO.File]::Delete($validatorPath) }');
  Lines.Add('  }');
  Lines.Add('}');
end;

// Coordinate GUI and scheduled operations through the same Compose directory.
// GUI und Aufgabenplanung über dieselbe Sperre im Compose-Ordner koordinieren.
procedure AddLocalOperationLock(const Lines: TStrings);
begin
  Lines.Add('  try {');
  Lines.Add('    $OperationLock = [IO.File]::Open((Join-Path $ComposeDir ''.paperless-operation.lock''), [IO.FileMode]::OpenOrCreate, [IO.FileAccess]::ReadWrite, [IO.FileShare]::None)');
  Lines.Add('  } catch { throw (''Die lokale Paperless-Installation ist belegt oder die Vorgangssperre konnte nicht geöffnet werden: '' + $_.Exception.Message) }');
end;

// Den gemeinsamen PowerShell-catch-Block und den Erfolgs-Exitcode hinzufügen.
procedure AddPsFooter(const Lines: TStringList);
begin
  Lines.Add('');
  Lines.Add('} catch {');
  Lines.Add('  Write-Host ""');
  Lines.Add('  Write-Host (''PAPERLESS_FEHLER: '' + $_.Exception.Message) -ForegroundColor Red');
  Lines.Add('  exit 1');
  Lines.Add('} finally {');
  Lines.Add('  if ($OperationLock) { $OperationLock.Dispose() }');
  Lines.Add('}');
  Lines.Add('');
  Lines.Add('exit 0');
end;

// Write the complete UTF-8 PS1 before replacing an existing task script.
// Das vollständige UTF-8-Skript schreiben, bevor eine vorhandene Aufgabendatei ersetzt wird.
procedure SavePsScript(const Lines: TStringList; const TargetPath: string);
var
  TemporaryPath: string;
  Attributes, NewAttributes: DWORD;
  Saved: Boolean;
begin
  TemporaryPath := TargetPath + '.' + GUIDToString(TGUID.NewGuid) + '.tmp';
  Attributes := Winapi.Windows.GetFileAttributes(PChar(TargetPath));
  Saved := False;
  try
    Lines.SaveToFile(TemporaryPath, TEncoding.UTF8);
    if Attributes <> INVALID_FILE_ATTRIBUTES then
    begin
      NewAttributes := Attributes and not (FILE_ATTRIBUTE_HIDDEN or FILE_ATTRIBUTE_READONLY);
      if NewAttributes = 0 then NewAttributes := FILE_ATTRIBUTE_NORMAL;
      if not Winapi.Windows.SetFileAttributes(PChar(TargetPath), NewAttributes) then RaiseLastOSError;
    end;
    if not Winapi.Windows.MoveFileEx(PChar(TemporaryPath), PChar(TargetPath),
      MOVEFILE_REPLACE_EXISTING or MOVEFILE_WRITE_THROUGH) then RaiseLastOSError;
    Saved := True;
    Winapi.Windows.SetFileAttributes(PChar(TargetPath), FILE_ATTRIBUTE_HIDDEN);
  finally
    if not Saved then
    begin
      if Attributes <> INVALID_FILE_ATTRIBUTES then
        Winapi.Windows.SetFileAttributes(PChar(TargetPath), Attributes);
      System.SysUtils.DeleteFile(TemporaryPath);
    end;
  end;
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

// Stage and verify the backup before giving it a timestamp name.
// Die Sicherung vor der Freigabe unter ihrem Zeitstempelnamen vorbereiten und prüfen.
procedure CreateLocalBackupScript(const TargetPath, ComposePath, BackupTarget, AppDataFolder, MailFile: string;
  MaxBackupFolders: Integer; Manual: Boolean);
var
  Lines: TStringList;
  LogName: string;
begin
  Lines := TStringList.Create;
  try
    if Manual then LogName := 'Backup.log'
    else LogName := 'GeplanterBackup.log';
    Lines.Add(LocalBackupScriptMarker);
    Lines.Add('[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false)');
    AddPsHeader(Lines);
    AddLocalPaperlessReadiness(Lines);
    AddLocalArchiveValidation(Lines);
    Lines.Add('$ComposeFile = ' + PsQuote(ExpandFileName(ComposePath)));
    Lines.Add('$ComposeDir = Split-Path -Parent $ComposeFile');
    Lines.Add('$BackupLog = ' + PsQuote(IncludeTrailingPathDelimiter(AppDataFolder) + LogName));
    Lines.Add('$MailFile = ' + PsQuote(MailFile));
    Lines.Add(Format('$MaxBackupFolders = %d', [MaxBackupFolders]));
    Lines.Add('$DumpName = ' + PsQuote(ComposeProjectName + '-db-1_backup.sql'));
    Lines.Add('$DataName = ' + PsQuote(ComposeProjectName + '_data.tar.gz'));
    Lines.Add('$MediaName = ' + PsQuote(ComposeProjectName + '_media.tar.gz'));
    Lines.Add('$ExportName = ' + PsQuote(ComposeProjectName + '_export.tar.gz'));
    Lines.Add('$DbDataName = ' + PsQuote(ComposeProjectName + '_db_data_18.tar.gz'));
    if Manual then
    begin
      Lines.Add('$Manual = $true');
      Lines.Add('$FinalBackupDir = ' + PsQuote(ExpandFileName(BackupTarget)));
      Lines.Add('$BackupBase = Split-Path -Parent $FinalBackupDir');
    end
    else
    begin
      Lines.Add('$Manual = $false');
      Lines.Add('$BackupBase = ' + PsQuote(ExpandFileName(BackupTarget)));
      Lines.Add('$FinalBackupDir = Join-Path $BackupBase (Get-Date -Format ''yyyy-MM-dd_HH-mm-ss'')');
    end;
    Lines.Add('function Write-BackupLog([string]$Message) {');
    Lines.Add('  try { Add-Content -LiteralPath $BackupLog -Encoding UTF8 -Value ((Get-Date -Format s) + '' '' + $Message) }');
    Lines.Add('  catch { Write-Warning (''Backup-Protokoll konnte nicht geschrieben werden: '' + $_.Exception.Message) }');
    Lines.Add('}');
    Lines.Add('function Get-BackupContainer([string]$Service) {');
    Lines.Add('  $ids = @(docker compose -f $ComposeFile ps --all -q $Service)');
    Lines.Add('  if ($LASTEXITCODE -ne 0 -or $ids.Count -ne 1 -or $ids[0] -notmatch ''^[0-9a-f]{12,64}$'') {');
    Lines.Add('    throw "Für $Service wurde kein eindeutiger Container gefunden."');
    Lines.Add('  }');
    Lines.Add('  $details = (docker inspect $ids[0] --format ''{{json .}}'') -join [Environment]::NewLine');
    Lines.Add('  if ($LASTEXITCODE -ne 0 -or -not $details) { throw "Container $Service konnte nicht geprüft werden." }');
    Lines.Add('  return $details | ConvertFrom-Json');
    Lines.Add('}');
    Lines.Add('function Assert-BackupMount($Container, [string]$Path) {');
    Lines.Add('  $mount = @($Container.Mounts | Where-Object { $_.Destination -ceq $Path -and $_.Type -in @(''volume'',''bind'') })');
    Lines.Add('  if ($mount.Count -ne 1 -or -not $mount[0].Source) { throw "Keine eindeutige Sicherungsquelle für $Path." }');
    Lines.Add('}');
    Lines.Add('function Save-BackupArchive([string]$ContainerId, [string]$Source, [string]$Name) {');
    Lines.Add('  Write-Host "Sichere $Name. Bitte warten."');
    Lines.Add('  Invoke-DockerStep { docker run --rm --network none --volumes-from ($ContainerId + '':ro'') -v ($BackupDir + '':/backup'') alpine tar -czvf "/backup/$Name" -C $Source . } "Fehler beim Sichern von $Name."');
    Lines.Add('  if ($Name -eq $DbDataName) {');
    Lines.Add('    Invoke-DockerStep { docker run --rm --network none -v ($BackupDir + '':/backup:ro'') alpine tar -tzf "/backup/$Name" | Out-Null } "Fehler beim Prüfen von $Name."');
    Lines.Add('  }');
    Lines.Add('}');
    Lines.Add('function Remove-OldVerifiedBackups {');
    Lines.Add('  if ($MaxBackupFolders -le 0) { return }');
    Lines.Add('  $folders = @(Get-ChildItem -LiteralPath $BackupBase -Directory | Where-Object {');
    Lines.Add('    $stamp = [datetime]::MinValue');
    Lines.Add('    if (($_.Attributes -band [IO.FileAttributes]::ReparsePoint) -or');
    Lines.Add('        -not [datetime]::TryParseExact($_.Name, ''yyyy-MM-dd_HH-mm-ss'', [Globalization.CultureInfo]::InvariantCulture, [Globalization.DateTimeStyles]::None, [ref]$stamp)) { return $false }');
    Lines.Add('    $folder = $_.FullName');
    Lines.Add('    $marker = Get-Item -LiteralPath (Join-Path $folder ''.paperless-backup-complete'') -ErrorAction SilentlyContinue');
    Lines.Add('    if (-not $marker -or $marker.PSIsContainer -or ($marker.Attributes -band [IO.FileAttributes]::ReparsePoint) -or');
    Lines.Add('        (Get-Content -LiteralPath $marker.FullName -Raw) -cne $BackupMarker) { return $false }');
    Lines.Add('    $foreign = @(Get-ChildItem -LiteralPath $folder -Force | Where-Object { $_.PSIsContainer -or ($_.Attributes -band [IO.FileAttributes]::ReparsePoint) })');
    Lines.Add('    if ($foreign.Count) { return $false }');
    Lines.Add('    foreach ($name in @($DumpName, $DataName, $MediaName, $ExportName)) {');
    Lines.Add('      $item = Get-Item -LiteralPath (Join-Path $folder $name) -ErrorAction SilentlyContinue');
    Lines.Add('      if (-not $item -or $item.PSIsContainer -or $item.Length -le 0 -or ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) { return $false }');
    Lines.Add('    }');
    Lines.Add('    return $true');
    Lines.Add('  } | Sort-Object Name -Descending)');
    Lines.Add('  # Preserve the current backup even if the clock has been set back.');
    Lines.Add('  # Aktuelles Backup auch bei zurückgestellter Uhr erhalten.');
    Lines.Add('  $folders | Where-Object { $_.FullName -ne $FinalBackupDir } |');
    Lines.Add('    Select-Object -Skip ($MaxBackupFolders - 1) | ForEach-Object {');
    Lines.Add('      try { Remove-Item -LiteralPath $_.FullName -Recurse -Force -ErrorAction Stop }');
    Lines.Add('      catch { Write-BackupLog (''Aufräumen fehlgeschlagen: '' + $_.Exception.Message); Write-Warning $_.Exception.Message }');
    Lines.Add('    }');
    Lines.Add('}');
    Lines.Add('$BackupDir = $null');
    Lines.Add('$TargetLock = $null');
    Lines.Add('$BackupMarker = ''Paperless Backup Programm PG18 - checked archive set v1''');
    Lines.Add('try {');
    AddLocalOperationLock(Lines);
    // Keep the source containers so Docker reuses their exact mounts.
    // Quellcontainer behalten, damit Docker genau deren Mounts verwendet.
    Lines.Add('  if (-not (Test-Path -LiteralPath $ComposeFile -PathType Leaf)) { throw ''Die gespeicherte Compose-Datei fehlt.'' }');
    Lines.Add('  Set-Location -LiteralPath $ComposeDir');
    Lines.Add('  [void][IO.Directory]::CreateDirectory($BackupBase)');
    Lines.Add('  $TargetLock = [IO.File]::Open((Join-Path $BackupBase ''.paperless-backup-target.lock''), [IO.FileMode]::OpenOrCreate, [IO.FileAccess]::ReadWrite, [IO.FileShare]::None)');
    Lines.Add('  if (Test-Path -LiteralPath $FinalBackupDir) { throw ''Der Backup-Zeitstempel ist bereits belegt. Bitte erneut versuchen.'' }');
    Lines.Add('  $BackupDir = Join-Path $BackupBase (''.paperless-incomplete-'' + [Guid]::NewGuid().ToString(''N''))');
    Lines.Add('  [void][IO.Directory]::CreateDirectory($BackupDir)');
    Lines.Add('  $Paperless = Get-BackupContainer ''paperless''');
    Lines.Add('  $Database = Get-BackupContainer ''db''');
    Lines.Add('  $DatabaseContainer = $Database.Id');
    Lines.Add('  if (-not $Database.State.Running) { throw ''Der PostgreSQL-Container ist nicht gestartet.'' }');
    Lines.Add('  foreach ($path in @(''/usr/src/paperless/data'',''/usr/src/paperless/media'',''/usr/src/paperless/export'')) { Assert-BackupMount $Paperless $path }');
    Lines.Add('  Assert-BackupMount $Database ''/var/lib/postgresql''');
    Lines.Add('  $version = (docker exec $DatabaseContainer psql -U paperless -d paperless -At -v ON_ERROR_STOP=1 -c ''SHOW server_version_num'') -join ''''');
    Lines.Add('  if ($LASTEXITCODE -ne 0 -or $version.Trim() -notmatch ''^18[0-9]{4}$'') { throw ''Eine laufende PostgreSQL-18-Datenbank wird benötigt.'' }');
    Lines.Add('  $alpineImage = @(docker image ls -q alpine:latest)');
    Lines.Add('  if ($LASTEXITCODE -ne 0) { throw ''Docker-Images konnten nicht geprüft werden.'' }');
    Lines.Add('  if (-not $alpineImage.Count) { Invoke-DockerStep { docker pull alpine } ''Das Archivierungsimage konnte nicht geladen werden.'' }');
    Lines.Add('  $DumpFile = Join-Path $BackupDir $DumpName');
    Lines.Add('  $keys = @($Paperless.Config.Env | Where-Object { $_.StartsWith(''PAPERLESS_SECRET_KEY='') -and $_.Length -gt ''PAPERLESS_SECRET_KEY=''.Length })');
    Lines.Add('  if ($keys.Count -eq 1) { [IO.File]::WriteAllText((Join-Path $BackupDir ''paperless_secret_key.txt''), ($keys[0] + [Environment]::NewLine), [Text.UTF8Encoding]::new($true)) }');
    Lines.Add('  else { Write-BackupLog ''WARNUNG: Secret Key wurde nicht gesichert.''; Write-Warning ''Secret Key wurde nicht gesichert.'' }');
    Lines.Add('  if ($MailFile) {');
    Lines.Add('    if (Test-Path -LiteralPath $MailFile -PathType Leaf) { Copy-Item -LiteralPath $MailFile -Destination (Join-Path $BackupDir ''email-versand.env.enc'') }');
    Lines.Add('    elseif ($Manual) { throw ''Die vorbereitete verschlüsselte Maildatei fehlt.'' }');
    Lines.Add('  }');
    Lines.Add('  $RestartPaperless = $false');
    Lines.Add('  $RestartDatabase = $false');
    Lines.Add('  $BackupError = $null');
    Lines.Add('  $RestartError = $null');
    Lines.Add('  try {');
    Lines.Add('    if ($Paperless.State.Running) {');
    Lines.Add('      $RestartPaperless = $true');
    Lines.Add('      Invoke-DockerStep { docker stop --time 60 $Paperless.Id } ''Paperless konnte nicht angehalten werden.''');
    Lines.Add('    }');
    Lines.Add('    Write-Host ''Erstelle den PostgreSQL-Dump.''');
    AddUtf8DatabaseDump(Lines);
    Lines.Add('    if (-not (Get-Item -LiteralPath $DumpFile).Length -or');
    Lines.Add('        -not (@(Get-Content -LiteralPath $DumpFile -Tail 12) -contains ''-- PostgreSQL database dump complete'')) {');
    Lines.Add('      throw ''Der PostgreSQL-Dump ist unvollständig.''');
    Lines.Add('    }');
    Lines.Add('    Save-BackupArchive $Paperless.Id ''/usr/src/paperless/data'' $DataName');
    Lines.Add('    Save-BackupArchive $Paperless.Id ''/usr/src/paperless/media'' $MediaName');
    Lines.Add('    Save-BackupArchive $Paperless.Id ''/usr/src/paperless/export'' $ExportName');
    Lines.Add('    if ($Manual) {');
    Lines.Add('      $RestartDatabase = $true');
    Lines.Add('      Invoke-DockerStep { docker stop --time 60 $DatabaseContainer } ''PostgreSQL konnte für das physische Archiv nicht angehalten werden.''');
    Lines.Add('      Save-BackupArchive $DatabaseContainer ''/var/lib/postgresql'' $DbDataName');
    Lines.Add('    }');
    Lines.Add('  } catch { $BackupError = $_.Exception.Message }');
    Lines.Add('  finally {');
    Lines.Add('    try {');
    Lines.Add('      if ($RestartDatabase) {');
    Lines.Add('        Invoke-DockerStep { docker start $DatabaseContainer } ''PostgreSQL konnte nicht neu gestartet werden.''');
    Lines.Add('        $ready = $false');
    Lines.Add('        for ($attempt = 0; $attempt -lt 60; $attempt++) {');
    Lines.Add('          docker exec $DatabaseContainer pg_isready -U paperless -d paperless | Out-Null');
    Lines.Add('          if ($LASTEXITCODE -eq 0) { $ready = $true; break }');
    Lines.Add('          Start-Sleep -Seconds 2');
    Lines.Add('        }');
    Lines.Add('        if (-not $ready) { throw ''PostgreSQL wurde nach dem Neustart nicht bereit.'' }');
    Lines.Add('      }');
    Lines.Add('      if ($RestartPaperless) {');
    Lines.Add('        Invoke-DockerStep { docker start $Paperless.Id } ''Paperless konnte nicht neu gestartet werden.''');
    Lines.Add('        Wait-LocalPaperless $Paperless.Id');
    Lines.Add('      }');
    Lines.Add('    } catch { $RestartError = $_.Exception.Message }');
    Lines.Add('  }');
    Lines.Add('  if ($BackupError -and $RestartError) { throw ($BackupError + '' Wiederanlauf fehlgeschlagen: '' + $RestartError) }');
    Lines.Add('  if ($BackupError) { throw $BackupError }');
    Lines.Add('  if ($RestartError) { throw $RestartError }');
    Lines.Add('  Assert-PaperlessBackupArchives $BackupDir $Paperless.Image $DumpName @($DataName, $MediaName, $ExportName)');
    Lines.Add('  $expectedFiles = @($DumpName, $DataName, $MediaName, $ExportName)');
    Lines.Add('  if ($Manual) { $expectedFiles += $DbDataName }');
    Lines.Add('  foreach ($name in $expectedFiles) {');
    Lines.Add('    $file = Get-Item -LiteralPath (Join-Path $BackupDir $name)');
    Lines.Add('    if ($file.PSIsContainer -or $file.Length -le 0) { throw "Die Sicherungsdatei $name fehlt oder ist leer." }');
    Lines.Add('  }');
    Lines.Add('  [IO.File]::WriteAllText((Join-Path $BackupDir ''.paperless-backup-complete''), $BackupMarker, [Text.Encoding]::ASCII)');
    Lines.Add('  [IO.Directory]::Move($BackupDir, $FinalBackupDir)');
    Lines.Add('  $BackupDir = $null');
    Lines.Add('  Write-BackupLog "Backup abgeschlossen. Ziel: $FinalBackupDir"');
    Lines.Add('  try { Remove-OldVerifiedBackups }');
    Lines.Add('  catch { Write-BackupLog (''Aufräumen fehlgeschlagen: '' + $_.Exception.Message); Write-Warning $_.Exception.Message }');
    Lines.Add('  Write-Host "Backup abgeschlossen: $FinalBackupDir"');
    Lines.Add('} catch {');
    Lines.Add('  $failure = $_.Exception.Message');
    Lines.Add('  Write-BackupLog (''FEHLER: '' + $failure)');
    Lines.Add('  Write-Host (''PAPERLESS_FEHLER: '' + $failure) -ForegroundColor Red');
    Lines.Add('  exit 1');
    Lines.Add('} finally {');
    Lines.Add('  if ($BackupDir -and (Test-Path -LiteralPath $BackupDir -PathType Container)) {');
    Lines.Add('    try { Remove-Item -LiteralPath $BackupDir -Recurse -Force -ErrorAction Stop }');
    Lines.Add('    catch { Write-BackupLog (''Temporärer Backupordner konnte nicht entfernt werden: '' + $_.Exception.Message) }');
    Lines.Add('  }');
    Lines.Add('  if ($TargetLock) { $TargetLock.Dispose() }');
    Lines.Add('  if ($OperationLock) { $OperationLock.Dispose() }');
    Lines.Add('}');
    Lines.Add('exit 0');
    SavePsScript(Lines, TargetPath);
  finally
    Lines.Free;
  end;
end;

procedure CreateManualBackupCmdScript(
  const TargetPath, ComposePath, BackupPath, AppDataFolder, MailFile: string; MaxBackupFolders: Integer);
begin
  CreateLocalBackupScript(TargetPath, ComposePath, BackupPath, AppDataFolder, MailFile, MaxBackupFolders, True);
end;

procedure CreatePlannedBackupCmdScript(
  const TargetPath, ComposePath, BackupBasePath, AppDataFolder: string; MaxBackupFolders: Integer);
begin
  CreateLocalBackupScript(TargetPath, ComposePath, BackupBasePath, AppDataFolder,
    IncludeTrailingPathDelimiter(AppDataFolder) + EmailEnvEncryptedFileName, MaxBackupFolders, False);
end;

procedure AddRestoreMigrations(const Lines: TStringList);
begin
  // Select the migration path from the imported Django markers.
  // Den Migrationsweg anhand der importierten Django-Marker wählen.
  Lines.Add('  $MigrationQuery = "SELECT CASE WHEN EXISTS (SELECT 1 FROM django_migrations WHERE app=''documents'' ' +
    'AND name IN (''1075_workflowaction_order'',''0001_squashed'',''0002_squashed'')) THEN ''ready'' ' +
    'WHEN EXISTS (SELECT 1 FROM django_migrations WHERE app=''documents'') THEN ''legacy'' ELSE ''unknown'' END;"');
  Lines.Add('  $MigrationState = docker exec --user postgres $DatabaseContainer psql -X -w -U paperless -d paperless -v ON_ERROR_STOP=1 -At -c $MigrationQuery');
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
  Lines.Add('    $MigrationState = docker exec --user postgres $DatabaseContainer psql -X -w -U paperless -d paperless -v ON_ERROR_STOP=1 -At -c $MigrationQuery');
  Lines.Add('    if ($LASTEXITCODE -ne 0 -or ($MigrationState -join '''').Trim() -ne ''ready'') { throw "Erforderlicher Migrationsstand nicht erreicht. Paperless bleibt gestoppt." }');
  Lines.Add('  } elseif ($MigrationState -eq ''ready'') {');
  Lines.Add('    Write-Host "Datenbank bereits kompatibel: Zwischenmigration wird uebersprungen."');
  Lines.Add('  } else { throw "Unbekannter Paperless-Migrationsstand. Abbruch." }');
  Lines.Add('  Write-Host "Migration auf die konfigurierte Paperless-Zielversion..."');
  Lines.Add('  Invoke-DockerStep { docker compose -f $ComposeFile run --rm --no-deps -T --entrypoint python3 paperless /usr/src/paperless/src/manage.py migrate --noinput } "Migration auf die Zielversion fehlgeschlagen."');
end;

// Build the transactional restore worker with separate input and recovery files.
// Den Restore-Worker mit separaten Eingabe- und Rückfalldateien erzeugen.
procedure CreateRestoreCmdScript(
  const TargetPath, ComposePath, BackupFolder, WorkDir, LogPath: string;
  const ApplyKey, ApplyMail, UseLegacyBackupNames: Boolean);
var
  Lines: TStringList;
  Prefix: string;
begin
  if UseLegacyBackupNames then Prefix := 'paperless-ngx'
  else Prefix := ComposeProjectName;
  Lines := TStringList.Create;
  try
    Lines.Add('[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false)');
    AddPsHeader(Lines);
    AddLocalPaperlessReadiness(Lines);
    AddLocalArchiveValidation(Lines);
    Lines.Add('$ComposeFile = ' + PsQuote(ComposePath));
    Lines.Add('$ComposeDir = ' + PsQuote(ExtractFilePath(ComposePath)));
    Lines.Add('$BackupDir = ' + PsQuote(BackupFolder));
    Lines.Add('$RestoreWorkDir = ' + PsQuote(WorkDir));
    Lines.Add('$RestoreLog = ' + PsQuote(LogPath));
    Lines.Add('$DumpFile = Join-Path $BackupDir ' + PsQuote(Prefix + '-db-1_backup.sql'));
    Lines.Add('$ArchiveNames = @{ data = ' + PsQuote(Prefix + '_data.tar.gz') +
      '; media = ' + PsQuote(Prefix + '_media.tar.gz') + '; export = ' + PsQuote(Prefix + '_export.tar.gz') + ' }');
    if ApplyKey then Lines.Add('$ApplyRestoreKey = $true')
    else Lines.Add('$ApplyRestoreKey = $false');
    if ApplyMail then Lines.Add('$ApplyRestoreMail = $true')
    else Lines.Add('$ApplyRestoreMail = $false');
{$I LocalRestoreWorker.inc}
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
