# Paperless Backup Programm

## Fester Statusbalken und aktualisierte Anleitung – 23.11.2026

Der grüne Statusbalken im Einstellungstab bleibt oberhalb der Scrollbox sichtbar. Nur die darunterliegenden Einstellungen scrollen. Die ODT-Anleitung beschreibt die lokale Nachinstallation, getrennte Installationsstände, den Erhalt der Serverversionen, Mausradbedienung und SSH-Wiederverbindung bei Serverinstallation und Update.

Inhaltsverzeichnis-Seitenzahlen und sichtbare Layoutprüfung bleiben offen. Die PDF-Dateien wurden nicht verändert. Win64-IDE-Build und Praxistests stehen weiterhin aus.

## Lokale Installation nachträglich einrichten – 23.11.2026

Nach einem Erststart im Servermodus können Sie unter Einstellungen „Lokale Installation“ wählen. Fehlt eine vollständige lokale Einrichtung, bietet das Programm deren Installation über das Setupfenster an. Docker Desktop muss installiert und gestartet sein. Der bestehende Windows-Laufzeitordner wird verwendet. Bei Ablehnung, Abbruch oder Fehler bleibt der Servermodus erhalten; nach erfolgreicher Installation und Vorbereitung wird Lokal gespeichert. Serverdaten und vorhandene Server-Imageversionen bleiben erhalten.

Lokaler und serverseitiger Installationsabschluss werden getrennt in der Einstellungen.ini gespeichert. Ältere lokale Abschlusswerte bleiben nutzbar. Für ältere Serverprofile ohne gespeicherten Installationserfolg lautet der neue Status „Unbekannt“; dies sperrt keine bestehende Serverinstallation. Aktueller Stand statisch geprüft, Win64-IDE-Build und praktische Prüfung stehen aus.

## Ergänzungen vom 22.11.2026

Serverinstallation und Serverupdate laufen als eigenständige Serveraufträge. Bei SSH-Unterbrechungen versucht die laufende Anwendung nach fünf Sekunden erneut zu verbinden und lädt neue Statusmeldungen nach. Die Reihenfolge down → pull → up bleibt erhalten. Root auf systemd verwendet einen transienten Systemdienst; der Ersatzweg über nohup/setsid benötigt eine gesonderte Prüfung bei serverseitiger Sitzungsbereinigung. Eine Wiederaufnahme nach Neustart des Windows-Programms ist nicht implementiert.

Im Tab **Einstellungen** unterstützt die Scrollbox jetzt das Mausrad. Den Mauszeiger über den Einstellungsbereich bewegen und auf- oder abwärts scrollen. Die Windows-Scrolleinstellung wird berücksichtigt; Steuerelemente mit eigener Mausradbehandlung behalten diese.

Der Quellstand ist statisch beziehungsweise für den SSH-Beobachter mit Simulationen geprüft. Aktueller Win64-IDE-Build und praktische GUI-/WLAN-Prüfungen stehen aus; Programmversion unverändert.

## Erststartdialoge – 17.11.2026

Die Betriebsartauswahl verwendet **Lokal** und **Server**. Der Beschreibungstext lautet **„Server: Paperless auf einem Server installieren.“** Die Auswahl führt nach der Laufzeitpfadwahl zu den Servereinstellungen; die eigentliche Installation wird dort gesondert gestartet.

Bei **„Möchten Sie den Installationspfad ändern?“** lautet die Reihenfolge **Nein, Ja, Abbrechen**. **Nein** erhält den Fokus und ist die Standardaktion für Enter; es verwendet den Standardordner. **Ja** öffnet die Ordnerauswahl. Abbrechen und Schließen beenden die Pfadwahl. Andere Dialoge behalten ihre Reihenfolge.

## Aktueller Entwicklungsstand / Current development status – 17.11.2026

Stand des Quellcodes: **17.11.2026**, Programmversion **6.26.11.100** in **Win64 Debug**, Entwicklung mit **Delphi 13 / VCL**. Verbindlicher Projektpfad: `C:\Users\konta\Documents\ComputerRalle Entwicklungen\paperless-backup-program`. Ältere datierte Abschnitte dokumentieren frühere Zustände; ihre Pfade, Versionswerte und Prüfungen gelten nicht als aktueller Sollstand.

Die Betriebsarten sind **Lokal** (Docker Desktop) und **Server** (Docker über SSH). Serverinstallation auf Debian 13, Backup, Restore, Upload, Download und Update sind implementiert. Die externe Zeitplanung bleibt offen. Lokale Zeitpläne starten `paperless-backup-geplant.ps1` direkt über `powershell.exe`.

Programmstandards: Paperless-ngx **3.4.2**, PostgreSQL **18**, Valkey **9-alpine**, Gotenberg **8**, Tika **3.2.3.0**, Alpine **3**, BusyBox **1**. Gespeicherte eigene Image-Tags und die tatsächlich laufenden Images sind davon zu unterscheiden. Servervorgaben: `/opt/paperless`, Projekt `paperless-ngx-pg18`, Webport `8000`, Backupziel `/srv/paperless_backup`; lokaler Webport `8001`.

Beim Serverstart und Speichern der Serverdaten erkennt die SSH-Prüfung den Compose-Projektnamen anhand der Haupt-Compose-Datei aus laufenden und gestoppten Projekten. Nur ein eindeutiger Treffer ersetzt den gespeicherten Namen. Mehrdeutigkeit oder Abfragefehler lassen ihn unverändert. Serveraktionen können erst nach Abschluss der Prüfung gestartet werden.

Der lokale Compose-Schutz erhält eine vorhandene Compose-Datei. Generierte PowerShell-Skripte werden weiterhin aktualisiert. Eigene Dateien unter `scripts` bleiben erhalten, gehören aber nicht zu den regulären Backup-/Restorearchiven. Die Mastervorlage protokolliert einen UTC-Zeitpunkt in `script-test.log`.

Die Aufbewahrung greift erst nach einer vollständig freigegebenen lokalen Sicherung und berücksichtigt ausschließlich markierte lokale Backups. Geplante Sicherungen enthalten SQL und die Archive von `data`, `media` und `export`, gegebenenfalls Maildatei und Schlüssel; sie erzeugen keine neue Imageversionsdatei und kein physisches DB-Archiv. Serverübertragungen prüfen Dateigrößen und SHA-256 vor der Freigabe.

Der aktuelle Win64-IDE-Build und vollständige Laufzeitprüfungen der jüngsten Änderungen stehen aus. Ältere erfolgreiche Builds und einzelne bestätigte Wiederherstellungen ersetzen diese Prüfungen nicht. Diese Dokumentationspflege führt keine Installation, Serveraktion oder Veröffentlichung aus.

Die ODT-Benutzeranleitung enthält die gelieferten Version-6-Bilder. Inhaltsverzeichnis-Seitenzahlen und visuelle Layoutkontrolle sind noch offen. Keine neue PDF-Fassung.

English: Version 6.26.11.100 targets Delphi 13 / Win64. Remote installation, backup, restore, transfer and updates are implemented; remote scheduling remains open. The latest build and full runtime validation are pending. The ODT includes the supplied version-6 screenshots; its table-of-contents page numbers and visual layout still need review.

## Fenster und Dialoge

Der aktuelle Projektstand ist **6.26.11.100** (Win64 Debug). Das Hauptfenster und das Fenster für die Ersteinrichtung öffnen auf dem in Windows festgelegten Hauptmonitor. Meldungen, Passwortabfragen und die Ordnerauswahl erscheinen mittig vor dem Fenster, aus dem Sie sie aufrufen. Das gilt auch, wenn dieses Fenster auf einen zweiten Monitor verschoben wurde.

## Erststart und Betriebsart

Beim ersten Start ohne bestätigten Laufzeitordner wählen Sie **Lokal** oder **Server**. **Lokal** führt zur Einrichtung mit Docker Desktop. Bei **Server** wählen Sie den Windows-Laufzeitordner. Anschließend öffnet das Programm **Einstellungen**, scrollt zu **Servereinstellungen Paperless Extern** und setzt den Fokus ins Hostfeld. Schließen Sie den Auswahldialog, endet der Start.

Beim Umschalten von **Lokal** auf **Server** bleibt ein vorhandenes Server-Versionsprofil erhalten. Nur ein noch nicht angelegtes Server-Versionsprofil wird mit den gespeicherten lokalen Image-Tags vorbelegt. Beim Erststart mit **Server** sind alle Felder mit Programmvorgaben ausgefüllt. In vorhandenen Profilen ergänzen die Vorgaben leere Felder.

| Docker-Image | Standard-Tag |
|---|---|
| Paperless-ngx | `3.4.2` |
| PostgreSQL | `18` |
| Valkey | `9-alpine` |
| Gotenberg | `8` |
| Apache Tika | `3.2.3.0` |
| Alpine | `3` |
| BusyBox | `1` |

Die Debian-Neuinstallation verwendet die ersten fünf Vorgaben für die Compose-Dienste. Beim Aktualisieren einer vorhandenen Serverinstallation werden die Image-Tags durch ausdrückliche Bearbeitung und bestätigtes Speichern geändert.

## Lokale Sicherung, Wiederherstellung und Updates

Manuelle und geplante Backups sichern die tatsächlich eingebundenen Docker-Volumes und Ordner. Backup-, Restore-, Installations- und Updateskripte verwenden eine gemeinsame Sperre für den Compose-Ordner. Das Backup erscheint nach Archivprüfung und Wiederanlauf der dafür gestoppten Dienste unter dem endgültigen Zeitstempel. Die automatische Aufbewahrung zählt vollständig freigegebene, markierte lokale Backups. Frühere Sicherungen und importierte Server-Backups ohne Markierung können Sie manuell verwalten.

Öffnen Sie nach dem Wechsel auf diese Programmfassung die lokale Betriebsart. Das Programm aktualisiert ein vorhandenes älteres Skript für geplante Backups am gespeicherten Compose-Pfad. Alternativ können Sie den Zeitplan neu speichern. Bei einem Fehler finden Sie das manuelle Backup-Protokoll als `Backup.log` und das geplante als `GeplanterBackup.log` im Laufzeitordner.

Verwenden Sie für jede Wiederherstellung ausschließlich Backups aus vertrauenswürdiger Quelle. Der lokale Restore prüft die Archive vor dem Dienststopp, sichert den bisherigen Bestand und führt Schemawechsel und SQL-Import gemeinsam in einer Transaktion aus. Bei einem Fehler versucht das Programm, den vorherigen Stand wiederherzustellen. Die Logdatei unter `Logs` enthält das Ergebnis und bei Bedarf den Pfad zu erhaltenen Rückfalldateien. Diese Dateien können Zugangsdaten enthalten.

Beim lokalen Speichern mit Neustart lädt das Updateskript die Images vor dem Stoppen von Paperless und wartet bei der Aktivierung auf PostgreSQL und eine Antwort der Paperless-Weboberfläche. Tritt ein Fehler auf, bevor die Migration beginnen konnte, versucht das Skript nach dem Stopp einen Neustart mit der bisherigen Compose-Datei. Sobald die Migration begonnen haben könnte, weist die Meldung auf den möglichen Datenbankwechsel hin. Die bisherige Compose-Datei bleibt für die Fehlerbehebung erhalten.

## Server-Backup und Wiederherstellung

**Praxisbestätigung vom 11.11.2026:** Ein auf der Linux-VM erzeugtes Backup wurde erfolgreich in Docker Desktop unter Windows eingespielt. Bei einer Wiederherstellung auf der Linux-VM meldete der Server-Worker den erfolgreichen Import und Start von Paperless. Das Programm findet vorhandene Server-Backups. Die Übertragungsdialoge für Upload und Download sowie das Öffnen eines Dokuments nach dem Server-Restore sind separat zu prüfen.

### Paperless auf einem neuen Debian-Server installieren

**Entwicklungsstand vom 12.11.2026:** Beim Klick auf **Serverdaten Speichern** blieb die SSH-Fingerabdruckabfrage im Praxistest aus. Das Programm meldete „Der Server hat keinen lesbaren SSH-Fingerabdruck geliefert.“ Die Prüfung endete dabei vor der Bestätigung und der SSH-Anmeldung. Im Quellcode steht jetzt ein zweiter Abrufweg über Windows OpenSSH bereit, wenn der direkte Scan keinen auswertbaren Schlüssel liefert. Die Korrektur ist mit simulierter SSH-Ausgabe geprüft und auf der betroffenen VM noch zu bestätigen. Die sichtbare Abfrage vor der Serverinstallation und die Installation auf einer frischen Debian-VM sind noch praktisch zu prüfen.

1. Eine frische Debian-13-VM (amd64) mit funktionierendem SSH-Zugang für `root` bereitstellen.
2. Unter **Einstellungen → Paperless Extern** die Serverdaten eintragen und speichern. Nach **Serverdaten Speichern** soll die Fingerabdruckabfrage vor der SSH-Anmeldung erscheinen, auch bei unveränderten Serverdaten. Den angezeigten Fingerabdruck mit dem auf dem Server vergleichen und bestätigen. Neue bestätigte Schlüssel werden nach erfolgreicher Anmeldung gespeichert. Bei Ablehnung oder einem geänderten gespeicherten Hostschlüssel wird die Prüfung abgebrochen.
3. **Paperless installieren** wählen, den SSH-Fingerabdruck im Dialog bestätigen und anschließend den Installationsauftrag bestätigen. Das Programm aktualisiert Debian-Pakete, installiert Docker und Compose und startet standardmäßig Paperless-ngx 3.4.2 mit PostgreSQL 18 unter `/opt/paperless`. Ein belegter Installationsordner wird vor der Paketaktualisierung abgelehnt.
4. Nach der Erfolgsmeldung **Paperless im Browser aufrufen** wählen und dort den Paperless-Admin anlegen. Der Eingangsordner ist über `\\<Server-IP>\paperless-consume` als beschreibbare Samba-Gastfreigabe vorgesehen. Windows kann Gastzugriffe abhängig von der SMB-Konfiguration ablehnen.
5. Der Dialog zeigt nach erfolgreicher Installation die Webadresse, die Samba-Freigabe und die Logdatei unter `Logs` an. Die Anwendung speichert Compose-Ordner, Projektname und Webport für spätere Aufrufe. Wenn ein später Schritt fehlschlägt und die Compose-Datei bereits angelegt wurde, bleibt sie auf dem Server. Den fehlgeschlagenen Schritt anhand der Logdatei prüfen.

### Paperless auf dem Server aktualisieren

Im Modus **Externe Serverinstallation** startet **Einstellungen Speichern** nach Bestätigung bei jedem Klick einen Update-Lauf über das gespeicherte SSH-Profil. Die aktuelle Compose-Datei auf dem Server ist die Grundlage. Manuelle Änderungen per SSH bleiben erhalten. Nur ausdrücklich geänderte Image-Tags werden in die Datei geschrieben.

Das Programm prüft Compose und führt für das gesamte Projekt **down**, **pull** und **up -d** mit Bereitschaftsprüfung aus. Der Ablauf gilt auch bei leeren oder unveränderten Versionsfeldern. Änderungen am PostgreSQL-Tag bleiben auf Hauptversion 18 begrenzt. Alpine und BusyBox können geändert werden, wenn die entsprechenden Compose-Dienste vorhanden sind.

Der Ablauf braucht Zugriff auf den lokalen Docker-Daemon und die gemeinsame Serversperre mit flock. Für Tag-Änderungen wird zusätzlich python3 benötigt. Die Abschlussmeldung nennt den Pfad zum technischen Protokoll unter **Logs**. Bei Fehlern vor dem Start mit neuen Images versucht das Programm den Wiederanlauf mit der bisherigen Konfiguration. Nach einem fehlgeschlagenen Start mit neuen Images nennt es den Pfad zur bisherigen Compose-Datei. Datenmigrationen können dann bereits begonnen haben.

### Server einrichten und sichern

**Compose-Projektname** ist mit `paperless-ngx-pg18` vorbelegt und bearbeitbar. Beim Start im Servermodus und bei **Serverdaten Speichern** prüft das Programm laufende und gestoppte Projekte. Gehört die Haupt-Compose-Datei im eingetragenen Ordner eindeutig zu einem Projekt, übernimmt das Programm dessen Namen und speichert ihn für spätere Serveraktionen. Ohne eindeutigen Treffer gilt der gespeicherte Name. Das Ergebnis steht bei den Serverdaten.

**Paperless im Browser aufrufen** verwendet im Servermodus die gespeicherte IP-Adresse oder den Hostnamen und den **Paperless-Webport**. Der Standard ist 8000. Bei einem abweichenden Docker-Hostport den Wert unter **Einstellungen → Paperless Extern** eintragen und mit **Serverdaten Speichern** übernehmen.

1. Unter **Einstellungen → Paperless Extern** die Serververbindung und den Backupordner eintragen und **Serverdaten Speichern** wählen. Der Standardpfad ist `/srv/paperless_backup`. **Backupordner anlegen** prüft nach Bestätigung den freien Platz am Ziel oder am nächsten vorhandenen Elternordner und legt den Ordner anschließend per SSH an.
2. Im Serverbetrieb **Paperless Backup Starten** wählen. **Ja** startet das Backup. **Nein** ruft den Status des letzten oder laufenden Server-Backups ab.
3. Nach einem erfolgreichen Lauf den angebotenen Download mit **Ja** starten. Für ein vorhandenes Backup **Backup vom Server laden** wählen, einen vollständigen Zeitstempelordner aus der Liste auswählen und mit **Weiter** zur Windows-Ordnerauswahl gehen. Die Liste zeigt die neueste Sicherung zuerst.
4. Den Windows-Zielordner auswählen. Der Download legt darin nach vollständiger Übertragung und Prüfung von Dateigrößen und SHA-256-Prüfsummen den Zeitstempelordner an. Ein vorhandener gleichnamiger Ordner bleibt erhalten. Der Fortschritt erscheint in der Anwendung. Eine erreichbare Netzwerkfreigabe kann ebenfalls als Ziel dienen.

### Server-Backup unter Windows einspielen

Auf **Lokale Installation** umschalten und **Backup Wiederherstellen** wählen. Den heruntergeladenen Zeitstempelordner selbst auswählen. Die Wiederherstellung ersetzt die Daten der ausgewählten lokalen Paperless-Installation. Vorher bei Bedarf deren aktuellen Stand sichern.

Der Server schreibt das Backup im lokalen PG18-Dateiformat. Die Wiederherstellung verwendet den UTF-8-SQL-Dump sowie die Archive `data`, `media` und `export`. Das zusätzlich gesicherte physische DB-Archiv ist für den regulären Restore nicht erforderlich. Der Backupordner enthält auch den Paperless Secret Key und die Image-Metadaten. Eine vorhandene verschlüsselte Maildatei wird mitgesichert.

### Backup auf dem Server einspielen

1. Liegt das Backup auf Windows, zuerst **Backup zum Server senden** wählen. Den PG18-Zeitstempelordner auswählen und das Serverziel bestätigen. Nach der Bestätigung legt das Programm einen fehlenden Server-Backupordner an, sofern der SSH-Benutzer die nötigen Rechte hat. Es prüft vor der Übertragung den freien Platz und vergleicht vor der Freigabe Dateigrößen und SHA-256-Prüfsummen. Gleichnamige Backups im Serverordner bleiben erhalten. Mit **Abbrechen** kann die laufende Übertragung beendet werden. Das Programm räumt nur den Zwischenordner dieses Vorgangs auf. Falls die Bereinigung fehlschlägt, zeigt es den betroffenen Pfad an.
2. Im Servermodus **Backup Wiederherstellen** wählen und den Hinweis mit **OK** schließen. Mit **Ja** die Liste der Backups im gespeicherten Serverordner öffnen. Ein Backup auswählen und den Zielserver prüfen.
3. Das Überschreiben der Datenbank und der Ordner `data`, `media` und `export` bestätigen. Paperless ist während der Wiederherstellung vorübergehend nicht erreichbar.
4. Bei Erfolg meldet das Programm **Wiederherstellung erfolgreich** und zeigt den Pfad zur Logdatei. Anschließend lassen sich die wiederhergestellten Dokumente im Browser kontrollieren.

Ein eigener Docker-Container führt die Wiederherstellung aus. Nach dem Start läuft er auch bei einer SSH-Unterbrechung weiter. Den letzten oder laufenden Status über **Backup Wiederherstellen → OK → Nein** abrufen. Backup und Restore verwenden eine gemeinsame Sperre. Die Statusanzeige gibt die neuen Arbeitsschritte der Reihe nach aus. Bei langen Archivschritten erscheint ein Zwischenstand in MiB. Scheitert der Restore nach Änderungen am Bestand, versucht der Server-Worker, den vorherigen Stand wiederherzustellen. Das Protokoll nennt den Verlauf und bei Bedarf die erhaltenen Rückfalldateien.

Der Restore spielt den SQL-Dump und die drei Datenarchive ein. Er übernimmt den Paperless-Schlüssel des Backups in die Compose-Konfiguration. Fehlt der Schlüssel oder ist er leer, verwendet das Programm seinen Legacy-Schlüssel. Die Wiederherstellung verschlüsselter Mail-Einstellungen erfolgt über den lokalen Restore.

### Betrieb und Fehlersuche

Das Backup prüft PostgreSQL 18, die tatsächlich eingebundenen Quellen und den freien Platz am gespeicherten Ziel. Ein eigener Docker-Backupcontainer hält Paperless während der Sicherung vorübergehend an. Er startet die gestoppten Dienste wieder und gibt den Zeitstempelordner nach erfolgreicher Archivprüfung frei. Bei Fehlern können Teildateien in einem `.paperless-*.partial`-Ordner verbleiben. Ein gestarteter Container kann bei unterbrochener SSH-Verbindung weiterlaufen.

Der erste Lauf benötigt gegebenenfalls Zugriff auf das Docker-CLI-Basisimage. Der SSH-Benutzer braucht Zugriff auf den lokalen Docker-Socket, Leserechte an den Sicherungsquellen und Schreibrechte am Backupziel. Die automatische SSH-Startprüfung zeigt den letzten Verbindungsstatus an. Neue Server-Fingerabdrücke vor der Bestätigung unabhängig vergleichen. Geänderte Schlüssel werden nicht automatisch ersetzt.

Die erzeugten PowerShell-Skripte bleiben pro Aufruf unter `Server` im Windows-Laufzeitordner. Der Dateiname besteht aus dem Zeitstempel im Format `JJJJ-MM-TT_HH-MM-SS` und der Endung `.ps1`. Bei Erfolg und bei erfassten Fehlern der Server-Wiederherstellung verweist der Dialog auf die gleichnamige `.log`-Datei unter `Logs` oder meldet einen Fehler beim Schreiben des Protokolls. Bei mehreren Aufrufen in derselben Sekunde verwendet das Programm den nächsten freien Zeitstempel. Das Skript zum Backupstart enthält auch den Linux-Starter und den Backupcontainer-Ablauf. SSH-Passwörter und Passphrasen bleiben in der Windows-Anmeldeinformationsverwaltung.

Die Statusabfrage für das Server-Backup verwendet Compose-Datei, Projekt und Backupziel. Das Downloadangebot nach einem erfolgreichen Lauf gehört zum zugehörigen Backupcontainer.

## Historischer Stand / Historical status – 08.10.2026

Version **5.26.10.100 ist veröffentlicht**. Die feste Skriptanbindung unten ist eine spätere, noch unveröffentlichte Quellcodeänderung dieses Chats. Keine neue Versionsnummer festgelegt.

Version **5.26.10.100 has been published**. The fixed script integration below is a later, unreleased source change from this chat. No new version number has been assigned.


## Download / Software herunterladen

**[Software für Windows herunterladen / Download the Windows software](https://downloads.ralf-peter-kleinert.de/software/paperless-backup-programm.html)**

Paperless Backup Programm is a Delphi/VCL application for Windows. It manages
Paperless-ngx locally with Docker Desktop or on a Docker server over SSH:
installation, backup, restore, transfers and image updates. Scheduled backups
are currently available for local installations.

Paperless Backup Programm ist eine Delphi/VCL-Anwendung für Windows. Sie verwaltet
Paperless-ngx lokal mit Docker Desktop oder auf einem Docker-Server über SSH:
Installation, Backup, Wiederherstellung, Übertragung und Image-Updates.
Geplante Backups stehen derzeit für lokale Installationen zur Verfügung.

## Features / Funktionen

- Create manual Paperless backups.
- Manuelle Paperless-Backups erstellen.
- Restore Paperless backups from a selected backup folder.
- Paperless-Backups aus einem ausgewaehlten Backup-Ordner wiederherstellen.
- Create Windows scheduled tasks for automatic backups.
- Windows-Aufgaben fuer automatische Backups erstellen.
- Generate and update `docker-compose.yml` for Paperless-ngx.
- `docker-compose.yml` fuer Paperless-ngx erzeugen und aktualisieren.
- Save Docker image versions with manual backups for later compatibility checks; scheduled local backups do not generate a new version file.
- Docker-Image-Versionen mit manuellen Backups speichern; geplante lokale Backups erzeugen keine neue Versionsdatei.
- Configure Paperless mail settings through `email-versand.env`.
- Paperless-Mail-Einstellungen ueber `email-versand.env` konfigurieren.
- Store Paperless mail settings in backups as encrypted `email-versand.env.enc`.
- Paperless-Mail-Einstellungen in Backups als verschluesselte `email-versand.env.enc` speichern.

## Requirements / Voraussetzungen

- Windows als Bedienrechner / Windows client.
- Lokal: Docker Desktop mit Linux-Containern / Local mode: Docker Desktop with Linux containers.
- Server: Windows-OpenSSH-Werkzeuge und ein erreichbarer Linux-Docker-Server mit Compose und passenden SSH-Rechten. Docker Desktop ist hierfür nicht erforderlich. / Server mode: Windows OpenSSH tools and a reachable Linux Docker/Compose host with appropriate SSH permissions; Docker Desktop is not required.
- Neuinstallation über die Serverfunktion: Debian 13 (amd64), Anmeldung als root. / Remote installation: Debian 13 (amd64), root login.
- Zum Kompilieren: Delphi 13 mit VCL, Ziel Win64. / To build: Delphi 13 with VCL, Win64 target.

Die Anwendung verwendet ausschließlich die mit Delphi mitgelieferten VCL-/RTL-Komponenten. Zusätzliche Komponenten oder Komponentenpakete von Drittanbietern müssen nicht installiert werden.

The application uses only VCL/RTL components supplied with Delphi. No additional components or third-party component packages need to be installed.

## Build / Kompilieren

Open `PaperlessBackupProgramm.dproj` in the Delphi 13 IDE and build the Win64 target.

Öffne `PaperlessBackupProgramm.dproj` in der Delphi-13-IDE und erstelle das Win64-Ziel.

Runtime settings use the PG18 folder below by default. A selected installation parent folder is respected; its Paperless Backup Programm PG18 subfolder is always used.

Laufzeiteinstellungen verwenden standardmäßig den PG18-Ordner unten. Bei eigener Installationspfadwahl wird der feste Unterordner Paperless Backup Programm PG18 im gewählten übergeordneten Ordner verwendet.

```text
%USERPROFILE%\Paperless Backup Programm PG18
```

## Important Notes / Wichtige Hinweise

- Test backup and restore before relying on the program for important data.
- Backup und Wiederherstellung testen, bevor das Programm fuer wichtige Daten verwendet wird.
- Keep at least one external backup copy.
- Mindestens eine externe Backup-Kopie aufbewahren.
- Restore should be tested before updating Paperless-ngx or Docker images.
- Die Wiederherstellung sollte vor Updates von Paperless-ngx oder Docker-Images getestet werden.
- The Paperless secret key is generated once and stored in `Einstellungen.ini`.
- Der Paperless Secret Key wird einmal erzeugt und in `Einstellungen.ini` gespeichert.
- Legacy installations store the old key separately as `Legacy-Paperless-Secret-Key`.
- Legacy-Installationen speichern den alten Key getrennt als `Legacy-Paperless-Secret-Key`.
- Keep this settings file when reusing an existing Paperless installation.
- Diese Einstellungsdatei behalten, wenn eine bestehende Paperless-Installation weiterverwendet wird.
- Existing installations without a saved key import the key from `docker-compose.yml` when available.
- Bestehende Installationen ohne gespeicherten Key importieren den Key aus `docker-compose.yml`, wenn er vorhanden ist.
- Manual and scheduled backups attempt to save the running Paperless container’s key in `paperless_secret_key.txt`. If this fails, the backup continues with a warning.
- Manuelle und geplante Backups versuchen, den Schlüssel des laufenden Paperless-Containers in `paperless_secret_key.txt` zu sichern. Bei einem Fehler läuft das Backup mit einer Warnung weiter.
- Restore reads the backup key; a missing or empty key uses the legacy key. A protected Compose file remains unchanged and its key takes precedence.
- Die Wiederherstellung liest den Backup-Schlüssel; bei fehlendem oder leerem Schlüssel wird der Legacy-Schlüssel verwendet. Eine geschützte Compose-Datei bleibt unverändert und ihr Schlüssel hat Vorrang.
- Backup archives are not encrypted by the Paperless secret key; protect the backup location separately.
- Die Backup-Archive werden nicht durch den Paperless Secret Key verschlüsselt; den Backup-Speicherort gesondert schützen.
- Keep this backup file private because it contains sensitive installation data.
- Diese Backup-Datei privat halten, da sie sensible Installationsdaten enthaelt.
- Mail settings are encrypted in backups with a user-provided password using Windows CNG (`bcrypt.dll`), PBKDF2-HMAC-SHA256, AES-256-CBC, and HMAC-SHA256.
- Mail-Einstellungen werden in Backups mit einem vom Benutzer vergebenen Passwort verschluesselt. Verwendet werden Windows CNG (`bcrypt.dll`), PBKDF2-HMAC-SHA256, AES-256-CBC und HMAC-SHA256.
- The backup password is not stored. If it is lost, `email-versand.env.enc` cannot be restored.
- Das Backup-Passwort wird nicht gespeichert. Bei Passwortverlust koennen die Mail-Einstellungen aus `email-versand.env.enc` nicht wiederhergestellt werden.
- The encrypted mail settings backup is portable across Windows PCs, but only with the correct password.
- Das verschluesselte Mail-Einstellungs-Backup ist auf andere Windows-PCs uebertragbar, aber nur mit dem richtigen Passwort.
- Manual backups create or update `email-versand.env.enc`; scheduled backups can only copy an already prepared encrypted file because they cannot ask for a password.
- Manuelle Backups erzeugen oder aktualisieren `email-versand.env.enc`; geplante Backups koennen nur eine bereits vorbereitete verschluesselte Datei kopieren, weil sie kein Passwort abfragen koennen.
- Use at your own risk.
- Verwendung auf eigene Gefahr.

## Repository Structure / Projektstruktur

- `Mainform.pas` - main application form and workflow coordination.
- `Mainform.pas` - Hauptformular und Ablaufsteuerung der Anwendung.
- `SetupForm.pas` - first-run notice, Docker check, and installation workflow.
- `SetupForm.pas` - Ersthinweis, Docker-Pruefung und Installationsablauf.
- `AppConfig.pas` - central file names, URLs, INI keys, and Docker defaults.
- `AppConfig.pas` - zentrale Dateinamen, URLs, INI-Schluessel und Docker-Standardwerte.
- `AppLogger.pas` - application logging for basic diagnostics.
- `AppLogger.pas` - Anwendungslogging fuer einfache Diagnose.
- `AppDialogs.pas` - centered application dialogs and message boxes.
- `AppDialogs.pas` - zentrierte Anwendungsdialoge und Meldungsfenster.
- `Crypto.pas` - password-based encryption helpers for sensitive backup files.
- `Crypto.pas` - passwortbasierte Verschluesselungshelfer fuer sensible Backup-Dateien.
- `ScriptGenerator.pas` - generation of backup, restore, restart, and scheduler scripts.
- `ScriptGenerator.pas` - Erzeugung von PowerShell-Skripten fuer Backup, Wiederherstellung, Neustart und Zeitplan.
- `DockerComposeGenerator.pas` - generation of the Paperless Docker Compose file.
- `DockerComposeGenerator.pas` - Erzeugung der Paperless-Docker-Compose-Datei.
- `assets/` - icons and images used by the application.
- `assets/` - Icons und Bilder der Anwendung.
- `update/` - update metadata.
- `update/` - Update-Metadaten.

## Projektleitung und Mitarbeit / Project leadership and contributions

Die Initiative zu diesem Projekt und die Projektleitung liegen bei Ralf-Peter Kleinert / ComputerRalle. Über die Entwicklungsrichtung, die Aufnahme von Beiträgen und offizielle Veröffentlichungen entscheidet Ralf-Peter Kleinert / ComputerRalle. Schreib- und Administrationsrechte für die offiziellen Repositories werden ausschließlich nach ausdrücklicher Freigabe vergeben.

Beiträge können über Pull Requests vorgeschlagen werden. Größere Änderungen und neue Funktionen sollen vorab mit der Projektleitung abgestimmt werden. Ein eingereichter oder übernommener Beitrag begründet keinen Anspruch auf Schreibrechte oder Mitentscheidung über das offizielle Projekt. Die Urheberrechte der jeweiligen Beitragenden bleiben bestehen.

Diese Regeln betreffen die Verwaltung des offiziellen Projekts. Die durch die GPLv3 gewährten Rechte, einschließlich eigener Änderungen und Abspaltungen, bleiben unberührt.

The project was initiated and is led by Ralf-Peter Kleinert / ComputerRalle. Ralf-Peter Kleinert / ComputerRalle decides on development direction, acceptance of contributions and official releases. Write and administrative access to the official repositories is granted only with explicit approval.

Contributions may be proposed through pull requests. Major changes and new features should be discussed with the project lead beforehand. Submitting or having a contribution accepted does not confer write access or decision-making authority over the official project. Contributors retain copyright in their respective contributions.

These rules govern administration of the official project. Rights granted by the GPLv3, including modifications and forks, remain unaffected.

## License / Lizenz

Copyright (C) 2026 Ralf-Peter Kleinert / ComputerRalle

This project is licensed under the GNU General Public License v3. See `LICENSE.txt`.
For commercial use without the obligation to disclose source code, please contact me for a separate license.

Dieses Projekt steht unter der GNU General Public License v3. Siehe `LICENSE.txt`.
Fuer kommerzielle Nutzung ohne Offenlegungspflicht kontaktieren Sie mich fuer eine separate Lizenz.


## Skripte vor der Verarbeitung / Pre-consume scripts – unreleased

Beim Erzeugen der Compose-Datei legt das Programm scripts im gewählten PG18-Installationsordner an. Eine fehlende master_pre_consume.sh wird als UTF-8 ohne BOM mit Linux-Zeilenumbrüchen angelegt:

~~~sh
#!/bin/sh
date -u >> /usr/src/paperless/scripts/script-test.log
exit 0
~~~

Die tatsächliche Vorlage enthält zusätzlich zweisprachige Kommentare. Sie protokolliert bei jedem Aufruf einen UTC-Zeitpunkt in script-test.log. Vorhandene Skripte bleiben erhalten. Keine Aktivierungs-Checkbox.

When generating Compose, the program creates scripts in the selected PG18 folder and a missing master_pre_consume.sh as a template that logs a UTC timestamp to script-test.log. Existing scripts are preserved; there is no activation checkbox.

Der Dienst paperless erhält immer folgenden Mount und Hook (Ausschnitt):

~~~yaml
volumes:
  - ./scripts:/usr/src/paperless/scripts
environment:
  PAPERLESS_PRE_CONSUME_SCRIPT: /usr/src/paperless/scripts/master_pre_consume.sh
~~~

./scripts folgt dem Compose-Verzeichnis. Installation/Update setzen mit einem kurzlebigen Container chmod 755 und prüfen test -x. Das Master kann eigene Logik enthalten oder weitere Skripte aufrufen. PDF-Entschlüsselung wird nicht mitgeliefert.

The relative scripts path follows the Compose directory. Setup/update use a temporary container to set and check execution permissions. The master may implement its own logic or call other scripts. PDF decryption is not supplied.

Vorhandene Installationen: Projekt neu erstellen, neue EXE einsetzen und Einstellungen mit bestätigtem Neustart/Update speichern. Der bestehende Ablauf kann Docker-Images aktualisieren. scripts gehört nicht zu den bisherigen Backup-/Restorearchiven; eigene Skripte separat sichern.

For existing installations, rebuild the project, deploy the new EXE and save settings with restart/update confirmed. This workflow may update Docker images. scripts is outside existing backup/restore archives; back up custom scripts separately.

Historische Win32-Generatorprüfungen sind dokumentiert. Für den aktuellen Stand stehen Win64-IDE-Build und vollständige Praxistests aus. / Historical Win32 generator checks are documented; the current Win64 IDE build and full runtime tests remain pending.

## Eigene Compose-Bearbeitungen schützen – Stand 17.11.2026

Im Tab **Einstellungen** schützt die entsprechende Checkbox eine vorhandene Compose-Datei vor automatischem Überschreiben. Aktivieren und mit **Einstellungen Speichern** übernehmen. Fehlende Dateien können angelegt werden. Generierte PowerShell-Skripte werden weiterhin aktualisiert; eigene Änderungen darin können verloren gehen. Eigene Dateien unter `scripts` bleiben erhalten.

Beim Aufheben des Schutzes zeigt die Anwendung den Sicherungsordner zur Bestätigung. **Nein** erhält den Schutz. **Ja** kopiert vorhandene `.ps1`, `.cmd`, `.bat`, `.sh`, `docker-compose.yml`, `compose.yml` sowie den vollständigen Unterordner `scripts` nach `<Installationsordner>\Eigene Bearbeitungen Backup\yyyy-mm-dd_hh-nn-ss`. Bei Kollision oder Kopierfehler bleibt der Schutz aktiv; eine teilweise angelegte Sicherung bleibt erhalten. Erst **Einstellungen Speichern** übernimmt das Aufheben dauerhaft.

Diese Dateisicherung ersetzt kein Paperless-Datenbackup. INI und separate Maildatei gehören nicht dazu. Reguläre Paperless-Backups enthalten `scripts` nicht; eigene Skripte separat sichern. Beim lokalen Update mit Schutz bleibt die eigene Compose-Datei maßgeblich. Im Servermodus bildet die aktuelle Server-Compose-Datei die Grundlage; nur ausdrücklich bearbeitete Image-Tags werden geändert.

English: Protection preserves an existing Compose file. Generated PowerShell scripts are still updated. Disabling protection requires confirmation and first backs up root scripts, Compose files and the full `scripts` tree. Failures retain protection. This file copy is not a Paperless data backup; custom scripts require separate backup.
