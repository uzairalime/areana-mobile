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

class PaymentPreferenceScreen extends StatefulWidget {
  const PaymentPreferenceScreen({super.key});

  @override
  State<PaymentPreferenceScreen> createState() =>
      _PaymentPreferenceScreenState();
}

class _PaymentPreferenceScreenState extends State<PaymentPreferenceScreen> {
  late String _selected;

  static const _options = [
    (
      id: 'pay_at_ground',
      title: 'Pay at ground',
      sub: 'Pay when you arrive — no advance needed',
    ),
    (
      id: 'online',
      title: 'Pay online',
      sub: 'Card or wallet before you play',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selected =
        context.read<ProfileCubit>().state.user?.paymentPreference ??
        'pay_at_ground';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final cubit = context.read<ProfileCubit>();
        return AppFormListener(
          status: state.saveStatus,
          errorMessage: state.errorMessage,
          loadingTitle: 'Saving preference',
          errorTitle: 'Update failed',
          onSuccess: () {
            cubit.clearSaveStatus();
            if (context.canPop()) context.pop();
          },
          onErrorDismissed: cubit.clearSaveStatus,
          child: ProfileSubpageScaffold(
            title: 'Payment preference',
            body: ListView(
              padding: const .fromLTRB(20, 8, 20, 28),
              children: [
                Text(
                  'Choose how you usually pay. You can still change it on each booking.',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                16.h,
                for (final option in _options) ...[
                  Material(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    child: InkWell(
                      onTap: () => setState(() => _selected = option.id),
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                      child: Ink(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusLg,
                          ),
                          border: Border.all(
                            color: _selected == option.id
                                ? AppColors.primary
                                : AppColors.outline,
                            width: _selected == option.id ? 1.6 : 1,
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
                                      option.title,
                                      style: context.textTheme.titleSmall
                                          ?.copyWith(fontWeight: .w800),
                                    ),
                                    4.h,
                                    Text(
                                      option.sub,
                                      style: context.textTheme.bodySmall
                                          ?.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                _selected == option.id
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: _selected == option.id
                                    ? AppColors.primary
                                    : AppColors.textDisabled,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  10.h,
                ],
                AppSizes.spaceLg.h,
                AppButton(
                  label: 'Save',
                  showArrow: false,
                  onPressed: () => cubit.savePaymentPreference(_selected),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
