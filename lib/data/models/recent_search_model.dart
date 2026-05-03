import 'package:hive/hive.dart';
import 'package:numpang_app/domain/entities/place_suggestion.dart';

part 'recent_search_model.g.dart';

@HiveType(typeId: 1)
class RecentSearchModel extends HiveObject {
  RecentSearchModel({
    required this.id,
    required this.query,
    required this.timestamp,
    this.placeId,
    this.placeName,
    this.placeAddress,
    this.latitude,
    this.longitude,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String query;

  @HiveField(2)
  final DateTime timestamp;

  @HiveField(3, defaultValue: null)
  final String? placeId;

  @HiveField(4, defaultValue: null)
  final String? placeName;

  @HiveField(5, defaultValue: null)
  final String? placeAddress;

  @HiveField(6, defaultValue: null)
  final double? latitude;

  @HiveField(7, defaultValue: null)
  final double? longitude;

  PlaceSuggestion? toPlaceSuggestion() {
    if (placeId == null ||
        placeName == null ||
        placeAddress == null ||
        latitude == null ||
        longitude == null) {
      return null;
    }
    return PlaceSuggestion(
      id: placeId!,
      name: placeName!,
      address: placeAddress!,
      latitude: latitude!,
      longitude: longitude!,
    );
  }

  static RecentSearchModel fromPlaceSuggestion({
    required String query,
    required PlaceSuggestion suggestion,
  }) {
    return RecentSearchModel(
      id: '${suggestion.id}_${DateTime.now().millisecondsSinceEpoch}',
      query: query,
      timestamp: DateTime.now(),
      placeId: suggestion.id,
      placeName: suggestion.name,
      placeAddress: suggestion.address,
      latitude: suggestion.latitude,
      longitude: suggestion.longitude,
    );
  }

  static RecentSearchModel fromQuery(String query) {
    return RecentSearchModel(
      id: 'query_${DateTime.now().millisecondsSinceEpoch}_$query',
      query: query,
      timestamp: DateTime.now(),
    );
  }
}
