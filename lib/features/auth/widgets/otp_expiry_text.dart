import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/extensions/extensions.dart';

/// Live code-expiry countdown, derived from the server's `expiresAt` /
/// `ttlSeconds`. Purely local UI: it only displays, the Cubit still
/// enforces expiry at submit time. Ticks once a second while mounted.
class OtpExpiryText extends StatefulWidget {
  const OtpExpiryText({super.key, required this.expiresAtMs});

  final int? expiresAtMs;

  @override
  State<OtpExpiryText> createState() => _OtpExpiryTextState();
}

class _OtpExpiryTextState extends State<OtpExpiryText> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.expiresAtMs != null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expiry = widget.expiresAtMs;
    if (expiry == null) {
      return const SizedBox.shrink();
    }
    final remainingMs = expiry - DateTime.now().millisecondsSinceEpoch;
    if (remainingMs <= 0) {
      return Text(
        'Code expired — tap Resend for a fresh code.',
        style: context.textTheme.bodyMedium?.copyWith(
          color: AppColors.error,
          fontWeight: .w700,
        ),
      );
    }
    final totalSeconds = (remainingMs / 1000).ceil();
    final minutes = totalSeconds ~/ 60;
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return Text(
      'Code expires in $minutes:$seconds',
      style: context.textTheme.bodyMedium?.copyWith(
        color: AppColors.textSecondary,
        fontWeight: .w600,
      ),
    );
  }
}
