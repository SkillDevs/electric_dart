import 'dart:async';
import 'package:data_table_2/data_table_2.dart';
import 'package:electricsql/electricsql.dart';
// ignore: invalid_use_of_internal_member, implementation_imports
import 'package:electricsql/src/devtools/shared.dart';
import 'package:electricsql_devtools_extension/remote.dart';
import 'package:electricsql_devtools_extension/tabs.dart';
import 'package:electricsql_devtools_extension/widgets/chip.dart';
import 'package:electricsql_devtools_extension/widgets/labeled_cell.dart';
import 'package:flutter/material.dart';

class ShapesTab extends StatefulWidget {
  const ShapesTab({super.key, required this.props});

  final DevToolsDbProps props;

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

    return DataTable2(
      minWidth: 800,
      isHorizontalScrollBarVisible: true,
      columns: <DataColumn>[
        ...['Shape Subscription Key', 'Table', 'Include', 'Where', 'Status']
            .map(
          (title) => DataColumn(
            label: LabeledTextCell(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
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
              includeStr = include.map((v) => v.select.tablename).join(', ');
            }

            return DataRow(
              cells: <DataCell>[
                DataCell(LabeledTextCell(shape.key)),
                DataCell(LabeledTextCell(shape.shape.tablename)),
                DataCell(LabeledTextCell(includeStr)),
                DataCell(LabeledTextCell(shape.shape.where ?? '')),
                DataCell(buildStatusCell(shape.status)),
              ],
            );
          },
        ),
      ],
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
