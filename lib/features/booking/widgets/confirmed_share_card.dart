import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/extensions/extensions.dart';

/// Share card on the confirmed screen: the booking's group share
/// code, joining via web `/join/<shareCode>`.
class ConfirmedShareCard extends StatelessWidget {
  const ConfirmedShareCard({super.key, required this.shareCode});

  final String shareCode;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: .start,
            children: [
              Text(
                'Share with your squad',
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: .w800,
                ),
              ),
              2.h,
              Text(
                'Friends join via /join/$shareCode',
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ).expand(),
          Text(
            shareCode,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: .w800,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ).paddingAll(14),
    );
  }
}
