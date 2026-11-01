import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/utils/venue_navigation.dart';
import '../../../core/widgets/app_custom_app_bar.dart';
import '../../../core/widgets/app_loading_handler.dart';
import '../../../core/widgets/guest_gate.dart';
import '../../../core/widgets/labels_builder.dart';
import '../cubit/bookings_cubit.dart';
import '../cubit/bookings_state.dart';
import '../model/booking_filter_tab.dart';
import '../model/user_booking.dart';
import '../widgets/booking_list_shimmer.dart';
import '../widgets/booking_review_sheet.dart';
import '../widgets/past_booking_tile.dart';
import '../widgets/upcoming_featured_card.dart';
import '../widgets/upcoming_timeline_tile.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  void _onAvatarTap(BuildContext context) {
    context.go(AppRoutes.account);
  }

  void _onMessages(BuildContext context) {
    AppHaptics.selection();
    context.go(AppRoutes.messages);
  }

  void _onNotifications(BuildContext context) {
    AppHaptics.selection();
    context.push(AppRoutes.notifications);
  }

  void _openBooking(BuildContext context, UserBooking booking) {
    AppHaptics.selection();
    context.push('${AppRoutes.bookingDetail}/${booking.id}', extra: booking);
  }

  void _rebook(BuildContext context, UserBooking booking) {
    VenueNavigation.openBookSlot(
      context,
      booking.toVenue(),
      preselectedCourtId: booking.courtId.isEmpty ? null : booking.courtId,
    );
  }

  Future<void> _addReview(BuildContext context, UserBooking booking) async {
    final result = await showBookingReviewSheet(context, booking: booking);
    if (result == null || !context.mounted) return;

    final ok = await context.read<BookingsCubit>().submitReview(
      bookingId: booking.id,
      rating: result.rating,
      comment: result.comment,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Thanks — your review for ${booking.venueName} is saved'
              : 'Could not save review',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GuestGate(
      title: 'Account required',
      message:
          'Create an account to save court bookings, get slot reminders, and manage your schedule in one place.',
      child: _BookingsTabDeepLinkListener(
        child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppCustomAppBar(
          onAvatarTap: () => _onAvatarTap(context),
          onMessages: () => _onMessages(context),
          onNotifications: () => _onNotifications(context),
        ),
        body: BlocBuilder<BookingsCubit, BookingsState>(
          buildWhen: (p, c) =>
              p.status != c.status ||
              p.errorMessage != c.errorMessage ||
              p.tab != c.tab ||
              p.bookings != c.bookings ||
              p.reviewSubmittingId != c.reviewSubmittingId,
          builder: (context, state) {
            final cubit = context.read<BookingsCubit>();
            return Column(
              crossAxisAlignment: .start,
              children: [
                BuildLabels<BookingFilterTab>(
                  expanded: true,
                  padding: const .symmetric(horizontal: AppSizes.pagePadding),
                  labels: BookingFilterTab.values,
                  label: state.tab,
                  textOf: (value) => value.label,
                  itemHorizontalPadding: 12,
                  onChange: cubit.setTab,
                ),
                8.h,
                Expanded(
                  child: AppLoadingHandler(
                    status: state.status,
                    errorMessage: state.errorMessage,
                    onRetry: cubit.load,
                    loading: BookingListShimmer(tab: state.tab),
                    child: _BookingsBody(
                      state: state,
                      onRefresh: cubit.refresh,
                      onOpen: (b) => _openBooking(context, b),
                      onRebook: (b) => _rebook(context, b),
                      onAddReview: (b) => _addReview(context, b),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      ),
    );
  }
}

/// Applies `/bookings?tab=` from deep links / `go` without fighting manual taps.
class _BookingsTabDeepLinkListener extends StatefulWidget {
  const _BookingsTabDeepLinkListener({required this.child});

  final Widget child;

  @override
  State<_BookingsTabDeepLinkListener> createState() =>
      _BookingsTabDeepLinkListenerState();
}

class _BookingsTabDeepLinkListenerState
    extends State<_BookingsTabDeepLinkListener> {
  String? _appliedQuery;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final raw = GoRouterState.of(context).uri.queryParameters['tab'];
    if (raw == _appliedQuery) return;
    final tab = BookingFilterTab.values.asNameMap()[raw];
    if (tab == null) {
      _appliedQuery = raw;
      return;
    }
    _appliedQuery = raw;
    final cubit = context.read<BookingsCubit>();
    if (cubit.state.tab == tab) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      cubit.setTab(tab);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _BookingsBody extends StatelessWidget {
  const _BookingsBody({
    required this.state,
    required this.onRefresh,
    required this.onOpen,
    required this.onRebook,
    required this.onAddReview,
  });

  final BookingsState state;
  final Future<void> Function() onRefresh;
  final ValueChanged<UserBooking> onOpen;
  final ValueChanged<UserBooking> onRebook;
  final ValueChanged<UserBooking> onAddReview;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      onRefresh: onRefresh,
      child: state.isEmptyForTab
          ? _BookingsEmpty(tab: state.tab)
          : switch (state.tab) {
              .upcoming => _UpcomingList(
                featured: state.featuredUpcoming!,
                alsoComingUp: state.alsoComingUp,
                onOpen: onOpen,
              ),
              .past => _PastList(
                groups: state.pastByYear,
                onOpen: onOpen,
                onRebook: onRebook,
                onAddReview: onAddReview,
              ),
              .reviews => _ReviewsList(
                bookings: state.reviewBookings,
                onOpen: onOpen,
                onRebook: onRebook,
                onAddReview: onAddReview,
              ),
            },
    );
  }
}

class _UpcomingList extends StatelessWidget {
  const _UpcomingList({
    required this.featured,
    required this.alsoComingUp,
    required this.onOpen,
  });

  final UserBooking featured;
  final List<UserBooking> alsoComingUp;
  final ValueChanged<UserBooking> onOpen;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const .fromLTRB(
        AppSizes.pagePadding,
        4,
        AppSizes.pagePadding,
        110,
      ),
      children: [
        UpcomingFeaturedCard(
          booking: featured,
          onTap: () => onOpen(featured),
        ),
        if (alsoComingUp.isNotEmpty) ...[
          22.h,
          Text(
            'ALSO COMING UP',
            style: context.textTheme.labelLarge?.copyWith(
              fontSize: 12,
              fontWeight: .w700,
              letterSpacing: 0.6,
              color: AppColors.textSecondary,
            ),
          ),
          12.h,
          for (var i = 0; i < alsoComingUp.length; i++)
            UpcomingTimelineTile(
              key: ValueKey(alsoComingUp[i].id),
              booking: alsoComingUp[i],
              isLast: i == alsoComingUp.length - 1,
              onTap: () => onOpen(alsoComingUp[i]),
            ),
        ],
      ],
    );
  }
}

class _PastList extends StatelessWidget {
  const _PastList({
    required this.groups,
    required this.onOpen,
    required this.onRebook,
    required this.onAddReview,
  });

  final List<PastBookingYearGroup> groups;
  final ValueChanged<UserBooking> onOpen;
  final ValueChanged<UserBooking> onRebook;
  final ValueChanged<UserBooking> onAddReview;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const .fromLTRB(
        AppSizes.pagePadding,
        4,
        AppSizes.pagePadding,
        110,
      ),
      itemCount: groups.length,
      itemBuilder: (context, groupIndex) {
        final group = groups[groupIndex];
        return Column(
          crossAxisAlignment: .start,
          children: [
            if (groupIndex > 0) 8.h,
            Row(
              children: [
                Text(
                  '${group.year}',
                  style: context.textTheme.labelLarge?.copyWith(
                    fontSize: 13,
                    fontWeight: .w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                10.w,
                const Expanded(child: Divider(color: AppColors.outline)),
              ],
            ),
            12.h,
            for (var i = 0; i < group.bookings.length; i++) ...[
              PastBookingTile(
                key: ValueKey(group.bookings[i].id),
                booking: group.bookings[i],
                onTap: () => onOpen(group.bookings[i]),
                onRebook: () => onRebook(group.bookings[i]),
                onAddReview: group.bookings[i].canAddReview
                    ? () => onAddReview(group.bookings[i])
                    : null,
              ),
              if (i < group.bookings.length - 1) 12.h,
            ],
            16.h,
          ],
        );
      },
    );
  }
}

class _ReviewsList extends StatelessWidget {
  const _ReviewsList({
    required this.bookings,
    required this.onOpen,
    required this.onRebook,
    required this.onAddReview,
  });

  final List<UserBooking> bookings;
  final ValueChanged<UserBooking> onOpen;
  final ValueChanged<UserBooking> onRebook;
  final ValueChanged<UserBooking> onAddReview;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const .fromLTRB(
        AppSizes.pagePadding,
        4,
        AppSizes.pagePadding,
        110,
      ),
      itemCount: bookings.length,
      separatorBuilder: (_, _) => 12.h,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return PastBookingTile(
          key: ValueKey(booking.id),
          booking: booking,
          onTap: () => onOpen(booking),
          onRebook: () => onRebook(booking),
          onAddReview: booking.canAddReview
              ? () => onAddReview(booking)
              : null,
        );
      },
    );
  }
}

class _BookingsEmpty extends StatelessWidget {
  const _BookingsEmpty({required this.tab});

  final BookingFilterTab tab;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: context.screenSize.height * 0.18),
        Icon(tab.emptyIcon, size: 48, color: AppColors.primary).center(),
        16.h,
        Text(
          tab.emptyTitle,
          textAlign: .center,
          style: context.textTheme.headlineMedium?.copyWith(fontSize: 20),
        ),
        8.h,
        Text(
          tab.emptyBody,
          textAlign: .center,
          style: context.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ).paddingSymmetric(horizontal: 40),
        22.h,
        if (tab == .upcoming)
          TextButton(
            onPressed: () {
              AppHaptics.light();
              context.go(AppRoutes.home);
            },
            child: Text(
              'Find a court',
              style: context.textTheme.labelLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: .w800,
              ),
            ),
          ),
      ],
    );
  }
}
