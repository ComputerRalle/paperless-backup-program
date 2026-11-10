unit ExternPaperless;

interface

procedure EnsureExternalPaperlessSection(const SettingsPath: string);

implementation

uses
  System.SysUtils, System.Classes, AppConfig;

// Add only the missing section, preserving existing content and encoding.
// Nur den fehlenden Abschnitt ergaenzen und Inhalt sowie Codierung erhalten.
procedure EnsureExternalPaperlessSection(const SettingsPath: string);
var
  Ini: TAppSettingsIni;
  Stream: TFileStream;
  Prefix: array[0..2] of Byte;
  Count: Integer;
  Encoding: TEncoding;
  Bytes: TBytes;
begin
  Ini := TAppSettingsIni.Create(SettingsPath);
  try
    if Ini.SectionExists('Paperless Extern') then Exit;
  finally
    Ini.Free;
  end;
  if FileExists(SettingsPath) then
    Stream := TFileStream.Create(SettingsPath, fmOpenReadWrite or fmShareDenyWrite)
  else
    Stream := TFileStream.Create(SettingsPath, fmCreate);
  try
    Count := Stream.Read(Prefix, SizeOf(Prefix));
    Encoding := TEncoding.UTF8;
    if (Count >= 2) and (Prefix[0] = $FF) and (Prefix[1] = $FE) then
      Encoding := TEncoding.Unicode
    else if (Count >= 2) and (Prefix[0] = $FE) and (Prefix[1] = $FF) then
      Encoding := TEncoding.BigEndianUnicode;
    Bytes := Encoding.GetBytes(sLineBreak + '[Paperless Extern]' + sLineBreak);
    Stream.Seek(0, soEnd);
    Stream.WriteBuffer(Bytes[0], Length(Bytes));
  finally
    Stream.Free;
  end;
end;

end.
