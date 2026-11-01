import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_icons.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/deep_link/deep_link_service.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/services/locator.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/widgets/app_loading_handler.dart';
import '../../../core/widgets/guest_gate.dart';
import '../../../core/widgets/labels_builder.dart';
import '../cubit/notifications_cubit.dart';
import '../cubit/notifications_state.dart';
import '../model/app_notification.dart';
import '../model/notification_filter_tab.dart';
import '../widgets/notification_list_shimmer.dart';
import '../widgets/notification_list_tile.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  void _openNotification(BuildContext context, AppNotification notification) {
    context.read<NotificationsCubit>().markRead(notification.id);
    if (notification.link.trim().isEmpty) return;
    getIt<DeepLinkService>().handleRaw(notification.link);
  }

  @override
  Widget build(BuildContext context) {
    return GuestGate(
      title: 'Log in for reminders',
      message:
          'Get booking confirmations, reminders and updates about your slots.',
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: BlocBuilder<NotificationsCubit, NotificationsState>(
            buildWhen: (p, c) =>
                p.status != c.status ||
                p.errorMessage != c.errorMessage ||
                p.tab != c.tab ||
                p.items != c.items ||
                p.markingAllRead != c.markingAllRead,
            builder: (context, state) {
              final cubit = context.read<NotificationsCubit>();
              return Column(
                crossAxisAlignment: .start,
                children: [
                  _Header(
                    unreadText: state.unreadText,
                    hasUnread: state.hasUnread,
                    onMarkAllRead: cubit.markAllRead,
                  ),
                  12.h,
                  BuildLabels<NotificationFilterTab>(
                    expanded: true,
                    padding: const .symmetric(
                      horizontal: AppSizes.pagePadding,
                    ),
                    labels: NotificationFilterTab.values,
                    label: state.tab,
                    textOf: (value) => value.label,
                    itemHorizontalPadding: 12,
                    onChange: cubit.setTab,
                  ),
                  8.h,
                  Expanded(
                    child: AppLoadingHandler(
                      status: state.status,
                      errorMessage: state.errorMessage,
                      onRetry: cubit.load,
                      loading: const NotificationListShimmer(),
                      child: _NotificationsBody(
                        tab: state.tab,
                        entries: state.listEntries,
                        hasMore: state.hasMore,
                        onLoadMore: cubit.loadMore,
                        onRefresh: cubit.refresh,
                        onOpen: (n) => _openNotification(context, n),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.unreadText,
    required this.hasUnread,
    required this.onMarkAllRead,
  });

  final String unreadText;
  final bool hasUnread;
  final VoidCallback onMarkAllRead;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .fromLTRB(
        AppSizes.pagePadding,
        8,
        8,
        0,
      ),
      child: Row(
        crossAxisAlignment: .start,
        children: [
          IconButton(
            onPressed: () {
              AppHaptics.selection();
              context.pop();
            },
            icon: const Icon(AppIcons.back, size: 18),
            color: AppColors.text,
          ),
          4.w,
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  'Notifications',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontSize: 24,
                    fontWeight: .w800,
                    letterSpacing: -0.4,
                  ),
                ),
                2.h,
                Text(
                  unreadText,
                  style: context.textTheme.labelLarge?.copyWith(
                    fontSize: 13,
                    fontWeight: .w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (hasUnread)
            TextButton(
              onPressed: () {
                AppHaptics.light();
                onMarkAllRead();
              },
              child: Text(
                'Mark all read',
                style: context.textTheme.labelLarge?.copyWith(
                  fontSize: 14,
                  fontWeight: .w800,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NotificationsBody extends StatelessWidget {
  const _NotificationsBody({
    required this.tab,
    required this.entries,
    required this.hasMore,
    required this.onLoadMore,
    required this.onRefresh,
    required this.onOpen,
  });

  final NotificationFilterTab tab;
  final List<NotificationListEntry> entries;
  final bool hasMore;
  final VoidCallback onLoadMore;
  final Future<void> Function() onRefresh;
  final ValueChanged<AppNotification> onOpen;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      onRefresh: onRefresh,
      child: entries.isEmpty
          ? _NotificationsEmpty(tab: tab)
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const .fromLTRB(
                AppSizes.pagePadding,
                4,
                AppSizes.pagePadding,
                32,
              ),
              itemCount: entries.length + (hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= entries.length) {
                  onLoadMore();
                  return const Padding(
                    padding: .symmetric(vertical: 12),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final entry = entries[index];
                return switch (entry) {
                  NotificationGroupHeader(:final title) => Padding(
                    padding: EdgeInsets.only(top: index == 0 ? 0 : 14, bottom: 8),
                    child: Text(
                      title,
                      style: context.textTheme.labelLarge?.copyWith(
                        fontSize: 13,
                        fontWeight: .w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  NotificationRowEntry(:final notification) => Padding(
                    padding: const .only(bottom: 10),
                    child: NotificationListTile(
                      key: ValueKey(notification.id),
                      notification: notification,
                      onTap: () => onOpen(notification),
                    ),
                  ),
                };
              },
            ),
    );
  }
}

class _NotificationsEmpty extends StatelessWidget {
  const _NotificationsEmpty({required this.tab});

  final NotificationFilterTab tab;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: context.screenSize.height * 0.18),
        Icon(tab.emptyIcon, size: 48, color: AppColors.primary).center(),
        16.h,
        Text(
          tab.emptyTitle,
          textAlign: .center,
          style: context.textTheme.headlineMedium?.copyWith(fontSize: 20),
        ),
        8.h,
        Text(
          tab.emptyBody,
          textAlign: .center,
          style: context.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ).paddingSymmetric(horizontal: 40),
      ],
    );
  }
}
