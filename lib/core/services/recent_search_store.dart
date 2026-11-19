import 'package:shared_preferences/shared_preferences.dart';

import '../../features/search/model/search_models.dart';

/// Persists the last [maxItems] place picks locally.
class RecentSearchStore {
  RecentSearchStore();

  static const _key = 'pitchside_recent_searches';
  static const maxItems = 5;

  Future<List<RecentPlace>> read() async {
    final prefs = await SharedPreferences.getInstance();
    return [
      for (final raw in prefs.getStringList(_key) ?? const <String>[])
        RecentPlace.fromStored(raw),
    ].where((item) => item.label.isNotEmpty).toList();
  }

  Future<List<RecentPlace>> add(RecentPlace place) async {
    final label = place.label.trim();
    if (label.isEmpty) return read();
    final lower = label.toLowerCase();
    if (lower == 'nearby' || lower == 'near me' || lower == 'current location') {
      return read();
    }

    final prefs = await SharedPreferences.getInstance();
    final current = [
      for (final raw in prefs.getStringList(_key) ?? <String>[])
        RecentPlace.fromStored(raw),
    ];
    final next = [
      RecentPlace(label: label, placeId: place.placeId, lat: place.lat, lng: place.lng),
      ...current.where((item) => item.label.toLowerCase() != lower),
    ].take(maxItems).toList(growable: false);

    await prefs.setStringList(
      _key,
      [for (final item in next) item.encoded],
    );
    return next;
  }

  Future<List<RecentPlace>> remove(RecentPlace place) async {
    final prefs = await SharedPreferences.getInstance();
    final next = [
      for (final raw in prefs.getStringList(_key) ?? <String>[])
        RecentPlace.fromStored(raw),
    ].where((item) => item.label.toLowerCase() != place.label.trim().toLowerCase()).toList();
    await prefs.setStringList(
      _key,
      [for (final item in next) item.encoded],
    );
    return next;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
