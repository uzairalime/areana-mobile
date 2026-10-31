import 'package:equatable/equatable.dart';

class CountryDialCode extends Equatable {
  const CountryDialCode({
    required this.code,
    required this.dialCode,
    required this.name,
    required this.flag,
  });

  final String code;
  final String dialCode;
  final String name;
  final String flag;

  String get display => '$flag  $dialCode';

  static const pakistan = CountryDialCode(
    code: 'PK',
    dialCode: '+92',
    name: 'Pakistan',
    flag: '🇵🇰',
  );

  static const defaults = <CountryDialCode>[
    pakistan,
    CountryDialCode(
      code: 'IN',
      dialCode: '+91',
      name: 'India',
      flag: '🇮🇳',
    ),
    CountryDialCode(
      code: 'AE',
      dialCode: '+971',
      name: 'United Arab Emirates',
      flag: '🇦🇪',
    ),
    CountryDialCode(
      code: 'SA',
      dialCode: '+966',
      name: 'Saudi Arabia',
      flag: '🇸🇦',
    ),
    CountryDialCode(
      code: 'GB',
      dialCode: '+44',
      name: 'United Kingdom',
      flag: '🇬🇧',
    ),
    CountryDialCode(
      code: 'US',
      dialCode: '+1',
      name: 'United States',
      flag: '🇺🇸',
    ),
  ];

  static CountryDialCode fromPhone(String? phone) {
    final raw = phone?.trim() ?? '';
    if (raw.isEmpty) return pakistan;
    for (final country in defaults) {
      if (raw.startsWith(country.dialCode)) return country;
    }
    return pakistan;
  }

  static String nationalNumber(String? phone, CountryDialCode country) {
    var raw = (phone ?? '').trim();
    if (raw.startsWith(country.dialCode)) {
      raw = raw.substring(country.dialCode.length).trim();
    }
    raw = raw.replaceFirst(RegExp(r'^0+'), '');
    return raw.replaceAll(RegExp(r'[^\d]'), '');
  }

  String compose(String national) {
    final digits = national.replaceAll(RegExp(r'\D'), '');
    final cleaned = digits.replaceFirst(RegExp(r'^0+'), '');
    return '$dialCode $cleaned'.trim();
  }

  @override
  List<Object?> get props => [code, dialCode];
}
