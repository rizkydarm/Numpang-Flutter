class LRUCacheEntry<V> {
  final V value;
  final DateTime timestamp;

  LRUCacheEntry(this.value) : timestamp = DateTime.now();
}

class LRUCache<K, V> {
  final int capacity;
  final Duration? ttl;
  final Map<K, LRUCacheEntry<V>> _cache = {};
  final List<K> _keys = [];

  LRUCache({required this.capacity, this.ttl});

  V? get(K key) {
    _cleanupExpired();
    final entry = _cache[key];
    if (entry == null) return null;

    if (ttl != null && DateTime.now().difference(entry.timestamp) > ttl!) {
      _remove(key);
      return null;
    }

    _updateAccessOrder(key);
    return entry.value;
  }

  void put(K key, V value) {
    _cleanupExpired();
    if (_cache.containsKey(key)) {
      _cache[key] = LRUCacheEntry(value);
      _updateAccessOrder(key);
    } else {
      if (_cache.length >= capacity) {
        _evictLRU();
      }
      _cache[key] = LRUCacheEntry(value);
      _keys.add(key);
    }
  }

  void clear() {
    _cache.clear();
    _keys.clear();
  }

  int get length => _cache.length;

  bool containsKey(K key) {
    _cleanupExpired();
    final entry = _cache[key];
    if (entry == null) return false;
    if (ttl != null && DateTime.now().difference(entry.timestamp) > ttl!) {
      _remove(key);
      return false;
    }
    return true;
  }

  void _remove(K key) {
    _cache.remove(key);
    _keys.remove(key);
  }

  void _updateAccessOrder(K key) {
    _keys.remove(key);
    _keys.add(key);
  }

  void _evictLRU() {
    if (_keys.isEmpty) return;
    final lruKey = _keys.first;
    _remove(lruKey);
  }

  void _cleanupExpired() {
    if (ttl == null) return;
    final now = DateTime.now();
    final expired = _cache.entries
        .where((e) => now.difference(e.value.timestamp) > ttl!)
        .map((e) => e.key)
        .toList();
    for (final key in expired) {
      _remove(key);
    }
  }
}
