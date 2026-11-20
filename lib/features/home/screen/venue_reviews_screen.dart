import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/widgets/app_loading_handler.dart';
import '../../../core/widgets/pagination_loader.dart';
import '../cubit/venue_reviews_cubit.dart';
import '../model/venue.dart';
import '../widgets/venue_detail_sections.dart';
import '../widgets/venue_detail_shimmer.dart';
import '../widgets/venue_rating_line.dart';

class VenueReviewsScreen extends StatelessWidget {
  const VenueReviewsScreen({super.key, required this.venue});

  final Venue venue;

  static Venue resolve(GoRouterState state) {
    final extra = state.extra;
    if (extra is Venue) return extra;
    final id = state.pathParameters['id'] ?? '';
    return Venue(
      id: id,
      name: 'Reviews',
      sport: '',
      location: '',
      priceFrom: 0,
      amenities: const [],
      nextSlot: '',
      heroColor: AppColors.primary,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        title: Text(
          venue.name.isEmpty ? 'Reviews' : venue.name,
          style: context.textTheme.titleLarge?.copyWith(fontWeight: .w800),
        ),
      ),
      body: BlocBuilder<VenueReviewsCubit, VenueReviewsState>(
        builder: (context, state) {
          final cubit = context.read<VenueReviewsCubit>();
          return AppLoadingHandler(
            status: state.status,
            errorMessage: state.errorMessage,
            onRetry: cubit.load,
            loading: const VenueReviewsListShimmer(),
            child: state.reviews.isEmpty
                ? ListView(
                    padding: const .fromLTRB(20, 48, 20, 28),
                    children: [
                      const Icon(
                        Icons.rate_review_outlined,
                        size: 48,
                        color: AppColors.primary,
                      ).center(),
                      16.h,
                      Text(
                        'No reviews yet',
                        textAlign: .center,
                        style: context.textTheme.headlineMedium?.copyWith(
                          fontSize: 20,
                        ),
                      ),
                      8.h,
                      Text(
                        'Be the first to rate this arena after you play.',
                        textAlign: .center,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const .fromLTRB(20, 8, 20, 28),
                    itemCount:
                        state.reviews.length +
                        (state.hasMore || state.paging ? 1 : 0) +
                        (venue.hasRating ? 1 : 0),
                    separatorBuilder: (_, _) => 12.h,
                    itemBuilder: (context, index) {
                      var i = index;
                      if (venue.hasRating) {
                        if (i == 0) {
                          return _ReviewsSummary(venue: venue);
                        }
                        i -= 1;
                      }
                      if (i < state.reviews.length) {
                        return VenueReviewTile(review: state.reviews[i]);
                      }
                      return PaginationLoader(
                        pageKey: '${state.reviews.length}',
                        enabled: state.hasMore && !state.paging,
                        errorMessage: state.paging ? '' : state.errorMessage,
                        onLoadMore: cubit.loadMore,
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}

class _ReviewsSummary extends StatelessWidget {
  const _ReviewsSummary({required this.venue});

  final Venue venue;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(
            'Player reviews',
            style: context.textTheme.titleMedium?.copyWith(fontWeight: .w800),
          ),
          8.h,
          VenueRatingLine(rating: venue.rating, reviewCount: venue.reviewCount),
        ],
      ).paddingAll(16),
    );
  }
}
