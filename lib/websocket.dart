import 'dart:typed_data';

import 'package:electric_client/satellite/client.dart';
import 'package:events_emitter/events_emitter.dart';
import 'package:web_socket_client/web_socket_client.dart';

class WebsocketIO extends EventEmitter {
  final Client client;

  WebsocketIO(this.client);

  void open() {
    // Create a WebSocket client.
    final socket = WebSocket(Uri.parse('ws://localhost:5133/ws'));

// Listen to messages from the server.
    socket.messages.listen((rawBytes) {
      // Handle incoming messages.

      final Uint8List messageBytes = rawBytes as Uint8List;

      print("Runtime type ${messageBytes.runtimeType}");

      print(messageBytes);
      late final DecodedMessage messageInfo;
      try {
        // TODO: Use union instead of throwing
        messageInfo = client.toMessage(messageBytes);
      } catch (e) {
        print(e);
        // this.emit('error', messageOrError)
        emit("error", messageInfo);
        return;
      }

      print("Received message ${messageInfo.msg.runtimeType}");
      final handler = client.getIncomingHandlerForMessage(messageInfo.msgType);
      final response = handler.handle(messageInfo.msg);

      if (handler.isRpc) {
        emit("rpc_response", response);
      }
    });

// Send a message to the server.
    // socket.send('ping');

// Close the connection.
    // socket.close();
  }
}
