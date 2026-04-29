import 'package:flutter_test/flutter_test.dart';
import 'package:numpang_app/data/datasources/destination_local_datasource.dart';
import 'package:numpang_app/data/models/destination_model.dart';

void main() {
  group('InMemoryDestinationDataSource', () {
    late InMemoryDestinationDataSource dataSource;

    setUp(() {
      dataSource = InMemoryDestinationDataSource();
    });

    final testDestination = DestinationModel(
      id: '1',
      name: 'Test Location',
      address: '123 Test St',
      latitude: 40.7128,
      longitude: -74.0060,
      createdAt: DateTime(2024, 1, 1),
    );

    test('should add destination', () async {
      final result = await dataSource.addDestination(testDestination);
      expect(result, equals(testDestination));
    });

    test('should get all destinations', () async {
      await dataSource.addDestination(testDestination);
      final results = await dataSource.getDestinations();
      expect(results.length, 1);
      expect(results[0].id, '1');
    });

    test('should delete destination by id', () async {
      await dataSource.addDestination(testDestination);
      await dataSource.deleteDestination('1');
      final results = await dataSource.getDestinations();
      expect(results, isEmpty);
    });

    test('should clear all destinations', () async {
      await dataSource.addDestination(testDestination);
      await dataSource.clearAll();
      final results = await dataSource.getDestinations();
      expect(results, isEmpty);
    });

    test('should return immutable list', () async {
      await dataSource.addDestination(testDestination);
      final results = await dataSource.getDestinations();
      expect(() => results.add(testDestination), throwsUnsupportedError);
    });
  });
}
