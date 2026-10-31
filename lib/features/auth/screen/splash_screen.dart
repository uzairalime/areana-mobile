import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_sizes.dart';
import '../../../core/consts/app_strings.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/widgets/pitchside_mark.dart';
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
            Column(
              children: [
                Column(
                  mainAxisAlignment: .center,
                  crossAxisAlignment: .center,
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
                    18.h,
                    Text(
                      AppStrings.appName,
                      style: context.textTheme.displayLarge?.copyWith(
                        color: AppColors.onPrimary,
                        fontSize: 40,
                        letterSpacing: -1.2,
                      ),
                    ),
                    8.h,
                    Text(
                      'Book your court. Pay at the ground.',
                      textAlign: .center,
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: const Color(0xD9FFFFFF),
                        fontWeight: .w500,
                        height: 1.5,
                      ),
                    ).paddingSymmetric(horizontal: 32),
                    16.h,
                    const Row(
                      mainAxisAlignment: .center,
                      children: [
                        _SportChip(label: 'Padel'),
                        SizedBox(width: 8),
                        _SportChip(label: 'Football'),
                        SizedBox(width: 8),
                        _SportChip(label: 'Indoor Cricket'),
                      ],
                    ),
                  ],
                ).expand(),
                BlocBuilder<SplashCubit, SplashState>(
                  builder: (context, state) {
                    if (state.destination == SplashDestination.loading) {
                      return const SizedBox(
                        height: 120,
                        child: CircularProgressIndicator(
                          color: AppColors.accent,
                        ),
                      ).center();
                    }
                    return Column(
                      children: [
                        FilledButton(
                          onPressed: () {
                            AppHaptics.medium();
                            context.push(AppRoutes.signup);
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: AppColors.text,
                            minimumSize: const Size.fromHeight(
                              AppSizes.buttonHeight,
                            ),
                            shape: const StadiumBorder(),
                          ),
                          child: Row(
                            mainAxisAlignment: .center,
                            children: [
                              Text(
                                'Get started',
                                style: context.textTheme.titleMedium?.copyWith(
                                  color: AppColors.text,
                                  fontSize: 16,
                                  fontWeight: .w800,
                                ),
                              ),
                              8.w,
                              const Icon(
                                Icons.arrow_forward,
                                size: 18,
                                color: AppColors.text,
                              ),
                            ],
                          ),
                        ),
                        10.h,
                        OutlinedButton(
                          onPressed: () {
                            AppHaptics.selection();
                            context.push(AppRoutes.login);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.onPrimary,
                            minimumSize: const Size.fromHeight(
                              AppSizes.buttonHeight,
                            ),
                            side: const BorderSide(
                              color: Color(0x66FFFFFF),
                              width: 1.5,
                            ),
                            shape: const StadiumBorder(),
                          ),
                          child: Text(
                            'I already have an account',
                            style: context.textTheme.titleSmall?.copyWith(
                              color: AppColors.onPrimary,
                              fontSize: 16,
                              fontWeight: .w700,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 48,
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: .center,
                            children: [
                              Text(
                                'Continue as guest',
                                style: context.textTheme.titleSmall?.copyWith(
                                  color: AppColors.accent,
                                  fontSize: 15,
                                  fontWeight: .w800,
                                ),
                              ),
                              8.w,
                              const Icon(
                                Icons.arrow_forward,
                                size: 18,
                                color: AppColors.accent,
                              ),
                            ],
                          ),
                        ).onTap(() {
                          AppHaptics.selection();
                          context.go(AppRoutes.home);
                        }),
                      ],
                    ).paddingOnly(left: 24, right: 24, bottom: 16);
                  },
                ),
                const SizedBox(height: 16),
              ],
            ).safeArea(),
          ],
        ),
      ).annotatedRegion(.light),
    );
  }
}

class _SportChip extends StatelessWidget {
  const _SportChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
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
