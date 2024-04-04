import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:todos_electrified/database/database.dart';
import 'package:todos_electrified/electric.dart';

import 'package:todos_electrified/database/drift/connection/connection.dart'
    as db_lib;

StateProvider<bool> dbDeletedProvider = StateProvider((ref) => false);

class DeleteLocalDbButton extends ConsumerWidget {
  final Color? fgColor;

  const DeleteLocalDbButton({this.fgColor, super.key});

  @override
  Widget build(BuildContext context, ref) {
    final messenger = ScaffoldMessenger.of(context);

    return TextButton.icon(
      style: TextButton.styleFrom(
        foregroundColor: fgColor ?? Theme.of(context).colorScheme.error,
      ),
      onPressed: () async {
        messenger.removeCurrentMaterialBanner();

        ref.read(dbDeletedProvider.notifier).update((state) => true);

        print("Closing Electric and deleting local database");

        final electric = ref.read(electricClientProvider);
        await electric.close();
        print("Electric closed");

        final todosDb = ref.read(todosDatabaseProvider);
        await todosDb.todosRepo.close();

        await db_lib.deleteTodosDbFile();
        print("Local database deleted");
      },
      icon: const Icon(Symbols.delete),
      label: const Text("Delete local database"),
    );
  }
}

class DeleteDbScreen extends StatelessWidget {
  const DeleteDbScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Local database has been deleted, please restart the app'),
      ),
    );
  }
}
