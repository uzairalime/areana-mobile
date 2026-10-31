import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/mock/mock_home_data.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/utils/money_format.dart';
import '../../../core/utils/venue_navigation.dart';
import '../../../core/media_slider/custom_image_carousel.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/venue_map_view.dart';
import '../../booking/widgets/court_hero_canvas.dart';
import '../model/venue.dart';

class VenueDetailScreen extends StatelessWidget {
  const VenueDetailScreen({super.key, required this.venue});

  final Venue venue;

  static Venue? resolve(GoRouterState state) {
    final extra = state.extra;
    if (extra is Venue) return extra;
    return MockHomeData.byId(state.pathParameters['id']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _DetailCarousel(venue: venue)),
                SliverPadding(
                  padding: const .fromLTRB(20, 18, 20, 28),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _Chip(
                            label: venue.sport,
                            background: AppColors.primarySoft,
                            foreground: AppColors.primary,
                          ),
                          const _Chip(
                            label: 'Pay at ground',
                            background: AppColors.accentSoft,
                            foreground: AppColors.payBadgeText,
                          ),
                        ],
                      ),
                      12.h,
                      Text(
                        venue.name,
                        style: context.textTheme.headlineMedium?.copyWith(
                          fontSize: 26,
                          fontWeight: .w800,
                          height: 1.15,
                          letterSpacing: -0.5,
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
                      if (venue.rating > 0) ...[
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
                              venue.rating.toStringAsFixed(1),
                              style: context.textTheme.titleSmall?.copyWith(
                                fontWeight: .w800,
                              ),
                            ),
                            6.w,
                            Text(
                              '(${venue.reviewCount} reviews)',
                              style: context.textTheme.labelMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (venue.description.isNotEmpty) ...[
                        AppSizes.spaceLg.h,
                        Text(
                          'About',
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: .w800,
                          ),
                        ),
                        8.h,
                        Text(
                          venue.description,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textBody,
                            height: 1.45,
                          ),
                        ),
                      ],
                      AppSizes.spaceLg.h,
                      Text(
                        'Details',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: .w800,
                        ),
                      ),
                      10.h,
                      if (venue.openHours.isNotEmpty)
                        _InfoRow(
                          icon: Icons.schedule_rounded,
                          label: 'Hours',
                          value: venue.openHours,
                        ),
                      if (venue.courtsLabel.isNotEmpty) ...[
                        8.h,
                        _InfoRow(
                          icon: Icons.grid_view_rounded,
                          label: 'Courts',
                          value: venue.courtsLabel,
                        ),
                      ],
                      8.h,
                      _InfoRow(
                        icon: Icons.event_available_rounded,
                        label: 'Next slot',
                        value: venue.nextSlot,
                      ),
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
                          for (final amenity in venue.amenities)
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(
                                  AppSizes.radiusPill,
                                ),
                                border: Border.all(color: AppColors.outline),
                              ),
                              child: Text(
                                amenity,
                                style: context.textTheme.labelMedium?.copyWith(
                                  fontWeight: .w600,
                                  fontSize: 12,
                                ),
                              ).paddingSymmetric(horizontal: 12, vertical: 8),
                            ),
                        ],
                      ),
                      AppSizes.spaceLg.h,
                      VenueMapCard(
                        title: 'Location',
                        subtitle: venue.location,
                        venues: [venue],
                        height: 190,
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
          _DetailStickyBar(venue: venue),
        ],
      ),
    ).annotatedRegion(.dark);
  }
}

class _DetailCarousel extends StatelessWidget {
  const _DetailCarousel({required this.venue});

  final Venue venue;

  @override
  Widget build(BuildContext context) {
    return CustomImageCarousel(
      urls: venue.imageUrls,
      height: 320,
      showActions: true,
      heroTagPrefix: 'venue-${venue.id}',
      onBack: () {
        AppHaptics.selection();
        context.pop();
      },
      fallback: CourtHeroCanvas(
        color: venue.heroColor,
        height: 320,
        showGradient: false,
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
      child: Text(
        label,
        style: context.textTheme.labelMedium?.copyWith(
          color: foreground,
          fontWeight: .w800,
          fontSize: 12,
        ),
      ).paddingSymmetric(horizontal: 10, vertical: 5),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          10.w,
          Column(
            crossAxisAlignment: .start,
            children: [
              Text(
                label,
                style: context.textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              2.h,
              Text(
                value,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: .w700,
                ),
              ),
            ],
          ).expand(),
        ],
      ).paddingSymmetric(horizontal: 14, vertical: 12),
    );
  }
}

class _DetailStickyBar extends StatelessWidget {
  const _DetailStickyBar({required this.venue});

  final Venue venue;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.outline)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0F0D1B14),
            blurRadius: 24,
            offset: Offset(0, -8),
          ),
        ],
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
                        MoneyFormat.pkr(venue.priceFrom),
                        style: context.textTheme.titleLarge?.copyWith(
                          fontSize: 22,
                          fontWeight: .w800,
                        ),
                      ),
                      4.w,
                      Text(
                        '/hr',
                        style: context.textTheme.labelMedium?.copyWith(
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
                onPressed: () => VenueNavigation.openBookSlot(context, venue),
                minimumSize: const Size(0, AppSizes.buttonHeight),
              ).expand(),
            ],
          ),
        ),
      ),
    );
  }
}
