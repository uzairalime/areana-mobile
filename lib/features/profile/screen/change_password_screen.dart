import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_form_listener.dart';
import '../../../core/widgets/app_text_field.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/profile_subpage_scaffold.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final cubit = context.read<ProfileCubit>();
        return AppFormListener(
          status: state.saveStatus,
          errorMessage: state.errorMessage,
          loadingTitle: 'Updating password',
          errorTitle: 'Update failed',
          onSuccess: () {
            cubit.clearSaveStatus();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password updated'),
                behavior: SnackBarBehavior.floating,
              ),
            );
            if (context.canPop()) context.pop();
          },
          onErrorDismissed: cubit.clearSaveStatus,
          child: ProfileSubpageScaffold(
            title: 'Change password',
            body: Form(
              key: cubit.passwordFormKey,
              child: ListView(
                padding: const .fromLTRB(20, 8, 20, 28),
                children: [
                  AppTextField(
                    label: 'Current password',
                    controller: cubit.currentPasswordController,
                    icon: Icons.lock_outline,
                    hint: 'Enter current password',
                    obscureText: true,
                    validator: AppValidators.password,
                  ),
                  AppSizes.spaceMd.h,
                  AppTextField(
                    label: 'New password',
                    controller: cubit.newPasswordController,
                    icon: Icons.lock_outline,
                    hint: 'At least 8 characters',
                    obscureText: true,
                    validator: AppValidators.password,
                  ),
                  AppSizes.spaceMd.h,
                  AppTextField(
                    label: 'Confirm new password',
                    controller: cubit.confirmPasswordController,
                    icon: Icons.lock_outline,
                    hint: 'Re-enter new password',
                    obscureText: true,
                    validator: (value) => AppValidators.confirmPassword(
                      value,
                      cubit.newPasswordController.text,
                    ),
                  ),
                  14.h,
                  _Rule('At least 8 characters'),
                  _Rule('One number or symbol'),
                  _Rule('Different from your last password'),
                  AppSizes.spaceLg.h,
                  AppButton(
                    label: 'Update password',
                    showArrow: false,
                    onPressed: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      cubit.changePassword();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 16, color: AppColors.primary),
          8.w,
          Text(
            text,
            style: context.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: .w600,
            ),
          ),
        ],
      ),
    );
  }
}
