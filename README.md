![Tests](https://github.com/SkillDevs/electric_dart/actions/workflows/tests.yml/badge.svg)

# Electric Dart ⚡🎯

Dart client implementation for [Electric](https://electric-sql.com/) based on commit `318f5ac0d201b79254bf41fdd0f20a9d70316747` of the [electric git repository](https://github.com/electric-sql/electric)

- Client based on the typescript client from the `clients/typescript` subfolder.

- Electric backend running with the `local-stack` Docker Compose using the `electric` Docker image built in that specific commit.

### Run the Todos example

Flutter version used: 3.10.x

This demo is compatible with the `todoMVC` official example [Link](https://github.com/electric-sql/examples).

1. Run the Electric backend ([Instructions](https://electric-sql.com/docs/overview/examples))

2. Apply the migrations in Postgres following the Migrations section [here](./todos_flutter/README.md)

3. From inside the todos_flutter directory: `flutter run` with the platform of your choice.

Note:

> Right now the `todoMVC` web examples are running against Electric client version 0.4.3. Which is incompatible with the server in the commit this is based on. You'll need to compile the typescript client and use that build in the web examples.

https://user-images.githubusercontent.com/22084723/253615129-0c0478ca-c329-43f7-a4b8-b3f46f5ddd43.mp4

## Development

Dart 3.x required

### Fetch the dependencies

`dart pub get`

### Generate the Protobuf code

Install the `protoc_plugin` Dart package. Version used: `^20.0.1`

`dart pub global activate protoc_plugin 20.0.1`

To generate the code

`protoc --dart_out=lib/src proto/satellite.proto && dart format lib/src/proto`

### Run the tests

`dart test`
