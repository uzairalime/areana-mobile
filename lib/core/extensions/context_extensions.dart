import 'package:flutter/material.dart';

extension ContextX on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get colorScheme => theme.colorScheme;

  TextTheme get textTheme => theme.textTheme;

  Size get screenSize => MediaQuery.sizeOf(this);

  void hideKeyboard() => FocusScope.of(this).unfocus();
}
