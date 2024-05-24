import 'dart:async';

// ignore: invalid_use_of_internal_member, implementation_imports
import 'package:electricsql/src/devtools/shared.dart';
import 'package:electricsql_devtools_extension/remote.dart';
import 'package:electricsql_devtools_extension/tabs.dart';
import 'package:electricsql_devtools_extension/widgets/db_rows_table.dart';
import 'package:electricsql_devtools_extension/widgets/scroll_behavior.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class InspectTablesTab extends HookWidget {
  const InspectTablesTab({super.key, required this.props});

  final DevToolsDbProps props;

  @override
  Widget build(BuildContext context) {
    final dbName = props.dbName;

    final tablesVN = useState<List<DbTableInfo>?>(null);
    final tableInfoVN = useState<DbTableInfo?>(null);
    final dbRowsVN = useState<List<Map<String, Object?>>>([]);

    final tables = tablesVN.value;
    final tableInfo = tableInfoVN.value;

    useEffect(
      () {
        (() async {
          final res = await Future.wait<List<DbTableInfo>>([
            kRemoteToolbar.getDbTables(dbName),
            kRemoteToolbar.getElectricTables(dbName),
          ]);
          final dbTables = res[0];
          final electricTables = res[1];
          final allTables = [...dbTables, ...electricTables];
          if (context.mounted) {
            tablesVN.value = allTables;
            if (allTables.isNotEmpty) {
              tableInfoVN.value = allTables.first;
            }
          }
        })();

        return null;
      },
      [dbName],
    );

    useEffect(
      () {
        Future<void> Function()? unsubscribe;
        if (tableInfo != null) {
          () async {
            Future<void> updateTableData() async {
              final rows = await kRemoteToolbar
                  .queryDb(dbName, 'SELECT * FROM ${tableInfo.name}', []);
              if (context.mounted) {
                dbRowsVN.value = rows.rows;
              }
            }

            unawaited(updateTableData());
            unsubscribe = await kRemoteToolbar.subscribeToDbTable(
              dbName,
              tableInfo.name,
              updateTableData,
            );
          }();
        } else {
          dbRowsVN.value = [];
        }
        return () {
          unsubscribe?.call();
        };
      },
      [dbName, tableInfo],
    );

    if (tables == null) {
      return const Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 15),
            Text('Loading tables...'),
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 200,
          child: _TablesList(
            tables: tables,
            selectedTable: tableInfo,
            onTableSelected: (t) => tableInfoVN.value = t,
          ),
        ),
        const VerticalDivider(width: 10),
        Expanded(
          child: DbRowsTable(rows: dbRowsVN.value),
        ),
      ],
    );
  }
}

class _TablesList extends StatelessWidget {
  const _TablesList({
    required this.tables,
    required this.selectedTable,
    required this.onTableSelected,
  });

  final List<DbTableInfo> tables;
  final DbTableInfo? selectedTable;
  final void Function(DbTableInfo) onTableSelected;

  @override
  Widget build(BuildContext context) {
    final electricTableIdxStart =
        tables.indexWhere((t) => t.name.startsWith('_electric'));

    return AlwaysScrollbarConfiguration(
      child: ListView.separated(
        itemCount: tables.length,
        separatorBuilder: (context, index) =>
            (electricTableIdxStart >= 0 && (index + 1) == electricTableIdxStart)
                ? const Divider(height: 1)
                : const SizedBox(),
        itemBuilder: (context, index) {
          final table = tables[index];
          return ListTile(
            selected: table.name == selectedTable?.name,
            title: Text(table.name),
            onTap: () => onTableSelected(table),
          );
        },
      ),
    );
  }
}
