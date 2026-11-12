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

unit ExternalStartupCheck;

interface

uses Winapi.Windows;

procedure StartExternalStartupCheck(const Host, UserName: string; PortNumber: Integer;
  const KeyFile, SettingsPath, ExePath: string; UseKey, ConfirmFingerprint: Boolean;
  out ProcessHandle: THandle; out ResultPath: string);

implementation

uses System.SysUtils, System.Classes, System.IOUtils, AppConfig;

// Quote a value as a PowerShell single-quoted literal.
// Einen Wert als einfach zitiertes PowerShell-Literal maskieren.
function PsLiteral(const Value: string): string;
begin
  Result := #39 + StringReplace(Value, #39, #39#39, [rfReplaceAll]) + #39;
end;

// Start the background SSH test and return its process handle and result-file path.
// Den SSH-Test im Hintergrund starten und Prozesshandle sowie Ergebnisdateipfad zurueckgeben.
procedure StartExternalStartupCheck(const Host, UserName: string; PortNumber: Integer;
  const KeyFile, SettingsPath, ExePath: string; UseKey, ConfirmFingerprint: Boolean;
  out ProcessHandle: THandle; out ResultPath: string);
var
  ScriptPath, Cmd, WorkDir, PowerShellPath: string;
  Lines: TStringList;
  SI: TStartupInfo;
  PI: TProcessInformation;
  ErrorCode: DWORD;
begin
  ProcessHandle := 0;
  ResultPath := '';
  WorkDir := ExtractFilePath(SettingsPath);
  Lines := TStringList.Create;
  try
    Lines.Add('$ErrorActionPreference = ''Stop''');
    Lines.Add('$result = ''unknown''');
    if ConfirmFingerprint then Lines.Add('$confirmFingerprint = $true')
    else Lines.Add('$confirmFingerprint = $false');
    Lines.Add('$tempKeys = $PSCommandPath + ''.hosts''');
    Lines.Add('$savedKeys = Join-Path $env:USERPROFILE ''.ssh\known_hosts''');
    Lines.Add('$env:PAPERLESS_SSH_HELPER = ''1''');
    Lines.Add('$env:PAPERLESS_SSH_SETTINGS = ' + PsLiteral(SettingsPath));
    if UseKey then Lines.Add('$env:PAPERLESS_SSH_AUTH = ''key''')
    else Lines.Add('$env:PAPERLESS_SSH_AUTH = ''password''');
    Lines.Add('$env:SSH_ASKPASS = ' + PsLiteral(ExePath));
    Lines.Add('$env:SSH_ASKPASS_REQUIRE = ''force''');
    Lines.Add('$env:DISPLAY = ''paperless:0''');
    Lines.Add('$serverHost = ' + PsLiteral(Host));
    Lines.Add('$serverUser = ' + PsLiteral(UserName));
    Lines.Add('$port = ' + PsLiteral(IntToStr(PortNumber)));
    Lines.Add('$workDir = ' + PsLiteral(WorkDir));
    Lines.Add('$resultPath = $PSCommandPath + ''.result''');
    Lines.Add('$cancelPath = $resultPath + ''.cancel''');
    Lines.Add('function Assert-Active { if (Test-Path -LiteralPath $cancelPath) { throw ''cancelled'' } }');
// Require a known host key and configure the chosen authentication method.
// Einen bekannten Hostschluessel verlangen und die gewaehlte Anmeldeart konfigurieren.
    Lines.Add('$baseArgs = @(''-o'', ''StrictHostKeyChecking=yes'', ''-o'', ''UpdateHostKeys=no'', ''-o'', ''ConnectTimeout=10'', ''-o'', ''NumberOfPasswordPrompts=1'', ''-p'', $port, ''-l'', $serverUser)');
    if UseKey then
      Lines.Add('$baseArgs += @(''-o'', ''IdentitiesOnly=yes'', ''-i'', ' + PsLiteral(KeyFile) + ')')
    else
      Lines.Add('$baseArgs += @(''-o'', ''PreferredAuthentications=password'', ''-o'', ''PubkeyAuthentication=no'')');
    Lines.Add('function Invoke-Check([string]$hostFile,[string]$confirmedFingerprints) {');
    Lines.Add('  Assert-Active');
    Lines.Add('  $a = @($baseArgs)');
    Lines.Add('  if ($hostFile) { $a += @(''-o'', (''UserKnownHostsFile="'' + $hostFile + ''"''), ''-o'', ''GlobalKnownHostsFile=none'') }');
    Lines.Add('  if ($confirmedFingerprints) { $a += ''-v'' }');
    Lines.Add('  $a += @($serverHost, ''true'')');
    Lines.Add('  $old = $ErrorActionPreference; $ErrorActionPreference = ''Continue''');
    Lines.Add('  try { $output = & ssh.exe @a 2>&1; $code = $LASTEXITCODE } finally { $ErrorActionPreference = $old }');
    Lines.Add('  $detail = ($output | ForEach-Object { $_.ToString() }) -join [Environment]::NewLine');
    Lines.Add('  Assert-Active');
    Lines.Add('  if ($code -eq 0) {');
    Lines.Add('    if ($confirmedFingerprints) {');
    Lines.Add('      $negotiated = [regex]::Matches($detail, ''(?m)^debug1: Server host key: \S+ (SHA256:\S+)'')');
    Lines.Add('      if (-not $negotiated.Count) { return ''hostkey'' }');
    Lines.Add('      $hash = $negotiated[$negotiated.Count-1].Groups[1].Value');
    Lines.Add('      if ($hash -cnotin ($confirmedFingerprints -split ''\s+'')) { return ''changed_host'' }');
    Lines.Add('    }');
    Lines.Add('    return ''success''');
    Lines.Add('  }');
    Lines.Add('  if ($detail -match ''REMOTE HOST IDENTIFICATION HAS CHANGED|Host key .* has changed|Offending .* key'') { return ''changed_host'' }');
    Lines.Add('  if ($detail -match ''No .* host key is known|no matching host key is known'') { return ''unknown_host'' }');
    Lines.Add('  if ($detail -match ''Host key verification failed'') { return ''hostkey'' }');
    Lines.Add('  if ($detail -match ''Permission denied|Authentication failed'') { return ''auth'' }');
    Lines.Add('  if ($detail -match ''Connection timed out|Connection refused|No route to host|Could not resolve hostname|Name or service not known|Network is unreachable'') { return ''unreachable'' }');
    Lines.Add('  return ''unknown''');
    Lines.Add('}');
    // Bring the fingerprint prompt in front of the main window even though PowerShell is hidden.
    // Die Fingerabdruckabfrage vor dem Hauptfenster anzeigen, auch wenn PowerShell verborgen läuft.
    Lines.Add('function Confirm-ServerFingerprint([string]$fingerprints,[bool]$saveOnConfirm) {');
    Lines.Add('  Add-Type -AssemblyName System.Windows.Forms');
    Lines.Add('  Assert-Active');
    Lines.Add('  $nl = [Environment]::NewLine');
    Lines.Add('  $message = ("Server: {0}:{1}" -f $serverHost,$port) + $nl+$nl+$fingerprints+$nl+$nl');
    Lines.Add('  $message += ''Bitte vergleichen Sie die angezeigten SSH-Fingerabdrücke mit den Fingerabdrücken auf Ihrem Server. Stimmen sie überein?''');
    Lines.Add('  if ($saveOnConfirm) { $message += $nl+$nl+''Bei Ja speichert das Programm neue Schlüssel nach erfolgreicher SSH-Anmeldung.'' }');
    Lines.Add('  $owner = New-Object Windows.Forms.Form');
    Lines.Add('  try {');
    Lines.Add('    $owner.ShowInTaskbar = $false; $owner.TopMost = $true; $owner.Opacity = 0');
    Lines.Add('    $owner.Show()');
    Lines.Add('    $choice = [Windows.Forms.MessageBox]::Show($owner, $message, ''SSH-Fingerabdruck bestätigen'', ''YesNo'', ''Warning'', ''Button2'')');
    Lines.Add('  } finally { $owner.Dispose() }');
    Lines.Add('  Assert-Active');
    Lines.Add('  return ($choice -eq [Windows.Forms.DialogResult]::Yes)');
    Lines.Add('}');
    // Explicit confirmation uses the host key scan before attempting SSH authentication.
    // Die ausdrückliche Bestätigung fragt den Hostschlüssel vor der SSH-Anmeldung ab.
    Lines.Add('function Read-ServerFingerprints {');
    Lines.Add('  Assert-Active');
    Lines.Add('  if (-not (Get-Command ssh-keygen.exe -ErrorAction SilentlyContinue)) { throw ''fingerprint_tools'' }');
    Lines.Add('  $old = $ErrorActionPreference; $ErrorActionPreference = ''Continue''');
    Lines.Add('  try {');
    Lines.Add('    $keys = @()');
    Lines.Add('    if (Get-Command ssh-keyscan.exe -ErrorAction SilentlyContinue) {');
    Lines.Add('      $keys = @(& ssh-keyscan.exe -T 10 -p $port -- $serverHost 2>$null)');
    Lines.Add('    }');
    Lines.Add('    Assert-Active');
    Lines.Add('    if ($keys.Count -gt 0) {');
    Lines.Add('      [IO.File]::WriteAllLines($tempKeys, [string[]]$keys, [Text.Encoding]::ASCII)');
    Lines.Add('      $fingerprints = (& ssh-keygen.exe -lf $tempKeys -E sha256 2>$null | Out-String).Trim()');
    Lines.Add('      if ($LASTEXITCODE -eq 0 -and $fingerprints) { return $fingerprints }');
    Lines.Add('    }');
    // If keyscan cannot supply a fingerprint, let OpenSSH record the negotiated host key in an isolated file.
    // Liefert keyscan keinen Fingerabdruck, den ausgehandelten Schlüssel über OpenSSH in einer separaten Datei erfassen.
    // The probe disables configured authentication methods and keeps the real known_hosts untouched.
    // Der Abruf deaktiviert konfigurierte Anmeldeverfahren und lässt die echte known_hosts unangetastet.
    Lines.Add('    [IO.File]::WriteAllText($tempKeys, '''', [Text.Encoding]::ASCII)');
    Lines.Add('    $probeArgs = @(''-F'', ''none'', ''-T'', ''-o'', ''BatchMode=yes'', ''-o'', ''PreferredAuthentications=none'', ''-o'', ''IdentityAgent=none'')');
    Lines.Add('    $probeArgs += @(''-o'', ''StrictHostKeyChecking=accept-new'', ''-o'', (''UserKnownHostsFile="'' + $tempKeys + ''"''), ''-o'', ''GlobalKnownHostsFile=none'')');
    Lines.Add('    $probeArgs += @(''-o'', ''UpdateHostKeys=no'', ''-o'', ''ConnectTimeout=10'', ''-p'', $port, ''-l'', $serverUser, $serverHost, ''true'')');
    Lines.Add('    & ssh.exe @probeArgs 2>$null | Out-Null');
    Lines.Add('    Assert-Active');
    Lines.Add('    if ((Get-Item -LiteralPath $tempKeys).Length -eq 0) { throw ''fingerprint_scan'' }');
    Lines.Add('    $fingerprints = (& ssh-keygen.exe -lf $tempKeys -E sha256 2>$null | Out-String).Trim()');
    Lines.Add('    if ($LASTEXITCODE -ne 0 -or -not $fingerprints) { throw ''fingerprint_unreadable'' }');
    Lines.Add('  } finally { $ErrorActionPreference = $old }');
    Lines.Add('  return $fingerprints');
    Lines.Add('}');
    Lines.Add('function Save-ConfirmedKeys($knownBefore) {');
    Lines.Add('  Assert-Active');
    Lines.Add('  $folder = Split-Path -Parent $savedKeys');
    Lines.Add('  if (-not (Test-Path -LiteralPath $folder)) { $null = New-Item -ItemType Directory -Path $folder -ErrorAction Stop }');
    Lines.Add('  $f = [IO.File]::Open($savedKeys, [IO.FileMode]::OpenOrCreate, [IO.FileAccess]::ReadWrite, [IO.FileShare]::None)');
    Lines.Add('  try {');
    Lines.Add('    if ($f.Length -gt 10485760) { throw ''known_hosts too large'' }');
    Lines.Add('    $b = New-Object byte[] ([int]$f.Length)');
    Lines.Add('    if ($b.Length -gt 0) { $n = $f.Read($b, 0, $b.Length); if ($n -ne $b.Length) { throw ''incomplete read'' } }');
    Lines.Add('    if ($null -eq $knownBefore) { if ($b.Length -ne 0) { throw ''known_hosts changed'' } }');
    Lines.Add('    elseif ([Convert]::ToBase64String($b) -ne $knownBefore) { throw ''known_hosts changed'' }');
    Lines.Add('    if ($b.Length -gt 0 -and $b[$b.Length - 1] -ne 10) { throw ''known_hosts missing final newline'' }');
    Lines.Add('    Assert-Active');
    Lines.Add('    $keys = [IO.File]::ReadAllLines($tempKeys, [Text.Encoding]::ASCII)');
    Lines.Add('    $bytes = [Text.Encoding]::ASCII.GetBytes((($keys -join [char]10) + [char]10))');
    Lines.Add('    $f.Position = $f.Length; $f.Write($bytes, 0, $bytes.Length); $f.Flush()');
    Lines.Add('  } finally { $f.Dispose() }');
    Lines.Add('}');
    Lines.Add('try {');
    Lines.Add('  Assert-Active');
    Lines.Add('  Set-Location -LiteralPath $workDir');
    Lines.Add('  $null = Get-Command ssh.exe -ErrorAction Stop');
    Lines.Add('  $fingerprints = ''''');
    Lines.Add('  $knownBefore = if (Test-Path -LiteralPath $savedKeys) { [Convert]::ToBase64String([IO.File]::ReadAllBytes($savedKeys)) } else { $null }');
    // Explicit checks show the fingerprint before SSH uses the saved credentials.
    // Bei ausdrücklicher Prüfung erscheint der Fingerabdruck vor der SSH-Anmeldung mit gespeicherten Zugangsdaten.
    Lines.Add('  if ($confirmFingerprint) {');
    Lines.Add('    $fingerprints = Read-ServerFingerprints');
    Lines.Add('    if (-not (Confirm-ServerFingerprint $fingerprints $true)) { throw ''cancelled'' }');
    Lines.Add('  }');
    Lines.Add('  $result = Invoke-Check '''' $fingerprints');
    Lines.Add('  if ($result -eq ''unknown_host'' -and (Test-Path -LiteralPath $savedKeys)) {');
    Lines.Add('    $result = Invoke-Check $savedKeys $fingerprints');
    Lines.Add('  }');
    Lines.Add('  if ($result -eq ''unknown_host'') {');
    Lines.Add('    $save = $true');
    Lines.Add('    if (-not $confirmFingerprint) {');
    Lines.Add('      $fingerprints = Read-ServerFingerprints');
    Lines.Add('      if (-not (Confirm-ServerFingerprint $fingerprints $false)) { throw ''cancelled'' }');
    Lines.Add('      $choice = [Windows.Forms.MessageBox]::Show(''Fingerabdruck für künftige Verbindungen speichern? Bei Nein ist die manuelle Prüfung bei jedem Start erforderlich.'', ''Fingerabdruck speichern?'', ''YesNoCancel'', ''Question'')');
    Lines.Add('      Assert-Active');
    Lines.Add('      if ($choice -eq [Windows.Forms.DialogResult]::Cancel) { throw ''cancelled'' }');
    Lines.Add('      $save = $choice -eq [Windows.Forms.DialogResult]::Yes');
    Lines.Add('    }');
    Lines.Add('    $result = Invoke-Check $tempKeys ''''');
    Lines.Add('    if ($result -eq ''success'' -and $save) {');
    Lines.Add('      try { Save-ConfirmedKeys $knownBefore }');
    Lines.Add('      catch { Assert-Active; $result = ''save_failed'' }');
    Lines.Add('    }');
    Lines.Add('  }');
    Lines.Add('} catch {');
    Lines.Add('  if ((Test-Path -LiteralPath $cancelPath) -or $_.Exception.Message -eq ''cancelled'') { $result = ''cancelled'' }');
    Lines.Add('  elseif ($_.Exception.Message -in @(''fingerprint_tools'',''fingerprint_scan'',''fingerprint_unreadable'')) { $result = $_.Exception.Message }');
    Lines.Add('  else { $result = ''unknown'' }');
    Lines.Add('}');
// Publish the result unless cancelled, then remove temporary files.
// Das Ergebnis ausser bei Abbruch bereitstellen und temporaere Dateien entfernen.
    Lines.Add('finally {');
    Lines.Add('  if (-not (Test-Path -LiteralPath $cancelPath)) { try { [IO.File]::WriteAllText($resultPath, $result, [Text.Encoding]::UTF8) } catch {} }');
    Lines.Add('  Remove-Item -LiteralPath $tempKeys -Force -ErrorAction SilentlyContinue');
    Lines.Add('  Remove-Item -LiteralPath $cancelPath -Force -ErrorAction SilentlyContinue');
    Lines.Add('  Remove-Item -LiteralPath $PSCommandPath -Force -ErrorAction SilentlyContinue');
    Lines.Add('}');
    // Use the backup timestamp format for the temporary script. The result path follows the script path.
    // Den Backup-Zeitstempel für das temporäre Skript verwenden. Der Ergebnispfad leitet sich vom Skriptpfad ab.
    ScriptPath := ReserveTimestampedScript(TPath.GetTempPath);
    try
      Lines.SaveToFile(ScriptPath, TEncoding.UTF8);
    except
      DeleteFile(PChar(ScriptPath));
      raise;
    end;
  finally
    Lines.Free;
  end;
  FillChar(SI, SizeOf(SI), 0);
  SI.cb := SizeOf(SI);
  SI.dwFlags := STARTF_USESHOWWINDOW;
  SI.wShowWindow := SW_HIDE;
  PowerShellPath := IncludeTrailingPathDelimiter(GetEnvironmentVariable('WINDIR')) +
    'System32\WindowsPowerShell\v1.0\powershell.exe';
  if not FileExists(PowerShellPath) then PowerShellPath := 'powershell.exe';
  Cmd := '"' + PowerShellPath + '" -NoProfile -STA -ExecutionPolicy Bypass -File "' + ScriptPath + '"';
  if not CreateProcess(nil, PChar(Cmd), nil, nil, False, CREATE_NO_WINDOW,
    nil, nil, SI, PI) then
  begin
    ErrorCode := GetLastError;
    DeleteFile(PChar(ScriptPath));
    RaiseLastOSError(ErrorCode);
  end;
  CloseHandle(PI.hThread);
  ProcessHandle := PI.hProcess;
  ResultPath := ScriptPath + '.result';
end;

end.
