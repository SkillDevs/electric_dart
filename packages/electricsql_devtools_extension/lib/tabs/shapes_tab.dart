import 'dart:async';
import 'package:electricsql/electricsql.dart';
// ignore: invalid_use_of_internal_member, implementation_imports
import 'package:electricsql/src/devtools/shared.dart';
import 'package:electricsql_devtools_extension/remote.dart';
import 'package:electricsql_devtools_extension/tabs.dart';
import 'package:electricsql_devtools_extension/widgets/chip.dart';
import 'package:flutter/material.dart';

class ShapesTab extends StatefulWidget {
  const ShapesTab({super.key, required this.props});

  final ToolbarTabsProps props;

  @override
  State<ShapesTab> createState() => _ShapesTabState();
}

class _ShapesTabState extends State<ShapesTab> {
  List<DebugShape>? _shapes;

  Future<void> Function()? _unsubscribe;

  @override
  void initState() {
    super.initState();
    _setupPeriodicShapesFetch(widget.props.dbName);
  }

  @override
  void didUpdateWidget(covariant ShapesTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.props.dbName != widget.props.dbName) {
      _setupPeriodicShapesFetch(widget.props.dbName);
    }
  }

  Future<void> _setupPeriodicShapesFetch(String dbName) async {
    await _unsubscribe?.call();
    _unsubscribe = null;

    _unsubscribe = await kRemoteToolbar.subscribeToSatelliteShapeSubscriptions(
      dbName,
      (shapes) {
        if (mounted) {
          setState(() {
            _shapes = shapes;
          });
        }
      },
    );

    final shapes = await kRemoteToolbar.getSatelliteShapeSubscriptions(dbName);
    if (mounted) {
      setState(() {
        _shapes = shapes;
      });
    }
  }

  @override
  void dispose() {
    _unsubscribe?.call();
    _unsubscribe = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shapes = _shapes;
    if (shapes == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (shapes.isEmpty) {
      return const Center(
        child: Text('No shape subscriptions found'),
      );
    }

    return Scrollbar(
      child: SingleChildScrollView(
        primary: true,
        child: DataTable(
          headingRowHeight: 35,
          dataRowMinHeight: 40,
          dataRowMaxHeight: 40,
          columns: <DataColumn>[
            ...['Shape Subscription Key', 'Table', 'Include', 'Where', 'Status']
                .map(
              (title) => DataColumn(
                label: Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
          rows: <DataRow>[
            ...shapes.map(
              (shape) {
                final include = shape.shape.include;
                final String includeStr;
                if (include == null || include.isEmpty) {
                  includeStr = '';
                } else {
                  includeStr =
                      include.map((v) => v.select.tablename).join(', ');
                }

                return DataRow(
                  cells: <DataCell>[
                    DataCell(Text(shape.key)),
                    DataCell(Text(shape.shape.tablename)),
                    DataCell(Text(includeStr)),
                    DataCell(Text(shape.shape.where ?? '')),
                    DataCell(buildStatusCell(shape.status)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStatusCell(SyncStatusType status) {
    if (status == SyncStatusType.undefined) {
      return const Text('-');
    }
    return ColoredChip(
      label: switch (status) {
        SyncStatusType.active => 'Active',
        SyncStatusType.cancelling => 'Cancelled',
        SyncStatusType.establishing => 'Establishing',
        SyncStatusType.undefined => throw UnimplementedError(),
      },
      fgAndBgColor: switch (status) {
        SyncStatusType.active => kChipColorGreen,
        SyncStatusType.cancelling => kChipColorRed,
        SyncStatusType.establishing => kChipColorOrange,
        SyncStatusType.undefined => throw UnimplementedError(),
      },
    );
  }
}
