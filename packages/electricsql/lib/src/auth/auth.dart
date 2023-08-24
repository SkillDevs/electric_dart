class AuthState {
  final String clientId;
  final String token;

  const AuthState({
    required this.clientId,
    required this.token,
  });
}

class AuthConfig {
  final String? clientId;
  final String token;

  const AuthConfig({
    this.clientId,
    required this.token,
  });
}

typedef TokenClaims = Map<String, Object?>;
