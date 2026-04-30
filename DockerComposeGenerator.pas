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
  System.Classes, System.SysUtils, System.IOUtils;

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
    'name: paperless-ngx' + sLineBreak + sLineBreak +
    'services:' + sLineBreak +
    '  broker:' + sLineBreak +
    '    image: docker.io/library/redis:'+ Versions.Redis + sLineBreak +
    '    restart: always' + sLineBreak + sLineBreak +
    '  db:' + sLineBreak +
    '    image: docker.io/library/postgres:' + Versions.Postgres + sLineBreak +
    '    restart: always' + sLineBreak +
    '    volumes:' + sLineBreak +
    '      - db_data:/var/lib/postgresql/data' + sLineBreak +
    '    environment:' + sLineBreak +
    '      POSTGRES_DB: paperless' + sLineBreak +
    '      POSTGRES_USER: paperless' + sLineBreak +
    '      POSTGRES_PASSWORD: paperless' + sLineBreak + sLineBreak +
    '  gotenberg:' + sLineBreak +
    '    image: gotenberg/gotenberg:' + Versions.Gotenberg + sLineBreak +
    '    restart: always' + sLineBreak +
    '    environment:' + sLineBreak +
    '      DISABLE_GOOGLE_CHROME: "1"' + sLineBreak + sLineBreak +
    '  tika:' + sLineBreak +
    '    image: docker.io/apache/tika:' + Versions.Tika + sLineBreak +
    '    restart: always' + sLineBreak + sLineBreak +
    '# Alpine is used by the backup program for volume archives' + sLineBreak +
    '  alpine:' + sLineBreak +
    '    image: alpine:' + Versions.Alpine + sLineBreak +
    '    container_name: alpine_helper' + sLineBreak +
    '    entrypoint: sh' + sLineBreak +
    '    stdin_open: true' + sLineBreak +
    '    tty: true' + sLineBreak + sLineBreak +
    '# BusyBox is available as an additional helper environment' + sLineBreak +
    '  busybox:'   + sLineBreak +
    '    image: busybox:' + Versions.Busybox + sLineBreak +
    '    container_name: busybox_helper' + sLineBreak +
    '    entrypoint: sh' + sLineBreak +
    '    stdin_open: true' + sLineBreak +
    '    tty: true' + sLineBreak + sLineBreak +
    '  paperless:' + sLineBreak +
    '    image: ghcr.io/paperless-ngx/paperless-ngx:' + Versions.Paperless + sLineBreak +
    '    depends_on:' + sLineBreak +
    '      - db' + sLineBreak +
    '      - broker' + sLineBreak +
    '      - gotenberg' + sLineBreak +
    '      - tika' + sLineBreak +
    '    ports:' + sLineBreak +
    '      - "8000:8000"' + sLineBreak +
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
    '  db_data:';
end;

procedure SaveDockerComposeFile(const TargetPath, Content: string);
begin
  TFile.WriteAllText(TargetPath, Content, TEncoding.UTF8);
end;

end.
