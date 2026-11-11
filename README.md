# Paperless Backup Programm

## Aktueller Stand Serveranbindung – 11.11.2026

Der Backup-Button verzweigt nach Betriebsart: Der lokale Ablauf bleibt bestehen; im Serverbetrieb startet BackupRestoreServer.pas eine lesende Speicherplatzprüfung, noch kein Backup. Die Compose-Datei wird per SSH in einem geschützten temporären Unterordner von Server im Laufzeitordner abgelegt und lokal gelesen. Docker Compose normalisiert die gelesenen Daten auf dem Server; das Ergebnis wird lokal im Speicher ausgewertet. Die Prüfung schätzt verwendete Volumes und Bind-Mounts und zeigt den freien Platz auf dem Dateisystem des Compose-Ordners. Ein tatsächliches Backupziel ist noch nicht festgelegt. Nach der Prüfung wird die temporäre Kopie gelöscht; bei Bereinigungsfehler erscheint eine Warnung. Python auf dem Server ist dafür nicht nötig. Ein gespeicherter SSH-Hostschlüssel, JSON-fähiges Compose, ein lokaler Docker-Daemon und ausreichende Leserechte sind Voraussetzungen. PowerShell und simulierte Abläufe wurden geprüft; ein Win64-IDE-Build und praktische SSH-/Docker-/GUI-Tests stehen aus. Externe Backup-, Restore-, Update- und Zeitplanfunktionen sind nicht implementiert.

Die automatische SSH-Startprüfung für Paperless Extern verwendet die gespeicherten Serverdaten und Windows-Zugangsdaten. Im Kopf steht je nach Testergebnis „Server verbunden“ oder „Server nicht verbunden“; fehlende Verbindungsdaten und die laufende Prüfung werden gesondert angezeigt. Der Status beschreibt den letzten Test, keine dauerhaft offene SSH-Verbindung. Unbekannte Server-Fingerabdrücke müssen unabhängig verglichen und bestätigt werden; bestätigte Schlüssel können nach erfolgreicher Anmeldung für spätere Verbindungen gespeichert oder nur für den aktuellen Test verwendet werden. Geänderte Schlüssel werden nicht automatisch ersetzt. Die erzeugte PowerShell und simulierte Fälle wurden geprüft; ein Delphi-13-Win64-IDE-Build und praktische Tests mit Server und Askpass stehen aus. Die Benutzeranleitung ist noch an diesen Ablauf anzupassen.

Stand 11.11.2026: Die externe Serveranbindung ist in Vorbereitung. Serverdaten und Anmeldeart werden gespeichert; Passwort und SSH-Key-Passphrase liegen in der Windows-Anmeldeinformationsverwaltung. Der sichtbare SSH-Test prüft Docker Compose sowie Existenz und Lesbarkeit der Compose-Datei; ein manueller Test mit Passwort wurde vom Benutzer bestätigt. Der optionale Askpass-Helfer für gespeicherte Zugangsdaten ist noch nicht praktisch mit ssh.exe bestätigt. Externe Backup-, Restore-, Update- und Zeitplanfunktionen sind noch nicht implementiert. Lokale Einstellungen und bestehende geplante Aufgaben bleiben getrennt. Historische Angaben weiter unten sind anhand des aktuellen Quellcodes und neuerer Revisionen zu prüfen.


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

Open `PaperlessBackupProgramm.dproj` in Delphi and build the Win32 target.

Oeffne `PaperlessBackupProgramm.dproj` in Delphi und kompiliere das Win32-Ziel.

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
