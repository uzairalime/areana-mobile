import 'package:shared_preferences/shared_preferences.dart';

/// Persists the last [maxItems] venue search queries locally.
class RecentSearchStore {
  RecentSearchStore();

  static const _key = 'pitchside_recent_searches';
  static const maxItems = 5;

  Future<List<String>> read() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? const [];
  }

  Future<List<String>> add(String raw) async {
    final query = raw.trim();
    if (query.isEmpty) return read();
    // Match ReelStay: never persist the ephemeral Near me row.
    final lower = query.toLowerCase();
    if (lower == 'nearby' || lower == 'near me') return read();

    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_key) ?? <String>[];
    final next = [
      query,
      ...current.where((item) => item.toLowerCase() != lower),
    ].take(maxItems).toList(growable: false);

    await prefs.setStringList(_key, next);
    return next;
  }

  Future<List<String>> remove(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_key) ?? <String>[];
    final next = current
        .where((item) => item.toLowerCase() != query.trim().toLowerCase())
        .toList();
    await prefs.setStringList(_key, next);
    return next;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
