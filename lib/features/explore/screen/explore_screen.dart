import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/enums/app_loading.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/utils/venue_map_clustering.dart';
import '../../../core/utils/venue_navigation.dart';
import '../../../core/widgets/app_loading_handler.dart';
import '../../home/model/sport_game.dart';
import '../../home/model/venue.dart';
import '../../home/widgets/court_filter_sheet.dart';
import '../cubit/explore_cubit.dart';
import '../cubit/explore_state.dart';
import '../model/explore_models.dart';
import '../widgets/explore_header.dart';
import '../widgets/explore_map_panel.dart';
import '../widgets/explore_venue_tile.dart';
import '../widgets/explore_venue_tile_shimmer.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    final initialTab = context.read<ExploreCubit>().state.pageTab.index;
    _pageController = PageController(initialPage: initialTab);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _openSearch() async {
    AppHaptics.selection();
    await context.push(AppRoutes.search);
  }

  Future<void> _openFilter(ExploreCubit cubit) async {
    final next = await showCourtFilterSheet(
      context,
      initial: cubit.state.filter,
      sports: SportGame.defaults.where((sport) => !sport.isAll).toList(),
    );
    if (next == null || !mounted) return;
    cubit.applyFilter(next);
  }

  void _onPageTab(ExploreCubit cubit, ExplorePageTab tab) {
    if (tab == cubit.state.pageTab) return;
    cubit.setPageTab(tab);
    _goToPage(tab.index);
  }

  void _goToPage(int index) {
    void animate() {
      if (!mounted || !_pageController.hasClients) return;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
      );
    }

    if (_pageController.hasClients) {
      animate();
    } else {
      // PageView mounts after load success — sync once it's attached.
      WidgetsBinding.instance.addPostFrameCallback((_) => animate());
    }
  }

  void _openDetail(BuildContext context, Venue venue) {
    VenueNavigation.openDetail(context, venue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            BlocBuilder<ExploreCubit, ExploreState>(
              buildWhen: (p, c) =>
                  p.search != c.search ||
                  p.pageTab != c.pageTab ||
                  p.selectedSportId != c.selectedSportId,
              builder: (context, state) {
                final cubit = context.read<ExploreCubit>();
                return ExploreHeader(
                  search: state.search,
                  pageTab: state.pageTab,
                  selectedSportId: state.selectedSportId,
                  onSearchTap: _openSearch,
                  onFilterTap: () => _openFilter(cubit),
                  onPageTabChanged: (tab) => _onPageTab(cubit, tab),
                  onSportSelected: cubit.selectSport,
                  onClearSearch: state.search.hasLocation
                      ? cubit.clearPlace
                      : null,
                ).paddingSymmetric(
                  horizontal: AppSizes.pagePadding,
                  vertical: 10,
                );
              },
            ),
            Expanded(
              child: BlocBuilder<ExploreCubit, ExploreState>(
                buildWhen: (p, c) =>
                    p.status != c.status ||
                    p.errorMessage != c.errorMessage ||
                    p.venues != c.venues ||
                    p.mapVenues != c.mapVenues ||
                    p.search != c.search ||
                    p.selectedSportId != c.selectedSportId ||
                    p.filter != c.filter ||
                    p.pageTab != c.pageTab ||
                    p.showBackToOrigin != c.showBackToOrigin ||
                    p.cameraFitNonce != c.cameraFitNonce,
                builder: (context, state) {
                  final cubit = context.read<ExploreCubit>();
                  final venues = state.visibleVenues;

                  // Keep PageView mounted so PageController stays attached
                  // (Venues/Map taps during load must not crash).
                  return PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      cubit.setPageTab(ExplorePageTab.values[index]);
                    },
                    children: [
                      AppLoadingHandler(
                        status: state.status,
                        errorMessage: state.errorMessage,
                        onRetry: cubit.load,
                        loading: const ExploreVenueTileShimmerList()
                            .paddingSymmetric(horizontal: AppSizes.pagePadding),
                        child: _VenuesList(
                          venues: venues,
                          onTap: (venue) => _openDetail(context, venue),
                        ),
                      ),
                      // Mount map only on Map tab — avoids tile/marker load on Venues.
                      _LazyMapPage(
                        active: state.pageTab == .map,
                        status: state.status,
                        venues: state.visibleMapVenues,
                        focus: state.originFocus,
                        viewport: state.mapViewport,
                        cameraFitNonce: state.cameraFitNonce,
                        showBackToOrigin: state.showBackToOrigin,
                        backToOriginLabel: state.backToOriginLabel,
                        onViewportChanged: cubit.onMapViewport,
                        onBackToOrigin: cubit.returnToOrigin,
                        onVenueTap: (venue) => _openDetail(context, venue),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Disposes the heavy map when user leaves Map tab (tiles + markers freed).
class _LazyMapPage extends StatelessWidget {
  const _LazyMapPage({
    required this.active,
    required this.status,
    required this.venues,
    required this.focus,
    required this.viewport,
    required this.cameraFitNonce,
    required this.showBackToOrigin,
    required this.backToOriginLabel,
    required this.onViewportChanged,
    required this.onBackToOrigin,
    required this.onVenueTap,
  });

  final bool active;
  final AppLoading status;
  final List<Venue> venues;
  final LatLng? focus;
  final MapViewport? viewport;
  final int cameraFitNonce;
  final bool showBackToOrigin;
  final String backToOriginLabel;
  final ValueChanged<MapViewport> onViewportChanged;
  final VoidCallback onBackToOrigin;
  final ValueChanged<Venue> onVenueTap;

  @override
  Widget build(BuildContext context) {
    if (!active) {
      return const ColoredBox(color: AppColors.background);
    }

    if (status == .loading || status == .initial) {
      return const ColoredBox(
        color: AppColors.background,
        child: Center(child: Text('Loading venues…')),
      );
    }

    if (status == .error) {
      return const ColoredBox(
        color: AppColors.background,
        child: Center(child: Text('Couldn’t load venues')),
      );
    }

    final mapped = [
      for (final v in venues)
        if (v.hasCoordinates) v,
    ];

    return ExploreMapPanel(
      venues: mapped,
      focus: focus,
      initialCenter: viewport == null
          ? null
          : LatLng(viewport!.centerLat, viewport!.centerLng),
      initialZoom: viewport?.zoom,
      cameraFitNonce: cameraFitNonce,
      onViewportChanged: onViewportChanged,
      showBackToOrigin: showBackToOrigin,
      backToOriginLabel: backToOriginLabel,
      onBackToOrigin: onBackToOrigin,
      onVenueTap: onVenueTap,
    );
  }
}

class _VenuesList extends StatelessWidget {
  const _VenuesList({required this.venues, required this.onTap});

  final List<Venue> venues;
  final ValueChanged<Venue> onTap;

  @override
  Widget build(BuildContext context) {
    if (venues.isEmpty) {
      return Column(
        mainAxisAlignment: .center,
        children: [
          const Icon(
            Icons.stadium_outlined,
            size: 48,
            color: AppColors.primary,
          ),
          12.h,
          Text(
            'No venues match',
            style: context.textTheme.titleMedium?.copyWith(fontWeight: .w800),
          ),
          6.h,
          Text(
            'Try another sport or clear filters.',
            style: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ).center();
    }

    return ListView.builder(
      padding: const .fromLTRB(
        AppSizes.pagePadding,
        4,
        AppSizes.pagePadding,
        110,
      ),
      itemCount: venues.length,
      itemExtent: 130, // 118 tile + 12 gap — enables list recycling
      itemBuilder: (context, index) {
        final venue = venues[index];
        return Padding(
          padding: const .only(bottom: 12),
          child: SizedBox(
            height: 118,
            child: RepaintBoundary(
              child: ExploreVenueTile(
                key: ValueKey(venue.id),
                venue: venue,
                onTap: () => onTap(venue),
              ),
            ),
          ),
        );
      },
    );
  }
}
