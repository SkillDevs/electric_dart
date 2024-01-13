//
//  Generated code. Do not modify.
//  source: proto/satellite.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class SatAuthHeader extends $pb.ProtobufEnum {
  static const SatAuthHeader UNSPECIFIED =
      SatAuthHeader._(0, _omitEnumNames ? '' : 'UNSPECIFIED');

  static const $core.List<SatAuthHeader> values = <SatAuthHeader>[
    UNSPECIFIED,
  ];

  static final $core.Map<$core.int, SatAuthHeader> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static SatAuthHeader? valueOf($core.int value) => _byValue[value];

  const SatAuthHeader._($core.int v, $core.String n) : super(v, n);
}

class SatErrorResp_ErrorCode extends $pb.ProtobufEnum {
  static const SatErrorResp_ErrorCode INTERNAL =
      SatErrorResp_ErrorCode._(0, _omitEnumNames ? '' : 'INTERNAL');
  static const SatErrorResp_ErrorCode AUTH_REQUIRED =
      SatErrorResp_ErrorCode._(1, _omitEnumNames ? '' : 'AUTH_REQUIRED');
  static const SatErrorResp_ErrorCode AUTH_FAILED =
      SatErrorResp_ErrorCode._(2, _omitEnumNames ? '' : 'AUTH_FAILED');
  static const SatErrorResp_ErrorCode REPLICATION_FAILED =
      SatErrorResp_ErrorCode._(3, _omitEnumNames ? '' : 'REPLICATION_FAILED');
  static const SatErrorResp_ErrorCode INVALID_REQUEST =
      SatErrorResp_ErrorCode._(4, _omitEnumNames ? '' : 'INVALID_REQUEST');
  static const SatErrorResp_ErrorCode PROTO_VSN_MISMATCH =
      SatErrorResp_ErrorCode._(5, _omitEnumNames ? '' : 'PROTO_VSN_MISMATCH');
  static const SatErrorResp_ErrorCode SCHEMA_VSN_MISMATCH =
      SatErrorResp_ErrorCode._(6, _omitEnumNames ? '' : 'SCHEMA_VSN_MISMATCH');

  static const $core.List<SatErrorResp_ErrorCode> values =
      <SatErrorResp_ErrorCode>[
    INTERNAL,
    AUTH_REQUIRED,
    AUTH_FAILED,
    REPLICATION_FAILED,
    INVALID_REQUEST,
    PROTO_VSN_MISMATCH,
    SCHEMA_VSN_MISMATCH,
  ];

  static final $core.Map<$core.int, SatErrorResp_ErrorCode> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static SatErrorResp_ErrorCode? valueOf($core.int value) => _byValue[value];

  const SatErrorResp_ErrorCode._($core.int v, $core.String n) : super(v, n);
}

class SatInStartReplicationReq_Option extends $pb.ProtobufEnum {
  static const SatInStartReplicationReq_Option NONE =
      SatInStartReplicationReq_Option._(0, _omitEnumNames ? '' : 'NONE');

  static const $core.List<SatInStartReplicationReq_Option> values =
      <SatInStartReplicationReq_Option>[
    NONE,
  ];

  static final $core.Map<$core.int, SatInStartReplicationReq_Option> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static SatInStartReplicationReq_Option? valueOf($core.int value) =>
      _byValue[value];

  const SatInStartReplicationReq_Option._($core.int v, $core.String n)
      : super(v, n);
}

/// error code enum
class SatInStartReplicationResp_ReplicationError_Code extends $pb.ProtobufEnum {
  static const SatInStartReplicationResp_ReplicationError_Code
      CODE_UNSPECIFIED = SatInStartReplicationResp_ReplicationError_Code._(
          0, _omitEnumNames ? '' : 'CODE_UNSPECIFIED');
  static const SatInStartReplicationResp_ReplicationError_Code BEHIND_WINDOW =
      SatInStartReplicationResp_ReplicationError_Code._(
          1, _omitEnumNames ? '' : 'BEHIND_WINDOW');
  static const SatInStartReplicationResp_ReplicationError_Code
      INVALID_POSITION = SatInStartReplicationResp_ReplicationError_Code._(
          2, _omitEnumNames ? '' : 'INVALID_POSITION');
  static const SatInStartReplicationResp_ReplicationError_Code
      SUBSCRIPTION_NOT_FOUND =
      SatInStartReplicationResp_ReplicationError_Code._(
          3, _omitEnumNames ? '' : 'SUBSCRIPTION_NOT_FOUND');
  static const SatInStartReplicationResp_ReplicationError_Code MALFORMED_LSN =
      SatInStartReplicationResp_ReplicationError_Code._(
          4, _omitEnumNames ? '' : 'MALFORMED_LSN');
  static const SatInStartReplicationResp_ReplicationError_Code
      UNKNOWN_SCHEMA_VSN = SatInStartReplicationResp_ReplicationError_Code._(
          5, _omitEnumNames ? '' : 'UNKNOWN_SCHEMA_VSN');

  static const $core.List<SatInStartReplicationResp_ReplicationError_Code>
      values = <SatInStartReplicationResp_ReplicationError_Code>[
    CODE_UNSPECIFIED,
    BEHIND_WINDOW,
    INVALID_POSITION,
    SUBSCRIPTION_NOT_FOUND,
    MALFORMED_LSN,
    UNKNOWN_SCHEMA_VSN,
  ];

  static final $core
      .Map<$core.int, SatInStartReplicationResp_ReplicationError_Code>
      _byValue = $pb.ProtobufEnum.initByValue(values);
  static SatInStartReplicationResp_ReplicationError_Code? valueOf(
          $core.int value) =>
      _byValue[value];

  const SatInStartReplicationResp_ReplicationError_Code._(
      $core.int v, $core.String n)
      : super(v, n);
}

class SatRelation_RelationType extends $pb.ProtobufEnum {
  static const SatRelation_RelationType TABLE =
      SatRelation_RelationType._(0, _omitEnumNames ? '' : 'TABLE');
  static const SatRelation_RelationType INDEX =
      SatRelation_RelationType._(1, _omitEnumNames ? '' : 'INDEX');
  static const SatRelation_RelationType VIEW =
      SatRelation_RelationType._(2, _omitEnumNames ? '' : 'VIEW');
  static const SatRelation_RelationType TRIGGER =
      SatRelation_RelationType._(3, _omitEnumNames ? '' : 'TRIGGER');

  static const $core.List<SatRelation_RelationType> values =
      <SatRelation_RelationType>[
    TABLE,
    INDEX,
    VIEW,
    TRIGGER,
  ];

  static final $core.Map<$core.int, SatRelation_RelationType> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static SatRelation_RelationType? valueOf($core.int value) => _byValue[value];

  const SatRelation_RelationType._($core.int v, $core.String n) : super(v, n);
}

class SatOpMigrate_Type extends $pb.ProtobufEnum {
  static const SatOpMigrate_Type CREATE_TABLE =
      SatOpMigrate_Type._(0, _omitEnumNames ? '' : 'CREATE_TABLE');
  static const SatOpMigrate_Type CREATE_INDEX =
      SatOpMigrate_Type._(1, _omitEnumNames ? '' : 'CREATE_INDEX');
  static const SatOpMigrate_Type ALTER_ADD_COLUMN =
      SatOpMigrate_Type._(6, _omitEnumNames ? '' : 'ALTER_ADD_COLUMN');

  static const $core.List<SatOpMigrate_Type> values = <SatOpMigrate_Type>[
    CREATE_TABLE,
    CREATE_INDEX,
    ALTER_ADD_COLUMN,
  ];

  static final $core.Map<$core.int, SatOpMigrate_Type> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static SatOpMigrate_Type? valueOf($core.int value) => _byValue[value];

  const SatOpMigrate_Type._($core.int v, $core.String n) : super(v, n);
}

/// error code enum
class SatSubsResp_SatSubsError_Code extends $pb.ProtobufEnum {
  static const SatSubsResp_SatSubsError_Code CODE_UNSPECIFIED =
      SatSubsResp_SatSubsError_Code._(
          0, _omitEnumNames ? '' : 'CODE_UNSPECIFIED');
  static const SatSubsResp_SatSubsError_Code SUBSCRIPTION_ID_ALREADY_EXISTS =
      SatSubsResp_SatSubsError_Code._(
          1, _omitEnumNames ? '' : 'SUBSCRIPTION_ID_ALREADY_EXISTS');
  static const SatSubsResp_SatSubsError_Code SHAPE_REQUEST_ERROR =
      SatSubsResp_SatSubsError_Code._(
          2, _omitEnumNames ? '' : 'SHAPE_REQUEST_ERROR');

  static const $core.List<SatSubsResp_SatSubsError_Code> values =
      <SatSubsResp_SatSubsError_Code>[
    CODE_UNSPECIFIED,
    SUBSCRIPTION_ID_ALREADY_EXISTS,
    SHAPE_REQUEST_ERROR,
  ];

  static final $core.Map<$core.int, SatSubsResp_SatSubsError_Code> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static SatSubsResp_SatSubsError_Code? valueOf($core.int value) =>
      _byValue[value];

  const SatSubsResp_SatSubsError_Code._($core.int v, $core.String n)
      : super(v, n);
}

/// error code enum
class SatSubsResp_SatSubsError_ShapeReqError_Code extends $pb.ProtobufEnum {
  static const SatSubsResp_SatSubsError_ShapeReqError_Code CODE_UNSPECIFIED =
      SatSubsResp_SatSubsError_ShapeReqError_Code._(
          0, _omitEnumNames ? '' : 'CODE_UNSPECIFIED');
  static const SatSubsResp_SatSubsError_ShapeReqError_Code TABLE_NOT_FOUND =
      SatSubsResp_SatSubsError_ShapeReqError_Code._(
          1, _omitEnumNames ? '' : 'TABLE_NOT_FOUND');
  static const SatSubsResp_SatSubsError_ShapeReqError_Code
      REFERENTIAL_INTEGRITY_VIOLATION =
      SatSubsResp_SatSubsError_ShapeReqError_Code._(
          2, _omitEnumNames ? '' : 'REFERENTIAL_INTEGRITY_VIOLATION');
  static const SatSubsResp_SatSubsError_ShapeReqError_Code
      EMPTY_SHAPE_DEFINITION = SatSubsResp_SatSubsError_ShapeReqError_Code._(
          3, _omitEnumNames ? '' : 'EMPTY_SHAPE_DEFINITION');
  static const SatSubsResp_SatSubsError_ShapeReqError_Code
      DUPLICATE_TABLE_IN_SHAPE_DEFINITION =
      SatSubsResp_SatSubsError_ShapeReqError_Code._(
          4, _omitEnumNames ? '' : 'DUPLICATE_TABLE_IN_SHAPE_DEFINITION');

  static const $core.List<SatSubsResp_SatSubsError_ShapeReqError_Code> values =
      <SatSubsResp_SatSubsError_ShapeReqError_Code>[
    CODE_UNSPECIFIED,
    TABLE_NOT_FOUND,
    REFERENTIAL_INTEGRITY_VIOLATION,
    EMPTY_SHAPE_DEFINITION,
    DUPLICATE_TABLE_IN_SHAPE_DEFINITION,
  ];

  static final $core.Map<$core.int, SatSubsResp_SatSubsError_ShapeReqError_Code>
      _byValue = $pb.ProtobufEnum.initByValue(values);
  static SatSubsResp_SatSubsError_ShapeReqError_Code? valueOf(
          $core.int value) =>
      _byValue[value];

  const SatSubsResp_SatSubsError_ShapeReqError_Code._(
      $core.int v, $core.String n)
      : super(v, n);
}

/// error code enum
class SatSubsDataError_Code extends $pb.ProtobufEnum {
  static const SatSubsDataError_Code CODE_UNSPECIFIED =
      SatSubsDataError_Code._(0, _omitEnumNames ? '' : 'CODE_UNSPECIFIED');
  static const SatSubsDataError_Code SHAPE_DELIVERY_ERROR =
      SatSubsDataError_Code._(1, _omitEnumNames ? '' : 'SHAPE_DELIVERY_ERROR');

  static const $core.List<SatSubsDataError_Code> values =
      <SatSubsDataError_Code>[
    CODE_UNSPECIFIED,
    SHAPE_DELIVERY_ERROR,
  ];

  static final $core.Map<$core.int, SatSubsDataError_Code> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static SatSubsDataError_Code? valueOf($core.int value) => _byValue[value];

  const SatSubsDataError_Code._($core.int v, $core.String n) : super(v, n);
}

/// error code enum
class SatSubsDataError_ShapeReqError_Code extends $pb.ProtobufEnum {
  static const SatSubsDataError_ShapeReqError_Code CODE_UNSPECIFIED =
      SatSubsDataError_ShapeReqError_Code._(
          0, _omitEnumNames ? '' : 'CODE_UNSPECIFIED');
  static const SatSubsDataError_ShapeReqError_Code SHAPE_SIZE_LIMIT_EXCEEDED =
      SatSubsDataError_ShapeReqError_Code._(
          1, _omitEnumNames ? '' : 'SHAPE_SIZE_LIMIT_EXCEEDED');

  static const $core.List<SatSubsDataError_ShapeReqError_Code> values =
      <SatSubsDataError_ShapeReqError_Code>[
    CODE_UNSPECIFIED,
    SHAPE_SIZE_LIMIT_EXCEEDED,
  ];

  static final $core.Map<$core.int, SatSubsDataError_ShapeReqError_Code>
      _byValue = $pb.ProtobufEnum.initByValue(values);
  static SatSubsDataError_ShapeReqError_Code? valueOf($core.int value) =>
      _byValue[value];

  const SatSubsDataError_ShapeReqError_Code._($core.int v, $core.String n)
      : super(v, n);
}

const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
