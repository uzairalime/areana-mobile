import 'package:arana360/core/config/app_config.dart';

/// Base URL comes from flavor config (`config.development.json` /
/// `config.production.json`). Never hardcode a host in a client.
class ApiEndpoints {
  const ApiEndpoints._();

  static const String baseUrl = AppConfig.apiBaseUrl;

  // Areana player auth — passwordless email OTP, same as user-web /auth.
  static const String requestOtp = 'auth/request-otp';
  static const String verifyOtp = 'auth/verify-otp';
  static const String refresh = 'auth/refresh';
  static const String logout = 'auth/logout';
  static const String authSessions = 'auth/sessions';
  static const String logoutAll = 'auth/logout-all';

  // Discovery (public) — user-web browse / courts / home.
  static const String venues = 'venues';
  static const String venuesCities = 'venues/cities';
  static const String venuesSurfaces = 'venues/surfaces';
  static String venue(String id) => 'venues/$id';
  static String venueCourts(String venueId) => 'venues/$venueId/courts';
  static String venueReviews(String venueId) => 'venues/$venueId/reviews';
  static String venueReport(String venueId) => 'venues/$venueId/report';
  static String venueReportMe(String venueId) => 'venues/$venueId/report/me';
  static String venueEvents(String venueId) => 'venues/$venueId/events';
  static const String courts = 'courts';
  static String court(String id) => 'courts/$id';
  static String courtAvailability(String courtId) =>
      'courts/$courtId/availability';
  static String courtReviews(String courtId) => 'courts/$courtId/reviews';
  static const String sports = 'sports';
  static const String amenities = 'amenities';
  static const String banners = 'banners';
  static const String searchSlots = 'search/slots';

  // Bookings (authenticated) — user-web /bookings.
  static const String bookings = 'bookings';
  static const String bookingsMe = 'bookings/me';
  static const String bookingsReschedulesPending =
      'bookings/reschedules/pending';
  static String booking(String id) => 'bookings/$id';
  static String bookingCancel(String id) => 'bookings/$id/cancel';
  static String bookingReschedule(String id) => 'bookings/$id/reschedule';
  static String bookingRescheduleWithdraw(String id) =>
      'bookings/$id/reschedule/withdraw';
  static String bookingShare(String id) => 'bookings/$id/share';
  static String bookingShared(String code) => 'bookings/shared/$code';
  static String bookingSharedJoin(String code) => 'bookings/shared/$code/join';
  static const String validatePromo = 'bookings/validate-promo';
  static const String reviews = 'reviews';

  // Favorites (authenticated, cursor paging).
  static const String favorites = 'favorites';
  static const String favoritesCheck = 'favorites/check';

  // Games board (public list, authenticated join/create).
  static const String gamePosts = 'game-posts';
  static String gamePost(String id) => 'game-posts/$id';
  static String gamePostJoin(String id) => 'game-posts/$id/join';
  static String gamePostLeave(String id) => 'game-posts/$id/leave';
  static String gamePostRequestAccept(String postId, String participantId) =>
      'game-posts/$postId/requests/$participantId/accept';
  static String gamePostRequestReject(String postId, String participantId) =>
      'game-posts/$postId/requests/$participantId/reject';

  // Waitlist (authenticated).
  static const String waitlist = 'waitlist';
  static const String waitlistMine = 'waitlist/mine';
  static String waitlistEntry(String id) => 'waitlist/$id';

  // TEMPORARY compatibility constants for sections not yet rewritten
  // (booking, bookings, messages, notifications). They keep the app
  // compiling between section pushes and are deleted in the final
  // cleanup section once those clients are rewritten. The old
  // Pitchside /profile constants were deleted here: the Areana API
  // has no /profile endpoint (it is /users/me), and leaving the
  // constants around risked a future caller using them by mistake.
  static const String popularVenues = 'venues/popular';
  static const String searchVenues = 'venues/search';
  static String venueAvailability(String venueId) =>
      'venues/$venueId/availability';
  static const String createBooking = 'bookings';
  static const String myBookings = 'bookings/me';
  static String bookingReview(String id) => 'bookings/$id/review';
  static const String notificationsReadAll = 'notifications/read-all';
  static String notificationRead(String id) => 'notifications/$id/read';
  static const String conversations = 'conversations';
  static String conversation(String id) => 'conversations/$id';
  static String conversationMessages(String id) =>
      'conversations/$id/messages';
  static String conversationRead(String id) => 'conversations/$id/read';

  // Profile / referrals / notifications (authenticated).
  static const String usersMe = 'users/me';
  static const String usersMeDeviceTokens = 'users/me/device-tokens';
  static String usersMeDeviceToken(String id) => 'users/me/device-tokens/$id';
  static const String referralsMe = 'referrals/me';
  static const String notifications = 'notifications';
  static const String notificationsUnreadCount = 'notifications/unread-count';
}
