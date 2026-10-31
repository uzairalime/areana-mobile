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
import '../../../core/utils/money_format.dart';
import '../../../core/widgets/app_form_listener.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../../auth/model/user_model.dart';
import '../cubit/booking_cubit.dart';
import '../cubit/booking_state.dart';
import '../widgets/booking_auth_sheet.dart';
import '../widgets/booking_sticky_bar.dart';
import '../widgets/booking_summary_card.dart';

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
          final dueLabel = state.payMethod == PayMethod.ground
              ? 'Due at ground'
              : 'Pay now';
          final ctaLabel = state.payMethod == PayMethod.ground
              ? 'Confirm booking'
              : 'Pay ${MoneyFormat.pkr(state.total)} and confirm';
          final trailing = state.payMethod == PayMethod.ground
              ? Icons.check
              : Icons.arrow_forward;

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
                      const _GuestCallout()
                    else if (session.user != null)
                      _AccountCard(user: session.user!),
                    AppSizes.spaceLg.h,
                    Text(
                      'How would you like to pay?',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontSize: 17,
                        fontWeight: .w800,
                      ),
                    ),
                    12.h,
                    _PayMethodCard(
                      selected: state.payMethod == PayMethod.ground,
                      icon: Icons.storefront_outlined,
                      title: 'Pay at ground',
                      body:
                          'Pay by cash or card at the front desk when you arrive.',
                      chipLabel: 'No advance payment',
                      onTap: () => cubit.selectPayMethod(PayMethod.ground),
                    ),
                    12.h,
                    _PayMethodCard(
                      selected: state.payMethod == PayMethod.online,
                      icon: Icons.credit_card_outlined,
                      title: 'Pay online',
                      body: 'Card or mobile wallet. Confirmed instantly.',
                      onTap: () => cubit.selectPayMethod(PayMethod.online),
                    ),
                    if (state.payMethod == PayMethod.ground) ...[
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
                    ],
                    AppSizes.spaceLg.h,
                    _PriceCard(
                      duration: state.selectedDuration ?? '60 min',
                      total: state.total,
                      dueLabel: dueLabel,
                    ),
                  ],
                ).expand(),
                BookingStickyBar(
                  enabled: state.canContinue,
                  ctaLabel: ctaLabel,
                  trailingIcon: trailing,
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

class _GuestCallout extends StatelessWidget {
  const _GuestCallout();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        crossAxisAlignment: .start,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(Icons.person_outline, color: AppColors.primary),
            ),
          ),
          12.w,
          Column(
            crossAxisAlignment: .start,
            children: [
              Text(
                'Booking as a guest',
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: .w800,
                  fontSize: 15,
                ),
              ),
              4.h,
              Text(
                'You will log in or create an account when you confirm. Your court, date and time stay saved.',
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ).expand(),
        ],
      ).paddingAll(14),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final name = user.name.isEmpty ? 'Player' : user.name;
    final phone = user.phone.isNotEmpty ? user.phone : user.email;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          ProfileAvatar(
            username: name,
            url: user.avatarUrl,
            size: 44,
          ),
          12.w,
          Column(
            crossAxisAlignment: .start,
            children: [
              Text(
                name,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: .w800,
                  fontSize: 15,
                ),
              ),
              2.h,
              Text(
                phone,
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ).expand(),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            ),
            child: Row(
              mainAxisSize: .min,
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 14,
                  color: AppColors.payBadgeText,
                ),
                4.w,
                Text(
                  'Logged in',
                  style: context.textTheme.labelMedium?.copyWith(
                    color: AppColors.payBadgeText,
                    fontWeight: .w800,
                    fontSize: 12,
                  ),
                ),
              ],
            ).paddingSymmetric(horizontal: 10, vertical: 6),
          ),
        ],
      ).paddingAll(14),
    );
  }

}

class _PayMethodCard extends StatelessWidget {
  const _PayMethodCard({
    required this.selected,
    required this.icon,
    required this.title,
    required this.body,
    required this.onTap,
    this.chipLabel,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String body;
  final VoidCallback onTap;
  final String? chipLabel;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.selectedSoft : AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const .all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.outline,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: .start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(
                    icon,
                    color: selected ? AppColors.accent : AppColors.primary,
                  ),
                ),
              ),
              12.w,
              Column(
                crossAxisAlignment: .start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: .w800,
                          fontSize: 15,
                        ),
                      ).expand(),
                      if (chipLabel != null)
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.accent
                                : AppColors.accentSoft,
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusPill,
                            ),
                          ),
                          child: Text(
                            chipLabel!,
                            style: context.textTheme.labelSmall?.copyWith(
                              color: AppColors.payBadgeText,
                              fontWeight: .w800,
                              fontSize: 11,
                            ),
                          ).paddingSymmetric(horizontal: 8, vertical: 4),
                        ),
                    ],
                  ),
                  6.h,
                  Text(
                    body,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: selected
                          ? AppColors.textBody
                          : AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ).expand(),
              8.w,
              DecoratedBox(
                decoration: BoxDecoration(
                  shape: .circle,
                  color: selected ? AppColors.primary : Colors.transparent,
                  border: Border.all(
                    color: selected
                        ? AppColors.primary
                        : const Color(0xFFB8C2BC),
                    width: 2,
                  ),
                ),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: selected
                      ? const Icon(
                          Icons.check,
                          size: 14,
                          color: AppColors.accent,
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  const _PriceCard({
    required this.duration,
    required this.total,
    required this.dueLabel,
  });

  final String duration;
  final int total;
  final String dueLabel;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        children: [
          _PriceRow(label: 'Court fee, $duration', value: MoneyFormat.pkr(total)),
          10.h,
          const _PriceRow(
            label: 'Booking fee',
            value: 'Free',
            valueColor: AppColors.freeFee,
          ),
          10.h,
          const Divider(height: 1, color: AppColors.outline),
          10.h,
          Row(
            children: [
              Text(
                dueLabel,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: .w800,
                  fontSize: 15,
                ),
              ).expand(),
              Text(
                MoneyFormat.pkr(total),
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: .w800,
                  fontSize: 22,
                ),
              ),
            ],
          ),
        ],
      ).paddingAll(16),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: context.textTheme.bodyMedium?.copyWith(fontSize: 14),
        ).expand(),
        Text(
          value,
          style: context.textTheme.labelLarge?.copyWith(
            color: valueColor ?? AppColors.text,
            fontWeight: .w700,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
