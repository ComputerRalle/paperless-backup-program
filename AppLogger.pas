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

// UTF-8-Anwendungslog als Best-Effort-Ausgabe. Erst nach bestätigtem Installationspfad initialisieren; Schreibfehler dürfen Arbeitsabläufe nicht abbrechen.
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

// Hängt eine UTF-8-Zeile mit Zeitstempel und Stufe an das Anwendungslog an.
// Ohne initialisierten Logpfad erfolgt kein Zugriff. Alle Schreibfehler werden abgefangen; sensible Werte darf der Aufrufer nicht übergeben.
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

// Logging im Anwendungsdatenordner initialisieren.
procedure InitLogger(const AppDataFolder: string);
begin
  LogFilePath := IncludeTrailingPathDelimiter(AppDataFolder) + ApplicationLogFileName;
  WriteLog('INFO', 'Logger initialized.');
end;

// Einen informativen Logeintrag schreiben.
procedure LogInfo(const MessageText: string);
begin
  WriteLog('INFO', MessageText);
end;

// Einen Warnungs-Logeintrag schreiben.
procedure LogWarning(const MessageText: string);
begin
  WriteLog('WARN', MessageText);
end;

// Einen Fehler-Logeintrag schreiben.
procedure LogError(const MessageText: string);
begin
  WriteLog('ERROR', MessageText);
end;

end.
