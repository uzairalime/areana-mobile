import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/utils/venue_map_clustering.dart';
import '../../../core/widgets/venue_map_view.dart';
import '../../home/model/venue.dart';

/// Explore Map tab — clustered price pins, bbox-driven markers.
class ExploreMapPanel extends StatelessWidget {
  const ExploreMapPanel({
    super.key,
    required this.venues,
    required this.onVenueTap,
    this.focus,
    this.initialCenter,
    this.initialZoom,
    this.cameraFitNonce = 0,
    this.onViewportChanged,
    this.showBackToOrigin = false,
    this.backToOriginLabel = '',
    this.onBackToOrigin,
  });

  final List<Venue> venues;
  final ValueChanged<Venue> onVenueTap;
  final LatLng? focus;
  final LatLng? initialCenter;
  final double? initialZoom;
  final int cameraFitNonce;
  final ValueChanged<MapViewport>? onViewportChanged;
  final bool showBackToOrigin;
  final String backToOriginLabel;
  final VoidCallback? onBackToOrigin;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: .expand,
      children: [
        VenueMapView(
          venues: venues,
          onVenueTap: onVenueTap,
          showControls: true,
          showPriceMarkers: true,
          enableClustering: true,
          focus: focus,
          initialCenter: initialCenter,
          initialZoom: initialZoom,
          cameraFitNonce: cameraFitNonce,
          onViewportChanged: onViewportChanged,
          controlsBottom: 100,
        ),
        if (showBackToOrigin && backToOriginLabel.isNotEmpty)
          Positioned(
            top: 12,
            left: 12,
            right: 72,
            child: _BackToOriginCard(
              label: backToOriginLabel,
              onTap: () {
                AppHaptics.selection();
                onBackToOrigin?.call();
              },
            ),
          ),
      ],
    );
  }
}

class _BackToOriginCard extends StatelessWidget {
  const _BackToOriginCard({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 3,
      shadowColor: AppColors.shadow.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        child: Padding(
          padding: const .fromLTRB(12, 10, 14, 10),
          child: Row(
            mainAxisSize: .min,
            children: [
              const Icon(
                Icons.arrow_back_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              8.w,
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: .ellipsis,
                  style: context.textTheme.labelLarge?.copyWith(
                    fontWeight: .w800,
                    fontSize: 13,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
