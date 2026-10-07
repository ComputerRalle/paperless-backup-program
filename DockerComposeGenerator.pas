// --------------------------------------------------------------
// Paperless Backup Program / Paperless Backup Programm
//
// Copyright (C) 2025-2026 Ralf-Peter Kleinert (#ComputerRalle / DIGITAL-easy)
// Website: https://ralf-peter-kleinert.de
// Website: https://computerralle.de
// YouTube: https://www.youtube.com/@ComputerRalle
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <https://www.fsf.org/licenses/>
// or check LICENSE.txt in this repository.
// --------------------------------------------------------------

// Erzeugt ausschließlich YAML-Text und speichert ihn als UTF-8. Auswahl der Einstellungen und Start der fünf Compose-Dienste erfolgen im Setupformular.
unit DockerComposeGenerator;

interface

type
  // Docker image versions used in docker-compose.yml.
  // Docker-Image-Versionen, die in docker-compose.yml verwendet werden.
  TDockerImageVersions = record
    Paperless: string;
    Postgres: string;
    Redis: string;
    Gotenberg: string;
    Tika: string;
    Alpine: string;
    Busybox: string;
  end;

function CreateDockerComposeContent(
  const Versions: TDockerImageVersions;
  const PaperlessInput: string;
  const PaperlessSecretKey: string;
  TrashRetentionDays: Integer): string;

procedure SaveDockerComposeFile(const TargetPath, Content: string);

implementation

uses
  System.Classes, System.SysUtils, System.IOUtils, AppConfig;
// Erzeugt die fünf Dienste broker, db, gotenberg, tika und paperless für das PG18-Projekt.
// Versionsfelder liefern die ausgewählten Tags; Redis bezeichnet intern den Valkey-Broker. Alpine/Busybox sind keine Dauerdienste.
// Der Datenbankmount verwendet /var/lib/postgresql für PG18. Ein PostgreSQL-17-Datenverzeichnis darf nicht direkt übernommen werden.
function CreateDockerComposeContent(
  const Versions: TDockerImageVersions;
  const PaperlessInput: string;
  const PaperlessSecretKey: string;
  TrashRetentionDays: Integer): string;
begin
  Result :=
    '# Compose file for the Paperless Backup Program by ComputerRalle' + sLineBreak +
    '# ralf-peter-kleinert.de' + sLineBreak +
    '# The compose project name is also used as prefix for the Docker volumes' + sLineBreak +
    'name: ' + ComposeProjectName + sLineBreak + sLineBreak +
    'services:' + sLineBreak +
    '  broker:' + sLineBreak +
    '    image: valkey/valkey:'+ Versions.Redis + sLineBreak +
    '    restart: always' + sLineBreak + sLineBreak +
    '  db:' + sLineBreak +
    '    image: postgres:' + Versions.Postgres + sLineBreak +
    '    restart: always' + sLineBreak +
    '    volumes:' + sLineBreak +
    '      - db_data_18:/var/lib/postgresql' + sLineBreak +
    '    environment:' + sLineBreak +
    '      POSTGRES_DB: paperless' + sLineBreak +
    '      POSTGRES_USER: paperless' + sLineBreak +
    '      POSTGRES_PASSWORD: paperless' + sLineBreak + sLineBreak +
    // Forward selected image tags unchanged; defaults are Gotenberg 8 and Tika latest.
    // Gewählte Image-Tags unverändert übernehmen; Vorgaben sind Gotenberg 8 und Tika latest.
    '  gotenberg:' + sLineBreak +
    '    image: gotenberg/gotenberg:' + Versions.Gotenberg + sLineBreak +
    '    restart: always' + sLineBreak +
    '    command:' + sLineBreak +
    '      - "gotenberg"' + sLineBreak +
    '      - "--chromium-disable-javascript=true"' + sLineBreak +
    '      - "--chromium-allow-list=file:///tmp/.*"' + sLineBreak + sLineBreak +
    '  tika:' + sLineBreak +
    '    image: apache/tika:' + Versions.Tika + sLineBreak +
    '    restart: always' + sLineBreak + sLineBreak +
    '  paperless:' + sLineBreak +
    '    image: ghcr.io/paperless-ngx/paperless-ngx:' + Versions.Paperless + sLineBreak +
    '    depends_on:' + sLineBreak +
    '      - db' + sLineBreak +
    '      - broker' + sLineBreak +
    '      - gotenberg' + sLineBreak +
    '      - tika' + sLineBreak +
    '    ports:' + sLineBreak +
    '      - "8001:8000"' + sLineBreak +
    '    restart: always' + sLineBreak +
    '    volumes:' + sLineBreak +
    '      - data:/usr/src/paperless/data' + sLineBreak +
    '      - media:/usr/src/paperless/media' + sLineBreak +
    '      - export:/usr/src/paperless/export' + sLineBreak +
    '      - ' + PaperlessInput + ':/usr/src/paperless/consume' + sLineBreak +
    '    env_file:' + sLineBreak +
    '      - ./email-versand.env' + sLineBreak +
    '    environment:' + sLineBreak +
    '      PAPERLESS_REDIS: redis://broker:6379' + sLineBreak +
    '      PAPERLESS_DBHOST: db' + sLineBreak +
    '      PAPERLESS_DBNAME: paperless' + sLineBreak +
    '      PAPERLESS_DBUSER: paperless' + sLineBreak +
    '      PAPERLESS_DBPASS: paperless' + sLineBreak +
    '      PAPERLESS_TIME_ZONE: Europe/Berlin' + sLineBreak +
    '      PAPERLESS_SECRET_KEY: "' + PaperlessSecretKey + '"' + sLineBreak +
    '      PAPERLESS_CONSUMPTION_DIR: /usr/src/paperless/consume' + sLineBreak +
    '      PAPERLESS_MEDIA_ROOT: /usr/src/paperless/media' + sLineBreak +
    '      PAPERLESS_EXPORT_DIR: /usr/src/paperless/export' + sLineBreak +
    '      PAPERLESS_TIKA_ENABLED: "1"' + sLineBreak +
    '      PAPERLESS_TIKA_GOTENBERG_ENDPOINT: http://gotenberg:3000' + sLineBreak +
    '      PAPERLESS_TIKA_ENDPOINT: http://tika:9998' + sLineBreak +
    '      PAPERLESS_CONSUMER_POLLING: "30"' + sLineBreak +
    '      PAPERLESS_CONSUMER_POLLING_DELAY: "30"' + sLineBreak +
    '      PAPERLESS_CONSUMER_POLLING_RETRY_COUNT: "3"' + sLineBreak +
    '      PAPERLESS_CONSUMER_DELETE_DUPLICATES: "true"' + sLineBreak +
    '      PAPERLESS_CONSUMER_RECURSIVE: "true"' + sLineBreak +
    '      PAPERLESS_EMPTY_TRASH_DELAY: "' + IntToStr(TrashRetentionDays) + '"' + sLineBreak +
    '      PAPERLESS_OCR_LANGUAGE: deu+eng' + sLineBreak +
    '      # Exported documents are named by year, month, day, and title' + sLineBreak +
    '      PAPERLESS_FILENAME_FORMAT: "{{ created_year }}-{{ created_month }}-{{ created_day }}_{{ title }}"' + sLineBreak +
    'volumes:' + sLineBreak +
    '  data:' + sLineBreak +
    '  media:' + sLineBreak +
    '  export:' + sLineBreak +
    '  db_data_18:';
end;
// Speichert den fertig erzeugten Compose-Text als UTF-8; startet weder Docker noch eine Installation.
procedure SaveDockerComposeFile(const TargetPath, Content: string);
begin
  TFile.WriteAllText(TargetPath, Content, TEncoding.UTF8);
end;

end.
