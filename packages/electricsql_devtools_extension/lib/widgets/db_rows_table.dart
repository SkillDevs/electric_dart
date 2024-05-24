import 'package:data_table_2/data_table_2.dart';
// import 'package:electricsql_devtools_extension/mock/mock_rows.dart';
import 'package:electricsql_devtools_extension/widgets/labeled_cell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

typedef ComparableGetter = Comparable<dynamic>? Function(
  Map<String, Object?> row,
);

class DbRowsTable extends HookWidget {
  final List<Map<String, dynamic>> rows;

  const DbRowsTable({required this.rows});

  // DbRowsTable({required List<Map<String, dynamic>> rows})
  //     : rows = debugGetSampleRows();

  @override
  Widget build(BuildContext context) {
    final tableSource = useMemoized(() => _DataSource(rows: rows), [rows]);
    final _sortColumnIndex = useState<int?>(null);
    final _sortAscending = useState<bool>(true);

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
      sortColumnIndex: _sortColumnIndex.value,
      sortAscending: _sortAscending.value,
      columns: <DataColumn>[
        ...columns.map(
          (column) => DataColumn(
            label: Text(column, maxLines: 2),
            onSort: (columnIndex, ascending) {
              tableSource.sort(_getComparableFunForColumn(column), ascending);
              _sortAscending.value = ascending;
              _sortColumnIndex.value = columnIndex;
            },
          ),
        ),
      ],
    );
  }

  ComparableGetter _getComparableFunForColumn(String column) {
    return (row) {
      final value = row[column];

      if (value == null) {
        return null;
      }

      if (value is num) {
        return value;
      } else if (value is String) {
        return value;
      } else if (value is bool) {
        return value ? 1 : 0;
      } else {
        return null;
      }
    };
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
        } else if (value is bool) {
          child = Icon(
            value ? Icons.check : Icons.close,
            size: 18,
          );
        } else {
          child = LabeledTextCell(value.toString());
        }
        return DataCell(child);
      }).toList(),
    );
  }

  void sort<T>(
    Comparable<T>? Function(Map<String, dynamic> row) getField,
    bool ascending,
  ) {
    rows.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);

      if (aValue == null && bValue == null) {
        return 0;
      }

      // Effective comparable values
      Comparable<dynamic> aC;
      Comparable<dynamic> bC;

      // sort nulls at the end
      if (aValue != null && bValue == null) {
        aC = 0;
        bC = 999;
      } else if (aValue == null && bValue != null) {
        aC = 999;
        bC = 0;
      } else {
        aC = aValue!;
        bC = bValue!;

        // if the types are different, compare them as strings
        if (aC.runtimeType != bC.runtimeType) {
          aC = aC.toString();
          bC = bC.toString();
        }
      }

      try {
        return ascending
            ? Comparable.compare(aC, bC)
            : Comparable.compare(bC, aC);
      } catch (_) {
        return 0;
      }
    });
    notifyListeners();
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => rows.length;

  @override
  int get selectedRowCount => 0;
}
