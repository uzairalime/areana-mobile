import 'package:flutter/widgets.dart';

import '../widgets/app_shimmer.dart';

extension ShimmerWidgetX on Widget {
  Widget shimmer({
    bool enabled = true,
    Duration period = const Duration(milliseconds: 1400),
  }) {
    return AppShimmer(enabled: enabled, period: period, child: this);
  }
}
