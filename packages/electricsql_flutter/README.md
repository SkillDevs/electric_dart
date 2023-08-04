## electricsql_flutter

Extra set of utilities when using Electric in a Flutter application to complement `electricsql`.

### Features

#### `ConnectivityStateController`
 A `ChangeNotifier` that you can use if you want to get notified about the `ConnectivityState` state between the app and the Electric service.
 It can be instantiated after electrifying the database:

 ```dart
final namespace = await electrify(...);
// Make sure to call [init] at the begining and call [dispose] when needed.
final controller = ConnectivityStateController(electricClient)..init();
 ```