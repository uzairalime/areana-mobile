import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/enums/app_loading.dart';
import '../../../core/services/api_result.dart';
import '../../../core/services/session_cubit.dart';
import '../../auth/model/user_model.dart';
import '../model/notification_prefs.dart';
import '../model/profile_overview.dart';
import 'profile_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._repository, this._session) : super(const ProfileState());

  final ProfileRepository _repository;
  final SessionCubit _session;
  var _savedIdsHydrated = false;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final cityController = TextEditingController();
  Future<void> load() async {
    emit(state.copyWith(status: AppLoading.loading, errorMessage: ''));
    final result = await _repository.fetchOverview();
    if (isClosed) return;
    result.when(
      success: (overview) {
        _syncControllers(overview.user);
        emit(
          state.copyWith(
            status: AppLoading.success,
            overview: overview,
            selectedSports: [...overview.user.favouriteSports],
            errorMessage: '',
          ),
        );
      },
      failure: (error) {
        emit(
          state.copyWith(
            status: AppLoading.error,
            errorMessage: error.message,
          ),
        );
      },
    );
  }

  Future<void> saveProfile({String? phone}) async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    emit(state.copyWith(saveStatus: AppLoading.loading, errorMessage: ''));
    final result = await _repository.updateProfile(
      name: nameController.text.trim(),
      phone: (phone ?? phoneController.text).trim(),
      email: emailController.text.trim(),
      city: cityController.text.trim(),
      favouriteSports: state.selectedSports,
    );
    if (isClosed) return;
    result.when(
      success: (user) {
        final overview = state.overview?.copyWith(user: user);
        emit(
          state.copyWith(
            saveStatus: AppLoading.success,
            overview: overview,
            errorMessage: '',
          ),
        );
      },
      failure: (error) {
        emit(
          state.copyWith(
            saveStatus: AppLoading.error,
            errorMessage: error.message,
          ),
        );
      },
    );
  }

  void toggleSport(String sportId) {
    final next = [...state.selectedSports];
    if (next.contains(sportId)) {
      next.remove(sportId);
    } else {
      next.add(sportId);
    }
    emit(state.copyWith(selectedSports: next));
  }

  Future<void> saveLanguage(String code) async {
    emit(state.copyWith(saveStatus: AppLoading.loading, errorMessage: ''));
    final result = await _repository.updateProfile(languageCode: code);
    if (isClosed) return;
    _handleUserSave(result);
  }

  Future<void> savePaymentPreference(String value) async {
    emit(state.copyWith(saveStatus: AppLoading.loading, errorMessage: ''));
    final result = await _repository.updateProfile(paymentPreference: value);
    if (isClosed) return;
    _handleUserSave(result);
  }

  Future<void> setTwoStep(bool enabled) async {
    emit(state.copyWith(actionStatus: AppLoading.loading, errorMessage: ''));
    final result = await _repository.updateProfile(twoStepEnabled: enabled);
    if (isClosed) return;
    result.when(
      success: (user) {
        emit(
          state.copyWith(
            actionStatus: AppLoading.success,
            overview: state.overview?.copyWith(user: user),
            errorMessage: '',
          ),
        );
      },
      failure: (error) {
        emit(
          state.copyWith(
            actionStatus: AppLoading.error,
            errorMessage: error.message,
          ),
        );
      },
    );
  }

  // No change-password: players sign in with email OTP, and the
  // Areana API has no password-change endpoint for players.
  Future<bool> deleteAccount() async {
    emit(state.copyWith(actionStatus: AppLoading.loading, errorMessage: ''));
    final result = await _repository.deleteAccount();
    if (isClosed) return false;
    return result.when(
      success: (_) async {
        await _session.clear();
        emit(state.copyWith(actionStatus: AppLoading.success));
        return true;
      },
      failure: (error) {
        emit(
          state.copyWith(
            actionStatus: AppLoading.error,
            errorMessage: error.message,
          ),
        );
        return false;
      },
    );
  }

  Future<void> loadNotificationPrefs() async {
    emit(state.copyWith(status: AppLoading.loading, errorMessage: ''));
    final result = await _repository.fetchNotificationPrefs();
    if (isClosed) return;
    result.when(
      success: (prefs) {
        emit(
          state.copyWith(
            status: AppLoading.success,
            notificationPrefs: prefs,
            errorMessage: '',
          ),
        );
      },
      failure: (error) {
        emit(
          state.copyWith(
            status: AppLoading.error,
            errorMessage: error.message,
          ),
        );
      },
    );
  }

  Future<void> updateNotificationPrefs(NotificationPrefs prefs) async {
    emit(
      state.copyWith(
        notificationPrefs: prefs,
        actionStatus: AppLoading.loading,
        errorMessage: '',
      ),
    );
    final result = await _repository.updateNotificationPrefs(prefs);
    if (isClosed) return;
    result.when(
      success: (next) {
        emit(
          state.copyWith(
            notificationPrefs: next,
            actionStatus: AppLoading.success,
          ),
        );
      },
      failure: (error) {
        emit(
          state.copyWith(
            actionStatus: AppLoading.error,
            errorMessage: error.message,
          ),
        );
      },
    );
  }

  Future<void> loadSavedVenues() async {
    emit(state.copyWith(status: AppLoading.loading, errorMessage: ''));
    final result = await _repository.fetchSavedVenues();
    if (isClosed) return;
    result.when(
      success: (venues) {
        _savedIdsHydrated = true;
        emit(
          state.copyWith(
            status: AppLoading.success,
            savedVenues: venues,
            savedVenueIds: [for (final v in venues) v.id],
            errorMessage: '',
          ),
        );
      },
      failure: (error) {
        emit(
          state.copyWith(
            status: AppLoading.error,
            errorMessage: error.message,
          ),
        );
      },
    );
  }

  /// Hydrates heart state for venue cards without loading full venue objects.
  Future<void> ensureSavedVenueIds() async {
    if (_savedIdsHydrated || !_session.state.isAuthenticated) return;
    final result = await _repository.fetchSavedVenueIds();
    if (isClosed) return;
    result.when(
      success: (ids) {
        _savedIdsHydrated = true;
        emit(state.copyWith(savedVenueIds: ids, errorMessage: ''));
      },
      failure: (_) {},
    );
  }

  /// Toggles save. Returns `true` when the venue is saved after the call.
  Future<bool> toggleSavedVenue(String venueId) async {
    if (venueId.isEmpty) return false;
    final currentlySaved = state.isVenueSaved(venueId);
    return currentlySaved
        ? !(await unsaveVenue(venueId))
        : await saveVenue(venueId);
  }

  Future<bool> saveVenue(String venueId) async {
    if (venueId.isEmpty || state.isVenueSaved(venueId)) return true;

    final previousIds = state.savedVenueIds;
    final nextIds = [...previousIds, venueId];
    emit(
      state.copyWith(
        savedVenueIds: nextIds,
        overview: _overviewWithSavedCount(nextIds.length),
      ),
    );

    final result = await _repository.saveVenue(venueId);
    if (isClosed) return state.isVenueSaved(venueId);
    return result.when(
      success: (_) => true,
      failure: (error) {
        emit(
          state.copyWith(
            savedVenueIds: previousIds,
            overview: _overviewWithSavedCount(previousIds.length),
            errorMessage: error.message,
          ),
        );
        return false;
      },
    );
  }

  /// Returns `true` when unsaved successfully (venue is no longer saved).
  Future<bool> unsaveVenue(String venueId) async {
    if (venueId.isEmpty || !state.isVenueSaved(venueId)) return true;

    final previousVenues = state.savedVenues;
    final previousIds = state.savedVenueIds;
    final nextIds = previousIds.where((id) => id != venueId).toList();
    emit(
      state.copyWith(
        savedVenues: previousVenues.where((v) => v.id != venueId).toList(),
        savedVenueIds: nextIds,
        overview: _overviewWithSavedCount(nextIds.length),
      ),
    );

    final result = await _repository.unsaveVenue(venueId);
    if (isClosed) return !state.isVenueSaved(venueId);
    return result.when(
      success: (_) => true,
      failure: (error) {
        emit(
          state.copyWith(
            savedVenues: previousVenues,
            savedVenueIds: previousIds,
            overview: _overviewWithSavedCount(previousIds.length),
            errorMessage: error.message,
          ),
        );
        return false;
      },
    );
  }

  ProfileOverview? _overviewWithSavedCount(int count) {
    final overview = state.overview;
    if (overview == null) return null;
    return overview.copyWith(
      stats: overview.stats.copyWith(savedVenuesCount: count),
    );
  }

  Future<void> loadReviews() async {
    emit(state.copyWith(status: AppLoading.loading, errorMessage: ''));
    final result = await _repository.fetchReviews();
    if (isClosed) return;
    result.when(
      success: (reviews) {
        emit(
          state.copyWith(
            status: AppLoading.success,
            reviews: reviews,
            errorMessage: '',
          ),
        );
      },
      failure: (error) {
        emit(
          state.copyWith(
            status: AppLoading.error,
            errorMessage: error.message,
          ),
        );
      },
    );
  }

  Future<void> loadHelp() async {
    emit(state.copyWith(status: AppLoading.loading, errorMessage: ''));
    final result = await _repository.fetchHelp();
    if (isClosed) return;
    result.when(
      success: (faqs) {
        emit(
          state.copyWith(
            status: AppLoading.success,
            faqs: faqs,
            errorMessage: '',
          ),
        );
      },
      failure: (error) {
        emit(
          state.copyWith(
            status: AppLoading.error,
            errorMessage: error.message,
          ),
        );
      },
    );
  }

  Future<void> requestDownloadData() async {
    emit(state.copyWith(actionStatus: AppLoading.loading, errorMessage: ''));
    final result = await _repository.requestDownloadData();
    if (isClosed) return;
    result.when(
      success: (_) {
        emit(state.copyWith(actionStatus: AppLoading.success));
      },
      failure: (error) {
        emit(
          state.copyWith(
            actionStatus: AppLoading.error,
            errorMessage: error.message,
          ),
        );
      },
    );
  }

  void clearSaveStatus() {
    if (state.saveStatus.isInitial && state.errorMessage.isEmpty) return;
    emit(state.copyWith(saveStatus: AppLoading.initial, errorMessage: ''));
  }

  void clearActionStatus() {
    if (state.actionStatus.isInitial && state.errorMessage.isEmpty) return;
    emit(state.copyWith(actionStatus: AppLoading.initial, errorMessage: ''));
  }

  void _syncControllers(UserModel user) {
    nameController.text = user.name;
    phoneController.text = user.phone;
    emailController.text = user.email;
    cityController.text = user.city;
  }

  void _handleUserSave(ApiResult<UserModel> result) {
    result.when(
      success: (user) {
        emit(
          state.copyWith(
            saveStatus: AppLoading.success,
            overview: state.overview?.copyWith(user: user),
            errorMessage: '',
          ),
        );
      },
      failure: (error) {
        emit(
          state.copyWith(
            saveStatus: AppLoading.error,
            errorMessage: error.message,
          ),
        );
      },
    );
  }

  @override
  Future<void> close() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    cityController.dispose();
    return super.close();
  }
}
