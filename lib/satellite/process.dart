import 'dart:async';
import 'dart:convert';

import 'package:electric_client/auth/auth.dart';
import 'package:electric_client/satellite/client.dart';
import 'package:electric_client/satellite/config.dart';
import 'package:electric_client/util/common.dart';
import 'package:electric_client/util/types.dart';

class Satellite {
  final ConsoleClient console;
  final Client client;
  final SatelliteConfig config;

  AuthState? _authState;
  LSN? _lsn;

  Satellite({
    required this.console,
    required this.client,
    required this.config,
  });

  Future<void> start(AuthState? authState) async {
    if (authState != null) {
      throw UnimplementedError();
      // this._authState = authState
    } else {
      final app = config.app;
      final env = config.env;
      final clientId = await _getClientId();
      final token = await _getMeta('token');
      final refreshToken = await _getMeta('refreshToken');

      _authState = AuthState(
        app: app,
        env: env,
        clientId: clientId,
        token: token,
        refreshToken: refreshToken,
      );
    }

    final lsnBase64 = await _getMeta('lsn');
    if (lsnBase64.isNotEmpty) {
      print("retrieved lsn $_lsn");
      _lsn = base64.decode(lsnBase64);
    } else {
      print("no lsn retrieved from store");
    }

    await _connectAndStartReplication();
  }

  Future<void> _connectAndStartReplication() async {
    print("connecting and starting replication");

    final authState = _authState;
    if (authState == null) {
      throw Exception("trying to connect before authentication");
    }

// TODO: Connect to client
    return client
        .connect()
        .then((_) => refreshAuthState(authState))
        .then((freshAuthState) => client.authenticate(freshAuthState))
        //.then(() => client.startReplication(_lsn))
        .then((_) => null)
        .onError(
      (error, st) {
        print("couldn't start replication: $error");
        return null;
      },
    );
  }

  FutureOr<AuthState> refreshAuthState(AuthState authState) async {
    try {
      final tokenResponse = await console.token(
        TokenRequest(
          app: authState.app,
          env: authState.env,
          clientId: authState.clientId,
        ),
      );
      await _setMeta('token', tokenResponse.token);
      // TODO: Bug
      await _setMeta('refreshToken', tokenResponse.token);

      return AuthState(
        app: authState.app,
        env: authState.env,
        clientId: authState.clientId,
        token: tokenResponse.token,
        refreshToken: tokenResponse.refreshToken,
      );
    } catch (error) {
      print("unable to refresh token: $error");
    }

    return authState;
  }

  Future<String> _getClientId() async {
    const clientIdKey = 'clientId';

    String clientId = await _getMeta(clientIdKey);

    if (clientId.isEmpty) {
      clientId = uuid();
      await _setMeta(clientIdKey, clientId);
    }
    return clientId;
  }

  Future<String> _getMeta(String key) async {
    // TODO: Fetch from db
    // const meta = this.opts.metaTable.toString()

    // const sql = `SELECT value from ${meta} WHERE key = ?`
    // const args = [key]
    // const rows = await this.adapter.query({ sql, args })

    // if (rows.length !== 1) {
    //   throw `Invalid metadata table: missing ${key}`
    // }

    // return rows[0].value as string

    return "";
  }

  Future<void> _setMeta(String key, Object? value) async {
    // TODO: Update in db
    // const meta = this.opts.metaTable.toString()

    // const sql = `UPDATE ${meta} SET value = ? WHERE key = ?`
    // const args = [value, key]

    // await this.adapter.run({ sql, args })
  }

  //   async _connectAndStartReplication(): Promise<void | SatelliteError> {
  //   Log.info(`connecting and starting replication`)

  //   if (!this._authState) {
  //     throw new Error(`trying to connect before authentication`)
  //   }
  //   const authState = this._authState

  //   return this.client
  //     .connect()
  //     .then(() => this.refreshAuthState(authState))
  //     .then((freshAuthState) => this.client.authenticate(freshAuthState))
  //     .then(() => this.client.startReplication(this._lsn))
  //     .catch((error) => {
  //       Log.warn(`couldn't start replication: ${error}`)
  //     })
  // }
}
