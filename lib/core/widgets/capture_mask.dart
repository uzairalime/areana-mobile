import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:material_ui/material_ui.dart';

/// Hides [child] from Microsoft Clarity session replay (OTP, phone, email).
class CaptureMask extends StatelessWidget {
  const CaptureMask({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => ClarityMask(child: child);
}
