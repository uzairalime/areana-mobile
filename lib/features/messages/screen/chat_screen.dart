import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_icons.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/widgets/app_loading_handler.dart';
import '../../../core/widgets/app_shimmer.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_state.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_composer.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key, required this.threadId});

  final String threadId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<ChatCubit, ChatState>(
          buildWhen: (p, c) =>
              p.status != c.status ||
              p.errorMessage != c.errorMessage ||
              p.thread != c.thread ||
              p.messages != c.messages,
          builder: (context, state) {
            final cubit = context.read<ChatCubit>();
            final thread = state.thread;

            return Column(
              children: [
                _ChatHeader(
                  title: thread?.name ?? 'Chat',
                  subtitle: thread?.subtitle ?? '',
                  initialsName: thread?.name ?? '',
                  avatarBg: thread?.avatarBg ?? AppColors.primarySoft,
                  avatarFg: thread?.avatarFg ?? AppColors.primary,
                  contextLabel: thread?.contextLabel ?? '',
                ),
                Expanded(
                  child: AppLoadingHandler(
                    status: state.status,
                    errorMessage: state.errorMessage,
                    onRetry: cubit.load,
                    loading: const _ChatShimmer(),
                    child: ListView.builder(
                      padding: const .fromLTRB(
                        AppSizes.pagePadding,
                        8,
                        AppSizes.pagePadding,
                        16,
                      ),
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {
                        final message = state.messages[index];
                        return Padding(
                          padding: const .only(bottom: 10),
                          child: ChatBubble(
                            key: ValueKey(message.id),
                            message: message,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                ChatComposer(
                  quickReplies: thread?.quickReplies ?? const [],
                  onSend: cubit.send,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({
    required this.title,
    required this.subtitle,
    required this.initialsName,
    required this.avatarBg,
    required this.avatarFg,
    required this.contextLabel,
  });

  final String title;
  final String subtitle;
  final String initialsName;
  final Color avatarBg;
  final Color avatarFg;
  final String contextLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .fromLTRB(8, 4, 12, 8),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  AppHaptics.selection();
                  context.pop();
                },
                icon: const Icon(AppIcons.back, size: 18),
                color: AppColors.text,
              ),
              ProfileAvatar(
                username: initialsName,
                size: 40,
                backgroundColor: avatarBg,
                foregroundColor: avatarFg,
                fontSize: 13,
              ),
              10.w,
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: .ellipsis,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: .w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: .ellipsis,
                        style: context.textTheme.labelMedium?.copyWith(
                          fontSize: 12,
                          fontWeight: .w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (contextLabel.isNotEmpty)
            Align(
              alignment: .centerLeft,
              child: Padding(
                padding: const .only(left: 52, right: 8),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Padding(
                    padding: const .symmetric(horizontal: 10, vertical: 6),
                    child: Row(
                      mainAxisSize: .min,
                      children: [
                        const Icon(
                          Icons.event_rounded,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        6.w,
                        Flexible(
                          child: Text(
                            contextLabel,
                            maxLines: 1,
                            overflow: .ellipsis,
                            style: context.textTheme.labelMedium?.copyWith(
                              fontSize: 12,
                              fontWeight: .w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ChatShimmer extends StatelessWidget {
  const _ChatShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const .fromLTRB(
        AppSizes.pagePadding,
        16,
        AppSizes.pagePadding,
        16,
      ),
      children: [
        const ShimmerBox(width: 64, height: 12, radius: 6).center(),
        16.h,
        const Align(
          alignment: .centerRight,
          child: ShimmerBox(width: 220, height: 48, radius: 16),
        ),
        12.h,
        const Align(
          alignment: .centerLeft,
          child: ShimmerBox(width: 240, height: 64, radius: 16),
        ),
        12.h,
        const Align(
          alignment: .centerLeft,
          child: ShimmerBox(width: 200, height: 48, radius: 16),
        ),
        12.h,
        const Align(
          alignment: .centerRight,
          child: ShimmerBox(width: 180, height: 48, radius: 16),
        ),
      ],
    ).shimmer();
  }
}
