import 'package:latlong2/latlong.dart';
import 'package:numpang_app/core/utils/lru_cache.dart';

class GeocodingCache {

  GeocodingCache()
      : _reverseGeocodeCache = LRUCache<String, String>(capacity: _capacity, ttl: _ttl),
        _searchCache = LRUCache<String, List<Map<String, dynamic>>>(capacity: _capacity, ttl: _ttl);
  static const int _capacity = 100;
  static const Duration _ttl = Duration(hours: 24);

  final LRUCache<String, String> _reverseGeocodeCache;
  final LRUCache<String, List<Map<String, dynamic>>> _searchCache;

  String? getReverseGeocode(LatLng position) {
    final key = '${position.latitude},${position.longitude}';
    return _reverseGeocodeCache.get(key);
  }

  void setReverseGeocode(LatLng position, String address) {
    final key = '${position.latitude},${position.longitude}';
    _reverseGeocodeCache.put(key, address);
  }

  List<Map<String, dynamic>>? getSearchResults(String query) {
    return _searchCache.get(query);
  }

  void setSearchResults(String query, List<Map<String, dynamic>> results) {
    _searchCache.put(query, results);
  }

  void clear() {
    _reverseGeocodeCache.clear();
    _searchCache.clear();
  }
}
