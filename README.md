![Tests](https://github.com/SkillDevs/electric_dart/actions/workflows/tests.yml/badge.svg)

[![pub package](https://img.shields.io/pub/v/electricsql.svg?label=electricsql&color=blue)](https://pub.dartlang.org/packages/electricsql)
[![pub package](https://img.shields.io/pub/v/electricsql_flutter.svg?label=electricsql_flutter&color=blue)](https://pub.dartlang.org/packages/electricsql_flutter)
[![pub package](https://img.shields.io/pub/v/electricsql_cli.svg?label=electricsql_cli&color=blue)](https://pub.dartlang.org/packages/electricsql_cli)

# Electric Dart ⚡🎯

#### 🛠️ WORK IN PROGRESS 🛠️

For development updates make sure to check out the official [ElectricSQL Discord](https://discord.gg/B7kHGwDcbj) server, as well as the official [Javascript client](https://www.npmjs.com/package/electric-sql)  

---

Unofficial Dart client implementation for [Electric](https://electric-sql.com/).

Client based on the typescript client from the `clients/typescript` subfolder from [electric git repository](https://github.com/electric-sql/electric) 

### Reference implementation: 

* [NPM package](https://www.npmjs.com/package/electric-sql). 
* Version `v0.5.1-dev`
* Commit: `7f3d6916a0889a79dea9c4965af81c87a140057b` 


### Run the Todos example

Flutter version used: 3.13.x

This demo is compatible with the `todoMVC` official example [Link](https://github.com/electric-sql/examples).

1. Run the Electric backend ([Instructions](https://electric-sql.com/docs/overview/examples))

    * Locally, the `local-stack` Docker Compose can be used [Link](https://github.com/electric-sql/electric/tree/main/local-stack)

2. Apply the migrations in Postgres following the Migrations section [here](https://github.com/SkillDevs/electric_dart/blob/master/todos_flutter/README.md)

3. From inside the todos_flutter directory: `flutter run` with the platform of your choice.

4. You can optionally tweak the `electrify` function in `lib/electric.dart` to change the Electric configuration, such as changing the URL or disable logs.

Note:

> Right now the `todoMVC` web examples are running against Electric client version 0.4.3. Which is incompatible with the server in the commit this is based on. For now, if you want to test multiple clients simultaneously, you can run the Flutter app on multiple platforms or on web and test it with different browsers.

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
