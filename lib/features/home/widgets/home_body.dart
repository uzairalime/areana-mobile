import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/enums/app_loading.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/locator.dart';
import '../../../core/services/session_cubit.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/utils/venue_navigation.dart';
import '../../profile/cubit/profile_cubit.dart';
import '../../profile/cubit/profile_state.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../model/venue.dart';
import 'court_card.dart';
import 'court_filter_sheet.dart';
import 'home_near_me_section.dart';
import 'home_sticky_search.dart';
import 'sport_game_grid.dart';
import 'venue_card.dart';
import 'venue_card_shimmer.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  Future<void> _onFavorite(BuildContext context, Venue venue) async {
    final session = context.read<SessionCubit>().state;
    if (!session.isAuthenticated) {
      context.push(AppRoutes.login);
      return;
    }
    await context.read<ProfileCubit>().toggleSavedVenue(venue.id);
  }

  @override
  Widget build(BuildContext context) {
    final profileCubit = getIt<ProfileCubit>()..ensureSavedVenueIds();

    return BlocProvider.value(
      value: profileCubit,
      child: BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.venues != current.venues ||
          previous.courts != current.courts ||
          previous.showingCourts != current.showingCourts ||
          previous.errorMessage != current.errorMessage ||
          previous.sports != current.sports ||
          previous.selectedSportId != current.selectedSportId ||
          previous.filter != current.filter,
      builder: (context, state) {
        final cubit = context.read<HomeCubit>();
        final now = DateTime.now();
        final dateLabel =
            '${_weekday(now.weekday)}, ${now.day} ${_month(now.month)}';

        return CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverPadding(
              padding: const .fromLTRB(
                AppSizes.pagePadding,
                12,
                AppSizes.pagePadding,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      dateLabel,
                      style: context.textTheme.titleSmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: .w600,
                        fontSize: 14,
                      ),
                    ),
                    8.h,
                    Text(
                      'Find a court.\nLock your slot.',
                      style: context.textTheme.headlineLarge?.copyWith(
                        fontSize: 30,
                        height: 1.12,
                        letterSpacing: -0.75,
                        fontWeight: .w800,
                        color: AppColors.text,
                      ),
                    ),
                    AppSizes.spaceSm.h,
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: HomeStickySearchDelegate(
                onSearchTap: () {
                  AppHaptics.selection();
                  context.push(AppRoutes.search);
                },
                onFilter: () async {
                  final next = await showCourtFilterSheet(
                    context,
                    initial: state.filter,
                  );
                  if (next == null || !context.mounted) return;
                  cubit.applyFilter(next);
                },
              ),
            ),
            SliverPadding(
              padding: const .fromLTRB(
                AppSizes.pagePadding,
                AppSizes.spaceSm,
                AppSizes.pagePadding,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: SportGameGrid(
                  sports: state.sports,
                  selectedId: state.selectedSportId,
                  onSelected: (sport) => cubit.selectSport(sport.id),
                ),
              ),
            ),
            // Discovery tabs, like user-web Venues | Courts.
            SliverPadding(
              padding: const .fromLTRB(
                AppSizes.pagePadding,
                AppSizes.spaceSm,
                AppSizes.pagePadding,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Arenas'),
                      selected: !state.showingCourts,
                      onSelected: (_) => cubit.setShowingCourts(false),
                    ),
                    8.w,
                    ChoiceChip(
                      label: const Text('Courts'),
                      selected: state.showingCourts,
                      onSelected: (_) => cubit.setShowingCourts(true),
                    ),
                  ],
                ),
              ),
            ),
            if (state.status.isLoading)
              const SliverPadding(
                padding: .fromLTRB(
                  AppSizes.pagePadding,
                  AppSizes.spaceLg,
                  AppSizes.pagePadding,
                  110,
                ),
                sliver: SliverToBoxAdapter(child: VenueCardShimmerList()),
              )
            else if (state.status.isError)
              SliverPadding(
                padding: const .fromLTRB(
                  AppSizes.pagePadding,
                  AppSizes.spaceLg,
                  AppSizes.pagePadding,
                  110,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Text(
                        state.errorMessage,
                        textAlign: .center,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                      12.h,
                      TextButton(
                        onPressed: cubit.load,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (state.showingCourts) ...[
              SliverPadding(
                padding: const .fromLTRB(
                  AppSizes.pagePadding,
                  AppSizes.spaceLg,
                  AppSizes.pagePadding,
                  110,
                ),
                sliver: SliverList.separated(
                  itemCount: state.courts.length,
                  separatorBuilder: (_, _) => AppSizes.spaceMd.h,
                  itemBuilder: (context, index) {
                    final item = state.courts[index];
                    return CourtCard(
                      item: item,
                      onOpen: () => context.push(
                        '${AppRoutes.courtDetail}/${item.court.id}',
                      ),
                      onBook: () => VenueNavigation.openBookSlot(
                        context,
                        item.toVenue(),
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              SliverPadding(
                padding: const .fromLTRB(
                  AppSizes.pagePadding,
                  AppSizes.spaceLg,
                  AppSizes.pagePadding,
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child: HomeNearMeSection(venues: state.venues),
                ),
              ),
              SliverPadding(
                padding: const .fromLTRB(
                  AppSizes.pagePadding,
                  AppSizes.spaceLg,
                  AppSizes.pagePadding,
                  10,
                ),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Popular venues',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: .w800,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const .fromLTRB(
                  AppSizes.pagePadding,
                  0,
                  AppSizes.pagePadding,
                  110,
                ),
                sliver: SliverList.separated(
                  itemCount: state.venues.length,
                  separatorBuilder: (_, _) => AppSizes.spaceMd.h,
                  itemBuilder: (context, index) {
                    final venue = state.venues[index];
                    return BlocBuilder<ProfileCubit, ProfileState>(
                      buildWhen: (p, c) =>
                          p.isVenueSaved(venue.id) != c.isVenueSaved(venue.id),
                      builder: (context, profile) {
                        return VenueCard(
                          venue: venue,
                          isFavorite: profile.isVenueSaved(venue.id),
                          onFavoriteTap: () => _onFavorite(context, venue),
                          onOpen: () =>
                              VenueNavigation.openDetail(context, venue),
                          onBook: () =>
                              VenueNavigation.openBookSlot(context, venue),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ],
        );
      },
    ),
    );
  }

  static String _weekday(int day) {
    const names = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return names[day - 1];
  }

  static String _month(int month) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return names[month - 1];
  }
}
