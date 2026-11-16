import 'package:arana360/core/utils/json_parsing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JSON numeric parsing', () {
    test('accepts JSON numbers and Prisma Decimal strings consistently', () {
      for (final value in <Object>[3000, 3000.75, '3000', '3000.75']) {
        expect(JsonParsing.intValue(value), 3000);
      }
      expect(JsonParsing.doubleValue('3000.75'), 3000.75);
      expect(JsonParsing.intValue('-2.75'), -2);
    });

    test('keeps integer precision instead of converting through double', () {
      const precise = 9007199254740993;
      expect(JsonParsing.intValue(precise), precise);
      expect(JsonParsing.intValue('$precise'), precise);
    });

    test(
      'uses nullable and explicit defaults for missing or invalid values',
      () {
        for (final value in <Object?>[null, '', 'unknown', false, <int>[]]) {
          expect(JsonParsing.intOrNull(value), isNull);
          expect(JsonParsing.doubleOrNull(value), isNull);
          expect(JsonParsing.intValue(value, 60), 60);
          expect(JsonParsing.doubleValue(value, 4.5), 4.5);
        }
      },
    );

    test('does not expose non-finite values to price/coordinate consumers', () {
      for (final value in <Object>[
        double.nan,
        double.infinity,
        double.negativeInfinity,
        'NaN',
        'Infinity',
        '-Infinity',
      ]) {
        expect(JsonParsing.intValue(value), 0);
        expect(JsonParsing.doubleOrNull(value), isNull);
      }
    });
  });
}
