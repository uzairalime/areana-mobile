import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_icons.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/media_slider/cache_image.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/utils/money_format.dart';
import '../../../core/utils/venue_navigation.dart';
import '../../../core/widgets/venue_map_view.dart';
import '../../booking/widgets/court_hero_canvas.dart';
import '../cubit/bookings_cubit.dart';
import '../cubit/bookings_state.dart';
import '../model/user_booking.dart';
import '../widgets/booking_cancel_dialog.dart';
import '../widgets/booking_reschedule_sheet.dart';
import '../widgets/booking_status_chip.dart';

class BookingDetailScreen extends StatelessWidget {
  const BookingDetailScreen({super.key, required this.booking});

  final UserBooking booking;

  static UserBooking? resolve(GoRouterState state) {
    final extra = state.extra;
    if (extra is UserBooking) return extra;
    // Deep links without a passed booking are not yet detail-driven:
    // the list screen always passes the booking as extra.
    return null;
  }

  Future<void> _update(BuildContext context, UserBooking booking) async {
    AppHaptics.medium();
    VenueNavigation.openBookSlot(
      context,
      booking.toVenue(),
      preselectedCourtId: booking.courtId.isEmpty ? null : booking.courtId,
    );
  }

  Future<void> _reschedule(BuildContext context, UserBooking booking) async {
    final result = await showBookingRescheduleSheet(context, booking: booking);
    if (result == null || !context.mounted) return;
    final ok = await context.read<BookingsCubit>().requestReschedule(
      bookingId: booking.id,
      date: result.date,
      startMinutes: result.startMinutes,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Reschedule request sent to ${booking.venueName}'
              : 'Could not send reschedule request',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _cancel(BuildContext context, UserBooking booking) async {
    final confirmed = await showBookingCancelDialog(
      context,
      booking: booking,
    );
    if (!confirmed || !context.mounted) return;

    final ok = await context.read<BookingsCubit>().cancelBooking(booking.id);
    if (!context.mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${booking.code} cancelled'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(AppRoutes.bookings);
      }
      return;
    }

    final message = context.read<BookingsCubit>().state.errorMessage;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message.isEmpty ? 'Could not cancel booking' : message,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingsCubit, BookingsState>(
      buildWhen: (p, c) =>
          p.bookings != c.bookings ||
          p.managingBookingId != c.managingBookingId,
      builder: (context, state) {
        final live = state.bookingById(booking.id) ?? booking;
        final venue = live.toVenue();
        final managing = state.isManaging(live.id);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _Hero(booking: live)),
                    SliverPadding(
                      padding: const .fromLTRB(20, 18, 20, 28),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          Row(
                            children: [
                              Text(
                                live.code,
                                style: context.textTheme.titleSmall?.copyWith(
                                  fontWeight: .w800,
                                  color: AppColors.textSecondary,
                                ),
                              ).expand(),
                              BookingStatusChip(status: live.status),
                            ],
                          ),
                          10.h,
                          Text(
                            live.venueName,
                            style: context.textTheme.headlineMedium?.copyWith(
                              fontSize: 26,
                              fontWeight: .w800,
                              height: 1.15,
                              letterSpacing: -0.4,
                            ),
                          ),
                          6.h,
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              4.w,
                              Text(
                                live.location,
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ).expand(),
                            ],
                          ),
                          AppSizes.spaceLg.h,
                          Text(
                            'Booking details',
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: .w800,
                            ),
                          ),
                          12.h,
                          _InfoCard(
                            rows: [
                              ('Sport', live.sport),
                              ('Date', live.dateLabel),
                              ('Time', live.timeLabel),
                              ('Court', live.courtLabel),
                              ('Duration', live.durationLabel),
                            ],
                          ),
                          AppSizes.spaceLg.h,
                          Text(
                            'Payment',
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: .w800,
                            ),
                          ),
                          12.h,
                          _InfoCard(
                            rows: [
                              ('Amount', MoneyFormat.pkr(live.amountDue)),
                              (
                                'Method',
                                live.payAtGround
                                    ? 'Pay at ground'
                                    : 'Paid online',
                              ),
                            ],
                          ),
                          if (venue.hasCoordinates) ...[
                            AppSizes.spaceLg.h,
                            VenueMapCard(
                              title: 'Location',
                              subtitle: live.location,
                              venues: [venue],
                              height: 200,
                            ),
                          ],
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
              _BottomBar(
                booking: live,
                managing: managing,
                onUpdate: () => _update(context, live),
                onReschedule: () => _reschedule(context, live),
                onCancel: () => _cancel(context, live),
                onBack: () {
                  AppHaptics.selection();
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(AppRoutes.bookings);
                  }
                },
              ),
            ],
          ),
        ).annotatedRegion(.dark);
      },
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.booking,
    required this.managing,
    required this.onUpdate,
    required this.onReschedule,
    required this.onCancel,
    required this.onBack,
  });

  final UserBooking booking;
  final bool managing;
  final VoidCallback onUpdate;
  final VoidCallback onReschedule;
  final VoidCallback onCancel;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const .fromLTRB(20, 8, 20, 16),
        child: booking.canModify
            ? Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: managing ? null : onReschedule,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(
                          AppSizes.buttonHeight,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusMd,
                          ),
                        ),
                      ),
                      child: Text(
                        'Reschedule',
                        style: context.textTheme.labelLarge?.copyWith(
                          fontWeight: .w800,
                        ),
                      ),
                    ),
                  ),
                  12.w,
                  Expanded(
                    child: OutlinedButton(
                      onPressed: managing ? null : onCancel,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(
                          AppSizes.buttonHeight,
                        ),
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusMd,
                          ),
                        ),
                      ),
                      child: managing
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              'Cancel',
                              style: context.textTheme.labelLarge?.copyWith(
                                color: AppColors.error,
                                fontWeight: .w800,
                              ),
                            ),
                    ),
                  ),
                  12.w,
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: managing ? null : onUpdate,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(
                          AppSizes.buttonHeight,
                        ),
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusMd,
                          ),
                        ),
                      ),
                      child: Text(
                        'Update slot',
                        style: context.textTheme.labelLarge?.copyWith(
                          color: AppColors.onPrimary,
                          fontWeight: .w800,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : SizedBox(
                width: double.infinity,
                height: AppSizes.buttonHeight,
                child: FilledButton(
                  onPressed: onBack,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                  ),
                  child: Text(
                    'Back to bookings',
                    style: context.textTheme.labelLarge?.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: .w800,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.booking});

  final UserBooking booking;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 240,
          width: double.infinity,
          child: booking.imageUrl.isNotEmpty
              ? CacheImage(
                  url: booking.imageUrl,
                  height: 240,
                  width: double.infinity,
                  memCacheWidth: 900,
                  errorWidget: CourtHeroCanvas(
                    color: booking.heroColor,
                    height: 240,
                    showGradient: true,
                  ),
                )
              : CourtHeroCanvas(
                  color: booking.heroColor,
                  height: 240,
                  showGradient: true,
                ),
        ),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const .all(16),
            child: Material(
              color: AppColors.surface.withValues(alpha: 0.94),
              shape: const CircleBorder(),
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
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.rows});

  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.outline),
      ),
      child: Padding(
        padding: const .all(14),
        child: Column(
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              Row(
                crossAxisAlignment: .start,
                children: [
                  SizedBox(
                    width: 92,
                    child: Text(
                      rows[i].$1,
                      style: context.textTheme.labelMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Text(
                    rows[i].$2,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: .w700,
                    ),
                  ).expand(),
                ],
              ),
              if (i < rows.length - 1) ...[
                10.h,
                const Divider(height: 1, color: AppColors.outline),
                10.h,
              ],
            ],
          ],
        ),
      ),
    );
  }
}
