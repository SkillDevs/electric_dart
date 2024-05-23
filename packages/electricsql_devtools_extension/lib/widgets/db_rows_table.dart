import 'package:data_table_2/data_table_2.dart';
import 'package:electricsql_devtools_extension/widgets/labeled_cell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class DbRowsTable extends HookWidget {
  final List<Map<String, dynamic>> rows;

  const DbRowsTable({required this.rows});

  @override
  Widget build(BuildContext context) {
    final tableSource = useMemoized(() => _DataSource(rows: rows), [rows]);

    if (rows.isEmpty) {
      return const Center(child: Text('No data to show'));
    }

    final sampleRow = rows.first;

    final columns = sampleRow.keys.toList();

    const approximateWidthPerCol = 150.0;

    return PaginatedDataTable2(
      minWidth: columns.length * approximateWidthPerCol,
      isHorizontalScrollBarVisible: true,
      columnSpacing: 25,
      rowsPerPage: 25,
      source: tableSource,
      headingTextStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      headingRowDecoration: const BoxDecoration(
        color: Color.fromARGB(255, 34, 59, 49),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      columns: <DataColumn>[
        ...columns.map(
          (title) => DataColumn(
            label: LabeledTextCell(
              title,
              maxLines: 1,
            ),
          ),
        ),
      ],
    );
  }
}

class _DataSource extends DataTableSource {
  final List<Map<String, dynamic>> rows;

  late final List<String> columns = rows.first.keys.toList();

  _DataSource({required this.rows});

  @override
  DataRow? getRow(int index) {
    if (index >= rows.length) {
      return null;
    }
    final row = rows[index];
    return DataRow(
      cells: columns.map((c) {
        final Object? value = row[c];
        final Widget child;

        if (value == null) {
          child = const Text(
            'NULL',
            style: TextStyle(color: Colors.grey),
          );
        } else {
          child = LabeledTextCell(value.toString());
        }
        return DataCell(child);
      }).toList(),
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => rows.length;

  @override
  int get selectedRowCount => 0;
}
