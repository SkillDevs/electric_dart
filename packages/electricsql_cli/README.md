## electricsql_cli

CLI to communicate with the Electric service and/or run the Electric & Postgres services locally. 

Mimics the behavior from the `electric-sql` CLI NPM package. https://www.npmjs.com/package/electric-sql

---

## Getting Started 🚀

Add `electricsql_cli` as a dev dependency in your `pubspec.yaml` file.

## Commands

```sh
# How to run
$ dart run electricsql_cli <command> [arguments]

# Description of the available commands
$ dart run electricsql_cli --help
$ dart run electricsql_cli <command> --help
```

## Documentation

All the available commands are documented here: [CLI commands](https://electric-sql.com/docs/api/cli)
The documentation is for the official CLI in Node, but functionality in Dart is equivalent, you can simply replace the `npx electric-sql` part with `dart run electricsql_cli`.