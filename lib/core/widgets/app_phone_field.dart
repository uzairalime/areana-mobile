import 'package:flutter/material.dart';

import '../consts/app_colors.dart';
import '../consts/app_sizes.dart';
import '../extensions/extensions.dart';
import '../models/country_dial_code.dart';
import '../utils/app_haptics.dart';

class AppPhoneField extends StatelessWidget {
  const AppPhoneField({
    super.key,
    required this.controller,
    required this.country,
    required this.onCountryChanged,
    this.label = 'Phone number',
    this.hint = '300 1234567',
    this.validator,
  });

  final TextEditingController controller;
  final CountryDialCode country;
  final ValueChanged<CountryDialCode> onCountryChanged;
  final String label;
  final String hint;
  final FormFieldValidator<String>? validator;

  Future<void> _pickCountry(BuildContext context) async {
    AppHaptics.selection();
    final next = await showModalBottomSheet<CountryDialCode>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: .vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        final maxHeight = MediaQuery.sizeOf(sheetContext).height * 0.55;
        return SafeArea(
          child: SizedBox(
            height: maxHeight,
            child: Column(
              children: [
                10.h,
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                  ),
                  child: const SizedBox(width: 40, height: 4),
                ),
                14.h,
                Text(
                  'Country code',
                  style: sheetContext.textTheme.titleMedium?.copyWith(
                    fontWeight: .w800,
                  ),
                ),
                8.h,
                Expanded(
                  child: ListView.separated(
                    itemCount: CountryDialCode.defaults.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, color: AppColors.outline),
                    itemBuilder: (context, index) {
                      final item = CountryDialCode.defaults[index];
                      final selected = item.code == country.code;
                      return ListTile(
                        leading: Text(
                          item.flag,
                          style: const TextStyle(fontSize: 22),
                        ),
                        title: Text(
                          item.name,
                          style: sheetContext.textTheme.titleSmall?.copyWith(
                            fontWeight: .w700,
                          ),
                        ),
                        trailing: Text(
                          item.dialCode,
                          style: sheetContext.textTheme.labelLarge?.copyWith(
                            fontWeight: .w800,
                            color: selected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                        onTap: () => Navigator.of(sheetContext).pop(item),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (next != null) onCountryChanged(next);
  }

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
          keyboardType: TextInputType.phone,
          validator: validator,
          autovalidateMode: .onUserInteraction,
          style: context.textTheme.titleSmall,
          decoration: InputDecoration(
            hintText: hint,
            errorMaxLines: 2,
            prefixIcon: InkWell(
              onTap: () => _pickCountry(context),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const .only(left: 12, right: 6),
                child: Row(
                  mainAxisSize: .min,
                  children: [
                    Text(country.flag, style: const TextStyle(fontSize: 18)),
                    4.w,
                    Text(
                      country.dialCode,
                      style: context.textTheme.labelLarge?.copyWith(
                        fontWeight: .w800,
                        color: AppColors.text,
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    6.w,
                    Container(width: 1, height: 22, color: AppColors.outline),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
