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

// Server backup, restore and transfer through the saved SSH profile.
// Server-Backup, Wiederherstellung und Übertragung über das gespeicherte SSH-Profil.
unit BackupRestoreServer;

interface

uses Winapi.Windows;

type
  TServerBackupAction = (sbaCheckSpace, sbaStartBackup, sbaWatchBackup, sbaDownloadBackup,
    sbaListBackups, sbaUploadBackup, sbaListRestoreBackups, sbaStartRestore, sbaWatchRestore,
    sbaInstallPaperless);

const
  ServerWorkerActions = [sbaStartBackup, sbaWatchBackup, sbaStartRestore, sbaWatchRestore];

function IsValidHost(const Value: string): Boolean;
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
  Vcl.Forms, AppConfig, ExternPaperless, DockerComposeGenerator;

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

// Check the service inside its container, regardless of the published host port.
// Den Dienst unabhängig vom veröffentlichten Hostport im Container prüfen.
procedure AddServerPaperlessReadyCheck(const Lines: TStringList);
begin
  Lines.Add('wait_paperless() {');
  Lines.Add('  attempts=0');
  Lines.Add('  until timeout -k 2 8 docker exec "$1" python3 -c ''import http.client, os, sys; connection = http.client.HTTPConnection("127.0.0.1", int(os.getenv("PAPERLESS_PORT") or 8000), timeout=4); connection.request("GET", "/"); sys.exit(connection.getresponse().status >= 500)'' >/dev/null 2>&1; do');
  Lines.Add('    attempts=$((attempts + 1))');
  Lines.Add('    [ "$attempts" -lt 60 ] || return 1');
  Lines.Add('    sleep 2');
  Lines.Add('  done');
  Lines.Add('}');
end;

{$I ServerBackupWorker.inc}
{$I ServerRestoreWorker.inc}

// Queue worker messages in order. Other operations still publish their latest status.
// Worker-Meldungen der Reihe nach ablegen. Andere Vorgänge geben ihren letzten Stand aus.
procedure AddServerProgress(const Lines: TStringList; QueueMessages: Boolean = False);
begin
  Lines.Add('$progressPath=$resultPath+''.progress''');
  Lines.Add('function SetProgress([string]$value) {');
  Lines.Add(' try {');
  Lines.Add('  $stream=[IO.File]::Open($progressPath,[IO.FileMode]::Open,[IO.FileAccess]::Write,([IO.FileShare]::ReadWrite -bor [IO.FileShare]::Delete))');
  if QueueMessages then
    Lines.Add('  try {$bytes=[Text.Encoding]::UTF8.GetBytes($value+"`n");$stream.Position=$stream.Length;$stream.Write($bytes,0,$bytes.Length)}finally{$stream.Dispose()}')
  else
    Lines.Add('  try {$bytes=[Text.Encoding]::UTF8.GetBytes($value);$stream.Write($bytes,0,$bytes.Length);$stream.SetLength($bytes.Length)}finally{$stream.Dispose()}');
  Lines.Add(' } catch {}');
  Lines.Add('}');
  if QueueMessages then
  begin
    Lines.Add('$progressWorker=''''');
    Lines.Add('$progressLineCount=0');
    // Track the last reported line for the current container. A status query starts at the current step of a running job.
    // Die zuletzt angezeigte Zeile des aktuellen Containers merken. Eine Statusabfrage setzt beim aktuellen Schritt eines laufenden Auftrags an.
    Lines.Add('function PublishWorkerProgress([string]$worker,[string[]]$log,[bool]$running,[bool]$watchOnly) {');
    Lines.Add(' if($script:progressWorker -ne $worker){');
    Lines.Add('  $script:progressWorker=$worker');
    Lines.Add('  $script:progressLineCount=0');
    Lines.Add('  if($watchOnly){');
    Lines.Add('   $script:progressLineCount=$log.Count');
    Lines.Add('   if($running -and $log.Count){$script:progressLineCount--}');
    Lines.Add('  }');
    Lines.Add(' }elseif($log.Count -lt $script:progressLineCount){$script:progressLineCount=0}');
    Lines.Add(' if($log.Count -gt $script:progressLineCount){');
    Lines.Add('  SetProgress ($log[$script:progressLineCount..($log.Count-1)] -join "`n")');
    Lines.Add('  $script:progressLineCount=$log.Count');
    Lines.Add(' }');
    Lines.Add('}');
  end;
end;

// Launch or observe the detached Docker worker using the shared SSH transport.
// Den getrennten Docker-Backupcontainer über denselben SSH-Transport starten oder beobachten.
procedure AddDockerBackupRun(const Lines: TStringList; Action: TServerBackupAction;
  const TargetFolder, RunId: string);
begin
  if Action = sbaStartBackup then
  begin
    Lines.Add('$launchBackup = $true');
    Lines.Add('$runId = ' + PsLiteral(RunId));
    Lines.Add('$formatPrefix = ' + PsLiteral(ComposeProjectName));
    Lines.Add('$launcher = ' + PsLiteral(ServerBackupLaunchScript));
  end
  else
    Lines.Add('$launchBackup = $false');
  Lines.Add('$backupTarget = ' + PsLiteral(TargetFolder));
  Lines.Add('$job=''paperless-pg18-backup-job''');
  AddServerProgress(Lines, True);
  // Pin a launched job by container ID and match profile and destination on reattachment.
  // Einen gestarteten Lauf über die Container-ID und die Statusabfrage über Profil und Ziel zuordnen.
  Lines.Add('$reference=$job');
  Lines.Add('$profileBytes=[Text.Encoding]::UTF8.GetBytes($composeFile+[char]10+$project+[char]10+$backupTarget+[char]10)');
  Lines.Add('$sha=[Security.Cryptography.SHA256]::Create()');
  Lines.Add('try{$profile=([BitConverter]::ToString($sha.ComputeHash($profileBytes))).Replace(''-'','''').ToLowerInvariant()}finally{$sha.Dispose()}');
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
  Lines.Add('  } elseif($launchResult -cmatch ''^OK: ([0-9a-f]{64})$''){$reference=$matches[1]}else{throw ''launch_result''}');
  Lines.Add(' }');
  Lines.Add(' if(-not $launchResult -or $launchResult.StartsWith(''OK: '')){');
  Lines.Add('  $step=''Status des Backupcontainers abfragen''');
  Lines.Add('  $fmt=''{{index .Config.Labels "de.computerralle.paperless.backup"}}:{{index .Config.Labels "de.computerralle.paperless.backup.profile"}}:{{.State.Status}}:{{.State.ExitCode}}:{{.Id}}''');
  Lines.Add('  $statusCmd=''ref=''+(ShArg $reference)+''; fmt=''+(ShArg $fmt)+''; unset DOCKER_HOST DOCKER_CONTEXT; local_docker() { docker --host unix:///var/run/docker.sock "$@"; }; if state=$(local_docker inspect --type=container --format "$fmt" "$ref" 2>/dev/null); then printf "%s\n" "$state"; case "$state" in pg18:''+$profile+'':*) id=$(printf "%s" "$state" | cut -d: -f5); local_docker logs "$id" 2>&1;; esac; elif local_docker info >/dev/null 2>&1; then printf "missing\n"; else exit 1; fi''');
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
  Lines.Add('   $meta=[regex]::Match($rows[0],''^pg18:([0-9a-f]{64}):([a-z]+):(\d+):([0-9a-f]{64})$'')');
  Lines.Add('   if(-not $meta.Success -or $meta.Groups[1].Value -cne $profile){');
  Lines.Add('    $title=''Kein Server-Backup für dieses Profil gefunden''');
  Lines.Add('    $msg=''Der vorhandene Backupcontainer ist einem anderen oder älteren Serverprofil zugeordnet.''');
  Lines.Add('    break');
  Lines.Add('   }');
  Lines.Add('   $state=$meta.Groups[2].Value;$exitCode=[int]$meta.Groups[3].Value;$workerId=$meta.Groups[4].Value');
  Lines.Add('   $log=@($rows | Select-Object -Skip 1)');
  Lines.Add('   $running=$state -in @(''running'',''restarting'',''paused'')');
  Lines.Add('   PublishWorkerProgress $workerId $log $running (-not $launchBackup)');
  Lines.Add('   if($running){');
  Lines.Add('    if(-not $log.Count){SetProgress ''Server-Backup läuft ...''}');
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
  Lines.Add('   if($log.Count){$msg+="`r`n`r`n"+(($log | Select-Object -Last 12) -join "`r`n")}');
  Lines.Add('   break');
  Lines.Add('  }');
  Lines.Add(' }');
  Lines.Add('} catch {');
  Lines.Add(' $title=''Server-Backup: Status nicht verfügbar''');
  Lines.Add(' $msg=(CheckFailure $step $_.Exception)+"`r`n`r`nEin bereits gestarteter Container kann weiterlaufen. Wählen Sie beim nächsten Aufruf Nein, um seinen Status abzurufen."');
  Lines.Add('}');
end;

// Start a detached restore or observe the last restore for the saved Compose profile.
// Einen getrennten Restore starten oder den letzten Restore des gespeicherten Compose-Profils beobachten.
procedure AddDockerRestoreRun(const Lines: TStringList; Action: TServerBackupAction;
  const TargetFolder, RestoreFolder, RunId: string);
begin
  AddServerProgress(Lines, True);
  Lines.Add('$job=''paperless-pg18-restore-job''');
  Lines.Add('$jobId=''''');
  Lines.Add('$answer=''''');
  Lines.Add('$step=''Status der Server-Wiederherstellung abfragen''');
  // Keep the same technical log for success, worker failure, and a lost status connection.
  // Technisches Protokoll bei Erfolg, Workerfehler und unterbrochener Statusverbindung ablegen.
  Lines.Add('function SaveRestoreLog([string]$backup,[string]$status,[string[]]$entries) {');
  Lines.Add('  try {');
  Lines.Add('    $logDir=[IO.Path]::Combine($runtimeDir,''Logs'')');
  Lines.Add('    [void][IO.Directory]::CreateDirectory($logDir)');
  Lines.Add('    $logPath=[IO.Path]::Combine($logDir,[IO.Path]::GetFileNameWithoutExtension($PSCommandPath)+''.log'')');
  Lines.Add('    $logLines=@("Server: $serverHost","Backup: $backup","Status: $status","PowerShell-Skript: $PSCommandPath","")+$entries');
  Lines.Add('    $logFile=[IO.File]::Open($logPath,[IO.FileMode]::CreateNew,[IO.FileAccess]::Write)');
  Lines.Add('    try {');
  Lines.Add('      $writer=[IO.StreamWriter]::new($logFile,[Text.Encoding]::UTF8)');
  Lines.Add('      try { foreach($entry in $logLines){$writer.WriteLine([string]$entry)} } finally {$writer.Dispose()}');
  Lines.Add('    } finally {$logFile.Dispose()}');
  Lines.Add('    return ([Environment]::NewLine*2+"Logdatei: $logPath")');
  Lines.Add('  } catch { return ([Environment]::NewLine*2+"Die Logdatei konnte nicht gespeichert werden.") }');
  Lines.Add('}');
  Lines.Add('try {');
  Lines.Add(' $lf=[string][char]10');
  Lines.Add(' $profileBytes=[Text.Encoding]::UTF8.GetBytes($composeFile+$lf+$project+$lf)');
  Lines.Add(' $sha=[Security.Cryptography.SHA256]::Create()');
  Lines.Add(' try{$profile=([BitConverter]::ToString($sha.ComputeHash($profileBytes))).Replace(''-'','''').ToLowerInvariant()}finally{$sha.Dispose()}');
  if Action = sbaStartRestore then
  begin
    Lines.Add(' $target = ' + PsLiteral(TargetFolder));
    Lines.Add(' $selected = ' + PsLiteral(RestoreFolder));
    Lines.Add(' $run = ' + PsLiteral(RunId));
    Lines.Add(' $prefix = ' + PsLiteral(ComposeProjectName));
    Lines.Add(' $launcher = ' + PsLiteral(ServerRestoreLaunchScript));
    Lines.Add(' $step=''Wiederherstellungscontainer vorbereiten und starten''');
    Lines.Add(' SetProgress $step');
    Lines.Add(' $prelude=@((''compose=''+(ShArg $composeFile)),(''project=''+(ShArg $project)),(''target=''+(ShArg $target)),(''selected=''+(ShArg $selected)),(''job=''+(ShArg $job)),(''run=''+(ShArg $run)),(''prefix=''+(ShArg $prefix))) -join $lf');
    Lines.Add(' $launchBytes=[Text.Encoding]::UTF8.GetBytes($prelude+$lf+$launcher)');
    Lines.Add(' $answer=(Text (Ssh ''sh -s'' $launchBytes 900000)).Trim()');
    Lines.Add(' if($answer.StartsWith(''ERROR: '')){');
    Lines.Add('  $title=''Server-Wiederherstellung: Start fehlgeschlagen''');
    Lines.Add('  $msg="Server: $serverHost"+[Environment]::NewLine+$answer.Substring(7)');
  Lines.Add('  $msg+=SaveRestoreLog $selected ''Start fehlgeschlagen'' @($answer.Substring(7))');
    Lines.Add(' } elseif($answer -cmatch ''^OK: ([0-9a-f]{64})$''){');
    Lines.Add('  $jobId=$matches[1]');
    Lines.Add(' } else {throw ''launch_result''}');
  end;
  // A started job is addressed by container ID. A status query also checks the saved Compose profile.
  // Einen gestarteten Auftrag über die Container-ID ansprechen. Bei der Statusabfrage auch das gespeicherte Compose-Profil prüfen.
  Lines.Add(' if(-not $answer -or $jobId){');
  Lines.Add('  $step=''Status der Server-Wiederherstellung abfragen''');
  Lines.Add('  $reference=$job;if($jobId){$reference=$jobId}');
  Lines.Add('  $fmt=''{{index .Config.Labels "de.computerralle.paperless.restore"}}:{{index .Config.Labels "de.computerralle.paperless.restore.profile"}}:{{.State.Status}}:{{.State.ExitCode}}:{{.Id}}''');
  Lines.Add('  $failures=0');
  Lines.Add('  while([IO.File]::Exists($progressPath)){');
  Lines.Add('   $cmd=''ref=''+(ShArg $reference)+''; fmt=''+(ShArg $fmt)+''; unset DOCKER_HOST DOCKER_CONTEXT; local_docker() { docker --host unix:///var/run/docker.sock "$@"; }; if state=$(local_docker inspect --type=container --format "$fmt" "$ref" 2>/dev/null); then printf "%s\n" "$state"; case "$state" in pg18:''+$profile+'':*) id=$(printf "%s" "$state" | cut -d: -f5); local_docker logs "$id" 2>&1;; esac; elif local_docker info >/dev/null 2>&1; then printf "missing\n"; else exit 1; fi''');
  Lines.Add('   try {$status=Remote $cmd;$failures=0} catch {');
  Lines.Add('    $failures++;if($failures -ge 3){throw};SetProgress ''SSH unterbrochen. Verbindung wird erneut versucht ...'';Start-Sleep -Seconds 4;continue');
  Lines.Add('   }');
  Lines.Add('   $rows=@($status.Trim() -split ''\r?\n'')');
  Lines.Add('   if($rows[0] -eq ''missing''){');
  Lines.Add('    $title=''Keine Server-Wiederherstellung gefunden''');
  Lines.Add('    $msg=''Der Wiederherstellungscontainer wurde auf dem Server nicht gefunden.''');
  Lines.Add('    break');
  Lines.Add('   }');
  Lines.Add('   $meta=[regex]::Match($rows[0],''^pg18:([0-9a-f]{64}):([a-z]+):(\d+):([0-9a-f]{64})$'')');
  Lines.Add('   if(-not $meta.Success -or $meta.Groups[1].Value -cne $profile){');
  Lines.Add('    $title=''Keine Server-Wiederherstellung für dieses Compose-Profil gefunden''');
  Lines.Add('    $msg="Server: $serverHost"+[Environment]::NewLine+''Der vorhandene Container gehört nicht zum gespeicherten Compose-Profil.''');
  Lines.Add('    break');
  Lines.Add('   }');
  Lines.Add('   $state=$meta.Groups[2].Value;$workerExitCode=[int]$meta.Groups[3].Value;$reference=$meta.Groups[4].Value');
  Lines.Add('   $log=@($rows | Select-Object -Skip 1)');
  Lines.Add('   $running=$state -in @(''running'',''restarting'',''paused'')');
  Lines.Add('   PublishWorkerProgress $reference $log $running (-not $jobId)');
  Lines.Add('   if($running){');
  Lines.Add('    if(-not $log.Count){SetProgress ''Server-Wiederherstellung läuft ...''}');
  Lines.Add('    Start-Sleep -Seconds 4');
  Lines.Add('    continue');
  Lines.Add('   }');
  // Require both Docker exit code 0 and the worker's final completion message.
  // Docker-Exitcode 0 und die abschließende Erfolgsmeldung des Workers voraussetzen.
  Lines.Add('   $successMarker=''Wiederherstellung abgeschlossen: ''');
  Lines.Add('   $backupCompleted=($state -eq ''exited'' -and $workerExitCode -eq 0 -and $log.Count -gt 0 -and $log[-1].StartsWith($successMarker))');
  Lines.Add('   if($backupCompleted){');
  Lines.Add('    $title=''Wiederherstellung erfolgreich''');
  Lines.Add('    $restoredFolder=$log[-1].Substring($successMarker.Length)');
  Lines.Add('    $msg="Das Backup wurde erfolgreich wiederhergestellt. Paperless antwortet."');
  Lines.Add('   }else{');
  Lines.Add('    $title=''Server-Wiederherstellung: Fehlgeschlagen''');
  Lines.Add('    $msg="Server: $serverHost"+[Environment]::NewLine+"Docker-Status: $state (Exitcode $workerExitCode)"');
  Lines.Add('    if($log.Count){$msg+=[Environment]::NewLine+[Environment]::NewLine+(($log | Select-Object -Last 12) -join [Environment]::NewLine)}');
  Lines.Add('    $restoredFolder=$selected');
  Lines.Add('   }');
  Lines.Add('   $msg+=SaveRestoreLog $restoredFolder "Docker: $state (Exitcode $workerExitCode)" $log');
  Lines.Add('   break');
  Lines.Add('  }');
  Lines.Add(' }');
  Lines.Add('} catch {');
  Lines.Add(' $title=''Server-Wiederherstellung: Status nicht verfügbar''');
  Lines.Add(' $msg=(CheckFailure $step $_.Exception)+[Environment]::NewLine+[Environment]::NewLine+''Ein bereits gestarteter Container kann weiterlaufen. Rufen Sie den Status über „Backup wiederherstellen“ erneut ab.''');
  Lines.Add(' $msg+=SaveRestoreLog $selected (CheckFailure $step $_.Exception) $log');
  Lines.Add('}');
end;

// Use the same four PG18 restore files for discovery and transfer.
// Für Suche und Übertragung dieselben vier für die PG18-Wiederherstellung nötigen Dateien verwenden.
procedure AddRequiredServerBackupFiles(const Lines: TStringList);
begin
  Lines.Add('$required = @(' +
    PsLiteral(ComposeProjectName + '-db-1_backup.sql') + ',' +
    PsLiteral(ComposeProjectName + '_data.tar.gz') + ',' +
    PsLiteral(ComposeProjectName + '_export.tar.gz') + ',' +
    PsLiteral(ComposeProjectName + '_media.tar.gz') + ')');
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

// Hash the actual bytes via the Windows PowerShell .NET runtime.
// Die übertragenen Bytes über die .NET-Laufzeit von Windows PowerShell prüfen.
procedure AddTransferHash(const Lines: TStringList);
begin
  Lines.Add('function GetTransferHash([string]$path) {');
  Lines.Add('  $file=[IO.File]::Open($path,[IO.FileMode]::Open,[IO.FileAccess]::Read,[IO.FileShare]::Read)');
  Lines.Add('  try {');
  Lines.Add('    $sha=[Security.Cryptography.SHA256]::Create()');
  Lines.Add('    try {');
  Lines.Add('      $buffer=New-Object byte[] (1MB)');
  Lines.Add('      while(($count=$file.Read($buffer,0,$buffer.Length)) -gt 0){');
  Lines.Add('        if(-not [IO.File]::Exists($progressPath)){throw ''transfer_cancelled''}');
  Lines.Add('        [void]$sha.TransformBlock($buffer,0,$count,$buffer,0)');
  Lines.Add('      }');
  Lines.Add('      [void]$sha.TransformFinalBlock($buffer,0,0)');
  Lines.Add('      return ([BitConverter]::ToString($sha.Hash)).Replace(''-'','''').ToLowerInvariant()');
  Lines.Add('    }');
  Lines.Add('    finally {$sha.Dispose()}');
  Lines.Add('  } finally {$file.Dispose()}');
  Lines.Add('}');
end;

// Copy the exact PG18 backup into a new local folder, then publish it in one move.
// Das PG18-Backup in einen neuen lokalen Ordner kopieren und erst danach freigeben.
procedure AddServerBackupDownload(const Lines: TStringList; const RemoteFolder, LocalFolder, RunId: string);
begin
  AddServerProgress(Lines);
  AddTransferHash(Lines);
  Lines.Add('$downloadSource = ' + PsLiteral(RemoteFolder));
  Lines.Add('$downloadParent = ' + PsLiteral(LocalFolder));
  Lines.Add('$runId = ' + PsLiteral(RunId));
  AddRequiredServerBackupFiles(Lines);
  Lines.Add('$optionalFiles = @(' + PsLiteral(ComposeProjectName + '_db_data_18.tar.gz') + ',' +
    PsLiteral(PaperlessSecretKeyFileName) + ',' + PsLiteral(ImageVersionsFileName) + ',' +
    PsLiteral(EmailEnvEncryptedFileName) + ')');
  Lines.Add(' $title=''Server-Backup: Download fehlgeschlagen''');
  Lines.Add(' $step=''Backupordner auf dem Server prüfen''');
  Lines.Add(' $staging=$null');
  Lines.Add(' try {');
  Lines.Add('  SetProgress ''Dateiliste des Server-Backups wird geprüft ...''');
  Lines.Add('  $folderName=$downloadSource.Substring($downloadSource.LastIndexOf(''/'')+1)');
  Lines.Add('  if($folderName -notmatch ''^[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}-[0-9]{2}-[0-9]{2}$''){throw ''backup_folder''}');
  Lines.Add('  $final=[IO.Path]::Combine($downloadParent,$folderName)');
  Lines.Add('  $names=$required+@($optionalFiles)');
  Lines.Add('  $manifest=''set -eu; cd ''+(ShArg $downloadSource)+''; test "$(pwd -P)" = ''+(ShArg $downloadSource)+''; emit_file() { test -f "$1" && test ! -L "$1" || exit 70; bytes=$(stat -c %s -- "$1"); sum=$(sha256sum < "$1"); printf "%s\t%s\t%s\n" "$1" "$bytes" "${sum%% *}"; }; for f in ''+(($required | ForEach-Object {ShArg $_}) -join '' '')+''; do emit_file "$f"; done; for f in ''+(($optionalFiles | ForEach-Object {ShArg $_}) -join '' '')+''; do if [ -e "$f" ] || [ -L "$f" ]; then emit_file "$f"; fi; done''');
  // Record both lengths and hashes before opening local staging files.
  // Vor dem Öffnen lokaler Arbeitsdateien Größe und Prüfsumme erfassen.
  Lines.Add('  $sizes=@{};$hashes=@{}');
  Lines.Add('  foreach($row in ((Text (Ssh $manifest $null 86400000 '''' 0 '''' $true)).TrimEnd("`r","`n") -split ''\r?\n'')){');
  Lines.Add('   $parts=$row.Split([char]9)');
  Lines.Add('   if($parts.Count -ne 3 -or $names -cnotcontains $parts[0] -or $sizes.ContainsKey($parts[0]) -or $parts[1] -notmatch ''^\d+$'' -or $parts[2] -cnotmatch ''^[0-9a-f]{64}$''){throw ''manifest''}');
  Lines.Add('   $sizes[$parts[0]]=[long]::Parse($parts[1],[Globalization.CultureInfo]::InvariantCulture)');
  Lines.Add('   $hashes[$parts[0]]=$parts[2]');
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
  Lines.Add('   $step="SHA-256 von $name prüfen"; SetProgress $step');
  Lines.Add('   if((GetTransferHash $destination) -cne $hashes[$name]){throw ''download_hash''}');
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
  Lines.Add('  elseif($_.Exception.Message -eq ''download_hash''){ $msg="$step`r`nDie Prüfsumme stimmt nicht mit der Angabe des Servers überein." }');
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

// Check capacity before writing and publish a staged upload under its original timestamp.
// Vor dem Schreiben den Speicher prüfen und die vollständige Kopie unter ihrem Zeitstempel freigeben.
// Check the destination before streaming a complete backup into a staging directory.
// Das Ziel vor der Übertragung des vollständigen Backups in einen temporären Ordner prüfen.
procedure AddServerBackupUpload(const Lines: TStringList; const LocalFolder, TargetFolder, RunId: string);
begin
  AddServerProgress(Lines);
  AddTransferHash(Lines);
  AddRequiredServerBackupFiles(Lines);
  Lines.Add('$uploadSource = ' + PsLiteral(LocalFolder));
  Lines.Add('$uploadParent = ' + PsLiteral(TargetFolder));
  Lines.Add('$runId = ' + PsLiteral(RunId));
  Lines.Add(' $title=''Backup zum Server senden: fehlgeschlagen''');
  Lines.Add(' $step=''Lokalen Backupordner prüfen''');
  Lines.Add(' $staging=$null');
  Lines.Add(' try {');
  Lines.Add('  SetProgress ''Dateien des lokalen Backups werden geprüft ...''');
  Lines.Add('  $directory=[IO.DirectoryInfo]::new($uploadSource)');
  Lines.Add('  $folderName=$directory.Name');
  Lines.Add('  if($folderName -notmatch ''^[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}-[0-9]{2}-[0-9]{2}$''){throw ''upload_folder_name''}');
  Lines.Add('  $files=@($directory.GetFileSystemInfos() | Sort-Object Name)');
  Lines.Add('  $names=@($files | ForEach-Object {$_.Name})');
  Lines.Add('  $total=[decimal]0');
  Lines.Add('  foreach($file in $files){');
  Lines.Add('   if($file -isnot [IO.FileInfo] -or ($file.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0){throw ''upload_file_type''}');
  Lines.Add('   $total+=[decimal]$file.Length');
  Lines.Add('  }');
  Lines.Add('  foreach($name in $required){');
  Lines.Add('   if($names -cnotcontains $name -or ([IO.FileInfo]::new([IO.Path]::Combine($uploadSource,$name))).Length -le 0){throw (''upload_missing:''+$name)}');
  Lines.Add('  }');
  Lines.Add('  $requiredBytes=$total+1MB');
  Lines.Add('  $step=''Freien Speicher am Serverziel prüfen''');
  Lines.Add('  SetProgress $step');
  Lines.Add('  $inspect=''cd -P ''+(ShArg $uploadParent)+'' || exit 72; test -w . && test -x . || exit 72; case "$PWD" in /|*[[:cntrl:]]*) exit 73;; esac; printf "%s\n" "$PWD"; df -B1 --output=avail -- .''');
  Lines.Add('  $rows=@((Remote $inspect) -split ''\r?\n'')');
  Lines.Add('  $parent=$rows[0]');
  Lines.Add('  if($parent -notmatch ''^/[^\x00-\x1f]+$''){throw ''upload_parent''}');
  Lines.Add('  $free=ReadFreeBytes (($rows | Select-Object -Skip 1) -join "`n")');
  Lines.Add('  if($free -lt $requiredBytes){throw ''upload_space''}');
  Lines.Add('  if(-not [IO.File]::Exists($progressPath)){throw ''upload_cancelled''}');
  Lines.Add('  $step=''Server-Zielordner vorbereiten''');
  Lines.Add('  $final=$parent+''/''+$folderName');
  Lines.Add('  $candidate=$parent+''/.paperless-upload-''+$runId+''.partial''');
  Lines.Add('  $finalArg=ShArg $final');
  Lines.Add('  $stageArg=ShArg $candidate');
  Lines.Add('  $null=Remote (''if [ -e ''+$finalArg+'' ] || [ -L ''+$finalArg+'' ]; then exit 74; fi; umask 077; mkdir -- ''+$stageArg)');
  Lines.Add('  $staging=$candidate');
  Lines.Add('  $index=0');
  Lines.Add('  foreach($file in $files){');
  Lines.Add('   if(-not [IO.File]::Exists($progressPath)){throw ''upload_cancelled''}');
  Lines.Add('   $index++');
  Lines.Add('   $step="Datei $index/$($files.Count) senden: $($file.Name)"');
  Lines.Add('   SetProgress $step');
  Lines.Add('   $destination=ShArg ($staging+''/''+$file.Name)');
  Lines.Add('   $expected=([long]$file.Length).ToString([Globalization.CultureInfo]::InvariantCulture)');
  Lines.Add('   $hash=GetTransferHash $file.FullName');
  Lines.Add('   $send=''set -eu; test -d ''+$stageArg+'' && test ! -L ''+$stageArg+'' || exit 75; umask 077; set -C; cat > ''+$destination+''; test "$(stat -c %s -- ''+$destination+'')" = ''+$expected+'' || exit 76; sum=$(sha256sum < ''+$destination+''); test "${sum%% *}" = ''+$hash+'' || exit 77''');
  Lines.Add('   $null=Ssh $send $null 86400000 '''' ([long]$file.Length) $file.FullName');
  Lines.Add('  }');
  Lines.Add('  if(-not [IO.File]::Exists($progressPath)){throw ''upload_cancelled''}');
  Lines.Add('  $step=''Vollständigen Backupordner auf dem Server freigeben''');
  Lines.Add('  $publish=''test -d ''+$stageArg+'' && test ! -L ''+$stageArg+'' || exit 75; mv -T -n -- ''+$stageArg+'' ''+$finalArg+'' || exit 75; if [ -e ''+$stageArg+'' ] || [ -L ''+$stageArg+'' ]; then exit 74; fi''');
  Lines.Add('  $null=Remote $publish');
  Lines.Add('  $staging=$null');
  Lines.Add('  $backupCompleted=$true');
  Lines.Add('  $title=''Backup zum Server senden: abgeschlossen''');
  Lines.Add('  $msg="Das Backup wurde auf den Server kopiert.`r`n`r`nServer: $serverHost`r`nZielordner: $final"');
  Lines.Add(' } catch {');
  Lines.Add('  $errorCode=$_.Exception.Message');
  Lines.Add('  if($errorCode -eq ''upload_space''){');
  Lines.Add('   $neededText=([double]($requiredBytes/1GB)).ToString(''N2'')');
  Lines.Add('   $freeText=([double]($free/1GB)).ToString(''N2'')');
  Lines.Add('   $msg="Auf dem Server ist nicht genug Platz für dieses Backup.`r`n`r`nZiel: $uploadParent`r`nBenötigt: $neededText GiB (inkl. Reserve)`r`nVerfügbar: $freeText GiB`r`n`r`nDer Kopiervorgang wurde abgebrochen."');
  Lines.Add('  } elseif($errorCode -eq ''upload_folder_name''){ $msg=''Bitte den Zeitstempelordner eines PG18-Backups auswählen.'' }');
  Lines.Add('  elseif($errorCode -eq ''upload_file_type''){ $msg=''Der Backupordner muss aus regulären Dateien ohne Unterordner oder Verknüpfungen bestehen.'' }');
  Lines.Add('  elseif($errorCode.StartsWith(''upload_missing:'')){ $msg=''Die erforderliche Backupdatei fehlt oder ist leer: ''+$errorCode.Substring(15) }');
  Lines.Add('  elseif($errorCode -eq ''ssh_exit_72''){ $msg=''Der gespeicherte Serverordner fehlt oder ist nicht beschreibbar: ''+$uploadParent }');
  Lines.Add('  elseif($errorCode -eq ''ssh_exit_74''){ $msg="Auf dem Server gibt es bereits einen gleichnamigen Backupordner:`r`n$final" }');
  Lines.Add('  elseif($errorCode -eq ''ssh_exit_76'' -or $errorCode -eq ''upload_length''){ $msg=$step+"`r`nDie Dateigröße stimmt nicht überein." }');
  Lines.Add('  elseif($errorCode -eq ''ssh_exit_77''){ $msg=$step+"`r`nDie SHA-256-Prüfsumme stimmt nicht überein." }');
  Lines.Add('  else { $msg=CheckFailure $step $_.Exception }');
  Lines.Add(' } finally {');
  Lines.Add('  if($staging){');
  Lines.Add('   try {');
  Lines.Add('    $clean=''if [ -d ''+$stageArg+'' ] && [ ! -L ''+$stageArg+'' ]; then find ''+$stageArg+'' -mindepth 1 -maxdepth 1 -type f -delete && rmdir -- ''+$stageArg+''; fi''');
  Lines.Add('    $null=Remote $clean');
  Lines.Add('   } catch { $msg+="`r`n`r`nUnvollständige Dateien können auf dem Server liegen: $staging" }');
  Lines.Add('  }');
  Lines.Add(' }');
end;

// Start the requested server operation with the saved SSH profile.
// Den gewählten Servervorgang mit dem gespeicherten SSH-Profil starten.
// Send the Linux installer over SSH stdin. Credentials are created on Debian.
// Das Linux-Installationsskript über SSH-stdin senden. Zugangsdaten entstehen auf Debian.
procedure AddServerInstallation(const Lines: TStringList);
var
  Versions: TDockerImageVersions;
  ComposeContent: string;
begin
  Versions := Default(TDockerImageVersions);
  Versions.Paperless := DefaultPaperlessVersion;
  Versions.Postgres := DefaultPostgresVersion;
  Versions.Redis := DefaultRedisVersion;
  Versions.Gotenberg := DefaultGotenbergVersion;
  Versions.Tika := DefaultTikaVersion;
  ComposeContent := CreateDockerComposeContent(Versions, './consume', '__PAPERLESS_SECRET_KEY__', 365, True);
  Lines.Add(' $title=''Paperless-Installation fehlgeschlagen''');
  Lines.Add(' $installStep=''SSH-Verbindung aufbauen''');
  Lines.Add(' $installFailure=''''');
  Lines.Add(' $installReady=$false');
  Lines.Add(' $installConfigCreated=$false');
  Lines.Add(' $nl=[Environment]::NewLine');
  Lines.Add(' $logDir=Join-Path $runtimeDir ''Logs''');
  Lines.Add(' $logPath=Join-Path $logDir ([IO.Path]::GetFileNameWithoutExtension($PSCommandPath)+''.log'')');
  Lines.Add(' $log=$null');
  Lines.Add(' try {');
  Lines.Add('  [void][IO.Directory]::CreateDirectory($logDir)');
  Lines.Add('  $log=[IO.StreamWriter]::new([IO.File]::Open($logPath,[IO.FileMode]::CreateNew,[IO.FileAccess]::Write,[IO.FileShare]::Read),[Text.UTF8Encoding]::new($false))');
  Lines.Add('  $log.AutoFlush=$true');
  Lines.Add('  $log.WriteLine("Server: $serverHost")');
  Lines.Add('  $linuxScript=@''');
  Lines.Add('target=' + ServerInstallFolder);
  Lines.Add('project=' + ComposeProjectName);
  Lines.Add('web_port=' + IntToStr(ServerInstallWebPort));
{$I ServerInstallWorker.inc}
  Lines.Add('''@');
  Lines.Add('  $bytes=[Text.Encoding]::UTF8.GetBytes($linuxScript.Replace([string][char]13,'''')+[char]10)');
  // Wait for the explicit completion marker from the installer.
  // Die ausdrückliche Abschlussmarkierung des Installationsskripts abwarten.
  Lines.Add('  $null=Ssh ''bash -s 2>&1'' $bytes 7200000');
  Lines.Add('  if(-not $installReady){throw ''install_incomplete''}');
  Lines.Add('  $urlHost=$serverHost');
  Lines.Add('  $shareHost=$serverHost');
  Lines.Add('  if($serverHost.Contains('':'')){');
  Lines.Add('   $urlHost="[$serverHost]"');
  Lines.Add('   $shareHost=$serverHost.Replace('':'',''-'')+''.ipv6-literal.net''');
  Lines.Add('  }');
  Lines.Add('  $title=''Paperless wurde erfolgreich installiert''');
  Lines.Add('  $msg="Paperless wurde erfolgreich installiert."');
  Lines.Add('  $msg+=$nl+$nl+"Weboberfläche: http://${urlHost}:' + IntToStr(ServerInstallWebPort) + '"');
  Lines.Add('  $msg+=$nl+"Richten Sie den Paperless-Admin beim ersten Aufruf im Browser ein."');
  Lines.Add('  $msg+=$nl+$nl+"Windows-Freigabe: \\$shareHost\paperless-consume"');
  Lines.Add('  $backupCompleted=$true');
  Lines.Add(' } catch {');
  Lines.Add('  if($installFailure){$msg=$installFailure}else{$msg=CheckFailure $installStep $_.Exception}');
  Lines.Add('  if($_.Exception.Message -eq ''ssh_exit_255''){');
  Lines.Add('   $msg+=$nl+"Prüfen Sie die Serverdaten und den bestätigten SSH-Fingerabdruck unter Verbindung testen."');
  Lines.Add('  }');
  Lines.Add('  if($installConfigCreated){$msg+=$nl+''Die Compose-Datei liegt bereits unter ' + ServerInstallFolder + '. Prüfen Sie den letzten Schritt in der Logdatei.''}');
  Lines.Add('  if($log){$log.WriteLine($msg)}');
  Lines.Add(' } finally {');
  Lines.Add('  if($log){$log.Dispose();$msg+=$nl+$nl+"Logdatei: $logPath"}');
  Lines.Add(' }');
end;

procedure StartServerBackup(out ProcessHandle: THandle; out ResultPath: string;
  const BackupFolder: string; Action: TServerBackupAction; const LocalDownloadFolder: string);
var
  Ini: TAppSettingsIni;
  SettingsPath, Host, UserName, KeyFile, Auth, ComposeFile, Project, SavedBackupFolder: string;
  ScriptPath, ServerDir, PowerShellPath, CommandLine, RunId: string;
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
    if (Action = sbaInstallPaperless) and (UserName <> 'root') then
      raise Exception.Create('Für die Installation muss der SSH-Benutzer root gespeichert sein.');
    if not IsValidHost(Host) or not IsValidUser(UserName) then
      raise Exception.Create('Bitte gültigen Server und Benutzernamen speichern.');
    if (((BackupFolder = '') and (Action = sbaCheckSpace)) or
        (Action in [sbaStartBackup, sbaStartRestore, sbaWatchRestore])) and
       ((ComposeFile = '') or not ComposeFile.StartsWith('/') or HasControlChars(ComposeFile) or HasControlChars(Project)) then
      raise Exception.Create('Bitte einen gültigen absoluten Compose-Ordner speichern.');
    if SameText(Auth, 'SSH-Key') then UseKey := True
    else if SameText(Auth, 'Passwort') then UseKey := False
    else raise Exception.Create('Die gespeicherte Anmeldeart ist ungültig.');
    if UseKey and ((KeyFile = '') or not FileExists(KeyFile)) then
      raise Exception.Create('Die gespeicherte SSH-Key-Datei wurde nicht gefunden.');
    if not UseKey and (ReadServerSecret(SettingsPath, 'Passwort') = '') then
      raise Exception.Create('Bitte zuerst das SSH-Passwort speichern.');

    if Action in [sbaStartBackup, sbaListBackups, sbaUploadBackup, sbaListRestoreBackups,
      sbaStartRestore] then
      SavedBackupFolder := NormalizeServerBackupFolder(SavedBackupFolder);
    if (Action = sbaDownloadBackup) and not TDirectory.Exists(LocalDownloadFolder) then
      raise Exception.Create('Der gewählte Windows-Zielordner ist nicht vorhanden.');
    if (Action = sbaUploadBackup) and not TDirectory.Exists(LocalDownloadFolder) then
      raise Exception.Create('Der gewählte lokale Backupordner ist nicht vorhanden.');
    // Use the run ID for temporary result and progress files and for server-side workspaces.
    // Die Lauf-ID für temporäre Ergebnis- und Fortschrittsdateien sowie serverseitige Arbeitsordner verwenden.
    RunId := StringReplace(StringReplace(TGUID.NewGuid.ToString, '{', '', []), '}', '', []);
    // Keep the generated script of each invocation in the Server directory.
    // Das erzeugte Skript jedes Aufrufs im Ordner Server aufbewahren.
    ServerDir := TPath.Combine(ExtractFilePath(SettingsPath), 'Server');
    if not TDirectory.Exists(ExtractFilePath(SettingsPath)) then
      raise Exception.Create('Der Laufzeitordner des Programms ist nicht vorhanden.');
    TDirectory.CreateDirectory(ServerDir);
    ServerDirAttributes := GetFileAttributes(PChar(ServerDir));
    if (ServerDirAttributes = INVALID_FILE_ATTRIBUTES) or
       ((ServerDirAttributes and FILE_ATTRIBUTE_REPARSE_POINT) <> 0) then
      raise Exception.Create('Der Server-Ordner muss ein direktes Verzeichnis im Laufzeitordner sein.');
    ResultPath := TPath.Combine(TPath.GetTempPath, 'paperless-server-' + RunId + '.result');
    TFile.WriteAllText(ResultPath, '', TEncoding.UTF8);
    if Action in ServerWorkerActions then
      TFile.WriteAllBytes(ResultPath + '.progress', nil)
    else if Action <> sbaCheckSpace then
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
      Lines.Add('function Ssh([string]$cmd,[byte[]]$inputBytes,[int]$timeoutMs=120000,[string]$outputPath,[long]$expectedBytes=0,[string]$inputPath,[bool]$monitorProgress=$false) {');
      Lines.Add(' $si=New-Object Diagnostics.ProcessStartInfo; $si.FileName=(Get-Command ssh.exe -ErrorAction Stop).Source');
      Lines.Add(' $a=@(''-T'',''-o'',''StrictHostKeyChecking=yes'',''-o'',''UpdateHostKeys=no'',''-o'',''ConnectTimeout=10'',''-o'',''NumberOfPasswordPrompts=1'',''-p'',$port,''-l'',$serverUser)');
      Lines.Add(' if($useKey){$a+=@(''-o'',''IdentitiesOnly=yes'',''-i'',$keyFile)}else{$a+=@(''-o'',''PreferredAuthentications=password'',''-o'',''PubkeyAuthentication=no'')}');
      Lines.Add(' if($outputPath -or $inputPath -or $monitorProgress){$a+=@(''-o'',''ServerAliveInterval=15'',''-o'',''ServerAliveCountMax=3'')}');
      if Action = sbaInstallPaperless then
        Lines.Add(' $a+=@(''-o'',''ServerAliveInterval=15'',''-o'',''ServerAliveCountMax=3'')');
      Lines.Add(' $a+=@($serverHost,$cmd);$si.Arguments=(($a|ForEach-Object{WinArg $_}) -join '' '')');
      Lines.Add(' $si.UseShellExecute=$false;$si.CreateNoWindow=$true;$si.RedirectStandardOutput=$true;$si.RedirectStandardError=$true;$si.RedirectStandardInput=$true');
      if Action = sbaInstallPaperless then
        Lines.Add(' $si.StandardOutputEncoding=[Text.Encoding]::UTF8;$si.StandardErrorEncoding=[Text.Encoding]::UTF8');
// Stream backup files directly to a new file and keep the bounded memory path for metadata.
// Backupdateien direkt in eine neue Datei schreiben und Metadaten weiter im Speicher lesen.
      Lines.Add(' $p=New-Object Diagnostics.Process;$p.StartInfo=$si;$m=$null;$source=$null;$started=$false');
      Lines.Add(' try {');
      Lines.Add('  if($outputPath){$m=[IO.File]::Open($outputPath,[IO.FileMode]::CreateNew,[IO.FileAccess]::Write,[IO.FileShare]::Read)}');
      Lines.Add('  else{$m=New-Object IO.MemoryStream}');
      Lines.Add('  if($inputPath){');
      Lines.Add('   if(([IO.File]::GetAttributes($inputPath) -band [IO.FileAttributes]::ReparsePoint) -ne 0){throw ''upload_file_type''}');
      Lines.Add('   $source=[IO.File]::Open($inputPath,[IO.FileMode]::Open,[IO.FileAccess]::Read,[IO.FileShare]::Read)');
      Lines.Add('   if($source.Length -ne $expectedBytes){throw ''upload_length''}');
      Lines.Add('  }');
      Lines.Add('  if(-not $p.Start()){throw ''ssh_start''}');
      Lines.Add('  $started=$true');
      Lines.Add('  $err=$p.StandardError.ReadToEndAsync()');
      if Action <> sbaInstallPaperless then
        Lines.Add('  $out=$p.StandardOutput.BaseStream.CopyToAsync($m)');
      // Stream local archives through SSH stdin with a progress-based timeout.
      // Lokale Archive über SSH-stdin streamen und bei Stillstand abbrechen.
      Lines.Add('  if($source){');
      Lines.Add('   $watch=[Diagnostics.Stopwatch]::StartNew();$sent=0');
      Lines.Add('   $write=$source.CopyToAsync($p.StandardInput.BaseStream)');
      Lines.Add('   while(-not $write.Wait(1000)){');
      Lines.Add('    if(-not [IO.File]::Exists($progressPath)){throw ''upload_cancelled''}');
      Lines.Add('    if($p.HasExited){throw (''ssh_exit_''+$p.ExitCode)}');
      Lines.Add('    $position=$source.Position');
      Lines.Add('    if($position -gt $sent){');
      Lines.Add('     $sent=$position;$watch.Restart()');
      Lines.Add('     if($expectedBytes -gt 0){SetProgress ("$step ("+[math]::Floor(100.0*$sent/$expectedBytes)+" %)")}');
      Lines.Add('    } elseif($watch.ElapsedMilliseconds -ge 300000){throw ''ssh_timeout''}');
      Lines.Add('   }');
      Lines.Add('   if($source.Position -ne $expectedBytes){throw ''upload_length''}');
      Lines.Add('  } elseif($inputBytes){');
      Lines.Add('   $write=$p.StandardInput.BaseStream.WriteAsync($inputBytes,0,$inputBytes.Length)');
      Lines.Add('   if(-not $write.Wait(120000)){throw ''ssh_timeout''}');
      Lines.Add('  }');
      Lines.Add('  $p.StandardInput.Close()');
      // Measure download progress and use an idle timeout so large active transfers can finish.
      // Downloadfortschritt messen und nur bei Stillstand abbrechen, damit große aktive Übertragungen fertig werden.
      if Action = sbaInstallPaperless then
      begin
        // Read installation output live and keep detailed command output in the log.
        // Installationsausgabe live lesen und technische Befehlsausgabe in der Logdatei behalten.
        Lines.Add('  $watch=[Diagnostics.Stopwatch]::StartNew()');
        Lines.Add('  while($true){');
        Lines.Add('   $remaining=[int][math]::Max(1,$timeoutMs-$watch.ElapsedMilliseconds)');
        Lines.Add('   $lineTask=$p.StandardOutput.ReadLineAsync()');
        Lines.Add('   if(-not $lineTask.Wait($remaining)){throw ''ssh_timeout''}');
        Lines.Add('   $line=$lineTask.Result;if($null -eq $line){break}');
        Lines.Add('   $log.WriteLine($line)');
        Lines.Add('   if($line.StartsWith(''PAPERLESS_STEP:'')){');
        Lines.Add('    $script:installStep=$line.Substring(15);SetProgress $script:installStep');
        Lines.Add('   }elseif($line.StartsWith(''PAPERLESS_ERROR:'')){$script:installFailure=$line.Substring(16)}');
        Lines.Add('   elseif($line -eq ''PAPERLESS_CONFIG_CREATED''){$script:installConfigCreated=$true}');
        Lines.Add('   elseif($line -eq ''PAPERLESS_INSTALL_COMPLETE''){$script:installReady=$true}');
        Lines.Add('  }');
        Lines.Add('  if(-not $p.WaitForExit(10000) -or -not $err.Wait(10000)){throw ''ssh_timeout''}');
        Lines.Add('  if($err.Result){$log.WriteLine($err.Result.Trim())}');
      end
      else
      begin
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
        Lines.Add('  } elseif($inputPath -or $monitorProgress){');
        Lines.Add('   $watch=[Diagnostics.Stopwatch]::StartNew()');
        Lines.Add('   while(-not $p.WaitForExit(1000)){');
        Lines.Add('    if(-not [IO.File]::Exists($progressPath)){throw ''transfer_cancelled''}');
        Lines.Add('    if($out.IsFaulted){$out.GetAwaiter().GetResult()}');
        Lines.Add('    if($watch.ElapsedMilliseconds -ge $timeoutMs){throw ''ssh_timeout''}');
        Lines.Add('   }');
        Lines.Add('  } elseif(-not $p.WaitForExit($timeoutMs)){throw ''ssh_timeout''}');
        Lines.Add('  if(-not $out.Wait(10000) -or -not $err.Wait(10000)){throw ''ssh_read''}');
      end;
      Lines.Add('  if($p.ExitCode -ne 0){throw (''ssh_exit_''+$p.ExitCode)}');
      Lines.Add('  if($outputPath){$m.Flush();if($m.Length -ne $expectedBytes){throw ''download_length''};return}');
      Lines.Add('  if($m.Length -gt 16777216){throw ''size''}');
      Lines.Add('  return ,$m.ToArray()');
      Lines.Add(' } finally {');
      Lines.Add('  if($started -and -not $p.HasExited){try{$p.Kill();[void]$p.WaitForExit(2000)}catch{}}');
      Lines.Add('  if($source){$source.Dispose()}');
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
      if Action = sbaInstallPaperless then
      begin
        AddServerProgress(Lines);
        AddServerInstallation(Lines);
      end
      else if Action = sbaUploadBackup then
        AddServerBackupUpload(Lines, ExpandFileName(LocalDownloadFolder), SavedBackupFolder, RunId)
      else if Action in [sbaListBackups, sbaListRestoreBackups] then
        AddServerBackupList(Lines, SavedBackupFolder)
      else if Action = sbaDownloadBackup then
        AddServerBackupDownload(Lines, NormalizeServerBackupFolder(BackupFolder),
          ExpandFileName(LocalDownloadFolder), RunId)
      else if Action = sbaStartRestore then
        AddDockerRestoreRun(Lines, Action, SavedBackupFolder, NormalizeServerBackupFolder(BackupFolder), RunId)
      else if Action = sbaWatchRestore then
        AddDockerRestoreRun(Lines, Action, '', '', RunId)
      else if Action in [sbaStartBackup, sbaWatchBackup] then
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
      if Action in [sbaStartRestore, sbaWatchRestore] then
        Lines.Add(' if(-not $backupCompleted){$msg+="`r`n`r`nPowerShell-Skript: $PSCommandPath"}')
      else if Action <> sbaInstallPaperless then
        Lines.Add(' $msg+="`r`n`r`nPowerShell-Skript: $PSCommandPath"');
      Lines.Add(' $json=@{ title=$title; message=$msg; backupCompleted=$backupCompleted; completedBackupFolder=$completedBackupFolder; availableBackupFolders=$availableBackupFolders } | ConvertTo-Json -Compress');
      Lines.Add(' $resultBytes=[Text.Encoding]::UTF8.GetBytes($json)');
      Lines.Add(' try {');
      Lines.Add('  $resultFile=[IO.File]::Open($resultPath,[IO.FileMode]::Open,[IO.FileAccess]::Write,[IO.FileShare]::Delete)');
      Lines.Add('  try {$resultFile.Write($resultBytes,0,$resultBytes.Length);$resultFile.SetLength($resultBytes.Length)}finally{$resultFile.Dispose()}');
      Lines.Add(' } catch [IO.FileNotFoundException] {}');
      Lines.Add('}');
      // Reserve the timestamp in Server and account for any existing log with that timestamp.
      // Den Zeitstempel in Server reservieren und vorhandene Logs mit demselben Zeitstempel berücksichtigen.
      ScriptPath := ReserveTimestampedScript(ServerDir, TPath.Combine(ExtractFilePath(SettingsPath), 'Logs'));
      try
        Lines.SaveToFile(ScriptPath, TEncoding.UTF8);
      except
        DeleteFile(ScriptPath);
        raise;
      end;
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