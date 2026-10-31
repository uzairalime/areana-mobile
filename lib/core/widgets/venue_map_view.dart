import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../features/home/model/venue.dart';
import '../consts/app_colors.dart';
import '../consts/app_sizes.dart';
import '../extensions/extensions.dart';
import '../utils/app_haptics.dart';
import '../utils/map_directions.dart';
import '../utils/money_format.dart';
import '../utils/venue_map_clustering.dart';

/// Shared OSM map used by Explore and venue detail.
class VenueMapView extends StatefulWidget {
  const VenueMapView({
    super.key,
    required this.venues,
    this.onVenueTap,
    this.showControls = true,
    this.interactive = true,
    this.openDirectionsOnTap = false,
    this.showPriceMarkers = true,
    this.enableClustering = false,
    this.initialZoom,
    this.borderRadius,
    this.controlsBottom = 16,
  });

  final List<Venue> venues;
  final ValueChanged<Venue>? onVenueTap;
  final bool showControls;

  /// When false, pan / pinch / scroll are locked (preview maps).
  final bool interactive;

  /// Full-map tap opens external directions to the primary venue.
  final bool openDirectionsOnTap;
  final bool showPriceMarkers;

  /// When true and venue count &gt; [VenueMapClustering.clusterThreshold],
  /// markers are clustered (zoom in spreads, zoom out merges).
  final bool enableClustering;
  final double? initialZoom;
  final BorderRadius? borderRadius;
  final double controlsBottom;

  @override
  State<VenueMapView> createState() => _VenueMapViewState();
}

class _VenueMapViewState extends State<VenueMapView> {
  final _mapController = MapController();

  static const _fallback = LatLng(24.8607, 67.0011);

  late double _zoom;
  LatLngBounds? _visibleBounds;
  List<Venue>? _mappedCache;
  List<Venue> _mapped = const [];

  @override
  void initState() {
    super.initState();
    _zoom = widget.initialZoom ?? _autoZoomFor(_resolveMapped());
    _mapped = _resolveMapped();
  }

  List<Venue> _resolveMapped() {
    final source = widget.venues;
    // Fast path only when the same instance is passed again.
    if (identical(source, _mappedCache) && _mapped.isNotEmpty) {
      return _mapped;
    }
    _mappedCache = source;
    return [
      for (final v in source)
        if (v.hasCoordinates) v,
    ];
  }

  LatLng get _center {
    final venues = _mapped;
    if (venues.isEmpty) return _fallback;
    if (venues.length == 1) {
      return LatLng(venues.first.latitude, venues.first.longitude);
    }
    var lat = 0.0;
    var lng = 0.0;
    for (final v in venues) {
      lat += v.latitude;
      lng += v.longitude;
    }
    final n = venues.length;
    return LatLng(lat / n, lng / n);
  }

  static double _autoZoomFor(List<Venue> venues) {
    if (venues.length <= 1) return 14;
    final lats = venues.map((v) => v.latitude);
    final lngs = venues.map((v) => v.longitude);
    final latSpan = (lats.reduce((a, b) => a > b ? a : b) -
            lats.reduce((a, b) => a < b ? a : b))
        .abs();
    final lngSpan = (lngs.reduce((a, b) => a > b ? a : b) -
            lngs.reduce((a, b) => a < b ? a : b))
        .abs();
    if (latSpan > 2 || lngSpan > 2) return 5.8;
    if (latSpan > 0.3 || lngSpan > 0.3) return 11;
    return 12.5;
  }

  double get _fitZoom => widget.initialZoom ?? _autoZoomFor(_mapped);

  List<Venue> _viewportVenues() {
    final bounds = _visibleBounds;
    if (bounds == null || _mapped.length <= VenueMapClustering.clusterThreshold) {
      return _mapped;
    }
    // Pad bounds slightly so edge markers don't pop in/out.
    final latPad = (bounds.north - bounds.south).abs() * 0.15;
    final lngPad = (bounds.east - bounds.west).abs() * 0.15;
    final minLat = bounds.south - latPad;
    final maxLat = bounds.north + latPad;
    final minLng = bounds.west - lngPad;
    final maxLng = bounds.east + lngPad;
    return [
      for (final v in _mapped)
        if (v.latitude >= minLat &&
            v.latitude <= maxLat &&
            v.longitude >= minLng &&
            v.longitude <= maxLng)
          v,
    ];
  }

  List<VenueCluster> _clusters() {
    final inView = _viewportVenues();
    if (!widget.enableClustering) {
      return [for (final v in inView) VenueCluster.single(v)];
    }
    return VenueMapClustering.build(venues: inView, zoom: _zoom);
  }

  @override
  void didUpdateWidget(covariant VenueMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(
      oldWidget.venues.map((v) => v.id).toList(growable: false),
      widget.venues.map((v) => v.id).toList(growable: false),
    )) {
      _mappedCache = null;
      _mapped = _resolveMapped();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _mapController.move(_center, _fitZoom);
        setState(() {
          _zoom = _fitZoom;
          _visibleBounds = _mapController.camera.visibleBounds;
        });
      });
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _onMapEvent(MapEvent event) {
    // Only recompute clusters after interaction settles — avoids per-frame rebuilds.
    if (event is MapEventMoveEnd ||
        event is MapEventFlingAnimationEnd ||
        event is MapEventDoubleTapZoomEnd ||
        event is MapEventScrollWheelZoom) {
      final cam = event.camera;
      final nextZoom = cam.zoom;
      final nextBounds = cam.visibleBounds;
      if ((nextZoom - _zoom).abs() < 0.01 &&
          _visibleBounds == nextBounds) {
        return;
      }
      setState(() {
        _zoom = nextZoom;
        _visibleBounds = nextBounds;
      });
    }
  }

  void _onClusterTap(VenueCluster cluster) {
    AppHaptics.selection();
    if (cluster.isSingle) {
      widget.onVenueTap?.call(cluster.first);
      return;
    }
    if (!widget.interactive) return;
    final nextZoom = (_zoom + 1.8).clamp(4.0, 18.0);
    _mapController.move(cluster.center, nextZoom);
    setState(() {
      _zoom = nextZoom;
      _visibleBounds = _mapController.camera.visibleBounds;
    });
  }

  void _openDirections() {
    final venue = _mapped.isNotEmpty ? _mapped.first : null;
    if (venue == null) return;
    AppHaptics.selection();
    MapDirections.openVenue(venue);
  }

  int get _interactionFlags {
    if (!widget.interactive) return InteractiveFlag.none;
    if (widget.showControls) {
      return InteractiveFlag.all & ~InteractiveFlag.rotate;
    }
    return InteractiveFlag.pinchZoom | InteractiveFlag.drag;
  }

  @override
  Widget build(BuildContext context) {
    _mapped = _resolveMapped();
    final clusters = _clusters();
    final lockGestures = !widget.interactive;
    final openDirections = widget.openDirectionsOnTap;

    final markers = <Marker>[
      for (final cluster in clusters)
        Marker(
          key: ValueKey(
            cluster.isSingle
                ? 'v-${cluster.first.id}'
                : 'c-${cluster.center.latitude.toStringAsFixed(4)}-'
                    '${cluster.center.longitude.toStringAsFixed(4)}-'
                    '${cluster.count}',
          ),
          point: cluster.center,
          width: cluster.isSingle
              ? (widget.showPriceMarkers ? 112 : 36)
              : 44,
          height: cluster.isSingle
              ? (widget.showPriceMarkers ? 44 : 36)
              : 44,
          alignment: .topCenter,
          child: cluster.isSingle
              ? (widget.showPriceMarkers
                    ? _PriceMarker(
                        label: MoneyFormat.pkr(cluster.first.priceFrom),
                        onTap: openDirections
                            ? _openDirections
                            : () => _onClusterTap(cluster),
                      )
                    : _PinMarker(
                        onTap: openDirections
                            ? _openDirections
                            : () => _onClusterTap(cluster),
                      ))
              : _ClusterMarker(
                  count: cluster.count,
                  onTap: () => _onClusterTap(cluster),
                ),
        ),
    ];

    Widget map = Stack(
      fit: .expand,
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _center,
            initialZoom: _fitZoom,
            minZoom: 4,
            maxZoom: 18,
            onMapReady: () {
              _visibleBounds = _mapController.camera.visibleBounds;
              _zoom = _mapController.camera.zoom;
            },
            onMapEvent: lockGestures ? null : _onMapEvent,
            onTap: openDirections ? (_, _) => _openDirections() : null,
            interactionOptions: InteractionOptions(flags: _interactionFlags),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.arana360',
              maxNativeZoom: 19,
              keepBuffer: 2,
              panBuffer: 1,
            ),
            MarkerLayer(markers: markers),
          ],
        ),
        if (widget.showControls && widget.interactive)
          Positioned(
            right: 12,
            bottom: widget.controlsBottom,
            child: Column(
              children: [
                _MapFab(
                  icon: Icons.my_location_rounded,
                  onTap: () {
                    AppHaptics.selection();
                    _mapController.move(_center, _fitZoom);
                    setState(() {
                      _zoom = _fitZoom;
                      _visibleBounds = _mapController.camera.visibleBounds;
                    });
                  },
                ),
                8.h,
                _MapFab(
                  icon: Icons.add,
                  onTap: () {
                    AppHaptics.selection();
                    final z = (_mapController.camera.zoom + 1).clamp(4.0, 18.0);
                    _mapController.move(_mapController.camera.center, z);
                  },
                ),
                8.h,
                _MapFab(
                  icon: Icons.remove,
                  onTap: () {
                    AppHaptics.selection();
                    final z = (_mapController.camera.zoom - 1).clamp(4.0, 18.0);
                    _mapController.move(_mapController.camera.center, z);
                  },
                ),
              ],
            ),
          ),
      ],
    );

    if (widget.borderRadius != null) {
      map = ClipRRect(borderRadius: widget.borderRadius!, child: map);
    }
    return map;
  }
}

/// Locked preview map for detail screens — tap opens external directions.
class VenueMapCard extends StatelessWidget {
  const VenueMapCard({
    super.key,
    required this.title,
    required this.venues,
    this.subtitle,
    this.height = 180,
    this.showPriceMarkers = false,
  });

  final String title;
  final String? subtitle;
  final List<Venue> venues;
  final double height;
  final bool showPriceMarkers;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          title,
          style: context.textTheme.titleMedium?.copyWith(fontWeight: .w800),
        ),
        if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
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
                subtitle!,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ).expand(),
            ],
          ),
        ],
        12.h,
        SizedBox(
          height: height,
          width: double.infinity,
          child: VenueMapView(
            venues: venues,
            showControls: false,
            interactive: false,
            openDirectionsOnTap: true,
            showPriceMarkers: showPriceMarkers,
            enableClustering: false,
            initialZoom: venues.length == 1 ? 14.5 : null,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          ),
        ),
      ],
    );
  }
}

class _ClusterMarker extends StatelessWidget {
  const _ClusterMarker({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: .circle,
          border: Border.all(color: AppColors.accent, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: Text(
              '$count',
              style: context.textTheme.labelLarge?.copyWith(
                color: AppColors.accent,
                fontWeight: .w800,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PriceMarker extends StatelessWidget {
  const _PriceMarker({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: .min,
        children: [
          Material(
            color: AppColors.surface,
            elevation: 4,
            shadowColor: AppColors.shadow.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            child: Padding(
              padding: const .symmetric(horizontal: 10, vertical: 7),
              child: Text(
                label,
                maxLines: 1,
                overflow: .ellipsis,
                style: context.textTheme.labelLarge?.copyWith(
                  fontWeight: .w800,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          CustomPaint(
            size: const Size(12, 8),
            painter: _MarkerTipPainter(color: AppColors.surface),
          ),
        ],
      ),
    );
  }
}

class _PinMarker extends StatelessWidget {
  const _PinMarker({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: const DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: .circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x330D1B14),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: SizedBox(
          width: 28,
          height: 28,
          child: Icon(Icons.stadium_rounded, size: 14, color: AppColors.accent),
        ),
      ),
    );
  }
}

class _MarkerTipPainter extends CustomPainter {
  const _MarkerTipPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _MarkerTipPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _MapFab extends StatelessWidget {
  const _MapFab({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: AppColors.shadow.withValues(alpha: 0.15),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 18, color: AppColors.text),
        ),
      ),
    );
  }
}
