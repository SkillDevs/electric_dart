///
//  Generated code. Do not modify.
//  source: proto/satellite.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,deprecated_member_use_from_same_package,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use satAuthHeaderDescriptor instead')
const SatAuthHeader$json = const {
  '1': 'SatAuthHeader',
  '2': const [
    const {'1': 'UNSPECIFIED', '2': 0},
  ],
  '4': const [
    const {'1': 1, '2': 1},
  ],
};

/// Descriptor for `SatAuthHeader`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List satAuthHeaderDescriptor = $convert
    .base64Decode('Cg1TYXRBdXRoSGVhZGVyEg8KC1VOU1BFQ0lGSUVEEAAiBAgBEAE=');
@$core.Deprecated('Use satPingReqDescriptor instead')
const SatPingReq$json = const {
  '1': 'SatPingReq',
};

/// Descriptor for `SatPingReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satPingReqDescriptor =
    $convert.base64Decode('CgpTYXRQaW5nUmVx');
@$core.Deprecated('Use satPingRespDescriptor instead')
const SatPingResp$json = const {
  '1': 'SatPingResp',
  '2': const [
    const {
      '1': 'lsn',
      '3': 1,
      '4': 1,
      '5': 12,
      '9': 0,
      '10': 'lsn',
      '17': true
    },
  ],
  '8': const [
    const {'1': '_lsn'},
  ],
};

/// Descriptor for `SatPingResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satPingRespDescriptor = $convert.base64Decode(
    'CgtTYXRQaW5nUmVzcBIVCgNsc24YASABKAxIAFIDbHNuiAEBQgYKBF9sc24=');
@$core.Deprecated('Use satAuthHeaderPairDescriptor instead')
const SatAuthHeaderPair$json = const {
  '1': 'SatAuthHeaderPair',
  '2': const [
    const {
      '1': 'key',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.Electric.Satellite.SatAuthHeader',
      '10': 'key'
    },
    const {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
};

/// Descriptor for `SatAuthHeaderPair`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satAuthHeaderPairDescriptor = $convert.base64Decode(
    'ChFTYXRBdXRoSGVhZGVyUGFpchIzCgNrZXkYASABKA4yIS5FbGVjdHJpYy5TYXRlbGxpdGUuU2F0QXV0aEhlYWRlclIDa2V5EhQKBXZhbHVlGAIgASgJUgV2YWx1ZQ==');
@$core.Deprecated('Use satAuthReqDescriptor instead')
const SatAuthReq$json = const {
  '1': 'SatAuthReq',
  '2': const [
    const {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    const {'1': 'token', '3': 2, '4': 1, '5': 9, '10': 'token'},
    const {
      '1': 'headers',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.Electric.Satellite.SatAuthHeaderPair',
      '10': 'headers'
    },
  ],
};

/// Descriptor for `SatAuthReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satAuthReqDescriptor = $convert.base64Decode(
    'CgpTYXRBdXRoUmVxEg4KAmlkGAEgASgJUgJpZBIUCgV0b2tlbhgCIAEoCVIFdG9rZW4SPwoHaGVhZGVycxgDIAMoCzIlLkVsZWN0cmljLlNhdGVsbGl0ZS5TYXRBdXRoSGVhZGVyUGFpclIHaGVhZGVycw==');
@$core.Deprecated('Use satAuthRespDescriptor instead')
const SatAuthResp$json = const {
  '1': 'SatAuthResp',
  '2': const [
    const {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    const {
      '1': 'headers',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.Electric.Satellite.SatAuthHeaderPair',
      '10': 'headers'
    },
  ],
};

/// Descriptor for `SatAuthResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satAuthRespDescriptor = $convert.base64Decode(
    'CgtTYXRBdXRoUmVzcBIOCgJpZBgBIAEoCVICaWQSPwoHaGVhZGVycxgDIAMoCzIlLkVsZWN0cmljLlNhdGVsbGl0ZS5TYXRBdXRoSGVhZGVyUGFpclIHaGVhZGVycw==');
@$core.Deprecated('Use satErrorRespDescriptor instead')
const SatErrorResp$json = const {
  '1': 'SatErrorResp',
  '2': const [
    const {
      '1': 'error_type',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.Electric.Satellite.SatErrorResp.ErrorCode',
      '10': 'errorType'
    },
  ],
  '4': const [SatErrorResp_ErrorCode$json],
};

@$core.Deprecated('Use satErrorRespDescriptor instead')
const SatErrorResp_ErrorCode$json = const {
  '1': 'ErrorCode',
  '2': const [
    const {'1': 'INTERNAL', '2': 0},
    const {'1': 'AUTH_REQUIRED', '2': 1},
    const {'1': 'AUTH_FAILED', '2': 2},
    const {'1': 'REPLICATION_FAILED', '2': 3},
    const {'1': 'INVALID_REQUEST', '2': 4},
    const {'1': 'PROTO_VSN_MISMATCH', '2': 5},
    const {'1': 'SCHEMA_VSN_MISMATCH', '2': 6},
  ],
};

/// Descriptor for `SatErrorResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satErrorRespDescriptor = $convert.base64Decode(
    'CgxTYXRFcnJvclJlc3ASSQoKZXJyb3JfdHlwZRgBIAEoDjIqLkVsZWN0cmljLlNhdGVsbGl0ZS5TYXRFcnJvclJlc3AuRXJyb3JDb2RlUgllcnJvclR5cGUimwEKCUVycm9yQ29kZRIMCghJTlRFUk5BTBAAEhEKDUFVVEhfUkVRVUlSRUQQARIPCgtBVVRIX0ZBSUxFRBACEhYKElJFUExJQ0FUSU9OX0ZBSUxFRBADEhMKD0lOVkFMSURfUkVRVUVTVBAEEhYKElBST1RPX1ZTTl9NSVNNQVRDSBAFEhcKE1NDSEVNQV9WU05fTUlTTUFUQ0gQBg==');
@$core.Deprecated('Use satInStartReplicationReqDescriptor instead')
const SatInStartReplicationReq$json = const {
  '1': 'SatInStartReplicationReq',
  '2': const [
    const {'1': 'lsn', '3': 1, '4': 1, '5': 12, '10': 'lsn'},
    const {
      '1': 'options',
      '3': 2,
      '4': 3,
      '5': 14,
      '6': '.Electric.Satellite.SatInStartReplicationReq.Option',
      '10': 'options'
    },
    const {
      '1': 'subscription_ids',
      '3': 4,
      '4': 3,
      '5': 9,
      '10': 'subscriptionIds'
    },
    const {
      '1': 'schema_version',
      '3': 5,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'schemaVersion',
      '17': true
    },
  ],
  '4': const [SatInStartReplicationReq_Option$json],
  '8': const [
    const {'1': '_schema_version'},
  ],
  '9': const [
    const {'1': 3, '2': 4},
  ],
};

@$core.Deprecated('Use satInStartReplicationReqDescriptor instead')
const SatInStartReplicationReq_Option$json = const {
  '1': 'Option',
  '2': const [
    const {'1': 'NONE', '2': 0},
  ],
  '4': const [
    const {'1': 1, '2': 1},
    const {'1': 2, '2': 2},
    const {'1': 3, '2': 3},
    const {'1': 4, '2': 4},
  ],
};

/// Descriptor for `SatInStartReplicationReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satInStartReplicationReqDescriptor =
    $convert.base64Decode(
        'ChhTYXRJblN0YXJ0UmVwbGljYXRpb25SZXESEAoDbHNuGAEgASgMUgNsc24STQoHb3B0aW9ucxgCIAMoDjIzLkVsZWN0cmljLlNhdGVsbGl0ZS5TYXRJblN0YXJ0UmVwbGljYXRpb25SZXEuT3B0aW9uUgdvcHRpb25zEikKEHN1YnNjcmlwdGlvbl9pZHMYBCADKAlSD3N1YnNjcmlwdGlvbklkcxIqCg5zY2hlbWFfdmVyc2lvbhgFIAEoCUgAUg1zY2hlbWFWZXJzaW9uiAEBIioKBk9wdGlvbhIICgROT05FEAAiBAgBEAEiBAgCEAIiBAgDEAMiBAgEEARCEQoPX3NjaGVtYV92ZXJzaW9uSgQIAxAE');
@$core.Deprecated('Use satInStartReplicationRespDescriptor instead')
const SatInStartReplicationResp$json = const {
  '1': 'SatInStartReplicationResp',
  '2': const [
    const {
      '1': 'err',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.Electric.Satellite.SatInStartReplicationResp.ReplicationError',
      '9': 0,
      '10': 'err',
      '17': true
    },
  ],
  '3': const [SatInStartReplicationResp_ReplicationError$json],
  '8': const [
    const {'1': '_err'},
  ],
};

@$core.Deprecated('Use satInStartReplicationRespDescriptor instead')
const SatInStartReplicationResp_ReplicationError$json = const {
  '1': 'ReplicationError',
  '2': const [
    const {
      '1': 'code',
      '3': 1,
      '4': 1,
      '5': 14,
      '6':
          '.Electric.Satellite.SatInStartReplicationResp.ReplicationError.Code',
      '10': 'code'
    },
    const {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
  ],
  '4': const [SatInStartReplicationResp_ReplicationError_Code$json],
};

@$core.Deprecated('Use satInStartReplicationRespDescriptor instead')
const SatInStartReplicationResp_ReplicationError_Code$json = const {
  '1': 'Code',
  '2': const [
    const {'1': 'CODE_UNSPECIFIED', '2': 0},
    const {'1': 'BEHIND_WINDOW', '2': 1},
    const {'1': 'INVALID_POSITION', '2': 2},
    const {'1': 'SUBSCRIPTION_NOT_FOUND', '2': 3},
    const {'1': 'MALFORMED_LSN', '2': 4},
    const {'1': 'UNKNOWN_SCHEMA_VSN', '2': 5},
  ],
};

/// Descriptor for `SatInStartReplicationResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satInStartReplicationRespDescriptor =
    $convert.base64Decode(
        'ChlTYXRJblN0YXJ0UmVwbGljYXRpb25SZXNwElUKA2VychgBIAEoCzI+LkVsZWN0cmljLlNhdGVsbGl0ZS5TYXRJblN0YXJ0UmVwbGljYXRpb25SZXNwLlJlcGxpY2F0aW9uRXJyb3JIAFIDZXJyiAEBGpQCChBSZXBsaWNhdGlvbkVycm9yElcKBGNvZGUYASABKA4yQy5FbGVjdHJpYy5TYXRlbGxpdGUuU2F0SW5TdGFydFJlcGxpY2F0aW9uUmVzcC5SZXBsaWNhdGlvbkVycm9yLkNvZGVSBGNvZGUSGAoHbWVzc2FnZRgCIAEoCVIHbWVzc2FnZSKMAQoEQ29kZRIUChBDT0RFX1VOU1BFQ0lGSUVEEAASEQoNQkVISU5EX1dJTkRPVxABEhQKEElOVkFMSURfUE9TSVRJT04QAhIaChZTVUJTQ1JJUFRJT05fTk9UX0ZPVU5EEAMSEQoNTUFMRk9STUVEX0xTThAEEhYKElVOS05PV05fU0NIRU1BX1ZTThAFQgYKBF9lcnI=');
@$core.Deprecated('Use satInStopReplicationReqDescriptor instead')
const SatInStopReplicationReq$json = const {
  '1': 'SatInStopReplicationReq',
};

/// Descriptor for `SatInStopReplicationReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satInStopReplicationReqDescriptor =
    $convert.base64Decode('ChdTYXRJblN0b3BSZXBsaWNhdGlvblJlcQ==');
@$core.Deprecated('Use satInStopReplicationRespDescriptor instead')
const SatInStopReplicationResp$json = const {
  '1': 'SatInStopReplicationResp',
};

/// Descriptor for `SatInStopReplicationResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satInStopReplicationRespDescriptor =
    $convert.base64Decode('ChhTYXRJblN0b3BSZXBsaWNhdGlvblJlc3A=');
@$core.Deprecated('Use satRelationColumnDescriptor instead')
const SatRelationColumn$json = const {
  '1': 'SatRelationColumn',
  '2': const [
    const {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    const {'1': 'type', '3': 2, '4': 1, '5': 9, '10': 'type'},
    const {'1': 'primaryKey', '3': 3, '4': 1, '5': 8, '10': 'primaryKey'},
    const {'1': 'is_nullable', '3': 4, '4': 1, '5': 8, '10': 'isNullable'},
  ],
};

/// Descriptor for `SatRelationColumn`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satRelationColumnDescriptor = $convert.base64Decode(
    'ChFTYXRSZWxhdGlvbkNvbHVtbhISCgRuYW1lGAEgASgJUgRuYW1lEhIKBHR5cGUYAiABKAlSBHR5cGUSHgoKcHJpbWFyeUtleRgDIAEoCFIKcHJpbWFyeUtleRIfCgtpc19udWxsYWJsZRgEIAEoCFIKaXNOdWxsYWJsZQ==');
@$core.Deprecated('Use satRelationDescriptor instead')
const SatRelation$json = const {
  '1': 'SatRelation',
  '2': const [
    const {'1': 'schema_name', '3': 1, '4': 1, '5': 9, '10': 'schemaName'},
    const {
      '1': 'table_type',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.Electric.Satellite.SatRelation.RelationType',
      '10': 'tableType'
    },
    const {'1': 'table_name', '3': 3, '4': 1, '5': 9, '10': 'tableName'},
    const {'1': 'relation_id', '3': 4, '4': 1, '5': 13, '10': 'relationId'},
    const {
      '1': 'columns',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.Electric.Satellite.SatRelationColumn',
      '10': 'columns'
    },
  ],
  '4': const [SatRelation_RelationType$json],
};

@$core.Deprecated('Use satRelationDescriptor instead')
const SatRelation_RelationType$json = const {
  '1': 'RelationType',
  '2': const [
    const {'1': 'TABLE', '2': 0},
    const {'1': 'INDEX', '2': 1},
    const {'1': 'VIEW', '2': 2},
    const {'1': 'TRIGGER', '2': 3},
  ],
};

/// Descriptor for `SatRelation`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satRelationDescriptor = $convert.base64Decode(
    'CgtTYXRSZWxhdGlvbhIfCgtzY2hlbWFfbmFtZRgBIAEoCVIKc2NoZW1hTmFtZRJLCgp0YWJsZV90eXBlGAIgASgOMiwuRWxlY3RyaWMuU2F0ZWxsaXRlLlNhdFJlbGF0aW9uLlJlbGF0aW9uVHlwZVIJdGFibGVUeXBlEh0KCnRhYmxlX25hbWUYAyABKAlSCXRhYmxlTmFtZRIfCgtyZWxhdGlvbl9pZBgEIAEoDVIKcmVsYXRpb25JZBI/Cgdjb2x1bW5zGAUgAygLMiUuRWxlY3RyaWMuU2F0ZWxsaXRlLlNhdFJlbGF0aW9uQ29sdW1uUgdjb2x1bW5zIjsKDFJlbGF0aW9uVHlwZRIJCgVUQUJMRRAAEgkKBUlOREVYEAESCAoEVklFVxACEgsKB1RSSUdHRVIQAw==');
@$core.Deprecated('Use satOpLogDescriptor instead')
const SatOpLog$json = const {
  '1': 'SatOpLog',
  '2': const [
    const {
      '1': 'ops',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.Electric.Satellite.SatTransOp',
      '10': 'ops'
    },
  ],
};

/// Descriptor for `SatOpLog`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satOpLogDescriptor = $convert.base64Decode(
    'CghTYXRPcExvZxIwCgNvcHMYASADKAsyHi5FbGVjdHJpYy5TYXRlbGxpdGUuU2F0VHJhbnNPcFIDb3Bz');
@$core.Deprecated('Use satTransOpDescriptor instead')
const SatTransOp$json = const {
  '1': 'SatTransOp',
  '2': const [
    const {
      '1': 'begin',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.Electric.Satellite.SatOpBegin',
      '9': 0,
      '10': 'begin'
    },
    const {
      '1': 'commit',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.Electric.Satellite.SatOpCommit',
      '9': 0,
      '10': 'commit'
    },
    const {
      '1': 'update',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.Electric.Satellite.SatOpUpdate',
      '9': 0,
      '10': 'update'
    },
    const {
      '1': 'insert',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.Electric.Satellite.SatOpInsert',
      '9': 0,
      '10': 'insert'
    },
    const {
      '1': 'delete',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.Electric.Satellite.SatOpDelete',
      '9': 0,
      '10': 'delete'
    },
    const {
      '1': 'migrate',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.Electric.Satellite.SatOpMigrate',
      '9': 0,
      '10': 'migrate'
    },
  ],
  '8': const [
    const {'1': 'op'},
  ],
};

/// Descriptor for `SatTransOp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satTransOpDescriptor = $convert.base64Decode(
    'CgpTYXRUcmFuc09wEjYKBWJlZ2luGAEgASgLMh4uRWxlY3RyaWMuU2F0ZWxsaXRlLlNhdE9wQmVnaW5IAFIFYmVnaW4SOQoGY29tbWl0GAIgASgLMh8uRWxlY3RyaWMuU2F0ZWxsaXRlLlNhdE9wQ29tbWl0SABSBmNvbW1pdBI5CgZ1cGRhdGUYAyABKAsyHy5FbGVjdHJpYy5TYXRlbGxpdGUuU2F0T3BVcGRhdGVIAFIGdXBkYXRlEjkKBmluc2VydBgEIAEoCzIfLkVsZWN0cmljLlNhdGVsbGl0ZS5TYXRPcEluc2VydEgAUgZpbnNlcnQSOQoGZGVsZXRlGAUgASgLMh8uRWxlY3RyaWMuU2F0ZWxsaXRlLlNhdE9wRGVsZXRlSABSBmRlbGV0ZRI8CgdtaWdyYXRlGAYgASgLMiAuRWxlY3RyaWMuU2F0ZWxsaXRlLlNhdE9wTWlncmF0ZUgAUgdtaWdyYXRlQgQKAm9w');
@$core.Deprecated('Use satOpBeginDescriptor instead')
const SatOpBegin$json = const {
  '1': 'SatOpBegin',
  '2': const [
    const {
      '1': 'commit_timestamp',
      '3': 1,
      '4': 1,
      '5': 4,
      '10': 'commitTimestamp'
    },
    const {'1': 'trans_id', '3': 2, '4': 1, '5': 9, '10': 'transId'},
    const {'1': 'lsn', '3': 3, '4': 1, '5': 12, '10': 'lsn'},
    const {
      '1': 'origin',
      '3': 4,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'origin',
      '17': true
    },
    const {'1': 'is_migration', '3': 5, '4': 1, '5': 8, '10': 'isMigration'},
  ],
  '8': const [
    const {'1': '_origin'},
  ],
};

/// Descriptor for `SatOpBegin`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satOpBeginDescriptor = $convert.base64Decode(
    'CgpTYXRPcEJlZ2luEikKEGNvbW1pdF90aW1lc3RhbXAYASABKARSD2NvbW1pdFRpbWVzdGFtcBIZCgh0cmFuc19pZBgCIAEoCVIHdHJhbnNJZBIQCgNsc24YAyABKAxSA2xzbhIbCgZvcmlnaW4YBCABKAlIAFIGb3JpZ2luiAEBEiEKDGlzX21pZ3JhdGlvbhgFIAEoCFILaXNNaWdyYXRpb25CCQoHX29yaWdpbg==');
@$core.Deprecated('Use satOpCommitDescriptor instead')
const SatOpCommit$json = const {
  '1': 'SatOpCommit',
  '2': const [
    const {
      '1': 'commit_timestamp',
      '3': 1,
      '4': 1,
      '5': 4,
      '10': 'commitTimestamp'
    },
    const {'1': 'trans_id', '3': 2, '4': 1, '5': 9, '10': 'transId'},
    const {'1': 'lsn', '3': 3, '4': 1, '5': 12, '10': 'lsn'},
  ],
};

/// Descriptor for `SatOpCommit`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satOpCommitDescriptor = $convert.base64Decode(
    'CgtTYXRPcENvbW1pdBIpChBjb21taXRfdGltZXN0YW1wGAEgASgEUg9jb21taXRUaW1lc3RhbXASGQoIdHJhbnNfaWQYAiABKAlSB3RyYW5zSWQSEAoDbHNuGAMgASgMUgNsc24=');
@$core.Deprecated('Use satOpInsertDescriptor instead')
const SatOpInsert$json = const {
  '1': 'SatOpInsert',
  '2': const [
    const {'1': 'relation_id', '3': 1, '4': 1, '5': 13, '10': 'relationId'},
    const {
      '1': 'row_data',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.Electric.Satellite.SatOpRow',
      '10': 'rowData'
    },
    const {'1': 'tags', '3': 3, '4': 3, '5': 9, '10': 'tags'},
  ],
};

/// Descriptor for `SatOpInsert`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satOpInsertDescriptor = $convert.base64Decode(
    'CgtTYXRPcEluc2VydBIfCgtyZWxhdGlvbl9pZBgBIAEoDVIKcmVsYXRpb25JZBI3Cghyb3dfZGF0YRgCIAEoCzIcLkVsZWN0cmljLlNhdGVsbGl0ZS5TYXRPcFJvd1IHcm93RGF0YRISCgR0YWdzGAMgAygJUgR0YWdz');
@$core.Deprecated('Use satOpUpdateDescriptor instead')
const SatOpUpdate$json = const {
  '1': 'SatOpUpdate',
  '2': const [
    const {'1': 'relation_id', '3': 1, '4': 1, '5': 13, '10': 'relationId'},
    const {
      '1': 'row_data',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.Electric.Satellite.SatOpRow',
      '10': 'rowData'
    },
    const {
      '1': 'old_row_data',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.Electric.Satellite.SatOpRow',
      '10': 'oldRowData'
    },
    const {'1': 'tags', '3': 4, '4': 3, '5': 9, '10': 'tags'},
  ],
};

/// Descriptor for `SatOpUpdate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satOpUpdateDescriptor = $convert.base64Decode(
    'CgtTYXRPcFVwZGF0ZRIfCgtyZWxhdGlvbl9pZBgBIAEoDVIKcmVsYXRpb25JZBI3Cghyb3dfZGF0YRgCIAEoCzIcLkVsZWN0cmljLlNhdGVsbGl0ZS5TYXRPcFJvd1IHcm93RGF0YRI+CgxvbGRfcm93X2RhdGEYAyABKAsyHC5FbGVjdHJpYy5TYXRlbGxpdGUuU2F0T3BSb3dSCm9sZFJvd0RhdGESEgoEdGFncxgEIAMoCVIEdGFncw==');
@$core.Deprecated('Use satOpDeleteDescriptor instead')
const SatOpDelete$json = const {
  '1': 'SatOpDelete',
  '2': const [
    const {'1': 'relation_id', '3': 1, '4': 1, '5': 13, '10': 'relationId'},
    const {
      '1': 'old_row_data',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.Electric.Satellite.SatOpRow',
      '10': 'oldRowData'
    },
    const {'1': 'tags', '3': 3, '4': 3, '5': 9, '10': 'tags'},
  ],
};

/// Descriptor for `SatOpDelete`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satOpDeleteDescriptor = $convert.base64Decode(
    'CgtTYXRPcERlbGV0ZRIfCgtyZWxhdGlvbl9pZBgBIAEoDVIKcmVsYXRpb25JZBI+CgxvbGRfcm93X2RhdGEYAiABKAsyHC5FbGVjdHJpYy5TYXRlbGxpdGUuU2F0T3BSb3dSCm9sZFJvd0RhdGESEgoEdGFncxgDIAMoCVIEdGFncw==');
@$core.Deprecated('Use satMigrationNotificationDescriptor instead')
const SatMigrationNotification$json = const {
  '1': 'SatMigrationNotification',
  '2': const [
    const {
      '1': 'old_schema_version',
      '3': 1,
      '4': 1,
      '5': 9,
      '10': 'oldSchemaVersion'
    },
    const {
      '1': 'old_schema_hash',
      '3': 2,
      '4': 1,
      '5': 9,
      '10': 'oldSchemaHash'
    },
    const {
      '1': 'new_schema_version',
      '3': 3,
      '4': 1,
      '5': 9,
      '10': 'newSchemaVersion'
    },
    const {
      '1': 'new_schema_hash',
      '3': 4,
      '4': 1,
      '5': 9,
      '10': 'newSchemaHash'
    },
  ],
};

/// Descriptor for `SatMigrationNotification`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satMigrationNotificationDescriptor =
    $convert.base64Decode(
        'ChhTYXRNaWdyYXRpb25Ob3RpZmljYXRpb24SLAoSb2xkX3NjaGVtYV92ZXJzaW9uGAEgASgJUhBvbGRTY2hlbWFWZXJzaW9uEiYKD29sZF9zY2hlbWFfaGFzaBgCIAEoCVINb2xkU2NoZW1hSGFzaBIsChJuZXdfc2NoZW1hX3ZlcnNpb24YAyABKAlSEG5ld1NjaGVtYVZlcnNpb24SJgoPbmV3X3NjaGVtYV9oYXNoGAQgASgJUg1uZXdTY2hlbWFIYXNo');
@$core.Deprecated('Use satOpRowDescriptor instead')
const SatOpRow$json = const {
  '1': 'SatOpRow',
  '2': const [
    const {'1': 'nulls_bitmask', '3': 1, '4': 1, '5': 12, '10': 'nullsBitmask'},
    const {'1': 'values', '3': 2, '4': 3, '5': 12, '10': 'values'},
  ],
};

/// Descriptor for `SatOpRow`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satOpRowDescriptor = $convert.base64Decode(
    'CghTYXRPcFJvdxIjCg1udWxsc19iaXRtYXNrGAEgASgMUgxudWxsc0JpdG1hc2sSFgoGdmFsdWVzGAIgAygMUgZ2YWx1ZXM=');
@$core.Deprecated('Use satOpMigrateDescriptor instead')
const SatOpMigrate$json = const {
  '1': 'SatOpMigrate',
  '2': const [
    const {'1': 'version', '3': 1, '4': 1, '5': 9, '10': 'version'},
    const {
      '1': 'stmts',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.Electric.Satellite.SatOpMigrate.Stmt',
      '10': 'stmts'
    },
    const {
      '1': 'table',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.Electric.Satellite.SatOpMigrate.Table',
      '9': 0,
      '10': 'table',
      '17': true
    },
  ],
  '3': const [
    SatOpMigrate_Stmt$json,
    SatOpMigrate_PgColumnType$json,
    SatOpMigrate_Column$json,
    SatOpMigrate_ForeignKey$json,
    SatOpMigrate_Table$json
  ],
  '4': const [SatOpMigrate_Type$json],
  '8': const [
    const {'1': '_table'},
  ],
};

@$core.Deprecated('Use satOpMigrateDescriptor instead')
const SatOpMigrate_Stmt$json = const {
  '1': 'Stmt',
  '2': const [
    const {
      '1': 'type',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.Electric.Satellite.SatOpMigrate.Type',
      '10': 'type'
    },
    const {'1': 'sql', '3': 2, '4': 1, '5': 9, '10': 'sql'},
  ],
};

@$core.Deprecated('Use satOpMigrateDescriptor instead')
const SatOpMigrate_PgColumnType$json = const {
  '1': 'PgColumnType',
  '2': const [
    const {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    const {'1': 'array', '3': 2, '4': 3, '5': 5, '10': 'array'},
    const {'1': 'size', '3': 3, '4': 3, '5': 5, '10': 'size'},
  ],
};

@$core.Deprecated('Use satOpMigrateDescriptor instead')
const SatOpMigrate_Column$json = const {
  '1': 'Column',
  '2': const [
    const {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    const {'1': 'sqlite_type', '3': 2, '4': 1, '5': 9, '10': 'sqliteType'},
    const {
      '1': 'pg_type',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.Electric.Satellite.SatOpMigrate.PgColumnType',
      '10': 'pgType'
    },
  ],
};

@$core.Deprecated('Use satOpMigrateDescriptor instead')
const SatOpMigrate_ForeignKey$json = const {
  '1': 'ForeignKey',
  '2': const [
    const {'1': 'fk_cols', '3': 1, '4': 3, '5': 9, '10': 'fkCols'},
    const {'1': 'pk_table', '3': 2, '4': 1, '5': 9, '10': 'pkTable'},
    const {'1': 'pk_cols', '3': 3, '4': 3, '5': 9, '10': 'pkCols'},
  ],
};

@$core.Deprecated('Use satOpMigrateDescriptor instead')
const SatOpMigrate_Table$json = const {
  '1': 'Table',
  '2': const [
    const {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    const {
      '1': 'columns',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.Electric.Satellite.SatOpMigrate.Column',
      '10': 'columns'
    },
    const {
      '1': 'fks',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.Electric.Satellite.SatOpMigrate.ForeignKey',
      '10': 'fks'
    },
    const {'1': 'pks', '3': 4, '4': 3, '5': 9, '10': 'pks'},
  ],
};

@$core.Deprecated('Use satOpMigrateDescriptor instead')
const SatOpMigrate_Type$json = const {
  '1': 'Type',
  '2': const [
    const {'1': 'CREATE_TABLE', '2': 0},
    const {'1': 'CREATE_INDEX', '2': 1},
    const {'1': 'ALTER_ADD_COLUMN', '2': 6},
  ],
};

/// Descriptor for `SatOpMigrate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satOpMigrateDescriptor = $convert.base64Decode(
    'CgxTYXRPcE1pZ3JhdGUSGAoHdmVyc2lvbhgBIAEoCVIHdmVyc2lvbhI7CgVzdG10cxgCIAMoCzIlLkVsZWN0cmljLlNhdGVsbGl0ZS5TYXRPcE1pZ3JhdGUuU3RtdFIFc3RtdHMSQQoFdGFibGUYAyABKAsyJi5FbGVjdHJpYy5TYXRlbGxpdGUuU2F0T3BNaWdyYXRlLlRhYmxlSABSBXRhYmxliAEBGlMKBFN0bXQSOQoEdHlwZRgBIAEoDjIlLkVsZWN0cmljLlNhdGVsbGl0ZS5TYXRPcE1pZ3JhdGUuVHlwZVIEdHlwZRIQCgNzcWwYAiABKAlSA3NxbBpMCgxQZ0NvbHVtblR5cGUSEgoEbmFtZRgBIAEoCVIEbmFtZRIUCgVhcnJheRgCIAMoBVIFYXJyYXkSEgoEc2l6ZRgDIAMoBVIEc2l6ZRqFAQoGQ29sdW1uEhIKBG5hbWUYASABKAlSBG5hbWUSHwoLc3FsaXRlX3R5cGUYAiABKAlSCnNxbGl0ZVR5cGUSRgoHcGdfdHlwZRgDIAEoCzItLkVsZWN0cmljLlNhdGVsbGl0ZS5TYXRPcE1pZ3JhdGUuUGdDb2x1bW5UeXBlUgZwZ1R5cGUaWQoKRm9yZWlnbktleRIXCgdma19jb2xzGAEgAygJUgZma0NvbHMSGQoIcGtfdGFibGUYAiABKAlSB3BrVGFibGUSFwoHcGtfY29scxgDIAMoCVIGcGtDb2xzGq8BCgVUYWJsZRISCgRuYW1lGAEgASgJUgRuYW1lEkEKB2NvbHVtbnMYAiADKAsyJy5FbGVjdHJpYy5TYXRlbGxpdGUuU2F0T3BNaWdyYXRlLkNvbHVtblIHY29sdW1ucxI9CgNma3MYAyADKAsyKy5FbGVjdHJpYy5TYXRlbGxpdGUuU2F0T3BNaWdyYXRlLkZvcmVpZ25LZXlSA2ZrcxIQCgNwa3MYBCADKAlSA3BrcyJACgRUeXBlEhAKDENSRUFURV9UQUJMRRAAEhAKDENSRUFURV9JTkRFWBABEhQKEEFMVEVSX0FERF9DT0xVTU4QBkIICgZfdGFibGU=');
@$core.Deprecated('Use satSubsReqDescriptor instead')
const SatSubsReq$json = const {
  '1': 'SatSubsReq',
  '2': const [
    const {
      '1': 'subscription_id',
      '3': 1,
      '4': 1,
      '5': 9,
      '10': 'subscriptionId'
    },
    const {
      '1': 'shape_requests',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.Electric.Satellite.SatShapeReq',
      '10': 'shapeRequests'
    },
  ],
};

/// Descriptor for `SatSubsReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satSubsReqDescriptor = $convert.base64Decode(
    'CgpTYXRTdWJzUmVxEicKD3N1YnNjcmlwdGlvbl9pZBgBIAEoCVIOc3Vic2NyaXB0aW9uSWQSRgoOc2hhcGVfcmVxdWVzdHMYAiADKAsyHy5FbGVjdHJpYy5TYXRlbGxpdGUuU2F0U2hhcGVSZXFSDXNoYXBlUmVxdWVzdHM=');
@$core.Deprecated('Use satSubsRespDescriptor instead')
const SatSubsResp$json = const {
  '1': 'SatSubsResp',
  '2': const [
    const {
      '1': 'subscription_id',
      '3': 1,
      '4': 1,
      '5': 9,
      '10': 'subscriptionId'
    },
    const {
      '1': 'err',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.Electric.Satellite.SatSubsResp.SatSubsError',
      '9': 0,
      '10': 'err',
      '17': true
    },
  ],
  '3': const [SatSubsResp_SatSubsError$json],
  '8': const [
    const {'1': '_err'},
  ],
};

@$core.Deprecated('Use satSubsRespDescriptor instead')
const SatSubsResp_SatSubsError$json = const {
  '1': 'SatSubsError',
  '2': const [
    const {
      '1': 'code',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.Electric.Satellite.SatSubsResp.SatSubsError.Code',
      '10': 'code'
    },
    const {'1': 'message', '3': 3, '4': 1, '5': 9, '10': 'message'},
    const {
      '1': 'shape_request_error',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.Electric.Satellite.SatSubsResp.SatSubsError.ShapeReqError',
      '10': 'shapeRequestError'
    },
  ],
  '3': const [SatSubsResp_SatSubsError_ShapeReqError$json],
  '4': const [SatSubsResp_SatSubsError_Code$json],
};

@$core.Deprecated('Use satSubsRespDescriptor instead')
const SatSubsResp_SatSubsError_ShapeReqError$json = const {
  '1': 'ShapeReqError',
  '2': const [
    const {
      '1': 'code',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.Electric.Satellite.SatSubsResp.SatSubsError.ShapeReqError.Code',
      '10': 'code'
    },
    const {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    const {'1': 'request_id', '3': 3, '4': 1, '5': 9, '10': 'requestId'},
  ],
  '4': const [SatSubsResp_SatSubsError_ShapeReqError_Code$json],
};

@$core.Deprecated('Use satSubsRespDescriptor instead')
const SatSubsResp_SatSubsError_ShapeReqError_Code$json = const {
  '1': 'Code',
  '2': const [
    const {'1': 'CODE_UNSPECIFIED', '2': 0},
    const {'1': 'TABLE_NOT_FOUND', '2': 1},
    const {'1': 'REFERENTIAL_INTEGRITY_VIOLATION', '2': 2},
    const {'1': 'EMPTY_SHAPE_DEFINITION', '2': 3},
    const {'1': 'DUPLICATE_TABLE_IN_SHAPE_DEFINITION', '2': 4},
  ],
};

@$core.Deprecated('Use satSubsRespDescriptor instead')
const SatSubsResp_SatSubsError_Code$json = const {
  '1': 'Code',
  '2': const [
    const {'1': 'CODE_UNSPECIFIED', '2': 0},
    const {'1': 'SUBSCRIPTION_ID_ALREADY_EXISTS', '2': 1},
    const {'1': 'SHAPE_REQUEST_ERROR', '2': 2},
  ],
};

/// Descriptor for `SatSubsResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satSubsRespDescriptor = $convert.base64Decode(
    'CgtTYXRTdWJzUmVzcBInCg9zdWJzY3JpcHRpb25faWQYASABKAlSDnN1YnNjcmlwdGlvbklkEkMKA2VychgCIAEoCzIsLkVsZWN0cmljLlNhdGVsbGl0ZS5TYXRTdWJzUmVzcC5TYXRTdWJzRXJyb3JIAFIDZXJyiAEBGvQECgxTYXRTdWJzRXJyb3ISRQoEY29kZRgCIAEoDjIxLkVsZWN0cmljLlNhdGVsbGl0ZS5TYXRTdWJzUmVzcC5TYXRTdWJzRXJyb3IuQ29kZVIEY29kZRIYCgdtZXNzYWdlGAMgASgJUgdtZXNzYWdlEmoKE3NoYXBlX3JlcXVlc3RfZXJyb3IYBCADKAsyOi5FbGVjdHJpYy5TYXRlbGxpdGUuU2F0U3Vic1Jlc3AuU2F0U3Vic0Vycm9yLlNoYXBlUmVxRXJyb3JSEXNoYXBlUmVxdWVzdEVycm9yGrsCCg1TaGFwZVJlcUVycm9yElMKBGNvZGUYASABKA4yPy5FbGVjdHJpYy5TYXRlbGxpdGUuU2F0U3Vic1Jlc3AuU2F0U3Vic0Vycm9yLlNoYXBlUmVxRXJyb3IuQ29kZVIEY29kZRIYCgdtZXNzYWdlGAIgASgJUgdtZXNzYWdlEh0KCnJlcXVlc3RfaWQYAyABKAlSCXJlcXVlc3RJZCKbAQoEQ29kZRIUChBDT0RFX1VOU1BFQ0lGSUVEEAASEwoPVEFCTEVfTk9UX0ZPVU5EEAESIwofUkVGRVJFTlRJQUxfSU5URUdSSVRZX1ZJT0xBVElPThACEhoKFkVNUFRZX1NIQVBFX0RFRklOSVRJT04QAxInCiNEVVBMSUNBVEVfVEFCTEVfSU5fU0hBUEVfREVGSU5JVElPThAEIlkKBENvZGUSFAoQQ09ERV9VTlNQRUNJRklFRBAAEiIKHlNVQlNDUklQVElPTl9JRF9BTFJFQURZX0VYSVNUUxABEhcKE1NIQVBFX1JFUVVFU1RfRVJST1IQAkIGCgRfZXJy');
@$core.Deprecated('Use satUnsubsReqDescriptor instead')
const SatUnsubsReq$json = const {
  '1': 'SatUnsubsReq',
  '2': const [
    const {
      '1': 'subscription_ids',
      '3': 1,
      '4': 3,
      '5': 9,
      '10': 'subscriptionIds'
    },
  ],
};

/// Descriptor for `SatUnsubsReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satUnsubsReqDescriptor = $convert.base64Decode(
    'CgxTYXRVbnN1YnNSZXESKQoQc3Vic2NyaXB0aW9uX2lkcxgBIAMoCVIPc3Vic2NyaXB0aW9uSWRz');
@$core.Deprecated('Use satUnsubsRespDescriptor instead')
const SatUnsubsResp$json = const {
  '1': 'SatUnsubsResp',
};

/// Descriptor for `SatUnsubsResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satUnsubsRespDescriptor =
    $convert.base64Decode('Cg1TYXRVbnN1YnNSZXNw');
@$core.Deprecated('Use satShapeReqDescriptor instead')
const SatShapeReq$json = const {
  '1': 'SatShapeReq',
  '2': const [
    const {'1': 'request_id', '3': 1, '4': 1, '5': 9, '10': 'requestId'},
    const {
      '1': 'shape_definition',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.Electric.Satellite.SatShapeDef',
      '10': 'shapeDefinition'
    },
  ],
};

/// Descriptor for `SatShapeReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satShapeReqDescriptor = $convert.base64Decode(
    'CgtTYXRTaGFwZVJlcRIdCgpyZXF1ZXN0X2lkGAEgASgJUglyZXF1ZXN0SWQSSgoQc2hhcGVfZGVmaW5pdGlvbhgCIAEoCzIfLkVsZWN0cmljLlNhdGVsbGl0ZS5TYXRTaGFwZURlZlIPc2hhcGVEZWZpbml0aW9u');
@$core.Deprecated('Use satShapeDefDescriptor instead')
const SatShapeDef$json = const {
  '1': 'SatShapeDef',
  '2': const [
    const {
      '1': 'selects',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.Electric.Satellite.SatShapeDef.Select',
      '10': 'selects'
    },
  ],
  '3': const [SatShapeDef_Select$json],
};

@$core.Deprecated('Use satShapeDefDescriptor instead')
const SatShapeDef_Select$json = const {
  '1': 'Select',
  '2': const [
    const {'1': 'tablename', '3': 1, '4': 1, '5': 9, '10': 'tablename'},
  ],
};

/// Descriptor for `SatShapeDef`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satShapeDefDescriptor = $convert.base64Decode(
    'CgtTYXRTaGFwZURlZhJACgdzZWxlY3RzGAEgAygLMiYuRWxlY3RyaWMuU2F0ZWxsaXRlLlNhdFNoYXBlRGVmLlNlbGVjdFIHc2VsZWN0cxomCgZTZWxlY3QSHAoJdGFibGVuYW1lGAEgASgJUgl0YWJsZW5hbWU=');
@$core.Deprecated('Use satSubsDataErrorDescriptor instead')
const SatSubsDataError$json = const {
  '1': 'SatSubsDataError',
  '2': const [
    const {
      '1': 'code',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.Electric.Satellite.SatSubsDataError.Code',
      '10': 'code'
    },
    const {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    const {
      '1': 'subscription_id',
      '3': 3,
      '4': 1,
      '5': 9,
      '10': 'subscriptionId'
    },
    const {
      '1': 'shape_request_error',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.Electric.Satellite.SatSubsDataError.ShapeReqError',
      '10': 'shapeRequestError'
    },
  ],
  '3': const [SatSubsDataError_ShapeReqError$json],
  '4': const [SatSubsDataError_Code$json],
};

@$core.Deprecated('Use satSubsDataErrorDescriptor instead')
const SatSubsDataError_ShapeReqError$json = const {
  '1': 'ShapeReqError',
  '2': const [
    const {
      '1': 'code',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.Electric.Satellite.SatSubsDataError.ShapeReqError.Code',
      '10': 'code'
    },
    const {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    const {'1': 'request_id', '3': 3, '4': 1, '5': 9, '10': 'requestId'},
  ],
  '4': const [SatSubsDataError_ShapeReqError_Code$json],
};

@$core.Deprecated('Use satSubsDataErrorDescriptor instead')
const SatSubsDataError_ShapeReqError_Code$json = const {
  '1': 'Code',
  '2': const [
    const {'1': 'CODE_UNSPECIFIED', '2': 0},
    const {'1': 'SHAPE_SIZE_LIMIT_EXCEEDED', '2': 1},
  ],
};

@$core.Deprecated('Use satSubsDataErrorDescriptor instead')
const SatSubsDataError_Code$json = const {
  '1': 'Code',
  '2': const [
    const {'1': 'CODE_UNSPECIFIED', '2': 0},
    const {'1': 'SHAPE_DELIVERY_ERROR', '2': 1},
  ],
};

/// Descriptor for `SatSubsDataError`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satSubsDataErrorDescriptor = $convert.base64Decode(
    'ChBTYXRTdWJzRGF0YUVycm9yEj0KBGNvZGUYASABKA4yKS5FbGVjdHJpYy5TYXRlbGxpdGUuU2F0U3Vic0RhdGFFcnJvci5Db2RlUgRjb2RlEhgKB21lc3NhZ2UYAiABKAlSB21lc3NhZ2USJwoPc3Vic2NyaXB0aW9uX2lkGAMgASgJUg5zdWJzY3JpcHRpb25JZBJiChNzaGFwZV9yZXF1ZXN0X2Vycm9yGAQgAygLMjIuRWxlY3RyaWMuU2F0ZWxsaXRlLlNhdFN1YnNEYXRhRXJyb3IuU2hhcGVSZXFFcnJvclIRc2hhcGVSZXF1ZXN0RXJyb3Ia0gEKDVNoYXBlUmVxRXJyb3ISSwoEY29kZRgBIAEoDjI3LkVsZWN0cmljLlNhdGVsbGl0ZS5TYXRTdWJzRGF0YUVycm9yLlNoYXBlUmVxRXJyb3IuQ29kZVIEY29kZRIYCgdtZXNzYWdlGAIgASgJUgdtZXNzYWdlEh0KCnJlcXVlc3RfaWQYAyABKAlSCXJlcXVlc3RJZCI7CgRDb2RlEhQKEENPREVfVU5TUEVDSUZJRUQQABIdChlTSEFQRV9TSVpFX0xJTUlUX0VYQ0VFREVEEAEiNgoEQ29kZRIUChBDT0RFX1VOU1BFQ0lGSUVEEAASGAoUU0hBUEVfREVMSVZFUllfRVJST1IQAQ==');
@$core.Deprecated('Use satSubsDataBeginDescriptor instead')
const SatSubsDataBegin$json = const {
  '1': 'SatSubsDataBegin',
  '2': const [
    const {
      '1': 'subscription_id',
      '3': 1,
      '4': 1,
      '5': 9,
      '10': 'subscriptionId'
    },
    const {'1': 'lsn', '3': 2, '4': 1, '5': 12, '10': 'lsn'},
  ],
};

/// Descriptor for `SatSubsDataBegin`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satSubsDataBeginDescriptor = $convert.base64Decode(
    'ChBTYXRTdWJzRGF0YUJlZ2luEicKD3N1YnNjcmlwdGlvbl9pZBgBIAEoCVIOc3Vic2NyaXB0aW9uSWQSEAoDbHNuGAIgASgMUgNsc24=');
@$core.Deprecated('Use satSubsDataEndDescriptor instead')
const SatSubsDataEnd$json = const {
  '1': 'SatSubsDataEnd',
};

/// Descriptor for `SatSubsDataEnd`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satSubsDataEndDescriptor =
    $convert.base64Decode('Cg5TYXRTdWJzRGF0YUVuZA==');
@$core.Deprecated('Use satShapeDataBeginDescriptor instead')
const SatShapeDataBegin$json = const {
  '1': 'SatShapeDataBegin',
  '2': const [
    const {'1': 'request_id', '3': 1, '4': 1, '5': 9, '10': 'requestId'},
    const {'1': 'uuid', '3': 2, '4': 1, '5': 9, '10': 'uuid'},
  ],
};

/// Descriptor for `SatShapeDataBegin`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satShapeDataBeginDescriptor = $convert.base64Decode(
    'ChFTYXRTaGFwZURhdGFCZWdpbhIdCgpyZXF1ZXN0X2lkGAEgASgJUglyZXF1ZXN0SWQSEgoEdXVpZBgCIAEoCVIEdXVpZA==');
@$core.Deprecated('Use satShapeDataEndDescriptor instead')
const SatShapeDataEnd$json = const {
  '1': 'SatShapeDataEnd',
};

/// Descriptor for `SatShapeDataEnd`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satShapeDataEndDescriptor =
    $convert.base64Decode('Cg9TYXRTaGFwZURhdGFFbmQ=');
