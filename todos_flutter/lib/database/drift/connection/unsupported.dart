import 'package:drift/drift.dart';

Never _unsupported() {
  throw UnsupportedError(
      'No suitable database implementation was found on this platform.');
}

// Depending on the platform the app is compiled to, the following stubs will
// be replaced with the methods in native.dart or web.dart

DatabaseConnection connect(String userId) {
  _unsupported();
}

Future<void> deleteTodosDbFile(String userId) {
  _unsupported();
}
