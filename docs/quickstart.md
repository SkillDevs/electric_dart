## Integrate Electric into your Flutter app

First we'd recommend you to run the `todos_example` app in the repository.
It contains a working example of Electric in a Flutter app, with Postgres migrations and the Electric service and a Postgres database running on your local machine via Docker.

In order to integrate Electric in your app you can do the following:

### 1. Add the dependency

Add the required dependencies into your project.

```yaml
dependencies:
  electricsql: <version>
  drift: ^2.17.0 # or greater

  # Optionally include if you want to use the Flutter utilities
  electricsql_flutter: <version>

dev_dependencies:
  electricsql_cli: <version>
  drift_dev: ^2.17.0 # or greater
  build_runner: ... # to build the drift code
```

The `electricsql_cli` package is installed as a dev dependency. This tool can be used to automatically generate a [drift](https://pub.dev/packages/drift) schema based on your Postgres schema, as well as other utilities, like running the Electric service and Postgres database locally.


### 2. Configure the backend locally

The `electricsql_cli` will provide mostly all you need to run a Postgres database and the Electric service locally.

```shell
dart run electricsql_cli <command> [--help]
```

One thing you need to provide yourself are the migrations that define the schema of the Postgres database, as well as a way to apply them incrementally.
An easy to use tool to do this is [`dbmate`](https://github.com/amacneil/dbmate), but there are many others.

To get started with `dbmate` you can copy the `tool/apply-migrations.sh` script from the `todos_flutter` example in the repository.
The script will automatically apply the migrations under the folder `db/migrations` into the Postgres database using the Electric CLI which will configure all the environment variables needed.

> [!NOTE]  
> The migrations need to specify which tables in the Postgres you want to "electrify", or make accesible in the client. That is done with a special syntax Electric provides: `ALTER TABLE <my table> ENABLE ELECTRIC;`. The example app in the repo has an example of how this is used in the `db/migrations` folder.
>
> More info: https://electric-sql.com/docs/usage/data-modelling/migrations

Most important commands from `electricsql_cli` to get you started:
1. `start`: Starts the Electric service and optionally the Postgres database with the option `--with-postgres`.
2. `stop`: Stops the service. Optionally you can remove all the Electric and Postgres data, in case you want to start from scratch using the option `--remove`.
3. `generate`: Generates the `drift` schema and the Electric migrations based on the Postgres schema. More info below.

### 3. Generate the glue code

`electricsql` for Dart uses [drift](https://pub.dev/packages/drift) to provide a type-safe interface to the local SQLite database.
The `electricsql_cli` tool can be used to automatically generate the `drift` schema based on your Postgres schema. That way you don't need to replicate the Postgres tables in `drift` table definitions in the app.

You can run the tool within your Flutter app as follows:

```sh
dart run electricsql_cli generate
```

After it finishes you should have the folder `lib/generated/electric` created. Inside you will find the `drift` schema and the Electric SQL migrations.

After this point, the app should be configured like a regular app that uses `drift`, with minor adjustments.
You can refer to the official `drift` docs here https://drift.simonbinder.eu/docs/getting-started/

When defining the `drift` database class you need to provide the tables from the generated file.

After defining the database, generate the `drift` code as usual.

```sh
dart run build_runner build
```

#### Sample code:

```dart
import 'dart:io';

import 'package:drift/native.dart';

// Import the generated Drift schema, which contains your electrified tables
import 'package:myapp/generated/electric/drift_schema.dart';

// [IMPORTANT] Add this line to enable the import of electric types for Drift
// You can also import them from `electricsql_flutter`
import 'package:electricsql/drivers/drift.dart'; 

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// [IMPORTANT LINE!!!] kElectrifiedTables comes from the generated file
// The rest is regular drift code
@DriftDatabase(tables: kElectrifiedTables)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // [IMPORTANT CHANGE!!!]
  // Drift by default creates the local database tables. This is done by electric in
  // this situation, so we provide an empty onCreate callback
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
      },
    );
  }
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
```

### 4. Initialize Electric

The last step would be to `electrify` the database. This will configure the local SQLite database in order to automatically sync with the Electric service.

```dart
import 'package:electricsql/electricsql.dart';
import 'package:electricsql_flutter/drivers/drift.dart';
import 'package:myapp/generated/electric/migrations.dart';

// This would be the Drift database
AppDatabase db;

final electric = await electrify<AppDatabase>(
    dbName: '<db_name>',
    db: db,
    // Bundled migrations. This variable is autogenerated using 
    // `dart run electricsql_cli generate`
    migrations: kElectricMigrations,
    config: ElectricConfig(
        // Electric service URL
        // Make sure it's not localhost if running on an emulator/usb connected device,
        // but the IP of your machine (192.168.x.x when hosting it yourself)
        url: 'http://<ip>:5133',
        // logger: LoggerConfig(
        //     level: Level.debug, // in production you can use Logger.off
        // ),
        //
    ),
);

// https://electric-sql.com/docs/usage/auth
// You can use the functions `insecureAuthToken` or `secureAuthToken` to generate one
final String jwtAuthToken = '<your JWT>';

// Connect to the Electric service
await electric.connect(jwtAuthToken);
```

### 5. Define the Shapes to sync

Sync data into the local database. With this you can sync, tables, related tables, and even filtered tables by a WHERE expression.
You can find more information regarding Shapes in the README.md of `electric_dart`.

```dart
// This would be the Drift database
AppDatabase db;

// Resolves once the shape subscription is confirmed by the server.
final shape = await electric.syncTable(db.todos);

// Resolves once the initial data load for the shape is complete.
await shape.synced
```

More info: https://electric-sql.com/docs/usage/data-access/shapes


### 6. Use the drift database normally

Everything should be working now. You can use the `drift` database normally.
Inserting, updating or deleting via the drift APIs should automatically sync the data to the Postgres database and to other devices.

You can see some examples of writes and reads in the main [README](https://github.com/SkillDevs/electric_dart/blob/master/README.md).

> [!NOTE]  
> EMULATORS AND MOBILE DEVICES: If you are running the app on an emulator/usb connected device, make sure you are providing the URL parameter to the Electric config with a non localhost IP. It should be the IP of your machine in your local network when hosting it yourself. For instance: `url: 'http://192.168.x.x:5133'`.


> [!NOTE]  
> WEB APPS: If you are running the app on web, in order for the browser to store the local database for your app make sure you are running the app in a non Guest/Incognito window and that you are using always the same port. You can do that with: `flutter run -d web-server --web-port=8081`

### 7. (Optional) Configure how the Drift code for Electric is generated

Check out the following [instructions](https://github.com/SkillDevs/electric_dart/blob/master/docs/customize_drift_schema_generation.md)
