import 'package:equatable/equatable.dart';

import '../../../core/enums/app_loading.dart';
import '../../auth/model/user_model.dart';
import '../../home/model/venue.dart';
import '../model/help_faq.dart';
import '../model/notification_prefs.dart';
import '../model/profile_overview.dart';
import '../model/user_review.dart';

class ProfileState extends Equatable {
  const ProfileState({
    this.status = AppLoading.initial,
    this.saveStatus = AppLoading.initial,
    this.actionStatus = AppLoading.initial,
    this.errorMessage = '',
    this.overview,
    this.notificationPrefs = const NotificationPrefs(),
    this.savedVenues = const [],
    this.savedVenueIds = const [],
    this.reviews = const [],
    this.faqs = const [],
    this.selectedSports = const [],
  });

  final AppLoading status;
  final AppLoading saveStatus;
  final AppLoading actionStatus;
  final String errorMessage;
  final ProfileOverview? overview;
  final NotificationPrefs notificationPrefs;
  final List<Venue> savedVenues;

  /// Lightweight id cache for hearts on venue cards (home / explore).
  final List<String> savedVenueIds;
  final List<UserReview> reviews;
  final List<HelpFaq> faqs;
  final List<String> selectedSports;

  UserModel? get user => overview?.user;

  bool isVenueSaved(String venueId) => savedVenueIds.contains(venueId);

  ProfileState copyWith({
    AppLoading? status,
    AppLoading? saveStatus,
    AppLoading? actionStatus,
    String? errorMessage,
    ProfileOverview? overview,
    NotificationPrefs? notificationPrefs,
    List<Venue>? savedVenues,
    List<String>? savedVenueIds,
    List<UserReview>? reviews,
    List<HelpFaq>? faqs,
    List<String>? selectedSports,
  }) {
    return ProfileState(
      status: status ?? this.status,
      saveStatus: saveStatus ?? this.saveStatus,
      actionStatus: actionStatus ?? this.actionStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      overview: overview ?? this.overview,
      notificationPrefs: notificationPrefs ?? this.notificationPrefs,
      savedVenues: savedVenues ?? this.savedVenues,
      savedVenueIds: savedVenueIds ?? this.savedVenueIds,
      reviews: reviews ?? this.reviews,
      faqs: faqs ?? this.faqs,
      selectedSports: selectedSports ?? this.selectedSports,
    );
  }

  @override
  List<Object?> get props => [
    status,
    saveStatus,
    actionStatus,
    errorMessage,
    overview,
    notificationPrefs,
    savedVenues,
    savedVenueIds,
    reviews,
    faqs,
    selectedSports,
  ];
}
