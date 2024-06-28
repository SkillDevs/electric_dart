import 'package:electricsql/drivers/drift.dart';
import 'package:electricsql/src/client/model/client.dart';
import 'package:electricsql/src/client/validation/validation.dart';
import 'package:electricsql/src/drivers/drift/drift.dart';
import 'package:electricsql/src/migrators/query_builder/query_builder.dart';
import 'package:electricsql/src/satellite/registry.dart';
import 'package:test/test.dart';

import '../../satellite/common.dart';
import '../drift/database.dart';

const PostData post1 = PostData(
  id: 1,
  title: 't1',
  contents: 'c1',
  nbr: 18,
  authorId: 1,
);

const UserData author1 = UserData(
  id: 1,
  name: 'alice',
  meta: null,
);

void main() async {
  test(
      'setReplicationTransform should validate transform does not modify outgoing FK column',
      () async {
    final db = TestsDatabase.memory();
    addTearDown(() => db.close());
    final context = await makeContext('main');
    addTearDown(() => context.cleanAndStopSatellite());

    final adapter = context.adapter;
    final notifier = context.notifier;
    final satellite = context.satellite;
    final client = context.client;

    final electric = DriftElectricClient(
      ElectricClientRawImpl.create(
        dbName: 'testDB',
        dbDescription: DBSchemaDrift(db: db, migrations: [], pgMigrations: []),
        adapter: adapter,
        notifier: notifier,
        satellite: satellite,
        registry: globalRegistry,
        dialect: Dialect.sqlite,
      ),
      db,
    );

    PostData modifyAuthorId(PostData post) {
      return post.copyWith(
        authorId: 9, // this is a FK, should not be allowed to modify it
      );
    }

    // postTable, userTable
    electric.setTableReplicationTransform(
      db.post,
      transformInbound: modifyAuthorId,
      transformOutbound: modifyAuthorId,
    );

    // Check outbound transform
    expect(
      () => client.replicationTransforms['Post']!
          .transformOutbound(driftInsertableToValues(post1)),
      throwsA(
        isA<InvalidRecordTransformationError>().having(
          (e) => e.toString(),
          'message',
          contains('Record transformation modified immutable fields: authorId'),
        ),
      ),
    );

    // Also check inbound transform
    expect(
      () => client.replicationTransforms['Post']!
          .transformInbound(driftInsertableToValues(post1)),
      throwsA(
        isA<InvalidRecordTransformationError>().having(
          (e) => e.toString(),
          'message',
          contains('Record transformation modified immutable fields: authorId'),
        ),
      ),
    );
  });

  test(
      'setReplicationTransform should validate transform does not modify incoming FK column',
      () async {
    final db = TestsDatabase.memory();
    addTearDown(() => db.close());
    final context = await makeContext('main');
    addTearDown(() => context.cleanAndStopSatellite());

    final adapter = context.adapter;
    final notifier = context.notifier;
    final satellite = context.satellite;
    final client = context.client;

    final electric = DriftElectricClient(
      ElectricClientRawImpl.create(
        dbName: 'testDB',
        dbDescription: DBSchemaDrift(db: db, migrations: [], pgMigrations: []),
        adapter: adapter,
        notifier: notifier,
        satellite: satellite,
        registry: globalRegistry,
        dialect: Dialect.sqlite,
      ),
      db,
    );

    UserData modifyUserId(UserData user) {
      return user.copyWith(
        id: 9, // this is the column pointed at by the FK, should not be allowed to modify it
      );
    }

    // postTable, userTable
    electric.setTableReplicationTransform(
      db.user,
      transformInbound: modifyUserId,
      transformOutbound: modifyUserId,
    );

    // Check outbound transform
    expect(
      () => client.replicationTransforms['User']!
          .transformOutbound(driftInsertableToValues(author1)),
      throwsA(
        isA<InvalidRecordTransformationError>().having(
          (e) => e.toString(),
          'message',
          contains('Record transformation modified immutable fields: id'),
        ),
      ),
    );

    // Also check inbound transform
    expect(
      () => client.replicationTransforms['User']!
          .transformInbound(driftInsertableToValues(author1)),
      throwsA(
        isA<InvalidRecordTransformationError>().having(
          (e) => e.toString(),
          'message',
          contains('Record transformation modified immutable fields: id'),
        ),
      ),
    );
  });
}
