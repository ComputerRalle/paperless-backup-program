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

## Requirements / Voraussetzungen

- Windows
- Docker Desktop
- Delphi with VCL support for building from source
- A working Paperless-ngx Docker setup, or Docker Desktop ready for first setup

## Build / Kompilieren

Open `PaperlessBackupProgram.dproj` in Delphi and build the Win32 target.

Oeffne `PaperlessBackupProgram.dproj` in Delphi und kompiliere das Win32-Ziel.

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
- Use at your own risk.
- Verwendung auf eigene Gefahr.

## Repository Structure / Projektstruktur

- `Mainform.pas` - main application form and workflow coordination.
- `Mainform.pas` - Hauptformular und Ablaufsteuerung der Anwendung.
- `HinweisForm.pas` - first-run notice, Docker check, and installation workflow.
- `HinweisForm.pas` - Ersthinweis, Docker-Pruefung und Installationsablauf.
- `ScriptGenerator.pas` - generation of backup, restore, restart, and scheduler scripts.
- `ScriptGenerator.pas` - Erzeugung von Backup-, Restore-, Neustart- und Zeitplan-Skripten.
- `DockerComposeGenerator.pas` - generation of the Paperless Docker Compose file.
- `DockerComposeGenerator.pas` - Erzeugung der Paperless-Docker-Compose-Datei.
- `assets/` - icons and images used by the application.
- `assets/` - Icons und Bilder der Anwendung.
- `update/` - update metadata.
- `update/` - Update-Metadaten.

## License / Lizenz

This project is published under the MIT License. See `LICENSE.txt`.

Dieses Projekt steht unter der MIT-Lizenz. Siehe `LICENSE.txt`.

