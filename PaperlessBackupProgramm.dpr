// --------------------------------------------------------------
//  Project: Paperless Backup Program / Paperless Backup Programm
//  Author: Ralf-Peter Kleinert - 2025
//  Alias: ComputerRalle / DIGITAL-easy
//  Website: https://ralf-peter-kleinert.de
//  YouTube: https://www.youtube.com/@ralf-peter-kleinert
//  Copyright (c) Ralf-Peter Kleinert
//  All rights reserved.
//
// --------------------------------------------------------------
//  Beschreibung:
//  Dieses Programm wurde von Ralf-Peter Kleinert (alias ComputerRalle / DIGITAL-easy)
//  entwickelt. Es dient zur Sicherung und Wiederherstellung von Paperless-Daten,
//  inklusive Versionsverwaltung, Backup-Planung und automatisierten Prüfungen.
//
//  Hinweis:
//  Dieses Projekt befindet sich in aktiver Entwicklung. Eine finale Lizenz
//  (Open Source oder proprietär) wird erst bei der offiziellen Veröffentlichung festgelegt.
//
//  Diese Lizenz- und Copyright-Informationen werden nach der Entscheidung,
//  welches Lizenzmodell infrage kommt, entsprechend angepasst.
//
// --------------------------------------------------------------
//  Description:
//  This program was developed by Ralf-Peter Kleinert (alias ComputerRalle / DIGITAL-easy).
//  It provides backup and restore functionality for Paperless data,
//  including version tracking, scheduled backups, and automated verification.
//
//  Note:
//  This project is currently under active development. A final license
//  (open-source or proprietary) will be defined upon official release.
//
//  These license and copyright details will be updated once
//  the final licensing model has been determined.
// --------------------------------------------------------------
program PaperlessBackupProgramm;

uses
  Vcl.Forms,
  Mainform in 'Mainform.pas' {MainformFrm},
  Vcl.Themes,
  Vcl.Styles,
  HinweisForm in 'HinweisForm.pas' {HinweisFrm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Windows11 Modern Dark');
  Application.CreateForm(TMainformFrm, MainformFrm);
  Application.CreateForm(THinweisFrm, HinweisFrm);
  Application.Run;
end.
