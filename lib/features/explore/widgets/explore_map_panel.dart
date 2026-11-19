import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/media_slider/cache_image.dart';
import '../../../core/services/locator.dart';
import '../../../core/services/location/location_cubit.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/utils/money_format.dart';
import '../../../core/utils/venue_map_clustering.dart';
import '../../../core/widgets/venue_map_view.dart';
import '../../booking/widgets/court_hero_canvas.dart';
import '../../home/model/venue.dart';

/// Explore Map tab — price chips, bbox-driven markers, pin preview card.
class ExploreMapPanel extends StatefulWidget {
  const ExploreMapPanel({
    super.key,
    required this.venues,
    required this.onViewVenue,
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
  final ValueChanged<Venue> onViewVenue;
  final LatLng? focus;
  final LatLng? initialCenter;
  final double? initialZoom;
  final int cameraFitNonce;
  final ValueChanged<MapViewport>? onViewportChanged;
  final bool showBackToOrigin;
  final String backToOriginLabel;
  final VoidCallback? onBackToOrigin;

  @override
  State<ExploreMapPanel> createState() => _ExploreMapPanelState();
}

class _ExploreMapPanelState extends State<ExploreMapPanel> {
  Venue? _selected;

  @override
  void didUpdateWidget(covariant ExploreMapPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final selected = _selected;
    if (selected == null) return;
    final stillThere = widget.venues.any((venue) => venue.id == selected.id);
    if (!stillThere) _selected = null;
  }

  void _select(Venue venue) {
    AppHaptics.selection();
    setState(() => _selected = venue);
  }

  void _clear() {
    if (_selected == null) return;
    setState(() => _selected = null);
  }

  Future<LatLng?> _myLocation() async {
    final cubit = getIt<LocationCubit>();
    await cubit.ensurePermission(fetchLocation: true);
    final position = cubit.state.position;
    if (position == null || !position.isValid) {
      if (!mounted) return null;
      final message = cubit.state.errorMessage;
      if (message.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
        );
      }
      return null;
    }
    return LatLng(position.latitude, position.longitude);
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return Stack(
      fit: .expand,
      children: [
        VenueMapView(
          venues: widget.venues,
          onVenueTap: _select,
          showControls: true,
          showPriceMarkers: true,
          enableClustering: true,
          focus: widget.focus,
          initialCenter: widget.initialCenter,
          initialZoom: widget.initialZoom,
          cameraFitNonce: widget.cameraFitNonce,
          onViewportChanged: widget.onViewportChanged,
          controlsBottom: selected == null ? 100 : 188,
          selectedVenueId: selected?.id,
          onBackgroundTap: _clear,
          resolveMyLocation: _myLocation,
        ),
        if (widget.showBackToOrigin && widget.backToOriginLabel.isNotEmpty)
          Positioned(
            top: 12,
            left: 12,
            right: 72,
            child: _BackToOriginCard(
              label: widget.backToOriginLabel,
              onTap: () {
                AppHaptics.selection();
                _clear();
                widget.onBackToOrigin?.call();
              },
            ),
          ),
        if (selected != null)
          Positioned(
            left: 12,
            right: 64,
            bottom: 108,
            child: _VenuePreviewCard(
              venue: selected,
              onView: () {
                AppHaptics.selection();
                widget.onViewVenue(selected);
              },
            ),
          ),
      ],
    );
  }
}

class _VenuePreviewCard extends StatelessWidget {
  const _VenuePreviewCard({required this.venue, required this.onView});

  final Venue venue;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 6,
      shadowColor: AppColors.shadow.withValues(alpha: 0.22),
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: Padding(
        padding: const .all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              child: SizedBox(
                width: 72,
                height: 72,
                child: CacheImage(
                  url: venue.coverUrl,
                  width: 72,
                  height: 72,
                  memCacheWidth: 160,
                  errorWidget: CourtHeroCanvas(
                    color: venue.heroColor,
                    height: 72,
                    showGradient: false,
                  ),
                ),
              ),
            ),
            10.w,
            Column(
              crossAxisAlignment: .start,
              mainAxisSize: .min,
              children: [
                Text(
                  venue.name,
                  maxLines: 1,
                  overflow: .ellipsis,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: .w800,
                  ),
                ),
                4.h,
                Text(
                  venue.location.isEmpty ? venue.sport : venue.location,
                  maxLines: 1,
                  overflow: .ellipsis,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                6.h,
                Text(
                  '${MoneyFormat.pkr(venue.priceFrom)}/hr',
                  style: context.textTheme.labelLarge?.copyWith(
                    fontWeight: .w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ).expand(),
            8.w,
            FilledButton(
              onPressed: onView,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.accent,
                minimumSize: const Size(64, 40),
                padding: const .symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
              child: const Text('View'),
            ),
          ],
        ),
      ),
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
