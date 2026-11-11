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
  const KeyFile, SettingsPath, ExePath: string; UseKey: Boolean;
  out ProcessHandle: THandle; out ResultPath: string);

implementation

uses System.SysUtils, System.Classes, System.IOUtils;

function PsLiteral(const Value: string): string;
begin
  Result := #39 + StringReplace(Value, #39, #39#39, [rfReplaceAll]) + #39;
end;

procedure StartExternalStartupCheck(const Host, UserName: string; PortNumber: Integer;
  const KeyFile, SettingsPath, ExePath: string; UseKey: Boolean;
  out ProcessHandle: THandle; out ResultPath: string);
var
  ScriptPath, Cmd, WorkDir, PowerShellPath: string;
  Lines: TStringList;
  SI: TStartupInfo;
  PI: TProcessInformation;
  ErrorCode: DWORD;
begin
  ProcessHandle := 0;
  ScriptPath := TPath.Combine(TPath.GetTempPath, 'paperless-startup-' + TGUID.NewGuid.ToString + '.ps1');
  ResultPath := ScriptPath + '.result';
  WorkDir := ExtractFilePath(SettingsPath);
  Lines := TStringList.Create;
  try
    Lines.Add('$ErrorActionPreference = ''Stop''');
    Lines.Add('$result = ''unknown''');
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
    Lines.Add('$resultPath = ' + PsLiteral(ResultPath));
    Lines.Add('$cancelPath = $resultPath + ''.cancel''');
    Lines.Add('function Assert-Active { if (Test-Path -LiteralPath $cancelPath) { throw ''cancelled'' } }');
    Lines.Add('$baseArgs = @(''-o'', ''StrictHostKeyChecking=yes'', ''-o'', ''UpdateHostKeys=no'', ''-o'', ''ConnectTimeout=10'', ''-o'', ''NumberOfPasswordPrompts=1'', ''-p'', $port, ''-l'', $serverUser)');
    if UseKey then
      Lines.Add('$baseArgs += @(''-o'', ''IdentitiesOnly=yes'', ''-i'', ' + PsLiteral(KeyFile) + ')')
    else
      Lines.Add('$baseArgs += @(''-o'', ''PreferredAuthentications=password'', ''-o'', ''PubkeyAuthentication=no'')');
    Lines.Add('function Invoke-Check([string] $hostFile) {');
    Lines.Add('  Assert-Active');
    Lines.Add('  $a = @($baseArgs)');
    Lines.Add('  if ($hostFile) { $a += @(''-o'', (''UserKnownHostsFile="'' + $hostFile + ''"''), ''-o'', ''GlobalKnownHostsFile=none'') }');
    Lines.Add('  $a += @($serverHost, ''true'')');
    Lines.Add('  $old = $ErrorActionPreference; $ErrorActionPreference = ''Continue''');
    Lines.Add('  try { $output = & ssh.exe @a 2>&1; $code = $LASTEXITCODE } finally { $ErrorActionPreference = $old }');
    Lines.Add('  $detail = ($output | Out-String)');
    Lines.Add('  Assert-Active');
    Lines.Add('  if ($code -eq 0) { return ''success'' }');
    Lines.Add('  if ($detail -match ''REMOTE HOST IDENTIFICATION HAS CHANGED|Host key .* has changed|Offending .* key'') { return ''changed_host'' }');
    Lines.Add('  if ($detail -match ''No .* host key is known|no matching host key is known'') { return ''unknown_host'' }');
    Lines.Add('  if ($detail -match ''Host key verification failed'') { return ''hostkey'' }');
    Lines.Add('  if ($detail -match ''Permission denied'') { return ''auth'' }');
    Lines.Add('  if ($detail -match ''Connection timed out|Connection refused|No route to host|Could not resolve hostname|Name or service not known|Network is unreachable'') { return ''unreachable'' }');
    Lines.Add('  return ''unknown''');
    Lines.Add('}');
    Lines.Add('try {');
    Lines.Add('  Assert-Active');
    Lines.Add('  Set-Location -LiteralPath $workDir');
    Lines.Add('  $null = Get-Command ssh.exe -ErrorAction Stop');
    Lines.Add('  $result = Invoke-Check ''''');
    Lines.Add('  if ($result -eq ''unknown_host'') {');
    Lines.Add('    if (Test-Path -LiteralPath $savedKeys) { $result = Invoke-Check $savedKeys }');
    Lines.Add('    if ($result -eq ''unknown_host'') {');
    Lines.Add('      Assert-Active');
    Lines.Add('      $knownBefore = if (Test-Path -LiteralPath $savedKeys) { [Convert]::ToBase64String([IO.File]::ReadAllBytes($savedKeys)) } else { $null }');
    Lines.Add('      $null = Get-Command ssh-keyscan.exe -ErrorAction Stop');
    Lines.Add('      $null = Get-Command ssh-keygen.exe -ErrorAction Stop');
    Lines.Add('      $old = $ErrorActionPreference; $ErrorActionPreference = ''Continue''');
    Lines.Add('      try { $keys = @( & ssh-keyscan.exe -T 10 -p $port -- $serverHost 2>$null ); $scanCode = $LASTEXITCODE } finally { $ErrorActionPreference = $old }');
    Lines.Add('      Assert-Active');
    Lines.Add('      if ($scanCode -ne 0 -or $keys.Count -eq 0) { $result = ''unknown'' }');
    Lines.Add('      else {');
    Lines.Add('        [IO.File]::WriteAllLines($tempKeys, [string[]]$keys, [Text.Encoding]::ASCII)');
    Lines.Add('        $fingerprints = (& ssh-keygen.exe -lf $tempKeys -E sha256 | Out-String).Trim()');
    Lines.Add('        if ($LASTEXITCODE -ne 0 -or -not $fingerprints) { throw ''Fingerabdruck konnte nicht gelesen werden.'' }');
    Lines.Add('        Add-Type -AssemblyName System.Windows.Forms');
    Lines.Add('        Assert-Active');
    Lines.Add('        $message = "Server: $serverHost`:$port`r`n`r`n$fingerprints`r`n`r`nBitte vergleichen Sie ALLE angezeigten Fingerabdruecke unabhaengig mit denen auf Ihrem Server. Stimmen sie ueberein?"');
    Lines.Add('        $choice = [Windows.Forms.MessageBox]::Show($message, ''Server-Fingerabdruck pruefen'', ''YesNo'', ''Warning'')');
    Lines.Add('        Assert-Active');
    Lines.Add('        if ($choice -ne [Windows.Forms.DialogResult]::Yes) { $result = ''cancelled'' }');
    Lines.Add('        else {');
    Lines.Add('          $save = [Windows.Forms.MessageBox]::Show(''Fingerabdruck fuer kuenftige Verbindungen speichern? Bei Nein ist die manuelle Pruefung bei jedem Start erforderlich.'', ''Fingerabdruck speichern?'', ''YesNoCancel'', ''Question'')');
    Lines.Add('          Assert-Active');
    Lines.Add('          if ($save -eq [Windows.Forms.DialogResult]::Cancel) { $result = ''cancelled'' }');
    Lines.Add('          else { $result = Invoke-Check $tempKeys }');
    Lines.Add('          if ($result -eq ''success'' -and $save -eq [Windows.Forms.DialogResult]::Yes) {');
    Lines.Add('            Assert-Active');
    Lines.Add('            try {');
    Lines.Add('              $folder = Split-Path -Parent $savedKeys');
    Lines.Add('              if (-not (Test-Path -LiteralPath $folder)) { $null = New-Item -ItemType Directory -Path $folder -ErrorAction Stop }');
    Lines.Add('              $f = [IO.File]::Open($savedKeys, [IO.FileMode]::OpenOrCreate, [IO.FileAccess]::ReadWrite, [IO.FileShare]::None)');
    Lines.Add('              try {');
    Lines.Add('                if ($f.Length -gt 10485760) { throw ''known_hosts too large'' }');
    Lines.Add('                $b = New-Object byte[] ([int]$f.Length)');
    Lines.Add('                if ($b.Length -gt 0) { $n = $f.Read($b, 0, $b.Length); if ($n -ne $b.Length) { throw ''incomplete read'' } }');
    Lines.Add('                if ($null -eq $knownBefore) { if ($b.Length -ne 0) { throw ''known_hosts changed'' } }');
    Lines.Add('                elseif ([Convert]::ToBase64String($b) -ne $knownBefore) { throw ''known_hosts changed'' }');
    Lines.Add('                if ($b.Length -gt 0 -and $b[$b.Length - 1] -ne 10) { throw ''known_hosts missing final newline'' }');
    Lines.Add('                Assert-Active');
    Lines.Add('                $bytes = [Text.Encoding]::ASCII.GetBytes((($keys -join "`n") + "`n"))');
    Lines.Add('                $f.Position = $f.Length; $f.Write($bytes, 0, $bytes.Length); $f.Flush()');
    Lines.Add('              } finally { $f.Dispose() }');
    Lines.Add('            } catch { if (Test-Path -LiteralPath $cancelPath) { throw ''cancelled'' }; $result = ''save_failed'' }');
    Lines.Add('          }');
    Lines.Add('        }');
    Lines.Add('      }');
    Lines.Add('    }');
    Lines.Add('  }');
    Lines.Add('} catch { if (Test-Path -LiteralPath $cancelPath) { $result = ''cancelled'' } else { $result = ''unknown'' } }');
    Lines.Add('finally {');
    Lines.Add('  if (-not (Test-Path -LiteralPath $cancelPath)) { try { [IO.File]::WriteAllText($resultPath, $result, [Text.Encoding]::UTF8) } catch {} }');
    Lines.Add('  Remove-Item -LiteralPath $tempKeys -Force -ErrorAction SilentlyContinue');
    Lines.Add('  Remove-Item -LiteralPath $cancelPath -Force -ErrorAction SilentlyContinue');
    Lines.Add('  Remove-Item -LiteralPath $PSCommandPath -Force -ErrorAction SilentlyContinue');
    Lines.Add('}');
    Lines.SaveToFile(ScriptPath, TEncoding.UTF8);
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
  Cmd := '"' + PowerShellPath + '" -NoProfile -ExecutionPolicy Bypass -File "' + ScriptPath + '"';
  if not CreateProcess(nil, PChar(Cmd), nil, nil, False, CREATE_NO_WINDOW,
    nil, nil, SI, PI) then
  begin
    ErrorCode := GetLastError;
    DeleteFile(PChar(ScriptPath));
    RaiseLastOSError(ErrorCode);
  end;
  CloseHandle(PI.hThread);
  ProcessHandle := PI.hProcess;
end;

end.
