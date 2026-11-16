/// Numeric conversion for JSON payloads and Prisma Decimal strings.
abstract final class JsonParsing {
  static int? intOrNull(Object? value) {
    if (value is int) return value;
    final number = _number(value);
    return number != null && number.isFinite ? number.toInt() : null;
  }

  static int intValue(Object? value, [int fallback = 0]) =>
      intOrNull(value) ?? fallback;

  static double? doubleOrNull(Object? value) {
    final number = _number(value);
    return number != null && number.isFinite ? number.toDouble() : null;
  }

  static double doubleValue(Object? value, [double fallback = 0]) =>
      doubleOrNull(value) ?? fallback;

  static num? _number(Object? value) => switch (value) {
    final num number => number,
    final String text => num.tryParse(text),
    _ => null,
  };
}
