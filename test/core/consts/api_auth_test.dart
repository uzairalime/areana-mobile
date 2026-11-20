import 'package:arana360/core/consts/api_auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('public discovery stays open without a token', () {
    const publicPaths = [
      'venues',
      'venues/abc',
      'courts/1/availability',
      'sports',
      'amenities',
      'banners',
      'search/slots',
      'places/autocomplete',
      'auth/request-otp',
      'auth/verify-otp',
      'auth/social',
      'auth/refresh',
      'game-posts',
      'bookings/shared/xyz',
    ];
    for (final path in publicPaths) {
      expect(ApiAuth.requiresAccessToken(path), isFalse, reason: path);
    }
  });

  test('player APIs require an access token', () {
    const authed = [
      'bookings/me',
      'bookings',
      'users/me',
      'users/me/device-tokens',
      'notifications',
      'conversations',
      'favorites',
      'waitlist/mine',
      'referrals/me',
      'auth/logout',
      'auth/complete-profile',
      'game-posts/1/join',
    ];
    for (final path in authed) {
      expect(ApiAuth.requiresAccessToken(path, 'GET'), isTrue, reason: path);
    }
    expect(ApiAuth.requiresAccessToken('game-posts', 'POST'), isTrue);
  });
}
