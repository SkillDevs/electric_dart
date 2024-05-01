import '../util/pg_docker.dart';

Future<EmbeddedPostgres> makePgDatabase(String name, int port) async {
  final pgEmbedded = EmbeddedPostgres(
    persistent: false,
    port: port,
    name: name,
  );
  await pgEmbedded.start();

  return pgEmbedded;
}
