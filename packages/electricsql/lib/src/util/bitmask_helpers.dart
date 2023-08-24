/// Sets a bit in the mask. Modifies the mask in place.
///
/// Mask is represented as a Uint8Array, which will be serialized element-by-element as a mask.
/// This means that `indexFromStart` enumerates all bits in the mask in the order they will be serialized:
///
/// @example
/// setMaskBit(new Uint8Array([0b00000000, 0b00000000]), 0)
/// // => new Uint8Array([0b10000000, 0b00000000])
///
/// @example
/// setMaskBit(new Uint8Array([0b00000000, 0b00000000]), 8)
/// // => new Uint8Array([0b00000000, 0b10000000])
///
/// @param array Uint8Array mask
/// @param indexFromStart bit index in the mask
void setMaskBit(List<int> array, int indexFromStart) {
  final byteIndex = (indexFromStart / 8).floor();
  final bitIndex = 7 - (indexFromStart % 8);

  final mask = 0x01 << bitIndex;
  array[byteIndex] = array[byteIndex] | mask;
}

/// Reads a bit in the mask
///
/// Mask is represented as a Uint8Array, which will be serialized element-by-element as a mask.
/// This means that `indexFromStart` enumerates all bits in the mask in the order they will be serialized:
///
/// @example
/// getMaskBit(new Uint8Array([0b10000000, 0b00000000]), 0)
/// // => 1
///
/// @example
/// getMaskBit(new Uint8Array([0b10000000, 0b00000000]), 8)
/// // => 0
///
/// @param array Uint8Array mask
/// @param indexFromStart bit index in the mask
int getMaskBit(List<int> array, int indexFromStart) {
  if (array.isEmpty) return 0;
  final byteIndex = (indexFromStart / 8).floor();
  final bitIndex = 7 - (indexFromStart % 8);

  final value = (array[byteIndex] >>> bitIndex) & 0x01;
  assert(value == 0 || value == 1, 'Invalid bit value $value');
  return value;
}
