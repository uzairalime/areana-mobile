import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reusable store-review prompts (Rate us, post-booking, future surfaces).
///
/// Native dialogs are OS-gated — calling this never guarantees a sheet appears.
class InAppReviewService {
  InAppReviewService({
    InAppReview? review,
    this.appStoreId,
    this.microsoftStoreId,
  }) : _review = review ?? InAppReview.instance;

  final InAppReview _review;

  /// Optional Apple App Store id (digits only). Helps iOS store listing fallback.
  final String? appStoreId;

  /// Optional Microsoft Store id for Windows listing fallback.
  final String? microsoftStoreId;

  static const _lastBookingPromptKey = 'in_app_review.last_booking_prompt_ms';

  /// Quiet period between automatic post-booking prompts.
  static const bookingCooldown = Duration(days: 45);

  /// Profile "Rate us" — try native review, then open the store page.
  Future<void> openFromMenu() => _request(forceStoreListing: true);

  /// After a successful booking — native review only, cooldown-protected.
  Future<void> promptAfterBooking({
    Duration delay = const Duration(milliseconds: 900),
  }) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    if (!await _bookingCooldownElapsed()) return;
    final requested = await _request(forceStoreListing: false);
    if (requested) await _markBookingPrompted();
  }

  /// Low-level entry for future call sites.
  ///
  /// Returns `true` when a native review was requested or the store was opened.
  Future<bool> requestReview({bool forceStoreListing = false}) {
    return _request(forceStoreListing: forceStoreListing);
  }

  Future<bool> _request({required bool forceStoreListing}) async {
    try {
      if (await _review.isAvailable()) {
        await _review.requestReview();
        return true;
      }
      if (forceStoreListing) {
        await _openStoreListing();
        return true;
      }
    } catch (_) {
      if (!forceStoreListing) return false;
      try {
        await _openStoreListing();
        return true;
      } catch (_) {
        return false;
      }
    }
    return false;
  }

  Future<void> _openStoreListing() {
    return _review.openStoreListing(
      appStoreId: appStoreId,
      microsoftStoreId: microsoftStoreId,
    );
  }

  Future<bool> _bookingCooldownElapsed() async {
    final prefs = await SharedPreferences.getInstance();
    final lastMs = prefs.getInt(_lastBookingPromptKey);
    if (lastMs == null) return true;
    final last = DateTime.fromMillisecondsSinceEpoch(lastMs);
    return DateTime.now().difference(last) >= bookingCooldown;
  }

  Future<void> _markBookingPrompted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _lastBookingPromptKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }
}
