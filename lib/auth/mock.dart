import 'package:electric_client/auth/auth.dart';
import 'package:electric_client/satellite/satellite.dart';

class MockConsoleClient implements ConsoleClient {
  @override
  Future<TokenResponse> token(TokenRequest req) {
    return Future.value(TokenResponse(token: 'MOCK_TOKEN', refreshToken: 'MOCK_REFRESH_TOKEN'));
  }
}
