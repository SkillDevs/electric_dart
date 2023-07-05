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

Right now the migrations bundled in the app itself are manually created from the `migrations.js` that
`npx electric-sql generate` creates.
