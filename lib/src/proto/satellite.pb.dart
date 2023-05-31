///
//  Generated code. Do not modify.
//  source: proto/satellite.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'satellite.pbenum.dart';

export 'satellite.pbenum.dart';

class SatPingReq extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'SatPingReq',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'Electric.Satellite.v1_3'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  SatPingReq._() : super();
  factory SatPingReq() => create();
  factory SatPingReq.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatPingReq.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatPingReq clone() => SatPingReq()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatPingReq copyWith(void Function(SatPingReq) updates) =>
      super.copyWith((message) => updates(message as SatPingReq))
          as SatPingReq; // ignore: deprecated_member_use
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
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'SatPingResp',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'Electric.Satellite.v1_3'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'lsn',
        $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  SatPingResp._() : super();
  factory SatPingResp({
    $core.List<$core.int>? lsn,
  }) {
    final _result = create();
    if (lsn != null) {
      _result.lsn = lsn;
    }
    return _result;
  }
  factory SatPingResp.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatPingResp.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatPingResp clone() => SatPingResp()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatPingResp copyWith(void Function(SatPingResp) updates) =>
      super.copyWith((message) => updates(message as SatPingResp))
          as SatPingResp; // ignore: deprecated_member_use
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
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'SatAuthHeaderPair',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'Electric.Satellite.v1_3'),
      createEmptyInstance: create)
    ..e<SatAuthHeader>(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'key',
        $pb.PbFieldType.OE,
        defaultOrMaker: SatAuthHeader.UNSPECIFIED,
        valueOf: SatAuthHeader.valueOf,
        enumValues: SatAuthHeader.values)
    ..aOS(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'value')
    ..hasRequiredFields = false;

  SatAuthHeaderPair._() : super();
  factory SatAuthHeaderPair({
    SatAuthHeader? key,
    $core.String? value,
  }) {
    final _result = create();
    if (key != null) {
      _result.key = key;
    }
    if (value != null) {
      _result.value = value;
    }
    return _result;
  }
  factory SatAuthHeaderPair.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatAuthHeaderPair.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatAuthHeaderPair clone() => SatAuthHeaderPair()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatAuthHeaderPair copyWith(void Function(SatAuthHeaderPair) updates) =>
      super.copyWith((message) => updates(message as SatAuthHeaderPair))
          as SatAuthHeaderPair; // ignore: deprecated_member_use
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
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'SatAuthReq',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'Electric.Satellite.v1_3'),
      createEmptyInstance: create)
    ..aOS(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'id')
    ..aOS(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'token')
    ..pc<SatAuthHeaderPair>(
        3,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'headers',
        $pb.PbFieldType.PM,
        subBuilder: SatAuthHeaderPair.create)
    ..hasRequiredFields = false;

  SatAuthReq._() : super();
  factory SatAuthReq({
    $core.String? id,
    $core.String? token,
    $core.Iterable<SatAuthHeaderPair>? headers,
  }) {
    final _result = create();
    if (id != null) {
      _result.id = id;
    }
    if (token != null) {
      _result.token = token;
    }
    if (headers != null) {
      _result.headers.addAll(headers);
    }
    return _result;
  }
  factory SatAuthReq.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatAuthReq.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatAuthReq clone() => SatAuthReq()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatAuthReq copyWith(void Function(SatAuthReq) updates) =>
      super.copyWith((message) => updates(message as SatAuthReq))
          as SatAuthReq; // ignore: deprecated_member_use
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
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'SatAuthResp',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'Electric.Satellite.v1_3'),
      createEmptyInstance: create)
    ..aOS(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'id')
    ..pc<SatAuthHeaderPair>(
        3,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'headers',
        $pb.PbFieldType.PM,
        subBuilder: SatAuthHeaderPair.create)
    ..hasRequiredFields = false;

  SatAuthResp._() : super();
  factory SatAuthResp({
    $core.String? id,
    $core.Iterable<SatAuthHeaderPair>? headers,
  }) {
    final _result = create();
    if (id != null) {
      _result.id = id;
    }
    if (headers != null) {
      _result.headers.addAll(headers);
    }
    return _result;
  }
  factory SatAuthResp.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatAuthResp.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatAuthResp clone() => SatAuthResp()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatAuthResp copyWith(void Function(SatAuthResp) updates) =>
      super.copyWith((message) => updates(message as SatAuthResp))
          as SatAuthResp; // ignore: deprecated_member_use
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
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'SatErrorResp',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'Electric.Satellite.v1_3'),
      createEmptyInstance: create)
    ..e<SatErrorResp_ErrorCode>(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'errorType',
        $pb.PbFieldType.OE,
        defaultOrMaker: SatErrorResp_ErrorCode.INTERNAL,
        valueOf: SatErrorResp_ErrorCode.valueOf,
        enumValues: SatErrorResp_ErrorCode.values)
    ..hasRequiredFields = false;

  SatErrorResp._() : super();
  factory SatErrorResp({
    SatErrorResp_ErrorCode? errorType,
  }) {
    final _result = create();
    if (errorType != null) {
      _result.errorType = errorType;
    }
    return _result;
  }
  factory SatErrorResp.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatErrorResp.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatErrorResp clone() => SatErrorResp()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatErrorResp copyWith(void Function(SatErrorResp) updates) =>
      super.copyWith((message) => updates(message as SatErrorResp))
          as SatErrorResp; // ignore: deprecated_member_use
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
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'SatInStartReplicationReq',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'Electric.Satellite.v1_3'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'lsn',
        $pb.PbFieldType.OY)
    ..pc<SatInStartReplicationReq_Option>(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'options',
        $pb.PbFieldType.KE,
        valueOf: SatInStartReplicationReq_Option.valueOf,
        enumValues: SatInStartReplicationReq_Option.values,
        defaultEnumValue: SatInStartReplicationReq_Option.NONE)
    ..a<$core.int>(
        3,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'syncBatchSize',
        $pb.PbFieldType.O3)
    ..hasRequiredFields = false;

  SatInStartReplicationReq._() : super();
  factory SatInStartReplicationReq({
    $core.List<$core.int>? lsn,
    $core.Iterable<SatInStartReplicationReq_Option>? options,
    $core.int? syncBatchSize,
  }) {
    final _result = create();
    if (lsn != null) {
      _result.lsn = lsn;
    }
    if (options != null) {
      _result.options.addAll(options);
    }
    if (syncBatchSize != null) {
      _result.syncBatchSize = syncBatchSize;
    }
    return _result;
  }
  factory SatInStartReplicationReq.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatInStartReplicationReq.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
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
          as SatInStartReplicationReq; // ignore: deprecated_member_use
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
}

class SatInStartReplicationResp extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'SatInStartReplicationResp',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'Electric.Satellite.v1_3'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  SatInStartReplicationResp._() : super();
  factory SatInStartReplicationResp() => create();
  factory SatInStartReplicationResp.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatInStartReplicationResp.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
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
          as SatInStartReplicationResp; // ignore: deprecated_member_use
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
}

class SatInStopReplicationReq extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'SatInStopReplicationReq',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'Electric.Satellite.v1_3'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  SatInStopReplicationReq._() : super();
  factory SatInStopReplicationReq() => create();
  factory SatInStopReplicationReq.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatInStopReplicationReq.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
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
          as SatInStopReplicationReq; // ignore: deprecated_member_use
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
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'SatInStopReplicationResp',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'Electric.Satellite.v1_3'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  SatInStopReplicationResp._() : super();
  factory SatInStopReplicationResp() => create();
  factory SatInStopReplicationResp.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatInStopReplicationResp.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
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
          as SatInStopReplicationResp; // ignore: deprecated_member_use
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
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'SatRelationColumn',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'Electric.Satellite.v1_3'),
      createEmptyInstance: create)
    ..aOS(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'name')
    ..aOS(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'type')
    ..aOB(
        3,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'primaryKey',
        protoName: 'primaryKey')
    ..hasRequiredFields = false;

  SatRelationColumn._() : super();
  factory SatRelationColumn({
    $core.String? name,
    $core.String? type,
    $core.bool? primaryKey,
  }) {
    final _result = create();
    if (name != null) {
      _result.name = name;
    }
    if (type != null) {
      _result.type = type;
    }
    if (primaryKey != null) {
      _result.primaryKey = primaryKey;
    }
    return _result;
  }
  factory SatRelationColumn.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatRelationColumn.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatRelationColumn clone() => SatRelationColumn()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatRelationColumn copyWith(void Function(SatRelationColumn) updates) =>
      super.copyWith((message) => updates(message as SatRelationColumn))
          as SatRelationColumn; // ignore: deprecated_member_use
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
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'SatRelation',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'Electric.Satellite.v1_3'),
      createEmptyInstance: create)
    ..aOS(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'schemaName')
    ..e<SatRelation_RelationType>(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'tableType',
        $pb.PbFieldType.OE,
        defaultOrMaker: SatRelation_RelationType.TABLE,
        valueOf: SatRelation_RelationType.valueOf,
        enumValues: SatRelation_RelationType.values)
    ..aOS(
        3,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'tableName')
    ..a<$core.int>(
        4,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'relationId',
        $pb.PbFieldType.OU3)
    ..pc<SatRelationColumn>(
        5,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'columns',
        $pb.PbFieldType.PM,
        subBuilder: SatRelationColumn.create)
    ..hasRequiredFields = false;

  SatRelation._() : super();
  factory SatRelation({
    $core.String? schemaName,
    SatRelation_RelationType? tableType,
    $core.String? tableName,
    $core.int? relationId,
    $core.Iterable<SatRelationColumn>? columns,
  }) {
    final _result = create();
    if (schemaName != null) {
      _result.schemaName = schemaName;
    }
    if (tableType != null) {
      _result.tableType = tableType;
    }
    if (tableName != null) {
      _result.tableName = tableName;
    }
    if (relationId != null) {
      _result.relationId = relationId;
    }
    if (columns != null) {
      _result.columns.addAll(columns);
    }
    return _result;
  }
  factory SatRelation.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatRelation.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatRelation clone() => SatRelation()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatRelation copyWith(void Function(SatRelation) updates) =>
      super.copyWith((message) => updates(message as SatRelation))
          as SatRelation; // ignore: deprecated_member_use
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
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'SatOpLog',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'Electric.Satellite.v1_3'),
      createEmptyInstance: create)
    ..pc<SatTransOp>(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'ops',
        $pb.PbFieldType.PM,
        subBuilder: SatTransOp.create)
    ..hasRequiredFields = false;

  SatOpLog._() : super();
  factory SatOpLog({
    $core.Iterable<SatTransOp>? ops,
  }) {
    final _result = create();
    if (ops != null) {
      _result.ops.addAll(ops);
    }
    return _result;
  }
  factory SatOpLog.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatOpLog.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatOpLog clone() => SatOpLog()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatOpLog copyWith(void Function(SatOpLog) updates) =>
      super.copyWith((message) => updates(message as SatOpLog))
          as SatOpLog; // ignore: deprecated_member_use
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
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'SatTransOp',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'Electric.Satellite.v1_3'),
      createEmptyInstance: create)
    ..oo(0, [1, 2, 3, 4, 5, 6])
    ..aOM<SatOpBegin>(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'begin',
        subBuilder: SatOpBegin.create)
    ..aOM<SatOpCommit>(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'commit',
        subBuilder: SatOpCommit.create)
    ..aOM<SatOpUpdate>(
        3,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'update',
        subBuilder: SatOpUpdate.create)
    ..aOM<SatOpInsert>(
        4,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'insert',
        subBuilder: SatOpInsert.create)
    ..aOM<SatOpDelete>(
        5,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'delete',
        subBuilder: SatOpDelete.create)
    ..aOM<SatOpMigrate>(
        6,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'migrate',
        subBuilder: SatOpMigrate.create)
    ..hasRequiredFields = false;

  SatTransOp._() : super();
  factory SatTransOp({
    SatOpBegin? begin,
    SatOpCommit? commit,
    SatOpUpdate? update,
    SatOpInsert? insert,
    SatOpDelete? delete,
    SatOpMigrate? migrate,
  }) {
    final _result = create();
    if (begin != null) {
      _result.begin = begin;
    }
    if (commit != null) {
      _result.commit = commit;
    }
    if (update != null) {
      _result.update = update;
    }
    if (insert != null) {
      _result.insert = insert;
    }
    if (delete != null) {
      _result.delete = delete;
    }
    if (migrate != null) {
      _result.migrate = migrate;
    }
    return _result;
  }
  factory SatTransOp.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatTransOp.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatTransOp clone() => SatTransOp()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatTransOp copyWith(void Function(SatTransOp) updates) =>
      super.copyWith((message) => updates(message as SatTransOp))
          as SatTransOp; // ignore: deprecated_member_use
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
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'SatOpBegin',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'Electric.Satellite.v1_3'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'commitTimestamp',
        $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'transId')
    ..a<$core.List<$core.int>>(
        3,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'lsn',
        $pb.PbFieldType.OY)
    ..aOS(
        4,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'origin')
    ..aOB(
        5,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'isMigration')
    ..hasRequiredFields = false;

  SatOpBegin._() : super();
  factory SatOpBegin({
    $fixnum.Int64? commitTimestamp,
    $core.String? transId,
    $core.List<$core.int>? lsn,
    $core.String? origin,
    $core.bool? isMigration,
  }) {
    final _result = create();
    if (commitTimestamp != null) {
      _result.commitTimestamp = commitTimestamp;
    }
    if (transId != null) {
      _result.transId = transId;
    }
    if (lsn != null) {
      _result.lsn = lsn;
    }
    if (origin != null) {
      _result.origin = origin;
    }
    if (isMigration != null) {
      _result.isMigration = isMigration;
    }
    return _result;
  }
  factory SatOpBegin.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatOpBegin.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatOpBegin clone() => SatOpBegin()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatOpBegin copyWith(void Function(SatOpBegin) updates) =>
      super.copyWith((message) => updates(message as SatOpBegin))
          as SatOpBegin; // ignore: deprecated_member_use
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
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'SatOpCommit',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'Electric.Satellite.v1_3'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'commitTimestamp',
        $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'transId')
    ..a<$core.List<$core.int>>(
        3,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'lsn',
        $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  SatOpCommit._() : super();
  factory SatOpCommit({
    $fixnum.Int64? commitTimestamp,
    $core.String? transId,
    $core.List<$core.int>? lsn,
  }) {
    final _result = create();
    if (commitTimestamp != null) {
      _result.commitTimestamp = commitTimestamp;
    }
    if (transId != null) {
      _result.transId = transId;
    }
    if (lsn != null) {
      _result.lsn = lsn;
    }
    return _result;
  }
  factory SatOpCommit.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatOpCommit.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatOpCommit clone() => SatOpCommit()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatOpCommit copyWith(void Function(SatOpCommit) updates) =>
      super.copyWith((message) => updates(message as SatOpCommit))
          as SatOpCommit; // ignore: deprecated_member_use
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
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'SatOpInsert',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'Electric.Satellite.v1_3'),
      createEmptyInstance: create)
    ..a<$core.int>(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'relationId',
        $pb.PbFieldType.OU3)
    ..aOM<SatOpRow>(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'rowData',
        subBuilder: SatOpRow.create)
    ..pPS(
        3,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'tags')
    ..hasRequiredFields = false;

  SatOpInsert._() : super();
  factory SatOpInsert({
    $core.int? relationId,
    SatOpRow? rowData,
    $core.Iterable<$core.String>? tags,
  }) {
    final _result = create();
    if (relationId != null) {
      _result.relationId = relationId;
    }
    if (rowData != null) {
      _result.rowData = rowData;
    }
    if (tags != null) {
      _result.tags.addAll(tags);
    }
    return _result;
  }
  factory SatOpInsert.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatOpInsert.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatOpInsert clone() => SatOpInsert()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatOpInsert copyWith(void Function(SatOpInsert) updates) =>
      super.copyWith((message) => updates(message as SatOpInsert))
          as SatOpInsert; // ignore: deprecated_member_use
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
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'SatOpUpdate',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'Electric.Satellite.v1_3'),
      createEmptyInstance: create)
    ..a<$core.int>(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'relationId',
        $pb.PbFieldType.OU3)
    ..aOM<SatOpRow>(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'rowData',
        subBuilder: SatOpRow.create)
    ..aOM<SatOpRow>(
        3,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'oldRowData',
        subBuilder: SatOpRow.create)
    ..pPS(
        4,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'tags')
    ..hasRequiredFields = false;

  SatOpUpdate._() : super();
  factory SatOpUpdate({
    $core.int? relationId,
    SatOpRow? rowData,
    SatOpRow? oldRowData,
    $core.Iterable<$core.String>? tags,
  }) {
    final _result = create();
    if (relationId != null) {
      _result.relationId = relationId;
    }
    if (rowData != null) {
      _result.rowData = rowData;
    }
    if (oldRowData != null) {
      _result.oldRowData = oldRowData;
    }
    if (tags != null) {
      _result.tags.addAll(tags);
    }
    return _result;
  }
  factory SatOpUpdate.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatOpUpdate.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatOpUpdate clone() => SatOpUpdate()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatOpUpdate copyWith(void Function(SatOpUpdate) updates) =>
      super.copyWith((message) => updates(message as SatOpUpdate))
          as SatOpUpdate; // ignore: deprecated_member_use
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
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'SatOpDelete',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'Electric.Satellite.v1_3'),
      createEmptyInstance: create)
    ..a<$core.int>(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'relationId',
        $pb.PbFieldType.OU3)
    ..aOM<SatOpRow>(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'oldRowData',
        subBuilder: SatOpRow.create)
    ..pPS(
        3,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'tags')
    ..hasRequiredFields = false;

  SatOpDelete._() : super();
  factory SatOpDelete({
    $core.int? relationId,
    SatOpRow? oldRowData,
    $core.Iterable<$core.String>? tags,
  }) {
    final _result = create();
    if (relationId != null) {
      _result.relationId = relationId;
    }
    if (oldRowData != null) {
      _result.oldRowData = oldRowData;
    }
    if (tags != null) {
      _result.tags.addAll(tags);
    }
    return _result;
  }
  factory SatOpDelete.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatOpDelete.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatOpDelete clone() => SatOpDelete()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatOpDelete copyWith(void Function(SatOpDelete) updates) =>
      super.copyWith((message) => updates(message as SatOpDelete))
          as SatOpDelete; // ignore: deprecated_member_use
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
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'SatMigrationNotification',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'Electric.Satellite.v1_3'),
      createEmptyInstance: create)
    ..aOS(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'oldSchemaVersion')
    ..aOS(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'oldSchemaHash')
    ..aOS(
        3,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'newSchemaVersion')
    ..aOS(
        4,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'newSchemaHash')
    ..hasRequiredFields = false;

  SatMigrationNotification._() : super();
  factory SatMigrationNotification({
    $core.String? oldSchemaVersion,
    $core.String? oldSchemaHash,
    $core.String? newSchemaVersion,
    $core.String? newSchemaHash,
  }) {
    final _result = create();
    if (oldSchemaVersion != null) {
      _result.oldSchemaVersion = oldSchemaVersion;
    }
    if (oldSchemaHash != null) {
      _result.oldSchemaHash = oldSchemaHash;
    }
    if (newSchemaVersion != null) {
      _result.newSchemaVersion = newSchemaVersion;
    }
    if (newSchemaHash != null) {
      _result.newSchemaHash = newSchemaHash;
    }
    return _result;
  }
  factory SatMigrationNotification.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatMigrationNotification.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
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
          as SatMigrationNotification; // ignore: deprecated_member_use
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
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'SatOpRow',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'Electric.Satellite.v1_3'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'nullsBitmask',
        $pb.PbFieldType.OY)
    ..p<$core.List<$core.int>>(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'values',
        $pb.PbFieldType.PY)
    ..hasRequiredFields = false;

  SatOpRow._() : super();
  factory SatOpRow({
    $core.List<$core.int>? nullsBitmask,
    $core.Iterable<$core.List<$core.int>>? values,
  }) {
    final _result = create();
    if (nullsBitmask != null) {
      _result.nullsBitmask = nullsBitmask;
    }
    if (values != null) {
      _result.values.addAll(values);
    }
    return _result;
  }
  factory SatOpRow.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatOpRow.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatOpRow clone() => SatOpRow()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatOpRow copyWith(void Function(SatOpRow) updates) =>
      super.copyWith((message) => updates(message as SatOpRow))
          as SatOpRow; // ignore: deprecated_member_use
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
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'SatOpMigrate.Stmt',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'Electric.Satellite.v1_3'),
      createEmptyInstance: create)
    ..e<SatOpMigrate_Type>(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'type',
        $pb.PbFieldType.OE,
        defaultOrMaker: SatOpMigrate_Type.CREATE_TABLE,
        valueOf: SatOpMigrate_Type.valueOf,
        enumValues: SatOpMigrate_Type.values)
    ..aOS(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'sql')
    ..hasRequiredFields = false;

  SatOpMigrate_Stmt._() : super();
  factory SatOpMigrate_Stmt({
    SatOpMigrate_Type? type,
    $core.String? sql,
  }) {
    final _result = create();
    if (type != null) {
      _result.type = type;
    }
    if (sql != null) {
      _result.sql = sql;
    }
    return _result;
  }
  factory SatOpMigrate_Stmt.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatOpMigrate_Stmt.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatOpMigrate_Stmt clone() => SatOpMigrate_Stmt()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatOpMigrate_Stmt copyWith(void Function(SatOpMigrate_Stmt) updates) =>
      super.copyWith((message) => updates(message as SatOpMigrate_Stmt))
          as SatOpMigrate_Stmt; // ignore: deprecated_member_use
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
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'SatOpMigrate.PgColumnType',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'Electric.Satellite.v1_3'),
      createEmptyInstance: create)
    ..aOS(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'name')
    ..p<$core.int>(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'array',
        $pb.PbFieldType.K3)
    ..p<$core.int>(
        3,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'size',
        $pb.PbFieldType.K3)
    ..hasRequiredFields = false;

  SatOpMigrate_PgColumnType._() : super();
  factory SatOpMigrate_PgColumnType({
    $core.String? name,
    $core.Iterable<$core.int>? array,
    $core.Iterable<$core.int>? size,
  }) {
    final _result = create();
    if (name != null) {
      _result.name = name;
    }
    if (array != null) {
      _result.array.addAll(array);
    }
    if (size != null) {
      _result.size.addAll(size);
    }
    return _result;
  }
  factory SatOpMigrate_PgColumnType.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatOpMigrate_PgColumnType.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
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
          as SatOpMigrate_PgColumnType; // ignore: deprecated_member_use
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
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'SatOpMigrate.Column',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'Electric.Satellite.v1_3'),
      createEmptyInstance: create)
    ..aOS(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'name')
    ..aOS(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'sqliteType')
    ..aOM<SatOpMigrate_PgColumnType>(
        3,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'pgType',
        subBuilder: SatOpMigrate_PgColumnType.create)
    ..hasRequiredFields = false;

  SatOpMigrate_Column._() : super();
  factory SatOpMigrate_Column({
    $core.String? name,
    $core.String? sqliteType,
    SatOpMigrate_PgColumnType? pgType,
  }) {
    final _result = create();
    if (name != null) {
      _result.name = name;
    }
    if (sqliteType != null) {
      _result.sqliteType = sqliteType;
    }
    if (pgType != null) {
      _result.pgType = pgType;
    }
    return _result;
  }
  factory SatOpMigrate_Column.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatOpMigrate_Column.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatOpMigrate_Column clone() => SatOpMigrate_Column()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatOpMigrate_Column copyWith(void Function(SatOpMigrate_Column) updates) =>
      super.copyWith((message) => updates(message as SatOpMigrate_Column))
          as SatOpMigrate_Column; // ignore: deprecated_member_use
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
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'SatOpMigrate.ForeignKey',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'Electric.Satellite.v1_3'),
      createEmptyInstance: create)
    ..pPS(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'fkCols')
    ..aOS(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'pkTable')
    ..pPS(
        3,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'pkCols')
    ..hasRequiredFields = false;

  SatOpMigrate_ForeignKey._() : super();
  factory SatOpMigrate_ForeignKey({
    $core.Iterable<$core.String>? fkCols,
    $core.String? pkTable,
    $core.Iterable<$core.String>? pkCols,
  }) {
    final _result = create();
    if (fkCols != null) {
      _result.fkCols.addAll(fkCols);
    }
    if (pkTable != null) {
      _result.pkTable = pkTable;
    }
    if (pkCols != null) {
      _result.pkCols.addAll(pkCols);
    }
    return _result;
  }
  factory SatOpMigrate_ForeignKey.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatOpMigrate_ForeignKey.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
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
          as SatOpMigrate_ForeignKey; // ignore: deprecated_member_use
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
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'SatOpMigrate.Table',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'Electric.Satellite.v1_3'),
      createEmptyInstance: create)
    ..aOS(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'name')
    ..pc<SatOpMigrate_Column>(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'columns',
        $pb.PbFieldType.PM,
        subBuilder: SatOpMigrate_Column.create)
    ..pc<SatOpMigrate_ForeignKey>(
        3,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'fks',
        $pb.PbFieldType.PM,
        subBuilder: SatOpMigrate_ForeignKey.create)
    ..pPS(
        4,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'pks')
    ..hasRequiredFields = false;

  SatOpMigrate_Table._() : super();
  factory SatOpMigrate_Table({
    $core.String? name,
    $core.Iterable<SatOpMigrate_Column>? columns,
    $core.Iterable<SatOpMigrate_ForeignKey>? fks,
    $core.Iterable<$core.String>? pks,
  }) {
    final _result = create();
    if (name != null) {
      _result.name = name;
    }
    if (columns != null) {
      _result.columns.addAll(columns);
    }
    if (fks != null) {
      _result.fks.addAll(fks);
    }
    if (pks != null) {
      _result.pks.addAll(pks);
    }
    return _result;
  }
  factory SatOpMigrate_Table.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatOpMigrate_Table.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatOpMigrate_Table clone() => SatOpMigrate_Table()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatOpMigrate_Table copyWith(void Function(SatOpMigrate_Table) updates) =>
      super.copyWith((message) => updates(message as SatOpMigrate_Table))
          as SatOpMigrate_Table; // ignore: deprecated_member_use
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
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'SatOpMigrate',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'Electric.Satellite.v1_3'),
      createEmptyInstance: create)
    ..aOS(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'version')
    ..pc<SatOpMigrate_Stmt>(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'stmts',
        $pb.PbFieldType.PM,
        subBuilder: SatOpMigrate_Stmt.create)
    ..aOM<SatOpMigrate_Table>(
        3,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'table',
        subBuilder: SatOpMigrate_Table.create)
    ..hasRequiredFields = false;

  SatOpMigrate._() : super();
  factory SatOpMigrate({
    $core.String? version,
    $core.Iterable<SatOpMigrate_Stmt>? stmts,
    SatOpMigrate_Table? table,
  }) {
    final _result = create();
    if (version != null) {
      _result.version = version;
    }
    if (stmts != null) {
      _result.stmts.addAll(stmts);
    }
    if (table != null) {
      _result.table = table;
    }
    return _result;
  }
  factory SatOpMigrate.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatOpMigrate.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatOpMigrate clone() => SatOpMigrate()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatOpMigrate copyWith(void Function(SatOpMigrate) updates) =>
      super.copyWith((message) => updates(message as SatOpMigrate))
          as SatOpMigrate; // ignore: deprecated_member_use
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
