import 'package:material_ui/material_ui.dart';

/// Requests a visible next page after layout, once for each page/cursor.
class PaginationLoader extends StatefulWidget {
  const PaginationLoader({
    super.key,
    required this.pageKey,
    required this.onLoadMore,
    this.enabled = true,
  });

  final Object? pageKey;
  final VoidCallback onLoadMore;
  final bool enabled;

  @override
  State<PaginationLoader> createState() => _PaginationLoaderState();
}

class _PaginationLoaderState extends State<PaginationLoader> {
  bool _scheduled = false;
  bool _requested = false;

  @override
  void initState() {
    super.initState();
    _scheduleRequest();
  }

  @override
  void didUpdateWidget(covariant PaginationLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageKey != widget.pageKey) _requested = false;
    _scheduleRequest();
  }

  void _scheduleRequest() {
    if (_scheduled || _requested || !widget.enabled) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      if (!mounted || _requested || !widget.enabled) return;
      _requested = true;
      widget.onLoadMore();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
