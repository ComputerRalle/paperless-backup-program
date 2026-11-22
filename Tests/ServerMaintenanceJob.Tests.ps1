$ErrorActionPreference='Stop'
$tokens=$null;$errors=$null
$inc=Join-Path (Split-Path $PSScriptRoot -Parent) 'ServerMaintenanceJob.inc'
$source=((Get-Content -LiteralPath $inc -Encoding UTF8 | ForEach-Object {
 if($_ -match "^  Lines.Add\('(.*)'\);$"){$matches[1].Replace("''", "'")}
}) -join "`n")+"`n"
[System.Management.Automation.Language.Parser]::ParseInput($source,[ref]$tokens,[ref]$errors) | Out-Null
if($errors){throw ($errors|Out-String)}
Invoke-Expression $source
function ShArg([string]$s){return "'"+$s.Replace("'","'\''")+"'"}
function SetProgress([string]$s){$script:progress.Add($s)}
function Start-Sleep {param($Seconds); if($Seconds -ne 5){throw 'retry interval'}; $script:waits++}
function JobSsh([string]$cmd,[byte[]]$bytes=$null){
 $script:commands.Add($cmd)
 if($script:answers.Count -eq 0){throw 'unexpected call'}
 $answer=$script:answers.Dequeue()
 if($answer.StartsWith('THROW:')){throw $answer.Substring(6)}
 return $answer
}
function CheckCase($name,$responses,$expected,$count){
 $script:answers=New-Object 'Collections.Generic.Queue[string]'
 foreach($r in $responses){$script:answers.Enqueue($r)}
 $script:commands=New-Object 'Collections.Generic.List[string]'
 $script:progress=New-Object 'Collections.Generic.List[string]'
 $script:waits=0;$script:installStep='Start';$script:installReady=$false;$script:installFailure=''
 $script:log=New-Object IO.StringWriter
 $failure=''
 try {InvokeDetachedJob 'printf test' "'/opt/path with space/compose.yml' 'project' '' '' '' '' '' '' ''"}catch{$failure=$_.Exception.Message}
 if($failure -ne $expected){throw "$name failure: $failure"}
 if($script:answers.Count -ne 0){throw "$name unused replies"}
 if(($log.ToString().Split(@('PAPERLESS_STEP:'),[StringSplitOptions]::None).Length-1) -ne $count){throw "$name duplicate/missing log"}
 if($expected -eq '' -and -not $script:installReady){throw "$name missing success"}
 Write-Output "PASS $name"
}
$first="PAPERLESS_JOB:running:1`nPAPERLESS_STEP:Pakete prüfen`n"
$last="PAPERLESS_JOB:done:0:2`nPAPERLESS_INSTALL_COMPLETE`n"
CheckCase 'success' @("PREPARED`n",'', $first,$last) '' 1
CheckCase 'lost launch acknowledgement' @("PREPARED`n",'THROW:ssh_exit_255','',$first,$last) '' 1
if($commands[1] -ne $commands[2]){throw 'Lost acknowledgement changed the job identity'}
CheckCase 'reconnect and resume log offset' @("PREPARED`n",'',$first,'THROW:ssh_exit_255','THROW:ssh_timeout',$last) '' 1
CheckCase 'preparation reconnect' @('THROW:ssh_exit_255',"PREPARED`n",'',$first,$last) '' 1
CheckCase 'server failure 100' @("PREPARED`n",'',"PAPERLESS_JOB:done:100:1`nPAPERLESS_STEP:APT`n") 'job_exit_100' 1
CheckCase 'server interrupted' @("PREPARED`n",'',"PAPERLESS_JOB:interrupted:0`n") 'job_interrupted' 0
CheckCase 'malformed poll' @("PREPARED`n",'',"PAPERLESS_JOB:done:0:9`n") 'job_status' 0
