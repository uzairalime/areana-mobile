import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../consts/app_colors.dart';
import '../extensions/extensions.dart';
import '../widgets/app_shimmer.dart';

/// Cached network image — same role as ReelStay [CacheImage], trimmed for Pitchside.
class CacheImage extends StatelessWidget {
  const CacheImage({
    super.key,
    required this.url,
    this.height,
    this.width,
    this.fit = .cover,
    this.alignment = .center,
    this.borderRadius,
    this.memCacheWidth,
    this.memCacheHeight,
    this.placeHolder,
    this.errorWidget,
  });

  final String url;
  final double? height;
  final double? width;
  final BoxFit fit;
  final Alignment alignment;
  final BorderRadius? borderRadius;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final Widget? placeHolder;
  final Widget? errorWidget;

  Widget _fallback() {
    return errorWidget ??
        const ColoredBox(
          color: AppColors.primarySoft,
          child: Center(
            child: Icon(
              Icons.image_outlined,
              color: AppColors.textSecondary,
              size: 36,
            ),
          ),
        );
  }

  Widget _loading() {
    return placeHolder ??
        ShimmerBox(
          width: width ?? double.infinity,
          height: height ?? double.infinity,
          radius: borderRadius?.topLeft.x ?? 0,
        ).shimmer();
  }

  @override
  Widget build(BuildContext context) {
    final trimmed = url.trim();
    Widget child;
    if (trimmed.isEmpty) {
      child = _fallback();
    } else {
      child = CachedNetworkImage(
        imageUrl: trimmed,
        height: height,
        width: width,
        fit: fit,
        alignment: alignment,
        memCacheWidth: memCacheWidth,
        memCacheHeight: memCacheHeight,
        filterQuality: .medium,
        fadeInDuration: const Duration(milliseconds: 200),
        fadeOutDuration: const Duration(milliseconds: 200),
        useOldImageOnUrlChange: true,
        placeholder: (_, _) => _loading(),
        errorWidget: (_, _, _) => _fallback(),
      );
    }

    final sized = SizedBox(height: height, width: width, child: child);
    if (borderRadius == null) return sized;
    return ClipRRect(borderRadius: borderRadius!, child: sized);
  }
}
