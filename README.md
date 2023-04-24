# Electric Dart

Dart client implementation for Electric [Electric](https://electric-sql.com/) based on:

- `typescript-client` (monorepo) (hash `29142a12f14f5db79239757a56726d79cbc53473`)

- Electric backend (hash `29142a12f14f5db79239757a56726d79cbc53473`) running with the `local-stack`

### Run the Todos example

Flutter version used: 3.7.X

This demo is compatible with the `todoMVC` official example [Link](https://github.com/electric-sql/examples).

1. Run the Electric backend ([Instructions](https://electric-sql.com/docs/overview/examples))

2. From inside the todos_flutter directory: `flutter run`

Note:

> Right now the `todoMVC` web examples are running against Electric client version 0.4.3. Which is incompatible with the server in the commit this is based on. You'll need to compile the typescript client and use that build in the web examples.


https://user-images.githubusercontent.com/22084723/233607256-2a36c911-152b-483b-9adf-81b4e5ff051d.mp4

## Development

### Fetch the dependencies

`dart pub get`

### Generate the Protobuf code

Install the `protoc_plugin` Dart package. Version used: `^20.0.1`

`dart pub global activate protoc_plugin`

To generate the code

`protoc --dart_out=lib proto/satellite.proto && dart format lib/proto`

### Run the tests

`dart test`
