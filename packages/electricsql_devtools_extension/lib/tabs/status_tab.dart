import 'package:electricsql/electricsql.dart';
import 'package:electricsql_devtools_extension/remote.dart';
import 'package:electricsql_devtools_extension/tabs.dart';
import 'package:electricsql_devtools_extension/widgets/chip.dart';
import 'package:electricsql_devtools_extension/widgets/data_table.dart';
import 'package:flutter/material.dart';

class StatusTab extends StatefulWidget {
  final ToolbarTabsProps props;

  const StatusTab({
    super.key,
    required this.props,
  });

  @override
  State<StatusTab> createState() => _StatusTabState();
}

class _StatusTabState extends State<StatusTab> {
  ConnectivityState? _status;
  Future<void> Function()? _unsubscribe;

  @override
  void initState() {
    super.initState();
    _updateStatusSusbcription(widget.props.dbName);
  }

  @override
  void didUpdateWidget(covariant StatusTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.props.dbName != widget.props.dbName) {
      _updateStatusSusbcription(widget.props.dbName);
    }
  }

  Future<void> _updateStatusSusbcription(String dbName) async {
    await _unsubscribe?.call();
    _unsubscribe = null;

    _unsubscribe = await kRemoteToolbar.subscribeToSatelliteStatus(dbName, (s) {
      if (mounted) {
        setState(() {
          _status = s;
        });
      }
    });

    final status = await kRemoteToolbar.getSatelliteStatus(dbName);
    if (mounted) {
      setState(() {
        _status = status;
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
    final status = _status;
    if (status == null) {
      return const Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 15),
            Text('Waiting for satellite process...'),
          ],
        ),
      );
    }

    return SimpleTable(
      items: [
        SimpleTableRow(
          title: 'Toggle Connection',
          child: Switch(
            value: status.status == ConnectivityStatus.connected,
            onChanged: (v) {
              kRemoteToolbar.toggleSatelliteStatus(
                widget.props.dbName,
              );
            },
          ),
        ),
        SimpleTableRow(
          title: 'Status',
          child: ColoredChip(
            label: switch (status.status) {
              ConnectivityStatus.connected => 'Connected',
              ConnectivityStatus.disconnected => 'Disconnected',
            },
            fgAndBgColor: status.status == ConnectivityStatus.connected
                ? kChipColorGreen
                : kChipColorRed,
          ),
        ),
        if (status.reason != null)
          SimpleTableRow(
            title: 'Reason',
            child: Text(status.reason!.message ?? 'Unknown'),
          ),
      ],
    );
  }
}
