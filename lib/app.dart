import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:upgrader/upgrader.dart';

import 'core/consts/app_strings.dart';
import 'core/deep_link/deep_link_service.dart';
import 'core/router/app_router.dart';
import 'core/services/app_upgrader.dart';
import 'core/services/locator.dart';
import 'core/services/location/location_cubit.dart';
import 'core/services/notification/notification_service.dart';
import 'core/services/session_cubit.dart';
import 'core/services/session_state.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_unfocus.dart';
import 'core/widgets/app_upgrade_alert.dart';
import 'features/explore/cubit/explore_cubit.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late final GoRouter _router = createAppRouter(navigatorKey: _navigatorKey);
  late final Upgrader _upgrader = createAppUpgrader();
  var _bootstrapped = false;

  @override
  void initState() {
    super.initState();
    _bootstrapServices();
  }

  Future<void> _bootstrapServices() async {
    if (_bootstrapped) return;
    _bootstrapped = true;
    await getIt<DeepLinkService>().attach(_router);
    await getIt<NotificationService>().initialize();
  }

  @override
  void dispose() {
    getIt<DeepLinkService>().dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<SessionCubit>()),
        BlocProvider.value(value: getIt<LocationCubit>()),
        BlocProvider.value(value: getIt<ExploreCubit>()),
      ],
      child: BlocListener<SessionCubit, SessionState>(
        listenWhen: (previous, current) =>
            !previous.isAuthenticated && current.isAuthenticated,
        listener: (context, state) {
          getIt<DeepLinkService>().flushPending();
        },
        child: MaterialApp.router(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          routerConfig: _router,
          builder: (context, child) {
            return AppUpgradeAlert(
              upgrader: _upgrader,
              navigatorKey: _navigatorKey,
              child: AppUnfocus(child: child ?? const SizedBox.shrink()),
            );
          },
        ),
      ),
    );
  }
}
