import 'package:material_ui/material_ui.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/extensions/extensions.dart';

/// Star + `4.5 (21 reviews)` — hidden when the venue has no rating.
class VenueRatingLine extends StatelessWidget {
  const VenueRatingLine({
    super.key,
    required this.rating,
    required this.reviewCount,
    this.iconSize = 18,
    this.compact = false,
  });

  final double rating;
  final int reviewCount;
  final double iconSize;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (rating <= 0) return const SizedBox.shrink();
    final countLabel = reviewCount == 1 ? 'review' : 'reviews';
    return Row(
      children: [
        Icon(Icons.star_rounded, size: iconSize, color: AppColors.accent),
        4.w,
        Text(
          rating.toStringAsFixed(1),
          style:
              (compact
                      ? context.textTheme.labelLarge
                      : context.textTheme.titleSmall)
                  ?.copyWith(fontWeight: .w800),
        ),
        6.w,
        Text(
          '($reviewCount $countLabel)',
          style: context.textTheme.labelMedium?.copyWith(
            color: AppColors.textSecondary,
            fontSize: compact ? 12 : 13,
          ),
        ),
      ],
    );
  }
}
