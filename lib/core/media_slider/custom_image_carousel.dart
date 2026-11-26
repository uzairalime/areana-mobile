import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';

import '../extensions/extensions.dart';
import '../utils/app_haptics.dart';
import 'cache_image.dart';
import 'muted_loop_video.dart';

class MediaSlide {
  const MediaSlide({required this.url, required this.isVideo});

  final String url;
  final bool isVideo;
}

/// ReelStay-style image carousel: preload, index badge, fullscreen on tap.
class CustomImageCarousel extends StatefulWidget {
  const CustomImageCarousel({
    super.key,
    required this.urls,
    this.videoUrls = const [],
    this.height = 320,
    this.radius,
    this.showActions = true,
    this.onBack,
    this.fallback,
    this.heroTagPrefix = 'media',
  });

  final List<String> urls;
  /// Played before [urls]. Never passed to the image cache.
  final List<String> videoUrls;
  final double height;
  final BorderRadius? radius;
  final bool showActions;
  final VoidCallback? onBack;
  final Widget? fallback;
  final String heroTagPrefix;

  @override
  State<CustomImageCarousel> createState() => _CustomImageCarouselState();
}

class _CustomImageCarouselState extends State<CustomImageCarousel> {
  final _currentIndex = ValueNotifier<int>(0);
  static const _preloadCount = 3;

  List<MediaSlide> get _slides {
    final videos = widget.videoUrls
        .where((u) => u.trim().isNotEmpty)
        .map((u) => MediaSlide(url: u.trim(), isVideo: true));
    final images = widget.urls
        .where((u) => u.trim().isNotEmpty)
        .map((u) => MediaSlide(url: u.trim(), isVideo: false));
    return [...videos, ...images];
  }

  int get _total {
    if (_slides.isNotEmpty) return _slides.length;
    return widget.fallback == null ? 0 : 1;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _preloadImages(1);
    });
  }

  @override
  void dispose() {
    _currentIndex.dispose();
    super.dispose();
  }

  void _preloadImages(int fromIndex) {
    final items = _slides;
    if (items.isEmpty) return;
    final end = (fromIndex + _preloadCount).clamp(0, items.length);
    for (var i = fromIndex; i < end; i++) {
      if (items[i].isVideo) continue;
      precacheImage(
        CachedNetworkImageProvider(items[i].url),
        context,
        onError: (_, _) {},
      );
    }
  }

  void _openFullscreen(int index) {
    if (_slides.isEmpty) return;
    AppHaptics.selection();
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierDismissible: true,
        pageBuilder: (_, _, _) => MediaSlideView(
          slides: _slides,
          initialIndex: index,
          heroTagPrefix: widget.heroTagPrefix,
          fallback: widget.fallback,
        ),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.radius;
    final total = _total;
    if (total == 0) return SizedBox(height: widget.height);

    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cacheWidth = (context.screenSize.width * dpr).round();
    final posterUrl = widget.urls.cast<String?>().firstWhere(
      (url) => url != null && url.trim().isNotEmpty,
      orElse: () => '',
    );

    Widget body = SizedBox(
      height: widget.height,
      width: double.infinity,
      child: Stack(
        fit: .expand,
        children: [
          if (_slides.isEmpty)
            widget.fallback!
          else
            PageView.builder(
              itemCount: _slides.length,
              onPageChanged: (index) {
                _currentIndex.value = index;
                _preloadImages(index + 1);
                setState(() {});
              },
              itemBuilder: (context, index) {
                final slide = _slides[index];
                if (slide.isVideo) {
                  return ActiveSlideVideo(
                    url: slide.url,
                    active: _currentIndex.value == index,
                    fallback: CacheImage(
                      url: posterUrl ?? '',
                      height: widget.height,
                      width: double.infinity,
                      memCacheWidth: cacheWidth,
                      errorWidget: widget.fallback,
                    ),
                  );
                }
                final tag = '${widget.heroTagPrefix}-$index';
                return Hero(
                  tag: tag,
                  child: Material(
                    type: .transparency,
                    child: CacheImage(
                      url: slide.url,
                      height: widget.height,
                      width: double.infinity,
                      memCacheWidth: cacheWidth,
                      errorWidget: widget.fallback,
                    ).onTap(() => _openFullscreen(index)),
                  ),
                );
              },
            ),
          if (widget.showActions)
            Positioned(
              top: 0,
              left: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const .only(left: 15, top: 8),
                  child:
                      DecoratedBox(
                        decoration: const BoxDecoration(
                          color: Colors.black45,
                          shape: .circle,
                        ),
                        child: const Padding(
                          padding: .all(10),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ).onTap(() {
                        AppHaptics.selection();
                        if (widget.onBack != null) {
                          widget.onBack!();
                        } else if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                      }),
                ),
              ),
            ),
          if (total > 1)
            Positioned(
              bottom: 15,
              right: 15,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const .symmetric(horizontal: 10, vertical: 4),
                  child: ValueListenableBuilder<int>(
                    valueListenable: _currentIndex,
                    builder: (_, currentIndex, _) => Text(
                      '${currentIndex + 1}/$total',
                      style: context.textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: .w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    if (radius != null) {
      body = ClipRRect(borderRadius: radius, child: body);
    }
    return body;
  }
}

/// Fullscreen image gallery (ReelStay [MediaSlideView] image path).
class MediaSlideView extends StatefulWidget {
  const MediaSlideView({
    super.key,
    required this.slides,
    required this.initialIndex,
    this.heroTagPrefix = 'media',
    this.fallback,
  });

  final List<MediaSlide> slides;
  final int initialIndex;
  final String heroTagPrefix;
  final Widget? fallback;

  @override
  State<MediaSlideView> createState() => _MediaSlideViewState();
}

class _MediaSlideViewState extends State<MediaSlideView> {
  late final PageController _pageController;
  late final ValueNotifier<int> _currentIndex;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _currentIndex = ValueNotifier(widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.slides.length;
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.92),
      body: Stack(
        fit: .expand,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: total,
            onPageChanged: (i) {
              _currentIndex.value = i;
              setState(() {});
            },
            itemBuilder: (context, index) {
              final slide = widget.slides[index];
              if (slide.isVideo) {
                return ActiveSlideVideo(
                  url: slide.url,
                  active: _currentIndex.value == index,
                  fallback: widget.fallback ??
                      const ColoredBox(color: Colors.black),
                );
              }
              final tag = '${widget.heroTagPrefix}-$index';
              return InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Hero(
                  tag: tag,
                  child: CacheImage(
                    url: slide.url,
                    height: double.infinity,
                    width: double.infinity,
                    fit: .contain,
                  ),
                ).center(),
              );
            },
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 10,
            left: 10,
            right: 10,
            child: Row(
              children: [
                DecoratedBox(
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: .circle,
                  ),
                  child: const Padding(
                    padding: .all(10),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ).onTap(() {
                  AppHaptics.selection();
                  Navigator.of(context).pop();
                }),
                const Spacer(),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const .symmetric(horizontal: 12, vertical: 6),
                    child: ValueListenableBuilder<int>(
                      valueListenable: _currentIndex,
                      builder: (_, value, _) {
                        final invalid = value < 0 || total == 0;
                        return Text(
                          invalid ? '0 / 0' : '${value + 1} / $total',
                          style: context.textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: .w700,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 40),
              ],
            ),
          ),
        ],
      ),
    ).annotatedRegion(.light);
  }
}
