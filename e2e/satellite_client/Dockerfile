FROM homebrew/brew:latest AS brew
RUN brew update
RUN brew install sqlite

FROM ubuntu:22.04 as base

# Node is necessary because the client can interpret JS objects as arguments in the CLI
RUN apt-get update && apt install sqlite3 wget nodejs -y

#############################################

# Specify the Dart SDK base image version using dart:<version> (ex: dart:2.12)
FROM dart:stable AS build

WORKDIR /repo/packages/electricsql
COPY packages/electricsql/pubspec.* ./
RUN dart pub get

WORKDIR /repo/e2e/satellite_client
COPY e2e/satellite_client/pubspec.* ./
RUN dart pub get

WORKDIR /repo

COPY . .

WORKDIR /repo/e2e/satellite_client

RUN dart pub get --offline

RUN dart compile exe bin/satellite_dart_client.dart -o bin/satellite_dart_client

#############################################

FROM base
COPY --from=build /repo/e2e/satellite_client/bin/satellite_dart_client /app/bin/

# Homebrew files
COPY --from=brew /home/linuxbrew/.linuxbrew/lib/libsqlite3.so /usr/local/lib


CMD ["/app/bin/satellite_dart_client"]
