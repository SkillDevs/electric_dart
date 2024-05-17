import 'package:electricsql/satellite.dart';
import 'package:electricsql/src/satellite/shapes/shape_manager.dart';
import 'package:test/test.dart';

void main() {
  test('Shape manager stores the subscription and returns a promise', () {
    // Setup
    final mng = ShapeManager();

    // Assertions
    final result = mng.syncRequested([Shape(tablename: 't1')]);
    expect(result, isA<NewSyncRequest>());
  });

  test('Shape manager returns an existing promise for already-requested shape',
      () {
    // Setup
    final mng = ShapeManager();
    final firstResult = mng.syncRequested([Shape(tablename: 't1')]);

    // Assertions
    final result =
        mng.syncRequested([Shape(tablename: 't1')]) as ExistingSyncRequest;

    expect(result.existing, (firstResult as NewSyncRequest).promise);
    expect(result.key, firstResult.key);
  });

  test('Shape manager returns a new promise for a shape with a key', () {
    // Setup
    final mng = ShapeManager();
    final firstResult =
        mng.syncRequested([Shape(tablename: 't1')]) as NewSyncRequest;

    // Assertions
    final result =
        mng.syncRequested([Shape(tablename: 't1')], 'k1') as NewSyncRequest;

    expect(result.promise, isNot(firstResult.promise));
    expect(result.key, isNot(firstResult.key));
  });

  test('Shape manager returns the same promise for the same shape and key', () {
    // Setup
    final mng = ShapeManager();
    final firstResult =
        mng.syncRequested([Shape(tablename: 't1')], 'k1') as NewSyncRequest;

    // Assertions
    final result = mng.syncRequested([Shape(tablename: 't1')], 'k1')
        as ExistingSyncRequest;

    expect(result.existing, firstResult.promise);
    expect(result.key, firstResult.key);
  });

  test('Shape manager returns new promise for the same key', () {
    // Setup
    final mng = ShapeManager();
    final firstResult =
        mng.syncRequested([Shape(tablename: 't1')], 'k1') as NewSyncRequest;

    // Assertions
    final result =
        mng.syncRequested([Shape(tablename: 't2')], 'k1') as NewSyncRequest;

    expect(result.promise, isNot(firstResult.promise));
    expect(result.key, firstResult.key);
  });

  test('Shape manager promise gets resolved when data arrives', () async {
    // Setup
    final mng = ShapeManager();
    final firstResult =
        mng.syncRequested([Shape(tablename: 't1')]) as NewSyncRequest;
    firstResult.setServerId('testID');

    // Assertions
    final cb = mng.dataDelivered('testID');
    expect(cb(), <dynamic>[]);

    await promiseResolved(firstResult.promise);
  });

  test(
      'Shape manager promise does not get resolved when data arrives if there are unsubscriptions',
      () async {
    // Setup
    final mng = ShapeManager();
    final firstResult =
        mng.syncRequested([Shape(tablename: 't1')], 'k1') as NewSyncRequest;
    firstResult.setServerId('testID');
    mng.dataDelivered('testID')();

    final secondResult =
        mng.syncRequested([Shape(tablename: 't2')], 'k1') as NewSyncRequest;
    secondResult.setServerId('otherID');

    final cb = mng.dataDelivered('otherID');
    expect(cb(), ['testID']);

    await promiseNotResovled(secondResult.promise, 10);

    // Making the unsubscribe is not enough
    mng.unsubscribeMade(['testID']);
    await promiseNotResovled(secondResult.promise, 10);

    // But receiving the unsub data is
    mng.goneBatchDelivered(['testID']);
    await promiseResolved(secondResult.promise);
  });

  test('Shape manager correctly rehydrates the state', () async {
    // Setup
    final mng = ShapeManager();
    final firstResult =
        mng.syncRequested([Shape(tablename: 't1')], 'k1') as NewSyncRequest;
    firstResult.setServerId('testID');
    mng.dataDelivered('testID')();

    final secondResult =
        mng.syncRequested([Shape(tablename: 't2')], 'k2') as NewSyncRequest;
    secondResult.setServerId('id2');
    mng.dataDelivered('id2')();

    mng.unsubscribeMade(['testID']);
    mng.goneBatchDelivered(['testID']);

    // Simulate reconnect
    mng.initialize(mng.serialize());
    expect(mng.listContinuedSubscriptions(), ['id2']);
  });
}

Future<void> promiseResolved(Future<dynamic> promise, [int ms = 10]) async {
  await promise.timeout(Duration(milliseconds: ms));
}

Future<void> promiseNotResovled(Future<dynamic> promise, [int ms = 10]) async {
  await expectLater(
    Future.any([
      Future.delayed(Duration(milliseconds: ms), () {
        throw 'Timeout reached';
      }),
      promise,
    ]),
    throwsA('Timeout reached'),
  );
}
