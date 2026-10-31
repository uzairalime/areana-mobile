import 'package:flutter/material.dart';

import '../consts/app_colors.dart';

/// Wraps skeleton children and paints a sliding highlight over them.
class AppShimmer extends StatefulWidget {
  const AppShimmer({
    super.key,
    required this.child,
    this.enabled = true,
    this.baseColor = AppColors.shimmerLowlight,
    this.highlightColor = AppColors.shimmerHighlight,
    this.period = const Duration(milliseconds: 1400),
  });

  final Widget child;
  final bool enabled;
  final Color baseColor;
  final Color highlightColor;
  final Duration period;

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.period)
      ..repeat();
  }

  @override
  void didUpdateWidget(AppShimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.enabled && _controller.isAnimating) {
      _controller.stop();
    }
    if (oldWidget.period != widget.period) {
      _controller.duration = widget.period;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: .srcATop,
          shaderCallback: (bounds) {
            final width = bounds.width;
            final slide = _controller.value * width * 2 - width;
            return LinearGradient(
              begin: .centerLeft,
              end: .centerRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.25, 0.5, 0.75],
              transform: _SlideGradientTransform(slide),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlideGradientTransform extends GradientTransform {
  const _SlideGradientTransform(this.slide);

  final double slide;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(slide, 0, 0);
  }
}

/// Solid block used inside [AppShimmer] / `.shimmer()`.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.radius = 8,
    this.color = AppColors.shimmerBase,
  });

  final double? width;
  final double? height;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
