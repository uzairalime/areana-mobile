import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/services/location/location_cubit.dart';
import '../../../core/services/location/location_state.dart';
import '../../../core/utils/venue_navigation.dart';
import '../../../core/widgets/app_shimmer.dart';
import '../model/nearby_venue.dart';
import '../model/venue.dart';
import 'near_me_permission_card.dart';
import 'near_me_venue_card.dart';

/// Home “Near me” strip — requests location like ReelStay, then ranks venues.
class HomeNearMeSection extends StatefulWidget {
  const HomeNearMeSection({super.key, required this.venues});

  final List<Venue> venues;

  @override
  State<HomeNearMeSection> createState() => _HomeNearMeSectionState();
}

class _HomeNearMeSectionState extends State<HomeNearMeSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cubit = context.read<LocationCubit>();
      if (!cubit.state.hasPosition) {
        cubit.ensurePermission(fetchLocation: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationCubit, LocationState>(
      builder: (context, location) {
        final cubit = context.read<LocationCubit>();

        return Column(
          crossAxisAlignment: .start,
          children: [
            Row(
              children: [
                Text(
                  'Near me',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: .w800,
                  ),
                ).expand(),
                if (location.hasPosition)
                  IconButton(
                    tooltip: 'Refresh location',
                    onPressed: location.isLoading
                        ? null
                        : cubit.refreshPosition,
                    icon: const Icon(Icons.my_location_rounded, size: 20),
                    color: AppColors.primary,
                  ),
              ],
            ),
            10.h,
            if (location.isLoading && !location.hasPosition)
              const _NearMeShimmer()
            else if (!location.isGranted || !location.hasPosition)
              NearMePermissionCard(
                message: location.errorMessage.isEmpty
                    ? 'Turn on location to see courts closest to you.'
                    : location.errorMessage,
                actionLabel: location.isDeniedForever ? 'Settings' : 'Enable',
                isLoading: location.isLoading,
                onAction: () {
                  if (location.isDeniedForever) {
                    cubit.openSettings();
                  } else {
                    cubit.ensurePermission(fetchLocation: true);
                  }
                },
              )
            else
              _NearbyList(venues: widget.venues, location: location),
          ],
        );
      },
    );
  }
}

class _NearbyList extends StatelessWidget {
  const _NearbyList({required this.venues, required this.location});

  final List<Venue> venues;
  final LocationState location;

  @override
  Widget build(BuildContext context) {
    final position = location.position!;
    final nearby = NearbyVenueSorter.fromVenues(
      venues: venues,
      latitude: position.latitude,
      longitude: position.longitude,
    );

    if (nearby.isEmpty) {
      return Text(
        'No courts within 25 km of your location yet.',
        style: context.textTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
        ),
      );
    }

    return SizedBox(
      height: 196,
      child: ListView.separated(
        scrollDirection: .horizontal,
        itemCount: nearby.length,
        separatorBuilder: (_, _) => 10.w,
        itemBuilder: (context, index) {
          final item = nearby[index];
          return NearMeVenueCard(
            item: item,
            onTap: () => VenueNavigation.openDetail(context, item.venue),
          );
        },
      ),
    );
  }
}

class _NearMeShimmer extends StatelessWidget {
  const _NearMeShimmer();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 196,
      child: ListView.separated(
        scrollDirection: .horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (_, _) => 10.w,
        itemBuilder: (_, _) => const DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: .all(Radius.circular(AppSizes.radiusLg)),
          ),
          child: SizedBox(
            width: 168,
            child: Padding(
              padding: .all(10),
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  ShimmerBox(height: 96, radius: 12),
                  SizedBox(height: 10),
                  ShimmerBox(width: 120, height: 12, radius: 6),
                  SizedBox(height: 8),
                  ShimmerBox(width: 72, height: 10, radius: 5),
                ],
              ),
            ),
          ),
        ),
      ),
    ).shimmer();
  }
}
