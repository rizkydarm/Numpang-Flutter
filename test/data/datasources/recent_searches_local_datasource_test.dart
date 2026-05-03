import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:numpang_app/data/datasources/recent_searches_local_datasource.dart';
import 'package:numpang_app/data/models/recent_search_model.dart';
import 'package:numpang_app/domain/entities/place_suggestion.dart';

// Simple test double that extends RecentSearchModel and implements delete
class TestableRecentSearch extends RecentSearchModel {
  TestableRecentSearch({
    required super.id,
    required super.query,
    required super.timestamp,
    super.placeId,
    super.placeName,
    super.placeAddress,
    super.latitude,
    super.longitude,
  });

  int deleteCallCount = 0;

  @override
  Future<void> delete() async {
    deleteCallCount++;
  }
}

class MockBox extends Mock implements Box<RecentSearchModel> {}

void main() {
  late RecentSearchesLocalDataSourceImpl dataSource;
  late MockBox mockBox;

  setUp(() {
    mockBox = MockBox();
    dataSource = RecentSearchesLocalDataSourceImpl(box: mockBox);
  });

  final testSuggestion = const PlaceSuggestion(
    id: '123',
    name: 'Test Place',
    address: '123 Test St',
    latitude: 40.7128,
    longitude: -74.0060,
  );

  group('getRecentSearches', () {
    test('returns sorted list by timestamp descending', () async {
      final older = TestableRecentSearch(
        id: 'older',
        query: 'older',
        timestamp: DateTime(2024, 1, 1),
      );
      final newer = TestableRecentSearch(
        id: 'newer',
        query: 'newer',
        timestamp: DateTime(2024, 2, 1),
      );

      when(() => mockBox.values).thenReturn([older, newer]);

      final result = await dataSource.getRecentSearches();

      expect(result.length, 2);
      expect(result[0].id, 'newer');
      expect(result[1].id, 'older');
    });

    test('returns max 20 items', () async {
      final items = List.generate(
        25,
        (i) => TestableRecentSearch(
          id: 'id_$i',
          query: 'query $i',
          timestamp: DateTime(2024, 1, i + 1),
        ),
      );

      when(() => mockBox.values).thenReturn(items);

      final result = await dataSource.getRecentSearches();

      expect(result.length, 20);
    });
  });

  group('addSearch', () {
    test('does nothing for empty query', () async {
      await dataSource.addSearch('');
      verifyNoMoreInteractions(mockBox);
    });

    test('adds search with trimmed query', () async {
      when(() => mockBox.values).thenReturn([]);
      when(() => mockBox.add(any())).thenAnswer((_) async => 0);

      await dataSource.addSearch('  test query  ');

      verify(() => mockBox.add(captureAny())).called(1);
    });

    test('removes existing query before adding', () async {
      final existing = TestableRecentSearch(
        id: 'existing',
        query: 'test query',
        timestamp: DateTime(2024, 1, 1),
      );

      when(() => mockBox.values).thenReturn([existing]);
      when(() => mockBox.add(any())).thenAnswer((_) async => 0);

      await dataSource.addSearch('test query', suggestion: testSuggestion);

      expect(existing.deleteCallCount, 1);
    });

    test('creates model with suggestion data', () async {
      when(() => mockBox.values).thenReturn([]);
      when(() => mockBox.add(any())).thenAnswer((_) async => 0);

      await dataSource.addSearch('test', suggestion: testSuggestion);

      final captured = verify(() => mockBox.add(captureAny())).captured;
      final model = captured.first as RecentSearchModel;
      expect(model.query, 'test');
      expect(model.placeId, '123');
      expect(model.placeName, 'Test Place');
      expect(model.latitude, 40.7128);
      expect(model.longitude, -74.0060);
    });

    test('creates model without suggestion when null', () async {
      when(() => mockBox.values).thenReturn([]);
      when(() => mockBox.add(any())).thenAnswer((_) async => 0);

      await dataSource.addSearch('plain query');

      final captured = verify(() => mockBox.add(captureAny())).captured;
      final model = captured.first as RecentSearchModel;
      expect(model.query, 'plain query');
      expect(model.placeId, null);
    });
  });

  group('removeSearch', () {
    test('removes item by id', () async {
      final mockItem = TestableRecentSearch(
        id: '123_123456',
        query: 'test',
        timestamp: DateTime(2024, 1, 1),
      );

      when(() => mockBox.values).thenReturn([mockItem]);

      await dataSource.removeSearch('123_123456');

      expect(mockItem.deleteCallCount, 1);
    });

    test('throws when item not found', () async {
      when(() => mockBox.values).thenReturn([]);

      expect(
        () => dataSource.removeSearch('nonexistent'),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('clearAllSearches', () {
    test('clears all items', () async {
      when(() => mockBox.clear()).thenAnswer((_) async => 5);

      await dataSource.clearAllSearches();

      verify(() => mockBox.clear()).called(1);
    });
  });
}
