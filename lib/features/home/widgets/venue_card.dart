import 'package:material_ui/material_ui.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/media_slider/cache_image.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/utils/money_format.dart';
import '../../booking/widgets/court_hero_canvas.dart';
import '../model/venue.dart';
import 'venue_rating_line.dart';

class VenueCard extends StatelessWidget {
  const VenueCard({
    super.key,
    required this.venue,
    required this.onOpen,
    required this.onBook,
    this.isFavorite = false,
    this.onFavoriteTap,
    this.showFavorite = true,
  });

  final Venue venue;
  final VoidCallback onOpen;
  final VoidCallback onBook;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;

  /// When true, shows the heart on the hero (requires [onFavoriteTap]).
  final bool showFavorite;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSizes.radiusXl),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusXl),
            border: Border.all(color: AppColors.outline),
            boxShadow: AppTheme.cardShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusXl),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                _VenueHero(
                  venue: venue,
                  isFavorite: isFavorite,
                  onFavoriteTap: showFavorite ? onFavoriteTap : null,
                ),
                Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      venue.name,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: .w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    6.h,
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
                          style: context.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ).expand(),
                      ],
                    ),
                    if (venue.hasRating) ...[
                      8.h,
                      VenueRatingLine(
                        rating: venue.rating,
                        reviewCount: venue.reviewCount,
                        iconSize: 16,
                        compact: true,
                      ),
                    ],
                    if (venue.amenities.isNotEmpty) 12.h,
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final amenity in venue.amenities)
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusPill,
                              ),
                            ),
                            child: Text(
                              amenity,
                              style: context.textTheme.labelMedium?.copyWith(
                                color: AppColors.textBody,
                                fontSize: 12,
                                fontWeight: .w600,
                              ),
                            ).paddingSymmetric(horizontal: 10, vertical: 6),
                          ),
                      ],
                    ),
                    16.h,
                    const Divider(height: 1, color: AppColors.outline),
                    12.h,
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: .start,
                          children: [
                            Text(
                              'From',
                              style: context.textTheme.labelSmall?.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: .w600,
                              ),
                            ),
                            2.h,
                            Text(
                              '${MoneyFormat.pkr(venue.priceFrom)}/hr',
                              style: context.textTheme.titleSmall?.copyWith(
                                fontWeight: .w800,
                              ),
                            ),
                          ],
                        ).expand(),
                        FilledButton.icon(
                          onPressed: () {
                            AppHaptics.selection();
                            onBook();
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                            minimumSize: const Size(0, 44),
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: AppColors.accent,
                          ),
                          label: Text(
                            'Book slot',
                            style: context.textTheme.labelLarge?.copyWith(
                              color: AppColors.onPrimary,
                              fontWeight: .w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ).paddingAll(AppSizes.spaceMd),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VenueHero extends StatelessWidget {
  const _VenueHero({
    required this.venue,
    required this.isFavorite,
    this.onFavoriteTap,
  });

  final Venue venue;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'venue-hero-${venue.id}',
      child: SizedBox(
        height: 170,
        width: double.infinity,
        child: Stack(
          fit: .expand,
          children: [
            CacheImage(
              url: venue.coverUrl,
              height: 170,
              width: double.infinity,
              memCacheWidth: 800,
              errorWidget: CourtHeroCanvas(
                color: venue.heroColor,
                height: 170,
                showGradient: false,
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: .topCenter,
                  end: .bottomCenter,
                  colors: [Color(0x330D1B14), Color(0x000D1B14)],
                ),
              ),
            ),
            Positioned(
              top: 14,
              left: 14,
              child: _PillBadge(
                label: venue.sport,
                background: AppColors.surface.withValues(alpha: 0.94),
                foreground: AppColors.text,
              ),
            ),
            Positioned(
              top: 14,
              right: 14,
              child: Row(
                mainAxisSize: .min,
                children: [
                  const _PillBadge(
                    label: 'Pay at ground',
                    background: AppColors.accent,
                    foreground: AppColors.text,
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                  if (onFavoriteTap != null) ...[
                    8.w,
                    _FavoriteButton(
                      isFavorite: isFavorite,
                      onTap: onFavoriteTap!,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.isFavorite, required this.onTap});

  final bool isFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface.withValues(alpha: 0.96),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          AppHaptics.selection();
          onTap();
        },
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            size: 18,
            color: isFavorite ? AppColors.error : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _PillBadge extends StatelessWidget {
  const _PillBadge({
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
  });

  final String label;
  final Color background;
  final Color foreground;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
      child: Row(
        mainAxisSize: .min,
        children: [
          if (icon != null) ...[Icon(icon, size: 14, color: foreground), 4.w],
          Text(
            label,
            style: context.textTheme.labelMedium?.copyWith(
              color: foreground,
              fontSize: 12,
              fontWeight: .w800,
            ),
          ),
        ],
      ).paddingSymmetric(horizontal: 10, vertical: 6),
    );
  }
}
