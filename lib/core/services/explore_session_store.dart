import '../../features/explore/model/explore_models.dart';

/// In-memory Explore snapshot for Courts/Map + sport while still on Explore.
/// Cleared when the user leaves Explore via the bottom nav.
class ExploreSessionStore {
  ExploreSearchCriteria search = const ExploreSearchCriteria();
  ExplorePageTab pageTab = ExplorePageTab.courts;
  String? selectedSportId;

  void saveSearch(ExploreSearchCriteria value) => search = value;

  void clearSearch() => search = const ExploreSearchCriteria();

  void savePageTab(ExplorePageTab value) => pageTab = value;

  void saveSportId(String? value) => selectedSportId = value;
}
