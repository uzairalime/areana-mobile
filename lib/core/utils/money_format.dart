abstract final class MoneyFormat {
  static String pkr(int amount) {
    final digits = amount.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      final fromEnd = digits.length - i;
      if (i > 0 && fromEnd % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(digits[i]);
    }
    return 'Rs ${buffer.toString()}';
  }
}
