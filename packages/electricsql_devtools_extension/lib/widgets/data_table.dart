import 'package:flutter/material.dart';

class SimpleTableRow {
  final String title;
  final Widget child;

  const SimpleTableRow({
    required this.title,
    required this.child,
  });
}

class SimpleTable extends StatelessWidget {
  final List<SimpleTableRow> items;

  const SimpleTable({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const {
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        for (final item in items)
          TableRow(
            children: [
              _FirstCol(child: Text(item.title)),
              _SecondCol(child: item.child),
            ],
          ),
      ],
    );
  }
}

class _FirstCol extends StatelessWidget {
  final Widget child;

  const _FirstCol({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: TextStyle(color: Theme.of(context).colorScheme.outline),
      child: child,
    );
  }
}

class _SecondCol extends StatelessWidget {
  final Widget child;

  const _SecondCol({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 40),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: child,
        ),
      ),
    );
  }
}
