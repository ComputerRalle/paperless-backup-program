# Changelog

All notable changes to this project are documented here.

Alle wichtigen Aenderungen an diesem Projekt werden hier dokumentiert.

## 5.26.4.105 - 2026-05-11

- Added password-based encryption for Paperless mail settings in backups as `email-versand.env.enc`.
- Passwortbasierte Verschluesselung fuer Paperless-Mail-Einstellungen in Backups als `email-versand.env.enc` ergaenzt.
- Added a masked password dialog with password confirmation for encrypted mail settings backups.
- Maskierten Passwortdialog mit Passwortwiederholung fuer verschluesselte Mail-Einstellungs-Backups ergaenzt.
- Clarified the backup mail encryption dialog cancel button so users can intentionally continue without mail settings.
- Abbrechen-Schaltflaeche im Backup-Mail-Verschluesselungsdialog verdeutlicht, damit Benutzer bewusst ohne Mail-Einstellungen fortfahren koennen.
- Added a restore option to continue without mail settings when the encrypted mail settings password is missing or wrong.
- Wiederherstellungsoption ergaenzt, um bei fehlendem oder falschem Mail-Passwort ohne Mail-Einstellungen fortzufahren.
- Scheduled backups now copy a prepared encrypted mail settings file when one is available.
- Geplante Backups kopieren eine vorbereitete verschluesselte Mail-Einstellungsdatei, wenn sie vorhanden ist.
- Restores now decrypt `email-versand.env.enc` back to `email-versand.env` when the encrypted file exists and the user provides the correct password.
- Wiederherstellungen entschluesseln `email-versand.env.enc` wieder zu `email-versand.env`, wenn die verschluesselte Datei vorhanden ist und das richtige Passwort eingegeben wird.
- Kept mail settings restore optional so older backups without `email-versand.env.enc` continue without error.
- Wiederherstellung der Mail-Einstellungen optional gehalten, damit aeltere Backups ohne `email-versand.env.enc` ohne Fehler weiterlaufen.
- Preserved existing configured `email-versand.env` files so automatic setup/update steps no longer overwrite filled mail settings.
- Vorhandene befuellte `email-versand.env`-Dateien werden erhalten, damit automatische Setup-/Update-Schritte Mail-Einstellungen nicht mehr ueberschreiben.
- Added a Paperless browser button on the backup tab and hid old path/script information labels from the main UI.
- Paperless-Browser-Button im Backup-Tab ergaenzt und alte Pfad-/Skriptinformationslabels aus der Hauptoberflaeche ausgeblendet.
- Added a welcome headline that is hidden after user interaction.
- Willkommensueberschrift ergaenzt, die nach Benutzerinteraktion ausgeblendet wird.
- Added a busy state that disables controls and locks tab changes while backup, restore, update, restart, or mail settings scripts are running.
- Beschaeftigt-Zustand ergaenzt, der Bedienelemente sperrt und Tabwechsel verhindert, waehrend Backup-, Wiederherstellungs-, Update-, Neustart- oder Mail-Einstellungs-Skripte laufen.
- Added operation-specific wait text, including mail settings status while applying `email-versand.env`.
- Vorgangsspezifische Wartetexte ergaenzt, inklusive Mail-Einstellungsstatus beim Anwenden von `email-versand.env`.
- Added setup form progress output for Paperless installation commands.
- Statusausgabe und Fortschrittsanzeige fuer Paperless-Installationsbefehle im Setup-Formular ergaenzt.
- Moved forms to screen center and centered dialogs over the active form.
- Formulare auf Bildschirmmitte gesetzt und Dialoge ueber dem aktiven Formular zentriert.
- Switched settings and mail-settings save flows back to the backup/restore tab so users can see script status.
- Einstellungen- und Mail-Einstellungen-Speichern wechseln nun zum Backup-/Wiederherstellen-Tab, damit Benutzer den Skriptstatus sehen.
- Fixed first-run setup cancellation so declining Paperless installation stops the setup flow instead of continuing invisibly.
- Abbruch der Ersteinrichtung korrigiert, damit eine abgelehnte Paperless-Installation den Ablauf stoppt statt unsichtbar weiterzulaufen.
- Kept Django database migration warnings non-fatal so update and restore scripts can continue when Paperless is not ready yet.
- Django-Datenbankmigrationswarnungen nicht-fatal gehalten, damit Update- und Wiederherstellungsskripte weiterlaufen koennen, wenn Paperless noch nicht bereit ist.
- Added timeout and live pipe reading for hidden command output to avoid hangs when Docker or PowerShell writes more output.
- Timeout und laufendes Pipe-Lesen fuer versteckte Befehlsausgaben ergaenzt, um Haenger bei groesserer Docker- oder PowerShell-Ausgabe zu vermeiden.
- Fixed setup-form lifetime handling when compose files and image version metadata are written from the main form.
- Lebensdauerbehandlung des Setup-Formulars korrigiert, wenn Compose-Dateien und Image-Versionen aus dem Hauptformular geschrieben werden.
- Updated project version metadata to `5.26.4.104`.
- Projekt-Versionsmetadaten auf `5.26.4.104` aktualisiert.
- Updated update metadata to `5.26.4.105`.
- Update-Metadaten auf `5.26.4.105` aktualisiert.
- Documented the Windows CNG based encryption approach and password-loss limitation.
- Windows-CNG-basierte Verschluesselung und die Einschraenkung bei verlorenem Passwort dokumentiert.
- Switched generated backup, restore, restart, update, and scheduler scripts from CMD to PowerShell.
- Generierte Backup-, Wiederherstellungs-, Neustart-, Update- und Zeitplan-Skripte von CMD auf PowerShell umgestellt.
- Switched generated PowerShell scripts from the isolated Django ContentType migration to the full Django database migration.
- Generierte PowerShell-Skripte von der einzelnen Django-ContentType-Migration auf die vollstaendige Django-Datenbankmigration umgestellt.
- Added an in-application status label and progress bar while visible PowerShell scripts are running.
- Statuslabel und Fortschrittsanzeige in der Anwendung ergaenzt, waehrend sichtbare PowerShell-Skripte laufen.
- Hid the old backup and restore readiness labels while scripts are running.
- Alte Backup- und Wiederherstellungs-Hinweise waehrend laufender Skripte ausgeblendet.
- Mirrored visible PowerShell output into the main form status label while scripts are running.
- Sichtbare PowerShell-Ausgabe waehrend laufender Skripte in das Statuslabel des Hauptformulars gespiegelt.
- Replaced generic PowerShell startup text with operation-specific status messages and shortened long label text.
- Allgemeine PowerShell-Startmeldung durch vorgangsspezifische Statusmeldungen ersetzt und lange Labeltexte gekuerzt.
- Removed the old backup and restore readiness texts from the main form.
- Alte Backup- und Wiederherstellungs-Bereitschaftstexte aus dem Hauptformular entfernt.
- Set operation-specific final status texts and moved the status label and progress bar upward.
- Vorgangsspezifische Abschlussmeldungen gesetzt und Statuslabel sowie Fortschrittsanzeige nach oben verschoben.
- Ran monitored PowerShell scripts without showing a console window.
- Ueberwachte PowerShell-Skripte ohne sichtbares Konsolenfenster ausgefuehrt.
- Centered application messages, folder picker dialogs, and setup windows over the main form.
- Anwendungsmitteilungen, Ordnerauswahldialoge und Einrichtungsfenster ueber dem Hauptformular zentriert.
- Reapplied settings automatically after restore so the database collation maintenance runs.
- Einstellungen nach der Wiederherstellung automatisch neu angewendet, damit die Datenbank-Collation-Wartung laeuft.
- Opened the restore folder picker in the last saved backup target folder.
- Ordnerauswahl fuer die Wiederherstellung im zuletzt gespeicherten Backup-Zielordner geoeffnet.
- Used the legacy Paperless secret key for restores from older backups without `paperless_secret_key.txt`.
- Legacy-Paperless-Secret-Key fuer Wiederherstellungen aus aelteren Backups ohne `paperless_secret_key.txt` verwendet.
- Separated new and legacy Paperless secret keys so fresh installations no longer receive the legacy key.
- Neue und Legacy-Paperless-Secret-Keys getrennt, damit Neuinstallationen nicht mehr den Legacy-Key erhalten.
- Renamed `HinweisForm` to `SetupForm` to better match the setup workflow.
- `HinweisForm` in `SetupForm` umbenannt, damit der Name besser zum Einrichtungsablauf passt.
- Added `paperless_secret_key.txt` to successful backups so the active Paperless secret key is preserved.
- `paperless_secret_key.txt` zu erfolgreichen Backups ergaenzt, damit der aktive Paperless Secret Key erhalten bleibt.
- Kept the legacy Paperless secret key fallback for existing installations.
- Legacy-Fallback fuer bestehende Paperless-Installationen beibehalten.
- Replaced the hard-coded Paperless secret key with a generated and persisted installation key.
- Fest eingetragenen Paperless Secret Key durch einen erzeugten und gespeicherten Installations-Key ersetzt.
- Added an application logger and first diagnostic log entries.
- Anwendungslogger und erste Diagnose-Logeintraege ergaenzt.
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
