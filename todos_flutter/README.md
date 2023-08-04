# todos_electrified

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Migrations

In this demo we used [go-migrate](https://github.com/golang-migrate/migrate) to apply the migrations automatically into Postgres.

To create a new migration:
`migrate create -ext sql -dir migrations -seq <migration_name>`

To apply the migrations using the Postgres connection the Electric local-stack has:
`migrate -path migrations -database "postgres://postgres:password@localhost:5432/electric?sslmode=disable" up`

Every time the schema changes in Postgres, we need to update the client bundling the required migrations. You can do that following the next section, although in this example they have already been generated.

### Generate the client migrations file

We can automatically generate the necessary migrations that the client app needs to bundle using the CLI tool.
With `electricsql_cli` as a dev dependency in your app, you can then run: 

`dart run electricsql_cli generate_migrations`

It will connect to the Electric service and generate the migrations file automatically. You can configure the service url
as well as the output file. Check out the options with `--help`.

The generated file contains the constant `kElectricMigrations` which you need to provide to the `electrify` function when initializing Electric.
