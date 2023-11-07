import 'dart:io';

import 'package:electricsql_cli/src/commands/generate_migrations/builder.dart';
import 'package:electricsql_cli/src/commands/generate_migrations/prisma.dart';
import 'package:test/test.dart';

void main() {
  test('test name', () async {
    final schemaInfo = extractInfoFromPrismaSchema(schema);

    final driftOutFile = File('test.dart');
    await buildDriftSchemaDartFile(schemaInfo, driftOutFile);
  });
}

const schema = '''
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model project {
  @@map("projects")

  id String @id @default(uuid())
  name String?

  owner_id String

  memberships membership[]
}

model membership {
  @@map("memberships")

  project project @relation(fields: [project_id], references: [id], onDelete: Cascade)
  project_id String

  user_id String

  inserted_at DateTime @default(now()) @db.Date

  @@id([project_id, user_id])
}

model datatypes {
  c_uuid        String   @id @db.Uuid
  c_text        String
  c_int         Int
  c_int2        Int      @db.SmallInt
  c_int4        Int
  c_float8      Float
  c_bool        Boolean
  c_date        DateTime @db.Date
  c_time        DateTime @db.Time
  c_timestamp   DateTime @db.Timestamp(6)
  c_timestamptz DateTime @db.Timestamptz(6)
}

''';

// const schema = '''
// model weirdnames {
//   c_uuid String @id @db.Uuid
//   val    String @map("1val")
// }
// ''';
