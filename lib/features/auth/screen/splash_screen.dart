import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/router/app_router.dart';
import '../cubit/splash_cubit.dart';
import '../model/splash_court_layout.dart';
import '../widgets/splash_court_art.dart';
import '../widgets/splash_launch_view.dart';
import '../widgets/splash_welcome_view.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listenWhen: (previous, current) =>
          previous.destination != current.destination &&
          current.destination == SplashDestination.home,
      listener: (context, state) => context.go(AppRoutes.home),
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: BlocSelector<SplashCubit, SplashState, SplashDestination>(
          selector: (state) => state.destination,
          builder: (context, destination) {
            final isLaunch = destination == SplashDestination.launch;
            return Stack(
              alignment: Alignment.center,
              fit: StackFit.expand,
              children: [
                SplashCourtArt(
                  layout: isLaunch
                      ? SplashCourtLayout.launch
                      : SplashCourtLayout.welcome,
                ),
                if (isLaunch)
                  SplashLaunchView(
                    key: const Key('splash-launch'),
                    onSkip: () {
                      context.read<SplashCubit>().advanceFromLaunch();
                    },
                  )
                else
                  const SplashWelcomeView(key: Key('splash-welcome')),
              ],
            );
          },
        ),
      ).annotatedRegion(.light),
    );
  }
}
