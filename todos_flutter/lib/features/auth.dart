import 'package:electricsql_flutter/electricsql_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// Generate an insecure authentication JWT.
// See https://electric-sql.com/docs/usage/auth for more details.
String authToken(String userId) {
  final claims = {'user_id': userId};

  return insecureAuthToken(claims);
}

class LoginScreen extends HookWidget {
  final ValueNotifier<String?> userVN;
  const LoginScreen({super.key, required this.userVN});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          UserTile(userId: "1", userVN: userVN),
          UserTile(userId: "2", userVN: userVN),
        ],
      ),
    );
  }
}

class UserTile extends StatelessWidget {
  final String userId;
  final ValueNotifier<String?> userVN;

  const UserTile({super.key, required this.userId, required this.userVN});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.arrow_forward),
      label: Text("User $userId"),
      onPressed: () {
        userVN.value = userId;
      },
    );
  }
}
