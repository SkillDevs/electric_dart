// ignore: invalid_use_of_internal_member, implementation_imports
import 'package:electricsql/src/devtools/shared.dart';
import 'package:electricsql_devtools_extension/hooks.dart';
import 'package:electricsql_devtools_extension/remote.dart';
import 'package:electricsql_devtools_extension/tabs.dart';
import 'package:electricsql_devtools_extension/widgets/chip.dart';
import 'package:electricsql_devtools_extension/widgets/code_rich_text.dart';
import 'package:electricsql_devtools_extension/widgets/data_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:highlight/languages/sql.dart' as sql_highlight;
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LocalDBTab extends StatefulWidget {
  final DevToolsDbProps props;
  final VoidCallback onDbReset;
  final bool canResetDb;

  const LocalDBTab({
    super.key,
    required this.props,
    required this.onDbReset,
    required this.canResetDb,
  });

  @override
  State<LocalDBTab> createState() => _LocalDBTabState();
}

class _LocalDBTabState extends State<LocalDBTab> {
  bool _resettingDb = false;
  List<DbTableInfo>? _dbTables;
  List<DbTableInfo>? _electricTables;

  @override
  void initState() {
    super.initState();
    _updateDbName(widget.props.dbName);
  }

  @override
  void didUpdateWidget(covariant LocalDBTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.props.dbName != widget.props.dbName) {
      _updateDbName(widget.props.dbName);
    }
  }

  Future<void> _updateDbName(String dbName) async {
    final api = kRemoteToolbar;
    final dbTables = await api.getDbTables(dbName);
    final electricTables = await api.getElectricTables(dbName);

    if (mounted) {
      setState(() {
        _dbTables = dbTables;
        _electricTables = electricTables;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SimpleTable(
      items: [
        SimpleTableRow(
          title: 'Database Name',
          child: Row(
            children: <Widget>[
              Text(
                widget.props.dbName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              if (widget.canResetDb && _resettingDb)
                const SizedBox.square(
                  dimension: 15,
                  child: CircularProgressIndicator(),
                )
              else
                Tooltip(
                  message: 'Deletes the local db and restarts the app',
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      foregroundColor: const Color(0xfff1a161),
                      backgroundColor: const Color(0xff362517),
                    ),
                    onPressed: !widget.canResetDb
                        ? null
                        : () async {
                            setState(() => _resettingDb = true);
                            await kRemoteToolbar.resetDb(widget.props.dbName);
                            if (!mounted) return;
                            widget.onDbReset();
                          },
                    child: const Text('RESET'),
                  ),
                ),
              // Explain why the reset button is disabled
              if (!widget.canResetDb) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: SelectableText(
                      "To support the 'reset' option you need to use the 'ElectricDevtoolsBinding.registerDbResetCallback' function in your app",
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        SimpleTableRow(
          title: 'Database Tables',
          child: TableDataItems(tables: _dbTables),
        ),
        SimpleTableRow(
          title: 'Internal Tables',
          child: TableDataItems(tables: _electricTables),
        ),
      ],
    );
  }
}

class TableDataItems extends StatelessWidget {
  final List<DbTableInfo>? tables;

  const TableDataItems({super.key, required this.tables});

  @override
  Widget build(BuildContext context) {
    if (tables == null) {
      return const SizedBox.square(
        dimension: 15,
        child: CircularProgressIndicator(),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final table in tables!)
            _TableChip(
              key: Key(table.name),
              table: table,
              // backgroundColor: table.isElectric ? Colors.blue : Colors.green,
            ),
        ],
      ),
    );
  }
}

class _TableChip extends StatefulWidget {
  final DbTableInfo table;
  const _TableChip({super.key, required this.table});

  @override
  State<_TableChip> createState() => _TableChipState();
}

class _TableChipState extends State<_TableChip> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    return PortalTarget(
      visible: hovered,
      portalFollower: IgnorePointer(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _TableChipHover(table: widget.table),
        ),
      ),
      anchor: const Aligned(
        follower: Alignment.topLeft,
        target: Alignment.bottomLeft,
        shiftToWithinBound: AxisFlag(x: true, y: true),
      ),
      child: MouseRegion(
        onEnter: (event) {
          if (!hovered) {
            setState(() {
              hovered = true;
            });
          }
        },
        onExit: (event) {
          if (hovered) {
            setState(() {
              hovered = false;
            });
          }
        },
        child: ColoredChip(
          label: widget.table.name,
          fgAndBgColor: kChipColorGrey,
        ),
      ),
    );
  }
}

class _TableChipHover extends ConsumerWidget {
  const _TableChipHover({
    required this.table,
  });

  final DbTableInfo table;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget child;
    if (table.sql != null && table.sql!.isNotEmpty) {
      child = HookBuilder(
        builder: (context) {
          final codeController = useCodeController(
            text: table.sql,
            language: sql_highlight.sql,
          );

          return CodeRichText(codeController);
        },
      );
    } else {
      child = getColumnsTable();
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                'Schema',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Flexible(child: child),
            ],
          ),
        ),
      ),
    );
  }

  Widget getColumnsTable() {
    return DataTable(
      headingRowHeight: 35,
      dataRowMinHeight: 35,
      dataRowMaxHeight: 35,
      columns: const <DataColumn>[
        DataColumn(
          label: Expanded(
            child: Text(
              'Column',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        DataColumn(
          label: Expanded(
            child: Text(
              'Type',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        DataColumn(
          label: Expanded(
            child: Text(
              'Nullable',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
      rows: <DataRow>[
        for (final column in table.columns)
          DataRow(
            cells: <DataCell>[
              DataCell(Text(column.name)),
              DataCell(Text(column.type)),
              DataCell(
                Icon(
                  column.nullable ? Icons.check : Icons.close,
                  size: 18,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
