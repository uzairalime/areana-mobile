class AppValidators {
  const AppValidators._();

  static String? requiredField(String? value, {String message = 'Required'}) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? email(String? value) {
    final requiredError = requiredField(value, message: 'Enter an email');
    if (requiredError != null) {
      return requiredError;
    }
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(value!.trim())) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? password(String? value) {
    final requiredError = requiredField(value, message: 'Enter a password');
    if (requiredError != null) {
      return requiredError;
    }
    if (value!.trim().length < 8) {
      return 'Use at least 8 characters';
    }
    return null;
  }

  static String? phone(String? value) {
    final requiredError = requiredField(
      value,
      message: 'Enter your phone number',
    );
    if (requiredError != null) {
      return requiredError;
    }
    final digits = value!.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  /// National number only (country dial selected separately).
  static String? nationalPhone(String? value) {
    final requiredError = requiredField(
      value,
      message: 'Enter your phone number',
    );
    if (requiredError != null) {
      return requiredError;
    }
    final digits = value!.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 9 || digits.length > 12) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  static String? emailOrPhone(String? value) {
    final requiredError = requiredField(
      value,
      message: 'Enter your email or phone number',
    );
    if (requiredError != null) {
      return requiredError;
    }
    final text = value!.trim();
    if (text.contains('@')) {
      return email(text);
    }
    return phone(text);
  }

  static String? otp(String? value) {
    final requiredError = requiredField(value, message: 'Enter the code');
    if (requiredError != null) {
      return requiredError;
    }
    final digits = value!.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 6) {
      return 'Enter the 6-digit code';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    final requiredError = requiredField(
      value,
      message: 'Confirm your password',
    );
    if (requiredError != null) {
      return requiredError;
    }
    if (value!.trim() != password) {
      return 'Passwords do not match';
    }
    return null;
  }
}
