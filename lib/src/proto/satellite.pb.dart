//
//  Generated code. Do not modify.
//  source: proto/satellite.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'satellite.pbenum.dart';

export 'satellite.pbenum.dart';

class SatPingReq extends $pb.GeneratedMessage {
  factory SatPingReq() => create();
  SatPingReq._() : super();
  factory SatPingReq.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatPingReq.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatPingReq',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'Electric.Satellite.v1_4'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatPingReq clone() => SatPingReq()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatPingReq copyWith(void Function(SatPingReq) updates) =>
      super.copyWith((message) => updates(message as SatPingReq)) as SatPingReq;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatPingReq create() => SatPingReq._();
  SatPingReq createEmptyInstance() => create();
  static $pb.PbList<SatPingReq> createRepeated() => $pb.PbList<SatPingReq>();
  @$core.pragma('dart2js:noInline')
  static SatPingReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SatPingReq>(create);
  static SatPingReq? _defaultInstance;
}

class SatPingResp extends $pb.GeneratedMessage {
  factory SatPingResp() => create();
  SatPingResp._() : super();
  factory SatPingResp.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatPingResp.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatPingResp',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'Electric.Satellite.v1_4'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'lsn', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatPingResp clone() => SatPingResp()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatPingResp copyWith(void Function(SatPingResp) updates) =>
      super.copyWith((message) => updates(message as SatPingResp))
          as SatPingResp;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatPingResp create() => SatPingResp._();
  SatPingResp createEmptyInstance() => create();
  static $pb.PbList<SatPingResp> createRepeated() => $pb.PbList<SatPingResp>();
  @$core.pragma('dart2js:noInline')
  static SatPingResp getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SatPingResp>(create);
  static SatPingResp? _defaultInstance;

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
}

class SatAuthHeaderPair extends $pb.GeneratedMessage {
  factory SatAuthHeaderPair() => create();
  SatAuthHeaderPair._() : super();
  factory SatAuthHeaderPair.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatAuthHeaderPair.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatAuthHeaderPair',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'Electric.Satellite.v1_4'),
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

class SatAuthReq extends $pb.GeneratedMessage {
  factory SatAuthReq() => create();
  SatAuthReq._() : super();
  factory SatAuthReq.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatAuthReq.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatAuthReq',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'Electric.Satellite.v1_4'),
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

  @$pb.TagNumber(3)
  $core.List<SatAuthHeaderPair> get headers => $_getList(2);
}

class SatAuthResp extends $pb.GeneratedMessage {
  factory SatAuthResp() => create();
  SatAuthResp._() : super();
  factory SatAuthResp.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatAuthResp.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatAuthResp',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'Electric.Satellite.v1_4'),
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

  @$pb.TagNumber(3)
  $core.List<SatAuthHeaderPair> get headers => $_getList(1);
}

class SatErrorResp extends $pb.GeneratedMessage {
  factory SatErrorResp() => create();
  SatErrorResp._() : super();
  factory SatErrorResp.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatErrorResp.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatErrorResp',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'Electric.Satellite.v1_4'),
      createEmptyInstance: create)
    ..e<SatErrorResp_ErrorCode>(
        1, _omitFieldNames ? '' : 'errorType', $pb.PbFieldType.OE,
        defaultOrMaker: SatErrorResp_ErrorCode.INTERNAL,
        valueOf: SatErrorResp_ErrorCode.valueOf,
        enumValues: SatErrorResp_ErrorCode.values)
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
}

class SatInStartReplicationReq extends $pb.GeneratedMessage {
  factory SatInStartReplicationReq() => create();
  SatInStartReplicationReq._() : super();
  factory SatInStartReplicationReq.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatInStartReplicationReq.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatInStartReplicationReq',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'Electric.Satellite.v1_4'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'lsn', $pb.PbFieldType.OY)
    ..pc<SatInStartReplicationReq_Option>(
        2, _omitFieldNames ? '' : 'options', $pb.PbFieldType.KE,
        valueOf: SatInStartReplicationReq_Option.valueOf,
        enumValues: SatInStartReplicationReq_Option.values,
        defaultEnumValue: SatInStartReplicationReq_Option.NONE)
    ..a<$core.int>(
        3, _omitFieldNames ? '' : 'syncBatchSize', $pb.PbFieldType.O3)
    ..pPS(4, _omitFieldNames ? '' : 'subscriptionIds')
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

  @$pb.TagNumber(3)
  $core.int get syncBatchSize => $_getIZ(2);
  @$pb.TagNumber(3)
  set syncBatchSize($core.int v) {
    $_setSignedInt32(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasSyncBatchSize() => $_has(2);
  @$pb.TagNumber(3)
  void clearSyncBatchSize() => clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.String> get subscriptionIds => $_getList(3);
}

class SatInStartReplicationResp_ReplicationError extends $pb.GeneratedMessage {
  factory SatInStartReplicationResp_ReplicationError() => create();
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
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'Electric.Satellite.v1_4'),
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

class SatInStartReplicationResp extends $pb.GeneratedMessage {
  factory SatInStartReplicationResp() => create();
  SatInStartReplicationResp._() : super();
  factory SatInStartReplicationResp.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatInStartReplicationResp.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatInStartReplicationResp',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'Electric.Satellite.v1_4'),
      createEmptyInstance: create)
    ..aOM<SatInStartReplicationResp_ReplicationError>(
        1, _omitFieldNames ? '' : 'err',
        subBuilder: SatInStartReplicationResp_ReplicationError.create)
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
}

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
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'Electric.Satellite.v1_4'),
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
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'Electric.Satellite.v1_4'),
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
  factory SatRelationColumn() => create();
  SatRelationColumn._() : super();
  factory SatRelationColumn.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatRelationColumn.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatRelationColumn',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'Electric.Satellite.v1_4'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'type')
    ..aOB(3, _omitFieldNames ? '' : 'primaryKey', protoName: 'primaryKey')
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
}

class SatRelation extends $pb.GeneratedMessage {
  factory SatRelation() => create();
  SatRelation._() : super();
  factory SatRelation.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatRelation.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatRelation',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'Electric.Satellite.v1_4'),
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

class SatOpLog extends $pb.GeneratedMessage {
  factory SatOpLog() => create();
  SatOpLog._() : super();
  factory SatOpLog.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatOpLog.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatOpLog',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'Electric.Satellite.v1_4'),
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

enum SatTransOp_Op { begin, commit, update, insert, delete, migrate, notSet }

class SatTransOp extends $pb.GeneratedMessage {
  factory SatTransOp() => create();
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
    0: SatTransOp_Op.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatTransOp',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'Electric.Satellite.v1_4'),
      createEmptyInstance: create)
    ..oo(0, [1, 2, 3, 4, 5, 6])
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
}

class SatOpBegin extends $pb.GeneratedMessage {
  factory SatOpBegin() => create();
  SatOpBegin._() : super();
  factory SatOpBegin.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatOpBegin.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatOpBegin',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'Electric.Satellite.v1_4'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'commitTimestamp', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'transId')
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'lsn', $pb.PbFieldType.OY)
    ..aOS(4, _omitFieldNames ? '' : 'origin')
    ..aOB(5, _omitFieldNames ? '' : 'isMigration')
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

  @$pb.TagNumber(2)
  $core.String get transId => $_getSZ(1);
  @$pb.TagNumber(2)
  set transId($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasTransId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTransId() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get lsn => $_getN(2);
  @$pb.TagNumber(3)
  set lsn($core.List<$core.int> v) {
    $_setBytes(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasLsn() => $_has(2);
  @$pb.TagNumber(3)
  void clearLsn() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get origin => $_getSZ(3);
  @$pb.TagNumber(4)
  set origin($core.String v) {
    $_setString(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasOrigin() => $_has(3);
  @$pb.TagNumber(4)
  void clearOrigin() => clearField(4);

  @$pb.TagNumber(5)
  $core.bool get isMigration => $_getBF(4);
  @$pb.TagNumber(5)
  set isMigration($core.bool v) {
    $_setBool(4, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasIsMigration() => $_has(4);
  @$pb.TagNumber(5)
  void clearIsMigration() => clearField(5);
}

class SatOpCommit extends $pb.GeneratedMessage {
  factory SatOpCommit() => create();
  SatOpCommit._() : super();
  factory SatOpCommit.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatOpCommit.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatOpCommit',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'Electric.Satellite.v1_4'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'commitTimestamp', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'transId')
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'lsn', $pb.PbFieldType.OY)
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

  @$pb.TagNumber(2)
  $core.String get transId => $_getSZ(1);
  @$pb.TagNumber(2)
  set transId($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasTransId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTransId() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get lsn => $_getN(2);
  @$pb.TagNumber(3)
  set lsn($core.List<$core.int> v) {
    $_setBytes(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasLsn() => $_has(2);
  @$pb.TagNumber(3)
  void clearLsn() => clearField(3);
}

class SatOpInsert extends $pb.GeneratedMessage {
  factory SatOpInsert() => create();
  SatOpInsert._() : super();
  factory SatOpInsert.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatOpInsert.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatOpInsert',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'Electric.Satellite.v1_4'),
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

  @$pb.TagNumber(3)
  $core.List<$core.String> get tags => $_getList(2);
}

class SatOpUpdate extends $pb.GeneratedMessage {
  factory SatOpUpdate() => create();
  SatOpUpdate._() : super();
  factory SatOpUpdate.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatOpUpdate.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatOpUpdate',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'Electric.Satellite.v1_4'),
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

  @$pb.TagNumber(4)
  $core.List<$core.String> get tags => $_getList(3);
}

class SatOpDelete extends $pb.GeneratedMessage {
  factory SatOpDelete() => create();
  SatOpDelete._() : super();
  factory SatOpDelete.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatOpDelete.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatOpDelete',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'Electric.Satellite.v1_4'),
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

  @$pb.TagNumber(3)
  $core.List<$core.String> get tags => $_getList(2);
}

class SatMigrationNotification extends $pb.GeneratedMessage {
  factory SatMigrationNotification() => create();
  SatMigrationNotification._() : super();
  factory SatMigrationNotification.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatMigrationNotification.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatMigrationNotification',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'Electric.Satellite.v1_4'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'oldSchemaVersion')
    ..aOS(2, _omitFieldNames ? '' : 'oldSchemaHash')
    ..aOS(3, _omitFieldNames ? '' : 'newSchemaVersion')
    ..aOS(4, _omitFieldNames ? '' : 'newSchemaHash')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatMigrationNotification clone() =>
      SatMigrationNotification()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatMigrationNotification copyWith(
          void Function(SatMigrationNotification) updates) =>
      super.copyWith((message) => updates(message as SatMigrationNotification))
          as SatMigrationNotification;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatMigrationNotification create() => SatMigrationNotification._();
  SatMigrationNotification createEmptyInstance() => create();
  static $pb.PbList<SatMigrationNotification> createRepeated() =>
      $pb.PbList<SatMigrationNotification>();
  @$core.pragma('dart2js:noInline')
  static SatMigrationNotification getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SatMigrationNotification>(create);
  static SatMigrationNotification? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get oldSchemaVersion => $_getSZ(0);
  @$pb.TagNumber(1)
  set oldSchemaVersion($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasOldSchemaVersion() => $_has(0);
  @$pb.TagNumber(1)
  void clearOldSchemaVersion() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get oldSchemaHash => $_getSZ(1);
  @$pb.TagNumber(2)
  set oldSchemaHash($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasOldSchemaHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearOldSchemaHash() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get newSchemaVersion => $_getSZ(2);
  @$pb.TagNumber(3)
  set newSchemaVersion($core.String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasNewSchemaVersion() => $_has(2);
  @$pb.TagNumber(3)
  void clearNewSchemaVersion() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get newSchemaHash => $_getSZ(3);
  @$pb.TagNumber(4)
  set newSchemaHash($core.String v) {
    $_setString(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasNewSchemaHash() => $_has(3);
  @$pb.TagNumber(4)
  void clearNewSchemaHash() => clearField(4);
}

class SatOpRow extends $pb.GeneratedMessage {
  factory SatOpRow() => create();
  SatOpRow._() : super();
  factory SatOpRow.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatOpRow.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatOpRow',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'Electric.Satellite.v1_4'),
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

  @$pb.TagNumber(2)
  $core.List<$core.List<$core.int>> get values => $_getList(1);
}

class SatOpMigrate_Stmt extends $pb.GeneratedMessage {
  factory SatOpMigrate_Stmt() => create();
  SatOpMigrate_Stmt._() : super();
  factory SatOpMigrate_Stmt.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatOpMigrate_Stmt.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatOpMigrate.Stmt',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'Electric.Satellite.v1_4'),
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
  factory SatOpMigrate_PgColumnType() => create();
  SatOpMigrate_PgColumnType._() : super();
  factory SatOpMigrate_PgColumnType.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatOpMigrate_PgColumnType.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatOpMigrate.PgColumnType',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'Electric.Satellite.v1_4'),
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
  $core.List<$core.int> get array => $_getList(1);

  @$pb.TagNumber(3)
  $core.List<$core.int> get size => $_getList(2);
}

class SatOpMigrate_Column extends $pb.GeneratedMessage {
  factory SatOpMigrate_Column() => create();
  SatOpMigrate_Column._() : super();
  factory SatOpMigrate_Column.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatOpMigrate_Column.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatOpMigrate.Column',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'Electric.Satellite.v1_4'),
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
  factory SatOpMigrate_ForeignKey() => create();
  SatOpMigrate_ForeignKey._() : super();
  factory SatOpMigrate_ForeignKey.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatOpMigrate_ForeignKey.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatOpMigrate.ForeignKey',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'Electric.Satellite.v1_4'),
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

  @$pb.TagNumber(1)
  $core.List<$core.String> get fkCols => $_getList(0);

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

  @$pb.TagNumber(3)
  $core.List<$core.String> get pkCols => $_getList(2);
}

class SatOpMigrate_Table extends $pb.GeneratedMessage {
  factory SatOpMigrate_Table() => create();
  SatOpMigrate_Table._() : super();
  factory SatOpMigrate_Table.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatOpMigrate_Table.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatOpMigrate.Table',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'Electric.Satellite.v1_4'),
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

class SatOpMigrate extends $pb.GeneratedMessage {
  factory SatOpMigrate() => create();
  SatOpMigrate._() : super();
  factory SatOpMigrate.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatOpMigrate.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatOpMigrate',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'Electric.Satellite.v1_4'),
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

  @$pb.TagNumber(2)
  $core.List<SatOpMigrate_Stmt> get stmts => $_getList(1);

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

class SatSubsReq extends $pb.GeneratedMessage {
  factory SatSubsReq() => create();
  SatSubsReq._() : super();
  factory SatSubsReq.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatSubsReq.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatSubsReq',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'Electric.Satellite.v1_4'),
      createEmptyInstance: create)
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

  @$pb.TagNumber(2)
  $core.List<SatShapeReq> get shapeRequests => $_getList(0);
}

class SatSubsResp extends $pb.GeneratedMessage {
  factory SatSubsResp() => create();
  SatSubsResp._() : super();
  factory SatSubsResp.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatSubsResp.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatSubsResp',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'Electric.Satellite.v1_4'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'subscriptionId')
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
}

class SatUnsubsReq extends $pb.GeneratedMessage {
  factory SatUnsubsReq() => create();
  SatUnsubsReq._() : super();
  factory SatUnsubsReq.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatUnsubsReq.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatUnsubsReq',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'Electric.Satellite.v1_4'),
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

  @$pb.TagNumber(1)
  $core.List<$core.String> get subscriptionIds => $_getList(0);
}

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
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'Electric.Satellite.v1_4'),
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

class SatShapeReq extends $pb.GeneratedMessage {
  factory SatShapeReq() => create();
  SatShapeReq._() : super();
  factory SatShapeReq.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatShapeReq.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatShapeReq',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'Electric.Satellite.v1_4'),
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

class SatShapeDef_Select extends $pb.GeneratedMessage {
  factory SatShapeDef_Select() => create();
  SatShapeDef_Select._() : super();
  factory SatShapeDef_Select.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatShapeDef_Select.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatShapeDef.Select',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'Electric.Satellite.v1_4'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'tablename')
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
}

class SatShapeDef extends $pb.GeneratedMessage {
  factory SatShapeDef() => create();
  SatShapeDef._() : super();
  factory SatShapeDef.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatShapeDef.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatShapeDef',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'Electric.Satellite.v1_4'),
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

  @$pb.TagNumber(1)
  $core.List<SatShapeDef_Select> get selects => $_getList(0);
}

class SatSubsError_ShapeReqError extends $pb.GeneratedMessage {
  factory SatSubsError_ShapeReqError() => create();
  SatSubsError_ShapeReqError._() : super();
  factory SatSubsError_ShapeReqError.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatSubsError_ShapeReqError.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatSubsError.ShapeReqError',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'Electric.Satellite.v1_4'),
      createEmptyInstance: create)
    ..e<SatSubsError_ShapeReqError_Code>(
        1, _omitFieldNames ? '' : 'code', $pb.PbFieldType.OE,
        defaultOrMaker: SatSubsError_ShapeReqError_Code.CODE_UNSPECIFIED,
        valueOf: SatSubsError_ShapeReqError_Code.valueOf,
        enumValues: SatSubsError_ShapeReqError_Code.values)
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOS(3, _omitFieldNames ? '' : 'requestId')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatSubsError_ShapeReqError clone() =>
      SatSubsError_ShapeReqError()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatSubsError_ShapeReqError copyWith(
          void Function(SatSubsError_ShapeReqError) updates) =>
      super.copyWith(
              (message) => updates(message as SatSubsError_ShapeReqError))
          as SatSubsError_ShapeReqError;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatSubsError_ShapeReqError create() => SatSubsError_ShapeReqError._();
  SatSubsError_ShapeReqError createEmptyInstance() => create();
  static $pb.PbList<SatSubsError_ShapeReqError> createRepeated() =>
      $pb.PbList<SatSubsError_ShapeReqError>();
  @$core.pragma('dart2js:noInline')
  static SatSubsError_ShapeReqError getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SatSubsError_ShapeReqError>(create);
  static SatSubsError_ShapeReqError? _defaultInstance;

  @$pb.TagNumber(1)
  SatSubsError_ShapeReqError_Code get code => $_getN(0);
  @$pb.TagNumber(1)
  set code(SatSubsError_ShapeReqError_Code v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => clearField(1);

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

class SatSubsError extends $pb.GeneratedMessage {
  factory SatSubsError() => create();
  SatSubsError._() : super();
  factory SatSubsError.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatSubsError.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatSubsError',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'Electric.Satellite.v1_4'),
      createEmptyInstance: create)
    ..e<SatSubsError_Code>(1, _omitFieldNames ? '' : 'code', $pb.PbFieldType.OE,
        defaultOrMaker: SatSubsError_Code.CODE_UNSPECIFIED,
        valueOf: SatSubsError_Code.valueOf,
        enumValues: SatSubsError_Code.values)
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOS(3, _omitFieldNames ? '' : 'subscriptionId')
    ..pc<SatSubsError_ShapeReqError>(
        4, _omitFieldNames ? '' : 'shapeRequestError', $pb.PbFieldType.PM,
        subBuilder: SatSubsError_ShapeReqError.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatSubsError clone() => SatSubsError()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatSubsError copyWith(void Function(SatSubsError) updates) =>
      super.copyWith((message) => updates(message as SatSubsError))
          as SatSubsError;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatSubsError create() => SatSubsError._();
  SatSubsError createEmptyInstance() => create();
  static $pb.PbList<SatSubsError> createRepeated() =>
      $pb.PbList<SatSubsError>();
  @$core.pragma('dart2js:noInline')
  static SatSubsError getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SatSubsError>(create);
  static SatSubsError? _defaultInstance;

  @$pb.TagNumber(1)
  SatSubsError_Code get code => $_getN(0);
  @$pb.TagNumber(1)
  set code(SatSubsError_Code v) {
    setField(1, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => clearField(1);

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

  @$pb.TagNumber(4)
  $core.List<SatSubsError_ShapeReqError> get shapeRequestError => $_getList(3);
}

class SatSubsDataBegin extends $pb.GeneratedMessage {
  factory SatSubsDataBegin() => create();
  SatSubsDataBegin._() : super();
  factory SatSubsDataBegin.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatSubsDataBegin.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatSubsDataBegin',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'Electric.Satellite.v1_4'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'subscriptionId')
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
}

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
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'Electric.Satellite.v1_4'),
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

class SatShapeDataBegin extends $pb.GeneratedMessage {
  factory SatShapeDataBegin() => create();
  SatShapeDataBegin._() : super();
  factory SatShapeDataBegin.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatShapeDataBegin.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatShapeDataBegin',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'Electric.Satellite.v1_4'),
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
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'Electric.Satellite.v1_4'),
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

const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
