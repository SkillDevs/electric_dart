import 'package:electricsql_cli/src/commands/generate_migrations/prisma.dart';
import 'package:test/test.dart';

void main() {
  test('prisma schema to drift info', () {
    final schemaInfo = extractInfoFromPrismaSchema(_prismaSchema);

    expect(schemaInfo.tables.length, 2);

    final projectsTable = schemaInfo.tables[0];
    expect(projectsTable.columns.length, 5);
    expect(projectsTable.tableName, 'projects');
    expect(projectsTable.dartClassName, 'Project');
    expect(
      projectsTable.columns
          .where((c) => c.isPrimaryKey)
          .map((c) => c.columnName)
          .toSet(),
      {'id'},
    );

    final membersTable = schemaInfo.tables[1];
    expect(membersTable.columns.length, 3);
    expect(membersTable.tableName, 'memberships');
    expect(membersTable.dartClassName, 'Membership');
    expect(
      membersTable.columns
          .where((c) => c.isPrimaryKey)
          .map((c) => c.columnName)
          .toSet(),
      {'project_id', 'user_id'},
    );
  });
}

const _prismaSchema = '''
model project {
  @@map("projects")

  id String @id @default(uuid())
  name String

  owner User @relation(fields: [owner_id], references: [username], onDelete: Cascade)
  owner_id String

  issues Issue[]
  memberships Membership[]

  inserted_at DateTime @default(now())
  updated_at DateTime @updatedAt
}

model membership {
  @@map("memberships")

  project Project @relation(fields: [project_id], references: [id], onDelete: Cascade)
  project_id String

  user User @relation(fields: [user_id], references: [username], onDelete: Cascade)
  user_id String

  inserted_at DateTime @default(now())

  @@id([project_id, user_id])
}
''';
