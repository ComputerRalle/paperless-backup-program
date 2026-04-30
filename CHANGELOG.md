# Changelog

All notable changes to this project are documented here.

Alle wichtigen Aenderungen an diesem Projekt werden hier dokumentiert.

## Unreleased / Noch nicht veroeffentlicht

- Switched the project license to GNU General Public License v3.
- Projektlizenz auf GNU General Public License v3 umgestellt.
- Updated copyright notices to `Copyright (C) 2026 Ralf-Peter Kleinert / ComputerRalle`.
- Copyright-Hinweise auf `Copyright (C) 2026 Ralf-Peter Kleinert / ComputerRalle` aktualisiert.
- Centralized application file names, URLs, INI version keys, and Docker defaults in `AppConfig.pas`.
- Dateinamen, URLs, INI-Versionsschluessel und Docker-Standardwerte in `AppConfig.pas` zentralisiert.
- Added `README.md` and this `CHANGELOG.md` for the repository.
- `README.md` und diese `CHANGELOG.md` fuer das Repository ergaenzt.
- Cleaned up the repository structure and removed generated Delphi history files from version control.
- Projektstruktur bereinigt und generierte Delphi-History-Dateien aus der Versionsverwaltung entfernt.
- Moved generated script and Docker Compose content into dedicated units.
- Generierte Skripte und Docker-Compose-Inhalte in eigene Units ausgelagert.
- Added German comments below the existing English comments.
- Deutsche Kommentare unter den vorhandenen englischen Kommentaren ergaenzt.

## 5.25.10.100 - 2025-10-29

- Published the source code on Codeberg and added license documentation.
- Quellcode auf Codeberg veroeffentlicht und Lizenzdokumentation ergaenzt.
- Updated project and update metadata to version `5.25.10.100`.
- Projekt- und Update-Metadaten auf Version `5.25.10.100` aktualisiert.

## 4.25.10.104 - 2025-10-28

- Added update checking for the Paperless Backup Programm itself.
- Updatepruefung fuer das Paperless Backup Programm selbst ergaenzt.
- Corrected version comparison by removing dots, padding version segments, and building a sortable version string.
- Versionsvergleich korrigiert, indem Punkte entfernt, Versionssegmente aufgefuellt und eine sortierbare Versionszeichenkette erzeugt werden.
- Finalized version `4.25.10.104` for upload to the download page.
- Version `4.25.10.104` fuer den Upload auf die Downloadseite finalisiert.
- Adjusted Docker image versions: Redis 7, Postgres 17, Gotenberg 8, Tika latest, Alpine 3, Busybox 1.
- Docker-Image-Versionen angepasst: Redis 7, Postgres 17, Gotenberg 8, Tika latest, Alpine 3, Busybox 1.

## 4.25.10.103 - 2025-10-28

- Added `.gitignore`, switched project metadata from debug to release, and updated program metadata.
- `.gitignore` ergaenzt, Projektmetadaten von Debug auf Release umgestellt und Programm-Metadaten aktualisiert.
- Cleaned the repository in several steps.
- Repository in mehreren Schritten bereinigt.
- Removed obsolete removed-procedures text from version control.
- Veraltete Datei mit entfernten Prozeduren aus der Versionsverwaltung entfernt.
- Renamed `AppDataOrdner` to `AppDataFolder`.
- `AppDataOrdner` in `AppDataFolder` umbenannt.

## 4.25.10.100 - 2025-10-27

- Initial source upload of Paperless Backup Programm version `4.25.10.100`.
- Erster Quellcode-Upload des Paperless Backup Programms Version `4.25.10.100`.
- Renamed the main form class from `TForm1` / `Form1` to `TMainformFrm` / `MainformFrm`.
- Hauptformular-Klasse von `TForm1` / `Form1` in `TMainformFrm` / `MainformFrm` umbenannt.
- Added and connected logo, icon, and bitmap assets.
- Logo-, Icon- und Bitmap-Dateien ergaenzt und eingebunden.
- Switched the VCL style from Windows 10 Dark to Windows 11 Modern Dark.
- VCL-Stil von Windows 10 Dark auf Windows 11 Modern Dark umgestellt.
