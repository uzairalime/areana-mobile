import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/extensions/extensions.dart';

class AuthStepHeader extends StatelessWidget {
  const AuthStepHeader({
    super.key,
    required this.step,
    required this.total,
    required this.title,
    required this.subtitle,
  });

  final int step;
  final int total;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          'Step $step of $total',
          style: context.textTheme.labelLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: .w700,
          ),
        ),
        8.h,
        Row(
          children: [
            for (var i = 1; i <= total; i++) ...[
              if (i > 1) 6.w,
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: i <= step ? AppColors.primary : AppColors.track,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: const SizedBox(height: 4),
                ),
              ),
            ],
          ],
        ),
        20.h,
        Text(title, style: context.textTheme.headlineLarge),
        8.h,
        Text(
          subtitle,
          style: context.textTheme.titleSmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: .w500,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}
