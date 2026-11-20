import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/enums/app_loading.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/locator.dart';
import '../../../core/services/session_cubit.dart';
import '../../../core/services/session_state.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/utils/venue_navigation.dart';
import '../../profile/cubit/profile_cubit.dart';
import '../../profile/cubit/profile_state.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../../../core/widgets/pagination_loader.dart';
import '../model/sport_game.dart';
import '../model/venue.dart';
import 'court_filter_sheet.dart';
import 'home_near_me_section.dart';
import 'home_sticky_search.dart';
import 'sport_game_grid.dart';
import 'venue_card.dart';
import 'venue_card_shimmer.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  late final ProfileCubit _profileCubit;
  bool _hydrationScheduled = false;

  @override
  void initState() {
    super.initState();
    _profileCubit = getIt<ProfileCubit>();
    _scheduleSavedVenues();
  }

  void _scheduleSavedVenues() {
    if (_hydrationScheduled) return;
    _hydrationScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hydrationScheduled = false;
      if (mounted && !_profileCubit.isClosed) {
        _profileCubit.ensureSavedVenueIds();
        _profileCubit.ensureLoaded();
      }
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

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
    return BlocListener<SessionCubit, SessionState>(
      listenWhen: (previous, current) =>
          previous.user?.id != current.user?.id ||
          previous.isAuthenticated != current.isAuthenticated,
      listener: (context, state) => _scheduleSavedVenues(),
      child: BlocProvider.value(
        value: _profileCubit,
        child: BlocBuilder<HomeCubit, HomeState>(
          buildWhen: (previous, current) =>
              previous.status != current.status ||
              previous.venues != current.venues ||
              previous.hasMore != current.hasMore ||
              previous.isLoadingMore != current.isLoadingMore ||
              previous.errorMessage != current.errorMessage ||
              previous.sports != current.sports ||
              previous.selectedSportId != current.selectedSportId ||
              previous.filter != current.filter,
          builder: (context, state) {
            final cubit = context.read<HomeCubit>();

            return CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: HomeStickySearchDelegate(
                    onSearchTap: () {
                      AppHaptics.selection();
                      context.push(AppRoutes.search);
                    },
                    onFilter: () async {
                      final catalog = state.sports
                          .where((sport) => !sport.isAll)
                          .toList();
                      final next = await showCourtFilterSheet(
                        context,
                        initial: state.filter,
                        sports: catalog.isEmpty
                            ? SportGame.defaults
                                  .where((sport) => !sport.isAll)
                                  .toList()
                            : catalog,
                      );
                      if (next == null || !context.mounted) return;
                      await cubit.applyFilter(next);
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
                else ...[
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
                      itemCount: state.venues.length + (state.hasMore ? 1 : 0),
                      separatorBuilder: (_, _) => AppSizes.spaceMd.h,
                      itemBuilder: (context, index) {
                        if (index >= state.venues.length) {
                          return PaginationLoader(
                            pageKey: state.page,
                            enabled: !state.isLoadingMore,
                            errorMessage: state.errorMessage,
                            onLoadMore: cubit.loadMore,
                          );
                        }
                        final venue = state.venues[index];
                        return BlocBuilder<ProfileCubit, ProfileState>(
                          buildWhen: (p, c) =>
                              p.isVenueSaved(venue.id) !=
                              c.isVenueSaved(venue.id),
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
      ),
    );
  }
}
