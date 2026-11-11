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

unit ExternPaperless;

interface

procedure EnsureExternalPaperlessSection(const SettingsPath: string);
function ReadServerSecret(const SettingsPath, SecretName: string): string;
procedure WriteServerSecret(const SettingsPath, SecretName, Value: string);
function RunServerAskPass: Integer;

implementation

uses
  Winapi.Windows, Winapi.WinCred, System.SysUtils, System.Classes;

const
  ServerCredentialNotFound = 1168; // ERROR_NOT_FOUND

// Only answer the requested secret; all host-key and unknown prompts fail closed.
// Nur das angeforderte Geheimnis ausgeben; Hostschluessel und unbekannte Fragen ablehnen.
function RunServerAskPass: Integer;
var
  Prompt, Mode, SettingsPath, Secret: string;
  OutputBytes: TBytes;
  OutputHandle: THandle;
  Written: DWORD;
begin
  Result := 1;
  Prompt := LowerCase(ParamStr(1));
  Mode := GetEnvironmentVariable('PAPERLESS_SSH_AUTH');
  SettingsPath := GetEnvironmentVariable('PAPERLESS_SSH_SETTINGS');
  if (SettingsPath = '') or (ParamCount <> 1) then Exit;
  if (Mode = 'password') and (Pos('password:', Prompt) > 0) then
    Secret := ReadServerSecret(SettingsPath, 'Passwort')
  else if (Mode = 'key') and (Pos('enter passphrase for key', Prompt) = 1) then
    Secret := ReadServerSecret(SettingsPath, 'Passphrase')
  else
    Exit;
  if (Secret = '') or (Pos(#10, Secret) > 0) or (Pos(#13, Secret) > 0) then Exit;
  OutputBytes := TEncoding.UTF8.GetBytes(Secret + #10);
  OutputHandle := GetStdHandle(STD_OUTPUT_HANDLE);
  if (OutputHandle = 0) or (OutputHandle = INVALID_HANDLE_VALUE) then Exit;
  if WriteFile(OutputHandle, OutputBytes[0], Length(OutputBytes), Written, nil) and
     (Written = DWORD(Length(OutputBytes))) then Result := 0;
end;

// Credentials are scoped to the selected settings path and Windows user.
// Zugangsdaten sind an den Einstellungspfad und Windows-Benutzer gebunden.
function ServerSecretTarget(const SettingsPath, SecretName: string): string;
begin
  Result := 'PaperlessBackup/' + ExpandFileName(SettingsPath) + '/' + SecretName;
end;

// Read the selected Windows credential; a missing entry returns an empty value.
// Das gewaehlte Windows-Zugangsdatenfeld lesen; ein fehlender Eintrag liefert einen leeren Wert.
function ReadServerSecret(const SettingsPath, SecretName: string): string;
var
  CredData: PCREDENTIAL;
  Target: string;
  ErrorCode: DWORD;
begin
  Result := '';
  Target := ServerSecretTarget(SettingsPath, SecretName);
  CredData := nil;
  if not CredRead(PChar(Target), CRED_TYPE_GENERIC, 0, CredData) then
  begin
    ErrorCode := GetLastError;
    if ErrorCode = ServerCredentialNotFound then Exit;
    RaiseLastOSError(ErrorCode);
  end;
  try
    if (CredData.CredentialBlobSize mod SizeOf(Char)) <> 0 then
      raise Exception.Create('Gespeicherte Zugangsdaten haben ein ungueltiges Format.');
    if CredData.CredentialBlobSize > 0 then
      SetString(Result, PChar(CredData.CredentialBlob), CredData.CredentialBlobSize div SizeOf(Char));
  finally
    CredFree(CredData);
  end;
end;

// Store the secret for this Windows user, or delete it when the value is empty.
// Das Geheimnis fuer diesen Windows-Benutzer speichern oder bei leerem Wert loeschen.
procedure WriteServerSecret(const SettingsPath, SecretName, Value: string);
var
  CredData: Winapi.WinCred.CREDENTIALW;
  Target: string;
  ErrorCode: DWORD;
begin
  Target := ServerSecretTarget(SettingsPath, SecretName);
  if Value = '' then
  begin
    if not CredDelete(PChar(Target), CRED_TYPE_GENERIC, 0) then
    begin
      ErrorCode := GetLastError;
      if ErrorCode <> ServerCredentialNotFound then RaiseLastOSError(ErrorCode);
    end;
    Exit;
  end;
  FillChar(CredData, SizeOf(CredData), 0);
  CredData.&Type := CRED_TYPE_GENERIC;
  CredData.TargetName := PChar(Target);
  CredData.CredentialBlobSize := Length(Value) * SizeOf(Char);
  CredData.CredentialBlob := PByte(PChar(Value));
  CredData.Persist := CRED_PERSIST_LOCAL_MACHINE;
  if not CredWrite(@CredData, 0) then RaiseLastOSError;
end;

// Add missing sections without changing any existing bytes or values.
// Fehlende Abschnitte ergaenzen, ohne vorhandene Bytes oder Werte zu veraendern.
procedure EnsureExternalPaperlessSection(const SettingsPath: string);
var
  Stream: THandleStream;
  OriginalHandle, TempHandle: THandle;
  TempPath: string;
  OriginalExists, TempCreated, ReplaceAttempted: Boolean;
  Data, Added, ResultData: TBytes;
  Encoding: TEncoding;
  UnitSize, Offset, Start, LineStart, InsertAt, NextOffset: Integer;
  BigEndian, HasPaperless, HasVersions, InPaperless: Boolean;
  Line, Header, AddedText: string;
  Ch: Char;

// Read a character using the detected INI byte width and byte order.
// Ein Zeichen mit der erkannten Bytebreite und Byte-Reihenfolge der INI lesen.
  function ReadCharacter(Index: Integer): Char;
  begin
    if UnitSize = 1 then
      Result := Char(Data[Index])
    else if BigEndian then
      Result := Char((Word(Data[Index]) shl 8) or Data[Index + 1])
    else
      Result := Char(Word(Data[Index]) or (Word(Data[Index + 1]) shl 8));
  end;

begin
  OriginalHandle := INVALID_HANDLE_VALUE;
  TempHandle := INVALID_HANDLE_VALUE;
  TempCreated := False;
  ReplaceAttempted := False;
  OriginalExists := FileExists(SettingsPath);
  try
    if OriginalExists then
    begin
      // Deny concurrent writes, but allow Windows to replace the file.
      // Gleichzeitige Schreibzugriffe sperren, Dateiersetzung aber erlauben.
      OriginalHandle := CreateFile(PChar(SettingsPath), GENERIC_READ,
        FILE_SHARE_READ or FILE_SHARE_DELETE, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
      if OriginalHandle = INVALID_HANDLE_VALUE then RaiseLastOSError;
      Stream := THandleStream.Create(OriginalHandle);
      try
        if Stream.Size > MaxInt then
          raise Exception.Create('Die Einstellungsdatei ist zu gross.');
        SetLength(Data, Integer(Stream.Size));
        if Length(Data) > 0 then
          Stream.ReadBuffer(Data[0], Length(Data));
      finally
        Stream.Free;
      end;
    end
    else
      SetLength(Data, 0);
    UnitSize := 1;
    Start := 0;
    BigEndian := False;
    Encoding := TEncoding.UTF8;
    if (Length(Data) >= 4) and
       (((Data[0] = $FF) and (Data[1] = $FE) and (Data[2] = 0) and (Data[3] = 0)) or
        ((Data[0] = 0) and (Data[1] = 0) and (Data[2] = $FE) and (Data[3] = $FF))) then
      raise Exception.Create('UTF-32 wird fuer die Einstellungsdatei nicht unterstuetzt.');
    if (Length(Data) >= 2) and (Data[0] = $FF) and (Data[1] = $FE) then
    begin
      UnitSize := 2;
      Start := 2;
      Encoding := TEncoding.Unicode;
    end
    else if (Length(Data) >= 2) and (Data[0] = $FE) and (Data[1] = $FF) then
    begin
      UnitSize := 2;
      Start := 2;
      BigEndian := True;
      Encoding := TEncoding.BigEndianUnicode;
    end
    else if (Length(Data) >= 3) and (Data[0] = $EF) and (Data[1] = $BB) and (Data[2] = $BF) then
      Start := 3;
    if ((Length(Data) - Start) mod UnitSize) <> 0 then
      raise Exception.Create('Die Einstellungsdatei hat eine ungueltige Codierung.');

// Find section boundaries without rewriting the original INI content.
// Abschnittsgrenzen suchen, ohne den urspruenglichen INI-Inhalt umzuschreiben.
    HasPaperless := False;
    HasVersions := False;
    InPaperless := False;
    InsertAt := Length(Data);
    Offset := Start;
    while Offset < Length(Data) do
    begin
      LineStart := Offset;
      Line := '';
      while Offset < Length(Data) do
      begin
        Ch := ReadCharacter(Offset);
        if (Ch = #13) or (Ch = #10) then Break;
        Line := Line + Ch;
        Inc(Offset, UnitSize);
      end;
      NextOffset := Offset;
      while NextOffset < Length(Data) do
      begin
        Ch := ReadCharacter(NextOffset);
        if (Ch <> #13) and (Ch <> #10) then Break;
        Inc(NextOffset, UnitSize);
      end;
      Offset := NextOffset;
      Line := Trim(Line);
      if (Length(Line) >= 2) and (Line[1] = '[') and (Line[Length(Line)] = ']') then
      begin
        if InPaperless then
        begin
          InsertAt := LineStart;
          InPaperless := False;
        end;
        Header := Trim(Copy(Line, 2, Length(Line) - 2));
        if SameText(Header, 'Paperless Extern') then
        begin
          if not HasPaperless then
            InPaperless := True;
          HasPaperless := True;
        end;
        if SameText(Header, 'Versionen Extern') then
          HasVersions := True;
      end;
    end;
    if HasPaperless and HasVersions then Exit;

    AddedText := '';
    if not HasPaperless then
    begin
      InsertAt := Length(Data);
      AddedText := sLineBreak + '[Paperless Extern]' + sLineBreak;
    end;
    if not HasVersions then
      AddedText := AddedText + sLineBreak + '[Versionen Extern]' + sLineBreak;
    Added := Encoding.GetBytes(AddedText);
    SetLength(ResultData, Length(Data) + Length(Added));
    if InsertAt > 0 then Move(Data[0], ResultData[0], InsertAt);
    if Length(Added) > 0 then Move(Added[0], ResultData[InsertAt], Length(Added));
    if InsertAt < Length(Data) then
      Move(Data[InsertAt], ResultData[InsertAt + Length(Added)], Length(Data) - InsertAt);
    // Write and flush a new file before replacing the original.
    // Erst die neue Datei schreiben und leeren, dann das Original ersetzen.
    TempPath := SettingsPath + '.' + TGUID.NewGuid.ToString + '.tmp';
    TempHandle := CreateFile(PChar(TempPath), GENERIC_WRITE, 0, nil,
      CREATE_NEW, FILE_ATTRIBUTE_NORMAL, 0);
    if TempHandle = INVALID_HANDLE_VALUE then RaiseLastOSError;
    TempCreated := True;
    Stream := THandleStream.Create(TempHandle);
    try
      if Length(ResultData) > 0 then
        Stream.WriteBuffer(ResultData[0], Length(ResultData));
      if not FlushFileBuffers(TempHandle) then RaiseLastOSError;
    finally
      Stream.Free;
      CloseHandle(TempHandle);
      TempHandle := INVALID_HANDLE_VALUE;
    end;
    ReplaceAttempted := True;
    if OriginalExists then
    begin
      if not ReplaceFile(PChar(SettingsPath), PChar(TempPath), nil, 0, nil, nil) then
        RaiseLastOSError;
    end
    else if not MoveFileEx(PChar(TempPath), PChar(SettingsPath), MOVEFILE_WRITE_THROUGH) then
      RaiseLastOSError;
    TempCreated := False;
  finally
    if TempHandle <> INVALID_HANDLE_VALUE then CloseHandle(TempHandle);
    if OriginalHandle <> INVALID_HANDLE_VALUE then CloseHandle(OriginalHandle);
    // After a failed replace retain the temporary copy for recovery.
    // Nach fehlgeschlagener Ersetzung die temporaere Kopie zur Rettung erhalten.
    if TempCreated and not ReplaceAttempted then DeleteFile(PChar(TempPath));
  end;
end;

end.
