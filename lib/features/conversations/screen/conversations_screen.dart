import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/widgets/app_loading_handler.dart';
import '../../../core/widgets/guest_gate.dart';
import '../../../core/widgets/labels_builder.dart';
import '../../../core/widgets/pagination_loader.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../cubit/conversations_cubit.dart';
import '../cubit/conversations_state.dart';
import '../model/conversation_models.dart';

class ConversationsScreen extends StatelessWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GuestGate(
      title: 'Sign in to chat',
      message: 'Your arena conversations show up here after you book a court.',
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Padding(
                padding: const .fromLTRB(
                  AppSizes.pagePadding,
                  12,
                  AppSizes.pagePadding,
                  0,
                ),
                child: Text(
                  'Messages',
                  style: context.textTheme.headlineMedium?.copyWith(
                    fontWeight: .w800,
                    fontSize: 28,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
              14.h,
              const _SearchField().paddingSymmetric(
                horizontal: AppSizes.pagePadding,
              ),
              14.h,
              BlocBuilder<ConversationsCubit, ConversationsState>(
                buildWhen: (p, c) =>
                    p.filter != c.filter || p.unreadThreadCount != c.unreadThreadCount,
                builder: (context, state) {
                  return Padding(
                    padding: const .symmetric(horizontal: AppSizes.pagePadding),
                    child: BuildLabels<ConversationInboxFilter>(
                      expanded: true,
                      labels: ConversationInboxFilter.values,
                      label: state.filter,
                      textOf: (value) => value == .unread && state.unreadThreadCount > 0
                          ? 'Unread  ${state.unreadThreadCount}'
                          : value.label,
                      onChange: (value) {
                        AppHaptics.selection();
                        context.read<ConversationsCubit>().setFilter(value);
                      },
                    ),
                  );
                },
              ),
              8.h,
              const _ThreadList().expand(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        border: Border.all(color: AppColors.outline),
      ),
      child: TextField(
        onChanged: context.read<ConversationsCubit>().search,
        textInputAction: .search,
        decoration: InputDecoration(
          hintText: 'Search chats',
          hintStyle: context.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.textSecondary,
          ),
          border: .none,
          contentPadding: const .symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }
}

class _ThreadList extends StatelessWidget {
  const _ThreadList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConversationsCubit, ConversationsState>(
      builder: (context, state) {
        final cubit = context.read<ConversationsCubit>();
        return AppLoadingHandler(
          status: state.status,
          errorMessage: state.errorMessage,
          onRetry: cubit.load,
          loading: const _ThreadShimmer(),
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: cubit.refresh,
            child: state.visibleThreads.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      80.h,
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 40,
                        color: AppColors.primary.withValues(alpha: 0.7),
                      ).center(),
                      12.h,
                      Text(
                        state.filter == .unread
                            ? 'No unread chats'
                            : 'No conversations yet',
                        textAlign: .center,
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: .w800,
                        ),
                      ),
                      6.h,
                      Text(
                        'Book a court, then chat with the arena from your booking.',
                        textAlign: .center,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ).paddingSymmetric(horizontal: 32),
                    ],
                  )
                : ListView.separated(
                    padding: const .fromLTRB(
                      AppSizes.pagePadding,
                      8,
                      AppSizes.pagePadding,
                      110,
                    ),
                    itemCount: state.visibleThreads.length + (state.hasMore ? 1 : 0),
                    separatorBuilder: (_, _) => 10.h,
                    itemBuilder: (context, index) {
                      if (index >= state.visibleThreads.length) {
                        return PaginationLoader(
                          pageKey: state.nextCursor,
                          enabled: !state.isLoadingMore,
                          errorMessage: state.errorMessage,
                          onLoadMore: cubit.loadMore,
                        );
                      }
                      final thread = state.visibleThreads[index];
                      return _ThreadTile(
                        thread: thread,
                        onTap: () async {
                          AppHaptics.selection();
                          await context.push(
                            '${AppRoutes.chat}/${thread.id}',
                            extra: thread,
                          );
                          if (context.mounted) cubit.refresh();
                        },
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}

class _ThreadTile extends StatelessWidget {
  const _ThreadTile({required this.thread, required this.onTap});

  final ConversationThread thread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const .fromLTRB(12, 12, 14, 12),
          child: Row(
            children: [
              ProfileAvatar(
                username: thread.title,
                size: 48,
                backgroundColor: AppColors.primarySoft,
                foregroundColor: AppColors.primary,
              ),
              12.w,
              Column(
                crossAxisAlignment: .start,
                children: [
                  Text(
                    thread.title,
                    maxLines: 1,
                    overflow: .ellipsis,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: .w800,
                    ),
                  ),
                  4.h,
                  Text(
                    thread.lastPreview.isEmpty
                        ? 'Start a conversation'
                        : thread.lastPreview,
                    maxLines: 1,
                    overflow: .ellipsis,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ).expand(),
              8.w,
              Column(
                crossAxisAlignment: .end,
                children: [
                  Text(
                    thread.compactAgo(DateTime.now()),
                    style: context.textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: .w600,
                    ),
                  ),
                  if (thread.hasUnread) ...[
                    8.h,
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
                            style: context.textTheme.labelSmall?.copyWith(
                              color: AppColors.accent,
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
      ),
    );
  }
}

class _ThreadShimmer extends StatelessWidget {
  const _ThreadShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const .fromLTRB(
        AppSizes.pagePadding,
        8,
        AppSizes.pagePadding,
        110,
      ),
      itemCount: 4,
      separatorBuilder: (_, _) => 10.h,
      itemBuilder: (_, _) => const ColoredBox(
        color: AppColors.surface,
        child: SizedBox(height: 76),
      ),
    );
  }
}
