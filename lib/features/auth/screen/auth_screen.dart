import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/enums/app_loading.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/session_cubit.dart';
import '../../../core/services/session_state.dart';
import '../../../core/utils/auth_navigation.dart';
import '../../../core/widgets/app_form_listener.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/auth_already_signed_in.dart';
import '../widgets/auth_done_step.dart';
import '../widgets/auth_email_step.dart';
import '../widgets/auth_signup_step.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/otp_verify_panel.dart';

/// Areana player auth, same flow as user-web `/auth`:
/// email → code → signup (new accounts only) → done / home.
/// All text fields are the custom [AppTextField]; the code field is
/// the custom [AppOtpField]. No password, no social, no forgot flow.
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final next = AuthNavigation.nextOf(context);
    return Scaffold(
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final cubit = context.read<AuthCubit>();
          return AppFormListener(
            status: state.status,
            errorMessage: state.errorMessage,
            loadingTitle: state.loaderTitle.isEmpty
                ? 'Please wait'
                : state.loaderTitle,
            errorTitle: state.errorTitle.isEmpty
                ? 'Something went wrong'
                : state.errorTitle,
            onSuccess: () => AuthNavigation.afterAuthSuccess(
              context,
              next: next,
            ),
            onErrorDismissed: cubit.clearError,
            child: Column(
              children: [
                AuthTopBar(
                  onBack: () {
                    if (state.step == AuthStep.email) {
                      context.pop();
                      return;
                    }
                    cubit.backStep();
                  },
                ),
                if (state.noticeMessage.isNotEmpty)
                  Container(
                    margin: const .fromLTRB(24, 0, 24, 12),
                    padding: const .symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    child: Text(
                      state.noticeMessage,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: .w600,
                      ),
                    ),
                  ),
                BlocBuilder<SessionCubit, SessionState>(
                  builder: (context, sessionState) {
                    if (sessionState.isAuthenticated &&
                        state.step != AuthStep.done &&
                        !state.status.isSuccess) {
                      return AuthAlreadySignedIn(
                        email: sessionState.user?.email ?? '',
                        onContinue: () => AuthNavigation.afterAuthSuccess(
                          context,
                          next: next,
                        ),
                      ).expand();
                    }
                    return switch (state.step) {
                      AuthStep.email => AuthEmailStep(
                        onGuestContinue: () => context.go(AppRoutes.home),
                      ).expand(),
                      AuthStep.code => OtpVerifyPanel(
                        email: cubit.emailController.text.trim(),
                        onVerify: cubit.verifyCode,
                        onResend: cubit.resendOtp,
                      ).expand(),
                      AuthStep.signup => const AuthSignupStep().expand(),
                      AuthStep.done => AuthDoneStep(
                        onContinue: () => AuthNavigation.afterAuthSuccess(
                          context,
                          next: next,
                        ),
                      ).expand(),
                    };
                  },
                ).expand(),
              ],
            ),
          );
        },
      ).safeArea(),
    ).annotatedRegion(.dark);
  }
}
