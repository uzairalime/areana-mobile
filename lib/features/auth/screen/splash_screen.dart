import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/consts/app_strings.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/widgets/pitchside_mark.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/primary_outline_button.dart';
import '../cubit/splash_cubit.dart';

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
        body: Stack(
          children: [
            const Positioned.fill(child: CustomPaint(painter: _CourtPainter())),
            const SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      children: [
                        Expanded(child: _SplashHeader()),
                        _SplashActions(),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).annotatedRegion(.light),
    );
  }
}

class _SplashHeader extends StatelessWidget {
  const _SplashHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const PitchsideMark(
            size: 96,
            radius: 28,
            shadows: [
              BoxShadow(
                color: Color(0x47000000),
                blurRadius: 40,
                offset: Offset(0, 20),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            AppStrings.appName,
            textAlign: TextAlign.center,
            style: context.textTheme.displayLarge?.copyWith(
              color: AppColors.onPrimary,
              fontSize: 40,
              letterSpacing: -1.2,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Book your court. Pay at the ground.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyLarge?.copyWith(
                color: const Color(0xD9FFFFFF),
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _SportChip(label: 'Padel'),
              _SportChip(label: 'Football'),
              _SportChip(label: 'Indoor Cricket'),
            ],
          ),
        ],
      ),
    );
  }
}

class _SplashActions extends StatelessWidget {
  const _SplashActions();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SplashCubit, SplashState, bool>(
      selector: (state) => state.destination == SplashDestination.loading,
      builder: (context, isLoading) {
        if (isLoading) {
          return const SizedBox(
            height: 120,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
          );
        }
        return const _WelcomeActions();
      },
    );
  }
}

class _WelcomeActions extends StatelessWidget {
  const _WelcomeActions();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PrimaryButton(
            label: 'Get started',
            onPressed: () {
              AppHaptics.medium();
              context.push(AppRoutes.signup);
            },
          ),
          const SizedBox(height: 10),
          PrimaryOutlineButton(
            label: 'I already have an account',
            onPressed: () {
              AppHaptics.selection();
              context.push(AppRoutes.login);
            },
          ),
          TextButton.icon(
            onPressed: () {
              AppHaptics.selection();
              context.go(AppRoutes.home);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accent,
              minimumSize: const Size(0, 48),
              textStyle: context.textTheme.titleSmall?.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            iconAlignment: IconAlignment.end,
            icon: const Icon(Icons.arrow_forward, size: 18),
            label: const Text('Continue as guest'),
          ),
        ],
      ),
    );
  }
}

class _SportChip extends StatelessWidget {
  const _SportChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0x1AFFFFFF),
        borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusPill)),
      ),
      child: Text(
        label,
        style: context.textTheme.labelMedium?.copyWith(
          color: AppColors.onPrimary,
        ),
      ).paddingSymmetric(horizontal: 12, vertical: 6),
    );
  }
}

class _CourtPainter extends CustomPainter {
  const _CourtPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.16)
      ..style = .stroke
      ..strokeWidth = 2;
    final center = Offset(size.width / 2, size.height * 0.39);
    canvas.drawCircle(center, 150, paint);
    canvas.drawCircle(center, 96, paint);
    canvas.drawCircle(
      center,
      46,
      Paint()..color = AppColors.accent.withValues(alpha: 0.1),
    );
    canvas.drawLine(
      Offset(-20, center.dy),
      Offset(size.width + 20, center.dy),
      paint,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - 220),
        width: 200,
        height: 130,
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + 210),
        width: 200,
        height: 130,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
