# todos_electrified

A new Flutter project.

## Prerequisites

* Flutter 3.13.x
* Postgres migrations tool - [dbmate](https://github.com/amacneil/dbmate/releases)
* Docker Compose - In order to run Electric locally


## Setup

### 0. Prepare the project in the electric_dart monorepo.

Because the example is running against local dependencies in the monorepo Melos is required to bootstrap the project correctly.

```sh
# Install melos
dart pub global activate melos

# Bootstrap the project
melos bs
```

### 1. Start backend

Before starting the app, we need to start the Electric service and a Postgres database.


```sh
cd backend
./start.sh # This sets environment variables from .envrc and starts the docker-compose
```

> **NOTE**: If you are running the example from a non tagged commit, it is highly recommended to change the `ELECTRIC_IMAGE` in the `.envrc` file to `electric:local-build` and run `make` on the main Electric repository (https://github.com/electric-sql/electric) at the same commit the Dart client is based on. You can find that commit in the Dart client README. This will ensure that the client matches the Electric service behavior, as the protocol can vary depending on the version.

### 2. Apply migrations in Postgres

In this demo we used [dbmate](https://github.com/amacneil/dbmate) to apply the migrations automatically into Postgres.

```sh
cd backend
./apply-migrations.sh # Under the hood this runs `dbmate` as follows:

# > POSTGRES_URL="postgres://postgres:password@localhost:5432/{dbname}?sslmode=disable"
# > dbmate -d migrations -u "$POSTGRES_URL" up
# Applying: 20230924100310_create_todo_list.sql
# Applying: 20230924100404_create_todo.sql
```

### 3. Get Flutter packages
    
```sh
flutter pub get
```

### 4. Generate the client migrations file

This generates the migrations Dart code needed by the Electric client to bundle the migrations. There is more information about this below.

```sh
# Within the Flutter app folder, where the pubspec.yaml file is located.
dart run electricsql_cli generate_migrations
```

### 5. Run the app

```sh
flutter run
```

You can run additional Flutter apps to test how they sync automatically. For example, you can run the web version and the mobile version at the same time. `flutter run -d <device_id>`

### 5. (Optional) Tweak the Electric configuration

You can optionally tweak the `electrify` function in `lib/electric.dart` to change the Electric configuration, such as changing the Electric service URL or disable the logs.

## Extra information about the migrations

To create a new migration with dbmate:
```sh
dbmate -d migrations new <migration_name>
```

To apply the migrations using the Postgres connection:
```sh
dbmate -d migrations -u "postgres://postgres:password@localhost:5434/todos-electrified?sslmode=disable" up
```

Every time the schema changes in Postgres, we need to update the client bundling the required migrations. You can do that following the next section, although in this example they have already been generated.

### Generate the client migrations file

We can automatically generate the necessary migrations that the client app needs to bundle using the CLI tool.
With `electricsql_cli` as a dev dependency in your app, you can then run: 

```sh
dart run electricsql_cli generate_migrations
```

It will connect to the Electric service and generate the migrations file automatically. You can configure the service url
as well as the output file. Check out the options with `--help`.

The generated file contains the constant `kElectricMigrations` which you need to provide to the `electrify` function when initializing Electric.
