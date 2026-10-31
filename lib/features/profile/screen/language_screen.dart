import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_form_listener.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/profile_subpage_scaffold.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  late String _selected;

  static const _options = [
    (code: 'en', title: 'English', sub: 'Default'),
    (code: 'ur', title: 'اردو', sub: 'Urdu'),
  ];

  @override
  void initState() {
    super.initState();
    _selected =
        context.read<ProfileCubit>().state.user?.languageCode ?? 'en';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final cubit = context.read<ProfileCubit>();
        return AppFormListener(
          status: state.saveStatus,
          errorMessage: state.errorMessage,
          loadingTitle: 'Saving language',
          errorTitle: 'Update failed',
          onSuccess: () {
            cubit.clearSaveStatus();
            if (context.canPop()) context.pop();
          },
          onErrorDismissed: cubit.clearSaveStatus,
          child: ProfileSubpageScaffold(
            title: 'Language',
            body: ListView(
              padding: const .fromLTRB(20, 8, 20, 28),
              children: [
                for (final option in _options) ...[
                  _OptionTile(
                    title: option.title,
                    subtitle: option.sub,
                    selected: _selected == option.code,
                    onTap: () => setState(() => _selected = option.code),
                  ),
                  10.h,
                ],
                AppSizes.spaceLg.h,
                AppButton(
                  label: 'Save',
                  showArrow: false,
                  onPressed: () => cubit.saveLanguage(_selected),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.outline,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Padding(
            padding: const .all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text(
                        title,
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: .w800,
                        ),
                      ),
                      4.h,
                      Text(
                        subtitle,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: selected ? AppColors.primary : AppColors.textDisabled,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
