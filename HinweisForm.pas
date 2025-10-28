// --------------------------------------------------------------
//  Project: Paperless Backup Program / Paperless Backup Programm
//  Author: Ralf-Peter Kleinert - 2025
//  Alias: ComputerRalle / DIGITAL-easy
//  Website: https://ralf-peter-kleinert.de
//  YouTube: https://www.youtube.com/@ralf-peter-kleinert
//  Copyright (c) Ralf-Peter Kleinert
//  All rights reserved.
//
// --------------------------------------------------------------
//  Beschreibung:
//  Dieses Programm wurde von Ralf-Peter Kleinert (alias ComputerRalle / DIGITAL-easy)
//  entwickelt. Es dient zur Sicherung und Wiederherstellung von Paperless-Daten,
//  inklusive Versionsverwaltung, Backup-Planung und automatisierten Prüfungen.
//
//  Hinweis:
//  Dieses Projekt befindet sich in aktiver Entwicklung. Eine finale Lizenz
//  (Open Source oder proprietär) wird erst bei der offiziellen Veröffentlichung festgelegt.
//
//  Diese Lizenz- und Copyright-Informationen werden nach der Entscheidung,
//  welches Lizenzmodell infrage kommt, entsprechend angepasst.
//
// --------------------------------------------------------------
//  Description:
//  This program was developed by Ralf-Peter Kleinert (alias ComputerRalle / DIGITAL-easy).
//  It provides backup and restore functionality for Paperless data,
//  including version tracking, scheduled backups, and automated verification.
//
//  Note:
//  This project is currently under active development. A final license
//  (open-source or proprietary) will be defined upon official release.
//
//  These license and copyright details will be updated once
//  the final licensing model has been determined.
// --------------------------------------------------------------
unit HinweisForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, System.IOUtils, ShellAPI, System.IniFiles;

type
  THinweisFrm = class(TForm)
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
    procedure HinweisVerstandenBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PaperlessInstallierenBtnClick(Sender: TObject);
    function RunCommand(const ExeName, Params: string; out ExitCode: Cardinal): Boolean;
    function IstDockerImPfad: Boolean;
    procedure ErzeugeDockerComposeDatei;
    procedure StarteDockerCompose;
    procedure LinkKlickLblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    function RunCommandAndCapture(const ExeName: string; const Params: array of string; Output: TStrings): Boolean;
    procedure PruefePaperlessContainerStatus;
    procedure KeePassXCLblClick(Sender: TObject);
    procedure IstDockerVorhanden;
    procedure ComputerRalleLblClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure WriteImageVersion(const ZielPfad: string);

  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  HinweisFrm: THinweisFrm;
  Pfad: string;
  PaperlessContainerVorhanden: Boolean;
	PaperlessContainerLaeuft: Boolean;
  DockerVorhanden: Boolean;
  BeendeApplicationBeiClose: Boolean;
  //Version of Images
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
  Mainform;

procedure THinweisFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
	if BeendeApplicationBeiClose = True then Application.Terminate;
end;

procedure THinweisFrm.FormCreate(Sender: TObject);
begin
  SetWindowLong(Handle, GWL_EXSTYLE,
	GetWindowLong(Handle, GWL_EXSTYLE) or WS_EX_APPWINDOW);
	SetWindowLong(Handle, GWL_HWNDPARENT, 0);
end;

procedure THinweisFrm.FormShow(Sender: TObject);
begin
  BeendeApplicationBeiClose := True;
  WillInstallieren := False;
  DockerVorhanden := False;
  PaperlessOefnnen := False;
 	Panel14.ParentBackground := False;
  Panel14.StyleElements := Panel14.StyleElements - [seClient];
  Panel14.Color := $00234D11;
  StatusBar1.Panels.Clear;
  StatusBar1.Height:= 25;
  StatusBar1.Font.Size:= 10;
  StatusBar1.Font.Style:= [fsBold];
  StatusBar1.Panels.Add.Text := ' ' + ' #ComputerRalle - Paperless Backup Programm ' + MainformFrm.HoleDateiVersion(Application.ExeName);

  //Einfärben der Labels / wegen Darkmode
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

  if FileExists(HinweisDatei) then
  begin
   	PaperlessInstallierenBtn.Enabled := False;
  end
  else
  begin
  	PaperlessInstallierenBtn.Enabled := True;
  end;

  //Prüfung ob Docker und Paperless vorhanden sind
  IstDockerVorhanden;
  if DockerVorhanden = True then
  begin
    SieBenoetigenDockerLbl.Caption := 'Docker ist Installiert. Sie können Paperless installieren.';
    WillkommenLbl.Visible := True;
    SieBenoetigenDockerLbl.Refresh;
    Label1.Visible := False;
    LinkKlickLbl.Visible := False;
    WillkommenLbl.Visible := True;
    ComputerRalleLbl.Visible := True;
  end;

  PruefePaperlessContainerStatus;
  if PaperlessContainerVorhanden = True then
  begin
    //Wird geändert, damit Paperless direkt gestartet werden kann, wenn installiert
    DockerGefundenLbl.Caption := 'Paperless Container gefunden. Installation nicht notwendig.';
    WillkommenLbl.Visible := True;
    ComputerRalleLbl.Visible := True;
    LinkKlickLbl.Caption:= 'http://localhost:8000';
    IstEsPaperlessInstallation := True;
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

  if PaperlessContainerLaeuft = True then
  begin
    //Wird geändert, damit Paperless direkt gestartet werden kann, wenn installiert
    DockerGefundenLbl.Caption := 'Paperless Container gefunden. Installation nicht notwendig.';
    LinkKlickLbl.Caption:= 'http://localhost:8000';
    IstEsPaperlessInstallation := True;
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

procedure THinweisFrm.HinweisVerstandenBtnClick(Sender: TObject);
var
  Ini: TIniFile;
begin
  BeendeApplicationBeiClose := False;
  if not DirectoryExists(Mainform.AppDataFolder) then ForceDirectories(AppDataFolder);
  //Verlagerung der Dateien in die ini
  //TFile.WriteAllText(IncludeTrailingPathDelimiter(Hauptformular.AppDataOrdner) + 'HinweisVerstanden.txt', 'ja', TEncoding.UTF8);
  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(Mainform.AppDataFolder) + 'Einstellungen.ini');
   try
    try
      Ini.WriteString('Einrichtung', 'Hinweis verstanden', 'Ja');
    except
      ShowMessage('Einstellungen.ini kann nicht geschrieben werden. Rechte?');
    end;
   finally
    Ini.Free;
   end;
   Close;
end;

procedure THinweisFrm.PaperlessInstallierenBtnClick(Sender: TObject);
var
	InstallErfolgreich: Boolean;
  ExitCode: Cardinal;
  Ini:TiniFile;
begin
  WillInstallieren := True;
	// Schritt 1: Prüfen, ob Docker überhaupt im Systempfad gefunden wird
	if not IstDockerImPfad then
	begin
  	MessageBox(0,
  	'Docker wurde nicht gefunden.' + #13#10 +
  	'Bitte installieren Sie Docker Desktop ganz normal,' + #13#10 +
  	'ohne „Als Administrator ausführen“ zu verwenden.' + #13#10 +
  	'Starten Sie danach den Computer neu und wiederholen Sie die Installation mit Paperless Backup Programm',
  	'Fehler',
  	MB_OK or MB_ICONERROR or MB_TOPMOST);
    WillInstallieren := False;
    ComputerRalleLbl.Visible := False;
    HinweisVerstandenBtn.Enabled := False;
    WillkommenLbl.Visible := False;
    LinkKlickLbl.Visible := False;
  	Exit;
	end else
  begin
  	DockerGefundenLbl.Visible := True;
  	DockerVorhanden := True;
  end;
  // Schritt 2: Sicherheitsabfrage vor Installation
  if MessageDlg('Möchten Sie Paperless jetzt installieren?', mtConfirmation, [mbYes, mbNo], 0) = mrNo then
    Exit;

  IstEsPaperlessInstallation := True;
  PaperlessOefnnen := True;

  //Ordner Paperless-Input auf Desktop abfragen, und bei nichtvorhandensein anlegen
  PaperlessInput := IncludeTrailingPathDelimiter(GetEnvironmentVariable('USERPROFILE')) + 'Desktop\Paperless-Input';
  if not DirectoryExists(PaperlessInput) then ForceDirectories(PaperlessInput);

  // Schritt 3: Prüfung, ob docker korrekt funktioniert
  if not Self.RunCommand('docker', 'info', ExitCode) or (ExitCode <> 0) then
  begin
    MessageBox(0,
      'Docker Desktop scheint nicht installiert oder gestartet zu sein, der Befehl "docker" funktioniert nicht korrekt.' + #13#10 + #13#10 +
      'Stellen Sie sicher, dass Docker installiert und gestartet ist.' + #13#10 +
      'Installieren und starten sie Docker Desktop. Sie werden zusätzlich zur Downloadseite von Docker Desktop geleitet.',
      'Fehler',
      MB_OK or MB_ICONERROR or MB_TOPMOST);
      WillInstallieren := False;
      ComputerRalleLbl.Visible := False;
      HinweisVerstandenBtn.Enabled := False;
      WillkommenLbl.Visible := False;
      LinkKlickLbl.Visible := False;
      ShellExecute(0, 'open', 'https://www.docker.com/products/docker-desktop/', nil, nil, SW_SHOWNORMAL);
  		Application.Terminate;
    	// optional, falls noch Code nach dem Aufruf folgen sollte
  		Exit;
  end else
  begin
    //Variable auf True setzen
  	DockerVorhanden := True;
  end;

  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(Mainform.AppDataFolder) + 'Einstellungen.ini');
  try
   	try
  		// Vor dem Auslösen des Skriptes den Pfad speichern
  		Ini.WriteString('Einrichtung', 'Installation abgeschlossen', 'Ja');
   	except
     	ShowMessage('Einstellungen.ini kann nicht geschrieben werden. Rechte?');
   	end;
  finally
   	Ini.Free;
  end;

  ErzeugeDockerComposeDatei;
  IstEsPaperlessInstallation:= False;
end;

procedure THinweisFrm.IstDockerVorhanden;
var
  ExitCode: Cardinal;
begin
  //Prüfung, ob docker korrekt funktioniert
  if not Self.RunCommand('docker', 'info', ExitCode) or (ExitCode <> 0) then
  begin
    MessageBox(0,
      'Docker Desktop scheint nicht installiert oder gestartet zu sein, der Befehl "docker" funktioniert nicht korrekt.' + #13#10 + #13#10 +
      'Stellen Sie sicher, dass Docker installiert und gestartet ist.' + #13#10 +
      'Installieren und starten sie Docker Desktop. Sie werden zusätzlich zur Downloadseite von Docker Desktop geleitet.',
      'Fehler',
      MB_OK or MB_ICONERROR or MB_TOPMOST);
    	DockerVorhanden := False;
    	WillInstallieren := False;
    	ComputerRalleLbl.Visible := False;
    	HinweisVerstandenBtn.Enabled := False;
    	WillkommenLbl.Visible := False;
    	LinkKlickLbl.Visible := False;
    	//ShowMessage('nicht Vorhanden');
      ShellExecute(0, 'open', 'https://www.docker.com/products/docker-desktop/', nil, nil, SW_SHOWNORMAL);
  		Application.Terminate;
    	// optional, falls noch Code nach dem Aufruf folgen sollte
  		Exit;
  end
  else
  begin
    DockerVorhanden := True;
    //ShowMessage('Vorhanden');
  end;

end;

function THinweisFrm.RunCommand(const ExeName, Params: string; out ExitCode: Cardinal): Boolean;
var
  SEInfo: TShellExecuteInfo;
  ProcHandle: THandle;
begin
  // ShellExecuteInfo-Struktur vollständig mit Nullen initialisieren
  ZeroMemory(@SEInfo, SizeOf(SEInfo));
  // Größe der Struktur setzen
  SEInfo.cbSize := SizeOf(TShellExecuteInfo);
  // Maske setzen: Prozess-Handle bleibt offen, damit wir auf das Ende warten können
  SEInfo.fMask := SEE_MASK_NOCLOSEPROCESS;
  // Kein zugehöriges Fenster
  SEInfo.Wnd := 0;
  // startet das Programm wie durch Doppelklick
  SEInfo.lpVerb := 'open';
  // Name der ausführbaren Datei (z. B. "docker")
  SEInfo.lpFile := PChar(ExeName);
  // Übergabeparameter, z. B. "--version"
  SEInfo.lpParameters := PChar(Params);
  // Arbeitsverzeichnis (hier: kein spezielles)
  SEInfo.lpDirectory := nil;
  // Anzeigeoption: Fenster versteckt starten
  SEInfo.nShow := SW_HIDE;
  // Versuche, den Prozess zu starten
  Result := ShellExecuteEx(@SEInfo);
  if Result then
  begin
    // Prozesshandle auslesen
    ProcHandle := SEInfo.hProcess;
    // Auf Beendigung des Prozesses warten
    WaitForSingleObject(ProcHandle, INFINITE);
    // ExitCode des gestarteten Prozesses ermitteln
    GetExitCodeProcess(ProcHandle, ExitCode);
    // Prozess-Handle schließen
    CloseHandle(ProcHandle);
  end
  else
  begin
    // Wenn Start fehlschlug, ExitCode auf -1 setzen
    ExitCode := DWORD(-1);
  end;
end;

function THinweisFrm.IstDockerImPfad: Boolean;
var
  Buffer: array[0..MAX_PATH - 1] of Char;
  Dummy: PChar;
begin
  // Sucht 'docker.exe' im aktuellen PATH
  Result := SearchPath(nil, 'docker.exe', nil, MAX_PATH, Buffer, Dummy) > 0;
end;


procedure THinweisFrm.KeePassXCLblClick(Sender: TObject);
begin
  ShellExecute(0, 'open', 'https://www.youtube.com/watch?v=j4DWjU9XucI', nil, nil, SW_SHOWNORMAL);
end;

procedure THinweisFrm.LinkKlickLblClick(Sender: TObject);
begin
  //Wenn Paperlessinstallation wird der Link für Paperless geändert
  if PaperlessOefnnen then
  ShellExecute(0, 'open', 'http://localhost:8000/', nil, nil, SW_SHOWNORMAL) else
  ShellExecute(0, 'open', 'https://www.docker.com/products/docker-desktop/', nil, nil, SW_SHOWNORMAL);
end;

procedure THinweisFrm.ComputerRalleLblClick(Sender: TObject);
begin
  ShellExecute(0, 'open', 'https://ralf-peter-kleinert.de', nil, nil, SW_SHOWNORMAL);
end;

procedure THinweisFrm.ErzeugeDockerComposeDatei;
// docker-compose docker compose Hauptdatei
var
  ComposePfad, Inhalt: string;
  CmdDatei: TStringList;
  Ini: TIniFile;
begin

  //Versionen der Images auslesen, wenn leer Standard
  Ini := TIniFile.Create(IncludeTrailingPathDelimiter(AppDataFolder) + 'Einstellungen.ini');
  try
		MainformFrm.redis_version_edit.Text := Ini.ReadString('Versionen', 'Redis-Version', '');
		if MainformFrm.redis_version_edit.Text = '' then
  	MainformFrm.redis_version_edit.Text := '7.4.4-alpine3.21';

		MainformFrm.paperless_version_edit.Text := Ini.ReadString('Versionen', 'Paperless-Version', '');
		if MainformFrm.paperless_version_edit.Text = '' then
  	MainformFrm.paperless_version_edit.Text := '2.18.1';

		MainformFrm.postgres_version_edit.Text := Ini.ReadString('Versionen', 'Postgres-Version', '');
		if MainformFrm.postgres_version_edit.Text = '' then
  	MainformFrm.postgres_version_edit.Text := '17.6';

		MainformFrm.gotenberg_version_edit.Text := Ini.ReadString('Versionen', 'Gotenberg-Version', '');
		if MainformFrm.gotenberg_version_edit.Text = '' then
  	MainformFrm.gotenberg_version_edit.Text := '8.21.1';

		MainformFrm.tika_version_edit.Text := Ini.ReadString('Versionen', 'Tika-Version', '');
		if MainformFrm.tika_version_edit.Text = '' then
  	MainformFrm.tika_version_edit.Text := '2.9.1-full';

		MainformFrm.alpine_version_edit.Text := Ini.ReadString('Versionen', 'Alpine-Version', '');
		if MainformFrm.alpine_version_edit.Text = '' then
  	MainformFrm.alpine_version_edit.Text := '3.22.2';

		MainformFrm.busybox_version_edit.Text := Ini.ReadString('Versionen', 'Busybox-Version', '');
		if MainformFrm.busybox_version_edit.Text = '' then
  	MainformFrm.busybox_version_edit.Text := '1.37.0';

  	redis_version := MainformFrm.redis_version_edit.Text;
  	paperless_ngx_version := MainformFrm.paperless_version_edit.Text;
  	postgresql_version := MainformFrm.postgres_version_edit.Text;
  	gotenberg_version := MainformFrm.gotenberg_version_edit.Text;
  	tika_version := MainformFrm.tika_version_edit.Text;
  	alpine_version := MainformFrm.alpine_version_edit.Text;
  	busybox_version := MainformFrm.busybox_version_edit.Text;

  finally
    ini.Free;
  end;

  ComposePfad := IncludeTrailingPathDelimiter(AppDataFolder) + 'docker-compose.yml';

  Inhalt :=
    '#compose Datei fuer den Einsatz des "Paperless Backup Programm" von ComputerRalle' + sLineBreak +
    '# ralf-peter-kleinert.de' + sLineBreak +
    '#Name des Containers, wird vor die Volumes gesetzt' + sLineBreak +
    'name: paperless-ngx' + sLineBreak + sLineBreak +
    'services:' + sLineBreak +
    '  broker:' + sLineBreak +
    '    image: redis:'+ redis_version + sLineBreak +   //var redis_version
    '    restart: always' + sLineBreak + sLineBreak +
    '  db:' + sLineBreak +
    '    image: postgres:' + postgresql_version + sLineBreak + //var postgresql_version
    '    restart: always' + sLineBreak +
    '    volumes:' + sLineBreak +
    '      - db_data:/var/lib/postgresql/data' + sLineBreak +
    '    environment:' + sLineBreak +
    '      POSTGRES_DB: paperless' + sLineBreak +
    '      POSTGRES_USER: paperless' + sLineBreak +
    '      POSTGRES_PASSWORD: paperless' + sLineBreak + sLineBreak +
    '  gotenberg:' + sLineBreak +
    '    image: gotenberg/gotenberg:' + gotenberg_version + sLineBreak +  //var gotenberg_version
    '    restart: always' + sLineBreak +
    '    environment:' + sLineBreak +
    '      DISABLE_GOOGLE_CHROME: "1"' + sLineBreak + sLineBreak +
    '  tika:' + sLineBreak +
    '    image: ghcr.io/paperless-ngx/tika:' + tika_version + sLineBreak +  //var tika_version
    '    restart: always' + sLineBreak + sLineBreak +
    '# alpine wird vom Paperless Backup Program benötigt' + sLineBreak +
    '  alpine:' + sLineBreak +
    '    image: alpine:' + alpine_version + sLineBreak +   //var alpine_version
    '    container_name: alpine_helper' + sLineBreak +
    '    entrypoint: sh' + sLineBreak +
    '    stdin_open: true' + sLineBreak +
    '    tty: true' + sLineBreak + sLineBreak +
    '# busybox als zusätzliche Umgebung' + sLineBreak +
    '  busybox:'   + sLineBreak +
    '    image: busybox:' + busybox_version + sLineBreak +
    '    container_name: busybox_helper' + sLineBreak +
    '    entrypoint: sh' + sLineBreak +
    '    stdin_open: true' + sLineBreak +
    '    tty: true' + sLineBreak + sLineBreak +
    '  paperless:' + sLineBreak +
    '    image: ghcr.io/paperless-ngx/paperless-ngx:' + paperless_ngx_version + sLineBreak +  //var paperless_ngx_version
    '    depends_on:' + sLineBreak +
    '      - db' + sLineBreak +
    '      - broker' + sLineBreak +
    '      - gotenberg' + sLineBreak +
    '      - tika' + sLineBreak +
    '    ports:' + sLineBreak +
    '      - "8000:8000"' + sLineBreak +
    '    restart: always' + sLineBreak +
    '    volumes:' + sLineBreak +
    '      - data:/usr/src/paperless/data' + sLineBreak +
    '      - media:/usr/src/paperless/media' + sLineBreak +
    '      - export:/usr/src/paperless/export' + sLineBreak +
    '      - ' + PaperlessInput + ':/usr/src/paperless/consume' + sLineBreak +
    '    env_file:' + sLineBreak +
    '      - ./email-versand.env' + sLineBreak +
    '    environment:' + sLineBreak +
    '      PAPERLESS_REDIS: redis://broker:6379' + sLineBreak +
    '      PAPERLESS_DBHOST: db' + sLineBreak +
    '      PAPERLESS_DBNAME: paperless' + sLineBreak +
    '      PAPERLESS_DBUSER: paperless' + sLineBreak +
    '      PAPERLESS_DBPASS: paperless' + sLineBreak +
    '      PAPERLESS_TIME_ZONE: Europe/Berlin' + sLineBreak +
    '      PAPERLESS_SECRET_KEY: aksjdfhs87H/(&986jlkhgiu87659zol' + sLineBreak +
    '      PAPERLESS_CONSUMPTION_DIR: /usr/src/paperless/consume' + sLineBreak +
    '      PAPERLESS_MEDIA_ROOT: /usr/src/paperless/media' + sLineBreak +
    '      PAPERLESS_EXPORT_DIR: /usr/src/paperless/export' + sLineBreak +
    '      PAPERLESS_TIKA_ENABLED: "1"' + sLineBreak +
    '      PAPERLESS_TIKA_GOTENBERG_ENDPOINT: http://gotenberg:3000' + sLineBreak +
    '      PAPERLESS_TIKA_ENDPOINT: http://tika:9998' + sLineBreak +
    '      PAPERLESS_CONSUMER_POLLING: "30"' + sLineBreak +
    '      PAPERLESS_CONSUMER_POLLING_DELAY: "30"' + sLineBreak +
    '      PAPERLESS_CONSUMER_POLLING_RETRY_COUNT: "3"' + sLineBreak +
    '      PAPERLESS_CONSUMER_DELETE_DUPLICATES: "true"' + sLineBreak +
    '      PAPERLESS_CONSUMER_RECURSIVE: "true"' + sLineBreak +
    '      PAPERLESS_EMPTY_TRASH_DELAY: "' + IntToStr(PapierkorbAufbewahrung) + '"' + sLineBreak +
    '      PAPERLESS_OCR_LANGUAGE: deu+eng' + sLineBreak +
    '      #Dokument Export benennt die Doks Nach Jahr, Monat, Tag, Name' + sLineBreak +
    '      PAPERLESS_FILENAME_FORMAT: "{{ created_year }}-{{ created_month }}-{{ created_day }}_{{ title }}"' + sLineBreak +
    'volumes:' + sLineBreak +
    '  data:' + sLineBreak +
    '  media:' + sLineBreak +
    '  export:' + sLineBreak +
    '  db_data:';

  // docker-compose.yml Datei schreiben
  TFile.WriteAllText(ComposePfad, Inhalt, TEncoding.UTF8);

  // DockerCoposePfad.txt zum einlesen des Pfades schreibenm wird bei Start geprüft
  TFile.WriteAllText(IncludeTrailingPathDelimiter(AppDataFolder) + 'DockerComposePfad.txt', ComposePfad);


  //Wenn neue docker-compose.yml im AppDataOrdner angelegt werden muss, wird das ausgeschaltet
  //HauptFormular suche nach: //Prüfen ob der neue ComposePfad bereits vorhanden ist
  if (NeueComposeSchreiben = False) and (IstEsUpdate = False) then
  begin
  	//CMD Skript zum starten von docker-compose.yml erstellen und speichern
  	CmdZielPfad := IncludeTrailingPathDelimiter(AppDataFolder) + 'starte_paperless.cmd';
		if not FileExists(CmdZielPfad) then
  	begin
    	CmdDatei := TStringList.Create;
    	try
      	CmdDatei.Add('@echo off');
      	CmdDatei.Add('cd /d "' + AppDataFolder + '"');
      	CmdDatei.Add('docker compose -f docker-compose.yml up -d');
      	CmdDatei.Add('echo Systeme starten. Fenster wird gleich geschlossen ...');
      	CmdDatei.Add('for /L %%i in (10,-1,1) do (echo %%i & timeout /t 1 >nul)');
      	CmdDatei.Add('endlocal');
      	CmdDatei.Add('exit');
      	CmdDatei.SaveToFile(CmdZielPfad, TEncoding.ANSI);
    	finally
      	CmdDatei.Free;
    	end;
  	end;
  	MainformFrm.CmdSkriptStartenUndUeberwachen;
  end;

  //Wenn die IstEsUpdate aktiviert wurde
  if IstEsUpdate = True then
  begin
    MainformFrm.LeseContainerNamenAusDatei;
    //ShowMessage(PaperlessDBName);
    //CMD Skript zum Neustart von Docker mit der neuen compose erstellen und speichern
  	CmdZielPfad := IncludeTrailingPathDelimiter(AppDataFolder) + 'update_paperless.cmd';
		if not FileExists(CmdZielPfad) OR IstEsUpdate = True then
  	begin
    	CmdDatei := TStringList.Create;
    	try
      	CmdDatei.Add('@echo off');
      	CmdDatei.Add('cd /d "' + AppDataFolder + '"');
        CmdDatei.Add('docker compose -f docker-compose.yml down');
      	CmdDatei.Add('echo Neustart wird kurz abgewartrt ...');
      	CmdDatei.Add('for /L %%i in (5,-1,1) do (echo %%i & timeout /t 1 >nul)');
        //Hier wrden die  Imgaes gezogen
      	CmdDatei.Add('docker compose -f docker-compose.yml pull && docker compose -f docker-compose.yml up -d');
        CmdDatei.Add('echo Repariere Django ContentType-Struktur...');
				CmdDatei.Add('docker exec -i paperless-ngx-paperless-1 python3 manage.py migrate contenttypes');
				CmdDatei.Add('echo Aktualisiere PostgreSQL Collation Version...');
				CmdDatei.Add(Format('docker exec -i %s psql -U paperless -d paperless -c "ALTER DATABASE paperless REFRESH COLLATION VERSION;"', [PaperlessDBName]));
    		CmdDatei.Add('echo Nicht mehr verwendete Volumes werden geloescht');
    		CmdDatei.Add('for /L %%i in (3,-1,1) do (echo %%i & timeout /t 1 >nul)');
    		CmdDatei.Add('docker volume prune -f');
    		CmdDatei.Add('for /L %%i in (3,-1,1) do (echo %%i & timeout /t 1 >nul)');
      	CmdDatei.Add('echo Systeme starten. Fenster wird gleich geschlossen ...');
      	CmdDatei.Add('for /L %%i in (10,-1,1) do (echo %%i & timeout /t 1 >nul)');
      	CmdDatei.Add('endlocal');
      	CmdDatei.Add('exit');
      	CmdDatei.SaveToFile(CmdZielPfad, TEncoding.ANSI);
    	finally
      	CmdDatei.Free;
    	end;
  	end;
  	MainformFrm.CmdSkriptStartenUndUeberwachen;
  end;

end;

procedure THinweisFrm.StarteDockerCompose;
var
  ExitCode: Cardinal;
begin
  if not RunCommand('docker', 'compose -f "' + ComposePfad + '" up -d', ExitCode) or (ExitCode <> 0) then
  begin
    MessageBox(0,
      'Fehler beim Start von Docker Compose.' + #13#10 +
      'Bitte prüfen Sie, ob Docker korrekt installiert und gestartet ist.',
      'Fehler',
      MB_OK or MB_ICONERROR or MB_TOPMOST);
  end
  else
  begin
    MessageBox(0,
      'Paperless wurde gestartet.',
      'Erfolg',
      MB_OK or MB_ICONINFORMATION or MB_TOPMOST);
  end;
end;

procedure THinweisFrm.PruefePaperlessContainerStatus;
var
  ComposePath: string;
  Output: TStringList;
begin
  // Standardmäßig alles auf False setzen
  PaperlessContainerVorhanden := False;
  PaperlessContainerLaeuft := False;

  // Prüfen, ob die docker-compose.yml existiert
  ComposePath := IncludeTrailingPathDelimiter(GetEnvironmentVariable('USERPROFILE')) +
                 'Paperless Backup Programm\docker-compose.yml';
  if not FileExists(ComposePath) then
    Exit;

  Output := TStringList.Create;
  try
    // Ist ein Container mit "paperless" im Namen vorhanden?
    if RunCommandAndCapture(
         'docker',
         ['ps', '-a', '--filter', 'name=paperless', '--format', '{{.Names}}'],
         Output
       ) and (Trim(Output.Text) <> '') then
      PaperlessContainerVorhanden := True;

    // Läuft dieser Container?
    Output.Clear;
    if RunCommandAndCapture(
         'docker',
         ['ps', '--filter', 'name=paperless', '--filter', 'status=running', '--format', '{{.Names}}'],
         Output
       ) and (Trim(Output.Text) <> '') then
      PaperlessContainerLaeuft := True;
  finally
    Output.Free;
  end;
end;

function THinweisFrm.RunCommandAndCapture(const ExeName: string; const Params: array of string; Output: TStrings): Boolean;
var
  CmdLine: string;
  I: Integer;
  SecurityAttr: TSecurityAttributes;
  ReadPipe, WritePipe: THandle;
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  Buffer: array[0..2047] of AnsiChar;
  BytesRead: DWORD;
  TotalOutput: string;
begin
  Result := False;
  Output.Clear;

  // Befehlskette zusammenbauen
  CmdLine := '"' + ExeName + '"';
  for I := Low(Params) to High(Params) do
    CmdLine := CmdLine + ' ' + Params[I];

  // Sicherheitsattribute vorbereiten
  ZeroMemory(@SecurityAttr, SizeOf(SecurityAttr));
  SecurityAttr.nLength := SizeOf(SecurityAttr);
  SecurityAttr.bInheritHandle := True;
  SecurityAttr.lpSecurityDescriptor := nil;

  // Pipe erzeugen
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
      CloseHandle(WritePipe); // Schreiben beenden

      TotalOutput := '';
      repeat
        BytesRead := 0;
        if ReadFile(ReadPipe, Buffer, SizeOf(Buffer) - 1, BytesRead, nil) and (BytesRead > 0) then
        begin
          Buffer[BytesRead] := #0;
          TotalOutput := TotalOutput + string(Buffer);
        end;
      until BytesRead = 0;

      Output.Text := Trim(TotalOutput);

      WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
      CloseHandle(ProcessInfo.hProcess);
      CloseHandle(ProcessInfo.hThread);
      Result := True;
    end;
  finally
    CloseHandle(ReadPipe);
  end;
end;

procedure THinweisFrm.WriteImageVersion(const ZielPfad: string);
var
  Ini: TIniFile;
  Txt: TStringList;
  Keys, Versions: array[0..6] of string;
  I: Integer;
  IniPfad, FinalPfad: string;
begin
  // Zielpfad auf absolute Form bringen
  FinalPfad := ExpandFileName(ZielPfad);

  // Sicherstellen, dass der Ordner existiert
  if not DirectoryExists(FinalPfad) then
    ForceDirectories(FinalPfad);

  IniPfad := IncludeTrailingPathDelimiter(Mainform.AppDataFolder) + 'Einstellungen.ini';
  if not FileExists(IniPfad) then Exit;

  Ini := TIniFile.Create(IniPfad);
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

    // Ganz wichtig: jetzt explizit ins Unterverzeichnis schreiben
    Txt.SaveToFile(IncludeTrailingPathDelimiter(FinalPfad) + 'image_versionen.txt', TEncoding.UTF8);
  finally
    Ini.Free;
    Txt.Free;
  end;
end;




end.
