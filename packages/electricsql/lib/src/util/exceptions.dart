class NestedException implements Exception {
  final Object error;
  final String reasonContext;
  final Object innerException;
  final StackTrace innerStackTrace;

  NestedException(
    this.error, {
    required this.reasonContext,
    required this.innerException,
    required this.innerStackTrace,
  });

  @override
  String toString() {
    return '$error\n  $reasonContext: $innerException\n  $innerStackTrace';
  }
}
