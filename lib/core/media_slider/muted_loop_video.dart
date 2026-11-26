import 'package:material_ui/material_ui.dart';
import 'package:video_player/video_player.dart';

import '../consts/api_endpoints.dart';
import 'cache_image.dart';

/// Turns a stored `/uploads/...` path into an absolute URL. Full URLs pass through.
String resolveMediaUrl(String url) {
  final trimmed = url.trim();
  if (trimmed.isEmpty || trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }
  final base = ApiEndpoints.baseUrl.replaceAll(RegExp(r'/+$'), '');
  final origin = base.endsWith('/api') ? base.substring(0, base.length - 4) : base;
  return '$origin${trimmed.startsWith('/') ? trimmed : '/$trimmed'}';
}

/// Card clip. The photo stays underneath, so a failed video never blanks the card.
class MutedLoopVideo extends StatefulWidget {
  const MutedLoopVideo({
    super.key,
    required this.url,
    required this.fallback,
  });

  final String url;
  final Widget fallback;

  @override
  State<MutedLoopVideo> createState() => _MutedLoopVideoState();
}

class _MutedLoopVideoState extends State<MutedLoopVideo> {
  VideoPlayerController? _controller;
  var _ready = false;

  @override
  void initState() {
    super.initState();
    _open();
  }

  @override
  void didUpdateWidget(MutedLoopVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _close();
      _open();
    }
  }

  Future<void> _open() async {
    final resolved = resolveMediaUrl(widget.url);
    if (resolved.isEmpty) return;
    final controller = VideoPlayerController.networkUrl(Uri.parse(resolved));
    _controller = controller;
    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0);
      await controller.play();
      if (!mounted || _controller != controller) {
        await controller.dispose();
        return;
      }
      final size = controller.value.size;
      if (size.width <= 0 || size.height <= 0) {
        await controller.dispose();
        if (mounted) setState(() => _controller = null);
        return;
      }
      setState(() => _ready = true);
    } catch (_) {
      await controller.dispose();
      if (mounted && _controller == controller) {
        setState(() {
          _controller = null;
          _ready = false;
        });
      }
    }
  }

  Future<void> _close() async {
    final controller = _controller;
    _controller = null;
    _ready = false;
    await controller?.dispose();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Stack(
      fit: .expand,
      children: [
        widget.fallback,
        if (_ready && controller != null)
          FittedBox(
            fit: .cover,
            clipBehavior: .hardEdge,
            child: SizedBox(
              width: controller.value.size.width,
              height: controller.value.size.height,
              child: VideoPlayer(controller),
            ),
          ),
      ],
    );
  }
}

/// Detail-carousel clip. Created only for the visible page, released when the page changes.
class ActiveSlideVideo extends StatefulWidget {
  const ActiveSlideVideo({
    super.key,
    required this.url,
    required this.active,
    required this.fallback,
  });

  final String url;
  final bool active;
  final Widget fallback;

  @override
  State<ActiveSlideVideo> createState() => _ActiveSlideVideoState();
}

class _ActiveSlideVideoState extends State<ActiveSlideVideo> {
  VideoPlayerController? _controller;
  var _ready = false;
  var _muted = true;

  @override
  void initState() {
    super.initState();
    if (widget.active) _open();
  }

  @override
  void didUpdateWidget(ActiveSlideVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.url != oldWidget.url) {
      _close();
      if (widget.active) _open();
      return;
    }
    if (widget.active && !oldWidget.active) {
      _open();
    } else if (!widget.active && oldWidget.active) {
      _close();
    }
  }

  Future<void> _open() async {
    if (_controller != null) return;
    final resolved = resolveMediaUrl(widget.url);
    if (resolved.isEmpty) return;
    final controller = VideoPlayerController.networkUrl(Uri.parse(resolved));
    _controller = controller;
    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(_muted ? 0 : 1);
      await controller.play();
      if (!mounted || !widget.active || _controller != controller) {
        await controller.dispose();
        if (_controller == controller) _controller = null;
        return;
      }
      setState(() => _ready = true);
    } catch (_) {
      await controller.dispose();
      if (mounted && _controller == controller) {
        setState(() => _controller = null);
      }
    }
  }

  Future<void> _close() async {
    final controller = _controller;
    _controller = null;
    _ready = false;
    await controller?.dispose();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Stack(
      fit: .expand,
      children: [
        widget.fallback,
        if (_ready && controller != null)
          FittedBox(
            fit: .cover,
            clipBehavior: .hardEdge,
            child: SizedBox(
              width: controller.value.size.width,
              height: controller.value.size.height,
              child: VideoPlayer(controller),
            ),
          ),
        if (_ready)
          Positioned(
            right: 12,
            bottom: 12,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () async {
                  final next = !_muted;
                  await controller?.setVolume(next ? 0 : 1);
                  if (mounted) setState(() => _muted = next);
                },
                icon: Icon(
                  _muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Photo, with the venue's first video played on top when there is one.
class VenueCover extends StatelessWidget {
  const VenueCover({
    super.key,
    required this.imageUrl,
    this.videoUrl = '',
    this.height,
    this.width,
    this.memCacheWidth,
    this.fallback,
  });

  final String imageUrl;
  final String videoUrl;
  final double? height;
  final double? width;
  final int? memCacheWidth;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    final image = CacheImage(
      url: imageUrl,
      height: height,
      width: width,
      memCacheWidth: memCacheWidth,
      errorWidget: fallback,
    );
    if (videoUrl.trim().isEmpty) return image;
    return MutedLoopVideo(url: videoUrl, fallback: image);
  }
}
