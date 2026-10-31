import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/utils/app_haptics.dart';

class ProfileMenuTile extends StatelessWidget {
  const ProfileMenuTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.iconColor,
    this.labelColor,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? trailing;
  final Color? iconColor;
  final Color? labelColor;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive
        ? AppColors.error
        : labelColor ?? AppColors.text;
    final leading = iconColor ??
        (destructive ? AppColors.error : AppColors.primary);

    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: () {
          AppHaptics.selection();
          onTap();
        },
        child: Padding(
          padding: const .symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 22, color: leading),
              12.w,
              Text(
                label,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: .w700,
                  fontSize: 15,
                  color: color,
                ),
              ).expand(),
              if (trailing != null) ...[
                Text(
                  trailing!,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: .w600,
                  ),
                ),
                6.w,
              ],
              if (!destructive)
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.textDisabled,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileMenuCard extends StatelessWidget {
  const ProfileMenuCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    // Material (not DecoratedBox) so ListTile / SwitchListTile ink +
    // selected fills paint on the correct ancestor.
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        side: const BorderSide(color: AppColors.outline),
      ),
      clipBehavior: .antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              const Divider(height: 1, color: AppColors.outline),
          ],
        ],
      ),
    );
  }
}

class ProfileSectionTitle extends StatelessWidget {
  const ProfileSectionTitle(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: context.textTheme.titleMedium?.copyWith(
        fontWeight: .w800,
        fontSize: 17,
        letterSpacing: -0.1,
      ),
    );
  }
}
