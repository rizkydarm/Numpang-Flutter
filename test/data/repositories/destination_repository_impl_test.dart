import 'package:flutter_test/flutter_test.dart';

import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:numpang_app/core/errors/failures.dart';
import 'package:numpang_app/data/datasources/destination_local_datasource.dart';
import 'package:numpang_app/data/datasources/destination_remote_datasource.dart';
import 'package:numpang_app/data/models/destination_model.dart';
import 'package:numpang_app/data/repositories/destination_repository_impl.dart';
import 'package:numpang_app/domain/entities/destination.dart';

import 'destination_repository_impl_test.mocks.dart';

@GenerateMocks([DestinationLocalDataSource, DestinationRemoteDataSource])
void main() {
  late DestinationRepositoryImpl repository;
  late MockDestinationLocalDataSource mockLocal;
  late MockDestinationRemoteDataSource mockRemote;

  setUp(() {
    mockLocal = MockDestinationLocalDataSource();
    mockRemote = MockDestinationRemoteDataSource();
    repository = DestinationRepositoryImpl(
      localDataSource: mockLocal,
      remoteDataSource: mockRemote,
    );
  });

  final testDestination = Destination(
    id: '1',
    name: 'Test',
    address: '123 Test St',
    latitude: 40.7128,
    longitude: -74.0060,
    createdAt: DateTime(2024),
  );

  final testModel = DestinationModel.fromEntity(testDestination);

  group('addDestination', () {
    test('should add to local and return entity', () async {
      when(mockLocal.addDestination(any))
          .thenAnswer((_) async => testModel);
      when(mockRemote.addDestination(any))
          .thenAnswer((_) async => testModel);

      final result = await repository.addDestination(testDestination);

      expect(result.isRight(), true);
      verify(mockLocal.addDestination(any)).called(1);
    });

    test('should return CacheFailure on local error', () async {
      when(mockLocal.addDestination(any)).thenThrow(Exception('DB Error'));

      final result = await repository.addDestination(testDestination);

      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<CacheFailure>()),
        (r) => fail('Should not succeed'),
      );
    });

    test('should not fail when remote fails', () async {
      when(mockLocal.addDestination(any))
          .thenAnswer((_) async => testModel);
      when(mockRemote.addDestination(any)).thenThrow(Exception('Network Error'));

      final result = await repository.addDestination(testDestination);

      expect(result.isRight(), true);
    });
  });

  group('getDestinations', () {
    test('should return list of entities', () async {
      when(mockLocal.getDestinations())
          .thenAnswer((_) async => [testModel]);

      final result = await repository.getDestinations();

      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Should not fail'),
        (r) => expect(r.length, 1),
      );
    });

    test('should return CacheFailure on error', () async {
      when(mockLocal.getDestinations()).thenThrow(Exception('DB Error'));

      final result = await repository.getDestinations();

      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<CacheFailure>()),
        (r) => fail('Should not succeed'),
      );
    });
  });

  group('deleteDestination', () {
    test('should delete and return void', () async {
      when(mockLocal.deleteDestination(any))
          .thenAnswer((_) async {});
      when(mockRemote.deleteDestination(any))
          .thenAnswer((_) async {});

      final result = await repository.deleteDestination('1');

      expect(result.isRight(), true);
      verify(mockLocal.deleteDestination('1')).called(1);
    });
  });
}
