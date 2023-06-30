// void authToken(String? iss, String? key) {
//   final mockIss = iss ?? 'dev.electric-sql.com';
//   final mockKey = key ?? 'integration-tests-signing-key-example';
//   final iat = Math.floor(Date.now() / 1000) - 1000;

//   return jwt.sign(
//       {user_id: 'test-user', type: 'access', iat},
//       mockKey,
//       {
//         issuer: mockIss,
//         algorithm: 'HS256',
//         expiresIn: '2h',
//       });
// }

//TODO(update): This function may not be needed in the client?
