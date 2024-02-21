import 'package:equatable/equatable.dart';

class AuthState {
  final String clientId;
  final String? userId;
  final String? token;

  const AuthState({
    required this.clientId,
    this.userId,
    this.token,
  });

  AuthState copyWith({
    String? clientId,
    String Function()? userId,
    String Function()? token,
  }) {
    return AuthState(
      clientId: clientId ?? this.clientId,
      userId: userId == null ? this.userId : userId(),
      token: token == null ? this.token : token(),
    );
  }
}

class AuthConfig with EquatableMixin {
  final String? clientId;

  const AuthConfig({
    this.clientId,
  });

  @override
  List<Object?> get props => [clientId];
}

typedef TokenClaims = Map<String, Object?>;
