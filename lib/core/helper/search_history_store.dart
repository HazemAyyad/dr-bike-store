import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryStore {
  SearchHistoryStore({required this.preferences, this.maxEntries = 6});

  static const preferenceKey = 'store_recent_searches';

  final SharedPreferences preferences;
  final int maxEntries;

  Future<List<String>> load() async => List<String>.unmodifiable(
    preferences.getStringList(preferenceKey) ?? const <String>[],
  );

  Future<List<String>> add(String query) async {
    final normalized = query.trim();
    if (normalized.isEmpty) return load();

    final updated =
        (await load()).toList()
          ..removeWhere(
            (entry) => entry.toLowerCase() == normalized.toLowerCase(),
          )
          ..insert(0, normalized);
    if (updated.length > maxEntries) {
      updated.removeRange(maxEntries, updated.length);
    }
    await preferences.setStringList(preferenceKey, updated);
    return List<String>.unmodifiable(updated);
  }

  Future<void> clear() => preferences.remove(preferenceKey);
}
