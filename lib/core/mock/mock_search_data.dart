import '../../features/home/model/venue.dart';
import '../../features/search/model/search_models.dart';
import 'mock_home_data.dart';

abstract final class MockSearchData {
  static const places = <PlaceSuggestion>[
    PlaceSuggestion(
      id: 'pk-lahore',
      primaryText: 'Lahore',
      secondaryText: 'Punjab, Pakistan',
    ),
    PlaceSuggestion(
      id: 'pk-karachi',
      primaryText: 'Karachi',
      secondaryText: 'Sindh, Pakistan',
    ),
    PlaceSuggestion(
      id: 'pk-islamabad',
      primaryText: 'Islamabad',
      secondaryText: 'Pakistan',
    ),
    PlaceSuggestion(
      id: 'pk-dha-lhr',
      primaryText: 'DHA',
      secondaryText: 'Lahore, Punjab, Pakistan',
    ),
    PlaceSuggestion(
      id: 'pk-gulberg',
      primaryText: 'Gulberg',
      secondaryText: 'Lahore, Punjab, Pakistan',
    ),
    PlaceSuggestion(
      id: 'pk-clifton',
      primaryText: 'Clifton',
      secondaryText: 'Karachi, Sindh, Pakistan',
    ),
    PlaceSuggestion(
      id: 'pk-gulshan',
      primaryText: 'Gulshan-e-Iqbal',
      secondaryText: 'Karachi, Sindh, Pakistan',
    ),
  ];

  static SearchBundle search(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) {
      return const SearchBundle();
    }

    final matchedPlaces = places.where((place) {
      return place.primaryText.toLowerCase().contains(needle) ||
          place.secondaryText.toLowerCase().contains(needle) ||
          place.displayLabel.toLowerCase().contains(needle);
    }).toList();

    final matchedVenues = MockHomeData.popularVenues.where((venue) {
      return venue.name.toLowerCase().contains(needle) ||
          venue.sport.toLowerCase().contains(needle) ||
          venue.location.toLowerCase().contains(needle) ||
          venue.amenities.any((a) => a.toLowerCase().contains(needle));
    }).toList();

    return SearchBundle(places: matchedPlaces, venues: matchedVenues);
  }

  static List<Venue> venuesInPlace(PlaceSuggestion place) {
    final city = place.primaryText.toLowerCase();
    final secondary = place.secondaryText.toLowerCase();
    return MockHomeData.popularVenues.where((venue) {
      final loc = venue.location.toLowerCase();
      return loc.contains(city) ||
          (secondary.contains('lahore') && loc.contains('lahore')) ||
          (secondary.contains('karachi') && loc.contains('karachi')) ||
          (secondary.contains('islamabad') && loc.contains('islamabad'));
    }).toList();
  }
}
