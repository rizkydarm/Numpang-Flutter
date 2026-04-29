import 'package:flutter_test/flutter_test.dart';
import 'package:numpang_app/core/utils/lru_cache.dart';

void main() {
  group('LRUCache', () {
    test('should store and retrieve values', () {
      final cache = LRUCache<String, int>(capacity: 3);
      cache.put('a', 1);
      cache.put('b', 2);

      expect(cache.get('a'), 1);
      expect(cache.get('b'), 2);
    });

    test('should evict LRU when capacity exceeded', () {
      final cache = LRUCache<String, int>(capacity: 2);
      cache.put('a', 1);
      cache.put('b', 2);
      cache.put('c', 3);

      expect(cache.get('a'), null);
      expect(cache.get('b'), 2);
      expect(cache.get('c'), 3);
    });

    test('should update access order on get', () {
      final cache = LRUCache<String, int>(capacity: 2);
      cache.put('a', 1);
      cache.put('b', 2);
      cache.get('a'); // 'a' becomes most recently used
      cache.put('c', 3);

      expect(cache.get('a'), 1);
      expect(cache.get('b'), null);
      expect(cache.get('c'), 3);
    });

    test('should respect TTL', () async {
      final cache = LRUCache<String, int>(
        capacity: 3,
        ttl: const Duration(milliseconds: 50),
      );
      cache.put('a', 1);

      expect(cache.get('a'), 1);

      await Future.delayed(const Duration(milliseconds: 60));

      expect(cache.get('a'), null);
    });

    test('should check containsKey correctly', () {
      final cache = LRUCache<String, int>(capacity: 2);
      cache.put('a', 1);

      expect(cache.containsKey('a'), true);
      expect(cache.containsKey('b'), false);
    });

    test('should clear all entries', () {
      final cache = LRUCache<String, int>(capacity: 3);
      cache.put('a', 1);
      cache.put('b', 2);
      cache.clear();

      expect(cache.get('a'), null);
      expect(cache.get('b'), null);
      expect(cache.length, 0);
    });
  });
}
