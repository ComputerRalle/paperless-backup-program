# Paperless Backup Programm

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

## Build / Kompilieren

Open `PaperlessBackupProgramm.dproj` in Delphi and build the Win32 target.

Oeffne `PaperlessBackupProgramm.dproj` in Delphi und kompiliere das Win32-Ziel.

The application stores runtime settings in the user profile folder:

Die Anwendung speichert Laufzeiteinstellungen im Benutzerprofil:

```text
%USERPROFILE%\Paperless Backup Programm
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
- Each successful backup stores the active Paperless secret key in `paperless_secret_key.txt`.
- Jedes erfolgreiche Backup speichert den aktiven Paperless Secret Key in `paperless_secret_key.txt`.
- Restore imports the secret key from `paperless_secret_key.txt`; older backups without this file use the legacy key.
- Die Wiederherstellung importiert den Secret Key aus `paperless_secret_key.txt`; aeltere Backups ohne diese Datei verwenden den Legacy-Key.
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

## License / Lizenz

Copyright (C) 2026 Ralf-Peter Kleinert / ComputerRalle

This project is licensed under the GNU General Public License v3. See `LICENSE.txt`.
For commercial use without the obligation to disclose source code, please contact me for a separate license.

Dieses Projekt steht unter der GNU General Public License v3. Siehe `LICENSE.txt`.
Fuer kommerzielle Nutzung ohne Offenlegungspflicht kontaktieren Sie mich fuer eine separate Lizenz.
