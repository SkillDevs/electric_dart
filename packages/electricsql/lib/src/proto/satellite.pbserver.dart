///
//  Generated code. Do not modify.
//  source: proto/satellite.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,deprecated_member_use_from_same_package,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:async' as $async;

import 'package:protobuf/protobuf.dart' as $pb;

import 'dart:core' as $core;
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

  $pb.GeneratedMessage createRequest($core.String method) {
    switch (method) {
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
        throw $core.ArgumentError('Unknown method: $method');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String method, $pb.GeneratedMessage request) {
    switch (method) {
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
        throw $core.ArgumentError('Unknown method: $method');
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

  $pb.GeneratedMessage createRequest($core.String method) {
    switch (method) {
      case 'startReplication':
        return $0.SatInStartReplicationReq();
      case 'stopReplication':
        return $0.SatInStopReplicationReq();
      default:
        throw $core.ArgumentError('Unknown method: $method');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String method, $pb.GeneratedMessage request) {
    switch (method) {
      case 'startReplication':
        return this
            .startReplication(ctx, request as $0.SatInStartReplicationReq);
      case 'stopReplication':
        return this.stopReplication(ctx, request as $0.SatInStopReplicationReq);
      default:
        throw $core.ArgumentError('Unknown method: $method');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json =>
      ClientRootServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => ClientRootServiceBase$messageJson;
}
