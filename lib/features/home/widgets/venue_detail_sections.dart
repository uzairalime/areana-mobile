import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/media_slider/cache_image.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/money_format.dart';
import '../../../core/utils/venue_navigation.dart';
import '../../booking/widgets/court_hero_canvas.dart';
import '../model/areana_models.dart';
import '../model/venue.dart';

const kVenueReviewPreviewCount = 4;

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

  String get _thumbUrl {
    for (final url in court.images) {
      if (url.trim().isNotEmpty) return url.trim();
    }
    return venue.coverUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: InkWell(
        onTap: () => context.push('${AppRoutes.courtDetail}/${court.id}'),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: AppColors.outline),
          ),
          child: Padding(
            padding: const .all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: CacheImage(
                      url: _thumbUrl,
                      width: 56,
                      height: 56,
                      memCacheWidth: 160,
                      errorWidget: CourtHeroCanvas(
                        color: venue.heroColor,
                        height: 56,
                        showGradient: false,
                      ),
                    ),
                  ),
                ),
                12.w,
                Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      court.name,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: .w800,
                        fontSize: 15,
                      ),
                    ),
                    2.h,
                    Text(
                      court.specLine,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    4.h,
                    Text(
                      '${MoneyFormat.pkr(court.pricePerHour)}/hr',
                      style: context.textTheme.labelLarge?.copyWith(
                        fontWeight: .w800,
                      ),
                    ),
                  ],
                ).expand(),
                FilledButton(
                  onPressed: () => VenueNavigation.openBookSlot(
                    context,
                    venue,
                    preselectedCourtId: court.id,
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    minimumSize: const Size(0, 36),
                    padding: const .symmetric(horizontal: 14),
                    tapTargetSize: .shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Book',
                    style: context.textTheme.labelLarge?.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: .w800,
                      fontSize: 13,
                    ),
                  ),
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
    required this.reviewCount,
    this.onSeeMore,
  });

  final List<AreanaReview> reviews;
  final bool hasMore;
  final int reviewCount;
  final VoidCallback? onSeeMore;

  @override
  Widget build(BuildContext context) {
    final preview = reviews.take(kVenueReviewPreviewCount).toList();
    final showSeeMore =
        onSeeMore != null &&
        preview.isNotEmpty &&
        (hasMore ||
            reviews.length > kVenueReviewPreviewCount ||
            reviewCount > preview.length);
    return Column(
      crossAxisAlignment: .start,
      children: [
        Row(
          children: [
            Text(
              'Reviews',
              style: context.textTheme.titleMedium?.copyWith(fontWeight: .w800),
            ).expand(),
            if (reviewCount > 0)
              Text(
                '$reviewCount',
                style: context.textTheme.labelMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: .w700,
                ),
              ),
          ],
        ),
        10.h,
        if (preview.isEmpty)
          Text(
            'No reviews yet.',
            style: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          )
        else
          for (final review in preview) ...[
            VenueReviewTile(review: review),
            10.h,
          ],
        if (showSeeMore)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onSeeMore,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.outline),
                minimumSize: const Size(0, 46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
              child: Text(
                'See more reviews',
                style: context.textTheme.labelLarge?.copyWith(
                  fontWeight: .w800,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class VenueReviewTile extends StatelessWidget {
  const VenueReviewTile({super.key, required this.review});

  final AreanaReview review;

  @override
  Widget build(BuildContext context) {
    final name = review.userName.trim().isEmpty ? 'Player' : review.userName;
    final date = _reviewDate(review.createdAt);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primarySoft,
                child: Text(
                  name.characters.first.toUpperCase(),
                  style: context.textTheme.titleSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: .w800,
                  ),
                ),
              ),
              10.w,
              Column(
                crossAxisAlignment: .start,
                children: [
                  Text(
                    name,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: .w800,
                      fontSize: 14,
                    ),
                  ),
                  if (date.isNotEmpty) ...[
                    2.h,
                    Text(
                      date,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ).expand(),
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 16,
                    color: AppColors.accent,
                  ),
                  4.w,
                  Text(
                    '${review.rating}',
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: .w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (review.comment != null && review.comment!.trim().isNotEmpty) ...[
            10.h,
            Text(
              review.comment!,
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.textBody,
                height: 1.4,
              ),
            ),
          ],
          if (review.ownerReply != null &&
              review.ownerReply!.trim().isNotEmpty) ...[
            10.h,
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const .all(10),
                child: Text(
                  'Owner: ${review.ownerReply!}',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ),
            ),
          ],
        ],
      ).paddingAll(14),
    );
  }
}

String _reviewDate(String raw) {
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return '';
  const months = [
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
  return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
}
