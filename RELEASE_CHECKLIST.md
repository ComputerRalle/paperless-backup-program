# Release Checklist / Release-Checkliste

Use this checklist before publishing a new Paperless Backup Programm release.

Diese Checkliste vor der Veroeffentlichung einer neuen Paperless Backup Programm Version verwenden.

## Prepare / Vorbereiten

- Check that the repository is clean before release work starts.
- Pruefen, dass das Repository vor der Release-Arbeit sauber ist.
- Review `CHANGELOG.md` and move finished entries from `Unreleased` into the new version.
- `CHANGELOG.md` pruefen und fertige Eintraege aus `Unreleased` in die neue Version verschieben.
- Check the program version in `PaperlessBackupProgram.dproj`.
- Programmversion in `PaperlessBackupProgram.dproj` pruefen.
- Check the update version in `update/update.ini`.
- Update-Version in `update/update.ini` pruefen.

## Build / Kompilieren

- Open `PaperlessBackupProgram.dproj` in Delphi.
- `PaperlessBackupProgram.dproj` in Delphi oeffnen.
- Select the Win32 Release target.
- Win32 Release-Ziel auswaehlen.
- Build the project without compiler errors.
- Projekt ohne Compilerfehler kompilieren.
- Keep generated Delphi files out of Git unless they are intentionally required.
- Generierte Delphi-Dateien nur dann in Git aufnehmen, wenn sie wirklich benoetigt werden.

## Smoke Test / Schnelltest

- Start the compiled program.
- Kompiliertes Programm starten.
- Check that the main form opens correctly.
- Pruefen, ob das Hauptformular korrekt geoeffnet wird.
- Check that saved settings are loaded.
- Pruefen, ob gespeicherte Einstellungen geladen werden.
- Check that Docker detection works.
- Pruefen, ob die Docker-Erkennung funktioniert.
- Check that the help and download links open the expected pages.
- Pruefen, ob Hilfe- und Downloadlinks die erwarteten Seiten oeffnen.

## Backup Test / Backup-Test

- Create a manual backup with a test Paperless installation.
- Manuelles Backup mit einer Test-Paperless-Installation erstellen.
- Check that the backup folder contains the expected files.
- Pruefen, ob der Backup-Ordner die erwarteten Dateien enthaelt.
- Check that `image_versionen.txt` is written when expected.
- Pruefen, ob `image_versionen.txt` wie erwartet geschrieben wird.
- Check that Paperless starts again after the backup.
- Pruefen, ob Paperless nach dem Backup wieder startet.

## Restore Test / Wiederherstellungs-Test

- Restore a backup into a test installation.
- Ein Backup in eine Testinstallation wiederherstellen.
- Check that Paperless starts after restore.
- Pruefen, ob Paperless nach der Wiederherstellung startet.
- Check that documents and metadata are available.
- Pruefen, ob Dokumente und Metadaten verfuegbar sind.
- Check that the database restore has no visible errors.
- Pruefen, ob die Datenbank-Wiederherstellung keine sichtbaren Fehler zeigt.

## Scheduled Backup Test / Test Geplantes Backup

- Create or update a scheduled backup task.
- Geplante Backup-Aufgabe erstellen oder aktualisieren.
- Check the task in Windows Task Scheduler.
- Aufgabe in der Windows-Aufgabenplanung pruefen.
- Run the scheduled task manually once.
- Geplante Aufgabe einmal manuell ausfuehren.
- Check that the planned backup folder is created.
- Pruefen, ob der geplante Backup-Ordner erstellt wird.
- Remove the scheduled task again when it was only used for testing.
- Geplante Aufgabe wieder entfernen, wenn sie nur fuer den Test angelegt wurde.

## Package / Paket erstellen

- Create the release ZIP or installer package.
- Release-ZIP oder Installer-Paket erstellen.
- Include only required runtime files.
- Nur benoetigte Laufzeitdateien aufnehmen.
- Do not include Delphi build folders, history folders, cache files, or local settings.
- Keine Delphi-Buildordner, History-Ordner, Cache-Dateien oder lokalen Einstellungen aufnehmen.
- Test the package on a clean Windows system or VM when possible.
- Paket nach Moeglichkeit auf einem sauberen Windows-System oder in einer VM testen.

## Publish / Veroeffentlichen

- Commit the final release changes with an English / German commit message.
- Finale Release-Aenderungen mit englischer / deutscher Commit-Message committen.
- Push the commit to Codeberg.
- Commit zu Codeberg pushen.
- Upload the release package to the download page.
- Release-Paket auf die Downloadseite hochladen.
- Check that the public download link works.
- Pruefen, ob der oeffentliche Downloadlink funktioniert.
- Check that the download page changelog matches `CHANGELOG.md`.
- Pruefen, ob der Changelog auf der Downloadseite zu `CHANGELOG.md` passt.

