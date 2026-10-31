import '../../../core/config/app_config.dart';
import '../../../core/mock/mock_delay.dart';
import '../../../core/mock/mock_profile_data.dart';
import '../../../core/services/api_result.dart';
import '../../../core/services/session_cubit.dart';
import '../../../core/services/session_store.dart';
import '../../auth/model/user_model.dart';
import '../../home/model/venue.dart';
import '../model/help_faq.dart';
import '../model/notification_prefs.dart';
import '../model/profile_overview.dart';
import '../model/user_review.dart';
import 'profile_client.dart';

class ProfileRepository {
  const ProfileRepository(this._client, this._store, this._session);

  final ProfileClient _client;
  final SessionStore _store;
  final SessionCubit _session;

  Future<ApiResult<ProfileOverview>> fetchOverview() async {
    final result = AppConfig.useMockApi
        ? await MockDelay.run(() => ApiSuccess(MockProfileData.overview(_store)))
        : await _client.fetchOverview();
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
    final result = AppConfig.useMockApi
        ? await MockDelay.run(
            () => ApiSuccess(
              MockProfileData.update(
                _store,
                name: name,
                phone: phone,
                email: email,
                avatarUrl: avatarUrl,
                city: city,
                favouriteSports: favouriteSports,
                languageCode: languageCode,
                paymentPreference: paymentPreference,
                twoStepEnabled: twoStepEnabled,
              ),
            ),
          )
        : await _client.updateProfile({
            'name': ?name,
            'phone': ?phone,
            'email': ?email,
            'avatar_url': ?avatarUrl,
            'city': ?city,
            'favourite_sports': ?favouriteSports,
            'language': ?languageCode,
            'payment_preference': ?paymentPreference,
            'two_step_enabled': ?twoStepEnabled,
          });
    final user = result.dataOrNull;
    if (user != null) {
      await _session.applyUser(user);
    }
    return result;
  }

  Future<ApiResult<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    if (AppConfig.useMockApi) {
      return MockDelay.run(() {
        if (currentPassword.trim().length < 4) {
          return const ApiError(message: 'Current password is incorrect');
        }
        return const ApiSuccess(null);
      });
    }
    return _client.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  Future<ApiResult<void>> deleteAccount() {
    if (AppConfig.useMockApi) {
      return MockDelay.run(() => const ApiSuccess(null));
    }
    return _client.deleteAccount();
  }

  Future<ApiResult<NotificationPrefs>> fetchNotificationPrefs() {
    if (AppConfig.useMockApi) {
      return MockDelay.run(
        () => ApiSuccess(MockProfileData.notificationPrefs),
      );
    }
    return _client.fetchNotificationPrefs();
  }

  Future<ApiResult<NotificationPrefs>> updateNotificationPrefs(
    NotificationPrefs prefs,
  ) {
    if (AppConfig.useMockApi) {
      return MockDelay.run(() {
        MockProfileData.notificationPrefs = prefs;
        return ApiSuccess(prefs);
      });
    }
    return _client.updateNotificationPrefs(prefs);
  }

  Future<ApiResult<List<Venue>>> fetchSavedVenues() {
    if (AppConfig.useMockApi) {
      return MockDelay.run(() => ApiSuccess(MockProfileData.savedVenues()));
    }
    return _client.fetchSavedVenues();
  }

  Future<ApiResult<List<String>>> fetchSavedVenueIds() {
    if (AppConfig.useMockApi) {
      return MockDelay.run(
        () => ApiSuccess(MockProfileData.savedVenueIds()),
      );
    }
    return fetchSavedVenues().then(
      (result) => result.map((venues) => [for (final v in venues) v.id]),
    );
  }

  Future<ApiResult<void>> saveVenue(String venueId) {
    if (AppConfig.useMockApi) {
      return MockDelay.run(() {
        MockProfileData.saveVenue(venueId);
        return const ApiSuccess(null);
      });
    }
    return _client.saveVenue(venueId);
  }

  Future<ApiResult<void>> unsaveVenue(String venueId) {
    if (AppConfig.useMockApi) {
      return MockDelay.run(() {
        MockProfileData.unsaveVenue(venueId);
        return const ApiSuccess(null);
      });
    }
    return _client.unsaveVenue(venueId);
  }

  Future<ApiResult<List<UserReview>>> fetchReviews() {
    if (AppConfig.useMockApi) {
      return MockDelay.run(() => const ApiSuccess(MockProfileData.reviews));
    }
    return _client.fetchReviews();
  }

  Future<ApiResult<List<HelpFaq>>> fetchHelp() {
    if (AppConfig.useMockApi) {
      return MockDelay.run(() => const ApiSuccess(MockProfileData.faqs));
    }
    return _client.fetchHelp();
  }

  Future<ApiResult<void>> requestDownloadData() {
    if (AppConfig.useMockApi) {
      return MockDelay.run(() => const ApiSuccess(null));
    }
    return _client.requestDownloadData();
  }
}
