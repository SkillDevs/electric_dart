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

class SatAuthHeaderPair extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'SatAuthHeaderPair',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'Electric.Satellite'),
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
              : 'Electric.Satellite'),
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
              : 'Electric.Satellite'),
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
              : 'Electric.Satellite'),
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
              : 'Electric.Satellite'),
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
    ..pPS(
        4,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'subscriptionIds')
    ..aOS(
        5,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'schemaVersion')
    ..hasRequiredFields = false;

  SatInStartReplicationReq._() : super();
  factory SatInStartReplicationReq({
    $core.List<$core.int>? lsn,
    $core.Iterable<SatInStartReplicationReq_Option>? options,
    $core.Iterable<$core.String>? subscriptionIds,
    $core.String? schemaVersion,
  }) {
    final _result = create();
    if (lsn != null) {
      _result.lsn = lsn;
    }
    if (options != null) {
      _result.options.addAll(options);
    }
    if (subscriptionIds != null) {
      _result.subscriptionIds.addAll(subscriptionIds);
    }
    if (schemaVersion != null) {
      _result.schemaVersion = schemaVersion;
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

  @$pb.TagNumber(4)
  $core.List<$core.String> get subscriptionIds => $_getList(2);

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
}

class SatInStartReplicationResp_ReplicationError extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'SatInStartReplicationResp.ReplicationError',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..e<SatInStartReplicationResp_ReplicationError_Code>(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'code',
        $pb.PbFieldType.OE,
        defaultOrMaker:
            SatInStartReplicationResp_ReplicationError_Code.CODE_UNSPECIFIED,
        valueOf: SatInStartReplicationResp_ReplicationError_Code.valueOf,
        enumValues: SatInStartReplicationResp_ReplicationError_Code.values)
    ..aOS(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'message')
    ..hasRequiredFields = false;

  SatInStartReplicationResp_ReplicationError._() : super();
  factory SatInStartReplicationResp_ReplicationError({
    SatInStartReplicationResp_ReplicationError_Code? code,
    $core.String? message,
  }) {
    final _result = create();
    if (code != null) {
      _result.code = code;
    }
    if (message != null) {
      _result.message = message;
    }
    return _result;
  }
  factory SatInStartReplicationResp_ReplicationError.fromBuffer(
          $core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatInStartReplicationResp_ReplicationError.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
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
          as SatInStartReplicationResp_ReplicationError; // ignore: deprecated_member_use
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
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'SatInStartReplicationResp',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..aOM<SatInStartReplicationResp_ReplicationError>(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'err',
        subBuilder: SatInStartReplicationResp_ReplicationError.create)
    ..hasRequiredFields = false;

  SatInStartReplicationResp._() : super();
  factory SatInStartReplicationResp({
    SatInStartReplicationResp_ReplicationError? err,
  }) {
    final _result = create();
    if (err != null) {
      _result.err = err;
    }
    return _result;
  }
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
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'SatInStopReplicationReq',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'Electric.Satellite'),
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
              : 'Electric.Satellite'),
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
              : 'Electric.Satellite'),
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
    ..aOB(
        4,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'isNullable')
    ..hasRequiredFields = false;

  SatRelationColumn._() : super();
  factory SatRelationColumn({
    $core.String? name,
    $core.String? type,
    $core.bool? primaryKey,
    $core.bool? isNullable,
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
    if (isNullable != null) {
      _result.isNullable = isNullable;
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
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'SatRelation',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'Electric.Satellite'),
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
              : 'Electric.Satellite'),
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
              : 'Electric.Satellite'),
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
              : 'Electric.Satellite'),
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
              : 'Electric.Satellite'),
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
              : 'Electric.Satellite'),
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
              : 'Electric.Satellite'),
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
              : 'Electric.Satellite'),
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
              : 'Electric.Satellite'),
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
              : 'Electric.Satellite'),
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
              : 'Electric.Satellite'),
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
              : 'Electric.Satellite'),
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
              : 'Electric.Satellite'),
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
              : 'Electric.Satellite'),
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
              : 'Electric.Satellite'),
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
              : 'Electric.Satellite'),
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

class SatSubsReq extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'SatSubsReq',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..aOS(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'subscriptionId')
    ..pc<SatShapeReq>(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'shapeRequests',
        $pb.PbFieldType.PM,
        subBuilder: SatShapeReq.create)
    ..hasRequiredFields = false;

  SatSubsReq._() : super();
  factory SatSubsReq({
    $core.String? subscriptionId,
    $core.Iterable<SatShapeReq>? shapeRequests,
  }) {
    final _result = create();
    if (subscriptionId != null) {
      _result.subscriptionId = subscriptionId;
    }
    if (shapeRequests != null) {
      _result.shapeRequests.addAll(shapeRequests);
    }
    return _result;
  }
  factory SatSubsReq.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatSubsReq.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatSubsReq clone() => SatSubsReq()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatSubsReq copyWith(void Function(SatSubsReq) updates) =>
      super.copyWith((message) => updates(message as SatSubsReq))
          as SatSubsReq; // ignore: deprecated_member_use
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static SatSubsReq create() => SatSubsReq._();
  SatSubsReq createEmptyInstance() => create();
  static $pb.PbList<SatSubsReq> createRepeated() => $pb.PbList<SatSubsReq>();
  @$core.pragma('dart2js:noInline')
  static SatSubsReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SatSubsReq>(create);
  static SatSubsReq? _defaultInstance;

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

  @$pb.TagNumber(2)
  $core.List<SatShapeReq> get shapeRequests => $_getList(1);
}

class SatSubsResp_SatSubsError_ShapeReqError extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'SatSubsResp.SatSubsError.ShapeReqError',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..e<SatSubsResp_SatSubsError_ShapeReqError_Code>(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'code',
        $pb.PbFieldType.OE,
        defaultOrMaker:
            SatSubsResp_SatSubsError_ShapeReqError_Code.CODE_UNSPECIFIED,
        valueOf: SatSubsResp_SatSubsError_ShapeReqError_Code.valueOf,
        enumValues: SatSubsResp_SatSubsError_ShapeReqError_Code.values)
    ..aOS(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'message')
    ..aOS(
        3,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'requestId')
    ..hasRequiredFields = false;

  SatSubsResp_SatSubsError_ShapeReqError._() : super();
  factory SatSubsResp_SatSubsError_ShapeReqError({
    SatSubsResp_SatSubsError_ShapeReqError_Code? code,
    $core.String? message,
    $core.String? requestId,
  }) {
    final _result = create();
    if (code != null) {
      _result.code = code;
    }
    if (message != null) {
      _result.message = message;
    }
    if (requestId != null) {
      _result.requestId = requestId;
    }
    return _result;
  }
  factory SatSubsResp_SatSubsError_ShapeReqError.fromBuffer(
          $core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatSubsResp_SatSubsError_ShapeReqError.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
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
          as SatSubsResp_SatSubsError_ShapeReqError; // ignore: deprecated_member_use
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

class SatSubsResp_SatSubsError extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'SatSubsResp.SatSubsError',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..e<SatSubsResp_SatSubsError_Code>(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'code',
        $pb.PbFieldType.OE,
        defaultOrMaker: SatSubsResp_SatSubsError_Code.CODE_UNSPECIFIED,
        valueOf: SatSubsResp_SatSubsError_Code.valueOf,
        enumValues: SatSubsResp_SatSubsError_Code.values)
    ..aOS(
        3,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'message')
    ..pc<SatSubsResp_SatSubsError_ShapeReqError>(
        4,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'shapeRequestError',
        $pb.PbFieldType.PM,
        subBuilder: SatSubsResp_SatSubsError_ShapeReqError.create)
    ..hasRequiredFields = false;

  SatSubsResp_SatSubsError._() : super();
  factory SatSubsResp_SatSubsError({
    SatSubsResp_SatSubsError_Code? code,
    $core.String? message,
    $core.Iterable<SatSubsResp_SatSubsError_ShapeReqError>? shapeRequestError,
  }) {
    final _result = create();
    if (code != null) {
      _result.code = code;
    }
    if (message != null) {
      _result.message = message;
    }
    if (shapeRequestError != null) {
      _result.shapeRequestError.addAll(shapeRequestError);
    }
    return _result;
  }
  factory SatSubsResp_SatSubsError.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatSubsResp_SatSubsError.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
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
          as SatSubsResp_SatSubsError; // ignore: deprecated_member_use
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

  @$pb.TagNumber(4)
  $core.List<SatSubsResp_SatSubsError_ShapeReqError> get shapeRequestError =>
      $_getList(2);
}

class SatSubsResp extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'SatSubsResp',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..aOS(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'subscriptionId')
    ..aOM<SatSubsResp_SatSubsError>(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'err',
        subBuilder: SatSubsResp_SatSubsError.create)
    ..hasRequiredFields = false;

  SatSubsResp._() : super();
  factory SatSubsResp({
    $core.String? subscriptionId,
    SatSubsResp_SatSubsError? err,
  }) {
    final _result = create();
    if (subscriptionId != null) {
      _result.subscriptionId = subscriptionId;
    }
    if (err != null) {
      _result.err = err;
    }
    return _result;
  }
  factory SatSubsResp.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatSubsResp.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatSubsResp clone() => SatSubsResp()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatSubsResp copyWith(void Function(SatSubsResp) updates) =>
      super.copyWith((message) => updates(message as SatSubsResp))
          as SatSubsResp; // ignore: deprecated_member_use
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

class SatUnsubsReq extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'SatUnsubsReq',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..pPS(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'subscriptionIds')
    ..hasRequiredFields = false;

  SatUnsubsReq._() : super();
  factory SatUnsubsReq({
    $core.Iterable<$core.String>? subscriptionIds,
  }) {
    final _result = create();
    if (subscriptionIds != null) {
      _result.subscriptionIds.addAll(subscriptionIds);
    }
    return _result;
  }
  factory SatUnsubsReq.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatUnsubsReq.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatUnsubsReq clone() => SatUnsubsReq()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatUnsubsReq copyWith(void Function(SatUnsubsReq) updates) =>
      super.copyWith((message) => updates(message as SatUnsubsReq))
          as SatUnsubsReq; // ignore: deprecated_member_use
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
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'SatUnsubsResp',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  SatUnsubsResp._() : super();
  factory SatUnsubsResp() => create();
  factory SatUnsubsResp.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatUnsubsResp.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatUnsubsResp clone() => SatUnsubsResp()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatUnsubsResp copyWith(void Function(SatUnsubsResp) updates) =>
      super.copyWith((message) => updates(message as SatUnsubsResp))
          as SatUnsubsResp; // ignore: deprecated_member_use
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
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'SatShapeReq',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..aOS(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'requestId')
    ..aOM<SatShapeDef>(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'shapeDefinition',
        subBuilder: SatShapeDef.create)
    ..hasRequiredFields = false;

  SatShapeReq._() : super();
  factory SatShapeReq({
    $core.String? requestId,
    SatShapeDef? shapeDefinition,
  }) {
    final _result = create();
    if (requestId != null) {
      _result.requestId = requestId;
    }
    if (shapeDefinition != null) {
      _result.shapeDefinition = shapeDefinition;
    }
    return _result;
  }
  factory SatShapeReq.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatShapeReq.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatShapeReq clone() => SatShapeReq()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatShapeReq copyWith(void Function(SatShapeReq) updates) =>
      super.copyWith((message) => updates(message as SatShapeReq))
          as SatShapeReq; // ignore: deprecated_member_use
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
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'SatShapeDef.Select',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..aOS(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'tablename')
    ..hasRequiredFields = false;

  SatShapeDef_Select._() : super();
  factory SatShapeDef_Select({
    $core.String? tablename,
  }) {
    final _result = create();
    if (tablename != null) {
      _result.tablename = tablename;
    }
    return _result;
  }
  factory SatShapeDef_Select.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatShapeDef_Select.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatShapeDef_Select clone() => SatShapeDef_Select()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatShapeDef_Select copyWith(void Function(SatShapeDef_Select) updates) =>
      super.copyWith((message) => updates(message as SatShapeDef_Select))
          as SatShapeDef_Select; // ignore: deprecated_member_use
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
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'SatShapeDef',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..pc<SatShapeDef_Select>(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'selects',
        $pb.PbFieldType.PM,
        subBuilder: SatShapeDef_Select.create)
    ..hasRequiredFields = false;

  SatShapeDef._() : super();
  factory SatShapeDef({
    $core.Iterable<SatShapeDef_Select>? selects,
  }) {
    final _result = create();
    if (selects != null) {
      _result.selects.addAll(selects);
    }
    return _result;
  }
  factory SatShapeDef.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatShapeDef.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatShapeDef clone() => SatShapeDef()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatShapeDef copyWith(void Function(SatShapeDef) updates) =>
      super.copyWith((message) => updates(message as SatShapeDef))
          as SatShapeDef; // ignore: deprecated_member_use
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

class SatSubsDataError_ShapeReqError extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'SatSubsDataError.ShapeReqError',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..e<SatSubsDataError_ShapeReqError_Code>(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'code',
        $pb.PbFieldType.OE,
        defaultOrMaker: SatSubsDataError_ShapeReqError_Code.CODE_UNSPECIFIED,
        valueOf: SatSubsDataError_ShapeReqError_Code.valueOf,
        enumValues: SatSubsDataError_ShapeReqError_Code.values)
    ..aOS(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'message')
    ..aOS(
        3,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'requestId')
    ..hasRequiredFields = false;

  SatSubsDataError_ShapeReqError._() : super();
  factory SatSubsDataError_ShapeReqError({
    SatSubsDataError_ShapeReqError_Code? code,
    $core.String? message,
    $core.String? requestId,
  }) {
    final _result = create();
    if (code != null) {
      _result.code = code;
    }
    if (message != null) {
      _result.message = message;
    }
    if (requestId != null) {
      _result.requestId = requestId;
    }
    return _result;
  }
  factory SatSubsDataError_ShapeReqError.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatSubsDataError_ShapeReqError.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
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
          as SatSubsDataError_ShapeReqError; // ignore: deprecated_member_use
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

class SatSubsDataError extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'SatSubsDataError',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..e<SatSubsDataError_Code>(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'code',
        $pb.PbFieldType.OE,
        defaultOrMaker: SatSubsDataError_Code.CODE_UNSPECIFIED,
        valueOf: SatSubsDataError_Code.valueOf,
        enumValues: SatSubsDataError_Code.values)
    ..aOS(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'message')
    ..aOS(
        3,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'subscriptionId')
    ..pc<SatSubsDataError_ShapeReqError>(
        4,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'shapeRequestError',
        $pb.PbFieldType.PM,
        subBuilder: SatSubsDataError_ShapeReqError.create)
    ..hasRequiredFields = false;

  SatSubsDataError._() : super();
  factory SatSubsDataError({
    SatSubsDataError_Code? code,
    $core.String? message,
    $core.String? subscriptionId,
    $core.Iterable<SatSubsDataError_ShapeReqError>? shapeRequestError,
  }) {
    final _result = create();
    if (code != null) {
      _result.code = code;
    }
    if (message != null) {
      _result.message = message;
    }
    if (subscriptionId != null) {
      _result.subscriptionId = subscriptionId;
    }
    if (shapeRequestError != null) {
      _result.shapeRequestError.addAll(shapeRequestError);
    }
    return _result;
  }
  factory SatSubsDataError.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatSubsDataError.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatSubsDataError clone() => SatSubsDataError()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatSubsDataError copyWith(void Function(SatSubsDataError) updates) =>
      super.copyWith((message) => updates(message as SatSubsDataError))
          as SatSubsDataError; // ignore: deprecated_member_use
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
  $core.List<SatSubsDataError_ShapeReqError> get shapeRequestError =>
      $_getList(3);
}

class SatSubsDataBegin extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'SatSubsDataBegin',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..aOS(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'subscriptionId')
    ..a<$core.List<$core.int>>(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'lsn',
        $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  SatSubsDataBegin._() : super();
  factory SatSubsDataBegin({
    $core.String? subscriptionId,
    $core.List<$core.int>? lsn,
  }) {
    final _result = create();
    if (subscriptionId != null) {
      _result.subscriptionId = subscriptionId;
    }
    if (lsn != null) {
      _result.lsn = lsn;
    }
    return _result;
  }
  factory SatSubsDataBegin.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatSubsDataBegin.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatSubsDataBegin clone() => SatSubsDataBegin()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatSubsDataBegin copyWith(void Function(SatSubsDataBegin) updates) =>
      super.copyWith((message) => updates(message as SatSubsDataBegin))
          as SatSubsDataBegin; // ignore: deprecated_member_use
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

class SatSubsDataEnd extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'SatSubsDataEnd',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  SatSubsDataEnd._() : super();
  factory SatSubsDataEnd() => create();
  factory SatSubsDataEnd.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatSubsDataEnd.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatSubsDataEnd clone() => SatSubsDataEnd()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatSubsDataEnd copyWith(void Function(SatSubsDataEnd) updates) =>
      super.copyWith((message) => updates(message as SatSubsDataEnd))
          as SatSubsDataEnd; // ignore: deprecated_member_use
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
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'SatShapeDataBegin',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..aOS(
        1,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'requestId')
    ..aOS(
        2,
        const $core.bool.fromEnvironment('protobuf.omit_field_names')
            ? ''
            : 'uuid')
    ..hasRequiredFields = false;

  SatShapeDataBegin._() : super();
  factory SatShapeDataBegin({
    $core.String? requestId,
    $core.String? uuid,
  }) {
    final _result = create();
    if (requestId != null) {
      _result.requestId = requestId;
    }
    if (uuid != null) {
      _result.uuid = uuid;
    }
    return _result;
  }
  factory SatShapeDataBegin.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatShapeDataBegin.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatShapeDataBegin clone() => SatShapeDataBegin()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatShapeDataBegin copyWith(void Function(SatShapeDataBegin) updates) =>
      super.copyWith((message) => updates(message as SatShapeDataBegin))
          as SatShapeDataBegin; // ignore: deprecated_member_use
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
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      const $core.bool.fromEnvironment('protobuf.omit_message_names')
          ? ''
          : 'SatShapeDataEnd',
      package: const $pb.PackageName(
          const $core.bool.fromEnvironment('protobuf.omit_message_names')
              ? ''
              : 'Electric.Satellite'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  SatShapeDataEnd._() : super();
  factory SatShapeDataEnd() => create();
  factory SatShapeDataEnd.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory SatShapeDataEnd.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  SatShapeDataEnd clone() => SatShapeDataEnd()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  SatShapeDataEnd copyWith(void Function(SatShapeDataEnd) updates) =>
      super.copyWith((message) => updates(message as SatShapeDataEnd))
          as SatShapeDataEnd; // ignore: deprecated_member_use
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
