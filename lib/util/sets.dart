List<T> difference<T>(List<T> a, List<T> b) {
  final bset = Set<T>.from(b);
  return a.where((x) => !bset.contains(x)).toList();
}

List<T> union<T>(List<T> a, List<T> b) {
  return <T>{...a, ...b}.toList();
}
