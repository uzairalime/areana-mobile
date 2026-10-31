import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/in_app_review_service.dart';
import '../../../core/services/locator.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/utils/money_format.dart';
import '../../../core/widgets/app_button.dart';
import '../cubit/booking_cubit.dart';
import '../cubit/booking_state.dart';

class BookingConfirmedScreen extends StatefulWidget {
  const BookingConfirmedScreen({super.key});

  @override
  State<BookingConfirmedScreen> createState() => _BookingConfirmedScreenState();
}

class _BookingConfirmedScreenState extends State<BookingConfirmedScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(getIt<InAppReviewService>().promptAfterBooking());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: BlocBuilder<BookingCubit, BookingState>(
        builder: (context, state) {
          final confirmation = state.confirmation;
          return Stack(
            children: [
              const Positioned(
                top: -40,
                right: -60,
                child: _GlowCircle(size: 220, opacity: 0.18),
              ),
              const Positioned(
                top: 80,
                right: 20,
                child: _GlowCircle(size: 120, opacity: 0.12),
              ),
              Column(
                children: [
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const .fromLTRB(24, 28, 24, 0),
                      child: Column(
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              shape: .circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accent.withValues(
                                    alpha: 0.18,
                                  ),
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: const SizedBox(
                              width: 68,
                              height: 68,
                              child: Icon(
                                Icons.check,
                                size: 34,
                                color: AppColors.text,
                              ),
                            ),
                          ),
                          10.h,
                          Text(
                            'Slot booked!',
                            textAlign: .center,
                            style: context.textTheme.headlineMedium?.copyWith(
                              color: AppColors.onPrimary,
                              fontSize: 28,
                              fontWeight: .w800,
                              letterSpacing: -0.6,
                            ),
                          ),
                          8.h,
                          Text(
                            confirmation?.payAtGround == true
                                ? 'Show your booking code at the front desk and pay when you arrive.'
                                : 'Your payment is confirmed. Show your booking code at the front desk.',
                            textAlign: .center,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: AppColors.onPrimary.withValues(
                                alpha: 0.82,
                              ),
                              fontSize: 14,
                              height: 1.45,
                            ),
                          ).paddingSymmetric(horizontal: 12),
                        ],
                      ),
                    ),
                  ),
                  24.h,
                  if (confirmation != null)
                    _TicketCard(state: state).paddingSymmetric(horizontal: 20),
                  const Spacer(),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const .fromLTRB(20, 20, 20, 24),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _GhostAction(
                                label: 'Add to calendar',
                                icon: Icons.event_outlined,
                                onPressed: () => AppHaptics.selection(),
                              ).expand(),
                              10.w,
                              _GhostAction(
                                label: 'Get directions',
                                icon: Icons.directions_outlined,
                                onPressed: () => AppHaptics.selection(),
                              ).expand(),
                            ],
                          ),
                          10.h,
                          AppButton(
                            label: 'Back to home',
                            showArrow: false,
                            backgroundColor: AppColors.accent,
                            foregroundColor: AppColors.onAccent,
                            onPressed: () {
                              AppHaptics.medium();
                              context.go(AppRoutes.home);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    ).annotatedRegion(.light);
  }
}

class _GhostAction extends StatelessWidget {
  const _GhostAction({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.onPrimary,
        minimumSize: const Size.fromHeight(52),
        side: BorderSide(
          color: AppColors.onPrimary.withValues(alpha: 0.4),
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
      ),
      child: Row(
        mainAxisAlignment: .center,
        children: [
          Icon(icon, size: 18, color: AppColors.onPrimary),
          8.w,
          Flexible(
            child: Text(
              label,
              overflow: .ellipsis,
              style: context.textTheme.labelLarge?.copyWith(
                color: AppColors.onPrimary,
                fontWeight: .w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: opacity),
        shape: .circle,
      ),
      child: SizedBox(width: size, height: size),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.state});

  final BookingState state;

  @override
  Widget build(BuildContext context) {
    final confirmation = state.confirmation!;
    return Stack(
      clipBehavior: .none,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 40,
                offset: Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const .fromLTRB(20, 20, 20, 18),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: .start,
                      children: [
                        Column(
                          crossAxisAlignment: .start,
                          children: [
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: AppColors.padelSoft,
                                borderRadius: BorderRadius.circular(
                                  AppSizes.radiusPill,
                                ),
                              ),
                              child: Text(
                                confirmation.sport,
                                style: context.textTheme.labelMedium?.copyWith(
                                  color: AppColors.padel,
                                  fontWeight: .w800,
                                  fontSize: 11,
                                ),
                              ).paddingSymmetric(horizontal: 10, vertical: 5),
                            ),
                            8.h,
                            Text(
                              confirmation.venueName,
                              style: context.textTheme.titleMedium?.copyWith(
                                fontSize: 19,
                                fontWeight: .w800,
                              ),
                            ),
                            4.h,
                            Text(
                              confirmation.location,
                              style: context.textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ).expand(),
                        Column(
                          crossAxisAlignment: .end,
                          children: [
                            Text(
                              'Booking code',
                              style: context.textTheme.labelSmall?.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                            4.h,
                            Text(
                              confirmation.code,
                              style: context.textTheme.titleMedium?.copyWith(
                                fontSize: 20,
                                fontWeight: .w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    16.h,
                    Row(
                      children: [
                        _TicketMeta(
                          label: 'Date',
                          value: confirmation.dateLabel,
                        ).expand(),
                        _TicketMeta(
                          label: 'Time',
                          value: confirmation.timeLabel,
                        ).expand(),
                      ],
                    ),
                    12.h,
                    Row(
                      children: [
                        _TicketMeta(
                          label: 'Court',
                          value: confirmation.courtLabel,
                        ).expand(),
                        _TicketMeta(
                          label: 'Duration',
                          value: confirmation.durationLabel,
                        ).expand(),
                      ],
                    ),
                  ],
                ),
              ),
              Stack(
                alignment: .center,
                children: [
                  CustomPaint(
                    painter: const _TicketDashPainter(),
                    child: const SizedBox(height: 1, width: double.infinity),
                  ),
                ],
              ),
              Padding(
                padding: const .fromLTRB(20, 16, 20, 20),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: .start,
                      children: [
                        Text(
                          confirmation.payAtGround
                              ? 'Amount due at ground'
                              : 'Amount paid',
                          style: context.textTheme.labelMedium?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        4.h,
                        Text(
                          MoneyFormat.pkr(confirmation.amountDue),
                          style: context.textTheme.headlineSmall?.copyWith(
                            fontSize: 24,
                            fontWeight: .w800,
                          ),
                        ),
                      ],
                    ).expand(),
                    if (confirmation.payAtGround)
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.accentSoft,
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusPill,
                          ),
                        ),
                        child: Text(
                          'Pay at ground',
                          style: context.textTheme.labelMedium?.copyWith(
                            color: AppColors.payBadgeText,
                            fontWeight: .w800,
                            fontSize: 12,
                          ),
                        ).paddingSymmetric(horizontal: 10, vertical: 6),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Positioned(
          left: -12,
          top: 0,
          bottom: 0,
          child: Center(child: _Notch()),
        ),
        const Positioned(
          right: -12,
          top: 0,
          bottom: 0,
          child: Center(child: _Notch()),
        ),
      ],
    );
  }
}

class _Notch extends StatelessWidget {
  const _Notch();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(color: AppColors.primary, shape: .circle),
      child: SizedBox(width: 24, height: 24),
    );
  }
}

class _TicketMeta extends StatelessWidget {
  const _TicketMeta({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
        4.h,
        Text(
          value,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: .w800,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

class _TicketDashPainter extends CustomPainter {
  const _TicketDashPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    const dash = 6.0;
    const gap = 4.0;
    var x = 16.0;
    while (x < size.width - 16) {
      canvas.drawLine(Offset(x, 0), Offset(x + dash, 0), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
