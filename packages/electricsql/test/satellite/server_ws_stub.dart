import 'dart:io';
import 'dart:typed_data';

import 'package:electricsql/src/proto/satellite.pb.dart';
import 'package:electricsql/src/satellite/client.dart';
import 'package:electricsql/src/util/proto.dart';

const _kPort = 30002;

typedef RpcResponse = List<Object>;

typedef RegularExpectation = ({SatMsgType msgType, Object responses});

class SatelliteWSServerStub {
  late final HttpServer server;
  List<RegularExpectation> nonRpcExpectations = [];
  final Map<String, List<Object>> rpcResponses = {};
  late final WebSocket socket;

  Future<void> start() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, _kPort);
    // print('Listening on localhost:${server.port}');

    WebSocket? _socketClient;

    server.listen((HttpRequest request) async {
      // print("Request ${request.uri.path}");
      if (request.uri.path == '/ws') {
        if (_socketClient != null) {
          throw StateError('A client is already connected');
        }
        // Upgrade an HttpRequest to a WebSocket connection
        final socketClient = await WebSocketTransformer.upgrade(request);
        _socketClient = socketClient;
        socket = socketClient;
        // print('Client connected!!!');

        // Listen for incoming messages from the client
        socketClient.listen(
          (messageRaw) {
            _handleMessage(messageRaw as Uint8List);
          },
          onError: (Object e, StackTrace st) {
            // ignore: avoid_print
            print('Error in ws stub: $e\n$st');
          },
        );
      } else {
        request.response.statusCode = HttpStatus.notFound;
        await request.response.close();
      }
    });
  }

  Future<void> _handleMessage(Uint8List data) async {
    final requestDecoded = toMessage(data);
    final request = requestDecoded.msg;
    final SatMsgType requestMsgType = getTypeFromSatObject(request)!;

    if (request is SatRpcRequest) {
      // Get expected RPC response, prioritizing known request IDs
      final expected =
          shift(rpcResponses['${request.method}/${request.requestId}']) ??
              shift(rpcResponses[request.method]);

      if (expected == null) return;

      final <Object>[rpcBody, ..._messages] = expected is Function
          ? (await Function.apply(expected, [request.message])) as RpcResponse
          : expected as RpcResponse;
      final messages = <Object>[..._messages];

      // Special-case StartReplication to also start it the other way
      if (rpcBody is SatInStartReplicationResp) {
        final message = SatInStartReplicationReq();

        final request = SatRpcRequest(
          method: 'startReplication',
          requestId: 1,
          message: encodeMessage(message),
        );

        messages.insert(0, request);
      }

      socket.add(writeMsg(wrapRpcResponse(request, rpcBody)));

      for (final message in messages) {
        if (message is String) {
          final intStr = message.replaceAll('ms', '');
          await Future<void>.delayed(
            Duration(milliseconds: int.parse(intStr)),
          );
        } else {
          socket.add(writeMsg(message));
        }
      }
    } else {
      // Regular message handlers
      // const expected = this.regularResponses.get(getShortName(request))?.shift()

      final expected = shift(nonRpcExpectations);
      if (expected == null) return;

      final (:msgType, :responses) = expected;

      if (requestMsgType != msgType) {
        throw Exception(
          'Expected request type $msgType but got $requestMsgType',
        );
      }

      final messageQueue = responses is Function
          ? Function.apply(responses, [request]) as List<Object>? ?? []
          : (responses as List<dynamic>).cast<Object>();

      for (final message in messageQueue) {
        socket.add(writeMsg(message));
      }
    }
  }

  void closeSocket(String? reason) {
    // status codes 4000-4999 are available for applications
    socket.close(reason != null ? 4000 : null, reason);
  }

  Future<void> close() async {
    await server.close();
  }

  /// Expect next non-RPC message received by the server to match `type`, and either send `responses` arg directly or execute as a function
  void nextMsgExpect(SatMsgType type, Object responses) {
    nonRpcExpectations.add((msgType: type, responses: responses));
  }

  /// Set next response to a given RPC method, optionally with `/n` suffix to match on request ID.
  ///
  /// - If `responses` is an array, then it's sent directly, with first element being an RPC response
  /// and the rest being regular messages sent immediately as a follow-up.
  /// - If `responses` is a function, then it's called with the decoded body of RPC request, and it's
  /// return value is expected to be an array with same semantics as in the previous point.
  void nextRpcResponse(
    String method,
    Object responses,
  ) {
    final queue = rpcResponses[method];
    if (queue != null) {
      queue.add(responses);
    } else {
      rpcResponses[method] = [responses];
    }
  }
}

T? shift<T>(List<T>? l) {
  if (l == null || l.isEmpty) {
    return null;
  }
  return l.removeAt(0);
}

Uint8List writeMsg(Object msg) {
  final msgType = getTypeFromSatObject(msg)!;
  return encodeSocketMessage(msgType, msg);
}

SatRpcResponse wrapRpcResponse(
  SatRpcRequest request,
  Object body,
) {
  final message = body is! SatErrorResp ? encodeMessage(body) : null;
  final error = body is SatErrorResp ? body : null;

  return SatRpcResponse(
    method: request.method,
    requestId: request.requestId,
    message: message,
    error: error,
  );
}
