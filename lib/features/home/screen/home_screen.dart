import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/session_cubit.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/widgets/app_custom_app_bar.dart';
import '../widgets/home_body.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _onAvatarTap(BuildContext context) {
    final session = context.read<SessionCubit>().state;
    if (!session.isAuthenticated) {
      context.push(AppRoutes.login);
      return;
    }
    context.go(AppRoutes.account);
  }

  void _onMessages(BuildContext context) {
    final session = context.read<SessionCubit>().state;
    if (!session.isAuthenticated) {
      context.push(AppRoutes.login);
      return;
    }
    AppHaptics.selection();
    context.go(AppRoutes.messages);
  }

  void _onNotifications(BuildContext context) {
    AppHaptics.selection();
    context.push(AppRoutes.notifications);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppCustomAppBar(
        onAvatarTap: () => _onAvatarTap(context),
        onMessages: () => _onMessages(context),
        onNotifications: () => _onNotifications(context),
      ),
      body: const HomeBody(),
    ).annotatedRegion(.dark);
  }
}
