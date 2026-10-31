import 'package:flutter/material.dart';

import '../consts/app_colors.dart';
import '../extensions/extensions.dart';
import '../utils/app_haptics.dart';

/// Sliding pill tabs adapted from ReelStay `BuildLabels`.
class BuildLabels<T> extends StatefulWidget {
  const BuildLabels({
    super.key,
    required this.labels,
    required this.label,
    required this.onChange,
    this.textOf,
    this.expanded = false,
    this.disabled = false,
    this.inline = false,
    this.padding = EdgeInsets.zero,
    this.itemHorizontalPadding,
  });

  final List<T> labels;
  final T label;
  final void Function(T label) onChange;
  final String Function(T value)? textOf;
  final bool expanded;
  final bool disabled;
  final bool inline;
  final EdgeInsets padding;
  final double? itemHorizontalPadding;

  @override
  State<BuildLabels<T>> createState() => _BuildLabelsState<T>();
}

class _BuildLabelsState<T> extends State<BuildLabels<T>> {
  static const _animationDuration = Duration(milliseconds: 300);

  late final ScrollController _scrollController;
  late List<GlobalKey> _keys;
  final _stackKey = GlobalKey();

  bool _indicatorReady = false;
  double _indicatorWidth = 0;
  double _indicatorLeft = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _updateKeys();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateIndicator();
      _scrollToActive(animate: false);
    });
  }

  @override
  void didUpdateWidget(covariant BuildLabels<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final labelsChanged = oldWidget.labels.length != widget.labels.length;
    final selectionChanged = oldWidget.label != widget.label;
    final layoutChanged = oldWidget.padding != widget.padding;

    if (labelsChanged) {
      _updateKeys();
      _indicatorReady = false;
    }
    if (selectionChanged) {
      _scrollToActive();
    }
    if (labelsChanged || selectionChanged || layoutChanged) {
      _scheduleIndicatorUpdate();
    }
  }

  void _updateKeys() {
    _keys = List.generate(widget.labels.length, (_) => GlobalKey());
  }

  void _scheduleIndicatorUpdate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _updateIndicator();
    });
  }

  void _updateIndicator() {
    final index = widget.labels.indexOf(widget.label);
    if (index == -1) return;

    final tabContext = _keys[index].currentContext;
    final stackContext = _stackKey.currentContext;
    if (tabContext == null || stackContext == null) return;

    final tabBox = tabContext.findRenderObject() as RenderBox?;
    final stackBox = stackContext.findRenderObject() as RenderBox?;
    if (tabBox == null || stackBox == null || !tabBox.hasSize) return;

    final stackOrigin = stackBox.localToGlobal(Offset.zero);
    final tabOrigin = tabBox.localToGlobal(Offset.zero);
    final left = tabOrigin.dx - stackOrigin.dx;
    final width = tabBox.size.width;

    if (left == _indicatorLeft && width == _indicatorWidth && _indicatorReady) {
      return;
    }

    setState(() {
      _indicatorWidth = width;
      _indicatorReady = true;
      _indicatorLeft = left;
    });
  }

  void _scrollToActive({bool animate = true}) {
    if (widget.expanded || !_scrollController.hasClients) return;

    final index = widget.labels.indexOf(widget.label);
    if (index == -1) return;

    final tabContext = _keys[index].currentContext;
    if (tabContext == null) return;

    final scrollable = Scrollable.maybeOf(tabContext);
    if (scrollable == null) return;
    if (!identical(scrollable.position, _scrollController.position)) return;

    final renderObject = tabContext.findRenderObject();
    if (renderObject == null) return;

    scrollable.position.ensureVisible(
      renderObject,
      duration: animate ? _animationDuration : Duration.zero,
      curve: Curves.easeInOut,
      alignment: 0.5,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _titleFor(T value) {
    final custom = widget.textOf?.call(value);
    if (custom != null) return custom;
    if (value is Enum) {
      final name = value.name;
      if (name.isEmpty) return name;
      return '${name[0].toUpperCase()}${name.substring(1)}';
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(30);

    final content = DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: radius,
        border: Border.all(color: AppColors.outline),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.06),
            offset: const Offset(0, 1),
            spreadRadius: 1,
            blurRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const .all(4),
        child: LayoutBuilder(
          builder: (context, _) {
            if (_indicatorReady) {
              _scheduleIndicatorUpdate();
            }
            return Stack(
              key: _stackKey,
              clipBehavior: .none,
              children: [
                if (_indicatorReady)
                  AnimatedPositioned(
                    duration: _animationDuration,
                    curve: Curves.easeInOut,
                    width: _indicatorWidth,
                    left: _indicatorLeft,
                    bottom: 0,
                    top: 0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                Row(
                  mainAxisSize: widget.expanded ? .max : .min,
                  children: List.generate(widget.labels.length, (idx) {
                    final value = widget.labels[idx];
                    final active = widget.label == value;
                    final tab = _TabButton(
                      key: _keys[idx],
                      title: _titleFor(value),
                      isSelected: active,
                      horizontalPadding: widget.itemHorizontalPadding,
                      onTap: widget.disabled
                          ? null
                          : () {
                              AppHaptics.light();
                              widget.onChange(value);
                            },
                    );
                    return widget.expanded ? tab.expand() : tab;
                  }),
                ),
              ],
            );
          },
        ),
      ),
    );

    if (widget.expanded || widget.inline) {
      return Padding(padding: widget.padding, child: content);
    }

    return SingleChildScrollView(
      scrollDirection: .horizontal,
      controller: _scrollController,
      clipBehavior: .none,
      padding: widget.padding,
      child: content,
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    super.key,
    required this.title,
    required this.isSelected,
    this.horizontalPadding,
    this.onTap,
  });

  final String title;
  final bool isSelected;
  final double? horizontalPadding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: .opaque,
      child: Padding(
        padding: .symmetric(
          horizontal: horizontalPadding ?? 20,
          vertical: 10,
        ),
        child: Text(
          title,
          maxLines: 1,
          overflow: .visible,
          textAlign: .center,
          style: context.textTheme.labelLarge?.copyWith(
            color: isSelected ? AppColors.accent : AppColors.textSecondary,
            fontWeight: isSelected ? .w700 : .w500,
            fontSize: 14,
          ),
        ).center(),
      ),
    );
  }
}
