import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/enums/app_loading.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/utils/money_format.dart';
import '../../../core/utils/venue_navigation.dart';
import '../../../core/widgets/app_button.dart';
import '../../booking/widgets/court_hero_canvas.dart';
import '../cubit/venue_detail_cubit.dart';
import '../model/venue.dart';
import '../widgets/venue_detail_sections.dart';

/// Court detail, mirroring user-web `/courts/[id]`: court spec +
/// price, its venue (name, city, amenities, rating), and public
/// court reviews. Book goes to the court-first booking flow with
/// the venue row built from the court detail's venue fields.
class CourtDetailScreen extends StatelessWidget {
  const CourtDetailScreen({super.key, required this.courtId});

  final String courtId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<CourtDetailCubit, CourtDetailState>(
        builder: (context, state) {
          final detail = state.detail;
          if (state.status.isLoading && detail == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (detail == null) {
            return Center(
              child: Column(
                mainAxisSize: .min,
                children: [
                  Text(
                    state.errorMessage.isEmpty
                        ? 'Court not found'
                        : state.errorMessage,
                    textAlign: .center,
                  ),
                  12.h,
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Go back'),
                  ),
                ],
              ),
            );
          }
          final court = detail.court;
          final venue = Venue(
            id: detail.venueId,
            name: detail.venueName,
            sport: court.sport,
            location: detail.venueCity.isEmpty
                ? detail.venueAddress
                : '${detail.venueAddress}, ${detail.venueCity}',
            priceFrom: court.pricePerHour,
            amenities: detail.venueAmenities,
            nextSlot: '',
            heroColor: AppColors.primary,
            rating: detail.venueRating,
            reviewCount: detail.venueRatingCount,
            latitude: detail.venueLat ?? 0,
            longitude: detail.venueLng ?? 0,
            imageUrls: detail.venueImages,
          );
          return Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _CourtHero(courtName: court.name),
                    ),
                    SliverPadding(
                      padding: const .fromLTRB(20, 18, 20, 28),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          Text(
                            court.name,
                            style: context.textTheme.headlineMedium?.copyWith(
                              fontSize: 26,
                              fontWeight: .w800,
                            ),
                          ),
                          8.h,
                          Text(
                            court.specLine,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          8.h,
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              4.w,
                              Text(
                                venue.location,
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ).expand(),
                            ],
                          ),
                          if (detail.venueRating > 0) ...[
                            12.h,
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 18,
                                  color: AppColors.accent,
                                ),
                                4.w,
                                Text(
                                  detail.venueRating.toStringAsFixed(1),
                                  style: context.textTheme.titleSmall?.copyWith(
                                    fontWeight: .w800,
                                  ),
                                ),
                                6.w,
                                Text(
                                  '(${detail.venueRatingCount} reviews)',
                                  style: context.textTheme.labelMedium
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                              ],
                            ),
                          ],
                          AppSizes.spaceLg.h,
                          Text(
                            'Arena',
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: .w800,
                            ),
                          ),
                          8.h,
                          Text(
                            detail.venueName,
                            style: context.textTheme.bodyMedium,
                          ),
                          if (detail.venueAmenities.isNotEmpty) ...[
                            AppSizes.spaceLg.h,
                            Text(
                              'Amenities',
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: .w800,
                              ),
                            ),
                            10.h,
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final amenity in detail.venueAmenities)
                                  DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(
                                        AppSizes.radiusPill,
                                      ),
                                      border: Border.all(
                                        color: AppColors.outline,
                                      ),
                                    ),
                                    child: Text(
                                      amenity,
                                      style: context.textTheme.labelMedium
                                          ?.copyWith(fontWeight: .w600),
                                    ).paddingSymmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                          AppSizes.spaceLg.h,
                          VenueReviewsSection(
                            reviews: state.reviews,
                            hasMore: state.hasMoreReviews,
                            onLoadMore: () => context
                                .read<CourtDetailCubit>()
                                .loadMoreReviews(),
                          ),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
              DecoratedBox(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.outline)),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const .fromLTRB(20, 12, 20, 16),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: .start,
                          mainAxisSize: .min,
                          children: [
                            Text(
                              'From',
                              style: context.textTheme.labelSmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            2.h,
                            Row(
                              crossAxisAlignment: .end,
                              children: [
                                Text(
                                  MoneyFormat.pkr(court.pricePerHour),
                                  style: context.textTheme.titleLarge?.copyWith(
                                    fontSize: 22,
                                    fontWeight: .w800,
                                  ),
                                ),
                                4.w,
                                Text(
                                  '/hr',
                                  style: context.textTheme.labelMedium
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        16.w,
                        AppButton(
                          label: 'Book slot',
                          showArrow: false,
                          icon: Icons.arrow_forward_rounded,
                          onPressed: () {
                            AppHaptics.selection();
                            VenueNavigation.openBookSlot(
                              context,
                              venue,
                              preselectedCourtId: court.id,
                            );
                          },
                          minimumSize: const Size(0, AppSizes.buttonHeight),
                        ).expand(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ).annotatedRegion(.dark);
  }
}

class _CourtHero extends StatelessWidget {
  const _CourtHero({required this.courtName});

  final String courtName;

  @override
  Widget build(BuildContext context) {
    return CourtHeroCanvas(
      color: AppColors.primary,
      height: 260,
      showGradient: false,
    );
  }
}
