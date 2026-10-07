# Installationspfad Anpassung

## Ausgangszustand vor Quelländerungen (02.10.2026)

Projekt: C:\Daten\Entwicklungen\ComputerRalle Software\paperless-backup-program.
Vorhandene uncommittete Änderungen werden erhalten. Diese Aufnahme beschreibt den gelesenen aktuellen Quellcode.

- AppConfig.AppDataFolderName: Paperless Backup Programm PG18.
- Mainform.FormCreate und FormShow setzen AppDataFolder jeweils auf USERPROFILE + AppDataFolderName. FormCreate erstellt den Ordner und initialisiert den Logger; FormShow setzt den Pfad nochmals zurück.
- SetupForm.CheckPaperlessContainerStatus baut den Composepfad unabhängig ebenfalls aus USERPROFILE + AppDataFolderName auf.
- FormShow erstellt vor dem Installationshandler bereits Compose. Bei einer Pfadauswahl im Handler muss dieser Vorlauf entfallen und der anschließend verwendete NewComposePath aktualisiert werden.
- SetupForm.InstallPaperlessBtnClick erstellt Compose/Startskript; CreateDockerComposeFile erstellt auch das Updateskript. Alle verwenden ansonsten AppDataFolder.

### Dateien außerhalb des Quellcodeordners

Im Laufzeitordner liegen Einstellungen.ini, docker-compose.yml, email-versand.env und gegebenenfalls email-versand.env.enc, update.ini, ContainerUndVolumesInfo.txt, DockerComposePfad.txt, BackupZiel.txt, InstallationAbgeschlossen.txt, HinweisVerstanden.txt sowie Logs.
Einstellungen.ini wird in Mainform (Start, Versionen, Mail, Sicherheit, Backup, Restore, Retention, Zeitplan) und SetupForm (Hinweis, Installation, Secret-Key, Image-Metadaten) über AppDataFolder geöffnet.
[Pfade] DockerComposePfad enthält historisch sowohl einen Ordner als auch einen vollständigen YAML-Dateipfad. Backup-/Restoreziele werden separat gespeichert. Alte Textmarker werden beim Start in die INI übernommen und entfernt.
update.ini ist eine heruntergeladene Versionsinformation im Laufzeitordner, keine Installationspfad-Konfiguration.

Auf diesem Rechner fehlt C:\Users\Ralf-Peter Kleinert\Paperless Backup Programm PG18.
Vorhanden ist die ältere Installation C:\Users\Ralf-Peter Kleinert\Paperless Backup Programm mit Einstellungen.ini, docker-compose.yml, email-versand.env, ContainerUndVolumesInfo.txt und update_paperless.cmd. Nur Dateiinventar, INI-Schlüssel und Pfadwerte werden gelesen; Geheimnisse werden nicht ausgegeben. Diese Dateien werden nicht geändert.
Die tatsächliche PG18-Installation unter C:\Users\konta auf dem VM/Testrechner ist hier nicht verfügbar. Ihre INI-Inhalte und Aufgaben können deshalb nur über die Quellcode-Schreib-/Lesestellen erfasst werden.

### Weitergabe an Skripte und andere Abläufe

- ScriptGenerator erhält ComposePath, AppDataFolder und Backupziel als Parameter. Manuelles/geplantes Backup schreibt Backup.log bzw. GeplanterBackup.log nach AppDataFolder. Restore und Neustart erhalten den Composepfad.
- Mainform erzeugt paperless-backup.ps1, paperless-backup-geplant.ps1, paperless-restore.ps1, paperless-neustart.ps1 im Composeordner; Zeitplanskripte Backup-Zeitplan-Anlegen.ps1, Backup-Zeitplan-Entfernen.ps1 und GeplanterBackupTaskSkript.ps1 in AppDataFolder. Aufgabenplanung erhält den erzeugten Skriptpfad.
- SetupForm erzeugt starte_paperless.ps1 und update_paperless.ps1 in AppDataFolder; Start nutzt PSScriptRoot, Update nutzt den übergebenen Laufzeitordner.
- Mainform: PowerShellStatus.log, BackupPfadeLog.txt, Maildateien, Containerinformationen und Updateprüfung verwenden AppDataFolder. AppLogger.InitLogger übernimmt diesen Pfad.
- DockerComposeGenerator verwendet relative env-Datei und feste Composeprojekt-/Volumenamen; Docker verwaltet die Volumes unabhängig vom Windows-Laufzeitordner.
- USERPROFILE\Desktop\Paperless-Input-PG18 bleibt der separate Consumeordner (Mainform.FormShow und SetupForm.InstallPaperlessBtnClick).
- USERPROFILE\Desktop\Paperless-Backup bleibt Standardbackupziel; Desktop\FallbackBackup bleibt Ersatzbackupziel. USERPROFILE bleibt Vorschlag im Restore-Ordnerdialog. Diese Pfade sind keine Laufzeitinstallation.

## Geplante Umsetzung

AppDataFolder bleibt die gemeinsame Laufzeitvariable. Ein kleiner benutzerspezifischer UTF-8-Pfadzeiger unter LOCALAPPDATA speichert die Wahl unabhängig von der EXE und vom gewählten Ordner. Bestehende Installationen ohne Pfadzeiger verwenden weiterhin den bisherigen Standard.
Bei Erstinstallation erscheint die Ja-/Nein-Abfrage. Ja öffnet einen VCL-Ordnerdialog, Abbruch beendet den Installationsversuch. Vorbereitete Einstellungen und Maildefaults werden in einen leeren Zielordner übernommen; bestehende Installationen werden nicht verschoben oder überschrieben. Danach werden Compose, Skripte und Pfadwerte im gewählten Ordner neu erzeugt. Schreibbarkeit wird vor Übernahme geprüft. Der Logger und globale abgeleitete Pfade werden aktualisiert.
## Umsetzung und dauerhafte Pfadverteilung

- AppConfig.DefaultInstallationFolder bildet ausschließlich den bisherigen Standard. LoadInstallationFolder lädt beim Start den gespeicherten Pfad; FormCreate und FormShow verwenden diesen Helfer. SetupForm.CheckPaperlessContainerStatus verwendet AppDataFolder.
- Der Pfadzeiger liegt unter %LOCALAPPDATA%\Paperless Backup Programm PG18\Installationspfad.ini, Abschnitt [Pfade], Schlüssel Installationspfad. Er enthält ausschließlich den absoluten Laufzeitordner und wird als UTF-8 gespeichert. Ohne Pfadzeiger bleiben bestehende Installationen im bisherigen Standardordner. Ungültige gespeicherte Pfade werden nicht still durch den Standard ersetzt.
- Mainform.SelectInstallationFolder wird zuerst im Installationshandler aufgerufen. Ja öffnet den Standard-VCL-Ordnerdialog, Nein verwendet den Standard. Abbruch oder fehlende Schreibrechte stoppen diesen Installationsversuch. Die Auswahl erfolgt einmal; bei einem späteren Wiederholungsversuch wird die gespeicherte Wahl benutzt.
- Aktualisierte Ordnerwahl: Der ausgewählte Ordner ist der übergeordnete Ordner und darf Dateien enthalten. Darin wird stets Paperless Backup Programm PG18 als Laufzeitunterordner angelegt. Bereits dort vorhandene Einstellungen und Maildateien werden bei der Übernahme nicht überschrieben.
- Bereits vorbereitete Einstellungen.ini, email-versand.env und gegebenenfalls email-versand.env.enc werden kopiert; vorhandene Quelldateien bleiben erhalten. DockerComposePfad wird auf die neue YAML-Datei gesetzt. Compose und Skripte entstehen anschließend über die bisherigen Generatoren im neuen Ordner.
- AppDataFolder, ComposePath, NewComposePath, BackupTargetFilePath, NoticeFilePath, InstallationCompletedFilePath und CmdTargetPath werden bei der Übernahme aktualisiert; InitLogger bindet das Logging neu und SaveEmptyEnvFile prüft die Maildefaults am neuen Ort.
- Die frühere Compose-Erstellung unmittelbar vor dem automatischen Installationshandler in FormShow wurde entfernt. Der Handler erzeugt Compose nach der Pfadwahl. Anschließend wird NewComposePath nochmals aus AppDataFolder aufgebaut.
- Einstellungen.ini wird in beiden Formularunits durch TAppSettingsIni gelesen/geschrieben (Standard-RTL TMemIniFile). Das ist eine direkte Voraussetzung für Unicode-Pfade: Windows TIniFile nutzt die Windows-INI-API und kann UTF-8-Pfadwerte nicht zuverlässig lesen. UTF-8 wird erkannt, bestehende ANSI-/BOM-Dateien werden eingelesen; erst tatsächliche Schreiboperationen speichern die jeweilige Datei als UTF-8 mit BOM. Schreiboperationen werden wie bisher sofort gespeichert. Keine pauschale Dateikonvertierung.
- Desktop-Consumeordner, Standard-/Fallbackbackup und Restore-Dialogvorgabe bleiben separate Benutzerpfade. Bestehende gespeicherte Backupziele bleiben erhalten. Dockerprojekt, Port und Volumes bleiben unverändert. Die EXE selbst wird durch die Auswahl nicht kopiert oder verschoben.
- Der Pfadzeiger bleibt pro Windows-Benutzer. Ein gemeinsamer Ordner stellt anderen Windows-Benutzern nicht automatisch dieselbe Konfiguration bereit und ändert keine Zugriffsrechte. Administratoren, Webzugriff und Docker-Daten sind durch diese Auswahl nicht isoliert.

## Prüfung

- Delphi-11-Win32-Direktbuild in separatem TEMP-Prüfverzeichnis erfolgreich; bestehende Warnungen/Hinweise, kein GUI-Start.
- Isolierter Delphi-Test: Standard ohne Pfadzeiger, UTF-8-Pfad mit Leerzeichen, ä/ß, weiteren Unicode-Zeichen, Apostroph, Dollarzeichen und eckigen Klammern; Wiederfinden in neuem Prozess; Unicode-INI-Roundtrip, bestehender Einstellungswert, gespeicherte Schlüssellöschung und Lesen/anschließendes UTF-8-Schreiben einer alten ANSI-INI erfolgreich.
- Aus echten ScriptGenerator-Routinen sechs Skripte erzeugt: manuell, geplant, Restore, Neustart, Aufgabenanlage und Aufgabenlöschung. UTF-8-BOM und Syntax mit Windows PowerShell 5.1 geprüft, keine Skriptausführung.
- Der erste Testhelfername enthielt Installation und löste Windows-Installer-Erkennung aus; dessen eigene Testdateien und Pfadzeiger außerhalb des Prüfverzeichnisses wurden entfernt. Der endgültige Helfer PathRoundtrip setzt Testprofilpfade ausdrücklich innerhalb des eigenen Prozesses und verwendet nur das TEMP-Prüfverzeichnis.
- UTF-8/BOM/Zeilenumbrüche und git diff --check geprüft. Vorhandene Benutzeränderungen sind erhalten.
- Nicht geprüft: interaktiver Ordnerdialog, echte Dockerinstallation, Dockerstart, Backup/Restore oder Ausführung einer Windows-Aufgabe auf dem VM/Testrechner. Die alte lokale Installation wurde nicht verändert.
- Nach Übernahme in Delphi neu erstellen und die neue EXE auf dem Testrechner einsetzen. Für die Neuinstallation Ja/Nein sowie Abbruch im Ordnerdialog prüfen; danach erneut starten und den gewählten Laufzeitordner sowie Einstellungen.ini/[Pfade]/DockerComposePfad kontrollieren.

## Ergänzung Desktopordner (02.10.2026)

Der Eingangsordner hieß im aktuellen Quellcode bereits Paperless-Input-PG18. Der Standardbackupordner heißt jetzt Paperless-Backup-PG18 und wird zentral über AppConfig.PaperlessBackupFolderName an beiden Standardpfadstellen verwendet. Bereits individuell gespeicherte Backupziele und vorhandene Ordner werden nicht automatisch umbenannt oder verschoben. Die oben dokumentierten früheren Standardnamen beschreiben den Ausgangszustand.


## Korrektur der Ordnerauswahl (02.10.2026)

Auf Benutzerwunsch wird unter jedem ausgewählten übergeordneten Ordner der feste Unterordner Paperless Backup Programm PG18 verwendet. Die Leerheitsprüfung entfällt. Beispiel: D:\Programme wird zu D:\Programme\Paperless Backup Programm PG18. Nein bleibt USERPROFILE\Paperless Backup Programm PG18. AppConfig.InstallationFolderUnderParent bildet beide Pfade; gespeichert und weitergegeben wird der vollständige Unterordnerpfad. Existierende Ziele werden akzeptiert; vorbereitete Einstellungs-/Maildateien werden nur kopiert, wenn sie am Ziel fehlen. Die genaue Ursache der vom Benutzer gemeldeten Übernahmefehlermeldung liegt ohne den Text nach dem Doppelpunkt nicht vor.

## Korrektur Erststart vor Pfadwahl (02.10.2026)

FormCreate lädt jetzt nur lesend den möglichen Pfad. InstallationPathReady wird ausschließlich durch einen gespeicherten Pfadzeiger oder den Abschlussstatus einer bestehenden Installation gesetzt (INI bzw. alter Abschlussmarker). Ein vorhandener Ordner allein oder nur Hinweis-/Mailvorbereitungen gelten nicht als abgeschlossene Auswahl.
Bei einem frischen Start werden weder der Standardlaufzeitordner noch Logger oder Maildefaults angelegt. FormShow bereitet Consumeordner und Maildefaults vorerst nur bei bestätigtem Pfad vor. Wird der erste Hinweis vor dem Installationsbutton bestätigt, bleibt die Bestätigung zunächst in NoticeAcceptedBeforeInstallation im Speicher. Vor den weiteren Dateimigrationen und Einstellungsvorbereitungen in FormShow wird die Pfadwahl nachgeholt; Abbruch beendet diesen Erststart ohne Standardordneranlage. SelectInstallationFolder schreibt die vorgemerkte Hinweisbestätigung erst in die Einstellungen des bestätigten Zielordners, aktiviert InstallationPathReady und initialisiert dort Logging und Maildefaults.
Bestehende bestätigte Installationen laden weiterhin ihren gespeicherten bzw. bisherigen Standardpfad. Bereits früher erzeugte Benutzerordner werden nicht automatisch gelöscht.

Prüfung: Delphi-11-Build und diff --check erfolgreich. Isolierter VCL-Test ohne FormShow/Application.Run und ohne Docker: FormCreate erstellt keinen Standardordner; erste Hinweisbestätigung bleibt im Speicher und erstellt ebenfalls keinen Ordner; unvollständiger Altordner mit bloßer Hinweisbestätigung umgeht die Pfadwahl nicht und erhält kein Startlog; gespeicherte Auswahl lädt den richtigen Zielordner und schreibt das Startlog nur dorthin. Alle neun Prüfungen erfolgreich. Interaktive Ordnerauswahl, vollständiger FormShow-Ablauf und echte Installation auf dem Benutzerrechner sind weiterhin nicht ausgeführt.
## Schließen vor Installation (02.10.2026)

Das X im Setupfenster setzt bei TerminateApplicationOnClose sofort ApplicationClosing, verwirft WantsInstall/ShouldOpenPaperless und liefert mrCancel zurück. Das Hauptfenster setzt dieselbe Abbruchmarkierung und schreibt beim Schließen keine Logmeldung mehr. Es werden weder Container gestartet noch Ordner/Dateien erzeugt oder Installationsaktionen nachgeholt.
Hintergrund: Delphi 11 TApplication.Terminate stellt zunächst nur WM_QUIT in die Nachrichtenwarteschlange. Application.Terminated kann unmittelbar nach ShowModal noch false sein. FormShow prüft deshalb zusätzlich ApplicationClosing am Eintritt und nach beiden modalen Hinweisabläufen sowie vor der weiteren Vorbereitung. Pfadwahl, Compose-Vorbereitung, Installationshandler, Hinweisbestätigung und Skriptstart haben entsprechende Eintrittssperren; die Pfadübernahme prüft auch nach dem Ordnerdialog erneut.
Prüfung: Delphi-11-Build und diff --check erfolgreich. Isolierter Test der tatsächlichen Schließen-Handler (ohne angezeigte GUI, Application.Run oder Docker) für Setup-X und Hauptfenster-X: Abbruchflag sofort gesetzt, keine Pfadwahl, keine Compose-Datei, keine Laufzeitordner und kein Skriptprozess, auch bei expliziten Folgeaufrufen. Zusätzlich bei zuvor bestätigtem Zielpfad: kein Logzuwachs durch das Schließen. Alle 19 Einzelprüfungen erfolgreich. Der echte interaktive X-Klick auf dem VM/Testrechner und eine Dockerinstallation wurden nicht ausgeführt.
## Erneute Abfrage bei fehlendem Benutzerordner (02.10.2026)

Neue direkte Benutzervorgabe: Fehlt %USERPROFILE%\Paperless Backup Programm PG18, muss bei jedem neuen Programmstart die Ordnerwahl erneut bestätigt werden, selbst bei vorhandenem Pfadzeiger oder Abschlussstatus einer externen Installation. Der Standardordner wird dafür nicht automatisch erstellt. Solange ausschließlich ein externer Installationsordner verwendet wird und der Standardordner fehlt, erscheint die Abfrage folglich bei jedem Start. Innerhalb eines einzelnen Starts wird die bereits bestätigte Wahl nicht nochmals abgefragt.
FormCreate setzt InstallationPathReady nur noch, wenn zusätzlich sowohl der Standardordner im Benutzerprofil als auch der gespeicherte Laufzeitordner existieren. Bei fehlendem gespeicherten Ziel ist ebenfalls eine neue Auswahl erforderlich. SelectInstallationFolder verwendet für Nein ausdrücklich DefaultInstallationFolder statt des geladenen externen Pfads; Ja erlaubt weiterhin die Wahl eines übergeordneten Ordners und bildet darin Paperless Backup Programm PG18. Vor erneuter Bestätigung wird auch der alte Hinweistextmarker nicht entfernt. Schließen per X bleibt vorrangiger Abbruch.
Prüfung: Delphi-11-Build, UTF-8 und diff --check erfolgreich. Isolierter Starttest mit zwölf erfolgreichen Einzelprüfungen einschließlich fehlendem Benutzerordner trotz gespeicherter externer Wahl, fehlendem gespeicherten Ziel ohne automatische Neuanlage sowie vorhandener Standard-/Zielordner. Keine angezeigte GUI oder Dockeroperation. Die früheren Dokumentationsaussagen zur einmaligen Auswahl gelten jetzt nur innerhalb eines Programmstarts bzw. bei vorhandenem Standardordner.
## Vorhandene Installation und Dialogzentrierung (02.10.2026)

Die neueste Benutzeranweisung ersetzt die vorherige Pflicht zur Ordnerfrage bei fehlendem Standardordner. InstallationPathReady benötigt wieder nur einen gespeicherten Auswahl-/Installationsnachweis und den vorhandenen tatsächlichen Laufzeitordner. Ein externes Ziel ohne Ordner im Benutzerprofil führt deshalb nicht zur erneuten Ordnerfrage. Fehlende Ziele und frische Installation benötigen weiterhin eine Auswahl; beim Abbruch per X laufen keine Folgeaktionen.
AppDialogs bevorzugt das Hauptfenster als Besitzer und Mittelpunkt sämtlicher eigener Meldungs- und Passwortdialoge. Die Windows-Meldungsbox verwendet weiterhin den bestehenden threadlokalen CBT-Hook. Derselbe Hook zentriert jetzt auch TFileOpenDialog-Ordnerauswahlen beim Aktivieren; Backup und Restore verwenden CenteredFolderDialogExecute. Die Installationsauswahl verwendet CenteredSelectDirectory mit einem nativen TFileOpenDialog im Ordner-Modus. Der übergeordnete Ordner bleibt frei wählbar und der feste PG18-Unterordner wird weiterhin ergänzt. SetupForm verwendet poMainFormCenter und CenterFormOnApplication nach dem Anzeigen.
Prüfung: Delphi-11-Build und diff --check erfolgreich. Zwölf isolierte Startprüfungen erfolgreich, einschließlich externem Ziel ohne Standardordner und fehlendem Ziel ohne automatische Neuanlage. Isolierter Form-/VCL-Meldungstest bestätigt identische Dialog- und Programmmitte (655,475). Die automatisierte Prüfung der nativen Windows-Dialoge konnte in diesem Testlauf nicht zuverlässig abgeschlossen werden; Testhelfer wurden beendet. Position von nativen Meldungs-/Ordnerdialogen und Passwort-/Setupfenstern auf dem tatsächlichen VM/Testrechner noch visuell prüfen. Keine echte Installation, Containerstarts oder Datenoperationen ausgeführt.
## Reparatur der Setup-Zentrierung im OnShow (02.10.2026)

Benutzer meldete den Fehler „Eigenschaft Visible kann im OnShow oder OnHide nicht verändert werden“ sowie falsche Position und Gestaltung der Setupseite. Ursache der zuvor eingebauten Zentrierung: CenterFormOnApplication setzte Dialog.Position auf poDesigned, obwohl es in SetupForm.FormShow aufgerufen wird. Delphi 11 TCustomForm.SetPosition ruft bei Änderung RecreateWnd auf; diese Fensterneuerzeugung ist im Show-/Hide-Ereignis unzulässig und unterbrach die weitere Setupinitialisierung.
Gezielte Korrektur ausschließlich in AppDialogs: CenterFormOnApplication ändert Position nicht mehr und verschiebt nur mit SetWindowPos (SWP_NOSIZE, SWP_NOZORDER, SWP_NOACTIVATE). Der bisherige Position-Setter in PrepareModalDialog bleibt erhalten, da diese Vorbereitung vor ShowModal und nicht aus einem Show-/Hide-Ereignis erfolgt. SetupForm.dfm und die Benutzeränderungen an Größe/Gestaltung bleiben unverändert.
Prüfung: Delphi-11-Build erfolgreich. Isolierter VCL-Regressionstest mit eigenem Testhauptfenster (kein Paperless-FormShow, kein Docker): 18 erfolgreiche Einzelprüfungen für tatsächliches OnShow/OnHide, stabile Handles, unveränderte Position-Eigenschaft durch den Helfer, Größe, Schrift und Steuerelementposition sowie übereinstimmende Fensterzentren; keine Reentranz. SHA-256 der SetupForm.dfm vor/nach der Reparatur identisch (6F84AB81CC534B32CE8C21A7B1777F22EFB1559BD0E661731946EE54B55C894E). Vollständige Setupoptik auf dem Benutzerrechner noch mit der neu erstellten EXE prüfen.