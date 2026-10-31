import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/utils/money_format.dart';
import '../../../core/widgets/app_button.dart';

class BookingStickyBar extends StatelessWidget {
  const BookingStickyBar({
    super.key,
    required this.enabled,
    required this.ctaLabel,
    required this.onPressed,
    this.meta,
    this.total,
    this.disabledLabel = 'Select a time slot to continue',
    this.trailingIcon = Icons.arrow_forward,
  });

  final bool enabled;
  final String ctaLabel;
  final VoidCallback? onPressed;
  final String? meta;
  final int? total;
  final String disabledLabel;
  final IconData trailingIcon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.outline)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0F0D1B14),
            blurRadius: 24,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const .fromLTRB(20, 12, 20, 18),
          child: enabled
              ? Column(
                  mainAxisSize: .min,
                  children: [
                    if (meta != null || total != null)
                      Row(
                        children: [
                          if (meta != null)
                            Text(
                              meta!,
                              style: context.textTheme.labelMedium?.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: .w600,
                                fontSize: 12,
                              ),
                            ).expand(),
                          if (total != null)
                            Text(
                              MoneyFormat.pkr(total!),
                              style: context.textTheme.titleLarge?.copyWith(
                                fontSize: 22,
                                fontWeight: .w800,
                              ),
                            ),
                        ],
                      ),
                    if (meta != null || total != null) 10.h,
                    AppButton(
                      label: ctaLabel,
                      onPressed: onPressed,
                      showArrow: false,
                      icon: trailingIcon,
                    ),
                  ],
                )
              : DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.track,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: SizedBox(
                    height: AppSizes.buttonHeight,
                    width: double.infinity,
                    child: Text(
                      disabledLabel,
                      textAlign: .center,
                      style: context.textTheme.titleSmall?.copyWith(
                        color: AppColors.textBody,
                        fontWeight: .w700,
                        fontSize: 15,
                      ),
                    ).center(),
                  ),
                ),
        ),
      ),
    );
  }
}
