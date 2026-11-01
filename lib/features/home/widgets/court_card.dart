import 'package:flutter/material.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/utils/money_format.dart';
import '../model/areana_models.dart';

/// Feature-only card for one court list row (user-web /courts).
/// Shows court name/spec, its venue, price, and distance when the
/// server sent it. No invented rating: courts carry no rating.
class CourtCard extends StatelessWidget {
  const CourtCard({
    super.key,
    required this.item,
    required this.onOpen,
    required this.onBook,
  });

  final AreanaCourtListItem item;
  final VoidCallback onOpen;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    final court = item.court;
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
          ),
          child: Padding(
            padding: const .all(16),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Row(
                  children: [
                    Text(
                      court.name,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: .w800,
                      ),
                    ).expand(),
                    if (item.distanceKm != null)
                      Text(
                        '${item.distanceKm!.toStringAsFixed(1)} km',
                        style: context.textTheme.labelMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
                4.h,
                Text(
                  court.specLine,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                4.h,
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    4.w,
                    Text(
                      '${item.venueName}, ${item.venueCity}',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ).expand(),
                  ],
                ),
                12.h,
                Row(
                  crossAxisAlignment: .end,
                  children: [
                    Text(
                      MoneyFormat.pkr(court.pricePerHour),
                      style: context.textTheme.titleMedium?.copyWith(
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
                    const Spacer(),
                    TextButton(
                      onPressed: onBook,
                      child: const Text('Book'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
