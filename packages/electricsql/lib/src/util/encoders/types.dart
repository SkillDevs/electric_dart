abstract interface class TypeEncoder {
  List<int> text(String text);
  List<int> json(Object j); // It can be String or JSON value
  List<int> boolean(Object b); // It can be bool or int
  List<int> timetz(String s);
}

abstract interface class TypeDecoder {
  String text(List<int> bytes, {bool? allowMalformed});
  String json(List<int> bytes, {bool? allowMalformed});
  int boolean(List<int> bytes);
  String timetz(List<int> bytes);
  Object float(List<int> bytes);
}
