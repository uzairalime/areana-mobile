import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/extensions/extensions.dart';
import '../model/chat_message.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    if (message.isDay) {
      return Padding(
        padding: const .symmetric(vertical: 10),
        child: Text(
          message.text,
          textAlign: .center,
          style: context.textTheme.labelMedium?.copyWith(
            fontSize: 12,
            fontWeight: .w700,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    final outbound = message.isOutbound;
    return Align(
      alignment: outbound ? .centerRight : .centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: context.screenSize.width * 0.78,
        ),
        child: Column(
          crossAxisAlignment: outbound ? .end : .start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: outbound ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(outbound ? 18 : 6),
                  bottomRight: Radius.circular(outbound ? 6 : 18),
                ),
                border: outbound
                    ? null
                    : Border.all(color: AppColors.outline),
              ),
              child: Padding(
                padding: const .fromLTRB(14, 12, 14, 12),
                child: Text(
                  message.text,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    height: 1.4,
                    fontWeight: .w500,
                    color: outbound ? AppColors.onPrimary : AppColors.text,
                  ),
                ),
              ),
            ),
            if (message.timeLabel.isNotEmpty) ...[
              4.h,
              Text(
                message.timeLabel,
                style: context.textTheme.labelSmall?.copyWith(
                  fontSize: 11,
                  fontWeight: .w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
