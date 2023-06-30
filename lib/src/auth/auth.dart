import 'dart:convert';

import 'package:electric_client/src/config/config.dart';
import 'package:electric_client/src/satellite/satellite.dart';
import 'package:electric_client/src/util/debug/debug.dart';
import 'package:http/http.dart' as http;

class AuthState {
  final String clientId;
  final String token;

  AuthState({
    required this.clientId,
    required this.token,
  });
}

class AuthConfig {
  final String? clientId;
  final String token;

  AuthConfig({
    required this.clientId,
    required this.token,
  });
}

// TODO(update): remove
// class TokenRequest {
//   final String app;
//   final String env;
//   final String clientId;

//   TokenRequest({
//     required this.app,
//     required this.env,
//     required this.clientId,
//   });
// }

// TODO(update): remove
// class TokenResponse {
//   final String token;
//   final String refreshToken;

//   TokenResponse({required this.token, required this.refreshToken});
// }


// TODO(update): remove
// class ConsoleHttpClient implements ConsoleClient {
//   final ElectricConfig config;

//   ConsoleHttpClient(this.config);

//   @override
//   Future<TokenResponse> token(TokenRequest req) async {
//     logger.info("fetching token for ${req.app} ${req.env} ${req.clientId}");

//     final protocol = config.console?.ssl == true ? 'https' : 'http';
//     final host = "$protocol://${config.console?.host}:${config.console?.port}";

//     final Map<String, Object?> bodyJ = {
//       "data": <String, Object?>{
//         "app": req.app,
//         "env": req.env,
//         "username": req.clientId,
//       }
//     };

//     final res = await http.post(
//       Uri.parse(
//         "$host/api/v1/jwt/auth/login",
//       ),
//       headers: {
//         'Content-Type': 'application/json',
//       },
//       body: json.encode(bodyJ),
//     );

//     final response =
//         await json.decode(utf8.decode(res.bodyBytes)) as Map<String, Object?>;

//     if (response['errors'] != null) {
//       throw Exception('unable to fetch token ${response['errors']}');
//     }

//     final responseData = response["data"]! as Map<String, Object?>;
//     return TokenResponse(
//       token: responseData['token']! as String,
//       refreshToken: responseData['refreshToken']! as String,
//     );
//   }
// }
