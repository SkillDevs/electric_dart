## 0.5.1

* Code based on official Typescript client [v0.9.2](https://github.com/electric-sql/electric/releases/tag/electric-sql%400.9.2)


## 0.5.0

* Code based on official Typescript client [v0.9.0](https://github.com/electric-sql/electric/releases/tag/electric-sql%400.9.0)
* The CLI from `electricsql_cli` has been greatly improved, now supporting running the Electric and Postgres services locally behind the scenes, simplifying the structure of the project. Checkout the Quickstart section in the README for more details.


## 0.4.1

* Code based on official Typescript client [v0.8.2](https://github.com/electric-sql/electric/releases/tag/electric-sql%400.8.2)


## 0.4.0

* Code based on official Typescript client [v0.8.0](https://github.com/electric-sql/electric/releases/tag/electric-sql%400.8.0) and [v0.8.1](https://github.com/electric-sql/electric/releases/tag/electric-sql%400.8.1)
* Breaking change: Compatible with the Electric service v0.8.0+
* Added support for additional data types from Postgres, replicated in the local SQLite and mapped as Dart types in the `drift` schema:
    - `jsonb`
    - `int8`
    - `float4`


## 0.3.1

* Code based on official Typescript client [v0.7.1](https://github.com/electric-sql/electric/releases/tag/electric-sql%400.7.1)


## 0.3.0

* Code based on official Typescript client [v0.7.0](https://github.com/electric-sql/electric/releases/tag/electric-sql%400.7.0)
* Breaking change: Compatible with the Electric service v0.7.0+
* Added support for additional data types from Postgres, replicated in the local SQLite and mapped as Dart types in the `drift` schema:
    - `uuid`
    - `int2`
    - `int4`
    - `float8`
    - `date`
    - `time`
    - `timetz`
    - `timestamp`
    - `timestamptz`
* Automatic drift schema generation using the `electricsql_cli` package. No longer needed to manually replicate the Postgres schema in `drift`.

## 0.2.1

* Code based on official Typescript client [v0.6.4](https://github.com/electric-sql/electric/releases/tag/electric-sql%400.6.4)
* Fix edge case condition after initial sync


## 0.2.0

* Code based on official Typescript client [v0.6.3](https://github.com/electric-sql/electric/releases/tag/electric-sql%400.6.3)
* Previous Typescript version changelogs: [v0.6.0](https://github.com/electric-sql/electric/releases/tag/electric-sql%400.6.0) [v0.6.1](https://github.com/electric-sql/electric/releases/tag/electric-sql%400.6.1) [v0.6.2](https://github.com/electric-sql/electric/releases/tag/electric-sql%400.6.2)
* Breaking change: Compatible with Electric v0.6.0+


## 0.1.3

* Code based on official Typescript client [v0.5.3](https://github.com/electric-sql/electric/releases/tag/electric-sql%400.5.3)
* Logger configuration


## 0.1.2

* Code based on official Typescript client v0.5.2-dev [f52f25f369e016183cc5bffca2005d65bf7cca12](https://github.com/electric-sql/electric/tree/f52f25f369e016183cc5bffca2005d65bf7cca12)


## 0.1.1

* Code based on official Typescript client [v0.5.2](https://github.com/electric-sql/electric/releases/tag/electric-sql%400.5.2)
* Colored logs


## 0.1.0

* Initial version.
