import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/services/locator.dart';
import '../../explore/cubit/explore_cubit.dart';
import '../widgets/app_bottom_nav.dart';

class DashboardShell extends StatelessWidget {
  const DashboardShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: AppBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          final leavingExplore =
              navigationShell.currentIndex == AppBottomNav.exploreIndex &&
              index != AppBottomNav.exploreIndex;
          if (leavingExplore) {
            getIt<ExploreCubit>().resetAfterLeave();
          }
          navigationShell.goBranch(index);
        },
      ),
    );
  }
}
