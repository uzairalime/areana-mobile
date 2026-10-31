import 'package:flutter/material.dart';

import '../consts/app_colors.dart';
import '../extensions/extensions.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    required this.hint,
    this.obscureText = false,
    this.onToggleObscure,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.validator,
    this.autovalidateMode = .onUserInteraction,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final bool obscureText;
  final VoidCallback? onToggleObscure;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode autovalidateMode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          label,
          style: context.textTheme.labelMedium?.copyWith(
            color: AppColors.textBody,
            fontWeight: .w700,
          ),
        ),
        6.h,
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onChanged: onChanged,
          validator: validator,
          autovalidateMode: autovalidateMode,
          style: context.textTheme.titleSmall,
          decoration: InputDecoration(
            hintText: hint,
            errorMaxLines: 2,
            prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
            suffixIcon: onToggleObscure == null
                ? null
                : IconButton(
                    onPressed: onToggleObscure,
                    icon: Icon(
                      obscureText
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textBody,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
