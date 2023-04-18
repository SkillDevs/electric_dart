import 'dart:io';

import 'package:electric_client/proto/satellite.pb.dart';
import 'package:electric_client/satellite/client.dart';
import 'package:electric_client/util/proto.dart';

const _kPort = 30002;

class SatelliteWSServerStub {
  final List<List<Object>> queue = [];
  late final HttpServer server;

  Future<void> start() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, _kPort);
    // print('Listening on localhost:${server.port}');

    WebSocket? _socketClient;

    server.listen((HttpRequest request) async {
      // print("Request ${request.uri.path}");
      if (request.uri.path == '/ws') {
        if (_socketClient != null) {
          throw StateError("A client is already connected");
        }
        // Upgrade an HttpRequest to a WebSocket connection
        final socketClient = await WebSocketTransformer.upgrade(request);
        _socketClient = socketClient;
        // print('Client connected!!!');

        // Listen for incoming messages from the client
        socketClient.listen((messageRaw) {
          if (queue.isEmpty) {
            return;
          }
          final next = queue.removeAt(0);
          for (final msgOrFun in next) {
            if (msgOrFun is Function) {
              Function.apply(msgOrFun, [messageRaw]);
              return;
            }

            final Object msg = msgOrFun;

            final SatMsgType msgType = getTypeFromSatObject(msg)!;

            if (msgType == SatMsgType.inStartReplicationResp) {
              // Do nothing
            }

            if (msgType == SatMsgType.authResp) {
              socketClient.add(encodeSocketMessage(msgType, msg as SatAuthResp));
            }

            if (msgType == SatMsgType.inStartReplicationResp) {
              socketClient.add(encodeSocketMessage(msgType, msg as SatInStartReplicationResp));
              socketClient.add(
                encodeSocketMessage(
                  SatMsgType.inStartReplicationReq,
                  SatInStartReplicationReq(),
                ),
              );
            }

            if (msgType == SatMsgType.inStopReplicationResp) {
              socketClient.add(encodeSocketMessage(msgType, msg as SatInStopReplicationResp));
            }

            if (msgType == SatMsgType.relation) {
              socketClient.add(encodeSocketMessage(msgType, msg as SatRelation));
            }

            if (msgType == SatMsgType.opLog) {
              socketClient.add(encodeSocketMessage(msgType, msg as SatOpLog));
            }

            if (msgType == SatMsgType.pingReq) {
              socketClient.add(encodeSocketMessage(msgType, msg as SatPingReq));
            }

            if (msgType == SatMsgType.pingResp) {
              socketClient.add(encodeSocketMessage(msgType, msg as SatPingResp));
            }
          }
        });
      } else {
        request.response.statusCode = HttpStatus.notFound;
        request.response.close();
      }
    });
  }

  Future<void> close() async {
    await server.close();
  }

  nextResponses(List<Object> messages) {
    queue.add(messages);
  }
}
