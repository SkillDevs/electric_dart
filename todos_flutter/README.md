# todos_electrified

A new Flutter project.

## Prerequisites

* Flutter 3.16.x
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
> [!NOTE]  
> If you are running the example from a non tagged commit, it is highly recommended to change the `ELECTRIC_IMAGE` in the `.envrc` file to `electric:local-build` and run `make` on the main Electric repository (https://github.com/electric-sql/electric) at the same commit the Dart client is based on. You can find that commit in the Dart client README. This will ensure that the client matches the Electric service behavior, as the protocol can vary depending on the version.

### 2. Apply migrations in Postgres

In this demo we used [dbmate](https://github.com/amacneil/dbmate) to apply the migrations automatically into Postgres.

Before continuing, make sure to wait a few seconds before the last command to ensure that Electric is ready to handle your migrations.

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

### 4. Generate the glue code

`electricsql` for Dart uses [drift](https://pub.dev/packages/drift) to provide a type-safe interface to the local SQLite database.
The `electricsql_cli` tool can be used to automatically generate the `drift` schema based on your Postgres schema. That way you don't need to replicate the Postgres tables in `drift` table definitions in the app. The example already has this code generated, but you can call it yourself to make sure it works correctly.
Another task this generation does is to bundle the migrations of the Postgres database into the client. More information below.

```sh
# Within the Flutter app folder, where the pubspec.yaml file is located.
dart run electricsql_cli generate
```

### 5. Run the app

```sh
flutter run
```

You can run additional Flutter apps to test how they sync automatically. For example, you can run the web version and the mobile version at the same time. `flutter run -d <device_id>`

> [!NOTE]  
> If you are running the app on an emulator/usb connected device, make sure you are providing the URL parameter to the Electric config with a non localhost IP. It should be the IP of your machine in your local network when hosting it yourself. For instance: `url: 'http://192.168.x.x:5133'`.

### 5. (Optional) Tweak the Electric configuration

You can optionally tweak the `electrify` function in `lib/electric.dart` to change the Electric configuration, such as changing the Electric service URL or disable the logs.

## Extra information about the migrations

To create a new migration with dbmate:
```sh
dbmate -d migrations new <migration_name>
```

To apply the migrations using the Postgres connection:
```sh
dbmate -d migrations -u "postgres://postgres:proxy_password@localhost:65432/todos-electrified?sslmode=disable" up
```

Every time the schema changes in Postgres, we need to update the client bundling the required migrations. You can do that following the next section, although in this example they have already been generated.

### Generating the glue code

We can automatically generate the necessary migrations and drift schema code that the client app needs by using the CLI tool.
With `electricsql_cli` as a dev dependency in your app, you can then run: 

```sh
dart run electricsql_cli generate
```

It will connect to the Electric service and generate all the necessary glue code. You can configure the service url as well as the output directory. Check out the options with `--help`.

The generated code contains the constant `kElectricMigrations` which you need to provide to the `electrify` function when initializing Electric.
