import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/widgets/app_loading_handler.dart';
import '../../../core/widgets/guest_gate.dart';
import '../../../core/widgets/labels_builder.dart';
import '../cubit/messages_cubit.dart';
import '../cubit/messages_state.dart';
import '../model/chat_thread.dart';
import '../model/message_filter_tab.dart';
import '../widgets/conversation_tile.dart';
import '../widgets/messages_list_shimmer.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  void _openChat(BuildContext context, ChatThread thread) {
    AppHaptics.selection();
    context.read<MessagesCubit>().markLocalRead(thread.id);
    context.push('${AppRoutes.chat}/${thread.id}');
  }

  @override
  Widget build(BuildContext context) {
    return GuestGate(
      title: 'Log in to start chatting',
      message:
          'Message venues about courts and timings, and get quick help from Pitchside support.',
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          surfaceTintColor: AppColors.background,
          elevation: 0,
          titleSpacing: AppSizes.pagePadding,
          title: Text(
            'Messages',
            style: context.textTheme.titleLarge?.copyWith(
              fontSize: 22,
              fontWeight: .w800,
              letterSpacing: -0.4,
            ),
          ),
          centerTitle: false,
        ),
        body: BlocBuilder<MessagesCubit, MessagesState>(
          buildWhen: (p, c) =>
              p.status != c.status ||
              p.errorMessage != c.errorMessage ||
              p.tab != c.tab ||
              p.threads != c.threads,
          builder: (context, state) {
            final cubit = context.read<MessagesCubit>();
            return Column(
              crossAxisAlignment: .start,
              children: [
                BuildLabels<MessageFilterTab>(
                  expanded: true,
                  padding: const .symmetric(horizontal: AppSizes.pagePadding),
                  labels: MessageFilterTab.values,
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
                    loading: const MessagesListShimmer(),
                    child: _MessagesBody(
                      tab: state.tab,
                      threads: state.visibleThreads,
                      onRefresh: cubit.refresh,
                      onOpen: (thread) => _openChat(context, thread),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MessagesBody extends StatelessWidget {
  const _MessagesBody({
    required this.tab,
    required this.threads,
    required this.onRefresh,
    required this.onOpen,
  });

  final MessageFilterTab tab;
  final List<ChatThread> threads;
  final Future<void> Function() onRefresh;
  final ValueChanged<ChatThread> onOpen;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      onRefresh: onRefresh,
      child: threads.isEmpty
          ? _MessagesEmpty(tab: tab)
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const .fromLTRB(
                AppSizes.pagePadding,
                4,
                AppSizes.pagePadding,
                110,
              ),
              itemCount: threads.length,
              separatorBuilder: (_, _) => 10.h,
              itemBuilder: (context, index) {
                final thread = threads[index];
                return ConversationTile(
                  key: ValueKey(thread.id),
                  thread: thread,
                  onTap: () => onOpen(thread),
                );
              },
            ),
    );
  }
}

class _MessagesEmpty extends StatelessWidget {
  const _MessagesEmpty({required this.tab});

  final MessageFilterTab tab;

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
