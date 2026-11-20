import 'package:material_ui/material_ui.dart';

import '../../../core/consts/app_colors.dart';
import '../../../core/consts/app_strings.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/widgets/pitchside_mark.dart';

class SplashLaunchView extends StatefulWidget {
  const SplashLaunchView({super.key, this.onSkip});

  final VoidCallback? onSkip;

  @override
  State<SplashLaunchView> createState() => _SplashLaunchViewState();
}

class _SplashLaunchViewState extends State<SplashLaunchView>
    with SingleTickerProviderStateMixin {
  static const _hold = Duration(milliseconds: 2400);

  late final AnimationController _motion;

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(vsync: this, duration: _hold);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.disableAnimationsOf(context);
    if (reduce) {
      _motion.value = 0.6;
    } else if (!_motion.isAnimating) {
      _motion.repeat();
    }
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: widget.onSkip != null,
      label: 'Continue to welcome screen',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onSkip,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _PulseMark(animation: _motion),
                    const SizedBox(height: 22),
                    Text(
                      AppStrings.appName,
                      textAlign: TextAlign.center,
                      style: context.textTheme.displayLarge?.copyWith(
                        color: AppColors.onPrimary,
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.47,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AppStrings.gameOn,
                      textAlign: TextAlign.center,
                      style: context.textTheme.titleSmall?.copyWith(
                        color: AppColors.accent,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 64),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _LaunchBar(animation: _motion),
                    const SizedBox(height: 14),
                    Text(
                      AppStrings.gettingCourtsReady,
                      textAlign: TextAlign.center,
                      style: context.textTheme.labelLarge?.copyWith(
                        color: const Color(0xD1FFFFFF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulseMark extends StatelessWidget {
  const _PulseMark({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      height: 112,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final t = animation.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: 1 + (t * 0.7),
                child: Opacity(
                  opacity: (0.55 * (1 - t)).clamp(0, 1),
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.all(Radius.circular(32)),
                    ),
                    child: SizedBox.expand(),
                  ),
                ),
              ),
              child!,
            ],
          );
        },
        child: const PitchsideMark(
          size: 112,
          radius: 32,
          shadows: [
            BoxShadow(
              color: Color(0x4D000000),
              blurRadius: 48,
              offset: Offset(0, 24),
            ),
          ],
        ),
      ),
    );
  }
}

class _LaunchBar extends StatelessWidget {
  const _LaunchBar({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return SizedBox(
          key: const Key('splash-launch-progress'),
          width: 120,
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(999)),
            child: LinearProgressIndicator(
              value: animation.value.clamp(0, 1),
              minHeight: 4,
              backgroundColor: const Color(0x2EFFFFFF),
              color: AppColors.accent,
            ),
          ),
        );
      },
    );
  }
}
