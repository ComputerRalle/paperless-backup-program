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

procedure CreateManualBackupCmdScript(
  const TargetPath, ComposePath, BackupPath, AppDataFolder, DatabaseContainerName: string;
  const Volumes: TDockerVolumeNames);
var
  CmdFile: TStringList;
begin
  CmdFile := TStringList.Create;
  try
    CmdFile.Add('@echo off');
    CmdFile.Add('setlocal');
    CmdFile.Add('echo CDM Skript wird gestartet... Bitte warten');
    CmdFile.Add('');
    CmdFile.Add('::=== Define folders ===');
    CmdFile.Add(Format('set "COMPOSE_DIR=%s"', [ExtractFilePath(ComposePath)]));
    CmdFile.Add(Format('set "BACKUP_DIR=%s"', [BackupPath]));
    CmdFile.Add('');
    CmdFile.Add('::=== Change to compose folder ===');
    CmdFile.Add('cd /d "%COMPOSE_DIR%"');
    CmdFile.Add('if errorlevel 1 (');
    CmdFile.Add('    echo Fehler: Konnte nicht ins Compose-Verzeichnis wechseln.');
    CmdFile.Add('    pause');
    CmdFile.Add('    exit /b 1');
    CmdFile.Add(')');
    CmdFile.Add('');
    CmdFile.Add('::=== Create backup folder when missing ===');
    CmdFile.Add('if not exist "%BACKUP_DIR%" (');
    CmdFile.Add('    echo Erstelle Backup-Ordner: %BACKUP_DIR%');
    CmdFile.Add('    mkdir "%BACKUP_DIR%"');
    CmdFile.Add(')');
    CmdFile.Add('');
    CmdFile.Add('::=== Create PostgreSQL dump first while the container is still running ===');
    CmdFile.Add('echo PostgreSQL-Dump wird erstellt...');
    CmdFile.Add(Format('docker exec %s pg_dump -U paperless paperless > "%%BACKUP_DIR%%\%s_backup.sql"', [DatabaseContainerName, DatabaseContainerName]));
    CmdFile.Add('if errorlevel 1 (');
    CmdFile.Add('    echo Fehler beim PostgreSQL-Dump. Abbruch.');
    CmdFile.Add('    pause');
    CmdFile.Add('    exit /b 1');
    CmdFile.Add(')');
    CmdFile.Add('');
    CmdFile.Add('::=== Stop containers ===');
    CmdFile.Add('echo Stoppe Docker-Container...');
    CmdFile.Add('docker compose down');
    CmdFile.Add('if errorlevel 1 (');
    CmdFile.Add('    echo Fehler beim Stoppen der Container. Abbruch.');
    CmdFile.Add('    pause');
    CmdFile.Add('    exit /b 1');
    CmdFile.Add(')');
    CmdFile.Add('');
    CmdFile.Add('::=== Back up Docker volumes ===');
    CmdFile.Add('echo Backup: data');
    CmdFile.Add('echo Bitte warten, Backup kann sehr lange dauern.');
    CmdFile.Add('echo ...');
    CmdFile.Add('echo ......');
    CmdFile.Add('echo .........');
    CmdFile.Add(Format('docker run --rm -v %s:/data -v "%%BACKUP_DIR%%":/backup alpine tar czvf /backup/%s.tar.gz -C /data .', [Volumes.Data, Volumes.Data]));
    CmdFile.Add('if errorlevel 1 (');
    CmdFile.Add('    echo Fehler beim Sichern von ''data''. Abbruch.');
    CmdFile.Add('    pause');
    CmdFile.Add('    exit /b 1');
    CmdFile.Add(')');
    CmdFile.Add('');
    CmdFile.Add('echo Backup: db_data');
    CmdFile.Add('echo Bitte warten, Backup kann sehr lange dauern.');
    CmdFile.Add('echo ...');
    CmdFile.Add('echo ......');
    CmdFile.Add('echo .........');
    CmdFile.Add(Format('docker run --rm -v %s:/data -v "%%BACKUP_DIR%%":/backup alpine tar czvf /backup/%s.tar.gz -C /data .', [Volumes.DbData, Volumes.DbData]));
    CmdFile.Add('if errorlevel 1 (');
    CmdFile.Add('    echo Fehler beim Sichern von ''db_data''. Abbruch.');
    CmdFile.Add('    pause');
    CmdFile.Add('    exit /b 1');
    CmdFile.Add(')');
    CmdFile.Add('');
    CmdFile.Add('echo Backup: export');
    CmdFile.Add('echo Bitte warten, Backup kann sehr lange dauern.');
    CmdFile.Add('echo ...');
    CmdFile.Add('echo ......');
    CmdFile.Add('echo .........');
    CmdFile.Add(Format('docker run --rm -v %s:/data -v "%%BACKUP_DIR%%":/backup alpine tar czvf /backup/%s.tar.gz -C /data .', [Volumes.ExportData, Volumes.ExportData]));
    CmdFile.Add('if errorlevel 1 (');
    CmdFile.Add('    echo Fehler beim Sichern von ''export''. Abbruch.');
    CmdFile.Add('    pause');
    CmdFile.Add('    exit /b 1');
    CmdFile.Add(')');
    CmdFile.Add('');
    CmdFile.Add('echo Backup: media');
    CmdFile.Add('echo Bitte warten, Backup kann sehr lange dauern.');
    CmdFile.Add('echo ...');
    CmdFile.Add('echo ......');
    CmdFile.Add('echo .........');
    CmdFile.Add(Format('docker run --rm -v %s:/data -v "%%BACKUP_DIR%%":/backup alpine tar czvf /backup/%s.tar.gz -C /data .', [Volumes.Media, Volumes.Media]));
    CmdFile.Add('if errorlevel 1 (');
    CmdFile.Add('    echo Fehler beim Sichern von ''media''. Abbruch.');
    CmdFile.Add('    pause');
    CmdFile.Add('    exit /b 1');
    CmdFile.Add(')');
    CmdFile.Add('');
    CmdFile.Add('::=== Start containers again ===');
    CmdFile.Add('echo Starte Docker-Container neu...');
    CmdFile.Add('docker compose up -d');
    CmdFile.Add('if errorlevel 1 (');
    CmdFile.Add('    echo Fehler beim Starten der Container. Manuell pruefen.');
    CmdFile.Add('    pause');
    CmdFile.Add('    exit /b 1');
    CmdFile.Add(')');
    CmdFile.Add('');
    CmdFile.Add('echo Nicht mehr verwendete Volumes werden geloescht');
    CmdFile.Add('for /L %%i in (3,-1,1) do (echo %%i & timeout /t 1 >nul)');
    CmdFile.Add('docker volume prune -f');
    CmdFile.Add('for /L %%i in (3,-1,1) do (echo %%i & timeout /t 1 >nul)');
    CmdFile.Add('echo -----------------------------------------');
    CmdFile.Add('echo Backup abgeschlossen: %DATE% %TIME%');
    CmdFile.Add('echo Dateien gespeichert in: %BACKUP_DIR%');
    CmdFile.Add('echo -----------------------------------------');
    CmdFile.Add('echo Systeme starten. Fenster wird gleich geschlossen ...');
    CmdFile.Add('echo Backup.log wurde gespeichert unter: "' + IncludeTrailingPathDelimiter(AppDataFolder) + 'Backup.log"');
    CmdFile.Add('echo Backup abgeschlossen: %DATE% %TIME% >> "' + IncludeTrailingPathDelimiter(AppDataFolder) + 'Backup.log"');
    CmdFile.Add('echo Backup-Ziel: %BACKUP_DIR% >> "' + IncludeTrailingPathDelimiter(AppDataFolder) + 'Backup.log"');
    CmdFile.Add('for /L %%i in (10,-1,1) do (echo %%i & timeout /t 1 >nul)');
    CmdFile.Add('endlocal');
    CmdFile.Add('exit');
    CmdFile.SaveToFile(TargetPath, TEncoding.ANSI);
  finally
    CmdFile.Free;
  end;
end;

procedure CreatePlannedBackupCmdScript(
  const TargetPath, ComposePath, BackupBasePath, AppDataFolder, DatabaseContainerName: string;
  const Volumes: TDockerVolumeNames);
var
  CmdFile: TStringList;
begin
  CmdFile := TStringList.Create;
  try
    CmdFile.Add('@echo off');
    CmdFile.Add('setlocal');
    CmdFile.Add(Format('set "COMPOSE_DIR=%s"', [ExtractFilePath(ComposePath)]));
    CmdFile.Add(Format('set "BACKUP_BASE=%s"', [BackupBasePath]));
    CmdFile.Add('');
    CmdFile.Add('for /f %%i in (''wmic os get LocalDateTime ^| find "."'') do set "DATUMZEIT=%%i"');
    CmdFile.Add('set "DATUMZEIT=%DATUMZEIT:~0,4%-%DATUMZEIT:~4,2%-%DATUMZEIT:~6,2%_%DATUMZEIT:~8,2%-%DATUMZEIT:~10,2%-%DATUMZEIT:~12,2%"');
    CmdFile.Add('set "BACKUP_DIR=%BACKUP_BASE%\%DATUMZEIT%"');
    CmdFile.Add('');
    CmdFile.Add('docker exec -i paperless-ngx-paperless-1 python3 manage.py migrate contenttypes');
    CmdFile.Add('cd /d "%COMPOSE_DIR%"');
    CmdFile.Add('if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"');
    CmdFile.Add(Format('docker exec %s pg_dump -U paperless paperless > "%%BACKUP_DIR%%\%s_backup.sql"', [DatabaseContainerName, DatabaseContainerName]));
    CmdFile.Add('docker compose down');
    CmdFile.Add(Format('docker run --rm -v %s:/data -v "%%BACKUP_DIR%%":/backup alpine tar czf /backup/%s.tar.gz -C /data .', [Volumes.Data, Volumes.Data]));
    CmdFile.Add(Format('docker run --rm -v %s:/data -v "%%BACKUP_DIR%%":/backup alpine tar czf /backup/%s.tar.gz -C /data .', [Volumes.Media, Volumes.Media]));
    CmdFile.Add(Format('docker run --rm -v %s:/data -v "%%BACKUP_DIR%%":/backup alpine tar czf /backup/%s.tar.gz -C /data .', [Volumes.ExportData, Volumes.ExportData]));
    CmdFile.Add('docker compose up -d');
    CmdFile.Add('docker volume prune -f');
    CmdFile.Add('echo Backup abgeschlossen: %DATE% %TIME% >> "' + IncludeTrailingPathDelimiter(AppDataFolder) + 'GeplanterBackup.log"');
    CmdFile.Add('echo Backup-Ziel: %BACKUP_DIR% >> "' + IncludeTrailingPathDelimiter(AppDataFolder) + 'GeplanterBackup.log"');
    CmdFile.Add('endlocal');
    CmdFile.Add('exit');
    CmdFile.SaveToFile(TargetPath, TEncoding.ANSI);
  finally
    CmdFile.Free;
  end;
end;

procedure CreateRestoreCmdScript(
  const TargetPath, ComposePath, BackupFolder, DatabaseContainerName: string;
  const Volumes: TDockerVolumeNames);
var
  CmdFile: TStringList;
begin
  CmdFile := TStringList.Create;
  try
    CmdFile.Add('@echo off');
    CmdFile.Add('setlocal');
    CmdFile.Add('');
    CmdFile.Add(':: === Folders ===');
    CmdFile.Add(Format('set "COMPOSE_DIR=%s"', [ExtractFilePath(ComposePath)]));
    CmdFile.Add(Format('set "BACKUP_DIR=%s"', [BackupFolder]));
    CmdFile.Add('');
    CmdFile.Add('cd /d "%COMPOSE_DIR%"');
    CmdFile.Add('if errorlevel 1 ( echo Fehler beim Wechsel in Compose-Verzeichnis & exit /b 1 )');
    CmdFile.Add('');
    CmdFile.Add('echo Stoppe Container...');
    CmdFile.Add('docker compose down');
    CmdFile.Add('');
    CmdFile.Add('echo Wiederherstellen Volume: data.');
    CmdFile.Add('echo Bitte warten, Wiederherstellung kann sehr lange dauern.');
    CmdFile.Add('echo ...');
    CmdFile.Add('echo ......');
    CmdFile.Add('echo .........');
    CmdFile.Add(Format('if exist "%%BACKUP_DIR%%\%0:s.tar.gz" ( docker run --rm -v %0:s:/data -v "%%BACKUP_DIR%%":/backup alpine sh -c "rm -rf /data/* && tar xzvf /backup/%0:s.tar.gz -C /data" ) else ( echo Fehler: %0:s.tar.gz fehlt! & pause & exit /b 1 )', [Volumes.Data]));
    CmdFile.Add('');
    CmdFile.Add('echo Wiederherstellen Volume: media.');
    CmdFile.Add('echo Bitte warten, Wiederherstellung kann sehr lange dauern.');
    CmdFile.Add('echo ...');
    CmdFile.Add('echo ......');
    CmdFile.Add('echo .........');
    CmdFile.Add(Format('if exist "%%BACKUP_DIR%%\%0:s.tar.gz" ( docker run --rm -v %0:s:/data -v "%%BACKUP_DIR%%":/backup alpine sh -c "rm -rf /data/* && tar xzvf /backup/%0:s.tar.gz -C /data" ) else ( echo Fehler: %0:s.tar.gz fehlt! & pause & exit /b 1 )', [Volumes.Media]));
    CmdFile.Add('');
    CmdFile.Add('echo Wiederherstellen Volume: export.');
    CmdFile.Add('echo Bitte warten, Wiederherstellung kann sehr lange dauern.');
    CmdFile.Add('echo ...');
    CmdFile.Add('echo ......');
    CmdFile.Add('echo .........');
    CmdFile.Add(Format('if exist "%%BACKUP_DIR%%\%0:s.tar.gz" ( docker run --rm -v %0:s:/data -v "%%BACKUP_DIR%%":/backup alpine sh -c "rm -rf /data/* && tar xzvf /backup/%0:s.tar.gz -C /data" ) else ( echo Fehler: %0:s.tar.gz fehlt! & pause & exit /b 1 )', [Volumes.ExportData]));
    CmdFile.Add('');
    CmdFile.Add('echo Starte Container...');
    CmdFile.Add('docker compose up -d');
    CmdFile.Add('echo Wiederherstellen der PostgreSQL-Datenbank. Bitte haben Sie Geduld...');
    CmdFile.Add('timeout /t 3 >nul');
    CmdFile.Add('docker exec -i paperless-ngx-paperless-1 python3 manage.py migrate contenttypes');
    CmdFile.Add('timeout /t 3 >nul');
    CmdFile.Add('');
    CmdFile.Add('echo Wiederherstellen der PostgreSQL-Datenbank (Datenbank wird gestartet) ...');
    CmdFile.Add('for /L %%i in (15,-1,1) do (echo %%i & timeout /t 1 >nul)');
    CmdFile.Add(Format('docker exec -i %s psql -U paperless paperless -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"', [DatabaseContainerName]));
    CmdFile.Add(Format('docker exec -i %s psql -U paperless paperless < "%%BACKUP_DIR%%\\%s_backup.sql"', [DatabaseContainerName, DatabaseContainerName]));
    CmdFile.Add('');
    CmdFile.Add('echo Nicht mehr verwendete Volumes werden geloescht');
    CmdFile.Add('for /L %%i in (3,-1,1) do (echo %%i & timeout /t 1 >nul)');
    CmdFile.Add('docker volume prune -f');
    CmdFile.Add('for /L %%i in (3,-1,1) do (echo %%i & timeout /t 1 >nul)');
    CmdFile.Add('echo -----------------------------------------');
    CmdFile.Add('echo Wiederherstellung abgeschlossen: %DATE% %TIME%');
    CmdFile.Add('echo Dateien aus: %BACKUP_DIR%');
    CmdFile.Add('echo Bitte geben Sie Paperless Zeit, seine Dienste zu starten. Das kann Minuten dauern.');
    CmdFile.Add('echo -----------------------------------------');
    CmdFile.Add('echo Systeme starten. Fenster wird gleich geschlossen ...');
    CmdFile.Add('for /L %%i in (10,-1,1) do (echo %%i & timeout /t 1 >nul)');
    CmdFile.Add('endlocal');
    CmdFile.Add('exit');
    CmdFile.SaveToFile(TargetPath, TEncoding.ANSI);
  finally
    CmdFile.Free;
  end;
end;

procedure CreateRestartCmdScript(const TargetPath, ComposePath: string);
var
  CmdFile: TStringList;
begin
  CmdFile := TStringList.Create;
  try
    CmdFile.Add('@echo off');
    CmdFile.Add('setlocal');
    CmdFile.Add(Format('set "COMPOSE_DIR=%s"', [ExtractFilePath(ComposePath)]));
    CmdFile.Add('');
    CmdFile.Add('');
    CmdFile.Add('cd /d "%COMPOSE_DIR%"');
    CmdFile.Add('echo Bitte warten, Paperless wird heruntergefahren.');
    CmdFile.Add('for /L %%i in (3,-1,1) do (echo %%i & timeout /t 1 >nul)');
    CmdFile.Add('docker compose down');
    CmdFile.Add('echo Bitte warten, Paperless wird neu gestartet.');
    CmdFile.Add('for /L %%i in (3,-1,1) do (echo %%i & timeout /t 1 >nul)');
    CmdFile.Add('docker compose up -d');
    CmdFile.Add('echo Nicht mehr verwendete Volumes werden geloescht');
    CmdFile.Add('for /L %%i in (3,-1,1) do (echo %%i & timeout /t 1 >nul)');
    CmdFile.Add('docker volume prune -f');
    CmdFile.Add('for /L %%i in (3,-1,1) do (echo %%i & timeout /t 1 >nul)');
    CmdFile.Add('timeout /t 3 >nul');
    CmdFile.Add('docker exec -i paperless-ngx-paperless-1 python3 manage.py migrate contenttypes');
    CmdFile.Add('timeout /t 3 >nul');
    CmdFile.Add('endlocal');
    CmdFile.Add('exit');
    CmdFile.SaveToFile(TargetPath, TEncoding.ANSI);
  finally
    CmdFile.Free;
  end;
end;

procedure CreateDeleteBackupScheduleCmdScript(const TargetPath: string);
var
  CmdFile: TStringList;
begin
  CmdFile := TStringList.Create;
  try
    CmdFile.Add('@echo off');
    CmdFile.Add('setlocal');
    CmdFile.Add('echo Backup-Aufgabe wird aus der Aufgabenplanung entfernt');
    CmdFile.Add('schtasks /delete /tn "PaperlessBackup" /f');
    CmdFile.Add('echo Fertig');
    CmdFile.Add('endlocal');
    CmdFile.Add('exit');
    CmdFile.SaveToFile(TargetPath, TEncoding.ANSI);
  finally
    CmdFile.Free;
  end;
end;

procedure CreateBackupScheduleCmdScript(
  const TargetPath, ProgramPath, Weekdays, Hour, Minute: string);
var
  CmdFile: TStringList;
begin
  CmdFile := TStringList.Create;
  try
    CmdFile.Add('@echo off');
    CmdFile.Add('echo === Backup-Aufgabe wird in die Aufgabenplanung eingetragen ===');
    CmdFile.Add(Format(
      'schtasks /create /tn "PaperlessBackup" /tr "\"%s\" /geplant" /sc weekly /d %s /st %s:%s /f',
      [ProgramPath, Weekdays, Hour, Minute]));
    CmdFile.Add('echo === Fertig ===');
    CmdFile.SaveToFile(TargetPath, TEncoding.ANSI);
  finally
    CmdFile.Free;
  end;
end;

end.
