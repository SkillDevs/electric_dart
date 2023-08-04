import 'dart:io';

Future<void> removeFile(String fileName) async {
  final file = File(fileName);
  if (await file.exists()) {
    await file.delete();
  }
}
