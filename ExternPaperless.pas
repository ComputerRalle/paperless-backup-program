unit ExternPaperless;

interface

procedure EnsureExternalPaperlessSection(const SettingsPath: string);

implementation

uses
  Winapi.Windows, System.SysUtils, System.Classes;

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
