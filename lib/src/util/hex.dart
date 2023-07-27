String toHexString(List<int> byteArray) {
  return byteArray.fold('', (acc, byte) {
    final String part = (byte & 0xff).toRadixString(16).padLeft(2, '0');
    return acc + part;
  });
}
