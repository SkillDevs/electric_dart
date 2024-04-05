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
dart run electricsql_cli start --with-postgres
```
> [!NOTE]  
> If you are running the example from a non tagged commit, it is highly recommended to run the Electric service with the `canary` Docker image. Check out the `.env` file to see instructions on how to do it. This will ensure that the client matches the Electric service behavior, as the protocol can vary depending on the version and the example app might be using non released features.

### 2. Apply migrations in Postgres

In this demo we used [dbmate](https://github.com/amacneil/dbmate) to apply the migrations automatically into Postgres.

Before continuing, make sure to wait a few seconds after the `start` command is run to ensure that Electric is ready to handle your migrations.

```sh
./tool/apply-migrations.sh 
# Under the hood this runs `dbmate` as follows, but the environment variables are automatically configured by the CLI

# > POSTGRES_URL="postgresql://postgres:proxy_password@localhost:65432/{dbname}?sslmode=disable"
# > dbmate -d db/migrations -u "$POSTGRES_URL" up
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
dart run electricsql_cli generate
```

### 5. Run the app

```sh
flutter run
```

You can run additional Flutter apps to test how they sync automatically. For example, you can run the web version and the mobile version at the same time. `flutter run -d <device_id>`

> [!NOTE]  
> EMULATORS AND MOBILE DEVICES: If you are running the app on an emulator/usb connected device, make sure you are providing the URL parameter to the Electric config with a non localhost IP. It should be the IP of your machine in your local network when hosting it yourself. For instance: `url: 'http://192.168.x.x:5133'`.


> [!NOTE]  
> WEB APPS: If you are running the app on web, in order for the browser to store the local database for your app make sure you are running the app in a non Guest/Incognito window and that you are using always the same port. You can do that with: `flutter run -d web-server --web-port=8081`

### 5. (Optional) Tweak the Electric configuration

You can optionally tweak the `electrify` function in `lib/electric.dart` to change the Electric configuration, such as changing the Electric service URL or disable the logs.

## Extra information about the migrations

To create a new migration with dbmate:
```sh
dbmate -d migrations new <migration_name>
```

Every time the schema changes in Postgres, we need to update the client bundling the required migrations. You can do that with the `generate` command as shown before.

### 6. Run a backend

To demonstrate how a full-stack Dart setup could look like with ElectricSQL,
this example includes a simple backend using `shelf` and `drift_postgres`.
Once postgres is running, you can start the backend with

```sh
dart run bin/backend.dart
```

With the backend running, you can fetch all todo items added to the database:

```sh
curl http://localhost:8080/

```

You can also post new todo entries with the backend, which show up in the app
right away thanks to Electric:

```sh
curl -X POST --data 'My todo entry' http://localhost:8080
```
