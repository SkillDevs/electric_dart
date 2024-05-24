import 'dart:async';

import 'package:devtools_extensions/devtools_extensions.dart';
// ignore: invalid_use_of_internal_member, implementation_imports
import 'package:electricsql/src/devtools/shared.dart';
import 'package:electricsql_devtools_extension/remote.dart';
import 'package:electricsql_devtools_extension/tabs.dart';
import 'package:electricsql_devtools_extension/tabs/inspect_tables_tab.dart';
import 'package:electricsql_devtools_extension/tabs/local_db_tab.dart';
import 'package:electricsql_devtools_extension/tabs/shapes_tab.dart';
import 'package:electricsql_devtools_extension/tabs/shell_tab.dart';
import 'package:electricsql_devtools_extension/tabs/status_tab.dart';
import 'package:electricsql_devtools_extension/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(
    const DevToolsExtension(
      child: ProviderScope(child: Portal(child: FooDevToolsExtension())),
    ),
  );
}

class FooDevToolsExtension extends StatefulWidget {
  const FooDevToolsExtension({super.key});

  @override
  State<FooDevToolsExtension> createState() => _FooDevToolsExtensionState();
}

class _FooDevToolsExtensionState extends State<FooDevToolsExtension> {
  List<String>? dbNames;
  DateTime dbNamesUpdatedAt = DateTime.now();

  StreamSubscription<void>? _sub;

  @override
  void initState() {
    super.initState();

    final satellitesChangedStream =
        serviceManager.service!.onExtensionEvent.where((e) {
      return e.extensionKind == 'electricsql:clients-list-changed';
    });

    _sub = satellitesChangedStream.listen((event) async {
      final names = await kRemoteToolbar.getSatelliteNames();
      _changeDbs(names);

      // Reset the state of the db body widget, to prevent inconsistencies
      // between devtools UI state and app state
      setState(() {
        dbNamesUpdatedAt = DateTime.now();
      });
    });

    kRemoteToolbar.getSatelliteNames().then((names) {
      if (mounted) {
        _changeDbs(names);
      }
    });
  }

  void _changeDbs(List<String> newDbNames) {
    setState(() {
      dbNames = newDbNames;
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _dbNames = dbNames;
    // final _dbNames = ['todos_db'];

    return Theme(
      data: getElectricTheme(),
      child: Builder(
        builder: (context) {
          // final theme = Theme.of(context);
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 1080,
                maxWidth: 1920,
              ),
              child: Card.outlined(
                color: kElectricColorScheme.surface,
                child: _dbNames == null || _dbNames.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Waiting for Electric...\nElectrify some database in your app to start',
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20),
                            CircularProgressIndicator(),
                          ],
                        ),
                      )
                    : _Loaded(
                        dbNames: _dbNames,
                        dbNamesUpdatedAt: dbNamesUpdatedAt,
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Loaded extends StatefulWidget {
  final List<String> dbNames;
  final DateTime dbNamesUpdatedAt;

  const _Loaded({
    required this.dbNames,
    required this.dbNamesUpdatedAt,
  });

  @override
  State<_Loaded> createState() => _LoadedState();
}

class _LoadedState extends State<_Loaded> {
  int dbIndex = 0;

  Key dbBodyWidgetKey = UniqueKey();

  void _changeDb(int index, {bool force = false}) {
    if (!force && index == dbIndex) return;

    setState(() {
      dbIndex = index;
      dbBodyWidgetKey = UniqueKey();
    });
  }

  @override
  void didUpdateWidget(covariant _Loaded oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!listEquals(widget.dbNames, oldWidget.dbNames)) {
      final currentDbName = widget.dbNames[dbIndex];
      int newDbIdx = widget.dbNames.indexOf(currentDbName);
      if (newDbIdx < 0) {
        newDbIdx = 0;
      }
      final newDbName = widget.dbNames[newDbIdx];
      _changeDb(newDbIdx, force: currentDbName != newDbName);
    }

    if (widget.dbNamesUpdatedAt != oldWidget.dbNamesUpdatedAt) {
      // Refresh the list of databases
      // This is so that we can fully refresh the "db" UI when the app notifies of
      // a change in the databases.
      // Otherwise we might see inconsistencies in th UI if the app restarts
      setState(() {
        dbBodyWidgetKey = UniqueKey();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedDb = widget.dbNames[dbIndex];

    return DefaultTabController(
      length: 5,
      child: Column(
        children: [
          _Header(
            dbIndex: dbIndex,
            dbNames: widget.dbNames,
            onDbSelected: (index) {
              _changeDb(index);
            },
          ),
          // Database content body
          Expanded(
            child: _Body(
              key: dbBodyWidgetKey,
              dbName: selectedDb,
            ),
          ),
        ],
      ),
    );
  }
}

class _Body extends StatefulWidget {
  final String dbName;
  const _Body({super.key, required this.dbName});

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  bool? canResetDb;
  SqlDialect? dbDialect;

  StreamSubscription<void>? _dbResetChangedSub;
  bool dbResetted = false;

  @override
  void initState() {
    super.initState();

    _listenDbResetChanged();
    _loadCanResetDb(widget.dbName);
    _loadDbDialect(widget.dbName);
  }

  @override
  void dispose() {
    _dbResetChangedSub?.cancel();
    super.dispose();
  }

  Future<void> _loadCanResetDb(String dbName) async {
    final newCanResetDb = await kRemoteToolbar.canResetDb(dbName);
    if (newCanResetDb != canResetDb) {
      setState(() {
        canResetDb = newCanResetDb;
      });
    }
  }

  Future<void> _loadDbDialect(String dbName) async {
    final newDbDialect = await kRemoteToolbar.getDbDialect(dbName);
    if (newDbDialect != dbDialect) {
      setState(() {
        dbDialect = newDbDialect;
      });
    }
  }

  void _listenDbResetChanged() {
    _dbResetChangedSub = serviceManager.service!.onExtensionEvent.where((e) {
      return e.extensionKind == 'electricsql:db-reset-changed' &&
          e.extensionData?.data['db'] == widget.dbName;
    }).listen((e) {
      _loadCanResetDb(widget.dbName);
    });
  }

  @override
  Widget build(BuildContext context) {
    final _canResetDb = canResetDb;
    final _dbDialect = dbDialect;

    if (_canResetDb == null || _dbDialect == null || dbResetted == true) {
      return const Center(child: CircularProgressIndicator());
    }

    final dbName = widget.dbName;

    final tabProps = DevToolsDbProps(
      dbName: dbName,
      dialect: _dbDialect,
    );

    return Column(
      children: <Widget>[
        const TabBar(
          isScrollable: true,
          tabs: [
            Tab(text: 'Connection'),
            Tab(text: 'Local DB'),
            Tab(text: 'Shapes'),
            Tab(text: 'Inspect Tables'),
            Tab(text: 'Shell'),
          ],
        ),
        Expanded(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
            child: TabBarView(
              // controller: _tabController,
              children: [
                StatusTab(props: tabProps),
                LocalDBTab(
                  props: tabProps,
                  canResetDb: _canResetDb,
                  onDbReset: () => setState(() {
                    dbResetted = true;
                  }),
                ),
                ShapesTab(props: tabProps),
                InspectTablesTab(props: tabProps),
                ShellTab(props: tabProps),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final int dbIndex;
  final List<String> dbNames;
  final void Function(int) onDbSelected;

  const _Header({
    required this.dbIndex,
    required this.dbNames,
    required this.onDbSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.bug_report_outlined,
            size: 20,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'ElectricSQL Debug Tools',
              style: TextStyle(fontSize: 16),
            ),
          ),
          if (dbNames.length > 1) ...[
            const SizedBox(width: 8),
            _DbSelector(
              dbIndex: dbIndex,
              dbNames: dbNames,
              onDbSelected: onDbSelected,
            ),
          ] else
            Text(
              dbNames[dbIndex],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }
}

class _DbSelector extends StatelessWidget {
  final int dbIndex;
  final List<String> dbNames;
  final void Function(int) onDbSelected;

  const _DbSelector({
    required this.dbIndex,
    required this.dbNames,
    required this.onDbSelected,
  });

  @override
  Widget build(BuildContext context) {
    final dbName = dbNames[dbIndex];
    return IntrinsicWidth(
      child: DropdownButtonFormField<String>(
        value: dbName,
        items: dbNames
            .map(
              (String value) => DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              ),
            )
            .toList(),
        onChanged: (String? value) {
          if (value != null) {
            final newIndex = dbNames.indexOf(value);
            if (newIndex != -1) {
              onDbSelected(newIndex);
            }
          }
        },
      ),
    );
  }
}
