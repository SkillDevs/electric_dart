//
//  Generated code. Do not modify.
//  source: proto/satellite.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
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
  ],
  '4': [
    {'1': 1, '2': 1},
  ],
};

/// Descriptor for `SatAuthHeader`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List satAuthHeaderDescriptor = $convert
    .base64Decode('Cg1TYXRBdXRoSGVhZGVyEg8KC1VOU1BFQ0lGSUVEEAAiBAgBEAE=');

@$core.Deprecated('Use satRpcRequestDescriptor instead')
const SatRpcRequest$json = {
  '1': 'SatRpcRequest',
  '2': [
    {'1': 'method', '3': 1, '4': 1, '5': 9, '10': 'method'},
    {'1': 'request_id', '3': 2, '4': 1, '5': 13, '10': 'requestId'},
    {'1': 'message', '3': 3, '4': 1, '5': 12, '10': 'message'},
  ],
};

/// Descriptor for `SatRpcRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satRpcRequestDescriptor = $convert.base64Decode(
    'Cg1TYXRScGNSZXF1ZXN0EhYKBm1ldGhvZBgBIAEoCVIGbWV0aG9kEh0KCnJlcXVlc3RfaWQYAi'
    'ABKA1SCXJlcXVlc3RJZBIYCgdtZXNzYWdlGAMgASgMUgdtZXNzYWdl');

@$core.Deprecated('Use satRpcResponseDescriptor instead')
const SatRpcResponse$json = {
  '1': 'SatRpcResponse',
  '2': [
    {'1': 'method', '3': 1, '4': 1, '5': 9, '10': 'method'},
    {'1': 'request_id', '3': 2, '4': 1, '5': 13, '10': 'requestId'},
    {'1': 'message', '3': 3, '4': 1, '5': 12, '9': 0, '10': 'message'},
    {
      '1': 'error',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.Electric.Satellite.SatErrorResp',
      '9': 0,
      '10': 'error'
    },
  ],
  '8': [
    {'1': 'result'},
  ],
};

/// Descriptor for `SatRpcResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satRpcResponseDescriptor = $convert.base64Decode(
    'Cg5TYXRScGNSZXNwb25zZRIWCgZtZXRob2QYASABKAlSBm1ldGhvZBIdCgpyZXF1ZXN0X2lkGA'
    'IgASgNUglyZXF1ZXN0SWQSGgoHbWVzc2FnZRgDIAEoDEgAUgdtZXNzYWdlEjgKBWVycm9yGAQg'
    'ASgLMiAuRWxlY3RyaWMuU2F0ZWxsaXRlLlNhdEVycm9yUmVzcEgAUgVlcnJvckIICgZyZXN1bH'
    'Q=');

@$core.Deprecated('Use satAuthHeaderPairDescriptor instead')
const SatAuthHeaderPair$json = {
  '1': 'SatAuthHeaderPair',
  '2': [
    {
      '1': 'key',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.Electric.Satellite.SatAuthHeader',
      '10': 'key'
    },
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
};

/// Descriptor for `SatAuthHeaderPair`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satAuthHeaderPairDescriptor = $convert.base64Decode(
    'ChFTYXRBdXRoSGVhZGVyUGFpchIzCgNrZXkYASABKA4yIS5FbGVjdHJpYy5TYXRlbGxpdGUuU2'
    'F0QXV0aEhlYWRlclIDa2V5EhQKBXZhbHVlGAIgASgJUgV2YWx1ZQ==');

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
      '6': '.Electric.Satellite.SatAuthHeaderPair',
      '10': 'headers'
    },
  ],
};

/// Descriptor for `SatAuthReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satAuthReqDescriptor = $convert.base64Decode(
    'CgpTYXRBdXRoUmVxEg4KAmlkGAEgASgJUgJpZBIUCgV0b2tlbhgCIAEoCVIFdG9rZW4SPwoHaG'
    'VhZGVycxgDIAMoCzIlLkVsZWN0cmljLlNhdGVsbGl0ZS5TYXRBdXRoSGVhZGVyUGFpclIHaGVh'
    'ZGVycw==');

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
      '6': '.Electric.Satellite.SatAuthHeaderPair',
      '10': 'headers'
    },
  ],
};

/// Descriptor for `SatAuthResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satAuthRespDescriptor = $convert.base64Decode(
    'CgtTYXRBdXRoUmVzcBIOCgJpZBgBIAEoCVICaWQSPwoHaGVhZGVycxgDIAMoCzIlLkVsZWN0cm'
    'ljLlNhdGVsbGl0ZS5TYXRBdXRoSGVhZGVyUGFpclIHaGVhZGVycw==');

@$core.Deprecated('Use satErrorRespDescriptor instead')
const SatErrorResp$json = {
  '1': 'SatErrorResp',
  '2': [
    {
      '1': 'error_type',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.Electric.Satellite.SatErrorResp.ErrorCode',
      '10': 'errorType'
    },
    {'1': 'lsn', '3': 2, '4': 1, '5': 12, '9': 0, '10': 'lsn', '17': true},
    {
      '1': 'message',
      '3': 3,
      '4': 1,
      '5': 9,
      '9': 1,
      '10': 'message',
      '17': true
    },
  ],
  '4': [SatErrorResp_ErrorCode$json],
  '8': [
    {'1': '_lsn'},
    {'1': '_message'},
  ],
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
    {'1': 'PROTO_VSN_MISMATCH', '2': 5},
    {'1': 'SCHEMA_VSN_MISMATCH', '2': 6},
  ],
};

/// Descriptor for `SatErrorResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satErrorRespDescriptor = $convert.base64Decode(
    'CgxTYXRFcnJvclJlc3ASSQoKZXJyb3JfdHlwZRgBIAEoDjIqLkVsZWN0cmljLlNhdGVsbGl0ZS'
    '5TYXRFcnJvclJlc3AuRXJyb3JDb2RlUgllcnJvclR5cGUSFQoDbHNuGAIgASgMSABSA2xzbogB'
    'ARIdCgdtZXNzYWdlGAMgASgJSAFSB21lc3NhZ2WIAQEimwEKCUVycm9yQ29kZRIMCghJTlRFUk'
    '5BTBAAEhEKDUFVVEhfUkVRVUlSRUQQARIPCgtBVVRIX0ZBSUxFRBACEhYKElJFUExJQ0FUSU9O'
    'X0ZBSUxFRBADEhMKD0lOVkFMSURfUkVRVUVTVBAEEhYKElBST1RPX1ZTTl9NSVNNQVRDSBAFEh'
    'cKE1NDSEVNQV9WU05fTUlTTUFUQ0gQBkIGCgRfbHNuQgoKCF9tZXNzYWdl');

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
      '6': '.Electric.Satellite.SatInStartReplicationReq.Option',
      '10': 'options'
    },
    {'1': 'subscription_ids', '3': 4, '4': 3, '5': 9, '10': 'subscriptionIds'},
    {
      '1': 'schema_version',
      '3': 5,
      '4': 1,
      '5': 9,
      '9': 0,
      '10': 'schemaVersion',
      '17': true
    },
    {
      '1': 'observed_transaction_data',
      '3': 6,
      '4': 3,
      '5': 4,
      '10': 'observedTransactionData'
    },
  ],
  '4': [SatInStartReplicationReq_Option$json],
  '8': [
    {'1': '_schema_version'},
  ],
  '9': [
    {'1': 3, '2': 4},
  ],
};

@$core.Deprecated('Use satInStartReplicationReqDescriptor instead')
const SatInStartReplicationReq_Option$json = {
  '1': 'Option',
  '2': [
    {'1': 'NONE', '2': 0},
  ],
  '4': [
    {'1': 1, '2': 1},
    {'1': 2, '2': 2},
    {'1': 3, '2': 3},
    {'1': 4, '2': 4},
  ],
};

/// Descriptor for `SatInStartReplicationReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satInStartReplicationReqDescriptor = $convert.base64Decode(
    'ChhTYXRJblN0YXJ0UmVwbGljYXRpb25SZXESEAoDbHNuGAEgASgMUgNsc24STQoHb3B0aW9ucx'
    'gCIAMoDjIzLkVsZWN0cmljLlNhdGVsbGl0ZS5TYXRJblN0YXJ0UmVwbGljYXRpb25SZXEuT3B0'
    'aW9uUgdvcHRpb25zEikKEHN1YnNjcmlwdGlvbl9pZHMYBCADKAlSD3N1YnNjcmlwdGlvbklkcx'
    'IqCg5zY2hlbWFfdmVyc2lvbhgFIAEoCUgAUg1zY2hlbWFWZXJzaW9uiAEBEjoKGW9ic2VydmVk'
    'X3RyYW5zYWN0aW9uX2RhdGEYBiADKARSF29ic2VydmVkVHJhbnNhY3Rpb25EYXRhIioKBk9wdG'
    'lvbhIICgROT05FEAAiBAgBEAEiBAgCEAIiBAgDEAMiBAgEEARCEQoPX3NjaGVtYV92ZXJzaW9u'
    'SgQIAxAE');

@$core.Deprecated('Use satInStartReplicationRespDescriptor instead')
const SatInStartReplicationResp$json = {
  '1': 'SatInStartReplicationResp',
  '2': [
    {
      '1': 'err',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.Electric.Satellite.SatInStartReplicationResp.ReplicationError',
      '9': 0,
      '10': 'err',
      '17': true
    },
    {
      '1': 'unacked_window_size',
      '3': 2,
      '4': 1,
      '5': 13,
      '9': 1,
      '10': 'unackedWindowSize',
      '17': true
    },
  ],
  '3': [SatInStartReplicationResp_ReplicationError$json],
  '8': [
    {'1': '_err'},
    {'1': '_unacked_window_size'},
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
          '.Electric.Satellite.SatInStartReplicationResp.ReplicationError.Code',
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
    {'1': 'MALFORMED_LSN', '2': 4},
    {'1': 'UNKNOWN_SCHEMA_VSN', '2': 5},
  ],
};

/// Descriptor for `SatInStartReplicationResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satInStartReplicationRespDescriptor = $convert.base64Decode(
    'ChlTYXRJblN0YXJ0UmVwbGljYXRpb25SZXNwElUKA2VychgBIAEoCzI+LkVsZWN0cmljLlNhdG'
    'VsbGl0ZS5TYXRJblN0YXJ0UmVwbGljYXRpb25SZXNwLlJlcGxpY2F0aW9uRXJyb3JIAFIDZXJy'
    'iAEBEjMKE3VuYWNrZWRfd2luZG93X3NpemUYAiABKA1IAVIRdW5hY2tlZFdpbmRvd1NpemWIAQ'
    'EalAIKEFJlcGxpY2F0aW9uRXJyb3ISVwoEY29kZRgBIAEoDjJDLkVsZWN0cmljLlNhdGVsbGl0'
    'ZS5TYXRJblN0YXJ0UmVwbGljYXRpb25SZXNwLlJlcGxpY2F0aW9uRXJyb3IuQ29kZVIEY29kZR'
    'IYCgdtZXNzYWdlGAIgASgJUgdtZXNzYWdlIowBCgRDb2RlEhQKEENPREVfVU5TUEVDSUZJRUQQ'
    'ABIRCg1CRUhJTkRfV0lORE9XEAESFAoQSU5WQUxJRF9QT1NJVElPThACEhoKFlNVQlNDUklQVE'
    'lPTl9OT1RfRk9VTkQQAxIRCg1NQUxGT1JNRURfTFNOEAQSFgoSVU5LTk9XTl9TQ0hFTUFfVlNO'
    'EAVCBgoEX2VyckIWChRfdW5hY2tlZF93aW5kb3dfc2l6ZQ==');

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
    {'1': 'is_nullable', '3': 4, '4': 1, '5': 8, '10': 'isNullable'},
  ],
};

/// Descriptor for `SatRelationColumn`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satRelationColumnDescriptor = $convert.base64Decode(
    'ChFTYXRSZWxhdGlvbkNvbHVtbhISCgRuYW1lGAEgASgJUgRuYW1lEhIKBHR5cGUYAiABKAlSBH'
    'R5cGUSHgoKcHJpbWFyeUtleRgDIAEoCFIKcHJpbWFyeUtleRIfCgtpc19udWxsYWJsZRgEIAEo'
    'CFIKaXNOdWxsYWJsZQ==');

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
      '6': '.Electric.Satellite.SatRelation.RelationType',
      '10': 'tableType'
    },
    {'1': 'table_name', '3': 3, '4': 1, '5': 9, '10': 'tableName'},
    {'1': 'relation_id', '3': 4, '4': 1, '5': 13, '10': 'relationId'},
    {
      '1': 'columns',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.Electric.Satellite.SatRelationColumn',
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
    'CgtTYXRSZWxhdGlvbhIfCgtzY2hlbWFfbmFtZRgBIAEoCVIKc2NoZW1hTmFtZRJLCgp0YWJsZV'
    '90eXBlGAIgASgOMiwuRWxlY3RyaWMuU2F0ZWxsaXRlLlNhdFJlbGF0aW9uLlJlbGF0aW9uVHlw'
    'ZVIJdGFibGVUeXBlEh0KCnRhYmxlX25hbWUYAyABKAlSCXRhYmxlTmFtZRIfCgtyZWxhdGlvbl'
    '9pZBgEIAEoDVIKcmVsYXRpb25JZBI/Cgdjb2x1bW5zGAUgAygLMiUuRWxlY3RyaWMuU2F0ZWxs'
    'aXRlLlNhdFJlbGF0aW9uQ29sdW1uUgdjb2x1bW5zIjsKDFJlbGF0aW9uVHlwZRIJCgVUQUJMRR'
    'AAEgkKBUlOREVYEAESCAoEVklFVxACEgsKB1RSSUdHRVIQAw==');

@$core.Deprecated('Use satOpLogDescriptor instead')
const SatOpLog$json = {
  '1': 'SatOpLog',
  '2': [
    {
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
    'CghTYXRPcExvZxIwCgNvcHMYASADKAsyHi5FbGVjdHJpYy5TYXRlbGxpdGUuU2F0VHJhbnNPcF'
    'IDb3Bz');

@$core.Deprecated('Use satOpLogAckDescriptor instead')
const SatOpLogAck$json = {
  '1': 'SatOpLogAck',
  '2': [
    {'1': 'ack_timestamp', '3': 1, '4': 1, '5': 4, '10': 'ackTimestamp'},
    {'1': 'lsn', '3': 2, '4': 1, '5': 12, '10': 'lsn'},
    {'1': 'transaction_id', '3': 3, '4': 1, '5': 4, '10': 'transactionId'},
    {'1': 'subscription_ids', '3': 4, '4': 3, '5': 9, '10': 'subscriptionIds'},
    {
      '1': 'additional_data_source_ids',
      '3': 5,
      '4': 3,
      '5': 4,
      '10': 'additionalDataSourceIds'
    },
  ],
};

/// Descriptor for `SatOpLogAck`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satOpLogAckDescriptor = $convert.base64Decode(
    'CgtTYXRPcExvZ0FjaxIjCg1hY2tfdGltZXN0YW1wGAEgASgEUgxhY2tUaW1lc3RhbXASEAoDbH'
    'NuGAIgASgMUgNsc24SJQoOdHJhbnNhY3Rpb25faWQYAyABKARSDXRyYW5zYWN0aW9uSWQSKQoQ'
    'c3Vic2NyaXB0aW9uX2lkcxgEIAMoCVIPc3Vic2NyaXB0aW9uSWRzEjsKGmFkZGl0aW9uYWxfZG'
    'F0YV9zb3VyY2VfaWRzGAUgAygEUhdhZGRpdGlvbmFsRGF0YVNvdXJjZUlkcw==');

@$core.Deprecated('Use satTransOpDescriptor instead')
const SatTransOp$json = {
  '1': 'SatTransOp',
  '2': [
    {
      '1': 'begin',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.Electric.Satellite.SatOpBegin',
      '9': 0,
      '10': 'begin'
    },
    {
      '1': 'commit',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.Electric.Satellite.SatOpCommit',
      '9': 0,
      '10': 'commit'
    },
    {
      '1': 'update',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.Electric.Satellite.SatOpUpdate',
      '9': 0,
      '10': 'update'
    },
    {
      '1': 'insert',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.Electric.Satellite.SatOpInsert',
      '9': 0,
      '10': 'insert'
    },
    {
      '1': 'delete',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.Electric.Satellite.SatOpDelete',
      '9': 0,
      '10': 'delete'
    },
    {
      '1': 'migrate',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.Electric.Satellite.SatOpMigrate',
      '9': 0,
      '10': 'migrate'
    },
    {
      '1': 'compensation',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.Electric.Satellite.SatOpCompensation',
      '9': 0,
      '10': 'compensation'
    },
    {
      '1': 'gone',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.Electric.Satellite.SatOpGone',
      '9': 0,
      '10': 'gone'
    },
    {
      '1': 'additional_begin',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.Electric.Satellite.SatOpAdditionalBegin',
      '9': 0,
      '10': 'additionalBegin'
    },
    {
      '1': 'additional_commit',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.Electric.Satellite.SatOpAdditionalCommit',
      '9': 0,
      '10': 'additionalCommit'
    },
  ],
  '8': [
    {'1': 'op'},
  ],
};

/// Descriptor for `SatTransOp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satTransOpDescriptor = $convert.base64Decode(
    'CgpTYXRUcmFuc09wEjYKBWJlZ2luGAEgASgLMh4uRWxlY3RyaWMuU2F0ZWxsaXRlLlNhdE9wQm'
    'VnaW5IAFIFYmVnaW4SOQoGY29tbWl0GAIgASgLMh8uRWxlY3RyaWMuU2F0ZWxsaXRlLlNhdE9w'
    'Q29tbWl0SABSBmNvbW1pdBI5CgZ1cGRhdGUYAyABKAsyHy5FbGVjdHJpYy5TYXRlbGxpdGUuU2'
    'F0T3BVcGRhdGVIAFIGdXBkYXRlEjkKBmluc2VydBgEIAEoCzIfLkVsZWN0cmljLlNhdGVsbGl0'
    'ZS5TYXRPcEluc2VydEgAUgZpbnNlcnQSOQoGZGVsZXRlGAUgASgLMh8uRWxlY3RyaWMuU2F0ZW'
    'xsaXRlLlNhdE9wRGVsZXRlSABSBmRlbGV0ZRI8CgdtaWdyYXRlGAYgASgLMiAuRWxlY3RyaWMu'
    'U2F0ZWxsaXRlLlNhdE9wTWlncmF0ZUgAUgdtaWdyYXRlEksKDGNvbXBlbnNhdGlvbhgHIAEoCz'
    'IlLkVsZWN0cmljLlNhdGVsbGl0ZS5TYXRPcENvbXBlbnNhdGlvbkgAUgxjb21wZW5zYXRpb24S'
    'MwoEZ29uZRgIIAEoCzIdLkVsZWN0cmljLlNhdGVsbGl0ZS5TYXRPcEdvbmVIAFIEZ29uZRJVCh'
    'BhZGRpdGlvbmFsX2JlZ2luGAkgASgLMiguRWxlY3RyaWMuU2F0ZWxsaXRlLlNhdE9wQWRkaXRp'
    'b25hbEJlZ2luSABSD2FkZGl0aW9uYWxCZWdpbhJYChFhZGRpdGlvbmFsX2NvbW1pdBgKIAEoCz'
    'IpLkVsZWN0cmljLlNhdGVsbGl0ZS5TYXRPcEFkZGl0aW9uYWxDb21taXRIAFIQYWRkaXRpb25h'
    'bENvbW1pdEIECgJvcA==');

@$core.Deprecated('Use satOpBeginDescriptor instead')
const SatOpBegin$json = {
  '1': 'SatOpBegin',
  '2': [
    {'1': 'commit_timestamp', '3': 1, '4': 1, '5': 4, '10': 'commitTimestamp'},
    {'1': 'lsn', '3': 3, '4': 1, '5': 12, '10': 'lsn'},
    {'1': 'origin', '3': 4, '4': 1, '5': 9, '9': 0, '10': 'origin', '17': true},
    {'1': 'is_migration', '3': 5, '4': 1, '5': 8, '10': 'isMigration'},
    {
      '1': 'additional_data_ref',
      '3': 6,
      '4': 1,
      '5': 4,
      '10': 'additionalDataRef'
    },
    {
      '1': 'transaction_id',
      '3': 7,
      '4': 1,
      '5': 4,
      '9': 1,
      '10': 'transactionId',
      '17': true
    },
  ],
  '8': [
    {'1': '_origin'},
    {'1': '_transaction_id'},
  ],
  '9': [
    {'1': 2, '2': 3},
  ],
};

/// Descriptor for `SatOpBegin`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satOpBeginDescriptor = $convert.base64Decode(
    'CgpTYXRPcEJlZ2luEikKEGNvbW1pdF90aW1lc3RhbXAYASABKARSD2NvbW1pdFRpbWVzdGFtcB'
    'IQCgNsc24YAyABKAxSA2xzbhIbCgZvcmlnaW4YBCABKAlIAFIGb3JpZ2luiAEBEiEKDGlzX21p'
    'Z3JhdGlvbhgFIAEoCFILaXNNaWdyYXRpb24SLgoTYWRkaXRpb25hbF9kYXRhX3JlZhgGIAEoBF'
    'IRYWRkaXRpb25hbERhdGFSZWYSKgoOdHJhbnNhY3Rpb25faWQYByABKARIAVINdHJhbnNhY3Rp'
    'b25JZIgBAUIJCgdfb3JpZ2luQhEKD190cmFuc2FjdGlvbl9pZEoECAIQAw==');

@$core.Deprecated('Use satOpAdditionalBeginDescriptor instead')
const SatOpAdditionalBegin$json = {
  '1': 'SatOpAdditionalBegin',
  '2': [
    {'1': 'ref', '3': 1, '4': 1, '5': 4, '10': 'ref'},
  ],
};

/// Descriptor for `SatOpAdditionalBegin`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satOpAdditionalBeginDescriptor = $convert
    .base64Decode('ChRTYXRPcEFkZGl0aW9uYWxCZWdpbhIQCgNyZWYYASABKARSA3JlZg==');

@$core.Deprecated('Use satOpCommitDescriptor instead')
const SatOpCommit$json = {
  '1': 'SatOpCommit',
  '2': [
    {'1': 'commit_timestamp', '3': 1, '4': 1, '5': 4, '10': 'commitTimestamp'},
    {'1': 'lsn', '3': 3, '4': 1, '5': 12, '10': 'lsn'},
    {
      '1': 'additional_data_ref',
      '3': 4,
      '4': 1,
      '5': 4,
      '10': 'additionalDataRef'
    },
    {
      '1': 'transaction_id',
      '3': 5,
      '4': 1,
      '5': 4,
      '9': 0,
      '10': 'transactionId',
      '17': true
    },
  ],
  '8': [
    {'1': '_transaction_id'},
  ],
  '9': [
    {'1': 2, '2': 3},
  ],
};

/// Descriptor for `SatOpCommit`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satOpCommitDescriptor = $convert.base64Decode(
    'CgtTYXRPcENvbW1pdBIpChBjb21taXRfdGltZXN0YW1wGAEgASgEUg9jb21taXRUaW1lc3RhbX'
    'ASEAoDbHNuGAMgASgMUgNsc24SLgoTYWRkaXRpb25hbF9kYXRhX3JlZhgEIAEoBFIRYWRkaXRp'
    'b25hbERhdGFSZWYSKgoOdHJhbnNhY3Rpb25faWQYBSABKARIAFINdHJhbnNhY3Rpb25JZIgBAU'
    'IRCg9fdHJhbnNhY3Rpb25faWRKBAgCEAM=');

@$core.Deprecated('Use satOpAdditionalCommitDescriptor instead')
const SatOpAdditionalCommit$json = {
  '1': 'SatOpAdditionalCommit',
  '2': [
    {'1': 'ref', '3': 1, '4': 1, '5': 4, '10': 'ref'},
  ],
};

/// Descriptor for `SatOpAdditionalCommit`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satOpAdditionalCommitDescriptor = $convert
    .base64Decode('ChVTYXRPcEFkZGl0aW9uYWxDb21taXQSEAoDcmVmGAEgASgEUgNyZWY=');

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
      '6': '.Electric.Satellite.SatOpRow',
      '10': 'rowData'
    },
    {'1': 'tags', '3': 3, '4': 3, '5': 9, '10': 'tags'},
  ],
};

/// Descriptor for `SatOpInsert`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satOpInsertDescriptor = $convert.base64Decode(
    'CgtTYXRPcEluc2VydBIfCgtyZWxhdGlvbl9pZBgBIAEoDVIKcmVsYXRpb25JZBI3Cghyb3dfZG'
    'F0YRgCIAEoCzIcLkVsZWN0cmljLlNhdGVsbGl0ZS5TYXRPcFJvd1IHcm93RGF0YRISCgR0YWdz'
    'GAMgAygJUgR0YWdz');

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
      '6': '.Electric.Satellite.SatOpRow',
      '10': 'rowData'
    },
    {
      '1': 'old_row_data',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.Electric.Satellite.SatOpRow',
      '10': 'oldRowData'
    },
    {'1': 'tags', '3': 4, '4': 3, '5': 9, '10': 'tags'},
  ],
};

/// Descriptor for `SatOpUpdate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satOpUpdateDescriptor = $convert.base64Decode(
    'CgtTYXRPcFVwZGF0ZRIfCgtyZWxhdGlvbl9pZBgBIAEoDVIKcmVsYXRpb25JZBI3Cghyb3dfZG'
    'F0YRgCIAEoCzIcLkVsZWN0cmljLlNhdGVsbGl0ZS5TYXRPcFJvd1IHcm93RGF0YRI+CgxvbGRf'
    'cm93X2RhdGEYAyABKAsyHC5FbGVjdHJpYy5TYXRlbGxpdGUuU2F0T3BSb3dSCm9sZFJvd0RhdG'
    'ESEgoEdGFncxgEIAMoCVIEdGFncw==');

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
      '6': '.Electric.Satellite.SatOpRow',
      '10': 'oldRowData'
    },
    {'1': 'tags', '3': 3, '4': 3, '5': 9, '10': 'tags'},
  ],
};

/// Descriptor for `SatOpDelete`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satOpDeleteDescriptor = $convert.base64Decode(
    'CgtTYXRPcERlbGV0ZRIfCgtyZWxhdGlvbl9pZBgBIAEoDVIKcmVsYXRpb25JZBI+CgxvbGRfcm'
    '93X2RhdGEYAiABKAsyHC5FbGVjdHJpYy5TYXRlbGxpdGUuU2F0T3BSb3dSCm9sZFJvd0RhdGES'
    'EgoEdGFncxgDIAMoCVIEdGFncw==');

@$core.Deprecated('Use satOpCompensationDescriptor instead')
const SatOpCompensation$json = {
  '1': 'SatOpCompensation',
  '2': [
    {'1': 'relation_id', '3': 1, '4': 1, '5': 13, '10': 'relationId'},
    {
      '1': 'pk_data',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.Electric.Satellite.SatOpRow',
      '10': 'pkData'
    },
    {'1': 'tags', '3': 4, '4': 3, '5': 9, '10': 'tags'},
  ],
};

/// Descriptor for `SatOpCompensation`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satOpCompensationDescriptor = $convert.base64Decode(
    'ChFTYXRPcENvbXBlbnNhdGlvbhIfCgtyZWxhdGlvbl9pZBgBIAEoDVIKcmVsYXRpb25JZBI1Cg'
    'dwa19kYXRhGAIgASgLMhwuRWxlY3RyaWMuU2F0ZWxsaXRlLlNhdE9wUm93UgZwa0RhdGESEgoE'
    'dGFncxgEIAMoCVIEdGFncw==');

@$core.Deprecated('Use satOpGoneDescriptor instead')
const SatOpGone$json = {
  '1': 'SatOpGone',
  '2': [
    {'1': 'relation_id', '3': 1, '4': 1, '5': 13, '10': 'relationId'},
    {
      '1': 'pk_data',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.Electric.Satellite.SatOpRow',
      '10': 'pkData'
    },
  ],
};

/// Descriptor for `SatOpGone`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satOpGoneDescriptor = $convert.base64Decode(
    'CglTYXRPcEdvbmUSHwoLcmVsYXRpb25faWQYASABKA1SCnJlbGF0aW9uSWQSNQoHcGtfZGF0YR'
    'gCIAEoCzIcLkVsZWN0cmljLlNhdGVsbGl0ZS5TYXRPcFJvd1IGcGtEYXRh');

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
      '6': '.Electric.Satellite.SatOpMigrate.Stmt',
      '10': 'stmts'
    },
    {
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
      '6': '.Electric.Satellite.SatOpMigrate.Type',
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
      '6': '.Electric.Satellite.SatOpMigrate.PgColumnType',
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
      '6': '.Electric.Satellite.SatOpMigrate.Column',
      '10': 'columns'
    },
    {
      '1': 'fks',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.Electric.Satellite.SatOpMigrate.ForeignKey',
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
    'CgxTYXRPcE1pZ3JhdGUSGAoHdmVyc2lvbhgBIAEoCVIHdmVyc2lvbhI7CgVzdG10cxgCIAMoCz'
    'IlLkVsZWN0cmljLlNhdGVsbGl0ZS5TYXRPcE1pZ3JhdGUuU3RtdFIFc3RtdHMSQQoFdGFibGUY'
    'AyABKAsyJi5FbGVjdHJpYy5TYXRlbGxpdGUuU2F0T3BNaWdyYXRlLlRhYmxlSABSBXRhYmxliA'
    'EBGlMKBFN0bXQSOQoEdHlwZRgBIAEoDjIlLkVsZWN0cmljLlNhdGVsbGl0ZS5TYXRPcE1pZ3Jh'
    'dGUuVHlwZVIEdHlwZRIQCgNzcWwYAiABKAlSA3NxbBpMCgxQZ0NvbHVtblR5cGUSEgoEbmFtZR'
    'gBIAEoCVIEbmFtZRIUCgVhcnJheRgCIAMoBVIFYXJyYXkSEgoEc2l6ZRgDIAMoBVIEc2l6ZRqF'
    'AQoGQ29sdW1uEhIKBG5hbWUYASABKAlSBG5hbWUSHwoLc3FsaXRlX3R5cGUYAiABKAlSCnNxbG'
    'l0ZVR5cGUSRgoHcGdfdHlwZRgDIAEoCzItLkVsZWN0cmljLlNhdGVsbGl0ZS5TYXRPcE1pZ3Jh'
    'dGUuUGdDb2x1bW5UeXBlUgZwZ1R5cGUaWQoKRm9yZWlnbktleRIXCgdma19jb2xzGAEgAygJUg'
    'Zma0NvbHMSGQoIcGtfdGFibGUYAiABKAlSB3BrVGFibGUSFwoHcGtfY29scxgDIAMoCVIGcGtD'
    'b2xzGq8BCgVUYWJsZRISCgRuYW1lGAEgASgJUgRuYW1lEkEKB2NvbHVtbnMYAiADKAsyJy5FbG'
    'VjdHJpYy5TYXRlbGxpdGUuU2F0T3BNaWdyYXRlLkNvbHVtblIHY29sdW1ucxI9CgNma3MYAyAD'
    'KAsyKy5FbGVjdHJpYy5TYXRlbGxpdGUuU2F0T3BNaWdyYXRlLkZvcmVpZ25LZXlSA2ZrcxIQCg'
    'Nwa3MYBCADKAlSA3BrcyJACgRUeXBlEhAKDENSRUFURV9UQUJMRRAAEhAKDENSRUFURV9JTkRF'
    'WBABEhQKEEFMVEVSX0FERF9DT0xVTU4QBkIICgZfdGFibGU=');

@$core.Deprecated('Use satSubsReqDescriptor instead')
const SatSubsReq$json = {
  '1': 'SatSubsReq',
  '2': [
    {'1': 'subscription_id', '3': 1, '4': 1, '5': 9, '10': 'subscriptionId'},
    {
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
    'CgpTYXRTdWJzUmVxEicKD3N1YnNjcmlwdGlvbl9pZBgBIAEoCVIOc3Vic2NyaXB0aW9uSWQSRg'
    'oOc2hhcGVfcmVxdWVzdHMYAiADKAsyHy5FbGVjdHJpYy5TYXRlbGxpdGUuU2F0U2hhcGVSZXFS'
    'DXNoYXBlUmVxdWVzdHM=');

@$core.Deprecated('Use satSubsRespDescriptor instead')
const SatSubsResp$json = {
  '1': 'SatSubsResp',
  '2': [
    {'1': 'subscription_id', '3': 1, '4': 1, '5': 9, '10': 'subscriptionId'},
    {
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
  '3': [SatSubsResp_SatSubsError$json],
  '8': [
    {'1': '_err'},
  ],
};

@$core.Deprecated('Use satSubsRespDescriptor instead')
const SatSubsResp_SatSubsError$json = {
  '1': 'SatSubsError',
  '2': [
    {
      '1': 'code',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.Electric.Satellite.SatSubsResp.SatSubsError.Code',
      '10': 'code'
    },
    {'1': 'message', '3': 3, '4': 1, '5': 9, '10': 'message'},
    {
      '1': 'shape_request_error',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.Electric.Satellite.SatSubsResp.SatSubsError.ShapeReqError',
      '10': 'shapeRequestError'
    },
  ],
  '3': [SatSubsResp_SatSubsError_ShapeReqError$json],
  '4': [SatSubsResp_SatSubsError_Code$json],
};

@$core.Deprecated('Use satSubsRespDescriptor instead')
const SatSubsResp_SatSubsError_ShapeReqError$json = {
  '1': 'ShapeReqError',
  '2': [
    {
      '1': 'code',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.Electric.Satellite.SatSubsResp.SatSubsError.ShapeReqError.Code',
      '10': 'code'
    },
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {'1': 'request_id', '3': 3, '4': 1, '5': 9, '10': 'requestId'},
  ],
  '4': [SatSubsResp_SatSubsError_ShapeReqError_Code$json],
};

@$core.Deprecated('Use satSubsRespDescriptor instead')
const SatSubsResp_SatSubsError_ShapeReqError_Code$json = {
  '1': 'Code',
  '2': [
    {'1': 'CODE_UNSPECIFIED', '2': 0},
    {'1': 'TABLE_NOT_FOUND', '2': 1},
    {'1': 'REFERENTIAL_INTEGRITY_VIOLATION', '2': 2},
    {'1': 'EMPTY_SHAPE_DEFINITION', '2': 3},
    {'1': 'DUPLICATE_TABLE_IN_SHAPE_DEFINITION', '2': 4},
    {'1': 'INVALID_WHERE_CLAUSE', '2': 5},
    {'1': 'INVALID_INCLUDE_TREE', '2': 6},
  ],
};

@$core.Deprecated('Use satSubsRespDescriptor instead')
const SatSubsResp_SatSubsError_Code$json = {
  '1': 'Code',
  '2': [
    {'1': 'CODE_UNSPECIFIED', '2': 0},
    {'1': 'SUBSCRIPTION_ID_ALREADY_EXISTS', '2': 1},
    {'1': 'SHAPE_REQUEST_ERROR', '2': 2},
  ],
};

/// Descriptor for `SatSubsResp`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satSubsRespDescriptor = $convert.base64Decode(
    'CgtTYXRTdWJzUmVzcBInCg9zdWJzY3JpcHRpb25faWQYASABKAlSDnN1YnNjcmlwdGlvbklkEk'
    'MKA2VychgCIAEoCzIsLkVsZWN0cmljLlNhdGVsbGl0ZS5TYXRTdWJzUmVzcC5TYXRTdWJzRXJy'
    'b3JIAFIDZXJyiAEBGqgFCgxTYXRTdWJzRXJyb3ISRQoEY29kZRgCIAEoDjIxLkVsZWN0cmljLl'
    'NhdGVsbGl0ZS5TYXRTdWJzUmVzcC5TYXRTdWJzRXJyb3IuQ29kZVIEY29kZRIYCgdtZXNzYWdl'
    'GAMgASgJUgdtZXNzYWdlEmoKE3NoYXBlX3JlcXVlc3RfZXJyb3IYBCADKAsyOi5FbGVjdHJpYy'
    '5TYXRlbGxpdGUuU2F0U3Vic1Jlc3AuU2F0U3Vic0Vycm9yLlNoYXBlUmVxRXJyb3JSEXNoYXBl'
    'UmVxdWVzdEVycm9yGu8CCg1TaGFwZVJlcUVycm9yElMKBGNvZGUYASABKA4yPy5FbGVjdHJpYy'
    '5TYXRlbGxpdGUuU2F0U3Vic1Jlc3AuU2F0U3Vic0Vycm9yLlNoYXBlUmVxRXJyb3IuQ29kZVIE'
    'Y29kZRIYCgdtZXNzYWdlGAIgASgJUgdtZXNzYWdlEh0KCnJlcXVlc3RfaWQYAyABKAlSCXJlcX'
    'Vlc3RJZCLPAQoEQ29kZRIUChBDT0RFX1VOU1BFQ0lGSUVEEAASEwoPVEFCTEVfTk9UX0ZPVU5E'
    'EAESIwofUkVGRVJFTlRJQUxfSU5URUdSSVRZX1ZJT0xBVElPThACEhoKFkVNUFRZX1NIQVBFX0'
    'RFRklOSVRJT04QAxInCiNEVVBMSUNBVEVfVEFCTEVfSU5fU0hBUEVfREVGSU5JVElPThAEEhgK'
    'FElOVkFMSURfV0hFUkVfQ0xBVVNFEAUSGAoUSU5WQUxJRF9JTkNMVURFX1RSRUUQBiJZCgRDb2'
    'RlEhQKEENPREVfVU5TUEVDSUZJRUQQABIiCh5TVUJTQ1JJUFRJT05fSURfQUxSRUFEWV9FWElT'
    'VFMQARIXChNTSEFQRV9SRVFVRVNUX0VSUk9SEAJCBgoEX2Vycg==');

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
      '6': '.Electric.Satellite.SatShapeDef',
      '10': 'shapeDefinition'
    },
  ],
};

/// Descriptor for `SatShapeReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satShapeReqDescriptor = $convert.base64Decode(
    'CgtTYXRTaGFwZVJlcRIdCgpyZXF1ZXN0X2lkGAEgASgJUglyZXF1ZXN0SWQSSgoQc2hhcGVfZG'
    'VmaW5pdGlvbhgCIAEoCzIfLkVsZWN0cmljLlNhdGVsbGl0ZS5TYXRTaGFwZURlZlIPc2hhcGVE'
    'ZWZpbml0aW9u');

@$core.Deprecated('Use satShapeDefDescriptor instead')
const SatShapeDef$json = {
  '1': 'SatShapeDef',
  '2': [
    {
      '1': 'selects',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.Electric.Satellite.SatShapeDef.Select',
      '10': 'selects'
    },
  ],
  '3': [SatShapeDef_Relation$json, SatShapeDef_Select$json],
};

@$core.Deprecated('Use satShapeDefDescriptor instead')
const SatShapeDef_Relation$json = {
  '1': 'Relation',
  '2': [
    {'1': 'foreign_key', '3': 1, '4': 3, '5': 9, '10': 'foreignKey'},
    {
      '1': 'select',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.Electric.Satellite.SatShapeDef.Select',
      '10': 'select'
    },
  ],
};

@$core.Deprecated('Use satShapeDefDescriptor instead')
const SatShapeDef_Select$json = {
  '1': 'Select',
  '2': [
    {'1': 'tablename', '3': 1, '4': 1, '5': 9, '10': 'tablename'},
    {'1': 'where', '3': 2, '4': 1, '5': 9, '10': 'where'},
    {
      '1': 'include',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.Electric.Satellite.SatShapeDef.Relation',
      '10': 'include'
    },
  ],
};

/// Descriptor for `SatShapeDef`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satShapeDefDescriptor = $convert.base64Decode(
    'CgtTYXRTaGFwZURlZhJACgdzZWxlY3RzGAEgAygLMiYuRWxlY3RyaWMuU2F0ZWxsaXRlLlNhdF'
    'NoYXBlRGVmLlNlbGVjdFIHc2VsZWN0cxprCghSZWxhdGlvbhIfCgtmb3JlaWduX2tleRgBIAMo'
    'CVIKZm9yZWlnbktleRI+CgZzZWxlY3QYAiABKAsyJi5FbGVjdHJpYy5TYXRlbGxpdGUuU2F0U2'
    'hhcGVEZWYuU2VsZWN0UgZzZWxlY3QagAEKBlNlbGVjdBIcCgl0YWJsZW5hbWUYASABKAlSCXRh'
    'YmxlbmFtZRIUCgV3aGVyZRgCIAEoCVIFd2hlcmUSQgoHaW5jbHVkZRgDIAMoCzIoLkVsZWN0cm'
    'ljLlNhdGVsbGl0ZS5TYXRTaGFwZURlZi5SZWxhdGlvblIHaW5jbHVkZQ==');

@$core.Deprecated('Use satSubsDataErrorDescriptor instead')
const SatSubsDataError$json = {
  '1': 'SatSubsDataError',
  '2': [
    {
      '1': 'code',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.Electric.Satellite.SatSubsDataError.Code',
      '10': 'code'
    },
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {'1': 'subscription_id', '3': 3, '4': 1, '5': 9, '10': 'subscriptionId'},
    {
      '1': 'shape_request_error',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.Electric.Satellite.SatSubsDataError.ShapeReqError',
      '10': 'shapeRequestError'
    },
  ],
  '3': [SatSubsDataError_ShapeReqError$json],
  '4': [SatSubsDataError_Code$json],
};

@$core.Deprecated('Use satSubsDataErrorDescriptor instead')
const SatSubsDataError_ShapeReqError$json = {
  '1': 'ShapeReqError',
  '2': [
    {
      '1': 'code',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.Electric.Satellite.SatSubsDataError.ShapeReqError.Code',
      '10': 'code'
    },
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {'1': 'request_id', '3': 3, '4': 1, '5': 9, '10': 'requestId'},
  ],
  '4': [SatSubsDataError_ShapeReqError_Code$json],
};

@$core.Deprecated('Use satSubsDataErrorDescriptor instead')
const SatSubsDataError_ShapeReqError_Code$json = {
  '1': 'Code',
  '2': [
    {'1': 'CODE_UNSPECIFIED', '2': 0},
    {'1': 'SHAPE_SIZE_LIMIT_EXCEEDED', '2': 1},
  ],
};

@$core.Deprecated('Use satSubsDataErrorDescriptor instead')
const SatSubsDataError_Code$json = {
  '1': 'Code',
  '2': [
    {'1': 'CODE_UNSPECIFIED', '2': 0},
    {'1': 'SHAPE_DELIVERY_ERROR', '2': 1},
  ],
};

/// Descriptor for `SatSubsDataError`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satSubsDataErrorDescriptor = $convert.base64Decode(
    'ChBTYXRTdWJzRGF0YUVycm9yEj0KBGNvZGUYASABKA4yKS5FbGVjdHJpYy5TYXRlbGxpdGUuU2'
    'F0U3Vic0RhdGFFcnJvci5Db2RlUgRjb2RlEhgKB21lc3NhZ2UYAiABKAlSB21lc3NhZ2USJwoP'
    'c3Vic2NyaXB0aW9uX2lkGAMgASgJUg5zdWJzY3JpcHRpb25JZBJiChNzaGFwZV9yZXF1ZXN0X2'
    'Vycm9yGAQgAygLMjIuRWxlY3RyaWMuU2F0ZWxsaXRlLlNhdFN1YnNEYXRhRXJyb3IuU2hhcGVS'
    'ZXFFcnJvclIRc2hhcGVSZXF1ZXN0RXJyb3Ia0gEKDVNoYXBlUmVxRXJyb3ISSwoEY29kZRgBIA'
    'EoDjI3LkVsZWN0cmljLlNhdGVsbGl0ZS5TYXRTdWJzRGF0YUVycm9yLlNoYXBlUmVxRXJyb3Iu'
    'Q29kZVIEY29kZRIYCgdtZXNzYWdlGAIgASgJUgdtZXNzYWdlEh0KCnJlcXVlc3RfaWQYAyABKA'
    'lSCXJlcXVlc3RJZCI7CgRDb2RlEhQKEENPREVfVU5TUEVDSUZJRUQQABIdChlTSEFQRV9TSVpF'
    'X0xJTUlUX0VYQ0VFREVEEAEiNgoEQ29kZRIUChBDT0RFX1VOU1BFQ0lGSUVEEAASGAoUU0hBUE'
    'VfREVMSVZFUllfRVJST1IQAQ==');

@$core.Deprecated('Use satSubsDataBeginDescriptor instead')
const SatSubsDataBegin$json = {
  '1': 'SatSubsDataBegin',
  '2': [
    {'1': 'subscription_id', '3': 1, '4': 1, '5': 9, '10': 'subscriptionId'},
    {'1': 'lsn', '3': 2, '4': 1, '5': 12, '10': 'lsn'},
  ],
};

/// Descriptor for `SatSubsDataBegin`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satSubsDataBeginDescriptor = $convert.base64Decode(
    'ChBTYXRTdWJzRGF0YUJlZ2luEicKD3N1YnNjcmlwdGlvbl9pZBgBIAEoCVIOc3Vic2NyaXB0aW'
    '9uSWQSEAoDbHNuGAIgASgMUgNsc24=');

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

const $core.Map<$core.String, $core.dynamic> RootServiceBase$json = {
  '1': 'Root',
  '2': [
    {
      '1': 'authenticate',
      '2': '.Electric.Satellite.SatAuthReq',
      '3': '.Electric.Satellite.SatAuthResp'
    },
    {
      '1': 'startReplication',
      '2': '.Electric.Satellite.SatInStartReplicationReq',
      '3': '.Electric.Satellite.SatInStartReplicationResp'
    },
    {
      '1': 'stopReplication',
      '2': '.Electric.Satellite.SatInStopReplicationReq',
      '3': '.Electric.Satellite.SatInStopReplicationResp'
    },
    {
      '1': 'subscribe',
      '2': '.Electric.Satellite.SatSubsReq',
      '3': '.Electric.Satellite.SatSubsResp'
    },
    {
      '1': 'unsubscribe',
      '2': '.Electric.Satellite.SatUnsubsReq',
      '3': '.Electric.Satellite.SatUnsubsResp'
    },
  ],
};

@$core.Deprecated('Use rootServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    RootServiceBase$messageJson = {
  '.Electric.Satellite.SatAuthReq': SatAuthReq$json,
  '.Electric.Satellite.SatAuthHeaderPair': SatAuthHeaderPair$json,
  '.Electric.Satellite.SatAuthResp': SatAuthResp$json,
  '.Electric.Satellite.SatInStartReplicationReq': SatInStartReplicationReq$json,
  '.Electric.Satellite.SatInStartReplicationResp':
      SatInStartReplicationResp$json,
  '.Electric.Satellite.SatInStartReplicationResp.ReplicationError':
      SatInStartReplicationResp_ReplicationError$json,
  '.Electric.Satellite.SatInStopReplicationReq': SatInStopReplicationReq$json,
  '.Electric.Satellite.SatInStopReplicationResp': SatInStopReplicationResp$json,
  '.Electric.Satellite.SatSubsReq': SatSubsReq$json,
  '.Electric.Satellite.SatShapeReq': SatShapeReq$json,
  '.Electric.Satellite.SatShapeDef': SatShapeDef$json,
  '.Electric.Satellite.SatShapeDef.Select': SatShapeDef_Select$json,
  '.Electric.Satellite.SatShapeDef.Relation': SatShapeDef_Relation$json,
  '.Electric.Satellite.SatSubsResp': SatSubsResp$json,
  '.Electric.Satellite.SatSubsResp.SatSubsError': SatSubsResp_SatSubsError$json,
  '.Electric.Satellite.SatSubsResp.SatSubsError.ShapeReqError':
      SatSubsResp_SatSubsError_ShapeReqError$json,
  '.Electric.Satellite.SatUnsubsReq': SatUnsubsReq$json,
  '.Electric.Satellite.SatUnsubsResp': SatUnsubsResp$json,
};

/// Descriptor for `Root`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List rootServiceDescriptor = $convert.base64Decode(
    'CgRSb290Ek8KDGF1dGhlbnRpY2F0ZRIeLkVsZWN0cmljLlNhdGVsbGl0ZS5TYXRBdXRoUmVxGh'
    '8uRWxlY3RyaWMuU2F0ZWxsaXRlLlNhdEF1dGhSZXNwEm8KEHN0YXJ0UmVwbGljYXRpb24SLC5F'
    'bGVjdHJpYy5TYXRlbGxpdGUuU2F0SW5TdGFydFJlcGxpY2F0aW9uUmVxGi0uRWxlY3RyaWMuU2'
    'F0ZWxsaXRlLlNhdEluU3RhcnRSZXBsaWNhdGlvblJlc3ASbAoPc3RvcFJlcGxpY2F0aW9uEisu'
    'RWxlY3RyaWMuU2F0ZWxsaXRlLlNhdEluU3RvcFJlcGxpY2F0aW9uUmVxGiwuRWxlY3RyaWMuU2'
    'F0ZWxsaXRlLlNhdEluU3RvcFJlcGxpY2F0aW9uUmVzcBJMCglzdWJzY3JpYmUSHi5FbGVjdHJp'
    'Yy5TYXRlbGxpdGUuU2F0U3Vic1JlcRofLkVsZWN0cmljLlNhdGVsbGl0ZS5TYXRTdWJzUmVzcB'
    'JSCgt1bnN1YnNjcmliZRIgLkVsZWN0cmljLlNhdGVsbGl0ZS5TYXRVbnN1YnNSZXEaIS5FbGVj'
    'dHJpYy5TYXRlbGxpdGUuU2F0VW5zdWJzUmVzcA==');

const $core.Map<$core.String, $core.dynamic> ClientRootServiceBase$json = {
  '1': 'ClientRoot',
  '2': [
    {
      '1': 'startReplication',
      '2': '.Electric.Satellite.SatInStartReplicationReq',
      '3': '.Electric.Satellite.SatInStartReplicationResp'
    },
    {
      '1': 'stopReplication',
      '2': '.Electric.Satellite.SatInStopReplicationReq',
      '3': '.Electric.Satellite.SatInStopReplicationResp'
    },
  ],
};

@$core.Deprecated('Use clientRootServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    ClientRootServiceBase$messageJson = {
  '.Electric.Satellite.SatInStartReplicationReq': SatInStartReplicationReq$json,
  '.Electric.Satellite.SatInStartReplicationResp':
      SatInStartReplicationResp$json,
  '.Electric.Satellite.SatInStartReplicationResp.ReplicationError':
      SatInStartReplicationResp_ReplicationError$json,
  '.Electric.Satellite.SatInStopReplicationReq': SatInStopReplicationReq$json,
  '.Electric.Satellite.SatInStopReplicationResp': SatInStopReplicationResp$json,
};

/// Descriptor for `ClientRoot`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List clientRootServiceDescriptor = $convert.base64Decode(
    'CgpDbGllbnRSb290Em8KEHN0YXJ0UmVwbGljYXRpb24SLC5FbGVjdHJpYy5TYXRlbGxpdGUuU2'
    'F0SW5TdGFydFJlcGxpY2F0aW9uUmVxGi0uRWxlY3RyaWMuU2F0ZWxsaXRlLlNhdEluU3RhcnRS'
    'ZXBsaWNhdGlvblJlc3ASbAoPc3RvcFJlcGxpY2F0aW9uEisuRWxlY3RyaWMuU2F0ZWxsaXRlLl'
    'NhdEluU3RvcFJlcGxpY2F0aW9uUmVxGiwuRWxlY3RyaWMuU2F0ZWxsaXRlLlNhdEluU3RvcFJl'
    'cGxpY2F0aW9uUmVzcA==');
