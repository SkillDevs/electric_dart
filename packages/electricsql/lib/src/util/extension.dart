import 'package:electricsql/src/proto/satellite.pb.dart';

extension SatOpUpdateExt on SatOpUpdate {
  SatOpRow? getNullableRowData() {
    return hasRowData() ? rowData : null;
  }

  SatOpRow? getNullableOldRowData() {
    return hasOldRowData() ? oldRowData : null;
  }
}

extension SatOpDeleteExt on SatOpDelete {
  SatOpRow? getNullableOldRowData() {
    return hasOldRowData() ? oldRowData : null;
  }
}

extension SatOpInsertExt on SatOpInsert {
  SatOpRow? getNullableRowData() {
    return hasRowData() ? rowData : null;
  }
}
