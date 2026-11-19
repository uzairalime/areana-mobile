import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_icons.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/enums/app_loading.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/locator.dart';
import '../../../core/services/location/location_cubit.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/widgets/app_shimmer.dart';
import '../../explore/cubit/explore_cubit.dart';
import '../cubit/search_cubit.dart';
import '../cubit/search_state.dart';
import '../model/search_models.dart';
import '../widgets/search_idle_body.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _focusNode = FocusNode();
  var _nearbyLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focusNode.requestFocus();
      context.read<LocationCubit>().checkPermission();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _openExplore(PlaceSuggestion place) async {
    AppHaptics.medium();
    await getIt<ExploreCubit>().applyArea(
      location: place.displayLabel,
      placeId: place.id,
      lat: place.lat,
      lng: place.lng,
    );
    if (!mounted) return;
    context.go(AppRoutes.explore);
  }

  Future<void> _pickPlace(PlaceSuggestion place) async {
    final resolved = await context.read<SearchCubit>().resolvePlace(place);
    if (!mounted || resolved == null || !resolved.hasCoordinates) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Couldn’t load that place. Try another search.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    await _openExplore(resolved);
  }

  Future<void> _pickRecent(RecentPlace recent) async {
    final resolved = await context.read<SearchCubit>().resolveRecent(recent);
    if (!mounted || resolved == null || !resolved.hasCoordinates) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Couldn’t open that search. Try it again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    await _openExplore(resolved);
  }

  Future<void> _pickNearby() async {
    if (_nearbyLoading) return;
    setState(() => _nearbyLoading = true);
    try {
      final location = context.read<LocationCubit>();
      await location.ensurePermission(fetchLocation: true);
      if (!mounted) return;
      if (!location.state.isGranted || !location.state.hasPosition) {
        final message = location.state.errorMessage.isEmpty
            ? 'Allow location access to find courts near you.'
            : location.state.errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            behavior: SnackBarBehavior.floating,
            action: location.state.isDeniedForever
                ? SnackBarAction(
                    label: 'Settings',
                    onPressed: location.openSettings,
                  )
                : null,
          ),
        );
        return;
      }
      final position = location.state.position!;
      final named = await context.read<SearchCubit>().reverseGeocode(
        lat: position.latitude,
        lng: position.longitude,
      );
      if (!mounted) return;
      final label = (named?.displayLabel.trim().isNotEmpty ?? false)
          ? named!.displayLabel
          : 'Current location';
      await _openExplore(
        PlaceSuggestion(
          id: named?.id.isNotEmpty == true ? named!.id : 'nearby',
          primaryText: label,
          label: label,
          lat: position.latitude,
          lng: position.longitude,
        ),
      );
    } finally {
      if (mounted) setState(() => _nearbyLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SearchCubit>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Padding(
              padding: const .fromLTRB(
                AppSizes.pagePadding,
                8,
                AppSizes.pagePadding,
                8,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      AppHaptics.selection();
                      context.pop();
                    },
                    icon: const Icon(AppIcons.back, size: 18),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: AppSizes.searchHeight,
                      child: TextField(
                        controller: cubit.queryController,
                        focusNode: _focusNode,
                        autofocus: true,
                        textInputAction: .search,
                        onChanged: cubit.onQueryChanged,
                        onSubmitted: (_) => cubit.submitCurrent(),
                        style: context.textTheme.titleSmall?.copyWith(
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search city, area or arena',
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          suffixIcon: BlocBuilder<SearchCubit, SearchState>(
                            buildWhen: (p, c) => p.query != c.query,
                            builder: (context, state) {
                              if (state.query.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return IconButton(
                                onPressed: () {
                                  cubit.queryController.clear();
                                  cubit.onQueryChanged('');
                                  _focusNode.requestFocus();
                                },
                                icon: const Icon(Icons.close_rounded, size: 18),
                              );
                            },
                          ),
                          filled: true,
                          fillColor: AppColors.surface,
                          contentPadding: const .symmetric(horizontal: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMd,
                            ),
                            borderSide: const BorderSide(
                              color: AppColors.outline,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMd,
                            ),
                            borderSide: const BorderSide(
                              color: AppColors.outline,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMd,
                            ),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) {
                  if (state.status == AppLoading.loading) {
                    return const _SearchShimmer();
                  }
                  if (state.status == AppLoading.error) {
                    return _MessageBody(
                      icon: Icons.error_outline_rounded,
                      title: 'Search failed',
                      body: state.errorMessage.isEmpty
                          ? 'Something went wrong'
                          : state.errorMessage,
                      actionLabel: 'Retry',
                      onAction: () => cubit.search(state.query),
                    );
                  }
                  if (state.showIdle) {
                    return SearchIdleBody(
                      recents: state.recents,
                      nearbyLoading: _nearbyLoading,
                      onNearby: _pickNearby,
                      onRecentTap: _pickRecent,
                      onRecentRemove: cubit.removeRecent,
                      onClearRecents: cubit.clearRecents,
                    );
                  }
                  if (state.showEmptyResults) {
                    return const _MessageBody(
                      icon: Icons.search_off_rounded,
                      title: 'No matches',
                      body: 'Try another city, neighborhood, or venue name.',
                    );
                  }
                  return ListView(
                    padding: const .fromLTRB(
                      AppSizes.pagePadding,
                      8,
                      AppSizes.pagePadding,
                      24,
                    ),
                    children: [
                      if (state.places.isNotEmpty) ...[
                        Text(
                          'Places',
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: .w800,
                          ),
                        ),
                        8.h,
                        for (final place in state.places)
                          _PlaceTile(
                            place: place,
                            onTap: () => _pickPlace(place),
                          ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ).annotatedRegion(.dark);
  }
}

class _PlaceTile extends StatelessWidget {
  const _PlaceTile({required this.place, required this.onTap});

  final PlaceSuggestion place;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: .zero,
      onTap: onTap,
      leading: const DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            Icons.location_on_outlined,
            color: AppColors.primary,
            size: 20,
          ),
        ),
      ),
      title: Text(
        place.primaryText,
        style: context.textTheme.titleSmall?.copyWith(fontWeight: .w700),
      ),
      subtitle: Text(
        place.secondaryText,
        style: context.textTheme.labelMedium?.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: const Icon(
        Icons.north_west_rounded,
        size: 16,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _MessageBody extends StatelessWidget {
  const _MessageBody({
    required this.icon,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: .center,
      children: [
        Icon(icon, size: 44, color: AppColors.primary),
        12.h,
        Text(
          title,
          style: context.textTheme.titleMedium?.copyWith(fontWeight: .w800),
        ),
        6.h,
        Text(
          body,
          textAlign: .center,
          style: context.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ).paddingSymmetric(horizontal: 40),
        if (actionLabel != null && onAction != null) ...[
          16.h,
          TextButton(
            onPressed: onAction,
            child: Text(
              actionLabel!,
              style: context.textTheme.labelLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: .w800,
              ),
            ),
          ),
        ],
      ],
    ).center();
  }
}

class _SearchShimmer extends StatelessWidget {
  const _SearchShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const .fromLTRB(
        AppSizes.pagePadding,
        8,
        AppSizes.pagePadding,
        24,
      ),
      itemCount: 4,
      separatorBuilder: (_, _) => 12.h,
      itemBuilder: (_, _) => const ShimmerBox(
        width: double.infinity,
        height: 118,
        radius: AppSizes.radiusXl,
      ),
    ).shimmer();
  }
}
