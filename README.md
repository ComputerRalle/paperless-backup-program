# Paperless Backup Programm

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
3. **Paperless installieren** wählen, den SSH-Fingerabdruck im Dialog bestätigen und anschließend den Installationsauftrag bestätigen. Das Programm aktualisiert Debian-Pakete, installiert Docker und Compose und startet Paperless mit PostgreSQL 18 unter `/opt/paperless`. Ein belegter Installationsordner wird vor der Paketaktualisierung abgelehnt.
4. Nach der Erfolgsmeldung **Paperless im Browser aufrufen** wählen und dort den Paperless-Admin anlegen. Der Eingangsordner ist über `\\<Server-IP>\paperless-consume` als beschreibbare Samba-Gastfreigabe vorgesehen. Windows kann Gastzugriffe abhängig von der SMB-Konfiguration ablehnen.
5. Der Dialog zeigt nach erfolgreicher Installation die Webadresse, die Samba-Freigabe und die Logdatei unter `Logs` an. Die Anwendung speichert Compose-Ordner, Projektname und Webport für spätere Aufrufe. Wenn ein später Schritt fehlschlägt und die Compose-Datei bereits angelegt wurde, bleibt sie auf dem Server. Den fehlgeschlagenen Schritt anhand der Logdatei prüfen.

### Server einrichten und sichern

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

## Stand / Status – 08.10.2026

Version **5.26.10.100 ist veröffentlicht**. Die feste Skriptanbindung unten ist eine spätere, noch unveröffentlichte Quellcodeänderung dieses Chats. Keine neue Versionsnummer festgelegt.

Version **5.26.10.100 has been published**. The fixed script integration below is a later, unreleased source change from this chat. No new version number has been assigned.


## Download / Software herunterladen

**[Software für Windows herunterladen / Download the Windows software](https://downloads.ralf-peter-kleinert.de/software/paperless-backup-programm.html)**

Paperless Backup Programm is a Delphi/VCL helper for Windows systems running
Paperless-ngx with Docker Desktop. It can install Paperless-ngx, create backups,
restore backups, prepare scheduled backups, and manage selected Docker image
versions from one desktop application.

Paperless Backup Programm ist ein Delphi/VCL-Hilfsprogramm fuer Windows-Systeme,
auf denen Paperless-ngx mit Docker Desktop laeuft. Es kann Paperless-ngx
installieren, Backups erstellen, Backups wiederherstellen, geplante Backups
vorbereiten und ausgewaehlte Docker-Image-Versionen verwalten.

## Features / Funktionen

- Create manual Paperless backups.
- Manuelle Paperless-Backups erstellen.
- Restore Paperless backups from a selected backup folder.
- Paperless-Backups aus einem ausgewaehlten Backup-Ordner wiederherstellen.
- Create Windows scheduled tasks for automatic backups.
- Windows-Aufgaben fuer automatische Backups erstellen.
- Generate and update `docker-compose.yml` for Paperless-ngx.
- `docker-compose.yml` fuer Paperless-ngx erzeugen und aktualisieren.
- Save Docker image versions with backups for later compatibility checks.
- Docker-Image-Versionen mit Backups speichern, um spaeter die Kompatibilitaet pruefen zu koennen.
- Configure Paperless mail settings through `email-versand.env`.
- Paperless-Mail-Einstellungen ueber `email-versand.env` konfigurieren.
- Store Paperless mail settings in backups as encrypted `email-versand.env.enc`.
- Paperless-Mail-Einstellungen in Backups als verschluesselte `email-versand.env.enc` speichern.

## Requirements / Voraussetzungen

- Windows
- Docker Desktop
- Delphi with VCL support for building from source
- A working Paperless-ngx Docker setup, or Docker Desktop ready for first setup

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
exit 0
~~~

Die tatsächliche Vorlage enthält zusätzlich Kommentare. Ohne eigene Ergänzungen tut sie nichts. Vorhandene Skripte bleiben erhalten. Keine Aktivierungs-Checkbox.

When generating Compose, the program creates scripts in the selected PG18 folder and a missing master_pre_consume.sh as a harmless template. Existing scripts are preserved; there is no activation checkbox.

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

Isolierter Win32-Build und Generatorprüfungen erfolgreich; echte GUI-/Docker-Ausführung steht aus. / Isolated Win32 build and generator checks passed; actual GUI/Docker execution remains untested.

## Eigene Bearbeitungen schützen – Stand 25.10.2026

Im Tab **Einstellungen** sitzt unter Paperless-Version und rechts neben Tika-Version die Checkbox **„Scripte und compose.yml für eigene Bearbeitung sperren“** (`MainformFrm`, `SettingsPan`, `ProtectCustomFilesCB`). Sie ist standardmäßig ausgeschaltet und unabhängig von der Versionsfreigabe. Die Auswahl wird mit **Einstellungen Speichern** dauerhaft übernommen und beim nächsten Start geladen.

Beim Aktivieren erklärt ein Ja/Nein-Warnfenster die Verantwortung für die eigene Dateipflege. Vorhandene `docker-compose.yml` und vom Programm erzeugte PowerShell-Skripte werden bei gespeichertem Schutz weder überschrieben noch als Einmalskripte nach dem Lauf gelöscht. Fehlende Dateien können weiterhin angelegt werden. Eigene Dateien unter `scripts` bleiben wie bisher erhalten. Es gibt keine Umleitung in einen anderen Arbeitsordner.

Backup, Wiederherstellung und Updates führen weiterhin die vorhandenen Dateien aus. Deshalb müssen Pfade, Backupziele, Wiederherstellungsquellen, Imageversionen und weitere Angaben darin selbst gepflegt werden. Änderungen in der Oberfläche werden nicht automatisch in geschützte Dateien eingetragen. Nach eigenen Änderungen **Einstellungen Speichern** anklicken und den Neustart bestätigen; der vorhandene Installations-/Updateablauf verwendet die Dateien und kann weiterhin Dockeraktionen und Image-Downloads ausführen.

Beim Entfernen des Häkchens erscheint vorab eine zweite Ja/Nein-Warnung mit dem vollständigen Sicherungsordner. **Nein** lässt den Haken gesetzt. **Ja** kopiert zuerst:

- vorhandene `.ps1`, `.cmd`, `.bat` und `.sh` im Installationsordner;
- `docker-compose.yml` und eine gegebenenfalls vorhandene `compose.yml`;
- sämtliche Dateien unter `scripts`, einschließlich der Unterordnerstruktur und Hilfsdateien.

Ziel ist `<Installationsordner>\Eigene Bearbeitungen Backup\yyyy-mm-dd_hh-nn-ss`, beispielsweise `2026-10-25_14-30-00`. Es gibt keine ID und keinen zusätzlichen Namenszusatz. Vorhandene Sicherungen werden nicht überschrieben. Existiert derselbe Zeitstempel bereits, bleibt der Schutz erhalten; erneut versuchen. Quellen werden nur kopiert, Dateiinhalte nicht neu codiert. Andere Dateien wie Einstellungen.ini und die separate Maildatei gehören nicht zu dieser Sicherung; diese ersetzt kein Paperless-Datenbackup und keine bisherige Backup-/Restorefunktion.

Nach erfolgreichem Kopieren nennt eine Meldung den tatsächlichen Sicherungsordner. Erst **Einstellungen Speichern** übernimmt die aufgehobene Sperre. Bei Kopierfehler wird der Haken wieder gesetzt; eine Fehlermeldung erscheint und eine teilweise angelegte Sicherung bleibt erhalten. Der vorbeugende Hinweis auf Kopierfehler wurde auf Benutzerwunsch aus beiden Warnfenstern entfernt; die Fehlerbehandlung bleibt bestehen. Laden gespeicherter Einstellungen und Nein im Aktivierungsfenster erzeugen keine Sicherung und keine erneute Aktivierungswarnung.

Prüfstand: Codepfade, Ereignisbindung, Dateiformate und Diffs statisch geprüft. Die lokale Delphi-13-Ausgabe unterstützt keinen Kommandozeilenbuild; IDE-Build erforderlich. Kein GUI-, tatsächlicher Delphi-Dateikopier- oder Dockerlauf durch diesen Chat. Keine Veröffentlichung und keine neue Programmversion bestätigt.

English: The saved settings checkbox preserves existing Compose and generated PowerShell files for manual maintenance. Disabling it requires confirmation and copies root scripts, Compose and the complete scripts file tree into a timestamp-only backup directory before unlocking can be saved. Failures keep protection enabled. Existing files still control backup, restore and update behavior. Static checks only; build and runtime verification in Delphi remain required.
