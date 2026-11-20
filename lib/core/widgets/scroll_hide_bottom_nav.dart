import 'package:material_ui/material_ui.dart';

/// Shared hide/show signal for the dashboard bottom nav.
///
/// Scroll-down hides, scroll-up (or top of list) shows. Tiny deltas are
/// ignored so nested chips / pull-to-refresh do not flicker the bar.
class BottomNavVisibilityController extends ChangeNotifier {
  BottomNavVisibilityController({
    this.hideThreshold = 14,
    this.topRevealPixels = 12,
  });

  final double hideThreshold;
  final double topRevealPixels;

  var _visible = true;
  var _accumulated = 0.0;

  bool get visible => _visible;

  void show() {
    _accumulated = 0;
    if (_visible) return;
    _visible = true;
    notifyListeners();
  }

  void hide() {
    _accumulated = 0;
    if (!_visible) return;
    _visible = false;
    notifyListeners();
  }

  void onNotification(ScrollNotification notification) {
    if (notification.depth != 0) return;
    if (notification is OverscrollNotification) {
      if (notification.overscroll < 0) show();
      return;
    }
    if (notification is! ScrollUpdateNotification) return;
    final delta = notification.scrollDelta;
    if (delta == null) return;
    applyScroll(
      axis: notification.metrics.axis,
      pixels: notification.metrics.pixels,
      delta: delta,
    );
  }

  void applyScroll({
    required Axis axis,
    required double pixels,
    required double delta,
  }) {
    if (axis != Axis.vertical) return;
    if (pixels <= topRevealPixels) {
      show();
      return;
    }
    if (delta == 0) return;

    if (_accumulated != 0 && delta.sign != _accumulated.sign) {
      _accumulated = 0;
    }
    _accumulated += delta;

    if (_accumulated >= hideThreshold) {
      hide();
    } else if (_accumulated <= -hideThreshold) {
      show();
    }
  }
}

/// Provides [BottomNavVisibilityController] without rebuilding scroll views
/// when visibility changes. Read with [maybeOf] (does not listen).
class BottomNavVisibilityScope
    extends InheritedNotifier<BottomNavVisibilityController> {
  const BottomNavVisibilityScope({
    super.key,
    required BottomNavVisibilityController controller,
    required super.child,
  }) : super(notifier: controller);

  static BottomNavVisibilityController? maybeOf(BuildContext context) {
    return context
        .getInheritedWidgetOfExactType<BottomNavVisibilityScope>()
        ?.notifier;
  }
}

/// Forwards primary vertical scroll updates to [BottomNavVisibilityScope].
/// No-ops when the scope is absent (pushed routes outside the dashboard).
class ScrollHideBottomNav extends StatelessWidget {
  const ScrollHideBottomNav({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final controller = BottomNavVisibilityScope.maybeOf(context);
    if (controller == null) return child;
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        controller.onNotification(notification);
        return false;
      },
      child: child,
    );
  }
}

/// Fade + slight settle of the floating bottom nav. Keeps layout size so
/// [Scaffold.extendBody] padding does not jump.
class FadeSlideBottomNav extends StatefulWidget {
  const FadeSlideBottomNav({
    super.key,
    required this.visible,
    required this.child,
  });

  final bool visible;
  final Widget child;

  static const duration = Duration(milliseconds: 260);
  static const reverseDuration = Duration(milliseconds: 200);

  @override
  State<FadeSlideBottomNav> createState() => _FadeSlideBottomNavState();
}

class _FadeSlideBottomNavState extends State<FadeSlideBottomNav>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: FadeSlideBottomNav.duration,
      reverseDuration: FadeSlideBottomNav.reverseDuration,
      value: widget.visible ? 1 : 0,
    );
    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.28),
      end: Offset.zero,
    ).animate(_fade);
  }

  @override
  void didUpdateWidget(covariant FadeSlideBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visible == widget.visible) return;
    if (widget.visible) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _fade.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: IgnorePointer(
        ignoring: !widget.visible,
        child: ExcludeSemantics(
          excluding: !widget.visible,
          child: SlideTransition(
            position: _slide,
            child: FadeTransition(opacity: _fade, child: widget.child),
          ),
        ),
      ),
    );
  }
}
