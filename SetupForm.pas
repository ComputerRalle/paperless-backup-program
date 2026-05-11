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

unit SetupForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, System.IOUtils, ShellAPI, System.IniFiles;

type
  TSetupFrm = class(TForm)
    HinweisVerstandenBtn: TButton;
    Panel14: TPanel;
    Label8: TLabel;
    Label9: TLabel;
    StatusBar1: TStatusBar;
    PaperlessInstallierenBtn: TButton;
    DockerGefundenLbl: TLabel;
    BitteBestaetigenLbl: TLabel;
    SieBenoetigenDockerLbl: TLabel;
    LinkKlickLbl: TLabel;
    HinweisMemo: TMemo;
    Label1: TLabel;
    KeePassXCLbl: TLabel;
    WillkommenLbl: TLabel;
    ComputerRalleLbl: TLabel;
    InstallLbl: TLabel;
    ProgressBar2: TProgressBar;
    InstallationCancelBtn: TButton;
    procedure NoticeAcceptedBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure InstallPaperlessBtnClick(Sender: TObject);
    function RunCommand(const ExeName, Params: string; out ExitCode: Cardinal): Boolean;
    function IsDockerInPath: Boolean;
    procedure CreateDockerComposeFile;
    procedure StartDockerCompose;
    procedure LinkClickLblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    function RunCommandAndCapture(const ExeName: string; const Params: array of string; Output: TStrings): Boolean;
    procedure CheckPaperlessContainerStatus;
    procedure KeePassXCLblClick(Sender: TObject);
    procedure CheckDockerAvailable;
    procedure ComputerRalleLblClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure WriteImageVersion(const TargetPath: string);
    procedure InstallationCancelBtnClick(Sender: TObject);

  private
    { Private declarations }
    { Private Deklarationen }
  public
    { Public declarations }
    { Öffentliche Deklarationen }
  end;

var
  SetupFrm: TSetupFrm;
  // Current Docker/Paperless status shown on the notice form.
  // Aktueller Docker-/Paperless-Status, der im Hinweisfenster angezeigt wird.
  PaperlessContainerExists: Boolean;
  PaperlessContainerRunning: Boolean;
  DockerAvailable: Boolean;
  TerminateApplicationOnClose: Boolean;
  // Docker image versions
  // Docker-Image-Versionen
  paperless_ngx_version: string;
  postgresql_version: string;
  redis_version: string;
  gotenberg_version: string;
  tika_version: string;
  alpine_version: string;
  busybox_version: string;

implementation

{$R *.dfm}

uses
  Mainform, DockerComposeGenerator, AppConfig, AppLogger, AppDialogs;
// Generate a per-installation Paperless secret key.
// Einen Paperless Secret Key pro Installation erzeugen.
function GeneratePaperlessSecretKey: string;
var
  Guid: TGUID;
begin
  Result := '';
  while Length(Result) < 64 do
  begin
    CreateGUID(Guid);
    Result := Result + StringReplace(StringReplace(GUIDToString(Guid), '{', '', []), '}', '', []);
    Result := StringReplace(Result, '-', '', [rfReplaceAll]);
  end;
  Result := Copy(Result, 1, 64);
end;
// Read an existing Paperless secret key from docker-compose.yml.
// Einen vorhandenen Paperless Secret Key aus docker-compose.yml lesen.
function ReadPaperlessSecretKeyFromCompose(const ComposePath: string): string;
const
  SecretPrefix = 'PAPERLESS_SECRET_KEY:';
var
  Lines: TStringList;
  I, PrefixPos: Integer;
  Line: string;
begin
  Result := '';
  if not FileExists(ComposePath) then Exit;
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(ComposePath, TEncoding.UTF8);
    for I := 0 to Lines.Count - 1 do
    begin
      Line := Trim(Lines[I]);
      PrefixPos := Pos(SecretPrefix, Line);
      if PrefixPos = 1 then
      begin
        Result := Trim(Copy(Line, Length(SecretPrefix) + 1, MaxInt));
        Result := StringReplace(Result, '"', '', [rfReplaceAll]);
        Exit;
      end;
    end;
  finally
    Lines.Free;
  end;
end;
// Reuse the saved key, import an existing compose key, migrate a legacy key, or create a new key.
// Gespeicherten Key verwenden, vorhandenen Compose-Key importieren, Legacy-Key migrieren oder neuen Key erzeugen.
function GetOrCreatePaperlessSecretKey(const Ini: TIniFile; const ComposePath: string): string;
var
  StoredKey, ComposeKey, LegacyStoredKey: string;
begin
  StoredKey := Ini.ReadString(IniSectionSecurity, IniKeyPaperlessSecretKey, '').Trim;
  LegacyStoredKey := Ini.ReadString(IniSectionSecurity, IniKeyLegacyPaperlessSecretKey, '').Trim;
  if (StoredKey <> '') and (StoredKey <> LegacyPaperlessSecretKey) then
  begin
    Result := StoredKey;
    Exit;
  end;
  ComposeKey := ReadPaperlessSecretKeyFromCompose(ComposePath);
  if ComposeKey <> '' then
  begin
    Result := ComposeKey;
    if ComposeKey = LegacyPaperlessSecretKey then
    begin
      Ini.WriteString(IniSectionSecurity, IniKeyLegacyPaperlessSecretKey, ComposeKey);
      Ini.DeleteKey(IniSectionSecurity, IniKeyPaperlessSecretKey);
      LogWarning('Legacy Paperless secret key imported from docker-compose.yml.');
    end
    else
    begin
      Ini.WriteString(IniSectionSecurity, IniKeyPaperlessSecretKey, ComposeKey);
      LogInfo('Existing Paperless secret key imported from docker-compose.yml.');
    end;
    Ini.UpdateFile;
    Exit;
  end;
  if LegacyStoredKey <> '' then
  begin
    Result := LegacyStoredKey;
    LogWarning('Legacy Paperless secret key reused from Einstellungen.ini.');
    Exit;
  end;
  if StoredKey = LegacyPaperlessSecretKey then
  begin
    Result := StoredKey;
    Ini.WriteString(IniSectionSecurity, IniKeyLegacyPaperlessSecretKey, StoredKey);
    Ini.DeleteKey(IniSectionSecurity, IniKeyPaperlessSecretKey);
    Ini.UpdateFile;
    LogWarning('Legacy Paperless secret key migrated to separate INI key.');
    Exit;
  end;
  Result := GeneratePaperlessSecretKey;
  Ini.WriteString(IniSectionSecurity, IniKeyPaperlessSecretKey, Result);
  Ini.UpdateFile;
  LogInfo('New Paperless secret key generated and saved.');
end;
// Write the active Paperless secret key into the backup folder.
// Den aktiven Paperless Secret Key in den Backup-Ordner schreiben.
procedure WritePaperlessSecretKeyBackup(const TargetPath: string; const Ini: TIniFile);
var
  ComposePath, SecretKey: string;
  Txt: TStringList;
begin
  SecretKey := Ini.ReadString(IniSectionSecurity, IniKeyPaperlessSecretKey, '').Trim;
  if SecretKey = LegacyPaperlessSecretKey then
    SecretKey := '';
  if SecretKey = '' then
  begin
    ComposePath := IncludeTrailingPathDelimiter(Mainform.AppDataFolder) + DockerComposeFileName;
    SecretKey := ReadPaperlessSecretKeyFromCompose(ComposePath);
  end;
  if SecretKey = '' then
    SecretKey := Ini.ReadString(IniSectionSecurity, IniKeyLegacyPaperlessSecretKey, '').Trim;
  if SecretKey = '' then
    SecretKey := Ini.ReadString(IniSectionSecurity, IniKeyPaperlessSecretKey, '').Trim;
  Txt := TStringList.Create;
  try
    Txt.Add('PAPERLESS_SECRET_KEY=' + SecretKey);
    Txt.SaveToFile(IncludeTrailingPathDelimiter(TargetPath) + PaperlessSecretKeyFileName, TEncoding.UTF8);
    LogInfo('Paperless secret key backup file written.');
  finally
    Txt.Free;
  end;
end;
// Close the whole program when the notice form was opened as the first form.
// Das gesamte Programm schließen, wenn das Hinweisfenster als erstes Fenster geöffnet wurde.
procedure TSetupFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if TerminateApplicationOnClose = True then Application.Terminate;
end;

// Make this form appear as a normal window in the Windows taskbar.
// Dieses Formular als normales Fenster in der Windows-Taskleiste anzeigen.
procedure TSetupFrm.FormCreate(Sender: TObject);
begin
  SetWindowLong(Handle, GWL_EXSTYLE,
  GetWindowLong(Handle, GWL_EXSTYLE) or WS_EX_APPWINDOW);
  SetWindowLong(Handle, GWL_HWNDPARENT, 0);
end;

// Prepare the notice window and show the correct installation state.
// Das Hinweisfenster vorbereiten und den passenden Installationsstatus anzeigen.
procedure TSetupFrm.FormShow(Sender: TObject);
begin
  TerminateApplicationOnClose := True;
  WantsInstall := False;
  DockerAvailable := False;
  ShouldOpenPaperless := False;
   Panel14.ParentBackground := False;
  Panel14.StyleElements := Panel14.StyleElements - [seClient];
  Panel14.Color := $00234D11;
  StatusBar1.Panels.Clear;
  StatusBar1.Height:= 25;
  StatusBar1.Font.Size:= 10;
  StatusBar1.Font.Style:= [fsBold];
  StatusBar1.Panels.Add.Text := ' ' + AppStatusTitle + MainformFrm.GetFileVersion(Application.ExeName);
  InstallLbl.Visible := False;
  InstallLbl.AutoSize := False;
  InstallLbl.Caption := '';
  ProgressBar2.Min := 0;
  ProgressBar2.Max := 100;
  ProgressBar2.Position := 0;
  ProgressBar2.Visible := False;
  InstallationCancelBtn.Visible := False;
  InstallationCancelBtn.Enabled := False;
  // Make link labels readable in dark mode.
  // Link-Beschriftungen im dunklen Modus lesbar machen.
  with LinkKlickLbl do
  begin
    StyleElements := StyleElements - [seFont];
    Transparent := True;
    Font.Color := clYellow;
  end;

  with ComputerRalleLbl do
  begin
    StyleElements := StyleElements - [seFont];
    Transparent := True;
    Font.Color := clYellow;
  end;

  if FileExists(NoticeFilePath) then
  begin
     PaperlessInstallierenBtn.Enabled := False;
  end
  else
  begin
    PaperlessInstallierenBtn.Enabled := True;
  end;

  // Check whether Docker and Paperless are already available.
  // Prüfen, ob Docker und Paperless bereits verfügbar sind.
  CheckDockerAvailable;
  if not DockerAvailable then Exit;
  if DockerAvailable = True then
  begin
    SieBenoetigenDockerLbl.Caption := 'Docker ist Installiert. Sie können Paperless installieren.';
    WillkommenLbl.Visible := True;
    SieBenoetigenDockerLbl.Refresh;
    Label1.Visible := False;
    LinkKlickLbl.Visible := False;
    WillkommenLbl.Visible := True;
    ComputerRalleLbl.Visible := True;
  end;

  CheckPaperlessContainerStatus;
  if PaperlessContainerExists = True then
  begin
    // Paperless is installed, so the user can open it directly.
    // Paperless ist installiert, daher kann der Benutzer es direkt öffnen.
    DockerGefundenLbl.Caption := 'Paperless Container gefunden. Installation nicht notwendig.';
    WillkommenLbl.Visible := True;
    ComputerRalleLbl.Visible := True;
    LinkKlickLbl.Caption:= PaperlessLocalUrl;
    IsPaperlessInstallation := True;
    Label1.Caption:= 'Paperless öffnen:';
    DockerGefundenLbl.Visible := True;
    with PaperlessInstallierenBtn do
    begin
      Enabled := False;
      Default := False;
      Cancel := False;
      Visible := True;
    end;
    HinweisVerstandenBtn.Default := True;
    HinweisVerstandenBtn.SetFocus;
  end;

  if PaperlessContainerRunning = True then
  begin
    // Paperless is running, so the user can open it directly.
    // Paperless läuft, daher kann der Benutzer es direkt öffnen.
    DockerGefundenLbl.Caption := 'Paperless Container gefunden. Installation nicht notwendig.';
    LinkKlickLbl.Caption:= PaperlessLocalUrl;
    IsPaperlessInstallation := True;
    Label1.Caption:= 'Paperless öffnen:';
    DockerGefundenLbl.Visible := True;
    with PaperlessInstallierenBtn do
    begin
      Enabled := False;
      Default := False;
      Cancel := False;
      Visible := True;
    end;
    HinweisVerstandenBtn.Default := True;
    HinweisVerstandenBtn.SetFocus;
  end;
end;

// Save that the first notice was accepted and close the setup notice form.
// Speichern, dass der erste Hinweis akzeptiert wurde, und das Hinweisfenster schliessen.
procedure TSetupFrm.NoticeAcceptedBtnClick(Sender: TObject);
var
  Ini: TIniFile;
begin
  TerminateApplicationOnClose := False;
  if not DirectoryExists(Mainform.AppDataFolder) then ForceDirectories(AppDataFolder);
  // Store this state in the INI file.
  // Diesen Zustand in der INI-Datei speichern.
  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(Mainform.AppDataFolder) + SettingsFileName);
   try
    try
      Ini.WriteString('Einrichtung', 'Hinweis verstanden', 'Ja');
    except
      CenteredShowMessage('Einstellungen.ini kann nicht geschrieben werden. Rechte?');
    end;
   finally
    Ini.Free;
   end;
   Close;
end;

// Start the first Paperless setup after the user confirms it.
// Die erste Paperless-Einrichtung starten, nachdem der Benutzer bestätigt hat.
procedure TSetupFrm.InstallPaperlessBtnClick(Sender: TObject);
var
  InstallErfolgreich: Boolean;
  ExitCode: Cardinal;
  Ini:TiniFile;
begin
  WantsInstall := True;
  BorderIcons := [];
  BorderStyle := bsSingle;
  // Step 1: Check whether Docker is available in the system PATH.
  // Schritt 1: Prüfen, ob Docker im System-PATH verfügbar ist.
  if not IsDockerInPath then
  begin
    CenteredMessageBox(
    'Docker wurde nicht gefunden.' + #13#10 +
    'Bitte installieren Sie Docker Desktop ganz normal,' + #13#10 +
    'ohne „Als Administrator ausführen“ zu verwenden.' + #13#10 +
    'Starten Sie danach den Computer neu und wiederholen Sie die Installation mit Paperless Backup Programm',
    'Fehler',
    MB_OK or MB_ICONERROR or MB_TOPMOST);
    WantsInstall := False;
    ComputerRalleLbl.Visible := False;
    HinweisVerstandenBtn.Enabled := False;
    WillkommenLbl.Visible := False;
    LinkKlickLbl.Visible := False;
    Exit;
  end else
  begin
    DockerGefundenLbl.Visible := True;
    DockerAvailable := True;
  end;
  // Step 2: Ask for confirmation before installation.
  // Schritt 2: Vor der Installation nach Bestätigung fragen.
  if CenteredMessageDlg('Möchten Sie Paperless jetzt installieren?', mtConfirmation, [mbYes, mbNo], 0) = mrNo then
  begin
    WantsInstall := False;
    IsPaperlessInstallation := False;
    ShouldOpenPaperless := False;
    Exit;
  end;
  IsPaperlessInstallation := True;
  ShouldOpenPaperless := True;
  PaperlessInstallierenBtn.Enabled := False;
  HinweisVerstandenBtn.Enabled := False;
  //InstallationCancelBtn.Visible := True;
  //InstallationCancelBtn.Enabled := True;

  // Create the desktop consume folder if it does not exist.
  // Den Consume-Ordner auf dem Desktop erstellen, falls er nicht existiert.
  PaperlessInput := IncludeTrailingPathDelimiter(GetEnvironmentVariable('USERPROFILE')) + 'Desktop\Paperless-Input';
  if not DirectoryExists(PaperlessInput) then ForceDirectories(PaperlessInput);

  // Step 3: Check whether Docker is working.
  // Schritt 3: Prüfen, ob Docker funktioniert.
  if not Self.RunCommand('docker', 'info', ExitCode) or (ExitCode <> 0) then
  begin
    CenteredMessageBox(
      'Docker Desktop scheint nicht installiert oder gestartet zu sein, der Befehl "docker" funktioniert nicht korrekt.' + #13#10 + #13#10 +
      'Stellen Sie sicher, dass Docker installiert und gestartet ist.' + #13#10 +
      'Installieren und starten sie Docker Desktop. Sie werden zusätzlich zur Downloadseite von Docker Desktop geleitet.',
      'Fehler',
      MB_OK or MB_ICONERROR or MB_TOPMOST);
      WantsInstall := False;
      ComputerRalleLbl.Visible := False;
      HinweisVerstandenBtn.Enabled := False;
      WillkommenLbl.Visible := False;
      LinkKlickLbl.Visible := False;
      ShellExecute(0, 'open', DockerDesktopUrl, nil, nil, SW_SHOWNORMAL);
      Application.Terminate;
      // Keep this Exit in case code is added below later.
      // Dieses Exit beibehalten, falls später darunter Code ergänzt wird.
      Exit;
  end else
  begin
    // Docker is ready.
    // Docker ist bereit.
    DockerAvailable := True;
  end;

  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(Mainform.AppDataFolder) + SettingsFileName);
  try
     try
      // Save the installation state before running the script.
      // Den Installationsstatus speichern, bevor das Skript ausgeführt wird.
      Ini.WriteString('Einrichtung', 'Installation abgeschlossen', 'Ja');
     except
       CenteredShowMessage('Einstellungen.ini kann nicht geschrieben werden. Rechte?');
     end;
  finally
     Ini.Free;
  end;

  CreateDockerComposeFile;
  InstallationCancelBtn.Visible := False;
  InstallationCancelBtn.Enabled := False;
  IsPaperlessInstallation:= False;
  BorderIcons := [biSystemMenu, biMinimize, biMaximize];
  BorderStyle := bsSizeable;
end;
// Cancel a running first installation and remove images already pulled by compose.
// Eine laufende Erstinstallation abbrechen und bereits von Compose geladene Images entfernen.
procedure TSetupFrm.InstallationCancelBtnClick(Sender: TObject);
begin
  InstallationCancelBtn.Enabled := False;
  InstallLbl.Visible := True;
  InstallLbl.Caption := 'Installation wird abgebrochen. Bitte warten ...';
  ProgressBar2.Visible := True;
  MainformFrm.CancelPaperlessInstallation;

  HinweisVerstandenBtn.Enabled := False;
end;

// Check whether Docker can answer "docker info".
// Prüfen, ob Docker auf "docker info" antworten kann.
procedure TSetupFrm.CheckDockerAvailable;
var
  ExitCode: Cardinal;
begin
  // Check whether Docker is working.
  // Prüfen, ob Docker funktioniert.
  if not Self.RunCommand('docker', 'info', ExitCode) or (ExitCode <> 0) then
  begin
    CenteredMessageBox(
      'Docker Desktop scheint nicht installiert oder gestartet zu sein, der Befehl "docker" funktioniert nicht korrekt.' + #13#10 + #13#10 +
      'Stellen Sie sicher, dass Docker installiert und gestartet ist.' + #13#10 +
      'Installieren und starten sie Docker Desktop. Sie werden zusätzlich zur Downloadseite von Docker Desktop geleitet.',
      'Fehler',
      MB_OK or MB_ICONERROR or MB_TOPMOST);
      DockerAvailable := False;
      WantsInstall := False;
      ComputerRalleLbl.Visible := False;
      HinweisVerstandenBtn.Enabled := False;
      WillkommenLbl.Visible := False;
      LinkKlickLbl.Visible := False;
      ShellExecute(0, 'open', DockerDesktopUrl, nil, nil, SW_SHOWNORMAL);
      Application.Terminate;
      // Keep this Exit in case code is added below later.
      // Dieses Exit beibehalten, falls später darunter Code ergänzt wird.
      Exit;
  end
  else
  begin
    DockerAvailable := True;
  end;

end;

// Start an external command, wait for it, and return its exit code.
// Einen externen Befehl starten, darauf warten und den Exit-Code zurückgeben.
function TSetupFrm.RunCommand(const ExeName, Params: string; out ExitCode: Cardinal): Boolean;
const
  CommandTimeoutMs = 120000;
var
  SEInfo: TShellExecuteInfo;
  ProcHandle: THandle;
  WaitResult: DWORD;
begin
  // Clear the ShellExecuteInfo structure before use.
  // Die ShellExecuteInfo-Struktur vor der Verwendung leeren.
  ZeroMemory(@SEInfo, SizeOf(SEInfo));
  // Set the structure size.
  // Die Strukturgröße setzen.
  SEInfo.cbSize := SizeOf(TShellExecuteInfo);
  // Keep the process handle open so we can wait for the command to finish.
  // Das Prozess-Handle offen halten, damit auf das Befehlsende gewartet werden kann.
  SEInfo.fMask := SEE_MASK_NOCLOSEPROCESS;
  // No owner window.
  // Kein Besitzerfenster.
  SEInfo.Wnd := 0;
  // Start the program like a normal shell launch.
  // Das Programm wie einen normalen Shell-Start ausführen.
  SEInfo.lpVerb := 'open';
  // Executable name, for example "docker".
  // Name der ausführbaren Datei, zum Beispiel "docker".
  SEInfo.lpFile := PChar(ExeName);
  // Command parameters, for example "--version".
  // Befehlsparameter, zum Beispiel "--version".
  SEInfo.lpParameters := PChar(Params);
  // No special working directory.
  // Kein spezielles Arbeitsverzeichnis.
  SEInfo.lpDirectory := nil;
  // Start hidden.
  // Versteckt starten.
  SEInfo.nShow := SW_HIDE;
  // Try to start the process.
  // Versuchen, den Prozess zu starten.
  Result := ShellExecuteEx(@SEInfo);
  if Result then
  begin
    // Read the process handle.
    // Das Prozess-Handle lesen.
    ProcHandle := SEInfo.hProcess;
    // Wait until the process exits.
    // Warten, bis der Prozess beendet ist.
    WaitResult := WaitForSingleObject(ProcHandle, CommandTimeoutMs);
    if WaitResult = WAIT_TIMEOUT then
    begin
      TerminateProcess(ProcHandle, DWORD(-1));
      ExitCode := DWORD(-1);
      CloseHandle(ProcHandle);
      Result := False;
      Exit;
    end;
    // Read the process exit code.
    // Den Exit-Code des Prozesses lesen.
    GetExitCodeProcess(ProcHandle, ExitCode);
    // Close the process handle.
    // Das Prozess-Handle schließen.
    CloseHandle(ProcHandle);
  end
  else
  begin
    // Use -1 when the process could not be started.
    // -1 verwenden, wenn der Prozess nicht gestartet werden konnte.
    ExitCode := DWORD(-1);
  end;
end;

// Check whether Windows can find docker.exe through the PATH variable.
// Prüfen, ob Windows docker.exe über die PATH-Variable finden kann.
function TSetupFrm.IsDockerInPath: Boolean;
var
  Buffer: array[0..MAX_PATH - 1] of Char;
  Dummy: PChar;
begin
  // Search for docker.exe in the current PATH.
  // Im aktuellen PATH nach docker.exe suchen.
  Result := SearchPath(nil, 'docker.exe', nil, MAX_PATH, Buffer, Dummy) > 0;
end;


// Open the KeePassXC help video.
// Das KeePassXC-Hilfevideo öffnen.
procedure TSetupFrm.KeePassXCLblClick(Sender: TObject);
begin
  ShellExecute(0, 'open', KeePassHelpVideoUrl, nil, nil, SW_SHOWNORMAL);
end;

// Open either Paperless or Docker, depending on the current form state.
// Je nach aktuellem Formularzustand Paperless oder Docker öffnen.
procedure TSetupFrm.LinkClickLblClick(Sender: TObject);
begin
  // During installation the link opens Paperless; otherwise it opens Docker.
  // Während der Installation öffnet der Link Paperless, sonst öffnet er Docker.
  if ShouldOpenPaperless then
  ShellExecute(0, 'open', PaperlessLocalUrlWithSlash, nil, nil, SW_SHOWNORMAL) else
  ShellExecute(0, 'open', DockerDesktopUrl, nil, nil, SW_SHOWNORMAL);
end;

// Open the ComputerRalle website.
// Die ComputerRalle-Webseite öffnen.
procedure TSetupFrm.ComputerRalleLblClick(Sender: TObject);
begin
  ShellExecute(0, 'open', ComputerRalleUrl, nil, nil, SW_SHOWNORMAL);
end;

// Create docker-compose.yml and, depending on the mode, start or restart Paperless.
// docker-compose.yml erstellen und Paperless je nach Modus starten oder neu starten.
procedure TSetupFrm.CreateDockerComposeFile;
var
  ComposePath, ComposeContent: string;
  PaperlessSecretKey: string;
  CmdFile: TStringList;
  Ini: TIniFile;
  Versions: TDockerImageVersions;
begin
  ComposePath := IncludeTrailingPathDelimiter(AppDataFolder) + DockerComposeFileName;
  // Read image versions from the INI file and apply defaults when empty.
  // Image-Versionen aus der INI-Datei lesen und bei leeren Werten Standardwerte verwenden.
  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + SettingsFileName);
  try
    MainformFrm.redis_version_edit.Text := Ini.ReadString(IniSectionVersions, IniKeyRedisVersion, '');
    if MainformFrm.redis_version_edit.Text = '' then
      MainformFrm.redis_version_edit.Text := DefaultRedisVersion;

    MainformFrm.paperless_version_edit.Text := Ini.ReadString(IniSectionVersions, IniKeyPaperlessVersion, '');
    if MainformFrm.paperless_version_edit.Text = '' then
      MainformFrm.paperless_version_edit.Text := DefaultPaperlessVersion;

    MainformFrm.postgres_version_edit.Text := Ini.ReadString(IniSectionVersions, IniKeyPostgresVersion, '');
    if MainformFrm.postgres_version_edit.Text = '' then
      MainformFrm.postgres_version_edit.Text := DefaultPostgresVersion;

    MainformFrm.gotenberg_version_edit.Text := Ini.ReadString(IniSectionVersions, IniKeyGotenbergVersion, '');
    if MainformFrm.gotenberg_version_edit.Text = '' then
      MainformFrm.gotenberg_version_edit.Text := DefaultGotenbergVersion;

    MainformFrm.tika_version_edit.Text := Ini.ReadString(IniSectionVersions, IniKeyTikaVersion, '');
    if MainformFrm.tika_version_edit.Text = '' then
      MainformFrm.tika_version_edit.Text := DefaultTikaVersion;

    MainformFrm.alpine_version_edit.Text := Ini.ReadString(IniSectionVersions, IniKeyAlpineVersion, '');
    if MainformFrm.alpine_version_edit.Text = '' then
      MainformFrm.alpine_version_edit.Text := DefaultAlpineVersion;

    MainformFrm.busybox_version_edit.Text := Ini.ReadString(IniSectionVersions, IniKeyBusyboxVersion, '');
    if MainformFrm.busybox_version_edit.Text = '' then
      MainformFrm.busybox_version_edit.Text := DefaultBusyboxVersion;

    redis_version := MainformFrm.redis_version_edit.Text;
    paperless_ngx_version := MainformFrm.paperless_version_edit.Text;
    postgresql_version := MainformFrm.postgres_version_edit.Text;
    gotenberg_version := MainformFrm.gotenberg_version_edit.Text;
    tika_version := MainformFrm.tika_version_edit.Text;
    alpine_version := MainformFrm.alpine_version_edit.Text;
    busybox_version := MainformFrm.busybox_version_edit.Text;
    PaperlessSecretKey := GetOrCreatePaperlessSecretKey(Ini, ComposePath);
  finally
    Ini.Free;
  end;
  Versions.Paperless := paperless_ngx_version;
  Versions.Postgres := postgresql_version;
  Versions.Redis := redis_version;
  Versions.Gotenberg := gotenberg_version;
  Versions.Tika := tika_version;
  Versions.Alpine := alpine_version;
  Versions.Busybox := busybox_version;
  ComposeContent := CreateDockerComposeContent(Versions, PaperlessInput, PaperlessSecretKey, TrashRetentionDays);

  // Write docker-compose.yml.
  // docker-compose.yml schreiben.
  SaveDockerComposeFile(ComposePath, ComposeContent);

  // Write the compose path marker file. It is migrated into the INI on startup.
  // Die Markerdatei für den Compose-Pfad schreiben. Sie wird beim Start in die INI migriert.
  TFile.WriteAllText(IncludeTrailingPathDelimiter(AppDataFolder) + ComposePathFileName, ComposePath);


  // Do not start here when the main form only needs to create a new compose file.
  // Hier nicht starten, wenn das Hauptformular nur eine neue Compose-Datei erstellen soll.
  if (ShouldWriteNewCompose = False) and (IsUpdate = False) then
  begin
    // Create and save the PowerShell script that starts docker-compose.yml.
    // Das PowerShell-Skript erstellen und speichern, das docker-compose.yml startet.
    CmdTargetPath := IncludeTrailingPathDelimiter(AppDataFolder) + 'starte_paperless.ps1';
    CmdFile := TStringList.Create;
    try
      CmdFile.Add('$ErrorActionPreference = ''Stop''');
      CmdFile.Add('try {');
      CmdFile.Add('  Set-Location -LiteralPath ''' + StringReplace(AppDataFolder, '''', '''''', [rfReplaceAll]) + '''');
      CmdFile.Add('  docker compose --progress plain -f docker-compose.yml up -d');
      CmdFile.Add('  if ($LASTEXITCODE -ne 0) { throw "Fehler beim Starten von Docker Compose. (ExitCode $LASTEXITCODE)" }');
      CmdFile.Add('  Write-Host "Systeme starten. Fenster wird gleich geschlossen ..."');
      CmdFile.Add('  for ($i = 10; $i -ge 1; $i--) { Write-Host $i; Start-Sleep -Seconds 1 }');
      CmdFile.Add('} catch {');
      CmdFile.Add('  Write-Host $_.Exception.Message -ForegroundColor Red');
      CmdFile.Add('  exit 1');
      CmdFile.Add('}');
      CmdFile.Add('exit 0');
      CmdFile.SaveToFile(CmdTargetPath, TEncoding.UTF8);
    finally
      CmdFile.Free;
    end;
    MainformFrm.StartAndMonitorCmdScript;
  end;

  // Update mode: rebuild the compose setup and restart Paperless.
  // Update-Modus: Compose-Konfiguration neu erstellen und Paperless neu starten.
  if IsUpdate = True then
  begin
    MainformFrm.ReadContainerNamesFromFile;
    // Create and save the PowerShell script for the Docker restart.
    // Das PowerShell-Skript für den Docker-Neustart erstellen und speichern.
    CmdTargetPath := IncludeTrailingPathDelimiter(AppDataFolder) + 'update_paperless.ps1';
    if not FileExists(CmdTargetPath) OR IsUpdate = True then
    begin
      CmdFile := TStringList.Create;
      try
        CmdFile.Add('$ErrorActionPreference = ''Stop''');
        CmdFile.Add('function Invoke-Step([scriptblock]$Command, [string]$ErrorMessage) {');
        CmdFile.Add('  & $Command');
        CmdFile.Add('  if ($LASTEXITCODE -ne 0) { throw "$ErrorMessage (ExitCode $LASTEXITCODE)" }');
        CmdFile.Add('}');
        CmdFile.Add('function Wait-Countdown([int]$Seconds) {');
        CmdFile.Add('  for ($i = $Seconds; $i -ge 1; $i--) { Write-Host $i; Start-Sleep -Seconds 1 }');
        CmdFile.Add('}');
        CmdFile.Add('try {');
        CmdFile.Add('  Set-Location -LiteralPath ''' + StringReplace(AppDataFolder, '''', '''''', [rfReplaceAll]) + '''');
        CmdFile.Add('  Invoke-Step { docker compose -f docker-compose.yml down } "Fehler beim Stoppen der Container."');
        CmdFile.Add('  Write-Host "Neustart wird kurz abgewartet ..."');
        CmdFile.Add('  Wait-Countdown 5');
        // Pull updated images here.
        // Hier aktualisierte Images herunterladen.
        CmdFile.Add('  Invoke-Step { docker compose --progress plain -f docker-compose.yml pull } "Fehler beim Herunterladen aktualisierter Images."');
        CmdFile.Add('  Invoke-Step { docker compose --progress plain -f docker-compose.yml up -d } "Fehler beim Starten der Container."');
        CmdFile.Add('  Write-Host "Aktualisiere Django-Datenbankstruktur..."');
        CmdFile.Add('  docker compose -f docker-compose.yml exec -T paperless python3 manage.py migrate');
        CmdFile.Add('  if ($LASTEXITCODE -ne 0) {');
        CmdFile.Add('    Write-Host "Hinweis: Django-Datenbankmigration konnte jetzt nicht abgeschlossen werden. Das Skript laeuft weiter." -ForegroundColor Yellow');
        CmdFile.Add('    $global:LASTEXITCODE = 0');
        CmdFile.Add('  }');
        CmdFile.Add('  Write-Host "Aktualisiere PostgreSQL Collation Version..."');
        CmdFile.Add(Format('  Invoke-Step { docker exec -i %s psql -U paperless -d paperless -c "ALTER DATABASE paperless REFRESH COLLATION VERSION;" } "Fehler beim Aktualisieren der PostgreSQL Collation Version."', [PaperlessDBName]));
        CmdFile.Add('  Write-Host "Nicht mehr verwendete Volumes werden geloescht"');
        CmdFile.Add('  Wait-Countdown 3');
        CmdFile.Add('  Invoke-Step { docker volume prune -f } "Fehler beim Bereinigen nicht verwendeter Volumes."');
        CmdFile.Add('  Wait-Countdown 3');
        CmdFile.Add('  Write-Host "Systeme starten. Fenster wird gleich geschlossen ..."');
        CmdFile.Add('  Wait-Countdown 10');
        CmdFile.Add('} catch {');
        CmdFile.Add('  Write-Host $_.Exception.Message -ForegroundColor Red');
        CmdFile.Add('  exit 1');
        CmdFile.Add('}');
        CmdFile.Add('exit 0');
        CmdFile.SaveToFile(CmdTargetPath, TEncoding.UTF8);
      finally
        CmdFile.Free;
      end;
    end;
    MainformFrm.StartAndMonitorCmdScript;
  end;

end;

// Start Paperless from the generated docker-compose.yml file.
// Paperless aus der generierten docker-compose.yml-Datei starten.
procedure TSetupFrm.StartDockerCompose;
var
  ExitCode: Cardinal;
begin
  if not RunCommand('docker', 'compose -f "' + ComposePath + '" up -d', ExitCode) or (ExitCode <> 0) then
  begin
    CenteredMessageBox(
      'Fehler beim Start von Docker Compose.' + #13#10 +
      'Bitte prüfen Sie, ob Docker korrekt installiert und gestartet ist.',
      'Fehler',
      MB_OK or MB_ICONERROR or MB_TOPMOST);
  end
  else
  begin
    CenteredMessageBox(
      'Paperless wurde gestartet.',
      'Erfolg',
      MB_OK or MB_ICONINFORMATION or MB_TOPMOST);
  end;
end;

// Detect whether a Paperless container exists and whether it is running.
// Erkennen, ob ein Paperless-Container existiert und ob er läuft.
procedure TSetupFrm.CheckPaperlessContainerStatus;
var
  ComposePath: string;
  Output: TStringList;
begin
  // Reset status flags first.
  // Status-Flags zuerst zurücksetzen.
  PaperlessContainerExists := False;
  PaperlessContainerRunning := False;

  // Check whether docker-compose.yml exists.
  // Prüfen, ob docker-compose.yml existiert.
  ComposePath := IncludeTrailingPathDelimiter(GetEnvironmentVariable('USERPROFILE')) +
                 'Paperless Backup Programm\docker-compose.yml';
  if not FileExists(ComposePath) then
    Exit;

  Output := TStringList.Create;
  try
    // Check whether a container with "paperless" in its name exists.
    // Prüfen, ob ein Container mit "paperless" im Namen existiert.
    if RunCommandAndCapture(
         'docker',
         ['ps', '-a', '--filter', 'name=paperless', '--format', '{{.Names}}'],
         Output
       ) and (Trim(Output.Text) <> '') then
      PaperlessContainerExists := True;

    // Check whether that container is running.
    // Prüfen, ob dieser Container läuft.
    Output.Clear;
    if RunCommandAndCapture(
         'docker',
         ['ps', '--filter', 'name=paperless', '--filter', 'status=running', '--format', '{{.Names}}'],
         Output
       ) and (Trim(Output.Text) <> '') then
      PaperlessContainerRunning := True;
  finally
    Output.Free;
  end;
end;

// Start a command hidden and capture its console output.
// Einen Befehl versteckt starten und seine Konsolenausgabe erfassen.
function TSetupFrm.RunCommandAndCapture(const ExeName: string; const Params: array of string; Output: TStrings): Boolean;
const
  CommandTimeoutMs = 120000;
var
  CmdLine: string;
  I: Integer;
  SecurityAttr: TSecurityAttributes;
  ReadPipe, WritePipe: THandle;
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  Buffer: array[0..2047] of AnsiChar;
  BytesRead, BytesAvailable, ReadSize: DWORD;
  WaitResult: DWORD;
  StartTick: UInt64;
  TotalOutput: string;
  Chunk: AnsiString;
begin
  Result := False;
  Output.Clear;

  // Build the command line.
  // Die Befehlszeile zusammenbauen.
  CmdLine := '"' + ExeName + '"';
  for I := Low(Params) to High(Params) do
    CmdLine := CmdLine + ' ' + Params[I];

  // Prepare inheritable pipe handles.
  // Vererbbare Pipe-Handles vorbereiten.
  ZeroMemory(@SecurityAttr, SizeOf(SecurityAttr));
  SecurityAttr.nLength := SizeOf(SecurityAttr);
  SecurityAttr.bInheritHandle := True;
  SecurityAttr.lpSecurityDescriptor := nil;

  // Create the pipe used to capture output.
  // Die Pipe zum Erfassen der Ausgabe erstellen.
  if not CreatePipe(ReadPipe, WritePipe, @SecurityAttr, 0) then Exit;
  try
    ZeroMemory(@StartupInfo, SizeOf(StartupInfo));
    StartupInfo.cb := SizeOf(StartupInfo);
    StartupInfo.dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
    StartupInfo.hStdOutput := WritePipe;
    StartupInfo.hStdError := WritePipe;
    StartupInfo.wShowWindow := SW_HIDE;

    ZeroMemory(@ProcessInfo, SizeOf(ProcessInfo));

    if CreateProcess(nil, PChar(CmdLine), nil, nil, True, 0, nil, nil, StartupInfo, ProcessInfo) then
    begin
      CloseHandle(WritePipe); // Stop writing so the reader can finish.
      // Schreiben beenden, damit der Leser fertig werden kann.
      WritePipe := 0;
      TotalOutput := '';
      StartTick := GetTickCount64;
      repeat
        WaitResult := WaitForSingleObject(ProcessInfo.hProcess, 50);
        repeat
          BytesAvailable := 0;
          if not PeekNamedPipe(ReadPipe, nil, 0, nil, @BytesAvailable, nil) then
            Break;
          if BytesAvailable = 0 then
            Break;
          BytesRead := 0;
          if BytesAvailable > SizeOf(Buffer) then
            ReadSize := SizeOf(Buffer)
          else
            ReadSize := BytesAvailable;
          if ReadFile(ReadPipe, Buffer, ReadSize, BytesRead, nil) and (BytesRead > 0) then
          begin
            SetString(Chunk, PAnsiChar(@Buffer[0]), BytesRead);
            TotalOutput := TotalOutput + string(Chunk);
          end
          else
            Break;
        until False;
        if (WaitResult = WAIT_TIMEOUT) and (GetTickCount64 - StartTick > CommandTimeoutMs) then
          Break;
      until WaitResult <> WAIT_TIMEOUT;
      if WaitResult <> WAIT_OBJECT_0 then
      begin
        TerminateProcess(ProcessInfo.hProcess, DWORD(-1));
        CloseHandle(ProcessInfo.hProcess);
        CloseHandle(ProcessInfo.hThread);
        Exit;
      end;
      repeat
        BytesRead := 0;
        if ReadFile(ReadPipe, Buffer, SizeOf(Buffer) - 1, BytesRead, nil) and (BytesRead > 0) then
        begin
          SetString(Chunk, PAnsiChar(@Buffer[0]), BytesRead);
          TotalOutput := TotalOutput + string(Chunk);
        end;
      until BytesRead = 0;

      Output.Text := Trim(TotalOutput);
      CloseHandle(ProcessInfo.hProcess);
      CloseHandle(ProcessInfo.hThread);
      Result := True;
    end;
  finally
    if WritePipe <> 0 then
      CloseHandle(WritePipe);
    CloseHandle(ReadPipe);
  end;
end;

// Write the Docker image versions that were used for a backup.
// Die Docker-Image-Versionen schreiben, die für ein Backup verwendet wurden.
procedure TSetupFrm.WriteImageVersion(const TargetPath: string);
var
  Ini: TIniFile;
  Txt: TStringList;
  Keys, Versions: array[0..6] of string;
  I: Integer;
  IniPath, FinalPath: string;
begin
  // Normalize the target path.
  // Den Zielpfad normalisieren.
  FinalPath := ExpandFileName(TargetPath);

  // Make sure the folder exists.
  // Sicherstellen, dass der Ordner existiert.
  if not DirectoryExists(FinalPath) then
    ForceDirectories(FinalPath);

  IniPath := IncludeTrailingPathDelimiter(Mainform.AppDataFolder) + SettingsFileName;
  if not FileExists(IniPath) then Exit;

  Ini := TIniFile.Create(IniPath);
  Txt := TStringList.Create;
  try
    Keys[0] := 'Paperless-Version';
    Keys[1] := 'Postgres-Version';
    Keys[2] := 'Redis-Version';
    Keys[3] := 'Gotenberg-Version';
    Keys[4] := 'Tika-Version';
    Keys[5] := 'Alpine-Version';
    Keys[6] := 'Busybox-Version';

    for I := 0 to High(Keys) do
      Versions[I] := Ini.ReadString('Versionen', Keys[I], 'unbekannt');

    Txt.Add('Paperless Backup – Toolversionen zum Zeitpunkt des Backups');
    Txt.Add('---------------------------------------------------------');
    for I := 0 to High(Keys) do
      Txt.Add(Keys[I] + ': ' + Versions[I]);
    Txt.Add('');
    Txt.Add('Backup erstellt am: ' + DateTimeToStr(Now));

    // Write the version file into the backup subfolder.
    // Die Versionsdatei in den Backup-Unterordner schreiben.
    Txt.SaveToFile(IncludeTrailingPathDelimiter(FinalPath) + ImageVersionsFileName, TEncoding.UTF8);
    WritePaperlessSecretKeyBackup(FinalPath, Ini);
  finally
    Ini.Free;
    Txt.Free;
  end;
end;

end.
