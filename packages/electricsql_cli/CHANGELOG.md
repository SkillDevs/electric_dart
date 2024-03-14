## 0.5.4

* Code based on official Typescript client [v0.9.5](https://github.com/electric-sql/electric/releases/tag/electric-sql%400.9.5) and [v0.9.6](https://github.com/electric-sql/electric/releases/tag/electric-sql%400.9.6).
* Check that at least Docker v23 is installed before running the CLI commands.


## 0.5.3

* Code based on official Typescript client [v0.9.3](https://github.com/electric-sql/electric/releases/tag/electric-sql%400.9.3) and [v0.9.4](https://github.com/electric-sql/electric/releases/tag/electric-sql%400.9.4)


## 0.5.2

* Code based on official Typescript client [v0.9.2](https://github.com/electric-sql/electric/releases/tag/electric-sql%400.9.2)


## 0.5.1

* Code based on official Typescript client [v0.9.1](https://github.com/electric-sql/electric/releases/tag/electric-sql%400.9.1)


## 0.5.0

* Code based on official Typescript client [v0.9.0](https://github.com/electric-sql/electric/releases/tag/electric-sql%400.9.0)
* The CLI has been greatly improved, now supporting running the Electric and Postgres services locally behind the scenes, simplifying the structure of the project. Checkout the Quickstart section in the README for more details.


## 0.4.1

* Code based on official Typescript client [v0.8.2](https://github.com/electric-sql/electric/releases/tag/electric-sql%400.8.2)
* New "proxy-tunnel" command that tunnels a Postgres TCP connection over a websocket for the Postgres Proxy.


## 0.4.0

* Code based on official Typescript client [v0.8.0](https://github.com/electric-sql/electric/releases/tag/electric-sql%400.8.0) and [v0.8.1](https://github.com/electric-sql/electric/releases/tag/electric-sql%400.8.1)
* Added additional CLI parameter, `int8AsBigInt` to configure how to treat the INT8 type in Dart code, either as a `BigInt` or as `int`. `BigInt` can be useful if you need the full INT8 range in Flutter Web. Otherwise, Dart `int` is capable of storing the full INT8 range for all other platforms.


## 0.3.1

* Code based on official Typescript client [v0.7.1](https://github.com/electric-sql/electric/releases/tag/electric-sql%400.7.1)


## 0.3.0

* [BREAKING CHANGE]: The `generate_migrations` command is now called `generate` and it will also generate the drift schema code automatically based on the Postgres schema.
This means that is no longer required to replicate the schema in drift manually with the same table and column names as the Postgres schema, making the process much simpler.


## 0.2.0

* Support electricsql Dart v0.2.0


## 0.1.3

* Update default Electric service port
* Better error handling


## 0.1.2

* Update generation style


## 0.1.1

* Update electricsql minimum version


## 0.1.0

- Initial version.
