import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

extension WidgetPaddingX on Widget {
  Widget paddingAll(double value) {
    return Padding(padding: EdgeInsets.all(value), child: this);
  }

  Widget paddingSymmetric({double horizontal = 0, double vertical = 0}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      child: this,
    );
  }

  Widget paddingOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        left: left,
        top: top,
        right: right,
        bottom: bottom,
      ),
      child: this,
    );
  }
}

extension WidgetFlexX on Widget {
  Widget expand({int flex = 1}) {
    return Expanded(flex: flex, child: this);
  }

  Widget flexible({int flex = 1, FlexFit fit = .loose}) {
    return Flexible(flex: flex, fit: fit, child: this);
  }
}

extension WidgetTapX on Widget {
  Widget onTap(VoidCallback? action) {
    return GestureDetector(onTap: action, behavior: .opaque, child: this);
  }
}

extension WidgetSafeAreaX on Widget {
  Widget safeArea({
    bool top = true,
    bool bottom = true,
    bool left = true,
    bool right = true,
    EdgeInsets minimum = EdgeInsets.zero,
  }) {
    return SafeArea(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      minimum: minimum,
      child: this,
    );
  }
}

extension WidgetAnnotatedRegionX on Widget {
  Widget annotatedRegion(SystemUiOverlayStyle style) {
    return AnnotatedRegion<SystemUiOverlayStyle>(value: style, child: this);
  }
}

extension WidgetAlignX on Widget {
  Widget align({
    Alignment alignment = .center,
    double? widthFactor,
    double? heightFactor,
  }) {
    return Align(
      alignment: alignment,
      widthFactor: widthFactor,
      heightFactor: heightFactor,
      child: this,
    );
  }

  Widget center({double? widthFactor, double? heightFactor}) {
    return Center(
      widthFactor: widthFactor,
      heightFactor: heightFactor,
      child: this,
    );
  }
}
