import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/utils/app_haptics.dart';

class ChatComposer extends StatefulWidget {
  const ChatComposer({
    super.key,
    required this.onSend,
    this.quickReplies = const [],
  });

  final ValueChanged<String> onSend;
  final List<String> quickReplies;

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  bool get _canSend => _controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController()..addListener(_onChanged);
    _focusNode = FocusNode();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  void _submit([String? override]) {
    final text = (override ?? _controller.text).trim();
    if (text.isEmpty) return;
    AppHaptics.light();
    widget.onSend(text);
    _controller.clear();
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onChanged)
      ..dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showQuick = widget.quickReplies.isNotEmpty && !_canSend;

    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: .min,
          children: [
            if (showQuick)
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: .horizontal,
                  padding: const .symmetric(horizontal: 16),
                  itemCount: widget.quickReplies.length,
                  separatorBuilder: (_, _) => 8.w,
                  itemBuilder: (context, index) {
                    final label = widget.quickReplies[index];
                    return ActionChip(
                      label: Text(label),
                      onPressed: () => _submit(label),
                      backgroundColor: AppColors.surface,
                      side: const BorderSide(color: AppColors.outline),
                      labelStyle: context.textTheme.labelLarge?.copyWith(
                        fontSize: 13,
                        fontWeight: .w700,
                        color: AppColors.primary,
                      ),
                    );
                  },
                ),
              ),
            if (showQuick) 8.h,
            Padding(
              padding: const .fromLTRB(16, 0, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      onSubmitted: (_) => _submit(),
                      textInputAction: .send,
                      decoration: InputDecoration(
                        hintText: 'Type a message',
                        filled: true,
                        fillColor: AppColors.surface,
                        contentPadding: const .symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: const BorderSide(color: AppColors.outline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: const BorderSide(color: AppColors.outline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                  8.w,
                  DecoratedBox(
                    decoration: BoxDecoration(
                      shape: .circle,
                      color: _canSend
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.35),
                    ),
                    child: IconButton(
                      onPressed: _canSend ? _submit : null,
                      icon: const Icon(Icons.send_rounded),
                      color: AppColors.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
