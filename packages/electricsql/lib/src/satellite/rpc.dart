import 'dart:async';
import 'dart:typed_data';

import 'package:electricsql/src/proto/satellite.pb.dart';
import 'package:electricsql/src/satellite/client.dart';
import 'package:electricsql/src/util/debug/debug.dart';
import 'package:electricsql/src/util/proto.dart';
import 'package:electricsql/src/util/types.dart';
import 'package:protobuf/protobuf.dart';

typedef RequestId = String;

typedef SenderFn = void Function(Object msg);

/// Wrapper class that exposes a `request` method for generated RPC services to use.
///
/// Any `SatRpcResponse` messages should be forwarded to this class to be correctly marked
/// as fulfilled.
class RPC implements RpcClient {
  final SenderFn _sender;
  int defaultTimeout;
  final Logger _log;

  /// Monotonically increasing request id
  int nextRequestId = 1;

  /// Known pending requests and the promise resolvers for them
  final Map<RequestId, ({Timer timer, Completer<List<int>> completer})>
      pendingRequests = {};

  /// Set of request identifiers that had timed out, for better errors
  final Set<RequestId> timedOutCalls = {};

  RPC(
    this._sender,
    this.defaultTimeout,
    this._log,
  );

  /// Perform given RPC method using given message as data.
  ///
  /// This fulfills unexported generated interface `RPC` in `_generated/protocol/satellite.ts`.
  /// The generated service instance expects to pass in an already-encoded message because RPC
  /// is assumed to be part of the transport and not the protocol. Service instance also expects
  /// to receive a still-encoded response.
  ///
  /// The details of the RPC contract are available in `.proto` file for the Satellite protocol,
  /// but the gist is that there are two special messages in the Satellite protocol: `SatRpcRequest`
  /// and `SatRpcResponse` that facilitate the call.
  @override
  Future<T> invoke<T extends GeneratedMessage>(
    ClientContext? ctx,
    String serviceName,
    String method,
    GeneratedMessage messageProto,
    T emptyResponse,
  ) async {
    final message = encodeMessage(messageProto);
    final requestId = nextRequestId++;

    final request = SatRpcRequest(
      method: method,
      requestId: requestId,
      message: message,
    );

    // This line may throw, which is why setting global state is done right after
    _sender(request);

    final completer = Completer<List<int>>();

    // Don't time requests out if debugger is attached to Node instance
    final timer = Timer(Duration(milliseconds: defaultTimeout), () {
      timedOut('$method/$requestId');
    });

    pendingRequests['$method/$requestId'] = (
      completer: completer,
      timer: timer,
    );

    final res = await completer.future;

    // Fill the response by decoding the bytes
    emptyResponse.mergeFromBuffer(res);
    return emptyResponse;
  }

  /// Handle RPC response, dispatching it to the appropriate listener if relevant
  void handleResponse(SatRpcResponse rpc) {
    final RequestId callIdentifier = '${rpc.method}/${rpc.requestId}';
    final pending = pendingRequests[callIdentifier];

    //print("handle $callIdentifier $pending  ${rpc.hasMessage()}  ${rpc.hasError()}  ${rpc.hasField(rpc.getTagNumber("message")!)}  ");
    if (pending != null) {
      if (!rpc.hasError()) {
        pending.completer.complete(rpc.message);
      } else {
        //print("WARNING: 'RPC call $callIdentifier failed with ${msgToString(rpc.error)}'");
        _log.warning(
          'RPC call $callIdentifier failed with ${msgToString(rpc.error)}',
        );
        pending.completer.completeError(rpc.error);
      }
      clearAndDelete(callIdentifier);
    } else if (timedOutCalls.contains(callIdentifier)) {
      timedOutCalls.remove(callIdentifier);
      _log.warning('Got an RPC response for $callIdentifier after timeout');
    } else {
      _log.warning('Got an unexpected RPC response for $callIdentifier');
    }
  }

  void clearAndDelete(RequestId callIdentifier) {
    final pending = pendingRequests[callIdentifier];

    if (pending != null) {
      pending.timer.cancel();
      pendingRequests.remove(callIdentifier);
    }
  }

  void timedOut(RequestId callIdentifier) {
    final pending = pendingRequests[callIdentifier];

    if (pending != null) {
      _log.error(
        'Timed out after ${defaultTimeout}ms while waiting for RPC response to $callIdentifier',
      );
      timedOutCalls.add(callIdentifier);
      pending.completer.completeError(
        SatelliteException(SatelliteErrorCode.timeout, callIdentifier),
      );
      clearAndDelete(callIdentifier);
    }
  }
}

typedef Responder = void Function(SatRpcRequest req, Object respOrError);

/// Build an RPC responder to reply to server-sent RPC requests.
///
/// The responder function itself just correctly wraps the result or error in
/// a SatRpcResponse object, and then sends it.
///
/// @param send function to send the response to the server
/// @returns function that builds and sends the RPC response
Responder rpcRespond(SenderFn send) {
  return (req, respOrError) {
    final SatErrorResp? error =
        respOrError is SatErrorResp ? respOrError : null;
    final message =
        respOrError is! SatErrorResp ? encodeMessage(respOrError) : null;

    print("create response msg=$message error=$error");
    send(
      SatRpcResponse(
        requestId: req.requestId,
        method: req.method,
        message: message,
        error: error,
      ),
    );
  };
}

// TODO(upgrade): Log requests
/// Wrap an RPC service instance to log decoded RPC request & response
///
/// `proto-ts`-generated server instance passes to and expects to receive from
/// the RPC client an already encoded request/response object. To centrally log the decoded
/// version of the object, we wrap the service with a proxy, logging the yet-decoded request
/// before the function call and already-decoded response from the function return.
///
/// @param service Service instance to wrap
/// @returns A proxy around the service instance
RootApi withRpcRequestLogging(RootApi service, Logger logger) {
  return service;
  /* return new Proxy(service, {
    get(target, p, _receiver) {
      if (typeof target[p as keyof Root] === 'function') {
        return new Proxy(target[p as keyof Root], {
          apply(target, thisArg, argArray) {
            if (logger.getLevel() <= 1)
              logger.debug(`[rpc] send: ${msgToString(argArray[0])}`)
            // All methods on the `RootClientImpl` service return promises that contain the response, so we can do this if we return the value
            return Reflect.apply(target, thisArg, argArray).then(
              (x: Awaited<ReturnType<Root[keyof Root]>>) => {
                if (logger.getLevel() <= 1)
                  logger.debug(`[rpc] recv: ${msgToString(x)}`)
                return x
              }
            )
          },
        })
      } else {
        return Reflect.get(target, p)
      }
    },
  }) */
}
