// This file must not be moved, as the devtools extension will try to look up
// types in this exact library.
// ignore_for_file: public_member_api_docs
@internal
library;

import 'dart:developer' as developer;

import 'package:electricsql/src/client/model/client.dart';
import 'package:electricsql/src/devtools/service_extension.dart';
import 'package:meta/meta.dart';

const _releaseMode = bool.fromEnvironment('dart.vm.product');

// This code is only used for the DevTools extension. Avoid including it
// in release builds.
const enableDevtools = !_releaseMode;

void postEvent(String type, Map<Object?, Object?> data) {
  developer.postEvent('electricsql:$type', data);
}

void _postClientsChangedEvent() {
  postEvent('clients-list-changed', {});
}

void postDbResetChanged(String dbName) {
  postEvent('db-reset-changed', {'db': dbName});
}

void postDbWasReset(String dbName) {
  postEvent('db-was-reset', {'db': dbName});
}

void handleNewElectricClient(BaseElectricClient client) {
  if (enableDevtools) {
    ElectricServiceExtension.registerIfNeeded();
    ElectricDevtoolsBinding.registerElectricClient(client);
    _postClientsChangedEvent();
  }
}

void handleElectricClientClosed(String dbName) {
  if (enableDevtools) {
    ElectricDevtoolsBinding.unregisterElectricClient(dbName);
    _postClientsChangedEvent();
  }
}
