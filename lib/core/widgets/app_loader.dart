import 'dart:ui';

import 'package:flutter/material.dart';

import '../consts/app_colors.dart';
import '../extensions/extensions.dart';

class AppLoader {
  AppLoader._();

  static final AppLoader instance = AppLoader._();

  OverlayEntry? _entry;

  void show(
    BuildContext context, {
    required String title,
    required String text,
  }) {
    hide();
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) {
      return;
    }
    _entry = OverlayEntry(
      builder: (context) => _AppLoaderOverlay(title: title, text: text),
    );
    overlay.insert(_entry!);
  }

  void hide() {
    final entry = _entry;
    _entry = null;
    if (entry != null && entry.mounted) {
      entry.remove();
    }
  }
}

class _AppLoaderOverlay extends StatelessWidget {
  const _AppLoaderOverlay({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Material(
      color: Colors.black.withValues(alpha: 0.42),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: (width - 48).clamp(280.0, 440.0),
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.text.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                offset: const Offset(0, 18),
                blurRadius: 44,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: .min,
            children: [
              const SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.primary,
                ),
              ),
              16.h,
              Text(
                title,
                textAlign: .center,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: .w800),
              ),
              8.h,
              Text(
                text,
                textAlign: .center,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ).center(),
      ),
    );
  }
}
