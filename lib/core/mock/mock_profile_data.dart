import '../../features/auth/model/user_model.dart';
import '../../features/home/model/venue.dart';
import '../../features/profile/model/help_faq.dart';
import '../../features/profile/model/notification_prefs.dart';
import '../../features/profile/model/profile_overview.dart';
import '../../features/profile/model/profile_stats.dart';
import '../../features/profile/model/user_review.dart';
import '../services/session_store.dart';
import 'mock_home_data.dart';

class MockProfileData {
  const MockProfileData._();

  static NotificationPrefs notificationPrefs = const NotificationPrefs();
  static final List<String> _savedVenueIds = [
    'arena-one',
    'goal-zone',
    'strike-indoor',
  ];

  static UserModel current(SessionStore session) {
    final base = session.user ??
        const UserModel(
          id: 'user_1',
          name: 'Ahmed Khan',
          email: 'ahmed@example.com',
          phone: '+92 300 1234567',
          provider: 'google',
        );
    return base.copyWith(
      city: base.city.isEmpty ? 'Karachi' : base.city,
      favouriteSports: base.favouriteSports.isEmpty
          ? const ['padel', 'football']
          : base.favouriteSports,
      memberSinceLabel: base.memberSinceLabel.isEmpty
          ? 'Member since Oct 2026'
          : base.memberSinceLabel,
      emailVerified: true,
      phoneVerified: true,
      languageCode: base.languageCode,
      paymentPreference: base.paymentPreference,
      twoStepEnabled: base.twoStepEnabled,
      passwordUpdatedLabel: base.passwordUpdatedLabel.isEmpty
          ? 'Updated 2 months ago'
          : base.passwordUpdatedLabel,
    );
  }

  static ProfileOverview overview(SessionStore session) {
    final user = current(session);
    return ProfileOverview(
      user: user,
      stats: ProfileStats(
        bookingsCount: 12,
        hoursPlayed: 18,
        reviewsCount: reviews.where((r) => !r.pending).length,
        savedVenuesCount: _savedVenueIds.length,
      ),
    );
  }

  static UserModel update(
    SessionStore session, {
    String? name,
    String? phone,
    String? email,
    String? avatarUrl,
    String? city,
    List<String>? favouriteSports,
    String? languageCode,
    String? paymentPreference,
    bool? twoStepEnabled,
  }) {
    final next = current(session).copyWith(
      name: name,
      phone: phone,
      email: email,
      avatarUrl: avatarUrl,
      clearAvatar: avatarUrl != null && avatarUrl.isEmpty,
      city: city,
      favouriteSports: favouriteSports,
      languageCode: languageCode,
      paymentPreference: paymentPreference,
      twoStepEnabled: twoStepEnabled,
    );
    return next;
  }

  static List<Venue> savedVenues() {
    return [
      for (final id in _savedVenueIds) ?MockHomeData.byId(id),
    ];
  }

  static List<String> savedVenueIds() => List<String>.unmodifiable(_savedVenueIds);

  static bool isVenueSaved(String venueId) => _savedVenueIds.contains(venueId);

  static bool saveVenue(String venueId) {
    if (venueId.isEmpty || _savedVenueIds.contains(venueId)) return false;
    _savedVenueIds.add(venueId);
    return true;
  }

  static bool unsaveVenue(String venueId) {
    return _savedVenueIds.remove(venueId);
  }

  static const List<UserReview> reviews = [
    UserReview(
      id: 'pending-strike',
      venueId: 'strike-indoor',
      venueName: 'Strike Indoor Cricket Arena',
      dateLabel: '25 Oct',
      body: '',
      pending: true,
      promptTitle: 'How was Strike Arena?',
      promptBody: 'You played there on 25 Oct. Share a quick review.',
    ),
    UserReview(
      id: 'r1',
      venueId: 'arena-one',
      venueName: 'Arena One Padel Club',
      dateLabel: '12 Oct 2026',
      rating: 5,
      body:
          'Glass courts are spotless and the lighting is great for evening games. Booking at the desk took seconds.',
    ),
    UserReview(
      id: 'r2',
      venueId: 'goal-zone',
      venueName: 'Goal Zone Turf',
      dateLabel: '2 Oct 2026',
      rating: 4,
      body:
          'Good turf and plenty of parking. Changing rooms could be cleaner, but the staff were helpful.',
    ),
    UserReview(
      id: 'r3',
      venueId: 'strike-indoor',
      venueName: 'Strike Indoor Cricket Arena',
      dateLabel: '21 Sep 2026',
      rating: 5,
      body: 'Best nets in the area. Bowling machine worked perfectly.',
    ),
    UserReview(
      id: 'r4',
      venueId: 'arena-one',
      venueName: 'Arena One Padel Club',
      dateLabel: '30 Aug 2026',
      rating: 4,
      body:
          'Fun session with friends. Slightly busy at 8 PM so book early.',
    ),
  ];

  static const List<HelpFaq> faqs = [
    HelpFaq(
      id: 'f1',
      question: 'How do I cancel a booking?',
      answer:
          'Open the booking, tap Cancel, and confirm. Free cancellation is available until the venue’s cutoff time.',
    ),
    HelpFaq(
      id: 'f2',
      question: 'Can I pay at the ground?',
      answer:
          'Yes. Choose Pay at ground at checkout when the venue supports it. Bring cash or the venue’s accepted method.',
    ),
    HelpFaq(
      id: 'f3',
      question: 'How do I change my slot?',
      answer:
          'Open a confirmed or pending booking and tap Update slot to pick a new time at the same venue.',
    ),
  ];
}
