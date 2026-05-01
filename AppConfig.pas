// --------------------------------------------------------------
// Original author: Ralf-Peter Kleinert - 2025
// Ursprünglicher Autor: Ralf-Peter Kleinert - 2025
// Alias: #ComputerRalle / DIGITAL-easy
// Künstlername: #ComputerRalle / DIGITAL-easy
// Project: Paperless Backup Program / Paperless Backup Programm
// Projekt: Paperless Backup Program / Paperless Backup Programm
// Website: https://ralf-peter-kleinert.de
// Webseite: https://ralf-peter-kleinert.de
// YouTube: https://www.youtube.com/@ralf-peter-kleinert
// YouTube-Kanal: https://www.youtube.com/@ralf-peter-kleinert
// Copyright (C) 2026 Ralf-Peter Kleinert / ComputerRalle
// Urheberrecht (C) 2026 Ralf-Peter Kleinert / ComputerRalle
// GNU General Public License v3 - see LICENSE.txt in the repository
// GNU General Public License v3 - siehe LICENSE.txt im Repository
// --------------------------------------------------------------

unit AppConfig;

interface

const
  // Application names and folders.
  // Anwendungsnamen und Ordner.
  AppDisplayName = 'Paperless Backup Programm';
  AppStatusTitle = '#ComputerRalle - Paperless Backup Programm ';
  AppDataFolderName = 'Paperless Backup Programm';

  // Runtime file names.
  // Dateinamen zur Laufzeit.
  SettingsFileName = 'Einstellungen.ini';
  BackupTargetFileName = 'BackupZiel.txt';
  ComposePathFileName = 'DockerComposePfad.txt';
  InstallationCompletedFileName = 'InstallationAbgeschlossen.txt';
  NoticeAcceptedFileName = 'HinweisVerstanden.txt';
  DockerComposeFileName = 'docker-compose.yml';
  EmailEnvFileName = 'email-versand.env';
  EmailEnvEncryptedFileName = 'email-versand.env.enc';
  ContainerVolumeInfoFileName = 'ContainerUndVolumesInfo.txt';
  ImageVersionsFileName = 'image_versionen.txt';
  PaperlessSecretKeyFileName = 'paperless_secret_key.txt';
  UpdateIniFileName = 'update.ini';
  ApplicationLogFileName = 'PaperlessBackupProgram.log';

  // INI sections and keys.
  // INI-Abschnitte und Schluessel.
  IniSectionVersions = 'Versionen';
  IniSectionSecurity = 'Sicherheit';
  IniKeyPaperlessVersion = 'Paperless-Version';
  IniKeyPostgresVersion = 'Postgres-Version';
  IniKeyRedisVersion = 'Redis-Version';
  IniKeyGotenbergVersion = 'Gotenberg-Version';
  IniKeyTikaVersion = 'Tika-Version';
  IniKeyAlpineVersion = 'Alpine-Version';
  IniKeyBusyboxVersion = 'Busybox-Version';
  IniKeyPaperlessSecretKey = 'Paperless-Secret-Key';
  IniKeyLegacyPaperlessSecretKey = 'Legacy-Paperless-Secret-Key';

  // Default Docker image versions.
  // Standardversionen der Docker-Images.
  DefaultPaperlessVersion = '2.20.15';
  DefaultPostgresVersion = '17';
  DefaultRedisVersion = '8';
  DefaultGotenbergVersion = '8.25';
  DefaultTikaVersion = 'latest';
  DefaultAlpineVersion = '3';
  DefaultBusyboxVersion = '1';
  LegacyPaperlessSecretKey = 'aksjdfhs87H/(&986jlkhgiu87659zol';

  // External links.
  // Externe Links.
  UpdateInfoUrl = 'https://ralf-peter-kleinert.de/paperless-backup-programm-update/update.ini';
  DockerDesktopUrl = 'https://www.docker.com/products/docker-desktop/';
  PaperlessLocalUrl = 'http://localhost:8000';
  PaperlessLocalUrlWithSlash = 'http://localhost:8000/';
  PaperlessFallbackLocalUrl = 'http://localhost:8080';
  ComputerRalleUrl = 'https://ralf-peter-kleinert.de';
  BuyMeACoffeeUrl = 'https://buymeacoffee.com/computerralle';
  KeePassHelpVideoUrl = 'https://www.youtube.com/watch?v=j4DWjU9XucI';
  ImprintUrl = 'https://ralf-peter-kleinert.de/impressum.html';
  PaperlessPlaylistUrl = 'https://www.youtube.com/playlist?list=PL0CRlqUkwGBm4wl1wYWen3L6jHIXhq3T7';
  YouTubeChannelUrl = 'https://www.youtube.com/@ralf-peter-kleinert';
  BackupGuideUrl = 'https://ralf-peter-kleinert.de/linux-os/paperless-backup-programm.html';
  BlogUrl = 'https://blog.ralf-peter-kleinert.de';
  NewsletterUrl = 'https://dashboard.mailerlite.com/forms/1051644/128840345310988026/share';
  ProgramDownloadUrl = 'https://downloads.ralf-peter-kleinert.de/software/paperless-backup-programm.html';

implementation

end.
