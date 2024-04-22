import 'package:electricsql/electricsql.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:todos_electrified/features/auth.dart';
import 'package:todos_electrified/electric.dart';
import 'package:todos_electrified/features/delete_local_db.dart';

/// Connect to Electric and handle errors
AsyncValue<void> useConnectToElectric(WidgetRef ref) {
  final electricClient = ref.watch(electricClientProvider);
  final userId = ref.watch(userIdProvider);

  final connectedAV = useState<AsyncValue<void>>(const AsyncValue.loading());

  final context = ref.context;

  final theme = Theme.of(context);

  final messenger = ScaffoldMessenger.of(context);

  useEffect(() {
    Future(() async {
      try {
        connectedAV.value = const AsyncValue.loading();
        await electricClient.connect(authToken(userId));

        if (!context.mounted) return;
        connectedAV.value = const AsyncValue.data(null);
      } catch (e, st) {
        print("Error connecting to Electric: $e\n$st");

        if (!context.mounted) return;

        connectedAV.value = AsyncValue.error(e, st);

        messenger.showMaterialBanner(
          MaterialBanner(
            content: const Text(
                "Error connecting to Electric, check logs. Consider deleting the local database."),
            actions: [
              DeleteLocalDbButton(
                fgColor: theme.colorScheme.onErrorContainer,
              )
            ],
            backgroundColor: theme.colorScheme.errorContainer,
          ),
        );
      }
    });

    return electricClient.disconnect;
  }, []);

  return connectedAV.value;
}

class ConnectingToElectric extends StatelessWidget {
  const ConnectingToElectric({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Center(
          child: SizedBox(
            height: 15,
            width: 15,
            child: CircularProgressIndicator(),
          ),
        ),
        SizedBox(width: 15),
        Text("Connecting to Electric"),
      ],
    );
  }
}

class ConnectivityButton extends HookConsumerWidget {
  const ConnectivityButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityState = ref.watch(
      connectivityStateControllerProvider
          .select((value) => value.connectivityState),
    );

    final theme = Theme.of(context);

    final ({Color color, IconData icon}) iconInfo =
        switch (connectivityState.status) {
      ConnectivityStatus.connected => (
          icon: Symbols.wifi,
          color: theme.colorScheme.primary
        ),
      ConnectivityStatus.disconnected => (
          icon: Symbols.wifi_off,
          color: theme.colorScheme.error
        ),
    };

    final String label = switch (connectivityState.status) {
      ConnectivityStatus.connected => "Connected",
      ConnectivityStatus.disconnected => "Disconnected",
    };

    return ElevatedButton.icon(
      onPressed: () async {
        final connectivityStateController =
            ref.read(connectivityStateControllerProvider);
        final electricClient = ref.read(electricClientProvider);
        final state = connectivityStateController.connectivityState;
        switch (state.status) {
          case ConnectivityStatus.connected:
            electricClient.disconnect();
          case ConnectivityStatus.disconnected:
            electricClient.connect();
        }
      },
      style: ElevatedButton.styleFrom(foregroundColor: iconInfo.color),
      icon: Icon(iconInfo.icon),
      label: Text(label),
    );
  }
}
