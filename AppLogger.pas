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

unit AppLogger;

interface

procedure InitLogger(const AppDataFolder: string);
procedure LogInfo(const MessageText: string);
procedure LogWarning(const MessageText: string);
procedure LogError(const MessageText: string);

implementation

uses
  System.SysUtils, System.Classes, System.IOUtils, AppConfig;

var
  LogFilePath: string;

// Append one log line to the configured application log file.
// Eine Logzeile an die konfigurierte Anwendungs-Logdatei anhaengen.
procedure WriteLog(const Level, MessageText: string);
var
  LogLine: string;
begin
  if LogFilePath = '' then Exit;

  try
    ForceDirectories(ExtractFilePath(LogFilePath));
    LogLine := FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now) +
      ' [' + Level + '] ' + MessageText + sLineBreak;
    TFile.AppendAllText(LogFilePath, LogLine, TEncoding.UTF8);
  except
    // Logging must never interrupt backup or restore workflows.
    // Logging darf Backup- oder Wiederherstellungsablaeufe niemals unterbrechen.
  end;
end;

// Initialize logging in the application data folder.
// Logging im Anwendungsdatenordner initialisieren.
procedure InitLogger(const AppDataFolder: string);
begin
  LogFilePath := IncludeTrailingPathDelimiter(AppDataFolder) + ApplicationLogFileName;
  WriteLog('INFO', 'Logger initialized.');
end;

// Write an informational log entry.
// Einen informativen Logeintrag schreiben.
procedure LogInfo(const MessageText: string);
begin
  WriteLog('INFO', MessageText);
end;

// Write a warning log entry.
// Einen Warnungs-Logeintrag schreiben.
procedure LogWarning(const MessageText: string);
begin
  WriteLog('WARN', MessageText);
end;

// Write an error log entry.
// Einen Fehler-Logeintrag schreiben.
procedure LogError(const MessageText: string);
begin
  WriteLog('ERROR', MessageText);
end;

end.
