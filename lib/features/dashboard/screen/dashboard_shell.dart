import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/services/locator.dart';
import '../../../core/services/session_store.dart';
import '../../../core/widgets/scroll_hide_bottom_nav.dart';
import '../../bookings/cubit/bookings_cubit.dart';
import '../../conversations/cubit/conversations_cubit.dart';
import '../../explore/cubit/explore_cubit.dart';
import '../../home/cubit/home_cubit.dart';
import '../../notifications/cubit/notifications_cubit.dart';
import '../../profile/cubit/profile_cubit.dart';
import '../widgets/app_bottom_nav.dart';

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  final _navVisibility = BottomNavVisibilityController();

  @override
  void initState() {
    super.initState();
    if (getIt<SessionStore>().isAuthenticated) {
      getIt<ProfileCubit>().ensureLoaded();
    }
  }

  @override
  void dispose() {
    _navVisibility.dispose();
    super.dispose();
  }

  StatefulNavigationShell get navigationShell => widget.navigationShell;

  void _onNavTap(int index) {
    _navVisibility.show();
    final current = navigationShell.currentIndex;
    final retap = index == current;
    if (!retap &&
        current == AppBottomNav.exploreIndex &&
        index != AppBottomNav.exploreIndex) {
      getIt<ExploreCubit>().resetAfterLeave();
    }
    navigationShell.goBranch(index, initialLocation: retap);
    final signedIn = getIt<SessionStore>().isAuthenticated;
    if (retap) {
      if (index == AppBottomNav.homeIndex) {
        getIt<HomeCubit>().refresh();
      } else if (index == AppBottomNav.bookingsIndex && signedIn) {
        getIt<BookingsCubit>().refresh();
      } else if (index == AppBottomNav.exploreIndex) {
        getIt<ExploreCubit>().refresh();
      }
    } else {
      if (index == AppBottomNav.bookingsIndex && signedIn) {
        getIt<BookingsCubit>().refresh();
      }
      if (index == AppBottomNav.chatsIndex && signedIn) {
        getIt<ConversationsCubit>().refresh();
      }
    }
    if (signedIn &&
        (index == AppBottomNav.homeIndex ||
            index == AppBottomNav.bookingsIndex)) {
      getIt<NotificationsCubit>().refreshUnread();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavVisibilityScope(
      controller: _navVisibility,
      child: Scaffold(
        backgroundColor: AppColors.background,
        extendBody: true,
        body: navigationShell,
        bottomNavigationBar: ListenableBuilder(
          listenable: _navVisibility,
          child: AppBottomNav(
            currentIndex: navigationShell.currentIndex,
            onTap: _onNavTap,
          ),
          builder: (context, child) {
            return FadeSlideBottomNav(
              visible: _navVisibility.visible,
              child: child!,
            );
          },
        ),
      ),
    );
  }
}
