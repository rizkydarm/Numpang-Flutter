import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:numpang_app/core/errors/failures.dart';
import 'package:numpang_app/domain/entities/destination.dart';
import 'package:numpang_app/domain/repositories/destination_repository.dart';
import 'package:numpang_app/domain/usecases/get_destinations_usecase.dart';

import 'get_destinations_usecase_test.mocks.dart';

@GenerateMocks([DestinationRepository])
void main() {
  late GetDestinationsUseCase useCase;
  late MockDestinationRepository mockRepository;

  setUp(() {
    mockRepository = MockDestinationRepository();
    useCase = GetDestinationsUseCase(mockRepository);
  });

  final tDestinations = [
    Destination(
      id: '1',
      name: 'Test Location 1',
      address: '123 Test St',
      latitude: 37.7749,
      longitude: -122.4194,
      createdAt: DateTime(2024),
    ),
    Destination(
      id: '2',
      name: 'Test Location 2',
      address: '456 Test Ave',
      latitude: 37.7849,
      longitude: -122.4094,
      createdAt: DateTime(2024, 1, 2),
    ),
  ];

  test('should get list of destinations from repository', () async {
    when(mockRepository.getDestinations())
        .thenAnswer((_) async => Right(tDestinations));

    final result = await useCase();

    expect(result, Right(tDestinations));
    verify(mockRepository.getDestinations());
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when getting destinations fails', () async {
    const tFailure = CacheFailure(message: 'Cache error');
    when(mockRepository.getDestinations())
        .thenAnswer((_) async => const Left(tFailure));

    final result = await useCase();

    expect(result, const Left(tFailure));
    verify(mockRepository.getDestinations());
  });
}
