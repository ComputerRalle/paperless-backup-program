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

// Externe Backup- und Wiederherstellungsabläufe.
unit BackupRestoreServer;

interface

uses Winapi.Windows;

type
  TServerBackupAction = (sbaCheckSpace, sbaStartBackup, sbaWatchBackup, sbaDownloadBackup,
    sbaListBackups);

function NormalizeServerBackupFolder(const Value: string): string;
procedure StartServerBackup(out ProcessHandle: THandle; out ResultPath: string;
  const BackupFolder: string = ''; Action: TServerBackupAction = sbaCheckSpace;
  const LocalDownloadFolder: string = '');
function ReadServerBackupResult(const ResultPath: string; ExitCode: DWORD;
  out Caption, MessageText: string; out CompletedBackupFolder: string;
  out AvailableBackupFolders: TArray<string>): Boolean;

implementation

uses
  System.SysUtils, System.Classes, System.IOUtils, System.JSON,
  Vcl.Forms, AppConfig, ExternPaperless;

// Quote a value as a PowerShell single-quoted literal.
// Einen Wert als einfach zitiertes PowerShell-Literal maskieren.
function PsLiteral(const Value: string): string;
begin
  Result := #39 + StringReplace(Value, #39, #39#39, [rfReplaceAll]) + #39;
end;

// Restrict the host to characters accepted by the SSH invocation.
// Den Host auf die fuer den SSH-Aufruf zugelassenen Zeichen beschraenken.
function IsValidHost(const Value: string): Boolean;
var
  C: Char;
begin
  Result := False;
  if (Value = '') or (Value[1] = '-') then Exit;
  for C in Value do
    if not CharInSet(C, ['A'..'Z', 'a'..'z', '0'..'9', '.', '-', ':', '_']) then Exit;
  Result := True;
end;

// Restrict the SSH user name to supported characters.
// Den SSH-Benutzernamen auf unterstuetzte Zeichen beschraenken.
function IsValidUser(const Value: string): Boolean;
var
  C: Char;
begin
  Result := False;
  if Value = '' then Exit;
  for C in Value do
    if not CharInSet(C, ['A'..'Z', 'a'..'z', '0'..'9', '.', '-', '_']) then Exit;
  Result := True;
end;

// Detect control characters in server paths and project names.
// Steuerzeichen in Serverpfaden und Projektnamen erkennen.
function HasControlChars(const Value: string): Boolean;
var
  C: Char;
begin
  Result := True;
  for C in Value do if Ord(C) < 32 then Exit;
  Result := False;
end;

// Use the default Compose file for a directory and retain explicit YAML names.
// Bei einem Ordner die Standard-Compose-Datei verwenden und YAML-Dateinamen beibehalten.
function RemoteComposeFile(const Value: string): string;
var
  S: string;
begin
  Result := Trim(Value);
  if Result = '' then Exit;
  S := LowerCase(Result);
  if S.EndsWith('.yml') or S.EndsWith('.yaml') then Exit;
  if Result[Length(Result)] <> '/' then Result := Result + '/';
  Result := Result + 'docker-compose.yml';
end;

// Accept a dedicated absolute Linux directory and reject ambiguous path components.
// Einen eigenen absoluten Linux-Ordner zulassen und mehrdeutige Pfadbestandteile ablehnen.
function NormalizeServerBackupFolder(const Value: string): string;
var
  DelimitedPath: string;
begin
  Result := Trim(Value);
  while (Length(Result) > 1) and Result.EndsWith('/') do
    SetLength(Result, Length(Result) - 1);
  DelimitedPath := Result + '/';
  if (Length(Result) < 2) or not Result.StartsWith('/') or HasControlChars(Result) or
     (Pos('//', Result) > 0) or (Pos('/./', DelimitedPath) > 0) or
     (Pos('/../', DelimitedPath) > 0) then
    raise Exception.Create('Bitte einen absoluten Linux-Pfad für einen eigenen Backupordner eingeben.');
end;

{$I ServerBackupWorker.inc}

// Publish the last readable server or download step to the application's progress display.
// Den letzten lesbaren Server- oder Download-Schritt an die Fortschrittsanzeige geben.
procedure AddServerProgress(const Lines: TStringList);
begin
  Lines.Add('$progressPath=$resultPath+''.progress''');
  Lines.Add('function SetProgress([string]$value) {');
  Lines.Add(' try {');
  Lines.Add('  $stream=[IO.File]::Open($progressPath,[IO.FileMode]::Open,[IO.FileAccess]::Write,([IO.FileShare]::ReadWrite -bor [IO.FileShare]::Delete))');
  Lines.Add('  try {$bytes=[Text.Encoding]::UTF8.GetBytes($value);$stream.Write($bytes,0,$bytes.Length);$stream.SetLength($bytes.Length)}finally{$stream.Dispose()}');
  Lines.Add(' } catch {}');
  Lines.Add('}');
end;

// Launch or observe the detached Docker worker using the shared SSH transport.
// Den getrennten Docker-Backupcontainer über denselben SSH-Transport starten oder beobachten.
procedure AddDockerBackupRun(const Lines: TStringList; Action: TServerBackupAction;
  const TargetFolder, RunId: string);
begin
  if Action = sbaStartBackup then
  begin
    Lines.Add('$launchBackup = $true');
    Lines.Add('$backupTarget = ' + PsLiteral(TargetFolder));
    Lines.Add('$runId = ' + PsLiteral(RunId));
    Lines.Add('$formatPrefix = ' + PsLiteral(ComposeProjectName));
    Lines.Add('$launcher = ' + PsLiteral(ServerBackupLaunchScript));
  end
  else
    Lines.Add('$launchBackup = $false');
  Lines.Add('$job=''paperless-pg18-backup-job''');
  AddServerProgress(Lines);
  Lines.Add('$step=''Status des Backupcontainers abfragen''');
  Lines.Add('try {');
  Lines.Add(' if($launchBackup){');
  Lines.Add('  $step=''Backupcontainer auf dem Server vorbereiten und starten''');
  Lines.Add('  SetProgress ''Backupcontainer wird vorbereitet ...''');
  Lines.Add('  $lineFeed=[string][char]10');
  Lines.Add('  $prelude=@((''compose=''+(ShArg $composeFile)),(''project=''+(ShArg $project)),(''target=''+(ShArg $backupTarget)),(''job=''+(ShArg $job)),(''run=''+(ShArg $runId)),(''prefix=''+(ShArg $formatPrefix))) -join $lineFeed');
  Lines.Add('  $launchBytes=[Text.Encoding]::UTF8.GetBytes($prelude+$lineFeed+$launcher)');
  Lines.Add('  $launchResult=(Text (Ssh ''sh -s'' $launchBytes 900000)).Trim()');
  Lines.Add('  if($launchResult.StartsWith(''ERROR: '')){');
  Lines.Add('   $title=''Server-Backup: Start fehlgeschlagen''');
  Lines.Add('   $msg="Server: $serverHost`r`n$($launchResult.Substring(7))"');
  Lines.Add('  } elseif(-not $launchResult.StartsWith(''OK: '')){throw ''launch_result''}');
  Lines.Add(' }');
  Lines.Add(' if(-not $launchResult -or $launchResult.StartsWith(''OK: '')){');
  Lines.Add('  $step=''Status des Backupcontainers abfragen''');
  Lines.Add('  $statusCmd=''id=$(docker ps -aq --no-trunc --filter "name=^/''+$job+''$") || exit 1; if [ -z "$id" ]; then printf "missing\n"; else docker inspect --format ''''{{index .Config.Labels "de.computerralle.paperless.backup"}}:{{.State.Status}}:{{.State.ExitCode}}'''' "$id" && docker logs --tail 12 "$id" 2>&1; fi''');
  Lines.Add('  $failures=0');
  Lines.Add('  while([IO.File]::Exists($progressPath)){');
  Lines.Add('   try {$status=Remote $statusCmd;$failures=0} catch {');
  Lines.Add('    $failures++;if($failures -ge 3){throw};SetProgress ''SSH unterbrochen. Verbindung wird erneut versucht ...'';Start-Sleep -Seconds 4;continue');
  Lines.Add('   }');
  Lines.Add('   $rows=@($status.Trim() -split ''\r?\n'')');
  Lines.Add('   if($rows[0] -eq ''missing''){');
  Lines.Add('    $title=''Kein Server-Backup gefunden.''');
  Lines.Add('    $msg=''Auf diesem Server wurde kein Backupcontainer gefunden.''');
  Lines.Add('    break');
  Lines.Add('   }');
  Lines.Add('   if($rows[0] -notmatch ''^pg18:([a-z]+):(\d+)$''){throw ''worker_state''}');
  Lines.Add('   $state=$matches[1];$exitCode=[int]$matches[2]');
  Lines.Add('   $log=@($rows | Select-Object -Skip 1)');
  Lines.Add('   if($state -in @(''running'',''restarting'',''paused'')){');
  Lines.Add('    if($log.Count){SetProgress $log[-1]}else{SetProgress ''Server-Backup läuft ...''}');
  Lines.Add('    Start-Sleep -Seconds 4');
  Lines.Add('    continue');
  Lines.Add('   }');
  Lines.Add('   $title=''Server-Backup: Fehlgeschlagen''');
  // Expose the backup path only when Docker confirms a successful exit and the worker logged publication.
  // Den Sicherungspfad erst bei erfolgreichem Docker-Exitcode und protokollierter Freigabe zurückgeben.
  Lines.Add('   $backupCompleted=($state -eq ''exited'' -and $exitCode -eq 0 -and $log.Count -gt 0 -and $log[-1] -match ''^Backup abgeschlossen: '')');
  Lines.Add('   if($backupCompleted){');
  Lines.Add('    $title=''Server-Backup: Abgeschlossen''');
  Lines.Add('    $completedBackupFolder=$log[-1].Substring(''Backup abgeschlossen: ''.Length)');
  Lines.Add('   }');
  Lines.Add('   $msg="Server: $serverHost`r`nDocker-Status: $state (Exitcode $exitCode)"');
  Lines.Add('   if($launchResult){$msg+="`r`n"+$launchResult.Substring(4)}');
  Lines.Add('   if($log.Count){$msg+="`r`n`r`n"+($log -join "`r`n")}');
  Lines.Add('   break');
  Lines.Add('  }');
  Lines.Add(' }');
  Lines.Add('} catch {');
  Lines.Add(' $title=''Server-Backup: Status nicht verfügbar''');
  Lines.Add(' $msg=(CheckFailure $step $_.Exception)+"`r`n`r`nEin bereits gestarteter Container kann weiterlaufen. Wählen Sie beim nächsten Aufruf Nein, um seinen Status abzurufen."');
  Lines.Add('}');
end;

// Use the same required PG18 file set for discovery and download.
// Für die Suche und den Download dieselben PG18-Pflichtdateien verwenden.
procedure AddRequiredServerBackupFiles(const Lines: TStringList);
begin
  Lines.Add('$required = @(' +
    PsLiteral(ComposeProjectName + '-db-1_backup.sql') + ',' +
    PsLiteral(ComposeProjectName + '_data.tar.gz') + ',' +
    PsLiteral(ComposeProjectName + '_db_data_18.tar.gz') + ',' +
    PsLiteral(ComposeProjectName + '_export.tar.gz') + ',' +
    PsLiteral(ComposeProjectName + '_media.tar.gz') + ',' +
    PsLiteral(PaperlessSecretKeyFileName) + ',' + PsLiteral(ImageVersionsFileName) + ')');
end;

// List only published timestamp folders with readable, nonempty backup files.
// Nur freigegebene Zeitstempelordner mit lesbaren, nicht leeren Sicherungsdateien auflisten.
procedure AddServerBackupList(const Lines: TStringList; const TargetFolder: string);
begin
  AddServerProgress(Lines);
  AddRequiredServerBackupFiles(Lines);
  Lines.Add('$listFolder = ' + PsLiteral(TargetFolder));
  Lines.Add(' $title=''Server-Backups: Prüfung fehlgeschlagen''');
  Lines.Add(' $step=''Gespeicherten Backupordner auf dem Server prüfen''');
  Lines.Add(' try {');
  Lines.Add('  SetProgress ''Server-Backupordner wird geprüft ...''');
  Lines.Add('  $pattern=''./[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]_[0-9][0-9]-[0-9][0-9]-[0-9][0-9]''');
  // Return canonical server paths separately from the dialog message.
  // Kanonische Serverpfade getrennt vom Meldungstext zurückgeben.
  Lines.Add('  $check=''cd -P ''+(ShArg $listFolder)+'' || exit 72; test -r . && test -x . || exit 72; case "$PWD" in /|*[[:cntrl:]]*) exit 73;; esac; printf "%s\n" "$PWD"; for d in ''+$pattern+''; do test -d "$d" && test ! -L "$d" || continue; for f in ''+(($required | ForEach-Object {ShArg $_}) -join '' '')+''; do p="$d/$f"; test -f "$p" && test -s "$p" && test -r "$p" && test ! -L "$p" || continue 2; done; printf "%s\n" "${d#./}"; done''');
  Lines.Add('  $rows=@((Remote $check) -split ''\r?\n'')');
  Lines.Add('  $canonicalFolder=$rows[0]');
  Lines.Add('  if($canonicalFolder -notmatch ''^/[^\x00-\x1f]+$''){throw ''backup_list_path''}');
  Lines.Add('  $entries=@($rows | Select-Object -Skip 1 | Where-Object {$_ -match ''^[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}-[0-9]{2}-[0-9]{2}$''} | Sort-Object -Descending)');
  Lines.Add('  $availableBackupFolders=@($entries | ForEach-Object {$canonicalFolder+''/''+$_})');
  Lines.Add('  $title=''Verfügbare Server-Backups''');
  Lines.Add('  $msg="Server: $serverHost`r`nBackupordner: $listFolder"');
  Lines.Add('  if($entries.Count -eq 0){');
  Lines.Add('   $msg+="`r`n`r`nIn diesem Ordner sind keine vollständigen, lesbaren Server-Backups verfügbar."');
  Lines.Add('  } else {');
  Lines.Add('   $msg+="`r`n`r`nVerfügbare Backups: $($entries.Count)"');
  Lines.Add('  }');
  Lines.Add('  $backupCompleted=$true');
  Lines.Add(' } catch {');
  Lines.Add('  $msg="Server: $serverHost`r`nBackupordner: $listFolder`r`n`r`n"');
  Lines.Add('  if($_.Exception.Message -eq ''ssh_exit_72''){ $msg+=''Der Backupordner ist auf dem Server nicht vorhanden oder nicht lesbar.'' }');
  Lines.Add('  else { $msg+=CheckFailure $step $_.Exception }');
  Lines.Add(' }');
end;

// Copy the exact PG18 backup into a new local folder, then publish it in one move.
// Das PG18-Backup in einen neuen lokalen Ordner kopieren und erst danach freigeben.
procedure AddServerBackupDownload(const Lines: TStringList; const RemoteFolder, LocalFolder, RunId: string);
begin
  AddServerProgress(Lines);
  Lines.Add('$downloadSource = ' + PsLiteral(RemoteFolder));
  Lines.Add('$downloadParent = ' + PsLiteral(LocalFolder));
  Lines.Add('$runId = ' + PsLiteral(RunId));
  AddRequiredServerBackupFiles(Lines);
  Lines.Add('$mailFile = ' + PsLiteral(EmailEnvEncryptedFileName));
  Lines.Add(' $title=''Server-Backup: Download fehlgeschlagen''');
  Lines.Add(' $step=''Backupordner auf dem Server prüfen''');
  Lines.Add(' $staging=$null');
  Lines.Add(' try {');
  Lines.Add('  SetProgress ''Dateiliste des Server-Backups wird geprüft ...''');
  Lines.Add('  $folderName=$downloadSource.Substring($downloadSource.LastIndexOf(''/'')+1)');
  Lines.Add('  if($folderName -notmatch ''^[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}-[0-9]{2}-[0-9]{2}$''){throw ''backup_folder''}');
  Lines.Add('  $final=[IO.Path]::Combine($downloadParent,$folderName)');
  Lines.Add('  $names=$required+@($mailFile)');
  Lines.Add('  $manifest=''set -eu; cd ''+(ShArg $downloadSource)+''; test "$(pwd -P)" = ''+(ShArg $downloadSource)+''; for f in ''+(($required | ForEach-Object {ShArg $_}) -join '' '')+''; do test -f "$f" && test ! -L "$f" || exit 70; bytes=$(stat -c %s -- "$f"); printf "%s\t%s\n" "$f" "$bytes"; done; f=''+(ShArg $mailFile)+''; if [ -e "$f" ] || [ -L "$f" ]; then test -f "$f" && test ! -L "$f" || exit 70; bytes=$(stat -c %s -- "$f"); printf "%s\t%s\n" "$f" "$bytes"; fi''');
  // Accept only the defined file names and record their remote sizes before opening local files.
  // Nur die festgelegten Dateinamen übernehmen und vor dem Öffnen lokaler Dateien ihre Größen erfassen.
  Lines.Add('  $sizes=@{}');
  Lines.Add('  foreach($row in ((Remote $manifest).TrimEnd("`r","`n") -split ''\r?\n'')){');
  Lines.Add('   $parts=$row.Split([char]9)');
  Lines.Add('   if($parts.Count -ne 2 -or $names -cnotcontains $parts[0] -or $sizes.ContainsKey($parts[0]) -or $parts[1] -notmatch ''^\d+$''){throw ''manifest''}');
  Lines.Add('   $sizes[$parts[0]]=[long]::Parse($parts[1],[Globalization.CultureInfo]::InvariantCulture)');
  Lines.Add('  }');
  Lines.Add('  foreach($name in $required){if(-not $sizes.ContainsKey($name) -or $sizes[$name] -le 0){throw ''manifest''}}');
  Lines.Add('  $step=''Windows-Zielordner vorbereiten''');
  Lines.Add('  if(-not [IO.Directory]::Exists($downloadParent)){throw ''download_parent''}');
  Lines.Add('  if(Test-Path -LiteralPath $final){throw ''download_exists''}');
  Lines.Add('  $candidate=[IO.Path]::Combine($downloadParent,''.paperless-download-''+$runId+''.partial'')');
  Lines.Add('  if(Test-Path -LiteralPath $candidate){throw ''download_staging''}');
  Lines.Add('  [void][IO.Directory]::CreateDirectory($candidate)');
  Lines.Add('  $staging=$candidate');
  Lines.Add('  $index=0');
  Lines.Add('  foreach($name in $names){');
  Lines.Add('   if(-not $sizes.ContainsKey($name)){continue}');
  Lines.Add('   if(-not [IO.File]::Exists($progressPath)){throw ''download_cancelled''}');
  Lines.Add('   $index++');
  Lines.Add('   $step="Datei $index/$($sizes.Count) herunterladen: $name"');
  Lines.Add('   SetProgress $step');
  Lines.Add('   $remoteFile=$downloadSource+''/''+$name');
  Lines.Add('   $quoted=ShArg $remoteFile');
  Lines.Add('   $destination=[IO.Path]::Combine($staging,$name)');
  Lines.Add('   Ssh (''test -f ''+$quoted+'' && test ! -L ''+$quoted+'' && cat -- ''+$quoted) $null -1 $destination ([long]$sizes[$name])');
  Lines.Add('  }');
  Lines.Add('  $step=''Vollständigen Backupordner freigeben''');
  Lines.Add('  if(-not [IO.File]::Exists($progressPath)){throw ''download_cancelled''}');
  // A directory move publishes the complete transfer and refuses an existing final directory.
  // Den vollständigen Download per Verzeichnisverschiebung freigeben und ein vorhandenes Ziel ablehnen.
  Lines.Add('  [IO.Directory]::Move($staging,$final)');
  Lines.Add('  $staging=$null');
  Lines.Add('  $backupCompleted=$true');
  Lines.Add('  $title=''Server-Backup: Download abgeschlossen''');
  Lines.Add('  $msg="Das Backup wurde auf diesen Windows-Computer heruntergeladen.`r`n`r`nZielordner: $final"');
  Lines.Add(' } catch {');
  Lines.Add('  if($_.Exception.Message -eq ''download_exists''){ $msg="Der Zielordner ist bereits vorhanden:`r`n$final" }');
  Lines.Add('  elseif($_.Exception.Message -eq ''download_length''){ $msg="$step`r`nDie Dateigröße stimmt nicht mit der Angabe des Servers überein." }');
  Lines.Add('  else { $msg=CheckFailure $step $_.Exception }');
  // Clean only the known files inside this run's staging directory if publication did not occur.
  // Bei fehlender Freigabe nur die bekannten Dateien im Zwischenordner dieses Laufs entfernen.
  Lines.Add(' } finally {');
  Lines.Add('  if($staging){');
  Lines.Add('   try {');
  Lines.Add('    if(([IO.File]::GetAttributes($staging) -band [IO.FileAttributes]::ReparsePoint) -ne 0){throw ''download_staging''}');
  Lines.Add('    foreach($name in $names){[IO.File]::Delete([IO.Path]::Combine($staging,$name))}');
  Lines.Add('    [IO.Directory]::Delete($staging,$false)');
  Lines.Add('   } catch { $msg+="`r`n`r`nUnvollständige Dateien liegen in: $staging" }');
  Lines.Add('  }');
  Lines.Add(' }');
end;

// Start the requested server operation with the saved SSH profile.
// Den gewählten Servervorgang mit dem gespeicherten SSH-Profil starten.
procedure StartServerBackup(out ProcessHandle: THandle; out ResultPath: string;
  const BackupFolder: string; Action: TServerBackupAction; const LocalDownloadFolder: string);
var
  Ini: TAppSettingsIni;
  SettingsPath, Host, UserName, KeyFile, Auth, ComposeFile, Project, SavedBackupFolder: string;
  ScriptPath, ServerDir, ScriptKind, PowerShellPath, CommandLine, RunId: string;
  ServerDirAttributes: DWORD;
  Lines: TStringList;
  PortNumber: Integer;
  UseKey: Boolean;
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
begin
  ProcessHandle := 0;
  ResultPath := '';
  SettingsPath := IncludeTrailingPathDelimiter(LoadInstallationFolder) + SettingsFileName;
  try
    Ini := TAppSettingsIni.Create(SettingsPath);
    try
      Host := Trim(Ini.ReadString('Paperless Extern', 'Host', ''));
      UserName := Trim(Ini.ReadString('Paperless Extern', 'Benutzer', ''));
      if not TryStrToInt(Trim(Ini.ReadString('Paperless Extern', 'SSH-Port', '')), PortNumber) or
        (PortNumber < 1) or (PortNumber > 65535) then
        raise Exception.Create('Bitte zuerst einen gültigen SSH-Port speichern.');
      KeyFile := Trim(Ini.ReadString('Paperless Extern', 'SSH-Key-Datei', ''));
      Auth := Ini.ReadString('Paperless Extern', 'Anmeldung', 'Passwort');
      ComposeFile := RemoteComposeFile(Ini.ReadString('Paperless Extern', 'Compose-Datei', ''));
      Project := Trim(Ini.ReadString('Paperless Extern', 'Compose-Projekt', ''));
      SavedBackupFolder := Ini.ReadString('Paperless Extern', IniKeyServerBackupFolder, DefaultServerBackupFolder);
    finally
      Ini.Free;
    end;
    if not IsValidHost(Host) or not IsValidUser(UserName) then
      raise Exception.Create('Bitte gültigen Server und Benutzernamen speichern.');
    if (BackupFolder = '') and (Action in [sbaCheckSpace, sbaStartBackup]) and
       ((ComposeFile = '') or not ComposeFile.StartsWith('/') or HasControlChars(ComposeFile) or HasControlChars(Project)) then
      raise Exception.Create('Bitte einen gültigen absoluten Compose-Ordner speichern.');
    if SameText(Auth, 'SSH-Key') then UseKey := True
    else if SameText(Auth, 'Passwort') then UseKey := False
    else raise Exception.Create('Die gespeicherte Anmeldeart ist ungültig.');
    if UseKey and ((KeyFile = '') or not FileExists(KeyFile)) then
      raise Exception.Create('Die gespeicherte SSH-Key-Datei wurde nicht gefunden.');
    if not UseKey and (ReadServerSecret(SettingsPath, 'Passwort') = '') then
      raise Exception.Create('Bitte zuerst das SSH-Passwort speichern.');

    if Action in [sbaStartBackup, sbaListBackups] then
      SavedBackupFolder := NormalizeServerBackupFolder(SavedBackupFolder);
    if (Action = sbaDownloadBackup) and not TDirectory.Exists(LocalDownloadFolder) then
      raise Exception.Create('Der gewählte Windows-Zielordner ist nicht vorhanden.');
    RunId := StringReplace(StringReplace(TGUID.NewGuid.ToString, '{', '', []), '}', '', []);
    // Retain the exact script for each invocation and keep only IPC files temporary.
    // Das genaue Skript jedes Aufrufs behalten und nur Ergebnis- und Fortschrittsdateien temporär speichern.
    ServerDir := TPath.Combine(ExtractFilePath(SettingsPath), 'Server');
    if not TDirectory.Exists(ExtractFilePath(SettingsPath)) then
      raise Exception.Create('Der Laufzeitordner des Programms ist nicht vorhanden.');
    TDirectory.CreateDirectory(ServerDir);
    ServerDirAttributes := GetFileAttributes(PChar(ServerDir));
    if (ServerDirAttributes = INVALID_FILE_ATTRIBUTES) or
       ((ServerDirAttributes and FILE_ATTRIBUTE_REPARSE_POINT) <> 0) then
      raise Exception.Create('Der Server-Ordner muss ein direktes Verzeichnis im Laufzeitordner sein.');
    case Action of
      sbaStartBackup: ScriptKind := 'backup-start';
      sbaWatchBackup: ScriptKind := 'backup-status';
      sbaDownloadBackup: ScriptKind := 'backup-download';
      sbaListBackups: ScriptKind := 'backupliste';
    else
      if BackupFolder <> '' then ScriptKind := 'backupordner'
      else ScriptKind := 'speicherpruefung';
    end;
    ScriptPath := TPath.Combine(ServerDir, FormatDateTime('yyyy-mm-dd_hh-nn-ss', Now) +
      '_' + ScriptKind + '_' + RunId + '.ps1');
    ResultPath := TPath.Combine(TPath.GetTempPath, 'paperless-server-' + RunId + '.result');
    TFile.WriteAllText(ResultPath, '', TEncoding.UTF8);
    if Action <> sbaCheckSpace then
      TFile.WriteAllText(ResultPath + '.progress', '', TEncoding.UTF8);
    Lines := TStringList.Create;
    try
      Lines.Add('# Paperless Backup Programm - generated server script / erzeugtes Serverskript');
      Lines.Add('# The application prepares the result file before starting this script.');
      Lines.Add('# Die Anwendung bereitet die Ergebnisdatei vor dem Skriptstart vor.');
      Lines.Add('$resultPath = ' + PsLiteral(ResultPath));
      Lines.Add('if (-not [IO.File]::Exists($resultPath)) { throw ''Bitte den Servervorgang im Paperless Backup Programm starten.'' }');
      Lines.Add('$env:PAPERLESS_SSH_HELPER = ''1''');
      Lines.Add('$env:PAPERLESS_SSH_SETTINGS = ' + PsLiteral(SettingsPath));
      if UseKey then Lines.Add('$env:PAPERLESS_SSH_AUTH = ''key''')
      else Lines.Add('$env:PAPERLESS_SSH_AUTH = ''password''');
      Lines.Add('$env:SSH_ASKPASS = ' + PsLiteral(Application.ExeName));
      Lines.Add('$env:SSH_ASKPASS_REQUIRE = ''force''');
      Lines.Add('$env:DISPLAY = ''paperless:0''');
      Lines.Add('$runtimeDir = ' + PsLiteral(ExtractFilePath(SettingsPath)));
      Lines.Add('$serverHost = ' + PsLiteral(Host));
      Lines.Add('$serverUser = ' + PsLiteral(UserName));
      Lines.Add('$port = ' + PsLiteral(IntToStr(PortNumber)));
      Lines.Add('$keyFile = ' + PsLiteral(KeyFile));
      Lines.Add('$composeFile = ' + PsLiteral(ComposeFile));
      Lines.Add('$project = ' + PsLiteral(Project));
      if UseKey then Lines.Add('$useKey = $true') else Lines.Add('$useKey = $false');
      Lines.Add('$ErrorActionPreference = ''Stop''');
      Lines.Add('$privateDir = $null');
      Lines.Add('$backupCompleted = $false');
      Lines.Add('$completedBackupFolder = ''''');
      Lines.Add('$availableBackupFolders = @()');
// Quote arguments for Windows and the remote POSIX shell.
// Argumente fuer Windows und die POSIX-Shell des Servers maskieren.
      Lines.Add('function WinArg([string]$s) {');
      Lines.Add(' $b=New-Object Text.StringBuilder; [void]$b.Append(''"''); $n=0');
      Lines.Add(' foreach($c in $s.ToCharArray()) {');
      Lines.Add('  if ($c -eq ''\'') {$n++;continue}');
      Lines.Add('  if ($c -eq ''"'') {[void]$b.Append((''\''*(2*$n+1)));[void]$b.Append(''"'');$n=0;continue}');
      Lines.Add('  if ($n) {[void]$b.Append((''\''*$n));$n=0};[void]$b.Append($c)');
      Lines.Add(' }');
      Lines.Add(' if($n){[void]$b.Append((''\''*(2*$n)))};[void]$b.Append(''"'');$b.ToString()');
      Lines.Add('}');
      Lines.Add('function ShArg([string]$s) {$q=[string][char]39;return $q+$s.Replace($q,($q+''\''+$q+$q))+$q}');
// Transfer SSH streams as bytes, keep stderr separate, and check the process result.
// SSH-Daten als Bytes uebertragen, stderr getrennt halten und das Prozessergebnis pruefen.
      Lines.Add('function Ssh([string]$cmd,[byte[]]$inputBytes,[int]$timeoutMs=120000,[string]$outputPath,[long]$expectedBytes=0) {');
      Lines.Add(' $si=New-Object Diagnostics.ProcessStartInfo; $si.FileName=(Get-Command ssh.exe -ErrorAction Stop).Source');
      Lines.Add(' $a=@(''-T'',''-o'',''StrictHostKeyChecking=yes'',''-o'',''UpdateHostKeys=no'',''-o'',''ConnectTimeout=10'',''-o'',''NumberOfPasswordPrompts=1'',''-p'',$port,''-l'',$serverUser)');
      Lines.Add(' if($useKey){$a+=@(''-o'',''IdentitiesOnly=yes'',''-i'',$keyFile)}else{$a+=@(''-o'',''PreferredAuthentications=password'',''-o'',''PubkeyAuthentication=no'')}');
      Lines.Add(' if($outputPath){$a+=@(''-o'',''ServerAliveInterval=15'',''-o'',''ServerAliveCountMax=3'')}');
      Lines.Add(' $a+=@($serverHost,$cmd);$si.Arguments=(($a|ForEach-Object{WinArg $_}) -join '' '')');
      Lines.Add(' $si.UseShellExecute=$false;$si.CreateNoWindow=$true;$si.RedirectStandardOutput=$true;$si.RedirectStandardError=$true;$si.RedirectStandardInput=$true');
// Stream backup files directly to a new file and keep the bounded memory path for metadata.
// Backupdateien direkt in eine neue Datei schreiben und Metadaten weiter im Speicher lesen.
      Lines.Add(' $p=New-Object Diagnostics.Process;$p.StartInfo=$si;$m=$null;$started=$false');
      Lines.Add(' try {');
      Lines.Add('  if($outputPath){$m=[IO.File]::Open($outputPath,[IO.FileMode]::CreateNew,[IO.FileAccess]::Write,[IO.FileShare]::Read)}');
      Lines.Add('  else{$m=New-Object IO.MemoryStream}');
      Lines.Add('  if(-not $p.Start()){throw ''ssh_start''}');
      Lines.Add('  $started=$true');
      Lines.Add('  $err=$p.StandardError.ReadToEndAsync();$out=$p.StandardOutput.BaseStream.CopyToAsync($m)');
      Lines.Add('  if($inputBytes){$write=$p.StandardInput.BaseStream.WriteAsync($inputBytes,0,$inputBytes.Length);if(-not $write.Wait(120000)){try{$p.Kill()}catch{};throw ''ssh_timeout''}}');
      Lines.Add('  $p.StandardInput.Close()');
      // Measure download progress and use an idle timeout so large active transfers can finish.
      // Downloadfortschritt messen und nur bei Stillstand abbrechen, damit große aktive Übertragungen fertig werden.
      Lines.Add('  if($outputPath){');
      Lines.Add('   $watch=[Diagnostics.Stopwatch]::StartNew();$received=0');
      Lines.Add('   while(-not $p.WaitForExit(1000)){');
      Lines.Add('    if(-not [IO.File]::Exists($progressPath)){throw ''download_cancelled''}');
      Lines.Add('    if($out.IsFaulted){$out.GetAwaiter().GetResult()}');
      Lines.Add('    $length=([IO.FileInfo]::new($outputPath)).Length');
      Lines.Add('    if($length -gt $expectedBytes){throw ''download_length''}');
      Lines.Add('    if($length -gt $received){');
      Lines.Add('     $received=$length;$watch.Restart()');
      Lines.Add('     if($expectedBytes -gt 0){SetProgress ("$step ("+[math]::Floor(100.0*$received/$expectedBytes)+" %)")}');
      Lines.Add('    } elseif($watch.ElapsedMilliseconds -ge 300000){throw ''ssh_timeout''}');
      Lines.Add('   }');
      Lines.Add('  } elseif(-not $p.WaitForExit($timeoutMs)){throw ''ssh_timeout''}');
      Lines.Add('  if(-not $out.Wait(10000) -or -not $err.Wait(10000)){throw ''ssh_read''}');
      Lines.Add('  if($p.ExitCode -ne 0){throw (''ssh_exit_''+$p.ExitCode)}');
      Lines.Add('  if($outputPath){$m.Flush();if($m.Length -ne $expectedBytes){throw ''download_length''};return}');
      Lines.Add('  if($m.Length -gt 16777216){throw ''size''}');
      Lines.Add('  return ,$m.ToArray()');
      Lines.Add(' } finally {');
      Lines.Add('  if($started -and -not $p.HasExited){try{$p.Kill();[void]$p.WaitForExit(2000)}catch{}}');
      Lines.Add('  if($m){$m.Dispose()}');
      Lines.Add('  $p.Dispose()');
      Lines.Add(' }');
      Lines.Add('}');
      Lines.Add('function Text([byte[]]$b){$utf8=New-Object Text.UTF8Encoding($false,$true);return $utf8.GetString($b).TrimStart([char]0xFEFF)}');
      Lines.Add('function Remote([string]$cmd){return Text (Ssh $cmd $null)}');
      // Parse the same byte-based df output for both server operations.
      // Die bytebasierte df-Ausgabe für beide Servervorgänge gleich auswerten.
      Lines.Add('function ReadFreeBytes([string]$output) {');
      Lines.Add(' $rows=@($output.Trim() -split ''\r?\n'')');
      Lines.Add(' if($rows.Count -ne 2 -or $rows[1].Trim() -notmatch ''^\d+$''){throw ''df''}');
      Lines.Add(' return [long]::Parse($rows[1].Trim(),[Globalization.CultureInfo]::InvariantCulture)');
      Lines.Add('}');
      // Report the failed step and known error codes without exposing command output.
      // Den fehlgeschlagenen Schritt und bekannte Fehlercodes ohne Befehlsausgabe melden.
      Lines.Add('function CheckFailure([string]$step,[Exception]$errorInfo) {');
      Lines.Add(' $code=$errorInfo.Message');
      Lines.Add(' if($code -match ''^ssh_exit_(-?\d+)$''){return "${step} (SSH-Exitcode $($matches[1]))."}');
      Lines.Add(' if($code -eq ''ssh_timeout''){return "${step} (Zeitlimit für SSH überschritten)."}');
      Lines.Add(' if($code -eq ''ssh_start'' -or $code -eq ''ssh_read''){return "${step} (SSH-Prozess konnte nicht gestartet oder ausgelesen werden)."}');
      Lines.Add(' if($code -eq ''changed''){return ''Die Compose-Datei wurde während der Prüfung geändert. Bitte erneut prüfen.''}');
      Lines.Add(' if($code -eq ''docker_remote''){return ''Der Docker-Daemon ist nicht über einen lokalen Unix-Socket erreichbar.''}');
      Lines.Add(' if($code -eq ''driver''){return "${step} (Volume-Treiber oder Optionen werden nicht unterstützt)."}');
      Lines.Add(' return "${step} fehlgeschlagen."');
      Lines.Add('}');
      Lines.Add('$title=''Server-Backup: Prüfung fehlgeschlagen''');
      Lines.Add('$msg=''Die Speicherplatzprüfung konnte nicht abgeschlossen werden.''');
      Lines.Add('try {');
      if Action = sbaListBackups then
        AddServerBackupList(Lines, SavedBackupFolder)
      else if Action = sbaDownloadBackup then
        AddServerBackupDownload(Lines, NormalizeServerBackupFolder(BackupFolder),
          ExpandFileName(LocalDownloadFolder), RunId)
      else if Action <> sbaCheckSpace then
        AddDockerBackupRun(Lines, Action, SavedBackupFolder, RunId)
      else if BackupFolder <> '' then
      begin
        Lines.Add(' $backupFolder = ' + PsLiteral(NormalizeServerBackupFolder(BackupFolder)));
        // Probe the nearest existing directory before creating the requested backup folder.
        // Vor dem Anlegen des Backupordners den nächstgelegenen vorhandenen Ordner prüfen.
      Lines.Add(' $title=''Server-Backup: Backupordner''');
      Lines.Add(' $msg="Server: $serverHost`r`nBackupordner: $backupFolder"');
      Lines.Add(' $step=''Freien Speicher für den Backupordner abfragen (df)''');
      Lines.Add(' try {');
      Lines.Add('  $probe=''p=''+(ShArg $backupFolder)+''; while [ ! -d "$p" ]; do if [ -e "$p" ] || [ -L "$p" ]; then exit 72; fi; p=${p%/*}; [ -n "$p" ] || p=/; done; df -B1 --output=avail -- "$p"''');
      Lines.Add('  $free=ReadFreeBytes (Remote $probe)');
      Lines.Add('  $freeText=(([double]$free/1GB).ToString(''N2''))+'' GiB''');
      Lines.Add('  $msg+="`r`n`r`nFreier Speicher am Backupziel vor dem Anlegen: $freeText"');
        // Create the directory only after df succeeded, with private permissions for new directories.
        // Den Ordner erst nach erfolgreichem df-Aufruf anlegen und neue Verzeichnisse privat halten.
      Lines.Add('  $step=''Backupordner auf dem Server anlegen (mkdir)''');
      Lines.Add('  $null=Remote (''umask 077; mkdir -p -- ''+(ShArg $backupFolder))');
      Lines.Add('  $msg+="`r`n`r`nDer Backupordner ist auf dem Server vorhanden."');
      Lines.Add(' } catch {');
      Lines.Add('  $title=''Server-Backup: Backupordner nicht bestätigt''');
      Lines.Add('  $msg+="`r`n`r`n"+(CheckFailure $step $_.Exception)');
      Lines.Add(' }');
      end
      else
      begin
// Query available space independently so a failed size estimate cannot hide the result.
// Freien Speicher separat abfragen, damit eine fehlgeschlagene Größenschätzung den Wert nicht verdeckt.
      Lines.Add(' $dir=$composeFile.Substring(0,$composeFile.LastIndexOf(''/''));if(-not $dir){$dir=''/''}');
      Lines.Add(' $issues=@();$freeText=''konnte nicht ermittelt werden'';$sizeText=$freeText');
      Lines.Add(' $step=''Freien Speicher im Compose-Ordner abfragen (df)''');
      Lines.Add(' try {');
      Lines.Add('  $free=ReadFreeBytes (Remote (''df -B1 --output=avail -- ''+(ShArg $dir)))');
      Lines.Add('  $freeText=(([double]$free/1GB).ToString(''N2''))+'' GiB''');
      Lines.Add(' } catch {$issues+=(CheckFailure $step $_.Exception)}');
      Lines.Add(' try {');
      Lines.Add(' $step=''Geschützten lokalen Server-Arbeitsordner anlegen''');
// Create a protected temporary workspace for the server Compose copy.
// Einen geschuetzten temporaeren Arbeitsbereich fuer die Server-Compose-Kopie anlegen.
      Lines.Add(' $serverDir=Join-Path $runtimeDir ''Server''');
      Lines.Add(' if(-not [IO.Directory]::Exists($runtimeDir)){throw ''runtime''}');
      Lines.Add(' if(-not [IO.Directory]::Exists($serverDir)){[void][IO.Directory]::CreateDirectory($serverDir)}');
      Lines.Add(' if(([IO.File]::GetAttributes($serverDir) -band [IO.FileAttributes]::ReparsePoint) -ne 0){throw ''server_link''}');
      Lines.Add(' $privateDir=Join-Path $serverDir (''compose-''+[guid]::NewGuid().ToString(''N''))');
      Lines.Add(' $acl=New-Object Security.AccessControl.DirectorySecurity;$acl.SetAccessRuleProtection($true,$false)');
      Lines.Add(' $sid=[Security.Principal.WindowsIdentity]::GetCurrent().User');
      Lines.Add(' $inherit=[Security.AccessControl.InheritanceFlags]::ContainerInherit -bor [Security.AccessControl.InheritanceFlags]::ObjectInherit');
      Lines.Add(' $rule=New-Object Security.AccessControl.FileSystemAccessRule($sid,[Security.AccessControl.FileSystemRights]::FullControl,$inherit,[Security.AccessControl.PropagationFlags]::None,[Security.AccessControl.AccessControlType]::Allow)');
      Lines.Add(' $acl.AddAccessRule($rule);[void][IO.Directory]::CreateDirectory($privateDir,$acl)');
      Lines.Add(' if(-not [IO.Directory]::GetAccessControl($privateDir).AreAccessRulesProtected){throw ''acl''}');
// Copy and read the original Compose bytes locally and compare the hash with the server file.
// Die urspruenglichen Compose-Bytes lokal kopieren und lesen; den Hash mit der Serverdatei vergleichen.
      Lines.Add(' $step=''Compose-Datei über SSH lesen''');
      Lines.Add(' $raw=Ssh (''cat -- ''+(ShArg $composeFile)) $null');
      Lines.Add(' if($raw.Length -eq 0){throw ''empty''}');
      Lines.Add(' $step=''Lokale Compose-Kopie schreiben und lesen''');
      Lines.Add(' $local=Join-Path $privateDir ''docker-compose.yml''');
      Lines.Add(' $f=New-Object IO.FileStream($local,[IO.FileMode]::CreateNew,[IO.FileAccess]::Write,[IO.FileShare]::None)');
      Lines.Add(' try{$f.Write($raw,0,$raw.Length);$f.Flush()}finally{$f.Dispose()}');
      Lines.Add(' $localBytes=[IO.File]::ReadAllBytes($local);$localText=Text $localBytes');
      Lines.Add(' if([string]::IsNullOrWhiteSpace($localText)){throw ''empty''}');
      Lines.Add(' $sha=[Security.Cryptography.SHA256]::Create()');
      Lines.Add(' try{$hash=([BitConverter]::ToString($sha.ComputeHash($localBytes))).Replace(''-'','''').ToLowerInvariant()}finally{$sha.Dispose()}');
      Lines.Add(' $step=''Compose-Datei mit dem Server vergleichen''');
      Lines.Add(' $remoteHash=(Remote (''sha256sum -- ''+(ShArg $composeFile))).Trim().Split('' '')[0].ToLowerInvariant()');
      Lines.Add(' if($remoteHash -notmatch ''^[0-9a-f]{64}$'' -or $hash -ne $remoteHash){throw ''changed''}');
      Lines.Add(' $step=''Docker-Kontext auf dem Server prüfen''');
      Lines.Add(' $context=(Remote ''case x${DOCKER_HOST-} in x|xunix:///*) :;; *) exit 95;; esac; docker context inspect'');$context=$context|ConvertFrom-Json');
      Lines.Add(' if(-not $context -or -not $context[0].Endpoints.docker.Host.StartsWith(''unix:///'')){throw ''docker_remote''}');

// Normalize the locally read bytes on the server and parse the JSON in local memory.
// Die lokal gelesenen Bytes auf dem Server aufloesen und das JSON lokal im Speicher auswerten.
      Lines.Add(' $cmd=''cd ''+(ShArg $dir)+'' && docker compose --project-directory ''+(ShArg $dir)+'' -f -''');
      Lines.Add(' if($project){$cmd+='' -p ''+(ShArg $project)}');
      Lines.Add(' $step=''Docker Compose auf dem Server ausführen''');
      Lines.Add(' $modelBytes=Ssh ($cmd+'' config --format json'') $localBytes');
      Lines.Add(' $step=''Compose-JSON unter Windows einlesen''');
      Lines.Add(' $model=(Text $modelBytes)|ConvertFrom-Json');
      Lines.Add(' if(-not $model.services){throw ''services''}');
// Resolve supported volume and bind sources; reject unsupported or inaccessible paths.
// Unterstuetzte Volume- und Bind-Quellen aufloesen; nicht unterstuetzte oder unzugaengliche Pfade ablehnen.
      Lines.Add(' $step=''Speicherpfade aus der Compose-Konfiguration ermitteln''');
      Lines.Add(' $paths=New-Object ''System.Collections.Generic.HashSet[string]'' ([StringComparer]::Ordinal)');
      Lines.Add(' foreach($service in $model.services.PSObject.Properties){foreach($mount in $service.Value.volumes){');
      Lines.Add('  if($null -eq $mount){continue};$source=[string]$mount.source');
      Lines.Add('  if([string]$mount.type -eq ''tmpfs''){continue}');
      Lines.Add('  $step=''Mount-Quelle aus der Compose-Konfiguration auflösen''');
      Lines.Add('  switch([string]$mount.type){');
      Lines.Add('   ''bind''{$path=$source}');
      Lines.Add('   ''volume''{');
      Lines.Add('    if(-not $source -or -not $model.volumes){throw ''volume''}');
      Lines.Add('    $prop=$model.volumes.PSObject.Properties[$source];if(-not $prop -or -not $prop.Value.name){throw ''volume''}');
      Lines.Add('    $volumeName=[string]$prop.Value.name');
      Lines.Add('    $step="Docker-Volume $volumeName auflösen"');
      Lines.Add('    $info=(Remote (''docker volume inspect -- ''+(ShArg $volumeName)))|ConvertFrom-Json');
      Lines.Add('    if(-not $info -or $info[0].Driver -ne ''local''){throw ''driver''}');
      Lines.Add('    if($info[0].Options -and @($info[0].Options.PSObject.Properties).Count -gt 0){throw ''driver''}');
      Lines.Add('    $path=[string]$info[0].Mountpoint');
      Lines.Add('   }');
      Lines.Add('   default{throw ''mount''}');
      Lines.Add('  }');
      Lines.Add('  if(-not $path -or -not $path.StartsWith(''/'') -or $path.IndexOfAny([char[]]"`r`n") -ge 0){throw ''path''}');
      Lines.Add('  $step="Speicherpfad $path auflösen (realpath)"');
      Lines.Add('  $path=(Remote (''realpath -e -- ''+(ShArg $path))).TrimEnd("`r","`n")');
      Lines.Add('  if(-not $path.StartsWith(''/'') -or $path -eq ''/'' -or $path.IndexOfAny([char[]]"`r`n") -ge 0){throw ''path''}');
      Lines.Add('  [void]$paths.Add($path)');
      Lines.Add(' }}');
      Lines.Add(' $step=''Speicherpfade für die Größenmessung zusammenstellen''');
      Lines.Add(' if($paths.Count -eq 0){throw ''paths''}');
// Avoid counting nested paths twice and estimate source size and available space.
// Verschachtelte Pfade nicht doppelt zaehlen und Quellgroesse sowie freien Speicherplatz schaetzen.
      Lines.Add(' $chosen=New-Object ''System.Collections.Generic.List[string]''');
      Lines.Add(' foreach($path in ($paths|Sort-Object Length)){');
      Lines.Add('  $covered=$false;foreach($parent in $chosen){if($path.Equals($parent,[StringComparison]::Ordinal) -or $path.StartsWith($parent+''/'',[StringComparison]::Ordinal)){$covered=$true;break}}');
      Lines.Add('  if(-not $covered){$chosen.Add($path)}');
      Lines.Add(' }');
      Lines.Add(' [long]$total=0');
      Lines.Add(' foreach($path in $chosen){');
      Lines.Add('  $step="Größe von $path messen (du)"');
      Lines.Add('  $v=Remote (''du -sb -- ''+(ShArg $path));if($v -notmatch ''^(\d+)\s''){throw ''du''}');
      Lines.Add('  $n=[long]::Parse($matches[1],[Globalization.CultureInfo]::InvariantCulture)');
      Lines.Add('  if($total -gt [long]::MaxValue-$n){throw ''overflow''}');
      Lines.Add('  $total+=$n');
      Lines.Add(' }');

      Lines.Add(' $step=''Compose-Datei nach der Messung erneut vergleichen''');
      Lines.Add(' $remoteHash=(Remote (''sha256sum -- ''+(ShArg $composeFile))).Trim().Split('' '')[0].ToLowerInvariant();if($hash -ne $remoteHash){throw ''changed''}');
      Lines.Add('  $sizeText=(([double]$total/1GB).ToString(''N2''))+'' GiB''');
      Lines.Add(' } catch {$issues+=(CheckFailure $step $_.Exception)}');
// Show both results and report only the failed step and safe error details.
// Beide Ergebnisse anzeigen und bei Fehlern nur den Prüfschritt und unkritische Details nennen.
      Lines.Add(' $msg="Server: $serverHost`r`nCompose-Ordner: $dir`r`n`r`nFreier Speicher auf dem Dateisystem des Compose-Ordners: $freeText`r`nGeschätzte Größe der zu sichernden Daten: $sizeText"');
      Lines.Add(' $title=''Server-Backup: Speicherplatz''');
      Lines.Add(' if($issues.Count -gt 0){');
      Lines.Add('  $title=''Server-Backup: Prüfung unvollständig''');
      Lines.Add('  $msg+="`r`n`r`n"+($issues -join "`r`n")');
      Lines.Add(' }');
      Lines.Add(' $msg+="`r`n`r`nDas Backupziel ist noch nicht festgelegt. Es wurde kein Backup gestartet."');
      end;

// Remove the temporary Compose copy and warn if cleanup fails.
// Die temporaere Compose-Kopie entfernen und bei fehlgeschlagener Bereinigung warnen.
      Lines.Add('}finally{');
      Lines.Add(' $cleanupFailed=$false');
      Lines.Add(' if($local -and [IO.File]::Exists($local)){try{[IO.File]::Delete($local)}catch{$cleanupFailed=$true}}');
      Lines.Add(' if($privateDir -and [IO.Directory]::Exists($privateDir)){try{[IO.Directory]::Delete($privateDir,$false)}catch{$cleanupFailed=$true}}');
// Publish the result after cleanup. Closing the app removes the file and prevents its recreation.
// Ergebnis nach der Bereinigung bereitstellen. Beim Schließen löscht Delphi die Datei, und das Skript legt sie nicht erneut an.
      Lines.Add(' if($cleanupFailed){');
      Lines.Add('  $msg+="`r`n`r`nDie temporäre Compose-Kopie oder ihr Arbeitsordner konnte nicht gelöscht werden. Bitte prüfen Sie den Ordner:`r`n$privateDir"');
      Lines.Add(' }');
      Lines.Add(' $msg+="`r`n`r`nPowerShell-Skript: $PSCommandPath"');
      Lines.Add(' $json=@{ title=$title; message=$msg; backupCompleted=$backupCompleted; completedBackupFolder=$completedBackupFolder; availableBackupFolders=$availableBackupFolders } | ConvertTo-Json -Compress');
      Lines.Add(' $resultBytes=[Text.Encoding]::UTF8.GetBytes($json)');
      Lines.Add(' try {');
      Lines.Add('  $resultFile=[IO.File]::Open($resultPath,[IO.FileMode]::Open,[IO.FileAccess]::Write,[IO.FileShare]::Delete)');
      Lines.Add('  try {$resultFile.Write($resultBytes,0,$resultBytes.Length);$resultFile.SetLength($resultBytes.Length)}finally{$resultFile.Dispose()}');
      Lines.Add(' } catch [IO.FileNotFoundException] {}');
      Lines.Add('}');
      Lines.SaveToFile(ScriptPath, TEncoding.UTF8);
    finally
      Lines.Free;
    end;
    PowerShellPath := IncludeTrailingPathDelimiter(GetEnvironmentVariable('WINDIR')) +
      'System32\WindowsPowerShell\v1.0\powershell.exe';
    if not FileExists(PowerShellPath) then PowerShellPath := 'powershell.exe';
    // Keep the process handle so Delphi reads the result only after PowerShell exits.
    // Prozesshandle behalten, damit Delphi das Ergebnis erst nach dem Ende von PowerShell liest.
    FillChar(StartupInfo, SizeOf(StartupInfo), 0);
    StartupInfo.cb := SizeOf(StartupInfo);
    CommandLine := '"' + PowerShellPath + '" -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "' + ScriptPath + '"';
    UniqueString(CommandLine);
    if not CreateProcess(nil, PChar(CommandLine), nil, nil, False, CREATE_NO_WINDOW,
      nil, nil, StartupInfo, ProcessInfo) then
      RaiseLastOSError;
    CloseHandle(ProcessInfo.hThread);
    ProcessHandle := ProcessInfo.hProcess;
  except
    if ResultPath <> '' then
    begin
      DeleteFile(ResultPath + '.progress');
      DeleteFile(ResultPath);
    end;
    ResultPath := '';
    raise;
  end;
end;

// Read the server operation's result and its optional backup paths separately from the dialog text.
// Ergebnis des Servervorgangs und optionale Sicherungspfade getrennt vom Dialogtext lesen.
function ReadServerBackupResult(const ResultPath: string; ExitCode: DWORD;
  out Caption, MessageText: string; out CompletedBackupFolder: string;
  out AvailableBackupFolders: TArray<string>): Boolean;
var
  Json: TJSONValue;
  TitleValue, MessageValue, CompletedValue, FolderValue, ListValue, Item: TJSONValue;
  FolderArray: TJSONArray;
  I, FolderCount: Integer;
begin
  Result := False;
  CompletedBackupFolder := '';
  AvailableBackupFolders := nil;
  Caption := 'Server-Backup: Prüfung fehlgeschlagen';
  MessageText := 'Der Servervorgang hat kein lesbares Ergebnis geliefert.';
  if ExitCode <> 0 then
    MessageText := MessageText + sLineBreak + Format('PowerShell-Exitcode: %u.', [ExitCode]);
  if (ExitCode = 0) and FileExists(ResultPath) then
  begin
    Json := TJSONObject.ParseJSONValue(TFile.ReadAllText(ResultPath, TEncoding.UTF8));
    try
      if Json is TJSONObject then
      begin
        TitleValue := TJSONObject(Json).GetValue('title');
        MessageValue := TJSONObject(Json).GetValue('message');
        if (TitleValue is TJSONString) and (MessageValue is TJSONString) then
        begin
          Caption := TitleValue.Value;
          MessageText := MessageValue.Value;
          CompletedValue := TJSONObject(Json).GetValue('backupCompleted');
          if Assigned(CompletedValue) then
            Result := SameText(CompletedValue.Value, 'true');
          FolderValue := TJSONObject(Json).GetValue('completedBackupFolder');
          if Result and (FolderValue is TJSONString) then
            CompletedBackupFolder := FolderValue.Value;
          ListValue := TJSONObject(Json).GetValue('availableBackupFolders');
          if Result and (ListValue is TJSONArray) then
          begin
            FolderArray := TJSONArray(ListValue);
            SetLength(AvailableBackupFolders, FolderArray.Count);
            FolderCount := 0;
            for I := 0 to FolderArray.Count - 1 do
            begin
              Item := FolderArray.Items[I];
              if Item is TJSONString then
              begin
                AvailableBackupFolders[FolderCount] := Item.Value;
                Inc(FolderCount);
              end;
            end;
            SetLength(AvailableBackupFolders, FolderCount);
          end;
        end;
      end;
    finally
      Json.Free;
    end;
  end;
end;

end.