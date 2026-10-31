import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';
import '../services/locator.dart';
import '../../features/profile/cubit/profile_repository.dart';

abstract final class AuthNavigation {
  static String? nextOf(BuildContext context) {
    return GoRouterState.of(context).uri.queryParameters['next'];
  }

  /// After access_token is stored: refresh profile, then route to home/checkout.
  static void afterAuthSuccess(BuildContext context, {String? next}) {
    getIt<ProfileRepository>().fetchOverview();
    final target = next ?? nextOf(context);
    switch (target) {
      case 'checkout':
        context.go(AppRoutes.checkout);
      case 'home':
        context.go(AppRoutes.home);
      default:
        context.go(AppRoutes.home);
    }
  }
}
