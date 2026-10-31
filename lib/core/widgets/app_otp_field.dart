import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../consts/app_colors.dart';
import '../consts/app_sizes.dart';
import '../extensions/extensions.dart';

class AppOtpField extends StatefulWidget {
  const AppOtpField({
    super.key,
    required this.controller,
    this.length = 6,
    this.onChanged,
    this.validator,
    this.autovalidateMode = .onUserInteraction,
  });

  final TextEditingController controller;
  final int length;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode autovalidateMode;

  @override
  State<AppOtpField> createState() => _AppOtpFieldState();
}

class _AppOtpFieldState extends State<AppOtpField> {
  late final List<TextEditingController> _digits;
  late final List<FocusNode> _nodes;

  @override
  void initState() {
    super.initState();
    _digits = List.generate(widget.length, (_) => TextEditingController());
    _nodes = List.generate(widget.length, (_) => FocusNode());
    _syncFromParent(widget.controller.text);
    widget.controller.addListener(_onParentChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onParentChanged);
    for (final controller in _digits) {
      controller.dispose();
    }
    for (final node in _nodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onParentChanged() {
    if (_joined() == widget.controller.text) {
      return;
    }
    _syncFromParent(widget.controller.text);
  }

  void _syncFromParent(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    for (var i = 0; i < widget.length; i++) {
      final next = i < digits.length ? digits[i] : '';
      if (_digits[i].text != next) {
        _digits[i].value = TextEditingValue(
          text: next,
          selection: TextSelection.collapsed(offset: next.length),
        );
      }
    }
  }

  String _joined() => _digits.map((c) => c.text).join();

  void _writeParent() {
    final value = _joined();
    if (widget.controller.text != value) {
      widget.controller.value = TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      );
    }
    widget.onChanged?.call(value);
  }

  void _applyAt(int index, String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      _digits[index].clear();
      _writeParent();
      if (index > 0) {
        _nodes[index - 1].requestFocus();
      }
      return;
    }

    if (digits.length == 1) {
      _digits[index].text = digits;
      _writeParent();
      if (index < widget.length - 1) {
        _nodes[index + 1].requestFocus();
      } else {
        _nodes[index].unfocus();
      }
      return;
    }

    for (var i = 0; i < digits.length && index + i < widget.length; i++) {
      _digits[index + i].text = digits[i];
    }
    _writeParent();
    final focusAt = (index + digits.length).clamp(0, widget.length - 1);
    _nodes[focusAt].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: (_) => widget.validator?.call(widget.controller.text),
      autovalidateMode: widget.autovalidateMode,
      builder: (field) {
        return Column(
          crossAxisAlignment: .start,
          children: [
            Text(
              'Verification code',
              style: context.textTheme.labelMedium?.copyWith(
                color: AppColors.textBody,
              ),
            ),
            6.h,
            Row(
              children: [
                for (var i = 0; i < widget.length; i++) ...[
                  if (i > 0) 8.w,
                  Expanded(
                    child: TextField(
                      controller: _digits[i],
                      focusNode: _nodes[i],
                      keyboardType: TextInputType.number,
                      textAlign: .center,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: .w800,
                        fontSize: 20,
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: const .symmetric(vertical: 14),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusMd,
                          ),
                          borderSide: BorderSide(
                            color: field.hasError
                                ? AppColors.error
                                : AppColors.border,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusMd,
                          ),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        _applyAt(i, value);
                        field.didChange(widget.controller.text);
                      },
                      onTap: () {
                        _digits[i].selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: _digits[i].text.length,
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
            if (field.hasError) ...[
              6.h,
              Text(
                field.errorText!,
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
