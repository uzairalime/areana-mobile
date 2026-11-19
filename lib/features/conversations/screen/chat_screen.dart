import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_state.dart';
import '../model/conversation_models.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.conversationId});

  final String conversationId;

  static ConversationThread? seedOf(GoRouterState state) {
    final extra = state.extra;
    return extra is ConversationThread ? extra : null;
  }

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _input = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _input.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _send(ChatCubit cubit, [String? preset]) async {
    final body = (preset ?? _input.text).trim();
    if (body.isEmpty) return;
    AppHaptics.selection();
    final ok = await cubit.send(body);
    if (!ok || !mounted) return;
    _input.clear();
  }

  Future<void> _call(String phone) async {
    final trimmed = phone.trim();
    if (trimmed.isEmpty) return;
    AppHaptics.selection();
    final uri = Uri(scheme: 'tel', path: trimmed);
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<ChatCubit, ChatState>(
          builder: (context, state) {
            final cubit = context.read<ChatCubit>();
            final thread = state.thread;
            return Column(
              children: [
                _Header(
                  title: thread?.title ?? 'Chat',
                  onBack: () {
                    AppHaptics.selection();
                    context.pop();
                  },
                  onCall: thread != null && thread.venuePhone.isNotEmpty
                      ? () => _call(thread.venuePhone)
                      : null,
                ),
                if (thread?.lastBooking != null)
                  _BookingChip(label: thread!.lastBooking!.chipLabel),
                Expanded(
                  child: state.status == .loading && state.messages.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : _MessageList(
                          messages: state.messages,
                          hasMore: state.hasMore,
                          onLoadMore: cubit.loadMore,
                        ),
                ),
                _Composer(
                  controller: _input,
                  focusNode: _focus,
                  sending: state.sending,
                  onSend: () => _send(cubit),
                  onQuickReply: (text) => _send(cubit, text),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.onBack,
    this.onCall,
  });

  final String title;
  final VoidCallback onBack;
  final VoidCallback? onCall;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .fromLTRB(8, 6, 12, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          ),
          ProfileAvatar(
            username: title,
            size: 40,
            backgroundColor: AppColors.primarySoft,
            foregroundColor: AppColors.primary,
          ),
          10.w,
          Column(
            crossAxisAlignment: .start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: .ellipsis,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: .w800,
                ),
              ),
              2.h,
              Text(
                'Usually replies within an hour',
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ).expand(),
          if (onCall != null)
            IconButton(
              onPressed: onCall,
              icon: const Icon(Icons.phone_rounded, color: AppColors.primary),
            ),
        ],
      ),
    );
  }
}

class _BookingChip extends StatelessWidget {
  const _BookingChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .fromLTRB(16, 0, 16, 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Padding(
          padding: const .symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              8.w,
              Text(
                label,
                maxLines: 1,
                overflow: .ellipsis,
                style: context.textTheme.labelLarge?.copyWith(
                  fontWeight: .w700,
                  color: AppColors.primary,
                  fontSize: 13,
                ),
              ).expand(),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.messages,
    required this.hasMore,
    required this.onLoadMore,
  });

  final List<ChatMessage> messages;
  final bool hasMore;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return Center(
        child: Text(
          'Say hello to the arena',
          style: context.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (hasMore &&
            notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 80) {
          onLoadMore();
        }
        return false;
      },
      child: ListView.builder(
        reverse: true,
        padding: const .fromLTRB(16, 8, 16, 12),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          final older = index + 1 < messages.length
              ? messages[index + 1]
              : null;
          final showDay =
              older == null || !_sameDay(older.createdAt, message.createdAt);
          return Column(
            children: [
              if (showDay) _DayLabel(at: message.createdAt),
              _Bubble(message: message),
            ],
          );
        },
      ),
    );
  }
}

class _DayLabel extends StatelessWidget {
  const _DayLabel({required this.at});

  final DateTime at;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final local = at.toLocal();
    final label = _sameDay(local, now)
        ? 'Today'
        : '${local.day} ${_month(local.month)}';
    return Padding(
      padding: const .symmetric(vertical: 10),
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          ),
          child: Padding(
            padding: const .symmetric(horizontal: 12, vertical: 4),
            child: Text(
              label,
              style: context.textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: .w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final mine = message.mine;
    return Align(
      alignment: mine ? .centerRight : .centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        child: Padding(
          padding: const .only(bottom: 8),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: mine ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(mine ? 18 : 6),
                bottomRight: Radius.circular(mine ? 6 : 18),
              ),
            ),
            child: Padding(
              padding: const .fromLTRB(14, 10, 14, 8),
              child: Column(
                crossAxisAlignment: mine ? .end : .start,
                children: [
                  Text(
                    message.body,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: mine ? AppColors.onPrimary : AppColors.text,
                      height: 1.35,
                    ),
                  ),
                  4.h,
                  Row(
                    mainAxisSize: .min,
                    children: [
                      Text(
                        message.timeLabel,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: mine
                              ? AppColors.onPrimary.withValues(alpha: 0.7)
                              : AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      if (mine) ...[
                        4.w,
                        Icon(
                          Icons.done_all_rounded,
                          size: 14,
                          color: AppColors.accent.withValues(alpha: 0.9),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.focusNode,
    required this.sending,
    required this.onSend,
    required this.onQuickReply,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool sending;
  final VoidCallback onSend;
  final ValueChanged<String> onQuickReply;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Column(
        mainAxisSize: .min,
        children: [
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: .horizontal,
              padding: const .symmetric(horizontal: 16),
              itemCount: conversationQuickReplies.length,
              separatorBuilder: (_, _) => 8.w,
              itemBuilder: (context, index) {
                final text = conversationQuickReplies[index];
                return ActionChip(
                  label: Text(text),
                  onPressed: sending ? null : () => onQuickReply(text),
                  backgroundColor: AppColors.surface,
                  side: const BorderSide(color: AppColors.outline),
                  labelStyle: context.textTheme.labelLarge?.copyWith(
                    fontWeight: .w600,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          8.h,
          Padding(
            padding: const .fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: .newline,
                      decoration: InputDecoration(
                        hintText: 'Type a message',
                        hintStyle: context.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        border: .none,
                        contentPadding: const .fromLTRB(18, 12, 18, 12),
                      ),
                    ),
                  ),
                ),
                10.w,
                Material(
                  color: AppColors.primary,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: sending ? null : onSend,
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: sending
                          ? const Padding(
                              padding: .all(12),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.accent,
                              ),
                            )
                          : const Icon(
                              Icons.send_rounded,
                              color: AppColors.accent,
                              size: 20,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

bool _sameDay(DateTime a, DateTime b) {
  final left = a.toLocal();
  final right = b.toLocal();
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}

String _month(int month) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return months[month - 1];
}
