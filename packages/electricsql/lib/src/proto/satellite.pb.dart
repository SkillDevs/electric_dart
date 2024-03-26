//
//  Generated code. Do not modify.
//  source: proto/satellite.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'satellite.pbenum.dart';

export 'satellite.pbenum.dart';

/// RPC request transport message, must be used to implement service RPC calls in the protocol
class SatRpcRequest extends $pb.GeneratedMessage {
  factory SatRpcRequest({
    $core.String? method,
    $core.int? requestId,
    $core.List<$core.int>? message,
  }) {
    final $result = create();
    if (method != null) {
      $result.method = method;
    }
    if (requestId != null) {
      $result.requestId = requestId;
    }
    if (message != null) {
      $result.message = message;
    }
    return $result;
  }
  SatRpcRequest._() : super();
  factory SatRpcRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatRpcRequest.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatRpcRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'method')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'requestId', $pb.PbFieldType.OU3)
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'message', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatRpcRequest clone() => SatRpcRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatRpcRequest copyWith(void Function(SatRpcRequest) updates) =>
      super.copyWith((message) => updates(message as SatRpcRequest))
          as SatRpcRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatRpcRequest create() => SatRpcRequest._();
  SatRpcRequest createEmptyInstance() => create();
  static $pb.PbList<SatRpcRequest> createRepeated() =>
      $pb.PbList<SatRpcRequest>();
  @$core.pragma('dart2js:noInline')
  static SatRpcRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SatRpcRequest>(create);
  static SatRpcRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get method => $_getSZ(0);
  @$pb.TagNumber(1)
  set method($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasMethod() => $_has(0);
  @$pb.TagNumber(1)
  void clearMethod() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get requestId => $_getIZ(1);
  @$pb.TagNumber(2)
  set requestId($core.int v) {
    $_setUnsignedInt32(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasRequestId() => $_has(1);
  @$pb.TagNumber(2)
  void clearRequestId() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get message => $_getN(2);
  @$pb.TagNumber(3)
  set message($core.List<$core.int> v) {
    $_setBytes(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasMessage() => $_has(2);
  @$pb.TagNumber(3)
  void clearMessage() => clearField(3);
}

enum SatRpcResponse_Result { message, error, notSet }

/// RPC response transport message, must be used to implement service RPC calls in the protocol
class SatRpcResponse extends $pb.GeneratedMessage {
  factory SatRpcResponse({
    $core.String? method,
    $core.int? requestId,
    $core.List<$core.int>? message,
    SatErrorResp? error,
  }) {
    final $result = create();
    if (method != null) {
      $result.method = method;
    }
    if (requestId != null) {
      $result.requestId = requestId;
    }
    if (message != null) {
      $result.message = message;
    }
    if (error != null) {
      $result.error = error;
    }
    return $result;
  }
  SatRpcResponse._() : super();
  factory SatRpcResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatRpcResponse.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, SatRpcResponse_Result>
      _SatRpcResponse_ResultByTag = {
    3: SatRpcResponse_Result.message,
    4: SatRpcResponse_Result.error,
    0: SatRpcResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatRpcResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..oo(0, [3, 4])
    ..aOS(1, _omitFieldNames ? '' : 'method')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'requestId', $pb.PbFieldType.OU3)
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'message', $pb.PbFieldType.OY)
    ..aOM<SatErrorResp>(4, _omitFieldNames ? '' : 'error',
        subBuilder: SatErrorResp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatRpcResponse clone() => SatRpcResponse()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatRpcResponse copyWith(void Function(SatRpcResponse) updates) =>
      super.copyWith((message) => updates(message as SatRpcResponse))
          as SatRpcResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatRpcResponse create() => SatRpcResponse._();
  SatRpcResponse createEmptyInstance() => create();
  static $pb.PbList<SatRpcResponse> createRepeated() =>
      $pb.PbList<SatRpcResponse>();
  @$core.pragma('dart2js:noInline')
  static SatRpcResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SatRpcResponse>(create);
  static SatRpcResponse? _defaultInstance;

  SatRpcResponse_Result whichResult() =>
      _SatRpcResponse_ResultByTag[$_whichOneof(0)]!;
  void clearResult() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.String get method => $_getSZ(0);
  @$pb.TagNumber(1)
  set method($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasMethod() => $_has(0);
  @$pb.TagNumber(1)
  void clearMethod() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get requestId => $_getIZ(1);
  @$pb.TagNumber(2)
  set requestId($core.int v) {
    $_setUnsignedInt32(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasRequestId() => $_has(1);
  @$pb.TagNumber(2)
  void clearRequestId() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get message => $_getN(2);
  @$pb.TagNumber(3)
  set message($core.List<$core.int> v) {
    $_setBytes(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasMessage() => $_has(2);
  @$pb.TagNumber(3)
  void clearMessage() => clearField(3);

  @$pb.TagNumber(4)
  SatErrorResp get error => $_getN(3);
  @$pb.TagNumber(4)
  set error(SatErrorResp v) {
    setField(4, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasError() => $_has(3);
  @$pb.TagNumber(4)
  void clearError() => clearField(4);
  @$pb.TagNumber(4)
  SatErrorResp ensureError() => $_ensure(3);
}

class SatAuthHeaderPair extends $pb.GeneratedMessage {
  factory SatAuthHeaderPair({
    SatAuthHeader? key,
    $core.String? value,
  }) {
    final $result = create();
    if (key != null) {
      $result.key = key;
    }
    if (value != null) {
      $result.value = value;
    }
    return $result;
  }
  SatAuthHeaderPair._() : super();
  factory SatAuthHeaderPair.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatAuthHeaderPair.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatAuthHeaderPair',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..e<SatAuthHeader>(1, _omitFieldNames ? '' : 'key', $pb.PbFieldType.OE,
        defaultOrMaker: SatAuthHeader.UNSPECIFIED,
        valueOf: SatAuthHeader.valueOf,
        enumValues: SatAuthHeader.values)
    ..aOS(2, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatAuthHeaderPair clone() => SatAuthHeaderPair()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatAuthHeaderPair copyWith(void Function(SatAuthHeaderPair) updates) =>
      super.copyWith((message) => updates(message as SatAuthHeaderPair))
          as SatAuthHeaderPair;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatAuthHeaderPair create() => SatAuthHeaderPair._();
  SatAuthHeaderPair createEmptyInstance() => create();
  static $pb.PbList<SatAuthHeaderPair> createRepeated() =>
      $pb.PbList<SatAuthHeaderPair>();
  @$core.pragma('dart2js:noInline')
  static SatAuthHeaderPair getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SatAuthHeaderPair>(create);
  static SatAuthHeaderPair? _defaultInstance;

  @$pb.TagNumber(1)
  SatAuthHeader get key => $_getN(0);
  @$pb.TagNumber(1)
  set key(SatAuthHeader v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearKey() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get value => $_getSZ(1);
  @$pb.TagNumber(2)
  set value($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearValue() => clearField(2);
}

///  (Client) Auth request
///
///  Client request is the first request that the client should send before
///  executing any other request.
class SatAuthReq extends $pb.GeneratedMessage {
  factory SatAuthReq({
    $core.String? id,
    $core.String? token,
    $core.Iterable<SatAuthHeaderPair>? headers,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (token != null) {
      $result.token = token;
    }
    if (headers != null) {
      $result.headers.addAll(headers);
    }
    return $result;
  }
  SatAuthReq._() : super();
  factory SatAuthReq.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatAuthReq.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatAuthReq',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'token')
    ..pc<SatAuthHeaderPair>(
        3, _omitFieldNames ? '' : 'headers', $pb.PbFieldType.PM,
        subBuilder: SatAuthHeaderPair.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatAuthReq clone() => SatAuthReq()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatAuthReq copyWith(void Function(SatAuthReq) updates) =>
      super.copyWith((message) => updates(message as SatAuthReq)) as SatAuthReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatAuthReq create() => SatAuthReq._();
  SatAuthReq createEmptyInstance() => create();
  static $pb.PbList<SatAuthReq> createRepeated() => $pb.PbList<SatAuthReq>();
  @$core.pragma('dart2js:noInline')
  static SatAuthReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SatAuthReq>(create);
  static SatAuthReq? _defaultInstance;

  /// Identity of the Satellite application. Is expected to be something like
  /// UUID. Required field
  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  /// Authentication token, auth method specific, required
  @$pb.TagNumber(2)
  $core.String get token => $_getSZ(1);
  @$pb.TagNumber(2)
  set token($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearToken() => clearField(2);

  /// Headers, required
  @$pb.TagNumber(3)
  $core.List<SatAuthHeaderPair> get headers => $_getList(2);
}

/// (Server) Auth response
class SatAuthResp extends $pb.GeneratedMessage {
  factory SatAuthResp({
    $core.String? id,
    $core.Iterable<SatAuthHeaderPair>? headers,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (headers != null) {
      $result.headers.addAll(headers);
    }
    return $result;
  }
  SatAuthResp._() : super();
  factory SatAuthResp.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatAuthResp.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatAuthResp',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..pc<SatAuthHeaderPair>(
        3, _omitFieldNames ? '' : 'headers', $pb.PbFieldType.PM,
        subBuilder: SatAuthHeaderPair.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatAuthResp clone() => SatAuthResp()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatAuthResp copyWith(void Function(SatAuthResp) updates) =>
      super.copyWith((message) => updates(message as SatAuthResp))
          as SatAuthResp;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatAuthResp create() => SatAuthResp._();
  SatAuthResp createEmptyInstance() => create();
  static $pb.PbList<SatAuthResp> createRepeated() => $pb.PbList<SatAuthResp>();
  @$core.pragma('dart2js:noInline')
  static SatAuthResp getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SatAuthResp>(create);
  static SatAuthResp? _defaultInstance;

  /// Identity of the Server
  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  /// Headers optional
  @$pb.TagNumber(3)
  $core.List<SatAuthHeaderPair> get headers => $_getList(1);
}

/// General purpose error message, that could be sent to any request from any
/// side. FIXME: We might want to separate that into Client/Server parts.
class SatErrorResp extends $pb.GeneratedMessage {
  factory SatErrorResp({
    SatErrorResp_ErrorCode? errorType,
    $core.List<$core.int>? lsn,
    $core.String? message,
  }) {
    final $result = create();
    if (errorType != null) {
      $result.errorType = errorType;
    }
    if (lsn != null) {
      $result.lsn = lsn;
    }
    if (message != null) {
      $result.message = message;
    }
    return $result;
  }
  SatErrorResp._() : super();
  factory SatErrorResp.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatErrorResp.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatErrorResp',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..e<SatErrorResp_ErrorCode>(
        1, _omitFieldNames ? '' : 'errorType', $pb.PbFieldType.OE,
        defaultOrMaker: SatErrorResp_ErrorCode.INTERNAL,
        valueOf: SatErrorResp_ErrorCode.valueOf,
        enumValues: SatErrorResp_ErrorCode.values)
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'lsn', $pb.PbFieldType.OY)
    ..aOS(3, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatErrorResp clone() => SatErrorResp()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatErrorResp copyWith(void Function(SatErrorResp) updates) =>
      super.copyWith((message) => updates(message as SatErrorResp))
          as SatErrorResp;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatErrorResp create() => SatErrorResp._();
  SatErrorResp createEmptyInstance() => create();
  static $pb.PbList<SatErrorResp> createRepeated() =>
      $pb.PbList<SatErrorResp>();
  @$core.pragma('dart2js:noInline')
  static SatErrorResp getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SatErrorResp>(create);
  static SatErrorResp? _defaultInstance;

  @$pb.TagNumber(1)
  SatErrorResp_ErrorCode get errorType => $_getN(0);
  @$pb.TagNumber(1)
  set errorType(SatErrorResp_ErrorCode v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasErrorType() => $_has(0);
  @$pb.TagNumber(1)
  void clearErrorType() => clearField(1);

  /// lsn of the txn that caused the problem, if available
  @$pb.TagNumber(2)
  $core.List<$core.int> get lsn => $_getN(1);
  @$pb.TagNumber(2)
  set lsn($core.List<$core.int> v) {
    $_setBytes(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasLsn() => $_has(1);
  @$pb.TagNumber(2)
  void clearLsn() => clearField(2);

  /// human readable explanation of what went wrong
  @$pb.TagNumber(3)
  $core.String get message => $_getSZ(2);
  @$pb.TagNumber(3)
  set message($core.String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasMessage() => $_has(2);
  @$pb.TagNumber(3)
  void clearMessage() => clearField(3);
}

/// (Consumer) Starts replication stream from producer to consumer
class SatInStartReplicationReq extends $pb.GeneratedMessage {
  factory SatInStartReplicationReq({
    $core.List<$core.int>? lsn,
    $core.Iterable<SatInStartReplicationReq_Option>? options,
    $core.Iterable<$core.String>? subscriptionIds,
    $core.String? schemaVersion,
    $core.Iterable<$fixnum.Int64>? observedTransactionData,
  }) {
    final $result = create();
    if (lsn != null) {
      $result.lsn = lsn;
    }
    if (options != null) {
      $result.options.addAll(options);
    }
    if (subscriptionIds != null) {
      $result.subscriptionIds.addAll(subscriptionIds);
    }
    if (schemaVersion != null) {
      $result.schemaVersion = schemaVersion;
    }
    if (observedTransactionData != null) {
      $result.observedTransactionData.addAll(observedTransactionData);
    }
    return $result;
  }
  SatInStartReplicationReq._() : super();
  factory SatInStartReplicationReq.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatInStartReplicationReq.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatInStartReplicationReq',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'lsn', $pb.PbFieldType.OY)
    ..pc<SatInStartReplicationReq_Option>(
        2, _omitFieldNames ? '' : 'options', $pb.PbFieldType.KE,
        valueOf: SatInStartReplicationReq_Option.valueOf,
        enumValues: SatInStartReplicationReq_Option.values,
        defaultEnumValue: SatInStartReplicationReq_Option.NONE)
    ..pPS(4, _omitFieldNames ? '' : 'subscriptionIds')
    ..aOS(5, _omitFieldNames ? '' : 'schemaVersion')
    ..p<$fixnum.Int64>(6, _omitFieldNames ? '' : 'observedTransactionData',
        $pb.PbFieldType.KU6)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatInStartReplicationReq clone() =>
      SatInStartReplicationReq()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatInStartReplicationReq copyWith(
          void Function(SatInStartReplicationReq) updates) =>
      super.copyWith((message) => updates(message as SatInStartReplicationReq))
          as SatInStartReplicationReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatInStartReplicationReq create() => SatInStartReplicationReq._();
  SatInStartReplicationReq createEmptyInstance() => create();
  static $pb.PbList<SatInStartReplicationReq> createRepeated() =>
      $pb.PbList<SatInStartReplicationReq>();
  @$core.pragma('dart2js:noInline')
  static SatInStartReplicationReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SatInStartReplicationReq>(create);
  static SatInStartReplicationReq? _defaultInstance;

  /// LSN position of the log on the producer side
  @$pb.TagNumber(1)
  $core.List<$core.int> get lsn => $_getN(0);
  @$pb.TagNumber(1)
  set lsn($core.List<$core.int> v) {
    $_setBytes(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasLsn() => $_has(0);
  @$pb.TagNumber(1)
  void clearLsn() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<SatInStartReplicationReq_Option> get options => $_getList(1);

  /// the subscriptions identifiers the client wants to resume subscription
  @$pb.TagNumber(4)
  $core.List<$core.String> get subscriptionIds => $_getList(2);

  /// The version of the most recent migration seen by the client.
  @$pb.TagNumber(5)
  $core.String get schemaVersion => $_getSZ(3);
  @$pb.TagNumber(5)
  set schemaVersion($core.String v) {
    $_setString(3, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasSchemaVersion() => $_has(3);
  @$pb.TagNumber(5)
  void clearSchemaVersion() => clearField(5);

  /// *
  ///  List of transaction IDs for which the client
  ///  observed additional data before disconnect
  @$pb.TagNumber(6)
  $core.List<$fixnum.Int64> get observedTransactionData => $_getList(4);
}

/// Error returned by the Producer when replication fails to start
class SatInStartReplicationResp_ReplicationError extends $pb.GeneratedMessage {
  factory SatInStartReplicationResp_ReplicationError({
    SatInStartReplicationResp_ReplicationError_Code? code,
    $core.String? message,
  }) {
    final $result = create();
    if (code != null) {
      $result.code = code;
    }
    if (message != null) {
      $result.message = message;
    }
    return $result;
  }
  SatInStartReplicationResp_ReplicationError._() : super();
  factory SatInStartReplicationResp_ReplicationError.fromBuffer(
          $core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatInStartReplicationResp_ReplicationError.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatInStartReplicationResp.ReplicationError',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..e<SatInStartReplicationResp_ReplicationError_Code>(
        1, _omitFieldNames ? '' : 'code', $pb.PbFieldType.OE,
        defaultOrMaker:
            SatInStartReplicationResp_ReplicationError_Code.CODE_UNSPECIFIED,
        valueOf: SatInStartReplicationResp_ReplicationError_Code.valueOf,
        enumValues: SatInStartReplicationResp_ReplicationError_Code.values)
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatInStartReplicationResp_ReplicationError clone() =>
      SatInStartReplicationResp_ReplicationError()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatInStartReplicationResp_ReplicationError copyWith(
          void Function(SatInStartReplicationResp_ReplicationError) updates) =>
      super.copyWith((message) =>
              updates(message as SatInStartReplicationResp_ReplicationError))
          as SatInStartReplicationResp_ReplicationError;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatInStartReplicationResp_ReplicationError create() =>
      SatInStartReplicationResp_ReplicationError._();
  SatInStartReplicationResp_ReplicationError createEmptyInstance() => create();
  static $pb.PbList<SatInStartReplicationResp_ReplicationError>
      createRepeated() =>
          $pb.PbList<SatInStartReplicationResp_ReplicationError>();
  @$core.pragma('dart2js:noInline')
  static SatInStartReplicationResp_ReplicationError getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
          SatInStartReplicationResp_ReplicationError>(create);
  static SatInStartReplicationResp_ReplicationError? _defaultInstance;

  /// error code
  @$pb.TagNumber(1)
  SatInStartReplicationResp_ReplicationError_Code get code => $_getN(0);
  @$pb.TagNumber(1)
  set code(SatInStartReplicationResp_ReplicationError_Code v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => clearField(1);

  /// a human-readable description of the error
  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => clearField(2);
}

/// (Producer) The result of the start replication requests
class SatInStartReplicationResp extends $pb.GeneratedMessage {
  factory SatInStartReplicationResp({
    SatInStartReplicationResp_ReplicationError? err,
    $core.int? unackedWindowSize,
  }) {
    final $result = create();
    if (err != null) {
      $result.err = err;
    }
    if (unackedWindowSize != null) {
      $result.unackedWindowSize = unackedWindowSize;
    }
    return $result;
  }
  SatInStartReplicationResp._() : super();
  factory SatInStartReplicationResp.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatInStartReplicationResp.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatInStartReplicationResp',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..aOM<SatInStartReplicationResp_ReplicationError>(
        1, _omitFieldNames ? '' : 'err',
        subBuilder: SatInStartReplicationResp_ReplicationError.create)
    ..a<$core.int>(
        2, _omitFieldNames ? '' : 'unackedWindowSize', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatInStartReplicationResp clone() =>
      SatInStartReplicationResp()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatInStartReplicationResp copyWith(
          void Function(SatInStartReplicationResp) updates) =>
      super.copyWith((message) => updates(message as SatInStartReplicationResp))
          as SatInStartReplicationResp;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatInStartReplicationResp create() => SatInStartReplicationResp._();
  SatInStartReplicationResp createEmptyInstance() => create();
  static $pb.PbList<SatInStartReplicationResp> createRepeated() =>
      $pb.PbList<SatInStartReplicationResp>();
  @$core.pragma('dart2js:noInline')
  static SatInStartReplicationResp getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SatInStartReplicationResp>(create);
  static SatInStartReplicationResp? _defaultInstance;

  /// returned in case replication fails to start
  @$pb.TagNumber(1)
  SatInStartReplicationResp_ReplicationError get err => $_getN(0);
  @$pb.TagNumber(1)
  set err(SatInStartReplicationResp_ReplicationError v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasErr() => $_has(0);
  @$pb.TagNumber(1)
  void clearErr() => clearField(1);
  @$pb.TagNumber(1)
  SatInStartReplicationResp_ReplicationError ensureErr() => $_ensure(0);

  /// * How many unacked transactions the producer is willing to send
  @$pb.TagNumber(2)
  $core.int get unackedWindowSize => $_getIZ(1);
  @$pb.TagNumber(2)
  set unackedWindowSize($core.int v) {
    $_setUnsignedInt32(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasUnackedWindowSize() => $_has(1);
  @$pb.TagNumber(2)
  void clearUnackedWindowSize() => clearField(2);
}

/// (Consumer) Request to stop replication
class SatInStopReplicationReq extends $pb.GeneratedMessage {
  factory SatInStopReplicationReq() => create();
  SatInStopReplicationReq._() : super();
  factory SatInStopReplicationReq.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatInStopReplicationReq.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatInStopReplicationReq',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatInStopReplicationReq clone() =>
      SatInStopReplicationReq()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatInStopReplicationReq copyWith(
          void Function(SatInStopReplicationReq) updates) =>
      super.copyWith((message) => updates(message as SatInStopReplicationReq))
          as SatInStopReplicationReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatInStopReplicationReq create() => SatInStopReplicationReq._();
  SatInStopReplicationReq createEmptyInstance() => create();
  static $pb.PbList<SatInStopReplicationReq> createRepeated() =>
      $pb.PbList<SatInStopReplicationReq>();
  @$core.pragma('dart2js:noInline')
  static SatInStopReplicationReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SatInStopReplicationReq>(create);
  static SatInStopReplicationReq? _defaultInstance;
}

/// (Producer) Acknowledgement that replication has been stopped
class SatInStopReplicationResp extends $pb.GeneratedMessage {
  factory SatInStopReplicationResp() => create();
  SatInStopReplicationResp._() : super();
  factory SatInStopReplicationResp.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatInStopReplicationResp.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatInStopReplicationResp',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatInStopReplicationResp clone() =>
      SatInStopReplicationResp()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatInStopReplicationResp copyWith(
          void Function(SatInStopReplicationResp) updates) =>
      super.copyWith((message) => updates(message as SatInStopReplicationResp))
          as SatInStopReplicationResp;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatInStopReplicationResp create() => SatInStopReplicationResp._();
  SatInStopReplicationResp createEmptyInstance() => create();
  static $pb.PbList<SatInStopReplicationResp> createRepeated() =>
      $pb.PbList<SatInStopReplicationResp>();
  @$core.pragma('dart2js:noInline')
  static SatInStopReplicationResp getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SatInStopReplicationResp>(create);
  static SatInStopReplicationResp? _defaultInstance;
}

class SatRelationColumn extends $pb.GeneratedMessage {
  factory SatRelationColumn({
    $core.String? name,
    $core.String? type,
    $core.bool? primaryKey,
    $core.bool? isNullable,
  }) {
    final $result = create();
    if (name != null) {
      $result.name = name;
    }
    if (type != null) {
      $result.type = type;
    }
    if (primaryKey != null) {
      $result.primaryKey = primaryKey;
    }
    if (isNullable != null) {
      $result.isNullable = isNullable;
    }
    return $result;
  }
  SatRelationColumn._() : super();
  factory SatRelationColumn.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatRelationColumn.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatRelationColumn',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'type')
    ..aOB(3, _omitFieldNames ? '' : 'primaryKey', protoName: 'primaryKey')
    ..aOB(4, _omitFieldNames ? '' : 'isNullable')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatRelationColumn clone() => SatRelationColumn()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatRelationColumn copyWith(void Function(SatRelationColumn) updates) =>
      super.copyWith((message) => updates(message as SatRelationColumn))
          as SatRelationColumn;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatRelationColumn create() => SatRelationColumn._();
  SatRelationColumn createEmptyInstance() => create();
  static $pb.PbList<SatRelationColumn> createRepeated() =>
      $pb.PbList<SatRelationColumn>();
  @$core.pragma('dart2js:noInline')
  static SatRelationColumn getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SatRelationColumn>(create);
  static SatRelationColumn? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get type => $_getSZ(1);
  @$pb.TagNumber(2)
  set type($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasType() => $_has(1);
  @$pb.TagNumber(2)
  void clearType() => clearField(2);

  @$pb.TagNumber(3)
  $core.bool get primaryKey => $_getBF(2);
  @$pb.TagNumber(3)
  set primaryKey($core.bool v) {
    $_setBool(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasPrimaryKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearPrimaryKey() => clearField(3);

  @$pb.TagNumber(4)
  $core.bool get isNullable => $_getBF(3);
  @$pb.TagNumber(4)
  set isNullable($core.bool v) {
    $_setBool(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasIsNullable() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsNullable() => clearField(4);
}

class SatRelation extends $pb.GeneratedMessage {
  factory SatRelation({
    $core.String? schemaName,
    SatRelation_RelationType? tableType,
    $core.String? tableName,
    $core.int? relationId,
    $core.Iterable<SatRelationColumn>? columns,
  }) {
    final $result = create();
    if (schemaName != null) {
      $result.schemaName = schemaName;
    }
    if (tableType != null) {
      $result.tableType = tableType;
    }
    if (tableName != null) {
      $result.tableName = tableName;
    }
    if (relationId != null) {
      $result.relationId = relationId;
    }
    if (columns != null) {
      $result.columns.addAll(columns);
    }
    return $result;
  }
  SatRelation._() : super();
  factory SatRelation.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatRelation.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatRelation',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'schemaName')
    ..e<SatRelation_RelationType>(
        2, _omitFieldNames ? '' : 'tableType', $pb.PbFieldType.OE,
        defaultOrMaker: SatRelation_RelationType.TABLE,
        valueOf: SatRelation_RelationType.valueOf,
        enumValues: SatRelation_RelationType.values)
    ..aOS(3, _omitFieldNames ? '' : 'tableName')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'relationId', $pb.PbFieldType.OU3)
    ..pc<SatRelationColumn>(
        5, _omitFieldNames ? '' : 'columns', $pb.PbFieldType.PM,
        subBuilder: SatRelationColumn.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatRelation clone() => SatRelation()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatRelation copyWith(void Function(SatRelation) updates) =>
      super.copyWith((message) => updates(message as SatRelation))
          as SatRelation;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatRelation create() => SatRelation._();
  SatRelation createEmptyInstance() => create();
  static $pb.PbList<SatRelation> createRepeated() => $pb.PbList<SatRelation>();
  @$core.pragma('dart2js:noInline')
  static SatRelation getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SatRelation>(create);
  static SatRelation? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get schemaName => $_getSZ(0);
  @$pb.TagNumber(1)
  set schemaName($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasSchemaName() => $_has(0);
  @$pb.TagNumber(1)
  void clearSchemaName() => clearField(1);

  @$pb.TagNumber(2)
  SatRelation_RelationType get tableType => $_getN(1);
  @$pb.TagNumber(2)
  set tableType(SatRelation_RelationType v) {
    setField(2, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasTableType() => $_has(1);
  @$pb.TagNumber(2)
  void clearTableType() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get tableName => $_getSZ(2);
  @$pb.TagNumber(3)
  set tableName($core.String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasTableName() => $_has(2);
  @$pb.TagNumber(3)
  void clearTableName() => clearField(3);

  /// Volatile identity defined at the start of the replication protocol may or
  /// may not be persisted is used in SatTransOp operations, to indicate
  /// relation the operation is working on.
  @$pb.TagNumber(4)
  $core.int get relationId => $_getIZ(3);
  @$pb.TagNumber(4)
  set relationId($core.int v) {
    $_setUnsignedInt32(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasRelationId() => $_has(3);
  @$pb.TagNumber(4)
  void clearRelationId() => clearField(4);

  @$pb.TagNumber(5)
  $core.List<SatRelationColumn> get columns => $_getList(4);
}

/// (Producer) Type defines replication messages, that flow from Producer once
/// the replication is established. Message contains operations log. Operations
/// should go in the LSN order. Begin and Commit operations corresponds to
/// transaction boundaries.
/// Transactions are guranteed not to be mixed, and will follow one by one.
class SatOpLog extends $pb.GeneratedMessage {
  factory SatOpLog({
    $core.Iterable<SatTransOp>? ops,
  }) {
    final $result = create();
    if (ops != null) {
      $result.ops.addAll(ops);
    }
    return $result;
  }
  SatOpLog._() : super();
  factory SatOpLog.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatOpLog.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatOpLog',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..pc<SatTransOp>(1, _omitFieldNames ? '' : 'ops', $pb.PbFieldType.PM,
        subBuilder: SatTransOp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatOpLog clone() => SatOpLog()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatOpLog copyWith(void Function(SatOpLog) updates) =>
      super.copyWith((message) => updates(message as SatOpLog)) as SatOpLog;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatOpLog create() => SatOpLog._();
  SatOpLog createEmptyInstance() => create();
  static $pb.PbList<SatOpLog> createRepeated() => $pb.PbList<SatOpLog>();
  @$core.pragma('dart2js:noInline')
  static SatOpLog getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SatOpLog>(create);
  static SatOpLog? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<SatTransOp> get ops => $_getList(0);
}

/// *
///  Acknowledgement message that the transaction with given LSN has been incorporated by the client.
///  Sent by the consumer and used by the producer to regulate garbage collection & backpressure.
///  Clients that don't send it after a certain number of transactions will be considered non-responsive
///  and the producer may choose to pause sending further information to such a client.
///
///  It's also important the the producer may deny connection requests from clients who try to connect with
///  LSN number less than the most recently acknowledged one, as the acknowledgement may have caused a
///  cleanup of information for this client before this point in time.
class SatOpLogAck extends $pb.GeneratedMessage {
  factory SatOpLogAck({
    $fixnum.Int64? ackTimestamp,
    $core.List<$core.int>? lsn,
    $fixnum.Int64? transactionId,
    $core.Iterable<$core.String>? subscriptionIds,
    $core.Iterable<$fixnum.Int64>? additionalDataSourceIds,
  }) {
    final $result = create();
    if (ackTimestamp != null) {
      $result.ackTimestamp = ackTimestamp;
    }
    if (lsn != null) {
      $result.lsn = lsn;
    }
    if (transactionId != null) {
      $result.transactionId = transactionId;
    }
    if (subscriptionIds != null) {
      $result.subscriptionIds.addAll(subscriptionIds);
    }
    if (additionalDataSourceIds != null) {
      $result.additionalDataSourceIds.addAll(additionalDataSourceIds);
    }
    return $result;
  }
  SatOpLogAck._() : super();
  factory SatOpLogAck.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatOpLogAck.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatOpLogAck',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'ackTimestamp', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'lsn', $pb.PbFieldType.OY)
    ..a<$fixnum.Int64>(
        3, _omitFieldNames ? '' : 'transactionId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..pPS(4, _omitFieldNames ? '' : 'subscriptionIds')
    ..p<$fixnum.Int64>(5, _omitFieldNames ? '' : 'additionalDataSourceIds',
        $pb.PbFieldType.KU6)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatOpLogAck clone() => SatOpLogAck()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatOpLogAck copyWith(void Function(SatOpLogAck) updates) =>
      super.copyWith((message) => updates(message as SatOpLogAck))
          as SatOpLogAck;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatOpLogAck create() => SatOpLogAck._();
  SatOpLogAck createEmptyInstance() => create();
  static $pb.PbList<SatOpLogAck> createRepeated() => $pb.PbList<SatOpLogAck>();
  @$core.pragma('dart2js:noInline')
  static SatOpLogAck getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SatOpLogAck>(create);
  static SatOpLogAck? _defaultInstance;

  /// * Timestamp on the sending side
  @$pb.TagNumber(1)
  $fixnum.Int64 get ackTimestamp => $_getI64(0);
  @$pb.TagNumber(1)
  set ackTimestamp($fixnum.Int64 v) {
    $_setInt64(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasAckTimestamp() => $_has(0);
  @$pb.TagNumber(1)
  void clearAckTimestamp() => clearField(1);

  /// * LSN of the most recent incorporated transaction
  @$pb.TagNumber(2)
  $core.List<$core.int> get lsn => $_getN(1);
  @$pb.TagNumber(2)
  set lsn($core.List<$core.int> v) {
    $_setBytes(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasLsn() => $_has(1);
  @$pb.TagNumber(2)
  void clearLsn() => clearField(2);

  /// * Transaction ID of the most recent incorporated transaction
  @$pb.TagNumber(3)
  $fixnum.Int64 get transactionId => $_getI64(2);
  @$pb.TagNumber(3)
  set transactionId($fixnum.Int64 v) {
    $_setInt64(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasTransactionId() => $_has(2);
  @$pb.TagNumber(3)
  void clearTransactionId() => clearField(3);

  /// * Subscription IDs for data that was received immediately after this transaction
  @$pb.TagNumber(4)
  $core.List<$core.String> get subscriptionIds => $_getList(3);

  /// * Transaction IDs for which additional data was received immediately after this transaction
  @$pb.TagNumber(5)
  $core.List<$fixnum.Int64> get additionalDataSourceIds => $_getList(4);
}

enum SatTransOp_Op {
  begin,
  commit,
  update,
  insert,
  delete,
  migrate,
  compensation,
  gone,
  additionalBegin,
  additionalCommit,
  notSet
}

/// (Producer) Single operation, should be only send as part of the SatOplog
/// message
class SatTransOp extends $pb.GeneratedMessage {
  factory SatTransOp({
    SatOpBegin? begin,
    SatOpCommit? commit,
    SatOpUpdate? update,
    SatOpInsert? insert,
    SatOpDelete? delete,
    SatOpMigrate? migrate,
    SatOpCompensation? compensation,
    SatOpGone? gone,
    SatOpAdditionalBegin? additionalBegin,
    SatOpAdditionalCommit? additionalCommit,
  }) {
    final $result = create();
    if (begin != null) {
      $result.begin = begin;
    }
    if (commit != null) {
      $result.commit = commit;
    }
    if (update != null) {
      $result.update = update;
    }
    if (insert != null) {
      $result.insert = insert;
    }
    if (delete != null) {
      $result.delete = delete;
    }
    if (migrate != null) {
      $result.migrate = migrate;
    }
    if (compensation != null) {
      $result.compensation = compensation;
    }
    if (gone != null) {
      $result.gone = gone;
    }
    if (additionalBegin != null) {
      $result.additionalBegin = additionalBegin;
    }
    if (additionalCommit != null) {
      $result.additionalCommit = additionalCommit;
    }
    return $result;
  }
  SatTransOp._() : super();
  factory SatTransOp.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatTransOp.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, SatTransOp_Op> _SatTransOp_OpByTag = {
    1: SatTransOp_Op.begin,
    2: SatTransOp_Op.commit,
    3: SatTransOp_Op.update,
    4: SatTransOp_Op.insert,
    5: SatTransOp_Op.delete,
    6: SatTransOp_Op.migrate,
    7: SatTransOp_Op.compensation,
    8: SatTransOp_Op.gone,
    9: SatTransOp_Op.additionalBegin,
    10: SatTransOp_Op.additionalCommit,
    0: SatTransOp_Op.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatTransOp',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..oo(0, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
    ..aOM<SatOpBegin>(1, _omitFieldNames ? '' : 'begin',
        subBuilder: SatOpBegin.create)
    ..aOM<SatOpCommit>(2, _omitFieldNames ? '' : 'commit',
        subBuilder: SatOpCommit.create)
    ..aOM<SatOpUpdate>(3, _omitFieldNames ? '' : 'update',
        subBuilder: SatOpUpdate.create)
    ..aOM<SatOpInsert>(4, _omitFieldNames ? '' : 'insert',
        subBuilder: SatOpInsert.create)
    ..aOM<SatOpDelete>(5, _omitFieldNames ? '' : 'delete',
        subBuilder: SatOpDelete.create)
    ..aOM<SatOpMigrate>(6, _omitFieldNames ? '' : 'migrate',
        subBuilder: SatOpMigrate.create)
    ..aOM<SatOpCompensation>(7, _omitFieldNames ? '' : 'compensation',
        subBuilder: SatOpCompensation.create)
    ..aOM<SatOpGone>(8, _omitFieldNames ? '' : 'gone',
        subBuilder: SatOpGone.create)
    ..aOM<SatOpAdditionalBegin>(9, _omitFieldNames ? '' : 'additionalBegin',
        subBuilder: SatOpAdditionalBegin.create)
    ..aOM<SatOpAdditionalCommit>(10, _omitFieldNames ? '' : 'additionalCommit',
        subBuilder: SatOpAdditionalCommit.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatTransOp clone() => SatTransOp()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatTransOp copyWith(void Function(SatTransOp) updates) =>
      super.copyWith((message) => updates(message as SatTransOp)) as SatTransOp;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatTransOp create() => SatTransOp._();
  SatTransOp createEmptyInstance() => create();
  static $pb.PbList<SatTransOp> createRepeated() => $pb.PbList<SatTransOp>();
  @$core.pragma('dart2js:noInline')
  static SatTransOp getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SatTransOp>(create);
  static SatTransOp? _defaultInstance;

  SatTransOp_Op whichOp() => _SatTransOp_OpByTag[$_whichOneof(0)]!;
  void clearOp() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  SatOpBegin get begin => $_getN(0);
  @$pb.TagNumber(1)
  set begin(SatOpBegin v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasBegin() => $_has(0);
  @$pb.TagNumber(1)
  void clearBegin() => clearField(1);
  @$pb.TagNumber(1)
  SatOpBegin ensureBegin() => $_ensure(0);

  @$pb.TagNumber(2)
  SatOpCommit get commit => $_getN(1);
  @$pb.TagNumber(2)
  set commit(SatOpCommit v) {
    setField(2, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasCommit() => $_has(1);
  @$pb.TagNumber(2)
  void clearCommit() => clearField(2);
  @$pb.TagNumber(2)
  SatOpCommit ensureCommit() => $_ensure(1);

  @$pb.TagNumber(3)
  SatOpUpdate get update => $_getN(2);
  @$pb.TagNumber(3)
  set update(SatOpUpdate v) {
    setField(3, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasUpdate() => $_has(2);
  @$pb.TagNumber(3)
  void clearUpdate() => clearField(3);
  @$pb.TagNumber(3)
  SatOpUpdate ensureUpdate() => $_ensure(2);

  @$pb.TagNumber(4)
  SatOpInsert get insert => $_getN(3);
  @$pb.TagNumber(4)
  set insert(SatOpInsert v) {
    setField(4, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasInsert() => $_has(3);
  @$pb.TagNumber(4)
  void clearInsert() => clearField(4);
  @$pb.TagNumber(4)
  SatOpInsert ensureInsert() => $_ensure(3);

  @$pb.TagNumber(5)
  SatOpDelete get delete => $_getN(4);
  @$pb.TagNumber(5)
  set delete(SatOpDelete v) {
    setField(5, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasDelete() => $_has(4);
  @$pb.TagNumber(5)
  void clearDelete() => clearField(5);
  @$pb.TagNumber(5)
  SatOpDelete ensureDelete() => $_ensure(4);

  @$pb.TagNumber(6)
  SatOpMigrate get migrate => $_getN(5);
  @$pb.TagNumber(6)
  set migrate(SatOpMigrate v) {
    setField(6, v);
  }

  @$pb.TagNumber(6)
  $core.bool hasMigrate() => $_has(5);
  @$pb.TagNumber(6)
  void clearMigrate() => clearField(6);
  @$pb.TagNumber(6)
  SatOpMigrate ensureMigrate() => $_ensure(5);

  @$pb.TagNumber(7)
  SatOpCompensation get compensation => $_getN(6);
  @$pb.TagNumber(7)
  set compensation(SatOpCompensation v) {
    setField(7, v);
  }

  @$pb.TagNumber(7)
  $core.bool hasCompensation() => $_has(6);
  @$pb.TagNumber(7)
  void clearCompensation() => clearField(7);
  @$pb.TagNumber(7)
  SatOpCompensation ensureCompensation() => $_ensure(6);

  @$pb.TagNumber(8)
  SatOpGone get gone => $_getN(7);
  @$pb.TagNumber(8)
  set gone(SatOpGone v) {
    setField(8, v);
  }

  @$pb.TagNumber(8)
  $core.bool hasGone() => $_has(7);
  @$pb.TagNumber(8)
  void clearGone() => clearField(8);
  @$pb.TagNumber(8)
  SatOpGone ensureGone() => $_ensure(7);

  @$pb.TagNumber(9)
  SatOpAdditionalBegin get additionalBegin => $_getN(8);
  @$pb.TagNumber(9)
  set additionalBegin(SatOpAdditionalBegin v) {
    setField(9, v);
  }

  @$pb.TagNumber(9)
  $core.bool hasAdditionalBegin() => $_has(8);
  @$pb.TagNumber(9)
  void clearAdditionalBegin() => clearField(9);
  @$pb.TagNumber(9)
  SatOpAdditionalBegin ensureAdditionalBegin() => $_ensure(8);

  @$pb.TagNumber(10)
  SatOpAdditionalCommit get additionalCommit => $_getN(9);
  @$pb.TagNumber(10)
  set additionalCommit(SatOpAdditionalCommit v) {
    setField(10, v);
  }

  @$pb.TagNumber(10)
  $core.bool hasAdditionalCommit() => $_has(9);
  @$pb.TagNumber(10)
  void clearAdditionalCommit() => clearField(10);
  @$pb.TagNumber(10)
  SatOpAdditionalCommit ensureAdditionalCommit() => $_ensure(9);
}

/// (Producer) Replication message that indicates transaction boundaries
/// should be only send as payload in the SatTransOp message
class SatOpBegin extends $pb.GeneratedMessage {
  factory SatOpBegin({
    $fixnum.Int64? commitTimestamp,
    $core.List<$core.int>? lsn,
    $core.String? origin,
    $core.bool? isMigration,
    $fixnum.Int64? additionalDataRef,
    $fixnum.Int64? transactionId,
  }) {
    final $result = create();
    if (commitTimestamp != null) {
      $result.commitTimestamp = commitTimestamp;
    }
    if (lsn != null) {
      $result.lsn = lsn;
    }
    if (origin != null) {
      $result.origin = origin;
    }
    if (isMigration != null) {
      $result.isMigration = isMigration;
    }
    if (additionalDataRef != null) {
      $result.additionalDataRef = additionalDataRef;
    }
    if (transactionId != null) {
      $result.transactionId = transactionId;
    }
    return $result;
  }
  SatOpBegin._() : super();
  factory SatOpBegin.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatOpBegin.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatOpBegin',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'commitTimestamp', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'lsn', $pb.PbFieldType.OY)
    ..aOS(4, _omitFieldNames ? '' : 'origin')
    ..aOB(5, _omitFieldNames ? '' : 'isMigration')
    ..a<$fixnum.Int64>(
        6, _omitFieldNames ? '' : 'additionalDataRef', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        7, _omitFieldNames ? '' : 'transactionId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatOpBegin clone() => SatOpBegin()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatOpBegin copyWith(void Function(SatOpBegin) updates) =>
      super.copyWith((message) => updates(message as SatOpBegin)) as SatOpBegin;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatOpBegin create() => SatOpBegin._();
  SatOpBegin createEmptyInstance() => create();
  static $pb.PbList<SatOpBegin> createRepeated() => $pb.PbList<SatOpBegin>();
  @$core.pragma('dart2js:noInline')
  static SatOpBegin getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SatOpBegin>(create);
  static SatOpBegin? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get commitTimestamp => $_getI64(0);
  @$pb.TagNumber(1)
  set commitTimestamp($fixnum.Int64 v) {
    $_setInt64(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasCommitTimestamp() => $_has(0);
  @$pb.TagNumber(1)
  void clearCommitTimestamp() => clearField(1);

  /// Lsn position that points to first data segment of transaction in the
  /// WAL
  @$pb.TagNumber(3)
  $core.List<$core.int> get lsn => $_getN(1);
  @$pb.TagNumber(3)
  set lsn($core.List<$core.int> v) {
    $_setBytes(1, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasLsn() => $_has(1);
  @$pb.TagNumber(3)
  void clearLsn() => clearField(3);

  /// Globally unique id of the source that transaction originated from. For
  /// data coming from Satellite this field is ignored. For data coming from
  /// Electric this field can be used to deduce if the incoming transaction
  /// originated on this Satellite instance or not.
  @$pb.TagNumber(4)
  $core.String get origin => $_getSZ(2);
  @$pb.TagNumber(4)
  set origin($core.String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasOrigin() => $_has(2);
  @$pb.TagNumber(4)
  void clearOrigin() => clearField(4);

  /// does this transaction contain ddl statements?
  @$pb.TagNumber(5)
  $core.bool get isMigration => $_getBF(3);
  @$pb.TagNumber(5)
  set isMigration($core.bool v) {
    $_setBool(3, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasIsMigration() => $_has(3);
  @$pb.TagNumber(5)
  void clearIsMigration() => clearField(5);

  /// *
  ///  If not 0, a transient reference for additional data pseudo-transaction
  ///  that will be sent at a later point in the stream. It may be shared by multiple transactions
  ///  sent by the server at the same time, because this additional data will be queried at the same
  ///  time. Duplicated on SatOpCommit.
  @$pb.TagNumber(6)
  $fixnum.Int64 get additionalDataRef => $_getI64(4);
  @$pb.TagNumber(6)
  set additionalDataRef($fixnum.Int64 v) {
    $_setInt64(4, v);
  }

  @$pb.TagNumber(6)
  $core.bool hasAdditionalDataRef() => $_has(4);
  @$pb.TagNumber(6)
  void clearAdditionalDataRef() => clearField(6);

  /// * Unique transaction ID, sent only by the server. No guarantees of monotonicity.
  @$pb.TagNumber(7)
  $fixnum.Int64 get transactionId => $_getI64(5);
  @$pb.TagNumber(7)
  set transactionId($fixnum.Int64 v) {
    $_setInt64(5, v);
  }

  @$pb.TagNumber(7)
  $core.bool hasTransactionId() => $_has(5);
  @$pb.TagNumber(7)
  void clearTransactionId() => clearField(7);
}

/// (Producer) Replication message that indicates a transaction boundary for additional data that existed on the server
/// but the client can now see
class SatOpAdditionalBegin extends $pb.GeneratedMessage {
  factory SatOpAdditionalBegin({
    $fixnum.Int64? ref,
  }) {
    final $result = create();
    if (ref != null) {
      $result.ref = ref;
    }
    return $result;
  }
  SatOpAdditionalBegin._() : super();
  factory SatOpAdditionalBegin.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatOpAdditionalBegin.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatOpAdditionalBegin',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'ref', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatOpAdditionalBegin clone() =>
      SatOpAdditionalBegin()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatOpAdditionalBegin copyWith(void Function(SatOpAdditionalBegin) updates) =>
      super.copyWith((message) => updates(message as SatOpAdditionalBegin))
          as SatOpAdditionalBegin;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatOpAdditionalBegin create() => SatOpAdditionalBegin._();
  SatOpAdditionalBegin createEmptyInstance() => create();
  static $pb.PbList<SatOpAdditionalBegin> createRepeated() =>
      $pb.PbList<SatOpAdditionalBegin>();
  @$core.pragma('dart2js:noInline')
  static SatOpAdditionalBegin getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SatOpAdditionalBegin>(create);
  static SatOpAdditionalBegin? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get ref => $_getI64(0);
  @$pb.TagNumber(1)
  set ref($fixnum.Int64 v) {
    $_setInt64(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasRef() => $_has(0);
  @$pb.TagNumber(1)
  void clearRef() => clearField(1);
}

/// (Producer) Replication message that indicates transaction boundaries
/// should be only send as payload in the SatTransOp message
class SatOpCommit extends $pb.GeneratedMessage {
  factory SatOpCommit({
    $fixnum.Int64? commitTimestamp,
    $core.List<$core.int>? lsn,
    $fixnum.Int64? additionalDataRef,
    $fixnum.Int64? transactionId,
  }) {
    final $result = create();
    if (commitTimestamp != null) {
      $result.commitTimestamp = commitTimestamp;
    }
    if (lsn != null) {
      $result.lsn = lsn;
    }
    if (additionalDataRef != null) {
      $result.additionalDataRef = additionalDataRef;
    }
    if (transactionId != null) {
      $result.transactionId = transactionId;
    }
    return $result;
  }
  SatOpCommit._() : super();
  factory SatOpCommit.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatOpCommit.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatOpCommit',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'commitTimestamp', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'lsn', $pb.PbFieldType.OY)
    ..a<$fixnum.Int64>(
        4, _omitFieldNames ? '' : 'additionalDataRef', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        5, _omitFieldNames ? '' : 'transactionId', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatOpCommit clone() => SatOpCommit()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatOpCommit copyWith(void Function(SatOpCommit) updates) =>
      super.copyWith((message) => updates(message as SatOpCommit))
          as SatOpCommit;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatOpCommit create() => SatOpCommit._();
  SatOpCommit createEmptyInstance() => create();
  static $pb.PbList<SatOpCommit> createRepeated() => $pb.PbList<SatOpCommit>();
  @$core.pragma('dart2js:noInline')
  static SatOpCommit getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SatOpCommit>(create);
  static SatOpCommit? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get commitTimestamp => $_getI64(0);
  @$pb.TagNumber(1)
  set commitTimestamp($fixnum.Int64 v) {
    $_setInt64(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasCommitTimestamp() => $_has(0);
  @$pb.TagNumber(1)
  void clearCommitTimestamp() => clearField(1);

  @$pb.TagNumber(3)
  $core.List<$core.int> get lsn => $_getN(1);
  @$pb.TagNumber(3)
  set lsn($core.List<$core.int> v) {
    $_setBytes(1, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasLsn() => $_has(1);
  @$pb.TagNumber(3)
  void clearLsn() => clearField(3);

  /// * If not 0, a transient reference for additional data pseudo-transaction
  /// that will be sent at a later point in the stream. It may be shared by multiple transactions
  /// sent by the server at the same time, because this additional data will be queried at the same
  /// time. Duplicated on SatOpBegin.
  @$pb.TagNumber(4)
  $fixnum.Int64 get additionalDataRef => $_getI64(2);
  @$pb.TagNumber(4)
  set additionalDataRef($fixnum.Int64 v) {
    $_setInt64(2, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasAdditionalDataRef() => $_has(2);
  @$pb.TagNumber(4)
  void clearAdditionalDataRef() => clearField(4);

  /// * Unique transaction ID, sent only by the server. No guarantees of monotonicity.
  @$pb.TagNumber(5)
  $fixnum.Int64 get transactionId => $_getI64(3);
  @$pb.TagNumber(5)
  set transactionId($fixnum.Int64 v) {
    $_setInt64(3, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasTransactionId() => $_has(3);
  @$pb.TagNumber(5)
  void clearTransactionId() => clearField(5);
}

class SatOpAdditionalCommit extends $pb.GeneratedMessage {
  factory SatOpAdditionalCommit({
    $fixnum.Int64? ref,
  }) {
    final $result = create();
    if (ref != null) {
      $result.ref = ref;
    }
    return $result;
  }
  SatOpAdditionalCommit._() : super();
  factory SatOpAdditionalCommit.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatOpAdditionalCommit.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatOpAdditionalCommit',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'ref', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatOpAdditionalCommit clone() =>
      SatOpAdditionalCommit()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatOpAdditionalCommit copyWith(
          void Function(SatOpAdditionalCommit) updates) =>
      super.copyWith((message) => updates(message as SatOpAdditionalCommit))
          as SatOpAdditionalCommit;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatOpAdditionalCommit create() => SatOpAdditionalCommit._();
  SatOpAdditionalCommit createEmptyInstance() => create();
  static $pb.PbList<SatOpAdditionalCommit> createRepeated() =>
      $pb.PbList<SatOpAdditionalCommit>();
  @$core.pragma('dart2js:noInline')
  static SatOpAdditionalCommit getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SatOpAdditionalCommit>(create);
  static SatOpAdditionalCommit? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get ref => $_getI64(0);
  @$pb.TagNumber(1)
  set ref($fixnum.Int64 v) {
    $_setInt64(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasRef() => $_has(0);
  @$pb.TagNumber(1)
  void clearRef() => clearField(1);
}

/// (Producer) Data manipulation message, that only should be part of the
/// SatTransOp message
class SatOpInsert extends $pb.GeneratedMessage {
  factory SatOpInsert({
    $core.int? relationId,
    SatOpRow? rowData,
    $core.Iterable<$core.String>? tags,
  }) {
    final $result = create();
    if (relationId != null) {
      $result.relationId = relationId;
    }
    if (rowData != null) {
      $result.rowData = rowData;
    }
    if (tags != null) {
      $result.tags.addAll(tags);
    }
    return $result;
  }
  SatOpInsert._() : super();
  factory SatOpInsert.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatOpInsert.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatOpInsert',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'relationId', $pb.PbFieldType.OU3)
    ..aOM<SatOpRow>(2, _omitFieldNames ? '' : 'rowData',
        subBuilder: SatOpRow.create)
    ..pPS(3, _omitFieldNames ? '' : 'tags')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatOpInsert clone() => SatOpInsert()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatOpInsert copyWith(void Function(SatOpInsert) updates) =>
      super.copyWith((message) => updates(message as SatOpInsert))
          as SatOpInsert;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatOpInsert create() => SatOpInsert._();
  SatOpInsert createEmptyInstance() => create();
  static $pb.PbList<SatOpInsert> createRepeated() => $pb.PbList<SatOpInsert>();
  @$core.pragma('dart2js:noInline')
  static SatOpInsert getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SatOpInsert>(create);
  static SatOpInsert? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get relationId => $_getIZ(0);
  @$pb.TagNumber(1)
  set relationId($core.int v) {
    $_setUnsignedInt32(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasRelationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRelationId() => clearField(1);

  @$pb.TagNumber(2)
  SatOpRow get rowData => $_getN(1);
  @$pb.TagNumber(2)
  set rowData(SatOpRow v) {
    setField(2, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasRowData() => $_has(1);
  @$pb.TagNumber(2)
  void clearRowData() => clearField(2);
  @$pb.TagNumber(2)
  SatOpRow ensureRowData() => $_ensure(1);

  /// dependency information
  @$pb.TagNumber(3)
  $core.List<$core.String> get tags => $_getList(2);
}

/// (Producer) Data manipulation message, that only should be part of the
/// SatTransOp message
class SatOpUpdate extends $pb.GeneratedMessage {
  factory SatOpUpdate({
    $core.int? relationId,
    SatOpRow? rowData,
    SatOpRow? oldRowData,
    $core.Iterable<$core.String>? tags,
  }) {
    final $result = create();
    if (relationId != null) {
      $result.relationId = relationId;
    }
    if (rowData != null) {
      $result.rowData = rowData;
    }
    if (oldRowData != null) {
      $result.oldRowData = oldRowData;
    }
    if (tags != null) {
      $result.tags.addAll(tags);
    }
    return $result;
  }
  SatOpUpdate._() : super();
  factory SatOpUpdate.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatOpUpdate.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatOpUpdate',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'relationId', $pb.PbFieldType.OU3)
    ..aOM<SatOpRow>(2, _omitFieldNames ? '' : 'rowData',
        subBuilder: SatOpRow.create)
    ..aOM<SatOpRow>(3, _omitFieldNames ? '' : 'oldRowData',
        subBuilder: SatOpRow.create)
    ..pPS(4, _omitFieldNames ? '' : 'tags')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatOpUpdate clone() => SatOpUpdate()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatOpUpdate copyWith(void Function(SatOpUpdate) updates) =>
      super.copyWith((message) => updates(message as SatOpUpdate))
          as SatOpUpdate;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatOpUpdate create() => SatOpUpdate._();
  SatOpUpdate createEmptyInstance() => create();
  static $pb.PbList<SatOpUpdate> createRepeated() => $pb.PbList<SatOpUpdate>();
  @$core.pragma('dart2js:noInline')
  static SatOpUpdate getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SatOpUpdate>(create);
  static SatOpUpdate? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get relationId => $_getIZ(0);
  @$pb.TagNumber(1)
  set relationId($core.int v) {
    $_setUnsignedInt32(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasRelationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRelationId() => clearField(1);

  @$pb.TagNumber(2)
  SatOpRow get rowData => $_getN(1);
  @$pb.TagNumber(2)
  set rowData(SatOpRow v) {
    setField(2, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasRowData() => $_has(1);
  @$pb.TagNumber(2)
  void clearRowData() => clearField(2);
  @$pb.TagNumber(2)
  SatOpRow ensureRowData() => $_ensure(1);

  @$pb.TagNumber(3)
  SatOpRow get oldRowData => $_getN(2);
  @$pb.TagNumber(3)
  set oldRowData(SatOpRow v) {
    setField(3, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasOldRowData() => $_has(2);
  @$pb.TagNumber(3)
  void clearOldRowData() => clearField(3);
  @$pb.TagNumber(3)
  SatOpRow ensureOldRowData() => $_ensure(2);

  /// dependency information
  @$pb.TagNumber(4)
  $core.List<$core.String> get tags => $_getList(3);
}

/// (Producer) Data manipulation message, that only should be part of the
/// SatTransOp message
class SatOpDelete extends $pb.GeneratedMessage {
  factory SatOpDelete({
    $core.int? relationId,
    SatOpRow? oldRowData,
    $core.Iterable<$core.String>? tags,
  }) {
    final $result = create();
    if (relationId != null) {
      $result.relationId = relationId;
    }
    if (oldRowData != null) {
      $result.oldRowData = oldRowData;
    }
    if (tags != null) {
      $result.tags.addAll(tags);
    }
    return $result;
  }
  SatOpDelete._() : super();
  factory SatOpDelete.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatOpDelete.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatOpDelete',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'relationId', $pb.PbFieldType.OU3)
    ..aOM<SatOpRow>(2, _omitFieldNames ? '' : 'oldRowData',
        subBuilder: SatOpRow.create)
    ..pPS(3, _omitFieldNames ? '' : 'tags')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatOpDelete clone() => SatOpDelete()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatOpDelete copyWith(void Function(SatOpDelete) updates) =>
      super.copyWith((message) => updates(message as SatOpDelete))
          as SatOpDelete;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatOpDelete create() => SatOpDelete._();
  SatOpDelete createEmptyInstance() => create();
  static $pb.PbList<SatOpDelete> createRepeated() => $pb.PbList<SatOpDelete>();
  @$core.pragma('dart2js:noInline')
  static SatOpDelete getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SatOpDelete>(create);
  static SatOpDelete? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get relationId => $_getIZ(0);
  @$pb.TagNumber(1)
  set relationId($core.int v) {
    $_setUnsignedInt32(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasRelationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRelationId() => clearField(1);

  @$pb.TagNumber(2)
  SatOpRow get oldRowData => $_getN(1);
  @$pb.TagNumber(2)
  set oldRowData(SatOpRow v) {
    setField(2, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasOldRowData() => $_has(1);
  @$pb.TagNumber(2)
  void clearOldRowData() => clearField(2);
  @$pb.TagNumber(2)
  SatOpRow ensureOldRowData() => $_ensure(1);

  /// dependency information
  @$pb.TagNumber(3)
  $core.List<$core.String> get tags => $_getList(2);
}

class SatOpCompensation extends $pb.GeneratedMessage {
  factory SatOpCompensation({
    $core.int? relationId,
    SatOpRow? pkData,
    $core.Iterable<$core.String>? tags,
  }) {
    final $result = create();
    if (relationId != null) {
      $result.relationId = relationId;
    }
    if (pkData != null) {
      $result.pkData = pkData;
    }
    if (tags != null) {
      $result.tags.addAll(tags);
    }
    return $result;
  }
  SatOpCompensation._() : super();
  factory SatOpCompensation.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatOpCompensation.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatOpCompensation',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'relationId', $pb.PbFieldType.OU3)
    ..aOM<SatOpRow>(2, _omitFieldNames ? '' : 'pkData',
        subBuilder: SatOpRow.create)
    ..pPS(4, _omitFieldNames ? '' : 'tags')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatOpCompensation clone() => SatOpCompensation()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatOpCompensation copyWith(void Function(SatOpCompensation) updates) =>
      super.copyWith((message) => updates(message as SatOpCompensation))
          as SatOpCompensation;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatOpCompensation create() => SatOpCompensation._();
  SatOpCompensation createEmptyInstance() => create();
  static $pb.PbList<SatOpCompensation> createRepeated() =>
      $pb.PbList<SatOpCompensation>();
  @$core.pragma('dart2js:noInline')
  static SatOpCompensation getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SatOpCompensation>(create);
  static SatOpCompensation? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get relationId => $_getIZ(0);
  @$pb.TagNumber(1)
  set relationId($core.int v) {
    $_setUnsignedInt32(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasRelationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRelationId() => clearField(1);

  @$pb.TagNumber(2)
  SatOpRow get pkData => $_getN(1);
  @$pb.TagNumber(2)
  set pkData(SatOpRow v) {
    setField(2, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasPkData() => $_has(1);
  @$pb.TagNumber(2)
  void clearPkData() => clearField(2);
  @$pb.TagNumber(2)
  SatOpRow ensurePkData() => $_ensure(1);

  /// dependency information
  @$pb.TagNumber(4)
  $core.List<$core.String> get tags => $_getList(2);
}

class SatOpGone extends $pb.GeneratedMessage {
  factory SatOpGone({
    $core.int? relationId,
    SatOpRow? pkData,
  }) {
    final $result = create();
    if (relationId != null) {
      $result.relationId = relationId;
    }
    if (pkData != null) {
      $result.pkData = pkData;
    }
    return $result;
  }
  SatOpGone._() : super();
  factory SatOpGone.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatOpGone.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatOpGone',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'relationId', $pb.PbFieldType.OU3)
    ..aOM<SatOpRow>(2, _omitFieldNames ? '' : 'pkData',
        subBuilder: SatOpRow.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatOpGone clone() => SatOpGone()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatOpGone copyWith(void Function(SatOpGone) updates) =>
      super.copyWith((message) => updates(message as SatOpGone)) as SatOpGone;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatOpGone create() => SatOpGone._();
  SatOpGone createEmptyInstance() => create();
  static $pb.PbList<SatOpGone> createRepeated() => $pb.PbList<SatOpGone>();
  @$core.pragma('dart2js:noInline')
  static SatOpGone getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SatOpGone>(create);
  static SatOpGone? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get relationId => $_getIZ(0);
  @$pb.TagNumber(1)
  set relationId($core.int v) {
    $_setUnsignedInt32(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasRelationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRelationId() => clearField(1);

  @$pb.TagNumber(2)
  SatOpRow get pkData => $_getN(1);
  @$pb.TagNumber(2)
  set pkData(SatOpRow v) {
    setField(2, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasPkData() => $_has(1);
  @$pb.TagNumber(2)
  void clearPkData() => clearField(2);
  @$pb.TagNumber(2)
  SatOpRow ensurePkData() => $_ensure(1);
}

/// Message that corresponds to the single row.
class SatOpRow extends $pb.GeneratedMessage {
  factory SatOpRow({
    $core.List<$core.int>? nullsBitmask,
    $core.Iterable<$core.List<$core.int>>? values,
  }) {
    final $result = create();
    if (nullsBitmask != null) {
      $result.nullsBitmask = nullsBitmask;
    }
    if (values != null) {
      $result.values.addAll(values);
    }
    return $result;
  }
  SatOpRow._() : super();
  factory SatOpRow.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatOpRow.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatOpRow',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'nullsBitmask', $pb.PbFieldType.OY)
    ..p<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'values', $pb.PbFieldType.PY)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatOpRow clone() => SatOpRow()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatOpRow copyWith(void Function(SatOpRow) updates) =>
      super.copyWith((message) => updates(message as SatOpRow)) as SatOpRow;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatOpRow create() => SatOpRow._();
  SatOpRow createEmptyInstance() => create();
  static $pb.PbList<SatOpRow> createRepeated() => $pb.PbList<SatOpRow>();
  @$core.pragma('dart2js:noInline')
  static SatOpRow getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SatOpRow>(create);
  static SatOpRow? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get nullsBitmask => $_getN(0);
  @$pb.TagNumber(1)
  set nullsBitmask($core.List<$core.int> v) {
    $_setBytes(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasNullsBitmask() => $_has(0);
  @$pb.TagNumber(1)
  void clearNullsBitmask() => clearField(1);

  /// values may contain binaries with size 0 for NULLs and empty values
  /// check nulls_bitmask to differentiate between the two
  @$pb.TagNumber(2)
  $core.List<$core.List<$core.int>> get values => $_getList(1);
}

class SatOpMigrate_Stmt extends $pb.GeneratedMessage {
  factory SatOpMigrate_Stmt({
    SatOpMigrate_Type? type,
    $core.String? sql,
  }) {
    final $result = create();
    if (type != null) {
      $result.type = type;
    }
    if (sql != null) {
      $result.sql = sql;
    }
    return $result;
  }
  SatOpMigrate_Stmt._() : super();
  factory SatOpMigrate_Stmt.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatOpMigrate_Stmt.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatOpMigrate.Stmt',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..e<SatOpMigrate_Type>(1, _omitFieldNames ? '' : 'type', $pb.PbFieldType.OE,
        defaultOrMaker: SatOpMigrate_Type.CREATE_TABLE,
        valueOf: SatOpMigrate_Type.valueOf,
        enumValues: SatOpMigrate_Type.values)
    ..aOS(2, _omitFieldNames ? '' : 'sql')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatOpMigrate_Stmt clone() => SatOpMigrate_Stmt()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatOpMigrate_Stmt copyWith(void Function(SatOpMigrate_Stmt) updates) =>
      super.copyWith((message) => updates(message as SatOpMigrate_Stmt))
          as SatOpMigrate_Stmt;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatOpMigrate_Stmt create() => SatOpMigrate_Stmt._();
  SatOpMigrate_Stmt createEmptyInstance() => create();
  static $pb.PbList<SatOpMigrate_Stmt> createRepeated() =>
      $pb.PbList<SatOpMigrate_Stmt>();
  @$core.pragma('dart2js:noInline')
  static SatOpMigrate_Stmt getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SatOpMigrate_Stmt>(create);
  static SatOpMigrate_Stmt? _defaultInstance;

  @$pb.TagNumber(1)
  SatOpMigrate_Type get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(SatOpMigrate_Type v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get sql => $_getSZ(1);
  @$pb.TagNumber(2)
  set sql($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasSql() => $_has(1);
  @$pb.TagNumber(2)
  void clearSql() => clearField(2);
}

class SatOpMigrate_PgColumnType extends $pb.GeneratedMessage {
  factory SatOpMigrate_PgColumnType({
    $core.String? name,
    $core.Iterable<$core.int>? array,
    $core.Iterable<$core.int>? size,
  }) {
    final $result = create();
    if (name != null) {
      $result.name = name;
    }
    if (array != null) {
      $result.array.addAll(array);
    }
    if (size != null) {
      $result.size.addAll(size);
    }
    return $result;
  }
  SatOpMigrate_PgColumnType._() : super();
  factory SatOpMigrate_PgColumnType.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatOpMigrate_PgColumnType.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatOpMigrate.PgColumnType',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..p<$core.int>(2, _omitFieldNames ? '' : 'array', $pb.PbFieldType.K3)
    ..p<$core.int>(3, _omitFieldNames ? '' : 'size', $pb.PbFieldType.K3)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatOpMigrate_PgColumnType clone() =>
      SatOpMigrate_PgColumnType()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatOpMigrate_PgColumnType copyWith(
          void Function(SatOpMigrate_PgColumnType) updates) =>
      super.copyWith((message) => updates(message as SatOpMigrate_PgColumnType))
          as SatOpMigrate_PgColumnType;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatOpMigrate_PgColumnType create() => SatOpMigrate_PgColumnType._();
  SatOpMigrate_PgColumnType createEmptyInstance() => create();
  static $pb.PbList<SatOpMigrate_PgColumnType> createRepeated() =>
      $pb.PbList<SatOpMigrate_PgColumnType>();
  @$core.pragma('dart2js:noInline')
  static SatOpMigrate_PgColumnType getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SatOpMigrate_PgColumnType>(create);
  static SatOpMigrate_PgColumnType? _defaultInstance;

  /// the pg type name, e.g. int4, char
  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);

  /// array dimensions, or [] for scalar types
  /// e.g. for a column declared as int4[][3], size = [-1, 3]
  @$pb.TagNumber(2)
  $core.List<$core.int> get array => $_getList(1);

  /// any size information, e.g. for varchar(SIZE) or [] for no size
  @$pb.TagNumber(3)
  $core.List<$core.int> get size => $_getList(2);
}

class SatOpMigrate_Column extends $pb.GeneratedMessage {
  factory SatOpMigrate_Column({
    $core.String? name,
    $core.String? sqliteType,
    SatOpMigrate_PgColumnType? pgType,
  }) {
    final $result = create();
    if (name != null) {
      $result.name = name;
    }
    if (sqliteType != null) {
      $result.sqliteType = sqliteType;
    }
    if (pgType != null) {
      $result.pgType = pgType;
    }
    return $result;
  }
  SatOpMigrate_Column._() : super();
  factory SatOpMigrate_Column.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatOpMigrate_Column.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatOpMigrate.Column',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'sqliteType')
    ..aOM<SatOpMigrate_PgColumnType>(3, _omitFieldNames ? '' : 'pgType',
        subBuilder: SatOpMigrate_PgColumnType.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatOpMigrate_Column clone() => SatOpMigrate_Column()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatOpMigrate_Column copyWith(void Function(SatOpMigrate_Column) updates) =>
      super.copyWith((message) => updates(message as SatOpMigrate_Column))
          as SatOpMigrate_Column;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatOpMigrate_Column create() => SatOpMigrate_Column._();
  SatOpMigrate_Column createEmptyInstance() => create();
  static $pb.PbList<SatOpMigrate_Column> createRepeated() =>
      $pb.PbList<SatOpMigrate_Column>();
  @$core.pragma('dart2js:noInline')
  static SatOpMigrate_Column getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SatOpMigrate_Column>(create);
  static SatOpMigrate_Column? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get sqliteType => $_getSZ(1);
  @$pb.TagNumber(2)
  set sqliteType($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasSqliteType() => $_has(1);
  @$pb.TagNumber(2)
  void clearSqliteType() => clearField(2);

  @$pb.TagNumber(3)
  SatOpMigrate_PgColumnType get pgType => $_getN(2);
  @$pb.TagNumber(3)
  set pgType(SatOpMigrate_PgColumnType v) {
    setField(3, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasPgType() => $_has(2);
  @$pb.TagNumber(3)
  void clearPgType() => clearField(3);
  @$pb.TagNumber(3)
  SatOpMigrate_PgColumnType ensurePgType() => $_ensure(2);
}

class SatOpMigrate_ForeignKey extends $pb.GeneratedMessage {
  factory SatOpMigrate_ForeignKey({
    $core.Iterable<$core.String>? fkCols,
    $core.String? pkTable,
    $core.Iterable<$core.String>? pkCols,
  }) {
    final $result = create();
    if (fkCols != null) {
      $result.fkCols.addAll(fkCols);
    }
    if (pkTable != null) {
      $result.pkTable = pkTable;
    }
    if (pkCols != null) {
      $result.pkCols.addAll(pkCols);
    }
    return $result;
  }
  SatOpMigrate_ForeignKey._() : super();
  factory SatOpMigrate_ForeignKey.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatOpMigrate_ForeignKey.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatOpMigrate.ForeignKey',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'fkCols')
    ..aOS(2, _omitFieldNames ? '' : 'pkTable')
    ..pPS(3, _omitFieldNames ? '' : 'pkCols')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatOpMigrate_ForeignKey clone() =>
      SatOpMigrate_ForeignKey()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatOpMigrate_ForeignKey copyWith(
          void Function(SatOpMigrate_ForeignKey) updates) =>
      super.copyWith((message) => updates(message as SatOpMigrate_ForeignKey))
          as SatOpMigrate_ForeignKey;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatOpMigrate_ForeignKey create() => SatOpMigrate_ForeignKey._();
  SatOpMigrate_ForeignKey createEmptyInstance() => create();
  static $pb.PbList<SatOpMigrate_ForeignKey> createRepeated() =>
      $pb.PbList<SatOpMigrate_ForeignKey>();
  @$core.pragma('dart2js:noInline')
  static SatOpMigrate_ForeignKey getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SatOpMigrate_ForeignKey>(create);
  static SatOpMigrate_ForeignKey? _defaultInstance;

  /// the columns in the child table that point to the parent
  @$pb.TagNumber(1)
  $core.List<$core.String> get fkCols => $_getList(0);

  /// the parent table
  @$pb.TagNumber(2)
  $core.String get pkTable => $_getSZ(1);
  @$pb.TagNumber(2)
  set pkTable($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasPkTable() => $_has(1);
  @$pb.TagNumber(2)
  void clearPkTable() => clearField(2);

  /// the cols in the parent table
  @$pb.TagNumber(3)
  $core.List<$core.String> get pkCols => $_getList(2);
}

class SatOpMigrate_Table extends $pb.GeneratedMessage {
  factory SatOpMigrate_Table({
    $core.String? name,
    $core.Iterable<SatOpMigrate_Column>? columns,
    $core.Iterable<SatOpMigrate_ForeignKey>? fks,
    $core.Iterable<$core.String>? pks,
  }) {
    final $result = create();
    if (name != null) {
      $result.name = name;
    }
    if (columns != null) {
      $result.columns.addAll(columns);
    }
    if (fks != null) {
      $result.fks.addAll(fks);
    }
    if (pks != null) {
      $result.pks.addAll(pks);
    }
    return $result;
  }
  SatOpMigrate_Table._() : super();
  factory SatOpMigrate_Table.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatOpMigrate_Table.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatOpMigrate.Table',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..pc<SatOpMigrate_Column>(
        2, _omitFieldNames ? '' : 'columns', $pb.PbFieldType.PM,
        subBuilder: SatOpMigrate_Column.create)
    ..pc<SatOpMigrate_ForeignKey>(
        3, _omitFieldNames ? '' : 'fks', $pb.PbFieldType.PM,
        subBuilder: SatOpMigrate_ForeignKey.create)
    ..pPS(4, _omitFieldNames ? '' : 'pks')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatOpMigrate_Table clone() => SatOpMigrate_Table()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatOpMigrate_Table copyWith(void Function(SatOpMigrate_Table) updates) =>
      super.copyWith((message) => updates(message as SatOpMigrate_Table))
          as SatOpMigrate_Table;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatOpMigrate_Table create() => SatOpMigrate_Table._();
  SatOpMigrate_Table createEmptyInstance() => create();
  static $pb.PbList<SatOpMigrate_Table> createRepeated() =>
      $pb.PbList<SatOpMigrate_Table>();
  @$core.pragma('dart2js:noInline')
  static SatOpMigrate_Table getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SatOpMigrate_Table>(create);
  static SatOpMigrate_Table? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<SatOpMigrate_Column> get columns => $_getList(1);

  @$pb.TagNumber(3)
  $core.List<SatOpMigrate_ForeignKey> get fks => $_getList(2);

  @$pb.TagNumber(4)
  $core.List<$core.String> get pks => $_getList(3);
}

///  A migration message, originating in Postgres, captured via event triggers,
///  propagated to electric, converted from postgres to the equivalent sqlite
///  statement and inserted into the replication stream
///
///  Each migration message includes the sql strings to execute on the satellite
///  client as well as metadata information about the resulting structure of the
///  changed tables.
class SatOpMigrate extends $pb.GeneratedMessage {
  factory SatOpMigrate({
    $core.String? version,
    $core.Iterable<SatOpMigrate_Stmt>? stmts,
    SatOpMigrate_Table? table,
  }) {
    final $result = create();
    if (version != null) {
      $result.version = version;
    }
    if (stmts != null) {
      $result.stmts.addAll(stmts);
    }
    if (table != null) {
      $result.table = table;
    }
    return $result;
  }
  SatOpMigrate._() : super();
  factory SatOpMigrate.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatOpMigrate.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatOpMigrate',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'version')
    ..pc<SatOpMigrate_Stmt>(
        2, _omitFieldNames ? '' : 'stmts', $pb.PbFieldType.PM,
        subBuilder: SatOpMigrate_Stmt.create)
    ..aOM<SatOpMigrate_Table>(3, _omitFieldNames ? '' : 'table',
        subBuilder: SatOpMigrate_Table.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatOpMigrate clone() => SatOpMigrate()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatOpMigrate copyWith(void Function(SatOpMigrate) updates) =>
      super.copyWith((message) => updates(message as SatOpMigrate))
          as SatOpMigrate;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatOpMigrate create() => SatOpMigrate._();
  SatOpMigrate createEmptyInstance() => create();
  static $pb.PbList<SatOpMigrate> createRepeated() =>
      $pb.PbList<SatOpMigrate>();
  @$core.pragma('dart2js:noInline')
  static SatOpMigrate getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SatOpMigrate>(create);
  static SatOpMigrate? _defaultInstance;

  /// the migration version as specified by the developer and put into
  /// the postgresql migration as an electric function call
  @$pb.TagNumber(1)
  $core.String get version => $_getSZ(0);
  @$pb.TagNumber(1)
  set version($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasVersion() => $_has(0);
  @$pb.TagNumber(1)
  void clearVersion() => clearField(1);

  /// a list of sql ddl statements to apply, converted from the pg originals
  /// The migration machinery converts an `ALTER TABLE action1, action2, action3;`
  /// query into a set of 3: `ALTER TABLE action1; ALTER TABLE action2,` etc
  /// so we need to support 1+ statements for every migration event.
  @$pb.TagNumber(2)
  $core.List<SatOpMigrate_Stmt> get stmts => $_getList(1);

  /// The resulting table definition after applying these migrations
  /// (a DDL statement can only affect one table at a time).
  @$pb.TagNumber(3)
  SatOpMigrate_Table get table => $_getN(2);
  @$pb.TagNumber(3)
  set table(SatOpMigrate_Table v) {
    setField(3, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasTable() => $_has(2);
  @$pb.TagNumber(3)
  void clearTable() => clearField(3);
  @$pb.TagNumber(3)
  SatOpMigrate_Table ensureTable() => $_ensure(2);
}

/// (Consumer) Request for new subscriptions
class SatSubsReq extends $pb.GeneratedMessage {
  factory SatSubsReq({
    $core.String? subscriptionId,
    $core.Iterable<SatShapeReq>? shapeRequests,
  }) {
    final $result = create();
    if (subscriptionId != null) {
      $result.subscriptionId = subscriptionId;
    }
    if (shapeRequests != null) {
      $result.shapeRequests.addAll(shapeRequests);
    }
    return $result;
  }
  SatSubsReq._() : super();
  factory SatSubsReq.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatSubsReq.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatSubsReq',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'subscriptionId')
    ..pc<SatShapeReq>(
        2, _omitFieldNames ? '' : 'shapeRequests', $pb.PbFieldType.PM,
        subBuilder: SatShapeReq.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatSubsReq clone() => SatSubsReq()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatSubsReq copyWith(void Function(SatSubsReq) updates) =>
      super.copyWith((message) => updates(message as SatSubsReq)) as SatSubsReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatSubsReq create() => SatSubsReq._();
  SatSubsReq createEmptyInstance() => create();
  static $pb.PbList<SatSubsReq> createRepeated() => $pb.PbList<SatSubsReq>();
  @$core.pragma('dart2js:noInline')
  static SatSubsReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SatSubsReq>(create);
  static SatSubsReq? _defaultInstance;

  /// a client-generated identifier to track the subscription
  @$pb.TagNumber(1)
  $core.String get subscriptionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set subscriptionId($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasSubscriptionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSubscriptionId() => clearField(1);

  /// Shape requests
  @$pb.TagNumber(2)
  $core.List<SatShapeReq> get shapeRequests => $_getList(1);
}

/// Shape request error
class SatSubsResp_SatSubsError_ShapeReqError extends $pb.GeneratedMessage {
  factory SatSubsResp_SatSubsError_ShapeReqError({
    SatSubsResp_SatSubsError_ShapeReqError_Code? code,
    $core.String? message,
    $core.String? requestId,
  }) {
    final $result = create();
    if (code != null) {
      $result.code = code;
    }
    if (message != null) {
      $result.message = message;
    }
    if (requestId != null) {
      $result.requestId = requestId;
    }
    return $result;
  }
  SatSubsResp_SatSubsError_ShapeReqError._() : super();
  factory SatSubsResp_SatSubsError_ShapeReqError.fromBuffer(
          $core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatSubsResp_SatSubsError_ShapeReqError.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatSubsResp.SatSubsError.ShapeReqError',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..e<SatSubsResp_SatSubsError_ShapeReqError_Code>(
        1, _omitFieldNames ? '' : 'code', $pb.PbFieldType.OE,
        defaultOrMaker:
            SatSubsResp_SatSubsError_ShapeReqError_Code.CODE_UNSPECIFIED,
        valueOf: SatSubsResp_SatSubsError_ShapeReqError_Code.valueOf,
        enumValues: SatSubsResp_SatSubsError_ShapeReqError_Code.values)
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOS(3, _omitFieldNames ? '' : 'requestId')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatSubsResp_SatSubsError_ShapeReqError clone() =>
      SatSubsResp_SatSubsError_ShapeReqError()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatSubsResp_SatSubsError_ShapeReqError copyWith(
          void Function(SatSubsResp_SatSubsError_ShapeReqError) updates) =>
      super.copyWith((message) =>
              updates(message as SatSubsResp_SatSubsError_ShapeReqError))
          as SatSubsResp_SatSubsError_ShapeReqError;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatSubsResp_SatSubsError_ShapeReqError create() =>
      SatSubsResp_SatSubsError_ShapeReqError._();
  SatSubsResp_SatSubsError_ShapeReqError createEmptyInstance() => create();
  static $pb.PbList<SatSubsResp_SatSubsError_ShapeReqError> createRepeated() =>
      $pb.PbList<SatSubsResp_SatSubsError_ShapeReqError>();
  @$core.pragma('dart2js:noInline')
  static SatSubsResp_SatSubsError_ShapeReqError getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
          SatSubsResp_SatSubsError_ShapeReqError>(create);
  static SatSubsResp_SatSubsError_ShapeReqError? _defaultInstance;

  /// error code
  @$pb.TagNumber(1)
  SatSubsResp_SatSubsError_ShapeReqError_Code get code => $_getN(0);
  @$pb.TagNumber(1)
  set code(SatSubsResp_SatSubsError_ShapeReqError_Code v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => clearField(1);

  /// a human-readable description of the error
  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => clearField(2);

  /// the shape request identifier that this error refers to
  @$pb.TagNumber(3)
  $core.String get requestId => $_getSZ(2);
  @$pb.TagNumber(3)
  set requestId($core.String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasRequestId() => $_has(2);
  @$pb.TagNumber(3)
  void clearRequestId() => clearField(3);
}

/// Error message returned by the Producer when it encounters
/// an error handling subscription request
class SatSubsResp_SatSubsError extends $pb.GeneratedMessage {
  factory SatSubsResp_SatSubsError({
    SatSubsResp_SatSubsError_Code? code,
    $core.String? message,
    $core.Iterable<SatSubsResp_SatSubsError_ShapeReqError>? shapeRequestError,
  }) {
    final $result = create();
    if (code != null) {
      $result.code = code;
    }
    if (message != null) {
      $result.message = message;
    }
    if (shapeRequestError != null) {
      $result.shapeRequestError.addAll(shapeRequestError);
    }
    return $result;
  }
  SatSubsResp_SatSubsError._() : super();
  factory SatSubsResp_SatSubsError.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatSubsResp_SatSubsError.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatSubsResp.SatSubsError',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..e<SatSubsResp_SatSubsError_Code>(
        2, _omitFieldNames ? '' : 'code', $pb.PbFieldType.OE,
        defaultOrMaker: SatSubsResp_SatSubsError_Code.CODE_UNSPECIFIED,
        valueOf: SatSubsResp_SatSubsError_Code.valueOf,
        enumValues: SatSubsResp_SatSubsError_Code.values)
    ..aOS(3, _omitFieldNames ? '' : 'message')
    ..pc<SatSubsResp_SatSubsError_ShapeReqError>(
        4, _omitFieldNames ? '' : 'shapeRequestError', $pb.PbFieldType.PM,
        subBuilder: SatSubsResp_SatSubsError_ShapeReqError.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatSubsResp_SatSubsError clone() =>
      SatSubsResp_SatSubsError()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatSubsResp_SatSubsError copyWith(
          void Function(SatSubsResp_SatSubsError) updates) =>
      super.copyWith((message) => updates(message as SatSubsResp_SatSubsError))
          as SatSubsResp_SatSubsError;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatSubsResp_SatSubsError create() => SatSubsResp_SatSubsError._();
  SatSubsResp_SatSubsError createEmptyInstance() => create();
  static $pb.PbList<SatSubsResp_SatSubsError> createRepeated() =>
      $pb.PbList<SatSubsResp_SatSubsError>();
  @$core.pragma('dart2js:noInline')
  static SatSubsResp_SatSubsError getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SatSubsResp_SatSubsError>(create);
  static SatSubsResp_SatSubsError? _defaultInstance;

  /// error code
  @$pb.TagNumber(2)
  SatSubsResp_SatSubsError_Code get code => $_getN(0);
  @$pb.TagNumber(2)
  set code(SatSubsResp_SatSubsError_Code v) {
    setField(2, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(2)
  void clearCode() => clearField(2);

  /// A human-readable description of the error
  @$pb.TagNumber(3)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(3)
  set message($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(3)
  void clearMessage() => clearField(3);

  /// Details of the shape request error
  @$pb.TagNumber(4)
  $core.List<SatSubsResp_SatSubsError_ShapeReqError> get shapeRequestError =>
      $_getList(2);
}

/// (Producer) Response for a subscription request
class SatSubsResp extends $pb.GeneratedMessage {
  factory SatSubsResp({
    $core.String? subscriptionId,
    SatSubsResp_SatSubsError? err,
  }) {
    final $result = create();
    if (subscriptionId != null) {
      $result.subscriptionId = subscriptionId;
    }
    if (err != null) {
      $result.err = err;
    }
    return $result;
  }
  SatSubsResp._() : super();
  factory SatSubsResp.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatSubsResp.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatSubsResp',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'subscriptionId')
    ..aOM<SatSubsResp_SatSubsError>(2, _omitFieldNames ? '' : 'err',
        subBuilder: SatSubsResp_SatSubsError.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatSubsResp clone() => SatSubsResp()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatSubsResp copyWith(void Function(SatSubsResp) updates) =>
      super.copyWith((message) => updates(message as SatSubsResp))
          as SatSubsResp;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatSubsResp create() => SatSubsResp._();
  SatSubsResp createEmptyInstance() => create();
  static $pb.PbList<SatSubsResp> createRepeated() => $pb.PbList<SatSubsResp>();
  @$core.pragma('dart2js:noInline')
  static SatSubsResp getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SatSubsResp>(create);
  static SatSubsResp? _defaultInstance;

  /// identifier of the subscription this response refers to
  @$pb.TagNumber(1)
  $core.String get subscriptionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set subscriptionId($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasSubscriptionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSubscriptionId() => clearField(1);

  /// the error details if the request failed
  @$pb.TagNumber(2)
  SatSubsResp_SatSubsError get err => $_getN(1);
  @$pb.TagNumber(2)
  set err(SatSubsResp_SatSubsError v) {
    setField(2, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasErr() => $_has(1);
  @$pb.TagNumber(2)
  void clearErr() => clearField(2);
  @$pb.TagNumber(2)
  SatSubsResp_SatSubsError ensureErr() => $_ensure(1);
}

/// (Consumer) Request to cancel subscriptions
class SatUnsubsReq extends $pb.GeneratedMessage {
  factory SatUnsubsReq({
    $core.Iterable<$core.String>? subscriptionIds,
  }) {
    final $result = create();
    if (subscriptionIds != null) {
      $result.subscriptionIds.addAll(subscriptionIds);
    }
    return $result;
  }
  SatUnsubsReq._() : super();
  factory SatUnsubsReq.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatUnsubsReq.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatUnsubsReq',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'subscriptionIds')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatUnsubsReq clone() => SatUnsubsReq()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatUnsubsReq copyWith(void Function(SatUnsubsReq) updates) =>
      super.copyWith((message) => updates(message as SatUnsubsReq))
          as SatUnsubsReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatUnsubsReq create() => SatUnsubsReq._();
  SatUnsubsReq createEmptyInstance() => create();
  static $pb.PbList<SatUnsubsReq> createRepeated() =>
      $pb.PbList<SatUnsubsReq>();
  @$core.pragma('dart2js:noInline')
  static SatUnsubsReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SatUnsubsReq>(create);
  static SatUnsubsReq? _defaultInstance;

  /// Identifiers of the subscriptions
  @$pb.TagNumber(1)
  $core.List<$core.String> get subscriptionIds => $_getList(0);
}

/// (Producer) Acknowledgment that the subscriptions were cancelled
class SatUnsubsResp extends $pb.GeneratedMessage {
  factory SatUnsubsResp() => create();
  SatUnsubsResp._() : super();
  factory SatUnsubsResp.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatUnsubsResp.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatUnsubsResp',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatUnsubsResp clone() => SatUnsubsResp()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatUnsubsResp copyWith(void Function(SatUnsubsResp) updates) =>
      super.copyWith((message) => updates(message as SatUnsubsResp))
          as SatUnsubsResp;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatUnsubsResp create() => SatUnsubsResp._();
  SatUnsubsResp createEmptyInstance() => create();
  static $pb.PbList<SatUnsubsResp> createRepeated() =>
      $pb.PbList<SatUnsubsResp>();
  @$core.pragma('dart2js:noInline')
  static SatUnsubsResp getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SatUnsubsResp>(create);
  static SatUnsubsResp? _defaultInstance;
}

/// Shape request
class SatShapeReq extends $pb.GeneratedMessage {
  factory SatShapeReq({
    $core.String? requestId,
    SatShapeDef? shapeDefinition,
  }) {
    final $result = create();
    if (requestId != null) {
      $result.requestId = requestId;
    }
    if (shapeDefinition != null) {
      $result.shapeDefinition = shapeDefinition;
    }
    return $result;
  }
  SatShapeReq._() : super();
  factory SatShapeReq.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatShapeReq.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatShapeReq',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
    ..aOM<SatShapeDef>(2, _omitFieldNames ? '' : 'shapeDefinition',
        subBuilder: SatShapeDef.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatShapeReq clone() => SatShapeReq()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatShapeReq copyWith(void Function(SatShapeReq) updates) =>
      super.copyWith((message) => updates(message as SatShapeReq))
          as SatShapeReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatShapeReq create() => SatShapeReq._();
  SatShapeReq createEmptyInstance() => create();
  static $pb.PbList<SatShapeReq> createRepeated() => $pb.PbList<SatShapeReq>();
  @$core.pragma('dart2js:noInline')
  static SatShapeReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SatShapeReq>(create);
  static SatShapeReq? _defaultInstance;

  /// Identifier of the request
  @$pb.TagNumber(1)
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => clearField(1);

  /// The shape definition
  @$pb.TagNumber(2)
  SatShapeDef get shapeDefinition => $_getN(1);
  @$pb.TagNumber(2)
  set shapeDefinition(SatShapeDef v) {
    setField(2, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasShapeDefinition() => $_has(1);
  @$pb.TagNumber(2)
  void clearShapeDefinition() => clearField(2);
  @$pb.TagNumber(2)
  SatShapeDef ensureShapeDefinition() => $_ensure(1);
}

class SatShapeDef_Relation extends $pb.GeneratedMessage {
  factory SatShapeDef_Relation({
    $core.Iterable<$core.String>? foreignKey,
    SatShapeDef_Select? select,
  }) {
    final $result = create();
    if (foreignKey != null) {
      $result.foreignKey.addAll(foreignKey);
    }
    if (select != null) {
      $result.select = select;
    }
    return $result;
  }
  SatShapeDef_Relation._() : super();
  factory SatShapeDef_Relation.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatShapeDef_Relation.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatShapeDef.Relation',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'foreignKey')
    ..aOM<SatShapeDef_Select>(2, _omitFieldNames ? '' : 'select',
        subBuilder: SatShapeDef_Select.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatShapeDef_Relation clone() =>
      SatShapeDef_Relation()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatShapeDef_Relation copyWith(void Function(SatShapeDef_Relation) updates) =>
      super.copyWith((message) => updates(message as SatShapeDef_Relation))
          as SatShapeDef_Relation;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatShapeDef_Relation create() => SatShapeDef_Relation._();
  SatShapeDef_Relation createEmptyInstance() => create();
  static $pb.PbList<SatShapeDef_Relation> createRepeated() =>
      $pb.PbList<SatShapeDef_Relation>();
  @$core.pragma('dart2js:noInline')
  static SatShapeDef_Relation getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SatShapeDef_Relation>(create);
  static SatShapeDef_Relation? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.String> get foreignKey => $_getList(0);

  @$pb.TagNumber(2)
  SatShapeDef_Select get select => $_getN(1);
  @$pb.TagNumber(2)
  set select(SatShapeDef_Select v) {
    setField(2, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasSelect() => $_has(1);
  @$pb.TagNumber(2)
  void clearSelect() => clearField(2);
  @$pb.TagNumber(2)
  SatShapeDef_Select ensureSelect() => $_ensure(1);
}

/// Select structure
class SatShapeDef_Select extends $pb.GeneratedMessage {
  factory SatShapeDef_Select({
    $core.String? tablename,
    $core.String? where,
    $core.Iterable<SatShapeDef_Relation>? include,
  }) {
    final $result = create();
    if (tablename != null) {
      $result.tablename = tablename;
    }
    if (where != null) {
      $result.where = where;
    }
    if (include != null) {
      $result.include.addAll(include);
    }
    return $result;
  }
  SatShapeDef_Select._() : super();
  factory SatShapeDef_Select.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatShapeDef_Select.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatShapeDef.Select',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'tablename')
    ..aOS(2, _omitFieldNames ? '' : 'where')
    ..pc<SatShapeDef_Relation>(
        3, _omitFieldNames ? '' : 'include', $pb.PbFieldType.PM,
        subBuilder: SatShapeDef_Relation.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatShapeDef_Select clone() => SatShapeDef_Select()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatShapeDef_Select copyWith(void Function(SatShapeDef_Select) updates) =>
      super.copyWith((message) => updates(message as SatShapeDef_Select))
          as SatShapeDef_Select;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatShapeDef_Select create() => SatShapeDef_Select._();
  SatShapeDef_Select createEmptyInstance() => create();
  static $pb.PbList<SatShapeDef_Select> createRepeated() =>
      $pb.PbList<SatShapeDef_Select>();
  @$core.pragma('dart2js:noInline')
  static SatShapeDef_Select getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SatShapeDef_Select>(create);
  static SatShapeDef_Select? _defaultInstance;

  /// table name for this select
  @$pb.TagNumber(1)
  $core.String get tablename => $_getSZ(0);
  @$pb.TagNumber(1)
  set tablename($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasTablename() => $_has(0);
  @$pb.TagNumber(1)
  void clearTablename() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get where => $_getSZ(1);
  @$pb.TagNumber(2)
  set where($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasWhere() => $_has(1);
  @$pb.TagNumber(2)
  void clearWhere() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<SatShapeDef_Relation> get include => $_getList(2);
}

/// Top-level structure of a shape definition
class SatShapeDef extends $pb.GeneratedMessage {
  factory SatShapeDef({
    $core.Iterable<SatShapeDef_Select>? selects,
  }) {
    final $result = create();
    if (selects != null) {
      $result.selects.addAll(selects);
    }
    return $result;
  }
  SatShapeDef._() : super();
  factory SatShapeDef.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatShapeDef.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatShapeDef',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..pc<SatShapeDef_Select>(
        1, _omitFieldNames ? '' : 'selects', $pb.PbFieldType.PM,
        subBuilder: SatShapeDef_Select.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatShapeDef clone() => SatShapeDef()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatShapeDef copyWith(void Function(SatShapeDef) updates) =>
      super.copyWith((message) => updates(message as SatShapeDef))
          as SatShapeDef;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatShapeDef create() => SatShapeDef._();
  SatShapeDef createEmptyInstance() => create();
  static $pb.PbList<SatShapeDef> createRepeated() => $pb.PbList<SatShapeDef>();
  @$core.pragma('dart2js:noInline')
  static SatShapeDef getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SatShapeDef>(create);
  static SatShapeDef? _defaultInstance;

  /// Selects for the Shape definition
  @$pb.TagNumber(1)
  $core.List<SatShapeDef_Select> get selects => $_getList(0);
}

/// Shape request error
class SatSubsDataError_ShapeReqError extends $pb.GeneratedMessage {
  factory SatSubsDataError_ShapeReqError({
    SatSubsDataError_ShapeReqError_Code? code,
    $core.String? message,
    $core.String? requestId,
  }) {
    final $result = create();
    if (code != null) {
      $result.code = code;
    }
    if (message != null) {
      $result.message = message;
    }
    if (requestId != null) {
      $result.requestId = requestId;
    }
    return $result;
  }
  SatSubsDataError_ShapeReqError._() : super();
  factory SatSubsDataError_ShapeReqError.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatSubsDataError_ShapeReqError.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatSubsDataError.ShapeReqError',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..e<SatSubsDataError_ShapeReqError_Code>(
        1, _omitFieldNames ? '' : 'code', $pb.PbFieldType.OE,
        defaultOrMaker: SatSubsDataError_ShapeReqError_Code.CODE_UNSPECIFIED,
        valueOf: SatSubsDataError_ShapeReqError_Code.valueOf,
        enumValues: SatSubsDataError_ShapeReqError_Code.values)
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOS(3, _omitFieldNames ? '' : 'requestId')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatSubsDataError_ShapeReqError clone() =>
      SatSubsDataError_ShapeReqError()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatSubsDataError_ShapeReqError copyWith(
          void Function(SatSubsDataError_ShapeReqError) updates) =>
      super.copyWith(
              (message) => updates(message as SatSubsDataError_ShapeReqError))
          as SatSubsDataError_ShapeReqError;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatSubsDataError_ShapeReqError create() =>
      SatSubsDataError_ShapeReqError._();
  SatSubsDataError_ShapeReqError createEmptyInstance() => create();
  static $pb.PbList<SatSubsDataError_ShapeReqError> createRepeated() =>
      $pb.PbList<SatSubsDataError_ShapeReqError>();
  @$core.pragma('dart2js:noInline')
  static SatSubsDataError_ShapeReqError getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SatSubsDataError_ShapeReqError>(create);
  static SatSubsDataError_ShapeReqError? _defaultInstance;

  /// error code
  @$pb.TagNumber(1)
  SatSubsDataError_ShapeReqError_Code get code => $_getN(0);
  @$pb.TagNumber(1)
  set code(SatSubsDataError_ShapeReqError_Code v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => clearField(1);

  /// a human-readable description of the error
  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => clearField(2);

  /// the shape request identifier that this error refers to
  @$pb.TagNumber(3)
  $core.String get requestId => $_getSZ(2);
  @$pb.TagNumber(3)
  set requestId($core.String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasRequestId() => $_has(2);
  @$pb.TagNumber(3)
  void clearRequestId() => clearField(3);
}

/// Error message returned by the Producer when it encounters
/// an error handling subscription data
class SatSubsDataError extends $pb.GeneratedMessage {
  factory SatSubsDataError({
    SatSubsDataError_Code? code,
    $core.String? message,
    $core.String? subscriptionId,
    $core.Iterable<SatSubsDataError_ShapeReqError>? shapeRequestError,
  }) {
    final $result = create();
    if (code != null) {
      $result.code = code;
    }
    if (message != null) {
      $result.message = message;
    }
    if (subscriptionId != null) {
      $result.subscriptionId = subscriptionId;
    }
    if (shapeRequestError != null) {
      $result.shapeRequestError.addAll(shapeRequestError);
    }
    return $result;
  }
  SatSubsDataError._() : super();
  factory SatSubsDataError.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatSubsDataError.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatSubsDataError',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..e<SatSubsDataError_Code>(
        1, _omitFieldNames ? '' : 'code', $pb.PbFieldType.OE,
        defaultOrMaker: SatSubsDataError_Code.CODE_UNSPECIFIED,
        valueOf: SatSubsDataError_Code.valueOf,
        enumValues: SatSubsDataError_Code.values)
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOS(3, _omitFieldNames ? '' : 'subscriptionId')
    ..pc<SatSubsDataError_ShapeReqError>(
        4, _omitFieldNames ? '' : 'shapeRequestError', $pb.PbFieldType.PM,
        subBuilder: SatSubsDataError_ShapeReqError.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatSubsDataError clone() => SatSubsDataError()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatSubsDataError copyWith(void Function(SatSubsDataError) updates) =>
      super.copyWith((message) => updates(message as SatSubsDataError))
          as SatSubsDataError;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatSubsDataError create() => SatSubsDataError._();
  SatSubsDataError createEmptyInstance() => create();
  static $pb.PbList<SatSubsDataError> createRepeated() =>
      $pb.PbList<SatSubsDataError>();
  @$core.pragma('dart2js:noInline')
  static SatSubsDataError getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SatSubsDataError>(create);
  static SatSubsDataError? _defaultInstance;

  /// error code
  @$pb.TagNumber(1)
  SatSubsDataError_Code get code => $_getN(0);
  @$pb.TagNumber(1)
  set code(SatSubsDataError_Code v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => clearField(1);

  /// A human-readable description of the error
  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => clearField(2);

  /// Subscription identifier this error refers to
  @$pb.TagNumber(3)
  $core.String get subscriptionId => $_getSZ(2);
  @$pb.TagNumber(3)
  set subscriptionId($core.String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasSubscriptionId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSubscriptionId() => clearField(3);

  /// Details of the shape request error
  @$pb.TagNumber(4)
  $core.List<SatSubsDataError_ShapeReqError> get shapeRequestError =>
      $_getList(3);
}

/// Begin delimiter for the incoming subscription data
class SatSubsDataBegin extends $pb.GeneratedMessage {
  factory SatSubsDataBegin({
    $core.String? subscriptionId,
    $core.List<$core.int>? lsn,
  }) {
    final $result = create();
    if (subscriptionId != null) {
      $result.subscriptionId = subscriptionId;
    }
    if (lsn != null) {
      $result.lsn = lsn;
    }
    return $result;
  }
  SatSubsDataBegin._() : super();
  factory SatSubsDataBegin.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatSubsDataBegin.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatSubsDataBegin',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'subscriptionId')
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'lsn', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatSubsDataBegin clone() => SatSubsDataBegin()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatSubsDataBegin copyWith(void Function(SatSubsDataBegin) updates) =>
      super.copyWith((message) => updates(message as SatSubsDataBegin))
          as SatSubsDataBegin;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatSubsDataBegin create() => SatSubsDataBegin._();
  SatSubsDataBegin createEmptyInstance() => create();
  static $pb.PbList<SatSubsDataBegin> createRepeated() =>
      $pb.PbList<SatSubsDataBegin>();
  @$core.pragma('dart2js:noInline')
  static SatSubsDataBegin getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SatSubsDataBegin>(create);
  static SatSubsDataBegin? _defaultInstance;

  /// Identifier of the subscription
  @$pb.TagNumber(1)
  $core.String get subscriptionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set subscriptionId($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasSubscriptionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSubscriptionId() => clearField(1);

  /// LSN at which this data is being sent. May be a duplicate of a transaction that was sent immediately before.
  @$pb.TagNumber(2)
  $core.List<$core.int> get lsn => $_getN(1);
  @$pb.TagNumber(2)
  set lsn($core.List<$core.int> v) {
    $_setBytes(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasLsn() => $_has(1);
  @$pb.TagNumber(2)
  void clearLsn() => clearField(2);
}

/// End delimiter for the incoming subscription data
class SatSubsDataEnd extends $pb.GeneratedMessage {
  factory SatSubsDataEnd() => create();
  SatSubsDataEnd._() : super();
  factory SatSubsDataEnd.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatSubsDataEnd.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatSubsDataEnd',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatSubsDataEnd clone() => SatSubsDataEnd()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatSubsDataEnd copyWith(void Function(SatSubsDataEnd) updates) =>
      super.copyWith((message) => updates(message as SatSubsDataEnd))
          as SatSubsDataEnd;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatSubsDataEnd create() => SatSubsDataEnd._();
  SatSubsDataEnd createEmptyInstance() => create();
  static $pb.PbList<SatSubsDataEnd> createRepeated() =>
      $pb.PbList<SatSubsDataEnd>();
  @$core.pragma('dart2js:noInline')
  static SatSubsDataEnd getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SatSubsDataEnd>(create);
  static SatSubsDataEnd? _defaultInstance;
}

/// Begin delimiter for the initial shape data
class SatShapeDataBegin extends $pb.GeneratedMessage {
  factory SatShapeDataBegin({
    $core.String? requestId,
    $core.String? uuid,
  }) {
    final $result = create();
    if (requestId != null) {
      $result.requestId = requestId;
    }
    if (uuid != null) {
      $result.uuid = uuid;
    }
    return $result;
  }
  SatShapeDataBegin._() : super();
  factory SatShapeDataBegin.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatShapeDataBegin.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatShapeDataBegin',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
    ..aOS(2, _omitFieldNames ? '' : 'uuid')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatShapeDataBegin clone() => SatShapeDataBegin()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatShapeDataBegin copyWith(void Function(SatShapeDataBegin) updates) =>
      super.copyWith((message) => updates(message as SatShapeDataBegin))
          as SatShapeDataBegin;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatShapeDataBegin create() => SatShapeDataBegin._();
  SatShapeDataBegin createEmptyInstance() => create();
  static $pb.PbList<SatShapeDataBegin> createRepeated() =>
      $pb.PbList<SatShapeDataBegin>();
  @$core.pragma('dart2js:noInline')
  static SatShapeDataBegin getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SatShapeDataBegin>(create);
  static SatShapeDataBegin? _defaultInstance;

  /// Identifier of the request
  @$pb.TagNumber(1)
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => clearField(1);

  /// The UUID of the shape on the Producer
  @$pb.TagNumber(2)
  $core.String get uuid => $_getSZ(1);
  @$pb.TagNumber(2)
  set uuid($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasUuid() => $_has(1);
  @$pb.TagNumber(2)
  void clearUuid() => clearField(2);
}

/// End delimiter for the initial shape data
class SatShapeDataEnd extends $pb.GeneratedMessage {
  factory SatShapeDataEnd() => create();
  SatShapeDataEnd._() : super();
  factory SatShapeDataEnd.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatShapeDataEnd.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatShapeDataEnd',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatShapeDataEnd clone() => SatShapeDataEnd()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatShapeDataEnd copyWith(void Function(SatShapeDataEnd) updates) =>
      super.copyWith((message) => updates(message as SatShapeDataEnd))
          as SatShapeDataEnd;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatShapeDataEnd create() => SatShapeDataEnd._();
  SatShapeDataEnd createEmptyInstance() => create();
  static $pb.PbList<SatShapeDataEnd> createRepeated() =>
      $pb.PbList<SatShapeDataEnd>();
  @$core.pragma('dart2js:noInline')
  static SatShapeDataEnd getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SatShapeDataEnd>(create);
  static SatShapeDataEnd? _defaultInstance;
}

class RootApi {
  $pb.RpcClient _client;
  RootApi(this._client);

  $async.Future<SatAuthResp> authenticate(
          $pb.ClientContext? ctx, SatAuthReq request) =>
      _client.invoke<SatAuthResp>(
          ctx, 'Root', 'authenticate', request, SatAuthResp());
  $async.Future<SatInStartReplicationResp> startReplication(
          $pb.ClientContext? ctx, SatInStartReplicationReq request) =>
      _client.invoke<SatInStartReplicationResp>(ctx, 'Root', 'startReplication',
          request, SatInStartReplicationResp());
  $async.Future<SatInStopReplicationResp> stopReplication(
          $pb.ClientContext? ctx, SatInStopReplicationReq request) =>
      _client.invoke<SatInStopReplicationResp>(
          ctx, 'Root', 'stopReplication', request, SatInStopReplicationResp());
  $async.Future<SatSubsResp> subscribe(
          $pb.ClientContext? ctx, SatSubsReq request) =>
      _client.invoke<SatSubsResp>(
          ctx, 'Root', 'subscribe', request, SatSubsResp());
  $async.Future<SatUnsubsResp> unsubscribe(
          $pb.ClientContext? ctx, SatUnsubsReq request) =>
      _client.invoke<SatUnsubsResp>(
          ctx, 'Root', 'unsubscribe', request, SatUnsubsResp());
}

class ClientRootApi {
  $pb.RpcClient _client;
  ClientRootApi(this._client);

  $async.Future<SatInStartReplicationResp> startReplication(
          $pb.ClientContext? ctx, SatInStartReplicationReq request) =>
      _client.invoke<SatInStartReplicationResp>(ctx, 'ClientRoot',
          'startReplication', request, SatInStartReplicationResp());
  $async.Future<SatInStopReplicationResp> stopReplication(
          $pb.ClientContext? ctx, SatInStopReplicationReq request) =>
      _client.invoke<SatInStopReplicationResp>(ctx, 'ClientRoot',
          'stopReplication', request, SatInStopReplicationResp());
}

const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
