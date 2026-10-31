import 'package:flutter/foundation.dart';
import 'package:upgrader/upgrader.dart';

/// Pitchside copy for store update prompts.
class PitchsideUpgraderMessages extends UpgraderMessages {
  PitchsideUpgraderMessages({super.code, super.context});

  @override
  String get title => 'Update available';

  @override
  String get body =>
      'A new version of {{appName}} is ready. '
      'Version {{currentAppStoreVersion}} is available — '
      'you’re on {{currentInstalledVersion}}.';

  @override
  String get prompt =>
      'Update now for the latest bookings experience, fixes, and improvements.';

  @override
  String get buttonTitleUpdate => 'Update now';

  @override
  String get buttonTitleLater => 'Not now';

  @override
  String get buttonTitleIgnore => 'Skip this version';

  @override
  String get releaseNotes => "What's new";
}

/// Shared [Upgrader] configured for Pitchside.
Upgrader createAppUpgrader() {
  return Upgrader(
    messages: PitchsideUpgraderMessages(),
    durationUntilAlertAgain: const Duration(days: 3),
    debugLogging: kDebugMode,
  );
}
