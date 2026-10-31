import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../model/chat_thread.dart';

class ConversationTile extends StatelessWidget {
  const ConversationTile({
    super.key,
    required this.thread,
    required this.onTap,
  });

  final ChatThread thread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
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
          ),
          child: Padding(
            padding: const .fromLTRB(14, 14, 14, 14),
            child: Row(
              children: [
                ProfileAvatar(
                  username: thread.name,
                  size: 48,
                  backgroundColor: thread.avatarBg,
                  foregroundColor: thread.avatarFg,
                  fontSize: 15,
                ),
                12.w,
                Expanded(
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              thread.name,
                              maxLines: 1,
                              overflow: .ellipsis,
                              style: context.textTheme.titleSmall?.copyWith(
                                fontSize: 15,
                                fontWeight: .w800,
                                letterSpacing: -0.1,
                              ),
                            ),
                          ),
                          8.w,
                          Text(
                            thread.timeLabel,
                            style: context.textTheme.labelMedium?.copyWith(
                              fontSize: 12,
                              fontWeight: .w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      4.h,
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              thread.preview,
                              maxLines: 1,
                              overflow: .ellipsis,
                              style: context.textTheme.bodyMedium?.copyWith(
                                fontSize: 13,
                                fontWeight: thread.hasUnread ? .w700 : .w500,
                                color: thread.hasUnread
                                    ? AppColors.text
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                          if (thread.hasUnread) ...[
                            8.w,
                            DecoratedBox(
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: .circle,
                              ),
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: Center(
                                  child: Text(
                                    thread.unreadCount > 9
                                        ? '9+'
                                        : '${thread.unreadCount}',
                                    style: context.textTheme.labelSmall
                                        ?.copyWith(
                                          color: AppColors.onPrimary,
                                          fontWeight: .w800,
                                          fontSize: 11,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
