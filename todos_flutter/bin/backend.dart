import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:todos_electrified/database/drift/database.dart';
import 'package:drift_postgres/drift_postgres.dart';
import 'package:postgres/postgres.dart';

void main() async {
  final database = AppDatabase(
    PgDatabase(
      endpoint: Endpoint(
        host: 'localhost',
        database: 'postgres',
        port: 65432,
        username: 'postgres',
        password: 'proxy_password',
      ),
      settings: const ConnectionSettings(sslMode: SslMode.disable),
      // We're using dbmate to manage migrations
      enableMigrations: false,
    ),
  );

  Future<Response> listAll(Request request) async {
    final entries = await database.todo.all().get();

    return Response.ok(
      json.encode(entries),
      headers: {'Content-Type': 'application/json'},
    );
  }

  final router = Router()..get('/', listAll);
  final handler = const Pipeline().addHandler(router.call);

  await serve(handler.call, 'localhost', 8080);
  print('Listening on http://localhost:8080/');
}
