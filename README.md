![Tests](https://github.com/SkillDevs/electric_dart/actions/workflows/tests.yml/badge.svg)

# Electric Dart ⚡🎯

Dart client implementation for [Electric](https://electric-sql.com/) based on commit `cd77e4a67f5367e1376cab752bd16177801d20b5` of the [electric git repository](https://github.com/electric-sql/electric)

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

![Electric Flutter](https://github.com/SkillDevs/electric_dart/assets/22084723/bcff59b3-747f-4e88-bb5c-79bb4c21bf2f)


## Development

Dart 3.x and Melos required

`dart pub global activate melos`


### Bootstrap the workspace

`melos bs`


### Generate the Protobuf code

Install the `protoc_plugin` Dart package. Version used: `^20.0.1`

`dart pub global activate protoc_plugin 20.0.1`

To generate the code

`melos generate_proto`


### Run the tests

`melos test:all`
