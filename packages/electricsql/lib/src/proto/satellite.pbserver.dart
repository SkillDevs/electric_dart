//
//  Generated code. Do not modify.
//  source: proto/satellite.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'satellite.pb.dart' as $0;
import 'satellite.pbjson.dart';

export 'satellite.pb.dart';

abstract class RootServiceBase extends $pb.GeneratedService {
  $async.Future<$0.SatAuthResp> authenticate(
      $pb.ServerContext ctx, $0.SatAuthReq request);
  $async.Future<$0.SatInStartReplicationResp> startReplication(
      $pb.ServerContext ctx, $0.SatInStartReplicationReq request);
  $async.Future<$0.SatInStopReplicationResp> stopReplication(
      $pb.ServerContext ctx, $0.SatInStopReplicationReq request);
  $async.Future<$0.SatSubsResp> subscribe(
      $pb.ServerContext ctx, $0.SatSubsReq request);
  $async.Future<$0.SatUnsubsResp> unsubscribe(
      $pb.ServerContext ctx, $0.SatUnsubsReq request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'authenticate':
        return $0.SatAuthReq();
      case 'startReplication':
        return $0.SatInStartReplicationReq();
      case 'stopReplication':
        return $0.SatInStopReplicationReq();
      case 'subscribe':
        return $0.SatSubsReq();
      case 'unsubscribe':
        return $0.SatUnsubsReq();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'authenticate':
        return this.authenticate(ctx, request as $0.SatAuthReq);
      case 'startReplication':
        return this
            .startReplication(ctx, request as $0.SatInStartReplicationReq);
      case 'stopReplication':
        return this.stopReplication(ctx, request as $0.SatInStopReplicationReq);
      case 'subscribe':
        return this.subscribe(ctx, request as $0.SatSubsReq);
      case 'unsubscribe':
        return this.unsubscribe(ctx, request as $0.SatUnsubsReq);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => RootServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => RootServiceBase$messageJson;
}

abstract class ClientRootServiceBase extends $pb.GeneratedService {
  $async.Future<$0.SatInStartReplicationResp> startReplication(
      $pb.ServerContext ctx, $0.SatInStartReplicationReq request);
  $async.Future<$0.SatInStopReplicationResp> stopReplication(
      $pb.ServerContext ctx, $0.SatInStopReplicationReq request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'startReplication':
        return $0.SatInStartReplicationReq();
      case 'stopReplication':
        return $0.SatInStopReplicationReq();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'startReplication':
        return this
            .startReplication(ctx, request as $0.SatInStartReplicationReq);
      case 'stopReplication':
        return this.stopReplication(ctx, request as $0.SatInStopReplicationReq);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json =>
      ClientRootServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => ClientRootServiceBase$messageJson;
}
