import 'package:electricsql/src/notifiers/event.dart';
import 'package:electricsql/src/notifiers/notifiers.dart';
import 'package:electricsql/src/util/tablename.dart';
import 'package:electricsql/src/util/types.dart' hide Change;
import 'package:test/test.dart';

void main() {
  test('subscribe to potential data changes', () {
    final source = EventNotifier(dbName: 'test.db');
    final target = EventNotifier(dbName: 'test.db');

    final notifications = <PotentialChangeNotification>[];

    target.subscribeToPotentialDataChanges((x) => notifications.add(x));

    source.potentiallyChanged();

    expect(notifications.length, 1);
  });

  test('potential data change subscriptions are scoped by dbName(s)', () {
    final source = EventNotifier(dbName: 'foo.db');
    final t1 = EventNotifier(dbName: 'foo.db');
    final t2 = EventNotifier(dbName: 'bar.db');

    final notifications = <Notification>[];

    t1.subscribeToPotentialDataChanges((x) => notifications.add(x));
    t2.subscribeToPotentialDataChanges((x) => notifications.add(x));

    source.potentiallyChanged();

    expect(notifications.length, 1);

    source.attach('bar.db', 'bar.db');
    source.potentiallyChanged();

    expect(notifications.length, 3);
  });

  test('subscribe to actual data changes', () {
    final source = EventNotifier(dbName: 'test.db');
    final target = EventNotifier(dbName: 'test.db');

    final notifications = <Notification>[];

    target.subscribeToDataChanges((x) => notifications.add(x));

    const qualifiedTablename = QualifiedTablename('main', 'Items');

    source.actuallyChanged(
      'test.db',
      [Change(qualifiedTablename: qualifiedTablename, rowids: null)],
      ChangeOrigin.local,
    );

    expect(notifications.length, 1);
  });

  test('actual data change subscriptions are scoped by dbName', () {
    final source = EventNotifier(dbName: 'foo.db');
    final t1 = EventNotifier(dbName: 'foo.db');
    final t2 = EventNotifier(dbName: 'bar.db');

    final notifications = <Notification>[];

    t1.subscribeToDataChanges((x) => notifications.add(x));
    t2.subscribeToDataChanges((x) => notifications.add(x));

    const qualifiedTablename = QualifiedTablename('main', 'Items');
    final changes = [Change(qualifiedTablename: qualifiedTablename)];

    source.actuallyChanged('foo.db', changes, ChangeOrigin.local);
    expect(notifications.length, 1);

    source.actuallyChanged('lala.db', changes, ChangeOrigin.local);
    expect(notifications.length, 1);

    source.actuallyChanged('bar.db', changes, ChangeOrigin.local);
    expect(notifications.length, 1);

    source.attach('bar.db', 'bar.db');
    source.actuallyChanged('bar.db', changes, ChangeOrigin.local);
    expect(notifications.length, 2);

    t2.attach('foo.db', 'foo.db');
    source.actuallyChanged('foo.db', changes, ChangeOrigin.local);
    expect(notifications.length, 4);
  });

  test('subscribe to connectivity change events is scoped by dbName', () {
    final source = EventNotifier(dbName: 'test.db');
    final target = EventNotifier(dbName: 'test.db');

    final notifications = <ConnectivityStateChangeNotification>[];

    target.subscribeToConnectivityStateChanges((x) => notifications.add(x));

    source.connectivityStateChanged(
      'test.db',
      const ConnectivityState(status: ConnectivityStatus.connected),
    );

    expect(notifications.length, 1);

    source.connectivityStateChanged(
      'non-existing-db',
      const ConnectivityState(status: ConnectivityStatus.connected),
    );

    expect(notifications.length, 1);
  });

  test('no more connectivity events after unsubscribe', () {
    final source = EventNotifier(dbName: 'test.db');
    final target = EventNotifier(dbName: 'test.db');

    final List<ConnectivityStateChangeNotification> notifications = [];

    final unsubscribe = target.subscribeToConnectivityStateChanges((x) {
      notifications.add(x);
    });

    source.connectivityStateChanged(
      'test.db',
      const ConnectivityState(status: ConnectivityStatus.connected),
    );

    unsubscribe();

    source.connectivityStateChanged(
      'test.db',
      const ConnectivityState(status: ConnectivityStatus.connected),
    );

    expect(notifications.length, 1);
  });
}
