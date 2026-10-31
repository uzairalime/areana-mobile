import 'package:flutter/widgets.dart';

extension NumSpacingX on num {
  Widget get w => SizedBox(width: toDouble());
  Widget get h => SizedBox(height: toDouble());
}
