import 'package:arana360/core/config/app_config.dart';

/// Base URL comes from flavor config (`config.development.json` / `config.production.json`).
class ApiEndpoints {
  const ApiEndpoints._();

  static const String baseUrl = AppConfig.apiBaseUrl;

  // Areana player auth — passwordless email OTP, same as user-web /auth.
  static const String requestOtp = 'auth/request-otp';
  static const String verifyOtp = 'auth/verify-otp';
  static const String refresh = 'auth/refresh';
  static const String logout = 'auth/logout';
  static const String profile = 'profile';
  static const String profilePassword = 'profile/password';
  static const String profileNotifications = 'profile/notifications';
  static const String profileSavedVenues = 'profile/saved-venues';
  static String profileSavedVenue(String id) => 'profile/saved-venues/$id';
  static const String profileReviews = 'profile/reviews';
  static const String profileHelp = 'profile/help';
  static const String profileDownloadData = 'profile/download-data';
  static const String sports = 'sports';
  static const String popularVenues = 'venues/popular';
  static const String searchVenues = 'venues/search';
  static String venueAvailability(String venueId) =>
      'venues/$venueId/availability';
  static const String createBooking = 'bookings';
  static const String myBookings = 'bookings/mine';
  static String bookingReview(String id) => 'bookings/$id/review';
  static String bookingCancel(String id) => 'bookings/$id/cancel';
  static const String notifications = 'notifications';
  static const String notificationsReadAll = 'notifications/read-all';
  static String notificationRead(String id) => 'notifications/$id/read';
  static const String conversations = 'conversations';
  static String conversation(String id) => 'conversations/$id';
  static String conversationMessages(String id) =>
      'conversations/$id/messages';
  static String conversationRead(String id) => 'conversations/$id/read';
}
