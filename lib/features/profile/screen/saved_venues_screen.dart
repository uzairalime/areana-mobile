import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/utils/venue_navigation.dart';
import '../../../core/widgets/app_loading_handler.dart';
import '../../home/widgets/venue_card.dart';
import '../../home/widgets/venue_card_shimmer.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/profile_subpage_scaffold.dart';

class SavedVenuesScreen extends StatefulWidget {
  const SavedVenuesScreen({super.key});

  @override
  State<SavedVenuesScreen> createState() => _SavedVenuesScreenState();
}

class _SavedVenuesScreenState extends State<SavedVenuesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadSavedVenues();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final cubit = context.read<ProfileCubit>();
        return ProfileSubpageScaffold(
          title: 'Saved venues',
          body: AppLoadingHandler(
            status: state.status,
            errorMessage: state.errorMessage,
            onRetry: cubit.loadSavedVenues,
            loading: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              padding: const .fromLTRB(20, 8, 20, 28),
              itemCount: 3,
              separatorBuilder: (_, _) => AppSizes.spaceMd.h,
              itemBuilder: (_, _) => const VenueCardShimmer(),
            ).shimmer(),
            child: state.savedVenues.isEmpty
                ? ListView(
                    padding: const .fromLTRB(20, 48, 20, 28),
                    children: [
                      const Icon(
                        Icons.favorite_border_rounded,
                        size: 48,
                        color: AppColors.primary,
                      ).center(),
                      16.h,
                      Text(
                        'No saved venues yet',
                        textAlign: .center,
                        style: context.textTheme.headlineMedium?.copyWith(
                          fontSize: 20,
                        ),
                      ),
                      8.h,
                      Text(
                        'Tap the heart on any venue to keep it here for quick booking.',
                        textAlign: .center,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      22.h,
                      TextButton(
                        onPressed: () {
                          AppHaptics.selection();
                          context.go(AppRoutes.explore);
                        },
                        child: Text(
                          'Explore venues',
                          style: context.textTheme.labelLarge?.copyWith(
                            color: AppColors.primary,
                            fontWeight: .w800,
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const .fromLTRB(20, 8, 20, 28),
                    itemCount: state.savedVenues.length,
                    separatorBuilder: (_, _) => AppSizes.spaceMd.h,
                    itemBuilder: (context, index) {
                      final venue = state.savedVenues[index];
                      return VenueCard(
                        venue: venue,
                        isFavorite: true,
                        onFavoriteTap: () {
                          cubit.unsaveVenue(venue.id);
                        },
                        onOpen: () =>
                            VenueNavigation.openDetail(context, venue),
                        onBook: () =>
                            VenueNavigation.openBookSlot(context, venue),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}
