import 'package:hive/hive.dart';
import 'package:numpang_app/data/models/recent_search_model.dart';
import 'package:numpang_app/domain/entities/place_suggestion.dart';

abstract class RecentSearchesLocalDataSource {
  Future<List<RecentSearchModel>> getRecentSearches();
  Future<void> addSearch(String query, {PlaceSuggestion? suggestion});
  Future<void> removeSearch(String id);
  Future<void> clearAllSearches();
}

class RecentSearchesLocalDataSourceImpl implements RecentSearchesLocalDataSource {
  RecentSearchesLocalDataSourceImpl({required Box<RecentSearchModel> box})
      : _box = box;

  final Box<RecentSearchModel> _box;
  static const int _maxItems = 20;

  @override
  Future<List<RecentSearchModel>> getRecentSearches() async {
    final items = _box.values.toList();
    items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return items.take(_maxItems).toList();
  }

  @override
  Future<void> addSearch(String query, {PlaceSuggestion? suggestion}) async {
    if (query.trim().isEmpty) return;

    final trimmedQuery = query.trim();

    final existing = _box.values.where((item) => item.query == trimmedQuery);
    if (existing.isNotEmpty) {
      for (final item in existing) {
        await item.delete();
      }
    }

    final model = suggestion != null
        ? RecentSearchModel.fromPlaceSuggestion(
            query: trimmedQuery,
            suggestion: suggestion,
          )
        : RecentSearchModel.fromQuery(trimmedQuery);

    await _box.add(model);
    await _enforceMaxLimit();
  }

  @override
  Future<void> removeSearch(String id) async {
    final item = _box.values.firstWhere(
      (item) => item.id == id,
      orElse: () => throw StateError('Item not found'),
    );
    await item.delete();
  }

  @override
  Future<void> clearAllSearches() async {
    await _box.clear();
  }

  Future<void> _enforceMaxLimit() async {
    final items = _box.values.toList();
    if (items.length <= _maxItems) return;

    items.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final toDelete = items.take(items.length - _maxItems);
    for (final item in toDelete) {
      await item.delete();
    }
  }
}
