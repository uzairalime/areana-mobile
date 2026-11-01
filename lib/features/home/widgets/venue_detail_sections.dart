import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/money_format.dart';
import '../../../core/utils/venue_navigation.dart';
import '../model/areana_models.dart';
import '../model/venue.dart';

/// Courts + reviews sections for the venue detail screen, mirroring
/// user-web venue detail: courts first (players book a court), then
/// public reviews. Kept out of the screen file to stay under 500 lines.
class VenueCourtsSection extends StatelessWidget {
  const VenueCourtsSection({super.key, required this.detail});

  final AreanaVenueDetail detail;

  @override
  Widget build(BuildContext context) {
    final venue = detail.venue.toVenue();
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          'Courts',
          style: context.textTheme.titleMedium?.copyWith(fontWeight: .w800),
        ),
        10.h,
        if (detail.courts.isEmpty)
          Text(
            'No courts listed for this arena yet.',
            style: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          )
        else
          for (final court in detail.courts) ...[
            _CourtRow(detail: detail, court: court, venue: venue),
            8.h,
          ],
      ],
    );
  }
}

class _CourtRow extends StatelessWidget {
  const _CourtRow({
    required this.detail,
    required this.court,
    required this.venue,
  });

  final AreanaVenueDetail detail;
  final AreanaCourt court;
  final Venue venue;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: InkWell(
        onTap: () =>
            context.push('${AppRoutes.courtDetail}/${court.id}'),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: AppColors.outline),
          ),
          child: Padding(
            padding: const .all(14),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      court.name,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: .w700,
                      ),
                    ),
                    2.h,
                    Text(
                      court.specLine,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ).expand(),
                Column(
                  crossAxisAlignment: .end,
                  children: [
                    Text(
                      MoneyFormat.pkr(court.pricePerHour),
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: .w800,
                      ),
                    ),
                    Text(
                      '/hr',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                8.w,
                TextButton(
                  onPressed: () => VenueNavigation.openBookSlot(
                    context,
                    venue,
                    preselectedCourtId: court.id,
                  ),
                  child: const Text('Book'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VenueReviewsSection extends StatelessWidget {
  const VenueReviewsSection({
    super.key,
    required this.reviews,
    required this.hasMore,
    required this.onLoadMore,
  });

  final List<AreanaReview> reviews;
  final bool hasMore;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          'Reviews',
          style: context.textTheme.titleMedium?.copyWith(fontWeight: .w800),
        ),
        10.h,
        if (reviews.isEmpty)
          Text(
            'No reviews yet.',
            style: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          )
        else
          for (final review in reviews) ...[
            Row(
              children: [
                const Icon(Icons.star_rounded, size: 16, color: AppColors.accent),
                4.w,
                Text(
                  '${review.rating}/5',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: .w700,
                  ),
                ),
                8.w,
                Text(
                  review.userName,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ).expand(),
              ],
            ),
            if (review.comment != null && review.comment!.isNotEmpty) ...[
              4.h,
              Text(review.comment!, style: context.textTheme.bodyMedium),
            ],
            if (review.ownerReply != null &&
                review.ownerReply!.isNotEmpty) ...[
              4.h,
              Text(
                'Owner: ${review.ownerReply!}',
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            12.h,
          ],
        if (hasMore)
          TextButton(onPressed: onLoadMore, child: const Text('Load more')),
      ],
    );
  }
}
