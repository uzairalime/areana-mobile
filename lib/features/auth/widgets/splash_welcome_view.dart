import 'package:material_ui/material_ui.dart';
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

class SplashWelcomeView extends StatelessWidget {
  const SplashWelcomeView({super.key});

  static const _buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusMd)),
  );

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _Header()),
                _Actions(),
                SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
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
          Text(
            AppStrings.bookYourCourt,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyLarge?.copyWith(
              color: const Color(0xD9FFFFFF),
              fontWeight: FontWeight.w500,
              height: 1.5,
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

class _Actions extends StatelessWidget {
  const _Actions();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PrimaryButton(
            label: AppStrings.getStarted,
            shape: SplashWelcomeView._buttonShape,
            onPressed: () {
              AppHaptics.medium();
              context.push(AppRoutes.signup);
            },
          ),
          const SizedBox(height: 10),
          PrimaryOutlineButton(
            label: AppStrings.alreadyHaveAccount,
            shape: SplashWelcomeView._buttonShape,
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
            label: const Text(AppStrings.continueAsGuest),
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
          fontWeight: FontWeight.w700,
        ),
      ).paddingSymmetric(horizontal: 12, vertical: 6),
    );
  }
}
