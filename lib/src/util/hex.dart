String toHexString(List<int> byteArray) {
  return byteArray.fold('', (acc, byte)  {
    final String part = '0' + (byte & 0xff).toRadixString(16);

    // TODO: Remove this print
    print("HEX: $byte -> $part");

    final sliced = part.substring(part.length - 2);
    return acc + sliced;
  });
}
