import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_icons.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/session_cubit.dart';
import '../../../core/services/session_state.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/widgets/app_form_listener.dart';
import '../cubit/booking_cubit.dart';
import '../cubit/booking_state.dart';
import '../widgets/booking_auth_sheet.dart';
import '../widgets/booking_sticky_bar.dart';
import '../widgets/booking_summary_card.dart';
import '../widgets/checkout_sections.dart';

/// Confirm booking, user-web style: summary, account/guest, promo,
/// pay-at-venue only, price breakdown, confirm. Sections live in
/// `checkout_sections.dart` so this file stays under 500 lines.
class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<SessionCubit, SessionState>(
        builder: (context, session) {
          return BlocBuilder<BookingCubit, BookingState>(
            builder: (context, state) {
              final cubit = context.read<BookingCubit>();
              final isGuest = !session.isAuthenticated;
              return AppFormListener(
                status: state.confirmStatus,
                errorMessage: state.errorMessage,
                loadingTitle: 'Confirming',
                errorTitle: 'Booking failed',
                onSuccess: () => context.push(AppRoutes.bookingConfirmed),
                onErrorDismissed: cubit.clearConfirmError,
                child: Column(
                  children: [
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const .fromLTRB(20, 16, 20, 8),
                        child: Row(
                          children: [
                            Material(
                              color: AppColors.surface,
                              shape: const CircleBorder(
                                side: BorderSide(color: AppColors.outline),
                              ),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: () {
                                  AppHaptics.selection();
                                  context.pop();
                                },
                                child: const SizedBox(
                                  width: 44,
                                  height: 44,
                                  child: Icon(AppIcons.back, size: 18),
                                ),
                              ),
                            ),
                            12.w,
                            Text(
                              'Confirm booking',
                              style: context.textTheme.headlineSmall?.copyWith(
                                fontSize: 22,
                                fontWeight: .w800,
                                letterSpacing: -0.4,
                              ),
                            ).expand(),
                          ],
                        ),
                      ),
                    ),
                    ListView(
                      padding: const .fromLTRB(20, 8, 20, 24),
                      children: [
                        BookingSummaryCard(state: state),
                        AppSizes.spaceLg.h,
                        if (isGuest)
                          const CheckoutGuestCallout()
                        else if (session.user != null)
                          CheckoutAccountCard(user: session.user!),
                        AppSizes.spaceLg.h,
                        CheckoutPromoField(state: state),
                        AppSizes.spaceLg.h,
                        Text(
                          'How would you like to pay?',
                          style: context.textTheme.titleMedium?.copyWith(
                            fontSize: 17,
                            fontWeight: .w800,
                          ),
                        ),
                        12.h,
                        const CheckoutPayGroundCard(),
                        12.h,
                        DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.textDisabled,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Text(
                            'Please arrive 10 minutes before your slot so the desk can check you in.',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: AppColors.textBody,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ).paddingSymmetric(horizontal: 14, vertical: 12),
                        ),
                        AppSizes.spaceLg.h,
                        CheckoutPriceCard(state: state),
                      ],
                    ).expand(),
                    BookingStickyBar(
                      enabled: state.canContinue,
                      ctaLabel: 'Confirm booking',
                      trailingIcon: Icons.check,
                      onPressed: () => _onConfirm(
                        context,
                        isGuest: isGuest,
                        state: state,
                        cubit: cubit,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    ).annotatedRegion(.dark);
  }

  Future<void> _onConfirm(
    BuildContext context, {
    required bool isGuest,
    required BookingState state,
    required BookingCubit cubit,
  }) async {
    if (isGuest) {
      await showBookingAuthSheet(
        context,
        title: 'Log in to confirm your booking',
        body:
            'Create a free account or log in to lock this slot. Nothing is paid until you arrive.',
        dismissLabel: 'Back to booking',
        summaryTitle:
            '${state.selectedCourt?.name ?? 'Court'} · ${state.venue?.sport ?? ''}',
        summaryMeta: state.summaryLine,
        summaryAmount: state.total,
        onLogin: () => context.push('${AppRoutes.login}?next=checkout'),
        onSignup: () => context.push('${AppRoutes.signup}?next=checkout'),
      );
      return;
    }
    await cubit.confirmBooking();
  }
}
