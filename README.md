# Electric Dart

Dart client implementation for Electric [Electric](https://electric-sql.com/) based on:

- `typescript-client` `v0.5.0` (hash `314df48f7908ede4ae9fe27d376746164d8905f5`)

- Electric backend `v0.2.0` (hash `f03c4df0030c8499eb66a607325f5a4d5613dad3`) running with the `local-stack`

### Run the Todos example

This demo is compatible with the `todoMVC` official example [Link](https://github.com/electric-sql/examples)

1. Run the Electric backend ([Instructions](https://electric-sql.com/docs/overview/examples))

2. From inside the todos_flutter directory: `flutter run`

https://user-images.githubusercontent.com/22084723/233607256-2a36c911-152b-483b-9adf-81b4e5ff051d.mp4

## Development

### Fetch the dependencies

`dart pub get`

### Generate the Protobuf code

Install the `protoc_plugin` Dart package. Version used: `^20.0.1`

`dart pub global activate protoc_plugin`

To generate the code

`protoc --dart_out=lib proto/satellite.proto`

### Run the tests

`dart test`
