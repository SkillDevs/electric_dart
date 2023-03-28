///
//  Generated code. Do not modify.
//  source: proto/satellite.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

// ignore_for_file: UNDEFINED_SHOWN_NAME
import 'dart:core' as $core;
import 'package:protobuf/protobuf.dart' as $pb;

class SatAuthHeader extends $pb.ProtobufEnum {
  static const SatAuthHeader UNSPECIFIED = SatAuthHeader._(0, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'UNSPECIFIED');
  static const SatAuthHeader PROTO_VERSION = SatAuthHeader._(1, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'PROTO_VERSION');
  static const SatAuthHeader SCHEMA_VERSION = SatAuthHeader._(2, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'SCHEMA_VERSION');

  static const $core.List<SatAuthHeader> values = <SatAuthHeader> [
    UNSPECIFIED,
    PROTO_VERSION,
    SCHEMA_VERSION,
  ];

  static final $core.Map<$core.int, SatAuthHeader> _byValue = $pb.ProtobufEnum.initByValue(values);
  static SatAuthHeader? valueOf($core.int value) => _byValue[value];

  const SatAuthHeader._($core.int v, $core.String n) : super(v, n);
}

class SatErrorResp_ErrorCode extends $pb.ProtobufEnum {
  static const SatErrorResp_ErrorCode INTERNAL = SatErrorResp_ErrorCode._(0, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'INTERNAL');
  static const SatErrorResp_ErrorCode AUTH_REQUIRED = SatErrorResp_ErrorCode._(1, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'AUTH_REQUIRED');
  static const SatErrorResp_ErrorCode AUTH_FAILED = SatErrorResp_ErrorCode._(2, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'AUTH_FAILED');
  static const SatErrorResp_ErrorCode REPLICATION_FAILED = SatErrorResp_ErrorCode._(3, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'REPLICATION_FAILED');
  static const SatErrorResp_ErrorCode INVALID_REQUEST = SatErrorResp_ErrorCode._(4, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'INVALID_REQUEST');
  static const SatErrorResp_ErrorCode PROTO_VSN_MISSMATCH = SatErrorResp_ErrorCode._(5, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'PROTO_VSN_MISSMATCH');
  static const SatErrorResp_ErrorCode SCHEMA_VSN_MISSMATCH = SatErrorResp_ErrorCode._(6, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'SCHEMA_VSN_MISSMATCH');

  static const $core.List<SatErrorResp_ErrorCode> values = <SatErrorResp_ErrorCode> [
    INTERNAL,
    AUTH_REQUIRED,
    AUTH_FAILED,
    REPLICATION_FAILED,
    INVALID_REQUEST,
    PROTO_VSN_MISSMATCH,
    SCHEMA_VSN_MISSMATCH,
  ];

  static final $core.Map<$core.int, SatErrorResp_ErrorCode> _byValue = $pb.ProtobufEnum.initByValue(values);
  static SatErrorResp_ErrorCode? valueOf($core.int value) => _byValue[value];

  const SatErrorResp_ErrorCode._($core.int v, $core.String n) : super(v, n);
}

class SatInStartReplicationReq_Option extends $pb.ProtobufEnum {
  static const SatInStartReplicationReq_Option NONE = SatInStartReplicationReq_Option._(0, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'NONE');
  static const SatInStartReplicationReq_Option LAST_ACKNOWLEDGED = SatInStartReplicationReq_Option._(1, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'LAST_ACKNOWLEDGED');
  static const SatInStartReplicationReq_Option SYNC_MODE = SatInStartReplicationReq_Option._(2, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'SYNC_MODE');
  static const SatInStartReplicationReq_Option FIRST_LSN = SatInStartReplicationReq_Option._(3, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'FIRST_LSN');
  static const SatInStartReplicationReq_Option LAST_LSN = SatInStartReplicationReq_Option._(4, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'LAST_LSN');

  static const $core.List<SatInStartReplicationReq_Option> values = <SatInStartReplicationReq_Option> [
    NONE,
    LAST_ACKNOWLEDGED,
    SYNC_MODE,
    FIRST_LSN,
    LAST_LSN,
  ];

  static final $core.Map<$core.int, SatInStartReplicationReq_Option> _byValue = $pb.ProtobufEnum.initByValue(values);
  static SatInStartReplicationReq_Option? valueOf($core.int value) => _byValue[value];

  const SatInStartReplicationReq_Option._($core.int v, $core.String n) : super(v, n);
}

class SatRelation_RelationType extends $pb.ProtobufEnum {
  static const SatRelation_RelationType TABLE = SatRelation_RelationType._(0, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'TABLE');
  static const SatRelation_RelationType INDEX = SatRelation_RelationType._(1, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'INDEX');
  static const SatRelation_RelationType VIEW = SatRelation_RelationType._(2, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'VIEW');
  static const SatRelation_RelationType TRIGGER = SatRelation_RelationType._(3, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'TRIGGER');

  static const $core.List<SatRelation_RelationType> values = <SatRelation_RelationType> [
    TABLE,
    INDEX,
    VIEW,
    TRIGGER,
  ];

  static final $core.Map<$core.int, SatRelation_RelationType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static SatRelation_RelationType? valueOf($core.int value) => _byValue[value];

  const SatRelation_RelationType._($core.int v, $core.String n) : super(v, n);
}

