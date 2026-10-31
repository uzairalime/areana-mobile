import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_icons.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/locator.dart';
import '../../../core/utils/auth_navigation.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_form_listener.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../booking/cubit/booking_cubit.dart';
import '../../booking/widgets/booking_summary_card.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/social_auth_buttons.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final next = AuthNavigation.nextOf(context);
    final bookingState = next == 'checkout'
        ? getIt<BookingCubit>().state
        : null;
    return Scaffold(
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final cubit = context.read<AuthCubit>();
          return AppFormListener(
            status: state.status,
            errorMessage: state.errorMessage,
            loadingTitle: state.loaderTitle.isEmpty ? 'Log in' : state.loaderTitle,
            errorTitle: state.errorTitle.isEmpty
                ? 'Log in failed'
                : state.errorTitle,
            onSuccess: () => AuthNavigation.afterAuthSuccess(
              context,
              next: next,
            ),
            onErrorDismissed: cubit.clearError,
            child: Column(
              children: [
                AuthTopBar(onBack: () => context.pop()),
                Form(
                  key: cubit.formKey,
                  child: ListView(
                    padding: const .fromLTRB(24, 12, 24, 24),
                    children: [
                      Text(
                        'Welcome back',
                        style: context.textTheme.headlineLarge,
                      ),
                      8.h,
                      Text(
                        next == 'checkout'
                            ? 'Log in to confirm your booking.'
                            : 'Log in to book your next slot.',
                        style: context.textTheme.titleSmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: .w500,
                          height: 1.45,
                        ),
                      ),
                      if (bookingState != null &&
                          bookingState.selectedCourt != null) ...[
                        AppSizes.spaceMd.h,
                        BookingReminderCard(state: bookingState),
                      ],
                      AppSizes.spaceMd.h,
                      AppTextField(
                        label: 'Email or phone number',
                        controller: cubit.identifierController,
                        icon: Icons.mail_outline,
                        hint: 'you@example.com',
                        keyboardType: .emailAddress,
                        onChanged: (_) => cubit.clearError(),
                        validator: AppValidators.emailOrPhone,
                      ),
                      AppSizes.spaceMd.h,
                      AppTextField(
                        label: 'Password',
                        controller: cubit.passwordController,
                        icon: Icons.lock_outline,
                        hint: 'Enter your password',
                        obscureText: state.obscurePassword,
                        onToggleObscure: cubit.togglePassword,
                        onChanged: (_) => cubit.clearError(),
                        validator: (value) => AppValidators.requiredField(
                          value,
                          message: 'Enter your password',
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push(AppRoutes.forgotPassword),
                        child: const Text('Forgot password?'),
                      ).align(alignment: .centerRight),
                      AppButton(
                        label: 'Log in',
                        showArrow: false,
                        onPressed: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          cubit.login();
                        },
                      ),
                      AppSizes.spaceMd.h,
                      const AuthOrDivider(),
                      AppSizes.spaceMd.h,
                      const SocialAuthButtons(),
                      AppSizes.spaceMd.h,
                      if (next == 'checkout')
                        AppButton.outlined(
                          label: 'Back to booking',
                          icon: AppIcons.back,
                          onPressed: () => context.pop(),
                        )
                      else
                        GuestContinueButton(
                          onPressed: () => context.go(AppRoutes.home),
                        ),
                      AppSizes.spaceLg.h,
                      Row(
                        mainAxisAlignment: .center,
                        children: [
                          Text(
                            'New here?',
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textBody,
                              fontWeight: .w500,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.push(
                              next == null
                                  ? AppRoutes.signup
                                  : '${AppRoutes.signup}?next=$next',
                            ),
                            child: const Text('Create account'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).expand(),
              ],
            ),
          );
        },
      ).safeArea(),
    ).annotatedRegion(.dark);
  }
}
