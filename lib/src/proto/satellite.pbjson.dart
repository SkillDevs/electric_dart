//
//  Generated code. Do not modify.
//  source: proto/satellite.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use satAuthHeaderDescriptor instead')
const SatAuthHeader$json = {
  '1': 'SatAuthHeader',
  '2': [
    {'1': 'UNSPECIFIED', '2': 0},
    {'1': 'PROTO_VERSION', '2': 1},
    {'1': 'SCHEMA_VERSION', '2': 2},
  ],
};

/// Descriptor for `SatAuthHeader`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List satAuthHeaderDescriptor = $convert.base64Decode(
    'Cg1TYXRBdXRoSGVhZGVyEg8KC1VOU1BFQ0lGSUVEEAASEQoNUFJPVE9fVkVSU0lPThABEhIKDl'
    'NDSEVNQV9WRVJTSU9OEAI=');

@$core.Deprecated('Use satPingReqDescriptor instead')
const SatPingReq$json = {
  '1': 'SatPingReq',
};

/// Descriptor for `SatPingReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satPingReqDescriptor =
    $convert.base64Decode('CgpTYXRQaW5nUmVx');

@$core.Deprecated('Use satPingRespDescriptor instead')
const SatPingResp$json = {
  '1': 'SatPingResp',
  '2': [
    {'1': 'lsn', '3': 1, '4': 1, '5': 12, '9': 0, '10': 'lsn', '17': true},
  ],
  '8': [
    {'1': '_lsn'},
  ],
};

/// Descriptor for `SatPingResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satPingRespDescriptor = $convert.base64Decode(
    'CgtTYXRQaW5nUmVzcBIVCgNsc24YASABKAxIAFIDbHNuiAEBQgYKBF9sc24=');

@$core.Deprecated('Use satAuthHeaderPairDescriptor instead')
const SatAuthHeaderPair$json = {
  '1': 'SatAuthHeaderPair',
  '2': [
    {
      '1': 'key',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.Electric.Satellite.v1_4.SatAuthHeader',
      '10': 'key'
    },
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
};

/// Descriptor for `SatAuthHeaderPair`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satAuthHeaderPairDescriptor = $convert.base64Decode(
    'ChFTYXRBdXRoSGVhZGVyUGFpchI4CgNrZXkYASABKA4yJi5FbGVjdHJpYy5TYXRlbGxpdGUudj'
    'FfNC5TYXRBdXRoSGVhZGVyUgNrZXkSFAoFdmFsdWUYAiABKAlSBXZhbHVl');

@$core.Deprecated('Use satAuthReqDescriptor instead')
const SatAuthReq$json = {
  '1': 'SatAuthReq',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'token', '3': 2, '4': 1, '5': 9, '10': 'token'},
    {
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
    'CgpTYXRBdXRoUmVxEg4KAmlkGAEgASgJUgJpZBIUCgV0b2tlbhgCIAEoCVIFdG9rZW4SRAoHaG'
    'VhZGVycxgDIAMoCzIqLkVsZWN0cmljLlNhdGVsbGl0ZS52MV80LlNhdEF1dGhIZWFkZXJQYWly'
    'UgdoZWFkZXJz');

@$core.Deprecated('Use satAuthRespDescriptor instead')
const SatAuthResp$json = {
  '1': 'SatAuthResp',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
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
    'CgtTYXRBdXRoUmVzcBIOCgJpZBgBIAEoCVICaWQSRAoHaGVhZGVycxgDIAMoCzIqLkVsZWN0cm'
    'ljLlNhdGVsbGl0ZS52MV80LlNhdEF1dGhIZWFkZXJQYWlyUgdoZWFkZXJz');

@$core.Deprecated('Use satErrorRespDescriptor instead')
const SatErrorResp$json = {
  '1': 'SatErrorResp',
  '2': [
    {
      '1': 'error_type',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.Electric.Satellite.v1_4.SatErrorResp.ErrorCode',
      '10': 'errorType'
    },
  ],
  '4': [SatErrorResp_ErrorCode$json],
};

@$core.Deprecated('Use satErrorRespDescriptor instead')
const SatErrorResp_ErrorCode$json = {
  '1': 'ErrorCode',
  '2': [
    {'1': 'INTERNAL', '2': 0},
    {'1': 'AUTH_REQUIRED', '2': 1},
    {'1': 'AUTH_FAILED', '2': 2},
    {'1': 'REPLICATION_FAILED', '2': 3},
    {'1': 'INVALID_REQUEST', '2': 4},
    {'1': 'PROTO_VSN_MISSMATCH', '2': 5},
    {'1': 'SCHEMA_VSN_MISSMATCH', '2': 6},
  ],
};

/// Descriptor for `SatErrorResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satErrorRespDescriptor = $convert.base64Decode(
    'CgxTYXRFcnJvclJlc3ASTgoKZXJyb3JfdHlwZRgBIAEoDjIvLkVsZWN0cmljLlNhdGVsbGl0ZS'
    '52MV80LlNhdEVycm9yUmVzcC5FcnJvckNvZGVSCWVycm9yVHlwZSKdAQoJRXJyb3JDb2RlEgwK'
    'CElOVEVSTkFMEAASEQoNQVVUSF9SRVFVSVJFRBABEg8KC0FVVEhfRkFJTEVEEAISFgoSUkVQTE'
    'lDQVRJT05fRkFJTEVEEAMSEwoPSU5WQUxJRF9SRVFVRVNUEAQSFwoTUFJPVE9fVlNOX01JU1NN'
    'QVRDSBAFEhgKFFNDSEVNQV9WU05fTUlTU01BVENIEAY=');

@$core.Deprecated('Use satInStartReplicationReqDescriptor instead')
const SatInStartReplicationReq$json = {
  '1': 'SatInStartReplicationReq',
  '2': [
    {'1': 'lsn', '3': 1, '4': 1, '5': 12, '10': 'lsn'},
    {
      '1': 'options',
      '3': 2,
      '4': 3,
      '5': 14,
      '6': '.Electric.Satellite.v1_4.SatInStartReplicationReq.Option',
      '10': 'options'
    },
    {'1': 'sync_batch_size', '3': 3, '4': 1, '5': 5, '10': 'syncBatchSize'},
    {'1': 'subscription_ids', '3': 4, '4': 3, '5': 9, '10': 'subscriptionIds'},
  ],
  '4': [SatInStartReplicationReq_Option$json],
};

@$core.Deprecated('Use satInStartReplicationReqDescriptor instead')
const SatInStartReplicationReq_Option$json = {
  '1': 'Option',
  '2': [
    {'1': 'NONE', '2': 0},
    {'1': 'LAST_ACKNOWLEDGED', '2': 1},
    {'1': 'SYNC_MODE', '2': 2},
    {'1': 'FIRST_LSN', '2': 3},
    {'1': 'LAST_LSN', '2': 4},
  ],
};

/// Descriptor for `SatInStartReplicationReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satInStartReplicationReqDescriptor = $convert.base64Decode(
    'ChhTYXRJblN0YXJ0UmVwbGljYXRpb25SZXESEAoDbHNuGAEgASgMUgNsc24SUgoHb3B0aW9ucx'
    'gCIAMoDjI4LkVsZWN0cmljLlNhdGVsbGl0ZS52MV80LlNhdEluU3RhcnRSZXBsaWNhdGlvblJl'
    'cS5PcHRpb25SB29wdGlvbnMSJgoPc3luY19iYXRjaF9zaXplGAMgASgFUg1zeW5jQmF0Y2hTaX'
    'plEikKEHN1YnNjcmlwdGlvbl9pZHMYBCADKAlSD3N1YnNjcmlwdGlvbklkcyJVCgZPcHRpb24S'
    'CAoETk9ORRAAEhUKEUxBU1RfQUNLTk9XTEVER0VEEAESDQoJU1lOQ19NT0RFEAISDQoJRklSU1'
    'RfTFNOEAMSDAoITEFTVF9MU04QBA==');

@$core.Deprecated('Use satInStartReplicationRespDescriptor instead')
const SatInStartReplicationResp$json = {
  '1': 'SatInStartReplicationResp',
  '2': [
    {
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
  '3': [SatInStartReplicationResp_ReplicationError$json],
  '8': [
    {'1': '_err'},
  ],
};

@$core.Deprecated('Use satInStartReplicationRespDescriptor instead')
const SatInStartReplicationResp_ReplicationError$json = {
  '1': 'ReplicationError',
  '2': [
    {
      '1': 'code',
      '3': 1,
      '4': 1,
      '5': 14,
      '6':
          '.Electric.Satellite.v1_4.SatInStartReplicationResp.ReplicationError.Code',
      '10': 'code'
    },
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
  ],
  '4': [SatInStartReplicationResp_ReplicationError_Code$json],
};

@$core.Deprecated('Use satInStartReplicationRespDescriptor instead')
const SatInStartReplicationResp_ReplicationError_Code$json = {
  '1': 'Code',
  '2': [
    {'1': 'CODE_UNSPECIFIED', '2': 0},
    {'1': 'BEHIND_WINDOW', '2': 1},
    {'1': 'INVALID_POSITION', '2': 2},
    {'1': 'SUBSCRIPTION_NOT_FOUND', '2': 3},
  ],
};

/// Descriptor for `SatInStartReplicationResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satInStartReplicationRespDescriptor = $convert.base64Decode(
    'ChlTYXRJblN0YXJ0UmVwbGljYXRpb25SZXNwEloKA2VychgBIAEoCzJDLkVsZWN0cmljLlNhdG'
    'VsbGl0ZS52MV80LlNhdEluU3RhcnRSZXBsaWNhdGlvblJlc3AuUmVwbGljYXRpb25FcnJvckgA'
    'UgNlcnKIAQEa7QEKEFJlcGxpY2F0aW9uRXJyb3ISXAoEY29kZRgBIAEoDjJILkVsZWN0cmljLl'
    'NhdGVsbGl0ZS52MV80LlNhdEluU3RhcnRSZXBsaWNhdGlvblJlc3AuUmVwbGljYXRpb25FcnJv'
    'ci5Db2RlUgRjb2RlEhgKB21lc3NhZ2UYAiABKAlSB21lc3NhZ2UiYQoEQ29kZRIUChBDT0RFX1'
    'VOU1BFQ0lGSUVEEAASEQoNQkVISU5EX1dJTkRPVxABEhQKEElOVkFMSURfUE9TSVRJT04QAhIa'
    'ChZTVUJTQ1JJUFRJT05fTk9UX0ZPVU5EEANCBgoEX2Vycg==');

@$core.Deprecated('Use satInStopReplicationReqDescriptor instead')
const SatInStopReplicationReq$json = {
  '1': 'SatInStopReplicationReq',
};

/// Descriptor for `SatInStopReplicationReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satInStopReplicationReqDescriptor =
    $convert.base64Decode('ChdTYXRJblN0b3BSZXBsaWNhdGlvblJlcQ==');

@$core.Deprecated('Use satInStopReplicationRespDescriptor instead')
const SatInStopReplicationResp$json = {
  '1': 'SatInStopReplicationResp',
};

/// Descriptor for `SatInStopReplicationResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satInStopReplicationRespDescriptor =
    $convert.base64Decode('ChhTYXRJblN0b3BSZXBsaWNhdGlvblJlc3A=');

@$core.Deprecated('Use satRelationColumnDescriptor instead')
const SatRelationColumn$json = {
  '1': 'SatRelationColumn',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'type', '3': 2, '4': 1, '5': 9, '10': 'type'},
    {'1': 'primaryKey', '3': 3, '4': 1, '5': 8, '10': 'primaryKey'},
  ],
};

/// Descriptor for `SatRelationColumn`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satRelationColumnDescriptor = $convert.base64Decode(
    'ChFTYXRSZWxhdGlvbkNvbHVtbhISCgRuYW1lGAEgASgJUgRuYW1lEhIKBHR5cGUYAiABKAlSBH'
    'R5cGUSHgoKcHJpbWFyeUtleRgDIAEoCFIKcHJpbWFyeUtleQ==');

@$core.Deprecated('Use satRelationDescriptor instead')
const SatRelation$json = {
  '1': 'SatRelation',
  '2': [
    {'1': 'schema_name', '3': 1, '4': 1, '5': 9, '10': 'schemaName'},
    {
      '1': 'table_type',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.Electric.Satellite.v1_4.SatRelation.RelationType',
      '10': 'tableType'
    },
    {'1': 'table_name', '3': 3, '4': 1, '5': 9, '10': 'tableName'},
    {'1': 'relation_id', '3': 4, '4': 1, '5': 13, '10': 'relationId'},
    {
      '1': 'columns',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.Electric.Satellite.v1_4.SatRelationColumn',
      '10': 'columns'
    },
  ],
  '4': [SatRelation_RelationType$json],
};

@$core.Deprecated('Use satRelationDescriptor instead')
const SatRelation_RelationType$json = {
  '1': 'RelationType',
  '2': [
    {'1': 'TABLE', '2': 0},
    {'1': 'INDEX', '2': 1},
    {'1': 'VIEW', '2': 2},
    {'1': 'TRIGGER', '2': 3},
  ],
};

/// Descriptor for `SatRelation`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satRelationDescriptor = $convert.base64Decode(
    'CgtTYXRSZWxhdGlvbhIfCgtzY2hlbWFfbmFtZRgBIAEoCVIKc2NoZW1hTmFtZRJQCgp0YWJsZV'
    '90eXBlGAIgASgOMjEuRWxlY3RyaWMuU2F0ZWxsaXRlLnYxXzQuU2F0UmVsYXRpb24uUmVsYXRp'
    'b25UeXBlUgl0YWJsZVR5cGUSHQoKdGFibGVfbmFtZRgDIAEoCVIJdGFibGVOYW1lEh8KC3JlbG'
    'F0aW9uX2lkGAQgASgNUgpyZWxhdGlvbklkEkQKB2NvbHVtbnMYBSADKAsyKi5FbGVjdHJpYy5T'
    'YXRlbGxpdGUudjFfNC5TYXRSZWxhdGlvbkNvbHVtblIHY29sdW1ucyI7CgxSZWxhdGlvblR5cG'
    'USCQoFVEFCTEUQABIJCgVJTkRFWBABEggKBFZJRVcQAhILCgdUUklHR0VSEAM=');

@$core.Deprecated('Use satOpLogDescriptor instead')
const SatOpLog$json = {
  '1': 'SatOpLog',
  '2': [
    {
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
    'CghTYXRPcExvZxI1CgNvcHMYASADKAsyIy5FbGVjdHJpYy5TYXRlbGxpdGUudjFfNC5TYXRUcm'
    'Fuc09wUgNvcHM=');

@$core.Deprecated('Use satTransOpDescriptor instead')
const SatTransOp$json = {
  '1': 'SatTransOp',
  '2': [
    {
      '1': 'begin',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.Electric.Satellite.v1_4.SatOpBegin',
      '9': 0,
      '10': 'begin'
    },
    {
      '1': 'commit',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.Electric.Satellite.v1_4.SatOpCommit',
      '9': 0,
      '10': 'commit'
    },
    {
      '1': 'update',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.Electric.Satellite.v1_4.SatOpUpdate',
      '9': 0,
      '10': 'update'
    },
    {
      '1': 'insert',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.Electric.Satellite.v1_4.SatOpInsert',
      '9': 0,
      '10': 'insert'
    },
    {
      '1': 'delete',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.Electric.Satellite.v1_4.SatOpDelete',
      '9': 0,
      '10': 'delete'
    },
    {
      '1': 'migrate',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.Electric.Satellite.v1_4.SatOpMigrate',
      '9': 0,
      '10': 'migrate'
    },
  ],
  '8': [
    {'1': 'op'},
  ],
};

/// Descriptor for `SatTransOp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satTransOpDescriptor = $convert.base64Decode(
    'CgpTYXRUcmFuc09wEjsKBWJlZ2luGAEgASgLMiMuRWxlY3RyaWMuU2F0ZWxsaXRlLnYxXzQuU2'
    'F0T3BCZWdpbkgAUgViZWdpbhI+CgZjb21taXQYAiABKAsyJC5FbGVjdHJpYy5TYXRlbGxpdGUu'
    'djFfNC5TYXRPcENvbW1pdEgAUgZjb21taXQSPgoGdXBkYXRlGAMgASgLMiQuRWxlY3RyaWMuU2'
    'F0ZWxsaXRlLnYxXzQuU2F0T3BVcGRhdGVIAFIGdXBkYXRlEj4KBmluc2VydBgEIAEoCzIkLkVs'
    'ZWN0cmljLlNhdGVsbGl0ZS52MV80LlNhdE9wSW5zZXJ0SABSBmluc2VydBI+CgZkZWxldGUYBS'
    'ABKAsyJC5FbGVjdHJpYy5TYXRlbGxpdGUudjFfNC5TYXRPcERlbGV0ZUgAUgZkZWxldGUSQQoH'
    'bWlncmF0ZRgGIAEoCzIlLkVsZWN0cmljLlNhdGVsbGl0ZS52MV80LlNhdE9wTWlncmF0ZUgAUg'
    'dtaWdyYXRlQgQKAm9w');

@$core.Deprecated('Use satOpBeginDescriptor instead')
const SatOpBegin$json = {
  '1': 'SatOpBegin',
  '2': [
    {'1': 'commit_timestamp', '3': 1, '4': 1, '5': 4, '10': 'commitTimestamp'},
    {'1': 'trans_id', '3': 2, '4': 1, '5': 9, '10': 'transId'},
    {'1': 'lsn', '3': 3, '4': 1, '5': 12, '10': 'lsn'},
    {'1': 'origin', '3': 4, '4': 1, '5': 9, '9': 0, '10': 'origin', '17': true},
    {'1': 'is_migration', '3': 5, '4': 1, '5': 8, '10': 'isMigration'},
  ],
  '8': [
    {'1': '_origin'},
  ],
};

/// Descriptor for `SatOpBegin`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satOpBeginDescriptor = $convert.base64Decode(
    'CgpTYXRPcEJlZ2luEikKEGNvbW1pdF90aW1lc3RhbXAYASABKARSD2NvbW1pdFRpbWVzdGFtcB'
    'IZCgh0cmFuc19pZBgCIAEoCVIHdHJhbnNJZBIQCgNsc24YAyABKAxSA2xzbhIbCgZvcmlnaW4Y'
    'BCABKAlIAFIGb3JpZ2luiAEBEiEKDGlzX21pZ3JhdGlvbhgFIAEoCFILaXNNaWdyYXRpb25CCQ'
    'oHX29yaWdpbg==');

@$core.Deprecated('Use satOpCommitDescriptor instead')
const SatOpCommit$json = {
  '1': 'SatOpCommit',
  '2': [
    {'1': 'commit_timestamp', '3': 1, '4': 1, '5': 4, '10': 'commitTimestamp'},
    {'1': 'trans_id', '3': 2, '4': 1, '5': 9, '10': 'transId'},
    {'1': 'lsn', '3': 3, '4': 1, '5': 12, '10': 'lsn'},
  ],
};

/// Descriptor for `SatOpCommit`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satOpCommitDescriptor = $convert.base64Decode(
    'CgtTYXRPcENvbW1pdBIpChBjb21taXRfdGltZXN0YW1wGAEgASgEUg9jb21taXRUaW1lc3RhbX'
    'ASGQoIdHJhbnNfaWQYAiABKAlSB3RyYW5zSWQSEAoDbHNuGAMgASgMUgNsc24=');

@$core.Deprecated('Use satOpInsertDescriptor instead')
const SatOpInsert$json = {
  '1': 'SatOpInsert',
  '2': [
    {'1': 'relation_id', '3': 1, '4': 1, '5': 13, '10': 'relationId'},
    {
      '1': 'row_data',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.Electric.Satellite.v1_4.SatOpRow',
      '10': 'rowData'
    },
    {'1': 'tags', '3': 3, '4': 3, '5': 9, '10': 'tags'},
  ],
};

/// Descriptor for `SatOpInsert`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satOpInsertDescriptor = $convert.base64Decode(
    'CgtTYXRPcEluc2VydBIfCgtyZWxhdGlvbl9pZBgBIAEoDVIKcmVsYXRpb25JZBI8Cghyb3dfZG'
    'F0YRgCIAEoCzIhLkVsZWN0cmljLlNhdGVsbGl0ZS52MV80LlNhdE9wUm93Ugdyb3dEYXRhEhIK'
    'BHRhZ3MYAyADKAlSBHRhZ3M=');

@$core.Deprecated('Use satOpUpdateDescriptor instead')
const SatOpUpdate$json = {
  '1': 'SatOpUpdate',
  '2': [
    {'1': 'relation_id', '3': 1, '4': 1, '5': 13, '10': 'relationId'},
    {
      '1': 'row_data',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.Electric.Satellite.v1_4.SatOpRow',
      '10': 'rowData'
    },
    {
      '1': 'old_row_data',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.Electric.Satellite.v1_4.SatOpRow',
      '10': 'oldRowData'
    },
    {'1': 'tags', '3': 4, '4': 3, '5': 9, '10': 'tags'},
  ],
};

/// Descriptor for `SatOpUpdate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satOpUpdateDescriptor = $convert.base64Decode(
    'CgtTYXRPcFVwZGF0ZRIfCgtyZWxhdGlvbl9pZBgBIAEoDVIKcmVsYXRpb25JZBI8Cghyb3dfZG'
    'F0YRgCIAEoCzIhLkVsZWN0cmljLlNhdGVsbGl0ZS52MV80LlNhdE9wUm93Ugdyb3dEYXRhEkMK'
    'DG9sZF9yb3dfZGF0YRgDIAEoCzIhLkVsZWN0cmljLlNhdGVsbGl0ZS52MV80LlNhdE9wUm93Ug'
    'pvbGRSb3dEYXRhEhIKBHRhZ3MYBCADKAlSBHRhZ3M=');

@$core.Deprecated('Use satOpDeleteDescriptor instead')
const SatOpDelete$json = {
  '1': 'SatOpDelete',
  '2': [
    {'1': 'relation_id', '3': 1, '4': 1, '5': 13, '10': 'relationId'},
    {
      '1': 'old_row_data',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.Electric.Satellite.v1_4.SatOpRow',
      '10': 'oldRowData'
    },
    {'1': 'tags', '3': 3, '4': 3, '5': 9, '10': 'tags'},
  ],
};

/// Descriptor for `SatOpDelete`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satOpDeleteDescriptor = $convert.base64Decode(
    'CgtTYXRPcERlbGV0ZRIfCgtyZWxhdGlvbl9pZBgBIAEoDVIKcmVsYXRpb25JZBJDCgxvbGRfcm'
    '93X2RhdGEYAiABKAsyIS5FbGVjdHJpYy5TYXRlbGxpdGUudjFfNC5TYXRPcFJvd1IKb2xkUm93'
    'RGF0YRISCgR0YWdzGAMgAygJUgR0YWdz');

@$core.Deprecated('Use satMigrationNotificationDescriptor instead')
const SatMigrationNotification$json = {
  '1': 'SatMigrationNotification',
  '2': [
    {
      '1': 'old_schema_version',
      '3': 1,
      '4': 1,
      '5': 9,
      '10': 'oldSchemaVersion'
    },
    {'1': 'old_schema_hash', '3': 2, '4': 1, '5': 9, '10': 'oldSchemaHash'},
    {
      '1': 'new_schema_version',
      '3': 3,
      '4': 1,
      '5': 9,
      '10': 'newSchemaVersion'
    },
    {'1': 'new_schema_hash', '3': 4, '4': 1, '5': 9, '10': 'newSchemaHash'},
  ],
};

/// Descriptor for `SatMigrationNotification`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satMigrationNotificationDescriptor = $convert.base64Decode(
    'ChhTYXRNaWdyYXRpb25Ob3RpZmljYXRpb24SLAoSb2xkX3NjaGVtYV92ZXJzaW9uGAEgASgJUh'
    'BvbGRTY2hlbWFWZXJzaW9uEiYKD29sZF9zY2hlbWFfaGFzaBgCIAEoCVINb2xkU2NoZW1hSGFz'
    'aBIsChJuZXdfc2NoZW1hX3ZlcnNpb24YAyABKAlSEG5ld1NjaGVtYVZlcnNpb24SJgoPbmV3X3'
    'NjaGVtYV9oYXNoGAQgASgJUg1uZXdTY2hlbWFIYXNo');

@$core.Deprecated('Use satOpRowDescriptor instead')
const SatOpRow$json = {
  '1': 'SatOpRow',
  '2': [
    {'1': 'nulls_bitmask', '3': 1, '4': 1, '5': 12, '10': 'nullsBitmask'},
    {'1': 'values', '3': 2, '4': 3, '5': 12, '10': 'values'},
  ],
};

/// Descriptor for `SatOpRow`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satOpRowDescriptor = $convert.base64Decode(
    'CghTYXRPcFJvdxIjCg1udWxsc19iaXRtYXNrGAEgASgMUgxudWxsc0JpdG1hc2sSFgoGdmFsdW'
    'VzGAIgAygMUgZ2YWx1ZXM=');

@$core.Deprecated('Use satOpMigrateDescriptor instead')
const SatOpMigrate$json = {
  '1': 'SatOpMigrate',
  '2': [
    {'1': 'version', '3': 1, '4': 1, '5': 9, '10': 'version'},
    {
      '1': 'stmts',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.Electric.Satellite.v1_4.SatOpMigrate.Stmt',
      '10': 'stmts'
    },
    {
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
  '3': [
    SatOpMigrate_Stmt$json,
    SatOpMigrate_PgColumnType$json,
    SatOpMigrate_Column$json,
    SatOpMigrate_ForeignKey$json,
    SatOpMigrate_Table$json
  ],
  '4': [SatOpMigrate_Type$json],
  '8': [
    {'1': '_table'},
  ],
};

@$core.Deprecated('Use satOpMigrateDescriptor instead')
const SatOpMigrate_Stmt$json = {
  '1': 'Stmt',
  '2': [
    {
      '1': 'type',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.Electric.Satellite.v1_4.SatOpMigrate.Type',
      '10': 'type'
    },
    {'1': 'sql', '3': 2, '4': 1, '5': 9, '10': 'sql'},
  ],
};

@$core.Deprecated('Use satOpMigrateDescriptor instead')
const SatOpMigrate_PgColumnType$json = {
  '1': 'PgColumnType',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'array', '3': 2, '4': 3, '5': 5, '10': 'array'},
    {'1': 'size', '3': 3, '4': 3, '5': 5, '10': 'size'},
  ],
};

@$core.Deprecated('Use satOpMigrateDescriptor instead')
const SatOpMigrate_Column$json = {
  '1': 'Column',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'sqlite_type', '3': 2, '4': 1, '5': 9, '10': 'sqliteType'},
    {
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
const SatOpMigrate_ForeignKey$json = {
  '1': 'ForeignKey',
  '2': [
    {'1': 'fk_cols', '3': 1, '4': 3, '5': 9, '10': 'fkCols'},
    {'1': 'pk_table', '3': 2, '4': 1, '5': 9, '10': 'pkTable'},
    {'1': 'pk_cols', '3': 3, '4': 3, '5': 9, '10': 'pkCols'},
  ],
};

@$core.Deprecated('Use satOpMigrateDescriptor instead')
const SatOpMigrate_Table$json = {
  '1': 'Table',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {
      '1': 'columns',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.Electric.Satellite.v1_4.SatOpMigrate.Column',
      '10': 'columns'
    },
    {
      '1': 'fks',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.Electric.Satellite.v1_4.SatOpMigrate.ForeignKey',
      '10': 'fks'
    },
    {'1': 'pks', '3': 4, '4': 3, '5': 9, '10': 'pks'},
  ],
};

@$core.Deprecated('Use satOpMigrateDescriptor instead')
const SatOpMigrate_Type$json = {
  '1': 'Type',
  '2': [
    {'1': 'CREATE_TABLE', '2': 0},
    {'1': 'CREATE_INDEX', '2': 1},
    {'1': 'ALTER_ADD_COLUMN', '2': 6},
  ],
};

/// Descriptor for `SatOpMigrate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satOpMigrateDescriptor = $convert.base64Decode(
    'CgxTYXRPcE1pZ3JhdGUSGAoHdmVyc2lvbhgBIAEoCVIHdmVyc2lvbhJACgVzdG10cxgCIAMoCz'
    'IqLkVsZWN0cmljLlNhdGVsbGl0ZS52MV80LlNhdE9wTWlncmF0ZS5TdG10UgVzdG10cxJGCgV0'
    'YWJsZRgDIAEoCzIrLkVsZWN0cmljLlNhdGVsbGl0ZS52MV80LlNhdE9wTWlncmF0ZS5UYWJsZU'
    'gAUgV0YWJsZYgBARpYCgRTdG10Ej4KBHR5cGUYASABKA4yKi5FbGVjdHJpYy5TYXRlbGxpdGUu'
    'djFfNC5TYXRPcE1pZ3JhdGUuVHlwZVIEdHlwZRIQCgNzcWwYAiABKAlSA3NxbBpMCgxQZ0NvbH'
    'VtblR5cGUSEgoEbmFtZRgBIAEoCVIEbmFtZRIUCgVhcnJheRgCIAMoBVIFYXJyYXkSEgoEc2l6'
    'ZRgDIAMoBVIEc2l6ZRqKAQoGQ29sdW1uEhIKBG5hbWUYASABKAlSBG5hbWUSHwoLc3FsaXRlX3'
    'R5cGUYAiABKAlSCnNxbGl0ZVR5cGUSSwoHcGdfdHlwZRgDIAEoCzIyLkVsZWN0cmljLlNhdGVs'
    'bGl0ZS52MV80LlNhdE9wTWlncmF0ZS5QZ0NvbHVtblR5cGVSBnBnVHlwZRpZCgpGb3JlaWduS2'
    'V5EhcKB2ZrX2NvbHMYASADKAlSBmZrQ29scxIZCghwa190YWJsZRgCIAEoCVIHcGtUYWJsZRIX'
    'Cgdwa19jb2xzGAMgAygJUgZwa0NvbHMauQEKBVRhYmxlEhIKBG5hbWUYASABKAlSBG5hbWUSRg'
    'oHY29sdW1ucxgCIAMoCzIsLkVsZWN0cmljLlNhdGVsbGl0ZS52MV80LlNhdE9wTWlncmF0ZS5D'
    'b2x1bW5SB2NvbHVtbnMSQgoDZmtzGAMgAygLMjAuRWxlY3RyaWMuU2F0ZWxsaXRlLnYxXzQuU2'
    'F0T3BNaWdyYXRlLkZvcmVpZ25LZXlSA2ZrcxIQCgNwa3MYBCADKAlSA3BrcyJACgRUeXBlEhAK'
    'DENSRUFURV9UQUJMRRAAEhAKDENSRUFURV9JTkRFWBABEhQKEEFMVEVSX0FERF9DT0xVTU4QBk'
    'IICgZfdGFibGU=');

@$core.Deprecated('Use satSubsReqDescriptor instead')
const SatSubsReq$json = {
  '1': 'SatSubsReq',
  '2': [
    {
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
    'CgpTYXRTdWJzUmVxEksKDnNoYXBlX3JlcXVlc3RzGAIgAygLMiQuRWxlY3RyaWMuU2F0ZWxsaX'
    'RlLnYxXzQuU2F0U2hhcGVSZXFSDXNoYXBlUmVxdWVzdHM=');

@$core.Deprecated('Use satSubsRespDescriptor instead')
const SatSubsResp$json = {
  '1': 'SatSubsResp',
  '2': [
    {'1': 'subscription_id', '3': 1, '4': 1, '5': 9, '10': 'subscriptionId'},
  ],
};

/// Descriptor for `SatSubsResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satSubsRespDescriptor = $convert.base64Decode(
    'CgtTYXRTdWJzUmVzcBInCg9zdWJzY3JpcHRpb25faWQYASABKAlSDnN1YnNjcmlwdGlvbklk');

@$core.Deprecated('Use satUnsubsReqDescriptor instead')
const SatUnsubsReq$json = {
  '1': 'SatUnsubsReq',
  '2': [
    {'1': 'subscription_ids', '3': 1, '4': 3, '5': 9, '10': 'subscriptionIds'},
  ],
};

/// Descriptor for `SatUnsubsReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satUnsubsReqDescriptor = $convert.base64Decode(
    'CgxTYXRVbnN1YnNSZXESKQoQc3Vic2NyaXB0aW9uX2lkcxgBIAMoCVIPc3Vic2NyaXB0aW9uSW'
    'Rz');

@$core.Deprecated('Use satUnsubsRespDescriptor instead')
const SatUnsubsResp$json = {
  '1': 'SatUnsubsResp',
};

/// Descriptor for `SatUnsubsResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satUnsubsRespDescriptor =
    $convert.base64Decode('Cg1TYXRVbnN1YnNSZXNw');

@$core.Deprecated('Use satShapeReqDescriptor instead')
const SatShapeReq$json = {
  '1': 'SatShapeReq',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 9, '10': 'requestId'},
    {
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
    'CgtTYXRTaGFwZVJlcRIdCgpyZXF1ZXN0X2lkGAEgASgJUglyZXF1ZXN0SWQSTwoQc2hhcGVfZG'
    'VmaW5pdGlvbhgCIAEoCzIkLkVsZWN0cmljLlNhdGVsbGl0ZS52MV80LlNhdFNoYXBlRGVmUg9z'
    'aGFwZURlZmluaXRpb24=');

@$core.Deprecated('Use satShapeDefDescriptor instead')
const SatShapeDef$json = {
  '1': 'SatShapeDef',
  '2': [
    {
      '1': 'selects',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.Electric.Satellite.v1_4.SatShapeDef.Select',
      '10': 'selects'
    },
  ],
  '3': [SatShapeDef_Select$json],
};

@$core.Deprecated('Use satShapeDefDescriptor instead')
const SatShapeDef_Select$json = {
  '1': 'Select',
  '2': [
    {'1': 'tablename', '3': 1, '4': 1, '5': 9, '10': 'tablename'},
  ],
};

/// Descriptor for `SatShapeDef`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satShapeDefDescriptor = $convert.base64Decode(
    'CgtTYXRTaGFwZURlZhJFCgdzZWxlY3RzGAEgAygLMisuRWxlY3RyaWMuU2F0ZWxsaXRlLnYxXz'
    'QuU2F0U2hhcGVEZWYuU2VsZWN0UgdzZWxlY3RzGiYKBlNlbGVjdBIcCgl0YWJsZW5hbWUYASAB'
    'KAlSCXRhYmxlbmFtZQ==');

@$core.Deprecated('Use satSubsErrorDescriptor instead')
const SatSubsError$json = {
  '1': 'SatSubsError',
  '2': [
    {
      '1': 'code',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.Electric.Satellite.v1_4.SatSubsError.Code',
      '10': 'code'
    },
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {'1': 'subscription_id', '3': 3, '4': 1, '5': 9, '10': 'subscriptionId'},
    {
      '1': 'shape_request_error',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.Electric.Satellite.v1_4.SatSubsError.ShapeReqError',
      '10': 'shapeRequestError'
    },
  ],
  '3': [SatSubsError_ShapeReqError$json],
  '4': [SatSubsError_Code$json],
};

@$core.Deprecated('Use satSubsErrorDescriptor instead')
const SatSubsError_ShapeReqError$json = {
  '1': 'ShapeReqError',
  '2': [
    {
      '1': 'code',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.Electric.Satellite.v1_4.SatSubsError.ShapeReqError.Code',
      '10': 'code'
    },
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {'1': 'request_id', '3': 3, '4': 1, '5': 9, '10': 'requestId'},
  ],
  '4': [SatSubsError_ShapeReqError_Code$json],
};

@$core.Deprecated('Use satSubsErrorDescriptor instead')
const SatSubsError_ShapeReqError_Code$json = {
  '1': 'Code',
  '2': [
    {'1': 'CODE_UNSPECIFIED', '2': 0},
    {'1': 'TABLE_NOT_FOUND', '2': 1},
  ],
};

@$core.Deprecated('Use satSubsErrorDescriptor instead')
const SatSubsError_Code$json = {
  '1': 'Code',
  '2': [
    {'1': 'CODE_UNSPECIFIED', '2': 0},
    {'1': 'SHAPE_REQUEST_ERROR', '2': 1},
  ],
};

/// Descriptor for `SatSubsError`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satSubsErrorDescriptor = $convert.base64Decode(
    'CgxTYXRTdWJzRXJyb3ISPgoEY29kZRgBIAEoDjIqLkVsZWN0cmljLlNhdGVsbGl0ZS52MV80Ll'
    'NhdFN1YnNFcnJvci5Db2RlUgRjb2RlEhgKB21lc3NhZ2UYAiABKAlSB21lc3NhZ2USJwoPc3Vi'
    'c2NyaXB0aW9uX2lkGAMgASgJUg5zdWJzY3JpcHRpb25JZBJjChNzaGFwZV9yZXF1ZXN0X2Vycm'
    '9yGAQgAygLMjMuRWxlY3RyaWMuU2F0ZWxsaXRlLnYxXzQuU2F0U3Vic0Vycm9yLlNoYXBlUmVx'
    'RXJyb3JSEXNoYXBlUmVxdWVzdEVycm9yGskBCg1TaGFwZVJlcUVycm9yEkwKBGNvZGUYASABKA'
    '4yOC5FbGVjdHJpYy5TYXRlbGxpdGUudjFfNC5TYXRTdWJzRXJyb3IuU2hhcGVSZXFFcnJvci5D'
    'b2RlUgRjb2RlEhgKB21lc3NhZ2UYAiABKAlSB21lc3NhZ2USHQoKcmVxdWVzdF9pZBgDIAEoCV'
    'IJcmVxdWVzdElkIjEKBENvZGUSFAoQQ09ERV9VTlNQRUNJRklFRBAAEhMKD1RBQkxFX05PVF9G'
    'T1VORBABIjUKBENvZGUSFAoQQ09ERV9VTlNQRUNJRklFRBAAEhcKE1NIQVBFX1JFUVVFU1RfRV'
    'JST1IQAQ==');

@$core.Deprecated('Use satSubsDataBeginDescriptor instead')
const SatSubsDataBegin$json = {
  '1': 'SatSubsDataBegin',
  '2': [
    {'1': 'subscription_id', '3': 1, '4': 1, '5': 9, '10': 'subscriptionId'},
  ],
};

/// Descriptor for `SatSubsDataBegin`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satSubsDataBeginDescriptor = $convert.base64Decode(
    'ChBTYXRTdWJzRGF0YUJlZ2luEicKD3N1YnNjcmlwdGlvbl9pZBgBIAEoCVIOc3Vic2NyaXB0aW'
    '9uSWQ=');

@$core.Deprecated('Use satSubsDataEndDescriptor instead')
const SatSubsDataEnd$json = {
  '1': 'SatSubsDataEnd',
};

/// Descriptor for `SatSubsDataEnd`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satSubsDataEndDescriptor =
    $convert.base64Decode('Cg5TYXRTdWJzRGF0YUVuZA==');

@$core.Deprecated('Use satShapeDataBeginDescriptor instead')
const SatShapeDataBegin$json = {
  '1': 'SatShapeDataBegin',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 9, '10': 'requestId'},
    {'1': 'uuid', '3': 2, '4': 1, '5': 9, '10': 'uuid'},
  ],
};

/// Descriptor for `SatShapeDataBegin`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satShapeDataBeginDescriptor = $convert.base64Decode(
    'ChFTYXRTaGFwZURhdGFCZWdpbhIdCgpyZXF1ZXN0X2lkGAEgASgJUglyZXF1ZXN0SWQSEgoEdX'
    'VpZBgCIAEoCVIEdXVpZA==');

@$core.Deprecated('Use satShapeDataEndDescriptor instead')
const SatShapeDataEnd$json = {
  '1': 'SatShapeDataEnd',
};

/// Descriptor for `SatShapeDataEnd`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satShapeDataEndDescriptor =
    $convert.base64Decode('Cg9TYXRTaGFwZURhdGFFbmQ=');
