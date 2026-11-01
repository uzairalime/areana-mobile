import '../../../core/services/api_result.dart';
import '../../../core/services/session_cubit.dart';
import '../../auth/model/user_model.dart';
import '../../home/model/venue.dart';
import '../model/help_faq.dart';
import '../model/notification_prefs.dart';
import '../model/profile_overview.dart';
import '../model/user_review.dart';
import 'profile_client.dart';

class ProfileRepository {
  ProfileRepository(this._client, this._session);

  final ProfileClient _client;
  final SessionCubit _session;

  /// Local-only notification toggles: the Areana API exposes no
  /// player notification-preferences endpoint, so these live in
  /// memory for the session instead of inventing a call.
  var _notificationPrefs = const NotificationPrefs();

  Future<ApiResult<ProfileOverview>> fetchOverview() async {
    final result = await _client.fetchOverview();
    final overview = result.dataOrNull;
    if (overview != null) {
      await _session.applyUser(overview.user);
    }
    return result;
  }

  Future<ApiResult<UserModel>> updateProfile({
    String? name,
    String? phone,
    String? email,
    String? avatarUrl,
    String? city,
    List<String>? favouriteSports,
    String? languageCode,
    String? paymentPreference,
    bool? twoStepEnabled,
  }) async {
    // PATCH /users/me accepts only name/phone/city. The remaining
    // fields have no server endpoint and stay local-only on the
    // session user; they are never sent to the server.
    final body = <String, dynamic>{
      if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
      if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
      if (city != null && city.trim().isNotEmpty) 'city': city.trim(),
    };
    final ApiResult<UserModel> result;
    if (body.isEmpty) {
      final current = _session.state.user;
      if (current == null) {
        return const ApiError(message: 'Not signed in');
      }
      result = ApiSuccess(current);
    } else {
      result = await _client.updateProfile(body);
    }
    final user = result.dataOrNull;
    if (user != null) {
      final merged = user.copyWith(
        languageCode: languageCode,
        paymentPreference: paymentPreference,
        twoStepEnabled: twoStepEnabled,
      );
      await _session.applyUser(merged);
      return ApiSuccess(merged);
    }
    return result;
  }

  Future<ApiResult<void>> deleteAccount() => _client.deleteAccount();

  Future<ApiResult<NotificationPrefs>> fetchNotificationPrefs() async =>
      ApiSuccess(_notificationPrefs);

  Future<ApiResult<NotificationPrefs>> updateNotificationPrefs(
    NotificationPrefs prefs,
  ) async {
    _notificationPrefs = prefs;
    return ApiSuccess(prefs);
  }

  Future<ApiResult<List<Venue>>> fetchSavedVenues() =>
      _client.fetchSavedVenues();

  Future<ApiResult<List<String>>> fetchSavedVenueIds() =>
      fetchSavedVenues().then(
        (result) => result.map((venues) => [for (final v in venues) v.id]),
      );

  Future<ApiResult<void>> saveVenue(String venueId) =>
      _client.saveVenue(venueId);

  Future<ApiResult<void>> unsaveVenue(String venueId) =>
      _client.unsaveVenue(venueId);

  /// No "my reviews" endpoint exists on the Areana API, so the
  /// reviews screen shows its empty state until one is added.
  Future<ApiResult<List<UserReview>>> fetchReviews() async =>
      const ApiSuccess(<UserReview>[]);

  /// No help/FAQ endpoint exists on the Areana API.
  Future<ApiResult<List<HelpFaq>>> fetchHelp() async =>
      const ApiSuccess(<HelpFaq>[]);

  /// No data-export endpoint exists on the Areana API.
  Future<ApiResult<void>> requestDownloadData() async =>
      const ApiError(message: 'Data download is not available yet');
}
