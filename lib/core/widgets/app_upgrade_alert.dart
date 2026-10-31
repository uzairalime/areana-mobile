import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';

import '../consts/app_colors.dart';
import '../consts/app_sizes.dart';
import '../extensions/extensions.dart';
import '../utils/app_haptics.dart';
import 'app_button.dart';

/// Store-update prompt styled to match Pitchside dialogs.
class AppUpgradeAlert extends UpgradeAlert {
  AppUpgradeAlert({
    super.key,
    super.upgrader,
    super.child,
    super.navigatorKey,
    super.barrierDismissible = false,
    super.showIgnore = false,
    super.showLater = true,
    super.showPrompt = true,
    super.showReleaseNotes = true,
  });

  @override
  UpgradeAlertState createState() => _AppUpgradeAlertState();
}

class _AppUpgradeAlertState extends UpgradeAlertState {
  @override
  Widget alertDialog(
    Key? key,
    String title,
    String message,
    String? releaseNotes,
    BuildContext context,
    bool cupertino,
    UpgraderMessages messages,
  ) {
    final isBlocked = widget.upgrader.blocked();
    final showIgnore = isBlocked ? false : widget.showIgnore;
    final showLater = isBlocked ? false : widget.showLater;
    final notesLabel = messages.message(UpgraderMessage.releaseNotes) ?? '';
    final prompt = messages.message(UpgraderMessage.prompt) ?? '';
    final updateLabel =
        messages.message(UpgraderMessage.buttonTitleUpdate) ?? 'Update now';
    final laterLabel =
        messages.message(UpgraderMessage.buttonTitleLater) ?? 'Not now';
    final ignoreLabel =
        messages.message(UpgraderMessage.buttonTitleIgnore) ?? 'Skip';

    return Dialog(
      key: key,
      backgroundColor: AppColors.surface,
      surfaceTintColor: AppColors.surface,
      insetPadding: const .symmetric(horizontal: 28, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 520),
        child: Padding(
          padding: const .fromLTRB(22, 26, 22, 18),
          child: Column(
            mainAxisSize: .min,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: .circle,
                ),
                child: const Padding(
                  padding: .all(14),
                  child: Icon(
                    Icons.system_update_alt_rounded,
                    size: 28,
                    color: AppColors.primary,
                  ),
                ),
              ),
              18.h,
              Text(
                title,
                key: const Key('upgrader.dialog.title'),
                textAlign: .center,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: .w800,
                  letterSpacing: -0.2,
                ),
              ),
              10.h,
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: .min,
                    children: [
                      Text(
                        message,
                        textAlign: .center,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                      if (widget.showPrompt && prompt.isNotEmpty) ...[
                        12.h,
                        Text(
                          prompt,
                          textAlign: .center,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textBody,
                            height: 1.4,
                            fontWeight: .w600,
                          ),
                        ),
                      ],
                      if (releaseNotes != null && releaseNotes.isNotEmpty) ...[
                        16.h,
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMd,
                            ),
                            border: Border.all(color: AppColors.outline),
                          ),
                          child: Padding(
                            padding: const .fromLTRB(14, 12, 14, 12),
                            child: Column(
                              crossAxisAlignment: .start,
                              children: [
                                Text(
                                  notesLabel,
                                  style: context.textTheme.labelLarge?.copyWith(
                                    fontWeight: .w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                                6.h,
                                Text(
                                  releaseNotes,
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: AppColors.textBody,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              22.h,
              AppButton(
                label: updateLabel,
                showArrow: false,
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.onAccent,
                onPressed: () {
                  AppHaptics.medium();
                  onUserUpdated(context, !isBlocked);
                },
              ),
              if (showLater) ...[
                6.h,
                SizedBox(
                  width: double.infinity,
                  height: AppSizes.buttonHeight - 8,
                  child: TextButton(
                    onPressed: () {
                      AppHaptics.light();
                      onUserLater(context, true);
                    },
                    child: Text(
                      laterLabel,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: .w700,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                ),
              ],
              if (showIgnore) ...[
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: TextButton(
                    onPressed: () => onUserIgnored(context, true),
                    child: Text(
                      ignoreLabel,
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: .w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
