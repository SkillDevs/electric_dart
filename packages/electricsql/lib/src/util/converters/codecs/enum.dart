import 'dart:convert';

class ElectricEnumCodec<T extends Enum> extends Codec<T, String> {
  final List<T> values;
  final Map<T, String> dartEnumToPgEnum;

  late final Map<String, T> pgEnumToDartEnum = {
    for (final entry in dartEnumToPgEnum.entries) entry.value: entry.key,
  };

  ElectricEnumCodec({
    required this.dartEnumToPgEnum,
    required this.values,
  }) : assert(dartEnumToPgEnum.length == values.length, 'Invalid enum mapping');

  @override
  Converter<String, T> get decoder => _EnumDecoder(this);

  @override
  Converter<T, String> get encoder => _EnumEncoder(this);
}

class _EnumDecoder<T extends Enum> extends Converter<String, T> {
  final ElectricEnumCodec<T> codec;

  const _EnumDecoder(this.codec);

  @override
  T convert(String input) {
    return codec.pgEnumToDartEnum[input]!;
  }
}

class _EnumEncoder<T extends Enum> extends Converter<T, String> {
  final ElectricEnumCodec<T> codec;

  const _EnumEncoder(this.codec);

  @override
  String convert(T input) {
    return codec.dartEnumToPgEnum[input]!;
  }
}
