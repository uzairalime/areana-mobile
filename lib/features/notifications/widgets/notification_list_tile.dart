import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/utils/app_haptics.dart';
import '../model/app_notification.dart';
import '../model/notification_type.dart';

class NotificationListTile extends StatelessWidget {
  const NotificationListTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final type = notification.type;
    final unread = notification.isUnread;

    return Material(
      color: unread ? AppColors.surface : const Color(0xFFF9FAF9),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () {
          AppHaptics.selection();
          onTap();
        },
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.outline),
            boxShadow: unread
                ? const [
                    BoxShadow(
                      color: Color(0x0A0D1B14),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: const .fromLTRB(14, 14, 12, 14),
            child: Row(
              crossAxisAlignment: .start,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    shape: .circle,
                    color: type.iconBg,
                  ),
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: Icon(type.icon, size: 22, color: type.iconFg),
                  ),
                ),
                12.w,
                Expanded(
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text(
                        notification.title,
                        style: context.textTheme.titleSmall?.copyWith(
                          fontSize: 15,
                          fontWeight: .w800,
                          letterSpacing: -0.1,
                          color: AppColors.text,
                        ),
                      ),
                      3.h,
                      Text(
                        notification.body,
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          height: 1.45,
                          color: AppColors.textBody,
                          fontWeight: .w500,
                        ),
                      ),
                      6.h,
                      Text(
                        notification.timeLabel,
                        style: context.textTheme.labelMedium?.copyWith(
                          fontSize: 12,
                          fontWeight: .w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (unread) ...[
                  8.w,
                  const Padding(
                    padding: .only(top: 6),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: .circle,
                        color: AppColors.primary,
                      ),
                      child: SizedBox(width: 10, height: 10),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
