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
// --------------------------------------------------------------

// Passwortbasierte Dateiverschlüsselung über Windows CNG: PBKDF2-HMAC-SHA256, getrennte AES-/HMAC-Schlüssel, AES-256-CBC und authentifizierter Dateikopf.
unit Crypto;

interface

uses
  System.SysUtils;

function EncryptBytesWithPassword(const PlainBytes: TBytes; const Password: string): TBytes;
function DecryptBytesWithPassword(const EncryptedBytes: TBytes; const Password: string): TBytes;
function EncryptStringWithPassword(const PlainText, Password: string): TBytes;
function DecryptStringWithPassword(const EncryptedBytes: TBytes; const Password: string): string;
procedure EncryptFileWithPassword(const SourceFile, TargetFile, Password: string);
procedure DecryptFileWithPassword(const SourceFile, TargetFile, Password: string);

implementation

uses
  System.Classes, System.IOUtils;

type
  NTSTATUS = LongInt;
  ULONG = Cardinal;
  BCRYPT_HANDLE = Pointer;
  BCRYPT_ALG_HANDLE = BCRYPT_HANDLE;
  BCRYPT_KEY_HANDLE = BCRYPT_HANDLE;
  BCRYPT_HASH_HANDLE = BCRYPT_HANDLE;

const
  STATUS_SUCCESS = NTSTATUS(0);
  BCRYPT_USE_SYSTEM_PREFERRED_RNG = ULONG($00000002);
  BCRYPT_ALG_HANDLE_HMAC_FLAG = ULONG($00000008);
  BCRYPT_BLOCK_PADDING = ULONG($00000001);

  BCRYPT_AES_ALGORITHM = 'AES';
  BCRYPT_SHA256_ALGORITHM = 'SHA256';
  BCRYPT_OBJECT_LENGTH = 'ObjectLength';
  BCRYPT_HASH_LENGTH = 'HashDigestLength';
  BCRYPT_CHAINING_MODE = 'ChainingMode';
  BCRYPT_CHAIN_MODE_CBC = 'ChainingModeCBC';

  CryptoMagic = 'CRPBCRYPT1';
  CryptoVersion = ULONG(1);
  SaltSize = 32;
  IvSize = 16;
  AesKeySize = 32;
  HmacKeySize = 32;
  DerivedKeySize = AesKeySize + HmacKeySize;
  Pbkdf2Iterations = ULONG(600000);

// Einen Windows-CNG-Algorithmusanbieter oeffnen.
function BCryptOpenAlgorithmProvider(
  out phAlgorithm: BCRYPT_ALG_HANDLE;
  pszAlgId: PWideChar;
  pszImplementation: PWideChar;
  dwFlags: ULONG): NTSTATUS; stdcall; external 'bcrypt.dll';

// Einen Windows-CNG-Algorithmusanbieter schließen.
function BCryptCloseAlgorithmProvider(
  hAlgorithm: BCRYPT_ALG_HANDLE;
  dwFlags: ULONG): NTSTATUS; stdcall; external 'bcrypt.dll';

// Einen Puffer mit kryptografisch sicheren Zufallsbytes fuellen.
function BCryptGenRandom(
  hAlgorithm: BCRYPT_ALG_HANDLE;
  pbBuffer: PByte;
  cbBuffer: ULONG;
  dwFlags: ULONG): NTSTATUS; stdcall; external 'bcrypt.dll';

// Eine Eigenschaft von einem Windows-CNG-Objekt lesen.
function BCryptGetProperty(
  hObject: BCRYPT_HANDLE;
  pszProperty: PWideChar;
  pbOutput: PByte;
  cbOutput: ULONG;
  out pcbResult: ULONG;
  dwFlags: ULONG): NTSTATUS; stdcall; external 'bcrypt.dll';

// Eine Eigenschaft an einem Windows-CNG-Objekt setzen.
function BCryptSetProperty(
  hObject: BCRYPT_HANDLE;
  pszProperty: PWideChar;
  pbInput: PByte;
  cbInput: ULONG;
  dwFlags: ULONG): NTSTATUS; stdcall; external 'bcrypt.dll';

// Schluesselmaterial aus einem Passwort mit PBKDF2 ableiten.
function BCryptDeriveKeyPBKDF2(
  hPrf: BCRYPT_ALG_HANDLE;
  pbPassword: PByte;
  cbPassword: ULONG;
  pbSalt: PByte;
  cbSalt: ULONG;
  cIterations: UInt64;
  pbDerivedKey: PByte;
  cbDerivedKey: ULONG;
  dwFlags: ULONG): NTSTATUS; stdcall; external 'bcrypt.dll';

// Einen symmetrischen Verschluesselungsschluessel aus Rohbytes erzeugen.
function BCryptGenerateSymmetricKey(
  hAlgorithm: BCRYPT_ALG_HANDLE;
  out phKey: BCRYPT_KEY_HANDLE;
  pbKeyObject: PByte;
  cbKeyObject: ULONG;
  pbSecret: PByte;
  cbSecret: ULONG;
  dwFlags: ULONG): NTSTATUS; stdcall; external 'bcrypt.dll';

// Ein Windows-CNG-Handle für symmetrische Schlüssel freigeben.
function BCryptDestroyKey(hKey: BCRYPT_KEY_HANDLE): NTSTATUS; stdcall; external 'bcrypt.dll';

// Bytes mit einem symmetrischen Windows-CNG-Schlüssel verschlüsseln.
function BCryptEncrypt(
  hKey: BCRYPT_KEY_HANDLE;
  pbInput: PByte;
  cbInput: ULONG;
  pPaddingInfo: Pointer;
  pbIV: PByte;
  cbIV: ULONG;
  pbOutput: PByte;
  cbOutput: ULONG;
  out pcbResult: ULONG;
  dwFlags: ULONG): NTSTATUS; stdcall; external 'bcrypt.dll';

// Bytes mit einem symmetrischen Windows-CNG-Schlüssel entschlüsseln.
function BCryptDecrypt(
  hKey: BCRYPT_KEY_HANDLE;
  pbInput: PByte;
  cbInput: ULONG;
  pPaddingInfo: Pointer;
  pbIV: PByte;
  cbIV: ULONG;
  pbOutput: PByte;
  cbOutput: ULONG;
  out pcbResult: ULONG;
  dwFlags: ULONG): NTSTATUS; stdcall; external 'bcrypt.dll';

// Ein Windows-CNG-Handle für Hash oder HMAC erzeugen.
function BCryptCreateHash(
  hAlgorithm: BCRYPT_ALG_HANDLE;
  out phHash: BCRYPT_HASH_HANDLE;
  pbHashObject: PByte;
  cbHashObject: ULONG;
  pbSecret: PByte;
  cbSecret: ULONG;
  dwFlags: ULONG): NTSTATUS; stdcall; external 'bcrypt.dll';

// Daten zu einer Windows-CNG-Hash- oder HMAC-Berechnung hinzufügen.
function BCryptHashData(
  hHash: BCRYPT_HASH_HANDLE;
  pbInput: PByte;
  cbInput: ULONG;
  dwFlags: ULONG): NTSTATUS; stdcall; external 'bcrypt.dll';

// Eine Windows-CNG-Hash- oder HMAC-Berechnung abschliessen.
function BCryptFinishHash(
  hHash: BCRYPT_HASH_HANDLE;
  pbOutput: PByte;
  cbOutput: ULONG;
  dwFlags: ULONG): NTSTATUS; stdcall; external 'bcrypt.dll';

// Ein Windows-CNG-Hash-Handle freigeben.
function BCryptDestroyHash(hHash: BCRYPT_HASH_HANDLE): NTSTATUS; stdcall; external 'bcrypt.dll';

// Convert failing NTSTATUS values into Delphi exceptions with context.
// Fehlgeschlagene NTSTATUS-Werte mit Kontext in Delphi-Exceptions umwandeln.
procedure CheckStatus(const Status: NTSTATUS; const Operation: string);
begin
  if Status <> STATUS_SUCCESS then
    raise Exception.Create(Operation + ' fehlgeschlagen. NTSTATUS=$' + IntToHex(Cardinal(Status), 8));
end;

// Einen beschreibbaren Byte-Zeiger oder nil für ein leeres Byte-Array zurückgeben.
function BytesData(var Bytes: TBytes): PByte;
begin
  if Length(Bytes) = 0 then
    Result := nil
  else
    Result := PByte(Pointer(Bytes));
end;

// Einen lesenden Byte-Zeiger oder nil für ein leeres Byte-Array zurückgeben.
function ConstBytesData(const Bytes: TBytes): PByte;
begin
  if Length(Bytes) = 0 then
    Result := nil
  else
    Result := PByte(Pointer(Bytes));
end;

// Ein Byte-Array an ein anderes anhängen.
procedure AppendBytes(var Target: TBytes; const Source: TBytes);
var
  OldLength: Integer;
begin
  OldLength := Length(Target);
  SetLength(Target, OldLength + Length(Source));
  if Length(Source) > 0 then
    Move(Source[0], Target[OldLength], Length(Source));
end;

// Eine vorzeichenlose 32-Bit-Zahl an ein Byte-Array anhängen.
procedure AppendUInt32(var Target: TBytes; const Value: ULONG);
var
  OldLength: Integer;
begin
  OldLength := Length(Target);
  SetLength(Target, OldLength + SizeOf(Value));
  Move(Value, Target[OldLength], SizeOf(Value));
end;

// Eine vorzeichenlose 32-Bit-Zahl aus einem Byte-Array lesen und den Offset weiterstellen.
function ReadUInt32(const Source: TBytes; var Offset: Integer): ULONG;
begin
  if Offset + SizeOf(Result) > Length(Source) then
    raise Exception.Create('Verschluesselte Daten sind unvollstaendig.');
  Move(Source[Offset], Result, SizeOf(Result));
  Inc(Offset, SizeOf(Result));
end;

// Eine feste Anzahl Bytes lesen und den Offset weiterstellen.
function ReadBytes(const Source: TBytes; var Offset: Integer; const Count: Integer): TBytes;
begin
  if (Count < 0) or (Offset + Count > Length(Source)) then
    raise Exception.Create('Verschluesselte Daten sind unvollstaendig.');
  SetLength(Result, Count);
  if Count > 0 then
    Move(Source[Offset], Result[0], Count);
  Inc(Offset, Count);
end;

// Kryptografisch sichere Zufallsbytes über Windows CNG erzeugen.
function RandomBytes(const Count: Integer): TBytes;
begin
  SetLength(Result, Count);
  if Count > 0 then
    CheckStatus(BCryptGenRandom(nil, BytesData(Result), Count, BCRYPT_USE_SYSTEM_PREFERRED_RNG), 'Zufallsdaten erzeugen');
end;

// Eine vorzeichenlose Integer-Eigenschaft von einem Windows-CNG-Handle lesen.
function GetUInt32Property(const Handle: BCRYPT_HANDLE; const PropertyName: string): ULONG;
var
  ResultSize: ULONG;
begin
  Result := 0;
  CheckStatus(
    BCryptGetProperty(Handle, PWideChar(PropertyName), PByte(@Result), SizeOf(Result), ResultSize, 0),
    'Crypto-Eigenschaft lesen');
end;

// Eine Zeichenketten-Eigenschaft an einem Windows-CNG-Handle setzen.
procedure SetStringProperty(const Handle: BCRYPT_HANDLE; const PropertyName, Value: string);
begin
  CheckStatus(
    BCryptSetProperty(Handle, PWideChar(PropertyName), PByte(PWideChar(Value)), (Length(Value) + 1) * SizeOf(WideChar), 0),
    'Crypto-Eigenschaft setzen');
end;

// Leitet mit PBKDF2-HMAC-SHA256 Schlüsselmaterial aus dem UTF-8-Passwort und zufälligem Salt ab.
// Die Aufrufer trennen daraus AES- und HMAC-Schlüssel; Windows-CNG-Handles werden im finally-Block freigegeben.
function DeriveKeys(const Password: string; const Salt: TBytes): TBytes;
var
  Alg: BCRYPT_ALG_HANDLE;
  PasswordBytes: TBytes;
begin
  Alg := nil;
  SetLength(Result, DerivedKeySize);
  PasswordBytes := TEncoding.UTF8.GetBytes(Password);
  CheckStatus(BCryptOpenAlgorithmProvider(Alg, PWideChar(BCRYPT_SHA256_ALGORITHM), nil, BCRYPT_ALG_HANDLE_HMAC_FLAG), 'PBKDF2 vorbereiten');
  try
    CheckStatus(
      BCryptDeriveKeyPBKDF2(
        Alg,
        ConstBytesData(PasswordBytes), Length(PasswordBytes),
        ConstBytesData(Salt), Length(Salt),
        Pbkdf2Iterations,
        BytesData(Result), Length(Result),
        0),
      'Schluessel ableiten');
  finally
    BCryptCloseAlgorithmProvider(Alg, 0);
  end;
end;

// Einen geprueften Bytebereich aus einem groesseren Byte-Array kopieren.
function SliceBytes(const Source: TBytes; const Offset, Count: Integer): TBytes;
begin
  if (Offset < 0) or (Count < 0) or (Offset + Count > Length(Source)) then
    raise Exception.Create('Interner Crypto-Fehler: ungueltiger Bytebereich.');
  SetLength(Result, Count);
  if Count > 0 then
    Move(Source[Offset], Result[0], Count);
end;

// Bytes mit AES-256-CBC und Block-Padding ver- oder entschlüsseln.
function AesCrypt(const Input, AesKey, Iv: TBytes; const Encrypt: Boolean): TBytes;
var
  Alg: BCRYPT_ALG_HANDLE;
  Key: BCRYPT_KEY_HANDLE;
  KeyObject, WorkIv: TBytes;
  ObjectLength, ResultSize: ULONG;
begin
  Alg := nil;
  Key := nil;
  CheckStatus(BCryptOpenAlgorithmProvider(Alg, PWideChar(BCRYPT_AES_ALGORITHM), nil, 0), 'AES vorbereiten');
  try
    SetStringProperty(Alg, BCRYPT_CHAINING_MODE, BCRYPT_CHAIN_MODE_CBC);
    ObjectLength := GetUInt32Property(Alg, BCRYPT_OBJECT_LENGTH);
    SetLength(KeyObject, ObjectLength);
    CheckStatus(
      BCryptGenerateSymmetricKey(Alg, Key, BytesData(KeyObject), Length(KeyObject), ConstBytesData(AesKey), Length(AesKey), 0),
      'AES-Schluessel erzeugen');
    try
      WorkIv := Copy(Iv, 0, Length(Iv));
      ResultSize := 0;
      if Encrypt then
        CheckStatus(BCryptEncrypt(Key, ConstBytesData(Input), Length(Input), nil, BytesData(WorkIv), Length(WorkIv), nil, 0, ResultSize, BCRYPT_BLOCK_PADDING), 'AES-Ausgabegroesse ermitteln')
      else
        CheckStatus(BCryptDecrypt(Key, ConstBytesData(Input), Length(Input), nil, BytesData(WorkIv), Length(WorkIv), nil, 0, ResultSize, BCRYPT_BLOCK_PADDING), 'AES-Ausgabegroesse ermitteln');

      SetLength(Result, ResultSize);
      WorkIv := Copy(Iv, 0, Length(Iv));
      if Encrypt then
        CheckStatus(BCryptEncrypt(Key, ConstBytesData(Input), Length(Input), nil, BytesData(WorkIv), Length(WorkIv), BytesData(Result), Length(Result), ResultSize, BCRYPT_BLOCK_PADDING), 'AES verschluesseln')
      else
        CheckStatus(BCryptDecrypt(Key, ConstBytesData(Input), Length(Input), nil, BytesData(WorkIv), Length(WorkIv), BytesData(Result), Length(Result), ResultSize, BCRYPT_BLOCK_PADDING), 'AES entschluesseln');
      SetLength(Result, ResultSize);
    finally
      BCryptDestroyKey(Key);
    end;
  finally
    BCryptCloseAlgorithmProvider(Alg, 0);
  end;
end;

// Einen HMAC-SHA256 über die angegebenen Daten berechnen.
function HmacSha256(const Data, HmacKey: TBytes): TBytes;
var
  Alg: BCRYPT_ALG_HANDLE;
  Hash: BCRYPT_HASH_HANDLE;
  HashObject: TBytes;
  ObjectLength, HashLength, ResultSize: ULONG;
begin
  Alg := nil;
  Hash := nil;
  CheckStatus(BCryptOpenAlgorithmProvider(Alg, PWideChar(BCRYPT_SHA256_ALGORITHM), nil, BCRYPT_ALG_HANDLE_HMAC_FLAG), 'HMAC vorbereiten');
  try
    ObjectLength := GetUInt32Property(Alg, BCRYPT_OBJECT_LENGTH);
    HashLength := GetUInt32Property(Alg, BCRYPT_HASH_LENGTH);
    SetLength(HashObject, ObjectLength);
    SetLength(Result, HashLength);
    CheckStatus(
      BCryptCreateHash(Alg, Hash, BytesData(HashObject), Length(HashObject), ConstBytesData(HmacKey), Length(HmacKey), 0),
      'HMAC erzeugen');
    try
      if Length(Data) > 0 then
        CheckStatus(BCryptHashData(Hash, ConstBytesData(Data), Length(Data), 0), 'HMAC Daten schreiben');
      CheckStatus(BCryptFinishHash(Hash, BytesData(Result), Length(Result), 0), 'HMAC abschliessen');
    finally
      BCryptDestroyHash(Hash);
    end;
  finally
    BCryptCloseAlgorithmProvider(Alg, 0);
  end;
end;

// Vergleicht gleich lange Bytefolgen ohne frühen Abbruch bei unterschiedlichem Inhalt.
// Abweichende Längen werden vorab erkannt; dies ist keine Zusicherung konstanter Laufzeit des gesamten Entschlüsselungsablaufs.
function SameBytesConstantTime(const Left, Right: TBytes): Boolean;
var
  I: Integer;
  Diff: Byte;
begin
  Result := Length(Left) = Length(Right);
  if not Result then Exit;
  Diff := 0;
  for I := 0 to Length(Left) - 1 do
    Diff := Diff or (Left[I] xor Right[I]);
  Result := Diff = 0;
end;

// Serialisiert Magic, Version, Iterationen und Längen als Dateikopf, danach Salt, IV, Ciphertext und HMAC.
// Mit leerem HMAC entsteht exakt der Datenbereich, der vor dem Anhängen des Prüfcodes authentifiziert wird.
function BuildEncryptedPayload(const Salt, Iv, CipherText, Hmac: TBytes): TBytes;
var
  MagicBytes: TBytes;
begin
  MagicBytes := TEncoding.ASCII.GetBytes(string(CryptoMagic));
  Result := nil;
  AppendBytes(Result, MagicBytes);
  AppendUInt32(Result, CryptoVersion);
  AppendUInt32(Result, Pbkdf2Iterations);
  AppendUInt32(Result, Length(Salt));
  AppendUInt32(Result, Length(Iv));
  AppendUInt32(Result, Length(CipherText));
  AppendBytes(Result, Salt);
  AppendBytes(Result, Iv);
  AppendBytes(Result, CipherText);
  AppendBytes(Result, Hmac);
end;

// Rohbytes mit einem Passwort verschlüsseln und die vollstaendige portable Nutzlast zurückgeben.
function EncryptBytesWithPassword(const PlainBytes: TBytes; const Password: string): TBytes;
var
  Salt, Iv, Keys, AesKey, HmacKey, CipherText, AuthenticatedData, Hmac: TBytes;
begin
  if Password = '' then
    raise Exception.Create('Passwort darf nicht leer sein.');

  Salt := RandomBytes(SaltSize);
  Iv := RandomBytes(IvSize);
  Keys := DeriveKeys(Password, Salt);
  AesKey := SliceBytes(Keys, 0, AesKeySize);
  HmacKey := SliceBytes(Keys, AesKeySize, HmacKeySize);
  CipherText := AesCrypt(PlainBytes, AesKey, Iv, True);

  // Der HMAC umfasst Header, Parameter und Ciphertext, aber nicht den angehängten HMAC selbst.
  AuthenticatedData := BuildEncryptedPayload(Salt, Iv, CipherText, nil);
  Hmac := HmacSha256(AuthenticatedData, HmacKey);
  Result := BuildEncryptedPayload(Salt, Iv, CipherText, Hmac);
end;

// Validiert Dateiformat, unterstützte Parameter und exakte Nutzlastlänge und prüft danach den HMAC.
// Erst bei gültigem HMAC wird AES entschlüsselt; falsches Passwort und veränderte Nutzlast ergeben dieselbe Fehlermeldung.
function DecryptBytesWithPassword(const EncryptedBytes: TBytes; const Password: string): TBytes;
var
  Offset: Integer;
  MagicBytes, ExpectedMagic, Salt, Iv, CipherText, StoredHmac, Keys, AesKey, HmacKey, AuthenticatedData, CalculatedHmac: TBytes;
  Version, Iterations, SaltLength, IvLength, CipherLength: ULONG;
begin
  if Password = '' then
    raise Exception.Create('Passwort darf nicht leer sein.');

  Offset := 0;
  ExpectedMagic := TEncoding.ASCII.GetBytes(string(CryptoMagic));
  MagicBytes := ReadBytes(EncryptedBytes, Offset, Length(ExpectedMagic));
  if not SameBytesConstantTime(MagicBytes, ExpectedMagic) then
    raise Exception.Create('Unbekanntes Crypto-Dateiformat.');

  Version := ReadUInt32(EncryptedBytes, Offset);
  if Version <> CryptoVersion then
    raise Exception.Create('Nicht unterstuetzte Crypto-Version.');

  Iterations := ReadUInt32(EncryptedBytes, Offset);
  if Iterations <> Pbkdf2Iterations then
    raise Exception.Create('Nicht unterstuetzte PBKDF2-Iterationenzahl.');

  SaltLength := ReadUInt32(EncryptedBytes, Offset);
  IvLength := ReadUInt32(EncryptedBytes, Offset);
  CipherLength := ReadUInt32(EncryptedBytes, Offset);
  Salt := ReadBytes(EncryptedBytes, Offset, SaltLength);
  Iv := ReadBytes(EncryptedBytes, Offset, IvLength);
  CipherText := ReadBytes(EncryptedBytes, Offset, CipherLength);
  StoredHmac := ReadBytes(EncryptedBytes, Offset, 32);

  if Offset <> Length(EncryptedBytes) then
    raise Exception.Create('Verschluesselte Daten enthalten unerwartete Zusatzdaten.');

  Keys := DeriveKeys(Password, Salt);
  AesKey := SliceBytes(Keys, 0, AesKeySize);
  HmacKey := SliceBytes(Keys, AesKeySize, HmacKeySize);
  // Der HMAC umfasst Header, Parameter und Ciphertext, aber nicht den angehängten HMAC selbst.
  AuthenticatedData := BuildEncryptedPayload(Salt, Iv, CipherText, nil);
  CalculatedHmac := HmacSha256(AuthenticatedData, HmacKey);
  if not SameBytesConstantTime(StoredHmac, CalculatedHmac) then
    raise Exception.Create('Passwort falsch oder verschluesselte Daten wurden veraendert.');

  // Keine Entschlüsselung unauthentifizierter Daten: Der HMAC wurde unmittelbar zuvor geprüft.
  Result := AesCrypt(CipherText, AesKey, Iv, False);
end;

// Eine UTF-8-Zeichenkette mit einem Passwort verschlüsseln.
function EncryptStringWithPassword(const PlainText, Password: string): TBytes;
begin
  Result := EncryptBytesWithPassword(TEncoding.UTF8.GetBytes(PlainText), Password);
end;

// Bytes entschlüsseln und den Klartext als UTF-8-Zeichenkette zurückgeben.
function DecryptStringWithPassword(const EncryptedBytes: TBytes; const Password: string): string;
begin
  Result := TEncoding.UTF8.GetString(DecryptBytesWithPassword(EncryptedBytes, Password));
end;

// Eine Datei mit einem Passwort verschlüsseln und die verschluesselte Zieldatei schreiben.
procedure EncryptFileWithPassword(const SourceFile, TargetFile, Password: string);
begin
  TFile.WriteAllBytes(TargetFile, EncryptBytesWithPassword(TFile.ReadAllBytes(SourceFile), Password));
end;

// Eine Datei mit einem Passwort entschlüsseln und die Klartext-Zieldatei schreiben.
procedure DecryptFileWithPassword(const SourceFile, TargetFile, Password: string);
begin
  TFile.WriteAllBytes(TargetFile, DecryptBytesWithPassword(TFile.ReadAllBytes(SourceFile), Password));
end;

end.
