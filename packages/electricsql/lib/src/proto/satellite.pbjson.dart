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
    const {'1': 'PROTO_VERSION', '2': 1},
  ],
};

/// Descriptor for `SatAuthHeader`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List satAuthHeaderDescriptor = $convert.base64Decode(
    'Cg1TYXRBdXRoSGVhZGVyEg8KC1VOU1BFQ0lGSUVEEAASEQoNUFJPVE9fVkVSU0lPThAB');
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
      '6': '.Electric.Satellite.v1_4.SatAuthHeader',
      '10': 'key'
    },
    const {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
};

/// Descriptor for `SatAuthHeaderPair`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satAuthHeaderPairDescriptor = $convert.base64Decode(
    'ChFTYXRBdXRoSGVhZGVyUGFpchI4CgNrZXkYASABKA4yJi5FbGVjdHJpYy5TYXRlbGxpdGUudjFfNC5TYXRBdXRoSGVhZGVyUgNrZXkSFAoFdmFsdWUYAiABKAlSBXZhbHVl');
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
      '6': '.Electric.Satellite.v1_4.SatAuthHeaderPair',
      '10': 'headers'
    },
  ],
};

/// Descriptor for `SatAuthReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satAuthReqDescriptor = $convert.base64Decode(
    'CgpTYXRBdXRoUmVxEg4KAmlkGAEgASgJUgJpZBIUCgV0b2tlbhgCIAEoCVIFdG9rZW4SRAoHaGVhZGVycxgDIAMoCzIqLkVsZWN0cmljLlNhdGVsbGl0ZS52MV80LlNhdEF1dGhIZWFkZXJQYWlyUgdoZWFkZXJz');
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
      '6': '.Electric.Satellite.v1_4.SatAuthHeaderPair',
      '10': 'headers'
    },
  ],
};

/// Descriptor for `SatAuthResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satAuthRespDescriptor = $convert.base64Decode(
    'CgtTYXRBdXRoUmVzcBIOCgJpZBgBIAEoCVICaWQSRAoHaGVhZGVycxgDIAMoCzIqLkVsZWN0cmljLlNhdGVsbGl0ZS52MV80LlNhdEF1dGhIZWFkZXJQYWlyUgdoZWFkZXJz');
@$core.Deprecated('Use satErrorRespDescriptor instead')
const SatErrorResp$json = const {
  '1': 'SatErrorResp',
  '2': const [
    const {
      '1': 'error_type',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.Electric.Satellite.v1_4.SatErrorResp.ErrorCode',
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
    'CgxTYXRFcnJvclJlc3ASTgoKZXJyb3JfdHlwZRgBIAEoDjIvLkVsZWN0cmljLlNhdGVsbGl0ZS52MV80LlNhdEVycm9yUmVzcC5FcnJvckNvZGVSCWVycm9yVHlwZSKbAQoJRXJyb3JDb2RlEgwKCElOVEVSTkFMEAASEQoNQVVUSF9SRVFVSVJFRBABEg8KC0FVVEhfRkFJTEVEEAISFgoSUkVQTElDQVRJT05fRkFJTEVEEAMSEwoPSU5WQUxJRF9SRVFVRVNUEAQSFgoSUFJPVE9fVlNOX01JU01BVENIEAUSFwoTU0NIRU1BX1ZTTl9NSVNNQVRDSBAG');
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
      '6': '.Electric.Satellite.v1_4.SatInStartReplicationReq.Option',
      '10': 'options'
    },
    const {
      '1': 'sync_batch_size',
      '3': 3,
      '4': 1,
      '5': 5,
      '10': 'syncBatchSize'
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
};

@$core.Deprecated('Use satInStartReplicationReqDescriptor instead')
const SatInStartReplicationReq_Option$json = const {
  '1': 'Option',
  '2': const [
    const {'1': 'NONE', '2': 0},
    const {'1': 'SYNC_MODE', '2': 2},
  ],
  '4': const [
    const {'1': 1, '2': 1},
    const {'1': 3, '2': 3},
    const {'1': 4, '2': 4},
  ],
};

/// Descriptor for `SatInStartReplicationReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satInStartReplicationReqDescriptor =
    $convert.base64Decode(
        'ChhTYXRJblN0YXJ0UmVwbGljYXRpb25SZXESEAoDbHNuGAEgASgMUgNsc24SUgoHb3B0aW9ucxgCIAMoDjI4LkVsZWN0cmljLlNhdGVsbGl0ZS52MV80LlNhdEluU3RhcnRSZXBsaWNhdGlvblJlcS5PcHRpb25SB29wdGlvbnMSJgoPc3luY19iYXRjaF9zaXplGAMgASgFUg1zeW5jQmF0Y2hTaXplEikKEHN1YnNjcmlwdGlvbl9pZHMYBCADKAlSD3N1YnNjcmlwdGlvbklkcxIqCg5zY2hlbWFfdmVyc2lvbhgFIAEoCUgAUg1zY2hlbWFWZXJzaW9uiAEBIjMKBk9wdGlvbhIICgROT05FEAASDQoJU1lOQ19NT0RFEAIiBAgBEAEiBAgDEAMiBAgEEARCEQoPX3NjaGVtYV92ZXJzaW9u');
@$core.Deprecated('Use satInStartReplicationRespDescriptor instead')
const SatInStartReplicationResp$json = const {
  '1': 'SatInStartReplicationResp',
  '2': const [
    const {
      '1': 'err',
      '3': 1,
      '4': 1,
      '5': 11,
      '6':
          '.Electric.Satellite.v1_4.SatInStartReplicationResp.ReplicationError',
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
          '.Electric.Satellite.v1_4.SatInStartReplicationResp.ReplicationError.Code',
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
        'ChlTYXRJblN0YXJ0UmVwbGljYXRpb25SZXNwEloKA2VychgBIAEoCzJDLkVsZWN0cmljLlNhdGVsbGl0ZS52MV80LlNhdEluU3RhcnRSZXBsaWNhdGlvblJlc3AuUmVwbGljYXRpb25FcnJvckgAUgNlcnKIAQEamQIKEFJlcGxpY2F0aW9uRXJyb3ISXAoEY29kZRgBIAEoDjJILkVsZWN0cmljLlNhdGVsbGl0ZS52MV80LlNhdEluU3RhcnRSZXBsaWNhdGlvblJlc3AuUmVwbGljYXRpb25FcnJvci5Db2RlUgRjb2RlEhgKB21lc3NhZ2UYAiABKAlSB21lc3NhZ2UijAEKBENvZGUSFAoQQ09ERV9VTlNQRUNJRklFRBAAEhEKDUJFSElORF9XSU5ET1cQARIUChBJTlZBTElEX1BPU0lUSU9OEAISGgoWU1VCU0NSSVBUSU9OX05PVF9GT1VORBADEhEKDU1BTEZPUk1FRF9MU04QBBIWChJVTktOT1dOX1NDSEVNQV9WU04QBUIGCgRfZXJy');
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
      '6': '.Electric.Satellite.v1_4.SatRelation.RelationType',
      '10': 'tableType'
    },
    const {'1': 'table_name', '3': 3, '4': 1, '5': 9, '10': 'tableName'},
    const {'1': 'relation_id', '3': 4, '4': 1, '5': 13, '10': 'relationId'},
    const {
      '1': 'columns',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.Electric.Satellite.v1_4.SatRelationColumn',
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
    'CgtTYXRSZWxhdGlvbhIfCgtzY2hlbWFfbmFtZRgBIAEoCVIKc2NoZW1hTmFtZRJQCgp0YWJsZV90eXBlGAIgASgOMjEuRWxlY3RyaWMuU2F0ZWxsaXRlLnYxXzQuU2F0UmVsYXRpb24uUmVsYXRpb25UeXBlUgl0YWJsZVR5cGUSHQoKdGFibGVfbmFtZRgDIAEoCVIJdGFibGVOYW1lEh8KC3JlbGF0aW9uX2lkGAQgASgNUgpyZWxhdGlvbklkEkQKB2NvbHVtbnMYBSADKAsyKi5FbGVjdHJpYy5TYXRlbGxpdGUudjFfNC5TYXRSZWxhdGlvbkNvbHVtblIHY29sdW1ucyI7CgxSZWxhdGlvblR5cGUSCQoFVEFCTEUQABIJCgVJTkRFWBABEggKBFZJRVcQAhILCgdUUklHR0VSEAM=');
@$core.Deprecated('Use satOpLogDescriptor instead')
const SatOpLog$json = const {
  '1': 'SatOpLog',
  '2': const [
    const {
      '1': 'ops',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.Electric.Satellite.v1_4.SatTransOp',
      '10': 'ops'
    },
  ],
};

/// Descriptor for `SatOpLog`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satOpLogDescriptor = $convert.base64Decode(
    'CghTYXRPcExvZxI1CgNvcHMYASADKAsyIy5FbGVjdHJpYy5TYXRlbGxpdGUudjFfNC5TYXRUcmFuc09wUgNvcHM=');
@$core.Deprecated('Use satTransOpDescriptor instead')
const SatTransOp$json = const {
  '1': 'SatTransOp',
  '2': const [
    const {
      '1': 'begin',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.Electric.Satellite.v1_4.SatOpBegin',
      '9': 0,
      '10': 'begin'
    },
    const {
      '1': 'commit',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.Electric.Satellite.v1_4.SatOpCommit',
      '9': 0,
      '10': 'commit'
    },
    const {
      '1': 'update',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.Electric.Satellite.v1_4.SatOpUpdate',
      '9': 0,
      '10': 'update'
    },
    const {
      '1': 'insert',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.Electric.Satellite.v1_4.SatOpInsert',
      '9': 0,
      '10': 'insert'
    },
    const {
      '1': 'delete',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.Electric.Satellite.v1_4.SatOpDelete',
      '9': 0,
      '10': 'delete'
    },
    const {
      '1': 'migrate',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.Electric.Satellite.v1_4.SatOpMigrate',
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
    'CgpTYXRUcmFuc09wEjsKBWJlZ2luGAEgASgLMiMuRWxlY3RyaWMuU2F0ZWxsaXRlLnYxXzQuU2F0T3BCZWdpbkgAUgViZWdpbhI+CgZjb21taXQYAiABKAsyJC5FbGVjdHJpYy5TYXRlbGxpdGUudjFfNC5TYXRPcENvbW1pdEgAUgZjb21taXQSPgoGdXBkYXRlGAMgASgLMiQuRWxlY3RyaWMuU2F0ZWxsaXRlLnYxXzQuU2F0T3BVcGRhdGVIAFIGdXBkYXRlEj4KBmluc2VydBgEIAEoCzIkLkVsZWN0cmljLlNhdGVsbGl0ZS52MV80LlNhdE9wSW5zZXJ0SABSBmluc2VydBI+CgZkZWxldGUYBSABKAsyJC5FbGVjdHJpYy5TYXRlbGxpdGUudjFfNC5TYXRPcERlbGV0ZUgAUgZkZWxldGUSQQoHbWlncmF0ZRgGIAEoCzIlLkVsZWN0cmljLlNhdGVsbGl0ZS52MV80LlNhdE9wTWlncmF0ZUgAUgdtaWdyYXRlQgQKAm9w');
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
      '6': '.Electric.Satellite.v1_4.SatOpRow',
      '10': 'rowData'
    },
    const {'1': 'tags', '3': 3, '4': 3, '5': 9, '10': 'tags'},
  ],
};

/// Descriptor for `SatOpInsert`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satOpInsertDescriptor = $convert.base64Decode(
    'CgtTYXRPcEluc2VydBIfCgtyZWxhdGlvbl9pZBgBIAEoDVIKcmVsYXRpb25JZBI8Cghyb3dfZGF0YRgCIAEoCzIhLkVsZWN0cmljLlNhdGVsbGl0ZS52MV80LlNhdE9wUm93Ugdyb3dEYXRhEhIKBHRhZ3MYAyADKAlSBHRhZ3M=');
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
      '6': '.Electric.Satellite.v1_4.SatOpRow',
      '10': 'rowData'
    },
    const {
      '1': 'old_row_data',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.Electric.Satellite.v1_4.SatOpRow',
      '10': 'oldRowData'
    },
    const {'1': 'tags', '3': 4, '4': 3, '5': 9, '10': 'tags'},
  ],
};

/// Descriptor for `SatOpUpdate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satOpUpdateDescriptor = $convert.base64Decode(
    'CgtTYXRPcFVwZGF0ZRIfCgtyZWxhdGlvbl9pZBgBIAEoDVIKcmVsYXRpb25JZBI8Cghyb3dfZGF0YRgCIAEoCzIhLkVsZWN0cmljLlNhdGVsbGl0ZS52MV80LlNhdE9wUm93Ugdyb3dEYXRhEkMKDG9sZF9yb3dfZGF0YRgDIAEoCzIhLkVsZWN0cmljLlNhdGVsbGl0ZS52MV80LlNhdE9wUm93UgpvbGRSb3dEYXRhEhIKBHRhZ3MYBCADKAlSBHRhZ3M=');
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
      '6': '.Electric.Satellite.v1_4.SatOpRow',
      '10': 'oldRowData'
    },
    const {'1': 'tags', '3': 3, '4': 3, '5': 9, '10': 'tags'},
  ],
};

/// Descriptor for `SatOpDelete`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satOpDeleteDescriptor = $convert.base64Decode(
    'CgtTYXRPcERlbGV0ZRIfCgtyZWxhdGlvbl9pZBgBIAEoDVIKcmVsYXRpb25JZBJDCgxvbGRfcm93X2RhdGEYAiABKAsyIS5FbGVjdHJpYy5TYXRlbGxpdGUudjFfNC5TYXRPcFJvd1IKb2xkUm93RGF0YRISCgR0YWdzGAMgAygJUgR0YWdz');
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
      '6': '.Electric.Satellite.v1_4.SatOpMigrate.Stmt',
      '10': 'stmts'
    },
    const {
      '1': 'table',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.Electric.Satellite.v1_4.SatOpMigrate.Table',
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
      '6': '.Electric.Satellite.v1_4.SatOpMigrate.Type',
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
      '6': '.Electric.Satellite.v1_4.SatOpMigrate.PgColumnType',
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
      '6': '.Electric.Satellite.v1_4.SatOpMigrate.Column',
      '10': 'columns'
    },
    const {
      '1': 'fks',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.Electric.Satellite.v1_4.SatOpMigrate.ForeignKey',
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
    'CgxTYXRPcE1pZ3JhdGUSGAoHdmVyc2lvbhgBIAEoCVIHdmVyc2lvbhJACgVzdG10cxgCIAMoCzIqLkVsZWN0cmljLlNhdGVsbGl0ZS52MV80LlNhdE9wTWlncmF0ZS5TdG10UgVzdG10cxJGCgV0YWJsZRgDIAEoCzIrLkVsZWN0cmljLlNhdGVsbGl0ZS52MV80LlNhdE9wTWlncmF0ZS5UYWJsZUgAUgV0YWJsZYgBARpYCgRTdG10Ej4KBHR5cGUYASABKA4yKi5FbGVjdHJpYy5TYXRlbGxpdGUudjFfNC5TYXRPcE1pZ3JhdGUuVHlwZVIEdHlwZRIQCgNzcWwYAiABKAlSA3NxbBpMCgxQZ0NvbHVtblR5cGUSEgoEbmFtZRgBIAEoCVIEbmFtZRIUCgVhcnJheRgCIAMoBVIFYXJyYXkSEgoEc2l6ZRgDIAMoBVIEc2l6ZRqKAQoGQ29sdW1uEhIKBG5hbWUYASABKAlSBG5hbWUSHwoLc3FsaXRlX3R5cGUYAiABKAlSCnNxbGl0ZVR5cGUSSwoHcGdfdHlwZRgDIAEoCzIyLkVsZWN0cmljLlNhdGVsbGl0ZS52MV80LlNhdE9wTWlncmF0ZS5QZ0NvbHVtblR5cGVSBnBnVHlwZRpZCgpGb3JlaWduS2V5EhcKB2ZrX2NvbHMYASADKAlSBmZrQ29scxIZCghwa190YWJsZRgCIAEoCVIHcGtUYWJsZRIXCgdwa19jb2xzGAMgAygJUgZwa0NvbHMauQEKBVRhYmxlEhIKBG5hbWUYASABKAlSBG5hbWUSRgoHY29sdW1ucxgCIAMoCzIsLkVsZWN0cmljLlNhdGVsbGl0ZS52MV80LlNhdE9wTWlncmF0ZS5Db2x1bW5SB2NvbHVtbnMSQgoDZmtzGAMgAygLMjAuRWxlY3RyaWMuU2F0ZWxsaXRlLnYxXzQuU2F0T3BNaWdyYXRlLkZvcmVpZ25LZXlSA2ZrcxIQCgNwa3MYBCADKAlSA3BrcyJACgRUeXBlEhAKDENSRUFURV9UQUJMRRAAEhAKDENSRUFURV9JTkRFWBABEhQKEEFMVEVSX0FERF9DT0xVTU4QBkIICgZfdGFibGU=');
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
      '6': '.Electric.Satellite.v1_4.SatShapeReq',
      '10': 'shapeRequests'
    },
  ],
};

/// Descriptor for `SatSubsReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satSubsReqDescriptor = $convert.base64Decode(
    'CgpTYXRTdWJzUmVxEicKD3N1YnNjcmlwdGlvbl9pZBgBIAEoCVIOc3Vic2NyaXB0aW9uSWQSSwoOc2hhcGVfcmVxdWVzdHMYAiADKAsyJC5FbGVjdHJpYy5TYXRlbGxpdGUudjFfNC5TYXRTaGFwZVJlcVINc2hhcGVSZXF1ZXN0cw==');
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
      '6': '.Electric.Satellite.v1_4.SatSubsResp.SatSubsError',
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
      '6': '.Electric.Satellite.v1_4.SatSubsResp.SatSubsError.Code',
      '10': 'code'
    },
    const {'1': 'message', '3': 3, '4': 1, '5': 9, '10': 'message'},
    const {
      '1': 'shape_request_error',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.Electric.Satellite.v1_4.SatSubsResp.SatSubsError.ShapeReqError',
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
      '6':
          '.Electric.Satellite.v1_4.SatSubsResp.SatSubsError.ShapeReqError.Code',
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
    'CgtTYXRTdWJzUmVzcBInCg9zdWJzY3JpcHRpb25faWQYASABKAlSDnN1YnNjcmlwdGlvbklkEkgKA2VychgCIAEoCzIxLkVsZWN0cmljLlNhdGVsbGl0ZS52MV80LlNhdFN1YnNSZXNwLlNhdFN1YnNFcnJvckgAUgNlcnKIAQEagwUKDFNhdFN1YnNFcnJvchJKCgRjb2RlGAIgASgOMjYuRWxlY3RyaWMuU2F0ZWxsaXRlLnYxXzQuU2F0U3Vic1Jlc3AuU2F0U3Vic0Vycm9yLkNvZGVSBGNvZGUSGAoHbWVzc2FnZRgDIAEoCVIHbWVzc2FnZRJvChNzaGFwZV9yZXF1ZXN0X2Vycm9yGAQgAygLMj8uRWxlY3RyaWMuU2F0ZWxsaXRlLnYxXzQuU2F0U3Vic1Jlc3AuU2F0U3Vic0Vycm9yLlNoYXBlUmVxRXJyb3JSEXNoYXBlUmVxdWVzdEVycm9yGsACCg1TaGFwZVJlcUVycm9yElgKBGNvZGUYASABKA4yRC5FbGVjdHJpYy5TYXRlbGxpdGUudjFfNC5TYXRTdWJzUmVzcC5TYXRTdWJzRXJyb3IuU2hhcGVSZXFFcnJvci5Db2RlUgRjb2RlEhgKB21lc3NhZ2UYAiABKAlSB21lc3NhZ2USHQoKcmVxdWVzdF9pZBgDIAEoCVIJcmVxdWVzdElkIpsBCgRDb2RlEhQKEENPREVfVU5TUEVDSUZJRUQQABITCg9UQUJMRV9OT1RfRk9VTkQQARIjCh9SRUZFUkVOVElBTF9JTlRFR1JJVFlfVklPTEFUSU9OEAISGgoWRU1QVFlfU0hBUEVfREVGSU5JVElPThADEicKI0RVUExJQ0FURV9UQUJMRV9JTl9TSEFQRV9ERUZJTklUSU9OEAQiWQoEQ29kZRIUChBDT0RFX1VOU1BFQ0lGSUVEEAASIgoeU1VCU0NSSVBUSU9OX0lEX0FMUkVBRFlfRVhJU1RTEAESFwoTU0hBUEVfUkVRVUVTVF9FUlJPUhACQgYKBF9lcnI=');
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
      '6': '.Electric.Satellite.v1_4.SatShapeDef',
      '10': 'shapeDefinition'
    },
  ],
};

/// Descriptor for `SatShapeReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satShapeReqDescriptor = $convert.base64Decode(
    'CgtTYXRTaGFwZVJlcRIdCgpyZXF1ZXN0X2lkGAEgASgJUglyZXF1ZXN0SWQSTwoQc2hhcGVfZGVmaW5pdGlvbhgCIAEoCzIkLkVsZWN0cmljLlNhdGVsbGl0ZS52MV80LlNhdFNoYXBlRGVmUg9zaGFwZURlZmluaXRpb24=');
@$core.Deprecated('Use satShapeDefDescriptor instead')
const SatShapeDef$json = const {
  '1': 'SatShapeDef',
  '2': const [
    const {
      '1': 'selects',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.Electric.Satellite.v1_4.SatShapeDef.Select',
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
    'CgtTYXRTaGFwZURlZhJFCgdzZWxlY3RzGAEgAygLMisuRWxlY3RyaWMuU2F0ZWxsaXRlLnYxXzQuU2F0U2hhcGVEZWYuU2VsZWN0UgdzZWxlY3RzGiYKBlNlbGVjdBIcCgl0YWJsZW5hbWUYASABKAlSCXRhYmxlbmFtZQ==');
@$core.Deprecated('Use satSubsDataErrorDescriptor instead')
const SatSubsDataError$json = const {
  '1': 'SatSubsDataError',
  '2': const [
    const {
      '1': 'code',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.Electric.Satellite.v1_4.SatSubsDataError.Code',
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
      '6': '.Electric.Satellite.v1_4.SatSubsDataError.ShapeReqError',
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
      '6': '.Electric.Satellite.v1_4.SatSubsDataError.ShapeReqError.Code',
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
    'ChBTYXRTdWJzRGF0YUVycm9yEkIKBGNvZGUYASABKA4yLi5FbGVjdHJpYy5TYXRlbGxpdGUudjFfNC5TYXRTdWJzRGF0YUVycm9yLkNvZGVSBGNvZGUSGAoHbWVzc2FnZRgCIAEoCVIHbWVzc2FnZRInCg9zdWJzY3JpcHRpb25faWQYAyABKAlSDnN1YnNjcmlwdGlvbklkEmcKE3NoYXBlX3JlcXVlc3RfZXJyb3IYBCADKAsyNy5FbGVjdHJpYy5TYXRlbGxpdGUudjFfNC5TYXRTdWJzRGF0YUVycm9yLlNoYXBlUmVxRXJyb3JSEXNoYXBlUmVxdWVzdEVycm9yGtcBCg1TaGFwZVJlcUVycm9yElAKBGNvZGUYASABKA4yPC5FbGVjdHJpYy5TYXRlbGxpdGUudjFfNC5TYXRTdWJzRGF0YUVycm9yLlNoYXBlUmVxRXJyb3IuQ29kZVIEY29kZRIYCgdtZXNzYWdlGAIgASgJUgdtZXNzYWdlEh0KCnJlcXVlc3RfaWQYAyABKAlSCXJlcXVlc3RJZCI7CgRDb2RlEhQKEENPREVfVU5TUEVDSUZJRUQQABIdChlTSEFQRV9TSVpFX0xJTUlUX0VYQ0VFREVEEAEiNgoEQ29kZRIUChBDT0RFX1VOU1BFQ0lGSUVEEAASGAoUU0hBUEVfREVMSVZFUllfRVJST1IQAQ==');
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
