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

procedure StartServerBackup;

implementation

uses
  Winapi.Windows, Winapi.ShellAPI, System.SysUtils, System.Classes, System.IOUtils,
  Vcl.Forms, AppConfig, AppDialogs, ExternPaperless;

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

// Start the read-only space estimate; server backup and restore are not implemented yet.
// Die lesende Speicherplatzschaetzung starten; Server-Backup und Restore sind noch nicht implementiert.
procedure StartServerBackup;
var
  Ini: TAppSettingsIni;
  SettingsPath, Host, UserName, KeyFile, Auth, ComposeFile, Project: string;
  ScriptPath, PowerShellPath, Params: string;
  Lines: TStringList;
  PortNumber: Integer;
  UseKey: Boolean;
  LaunchResult: HINST;
begin
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
    finally
      Ini.Free;
    end;
    if not IsValidHost(Host) or not IsValidUser(UserName) then
      raise Exception.Create('Bitte gültigen Server und Benutzernamen speichern.');
    if (ComposeFile = '') or (ComposeFile[1] <> '/') or HasControlChars(ComposeFile) or HasControlChars(Project) then
      raise Exception.Create('Bitte einen gültigen absoluten Compose-Ordner speichern.');
    if SameText(Auth, 'SSH-Key') then UseKey := True
    else if SameText(Auth, 'Passwort') then UseKey := False
    else raise Exception.Create('Die gespeicherte Anmeldeart ist ungültig.');
    if UseKey and ((KeyFile = '') or not FileExists(KeyFile)) then
      raise Exception.Create('Die gespeicherte SSH-Key-Datei wurde nicht gefunden.');
    if not UseKey and (ReadServerSecret(SettingsPath, 'Passwort') = '') then
      raise Exception.Create('Bitte zuerst das SSH-Passwort speichern.');

    ScriptPath := TPath.Combine(TPath.GetTempPath, 'paperless-server-space-' + TGUID.NewGuid.ToString + '.ps1');
    Lines := TStringList.Create;
    try
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
      Lines.Add('function Ssh([string]$cmd,[byte[]]$inputBytes) {');
      Lines.Add(' $si=New-Object Diagnostics.ProcessStartInfo; $si.FileName=(Get-Command ssh.exe -ErrorAction Stop).Source');
      Lines.Add(' $a=@(''-T'',''-o'',''StrictHostKeyChecking=yes'',''-o'',''UpdateHostKeys=no'',''-o'',''ConnectTimeout=10'',''-o'',''NumberOfPasswordPrompts=1'',''-p'',$port,''-l'',$serverUser)');
      Lines.Add(' if($useKey){$a+=@(''-o'',''IdentitiesOnly=yes'',''-i'',$keyFile)}else{$a+=@(''-o'',''PreferredAuthentications=password'',''-o'',''PubkeyAuthentication=no'')}');
      Lines.Add(' $a+=@($serverHost,$cmd);$si.Arguments=(($a|ForEach-Object{WinArg $_}) -join '' '')');
      Lines.Add(' $si.UseShellExecute=$false;$si.CreateNoWindow=$true;$si.RedirectStandardOutput=$true;$si.RedirectStandardError=$true;$si.RedirectStandardInput=$true');
      Lines.Add(' $p=New-Object Diagnostics.Process;$p.StartInfo=$si;$m=New-Object IO.MemoryStream');
      Lines.Add(' try {');
      Lines.Add('  if(-not $p.Start()){throw ''ssh_start''}');
      Lines.Add('  $err=$p.StandardError.ReadToEndAsync();$out=$p.StandardOutput.BaseStream.CopyToAsync($m)');
      Lines.Add('  if($inputBytes){$write=$p.StandardInput.BaseStream.WriteAsync($inputBytes,0,$inputBytes.Length);if(-not $write.Wait(120000)){try{$p.Kill()}catch{};throw ''ssh_timeout''}}');
      Lines.Add('  $p.StandardInput.Close()');
      Lines.Add('  if(-not $p.WaitForExit(120000)){try{$p.Kill()}catch{};throw ''ssh_timeout''}');
      Lines.Add('  if(-not $out.Wait(10000) -or -not $err.Wait(10000)){throw ''ssh_read''}');
      Lines.Add('  if($p.ExitCode -ne 0){throw ''ssh_failed''}');
      Lines.Add('  if($m.Length -gt 16777216){throw ''size''}');
      Lines.Add('  return ,$m.ToArray()');
      Lines.Add(' } finally {$m.Dispose();$p.Dispose()}');
      Lines.Add('}');
      Lines.Add('function Text([byte[]]$b){$utf8=New-Object Text.UTF8Encoding($false,$true);return $utf8.GetString($b).TrimStart([char]0xFEFF)}');
      Lines.Add('function Remote([string]$cmd){return Text (Ssh $cmd $null)}');
      Lines.Add('try {');
      Lines.Add(' Add-Type -AssemblyName System.Windows.Forms');
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
      Lines.Add(' $raw=Ssh (''cat -- ''+(ShArg $composeFile)) $null');
      Lines.Add(' if($raw.Length -eq 0){throw ''empty''}');
      Lines.Add(' $local=Join-Path $privateDir ''docker-compose.yml''');
      Lines.Add(' $f=New-Object IO.FileStream($local,[IO.FileMode]::CreateNew,[IO.FileAccess]::Write,[IO.FileShare]::None)');
      Lines.Add(' try{$f.Write($raw,0,$raw.Length);$f.Flush()}finally{$f.Dispose()}');
      Lines.Add(' $localBytes=[IO.File]::ReadAllBytes($local);$localText=Text $localBytes');
      Lines.Add(' if([string]::IsNullOrWhiteSpace($localText)){throw ''empty''}');
      Lines.Add(' $sha=[Security.Cryptography.SHA256]::Create()');
      Lines.Add(' try{$hash=([BitConverter]::ToString($sha.ComputeHash($localBytes))).Replace(''-'','''').ToLowerInvariant()}finally{$sha.Dispose()}');
      Lines.Add(' $remoteHash=(Remote (''sha256sum -- ''+(ShArg $composeFile))).Trim().Split('' '')[0].ToLowerInvariant()');
      Lines.Add(' if($remoteHash -notmatch ''^[0-9a-f]{64}$'' -or $hash -ne $remoteHash){throw ''changed''}');
      Lines.Add(' $context=(Remote ''case x${DOCKER_HOST-} in x|xunix:///*) :;; *) exit 95;; esac; docker context inspect'');$context=$context|ConvertFrom-Json');
      Lines.Add(' if(-not $context -or -not $context[0].Endpoints.docker.Host.StartsWith(''unix:///'')){throw ''docker_remote''}');
      Lines.Add(' $dir=$composeFile.Substring(0,$composeFile.LastIndexOf(''/''));if(-not $dir){$dir=''/''}');
// Normalize the locally read bytes on the server and parse the JSON in local memory.
// Die lokal gelesenen Bytes auf dem Server aufloesen und das JSON lokal im Speicher auswerten.
      Lines.Add(' $cmd=''cd ''+(ShArg $dir)+'' && docker compose --project-directory ''+(ShArg $dir)+'' -f -''');
      Lines.Add(' if($project){$cmd+='' -p ''+(ShArg $project)}');
      Lines.Add(' $model=(Text (Ssh ($cmd+'' config --format json'') $localBytes))|ConvertFrom-Json');
      Lines.Add(' if(-not $model.services){throw ''services''}');
// Resolve supported volume and bind sources; reject unsupported or inaccessible paths.
// Unterstuetzte Volume- und Bind-Quellen aufloesen; nicht unterstuetzte oder unzugaengliche Pfade ablehnen.
      Lines.Add(' $paths=New-Object ''System.Collections.Generic.HashSet[string]'' ([StringComparer]::Ordinal)');
      Lines.Add(' foreach($service in $model.services.PSObject.Properties){foreach($mount in $service.Value.volumes){');
      Lines.Add('  if($null -eq $mount){continue};$source=[string]$mount.source');
      Lines.Add('  if([string]$mount.type -eq ''tmpfs''){continue}');
      Lines.Add('  switch([string]$mount.type){');
      Lines.Add('   ''bind''{$path=$source}');
      Lines.Add('   ''volume''{');
      Lines.Add('    if(-not $source -or -not $model.volumes){throw ''volume''}');
      Lines.Add('    $prop=$model.volumes.PSObject.Properties[$source];if(-not $prop -or -not $prop.Value.name){throw ''volume''}');
      Lines.Add('    $info=(Remote (''docker volume inspect -- ''+(ShArg ([string]$prop.Value.name))))|ConvertFrom-Json');
      Lines.Add('    if(-not $info -or $info[0].Driver -ne ''local''){throw ''driver''}');
      Lines.Add('    if($info[0].Options -and @($info[0].Options.PSObject.Properties).Count -gt 0){throw ''driver''}');
      Lines.Add('    $path=[string]$info[0].Mountpoint');
      Lines.Add('   }');
      Lines.Add('   default{throw ''mount''}');
      Lines.Add('  }');
      Lines.Add('  if(-not $path -or -not $path.StartsWith(''/'') -or $path.IndexOfAny([char[]]"`r`n") -ge 0){throw ''path''}');
      Lines.Add('  $path=(Remote (''realpath -e -- ''+(ShArg $path))).TrimEnd("`r","`n")');
      Lines.Add('  if(-not $path.StartsWith(''/'') -or $path -eq ''/'' -or $path.IndexOfAny([char[]]"`r`n") -ge 0){throw ''path''}');
      Lines.Add('  [void]$paths.Add($path)');
      Lines.Add(' }}');
      Lines.Add(' if($paths.Count -eq 0){throw ''paths''}');
// Avoid counting nested paths twice and estimate source size and available space.
// Verschachtelte Pfade nicht doppelt zaehlen und Quellgroesse sowie freien Speicherplatz schaetzen.
      Lines.Add(' $chosen=New-Object ''System.Collections.Generic.List[string]''');
      Lines.Add(' foreach($path in ($paths|Sort-Object Length)){');
      Lines.Add('  $covered=$false;foreach($parent in $chosen){if($path.Equals($parent,[StringComparison]::Ordinal) -or $path.StartsWith($parent+''/'',[StringComparison]::Ordinal)){$covered=$true;break}}');
      Lines.Add('  if(-not $covered){$chosen.Add($path)}');
      Lines.Add(' }');
      Lines.Add(' [long]$total=0');
      Lines.Add(' foreach($path in $chosen){$v=Remote (''du -sb -- ''+(ShArg $path));if($v -notmatch ''^(\d+)\s''){throw ''du''};$n=[long]::Parse($matches[1],[Globalization.CultureInfo]::InvariantCulture);if($total -gt [long]::MaxValue-$n){throw ''overflow''};$total+=$n}');
      Lines.Add(' $out=(Remote (''df -B1 --output=avail -- ''+(ShArg $dir))).Trim();$rows=@($out -split ''\r?\n'')');
      Lines.Add(' if($rows.Count -ne 2 -or $rows[1].Trim() -notmatch ''^\d+$''){throw ''df''}');
      Lines.Add(' [long]$free=[long]::Parse($rows[1].Trim(),[Globalization.CultureInfo]::InvariantCulture)');
      Lines.Add(' $remoteHash=(Remote (''sha256sum -- ''+(ShArg $composeFile))).Trim().Split('' '')[0].ToLowerInvariant();if($hash -ne $remoteHash){throw ''changed''}');
      Lines.Add(' $msg="Gespeichertes Serverprofil: $serverHost`r`nCompose-Ordner: $dir`r`n`r`nGeschätzte Größe der zu sichernden Daten: $(([double]$total/1GB).ToString(''N2'')) GiB`r`nFreier Speicher auf dem Dateisystem des Compose-Ordners: $(([double]$free/1GB).ToString(''N2'')) GiB`r`n`r`nDies ist eine grobe Schätzung. Das Backupziel ist noch nicht festgelegt; auf einem anderen Dateisystem muss erneut geprüft werden. Es wurde kein Backup gestartet."');
      Lines.Add(' [Windows.Forms.MessageBox]::Show($msg,''Server-Backup: Speicherplatz'',''OK'',''Warning'')|Out-Null');
      Lines.Add('}catch{');
      Lines.Add(' $why=''Bitte SSH-Verbindung, bestätigten Fingerabdruck, Docker Compose und Zugriffsrechte prüfen. Die verwendeten Speicherpfade müssen lesbar sein.''');
      Lines.Add(' if($_.Exception.Message -eq ''changed''){$why=''Die Compose-Datei wurde während der Prüfung geändert. Bitte erneut prüfen.''}');
      Lines.Add(' if($_.Exception.Message -eq ''runtime'' -or $_.Exception.Message -eq ''server_link'' -or $_.Exception.Message -eq ''acl''){$why=''Der geschützte Server-Arbeitsordner konnte nicht sicher angelegt werden.''}');
      Lines.Add(' [Windows.Forms.MessageBox]::Show("Der Speicherplatz konnte nicht zuverlässig ermittelt werden.`r`nServer: $serverHost`r`n`r`n$why`r`n`r`nEs wurde kein Backup gestartet.",''Server-Backup: Prüfung fehlgeschlagen'',''OK'',''Warning'')|Out-Null');
// Remove the temporary Compose copy and warn if cleanup fails.
// Die temporaere Compose-Kopie entfernen und bei fehlgeschlagener Bereinigung warnen.
      Lines.Add('}finally{');
      Lines.Add(' $cleanupFailed=$false');
      Lines.Add(' if($local -and [IO.File]::Exists($local)){try{[IO.File]::Delete($local)}catch{$cleanupFailed=$true}}');
      Lines.Add(' if($privateDir -and [IO.Directory]::Exists($privateDir)){try{[IO.Directory]::Delete($privateDir,$false)}catch{$cleanupFailed=$true}}');
      Lines.Add(' if($cleanupFailed){try{[Windows.Forms.MessageBox]::Show("Die temporäre Compose-Kopie oder ihr Arbeitsordner konnte nicht gelöscht werden. Bitte prüfen Sie den Ordner:`r`n$privateDir",''Server-Backup: Bereinigung'',''OK'',''Warning'')|Out-Null}catch{}}');
      Lines.Add(' Remove-Item -LiteralPath $PSCommandPath -Force -ErrorAction SilentlyContinue');
      Lines.Add('}');
      Lines.SaveToFile(ScriptPath, TEncoding.UTF8);
    finally
      Lines.Free;
    end;
    PowerShellPath := IncludeTrailingPathDelimiter(GetEnvironmentVariable('WINDIR')) +
      'System32\WindowsPowerShell\v1.0\powershell.exe';
    if not FileExists(PowerShellPath) then PowerShellPath := 'powershell.exe';
    Params := '-NoProfile -ExecutionPolicy Bypass -File "' + ScriptPath + '"';
    LaunchResult := ShellExecute(Application.Handle, 'open', PChar(PowerShellPath), PChar(Params), nil, SW_HIDE);
    if NativeInt(LaunchResult) <= 32 then
    begin
      DeleteFile(ScriptPath);
      raise Exception.Create('Der Prozess zur Speicherplatzprüfung konnte nicht gestartet werden.');
    end;
  except
    on E: Exception do
      CenteredShowMessage('Server-Backup: ' + E.Message);
  end;
end;

end.