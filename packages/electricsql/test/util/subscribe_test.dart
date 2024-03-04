import 'package:electricsql/notifiers.dart';
import 'package:electricsql/src/notifiers/mock.dart';
import 'package:electricsql/util.dart';
import 'package:test/test.dart';

late Notifier notifier;
const mockDbName = 'test.db';

void main() {
  setUp(() {
    notifier = MockNotifier(mockDbName, eventEmitter: EventEmitter());
  });

  test('should yield connectivity state updates as notifier signals them',
      () async {
    final subscribe = createConnectivityStateSubscribeFunction(notifier);
    final states = <ConnectivityState>[];

    subscribe((s) => states.add(s));
    expect(states.length, 0);

    notifier.connectivityStateChanged(
      mockDbName,
      const ConnectivityState(
        status: ConnectivityStatus.connected,
      ),
    );
    await null;
    expect(states.length, 1);
    expect(states[0].status, ConnectivityStatus.connected);

    notifier.connectivityStateChanged(
      mockDbName,
      const ConnectivityState(
        status: ConnectivityStatus.connected,
      ),
    );
    await null;
    expect(states.length, 2);
    expect(states[1].status, ConnectivityStatus.connected);

    notifier.connectivityStateChanged(
      mockDbName,
      const ConnectivityState(
        status: ConnectivityStatus.disconnected,
      ),
    );

    await null;
    expect(states.length, 3);
    expect(states[2].status, ConnectivityStatus.disconnected);
  });

  test('should NOT yield subsequent connectivity updates after unsubscribing',
      () async {
    final subscribe = createConnectivityStateSubscribeFunction(notifier);

    final states = <ConnectivityState>[];
    final unsubscribe = subscribe((u) => states.add(u));

    expect(states.length, 0);

    // unsubscribing before change should not yield update
    unsubscribe();
    notifier.connectivityStateChanged(
      mockDbName,
      const ConnectivityState(
        status: ConnectivityStatus.connected,
      ),
    );

    await null;

    expect(states.length, 0);
  });
}
