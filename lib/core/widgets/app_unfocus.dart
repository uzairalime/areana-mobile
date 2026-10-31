import 'package:flutter/material.dart';

class AppUnfocus extends StatelessWidget {
  const AppUnfocus({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: .translucent,
      onPointerDown: _unfocusOutside,
      child: child,
    );
  }

  void _unfocusOutside(PointerDownEvent event) {
    final focus = FocusManager.instance.primaryFocus;
    if (focus == null || !focus.hasFocus) {
      return;
    }
    final box = focus.context?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) {
      focus.unfocus();
      return;
    }
    final bounds = box.localToGlobal(Offset.zero) & box.size;
    if (!bounds.contains(event.position)) {
      focus.unfocus();
    }
  }
}
