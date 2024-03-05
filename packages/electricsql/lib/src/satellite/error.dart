import 'package:electricsql/src/util/debug/debug.dart';
import 'package:electricsql/src/util/types.dart';

const _kFatalErrorDescription =
    "Client can't connect with the server after a fatal error. This can happen due to divergence between local client and server. Use developer tools to clear the local database, or delete the database file. We're working on tools to allow recovering the state of the local database.";

const _throwErrors = {
  SatelliteErrorCode.internal,
  SatelliteErrorCode.fatalError,
  SatelliteErrorCode.connectionCancelledByDisconnect,
};

const _fatalErrors = {
  SatelliteErrorCode.invalidRequest,
  SatelliteErrorCode.unknownSchemaVersion,
  SatelliteErrorCode.authRequired,
  SatelliteErrorCode.authExpired,
};

const _outOfSyncErrors = [
  SatelliteErrorCode.invalidPosition,
  SatelliteErrorCode.behindWindow,
  SatelliteErrorCode.subscriptionNotFound,
];

bool isThrowable(SatelliteException error) {
  return _throwErrors.contains(error.code);
}

bool isFatal(SatelliteException error) {
  return _fatalErrors.contains(error.code);
}

bool isOutOfSyncError(SatelliteException error) {
  return _outOfSyncErrors.contains(error.code);
}

void _logFatalErrorDescription() {
  logger.error(_kFatalErrorDescription);
}

SatelliteException wrapFatalError(SatelliteException error) {
  _logFatalErrorDescription();
  return SatelliteException(
    SatelliteErrorCode.fatalError,
    'Fatal error: ${error.message}. Check log for more information',
  );
}
