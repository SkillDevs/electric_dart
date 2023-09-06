# FROM node:18-alpine AS workspace

# RUN apk update && apk add git
# RUN corepack enable && corepack prepare pnpm@8.6.0 --activate

# RUN mkdir /app
# WORKDIR /app

# COPY pnpm-lock.yaml ./
# RUN pnpm fetch


# COPY pnpm-workspace.yaml ./
# COPY clients/typescript ./clients/typescript
# COPY generator ./generator
# COPY e2e/satellite_client/package.json  ./e2e/satellite_client/

# RUN pnpm install -r --filter @internal/satellite-client^...
# RUN pnpm run -r --filter @internal/satellite-client^... build
# RUN pnpm install -r --filter @internal/satellite-client
# COPY e2e/satellite_client/src  ./e2e/satellite_client/src
# COPY e2e/satellite_client/tsconfig.json  ./e2e/satellite_client
# RUN pnpm run -r --filter @internal/satellite-client build

# RUN pnpm --filter @internal/satellite-client --prod deploy output

# FROM node:18-alpine AS runner
# WORKDIR /app

# ENV NODE_ENV=production

# COPY --from=workspace /app/output .

# ENTRYPOINT ["node"]

FROM ubuntu:22.04 as base
RUN apt-get update && apt install sqlite3 wget -y

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

CMD ["/app/bin/satellite_dart_client"]
