import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:numpang_app/core/errors/failures.dart';
import 'package:numpang_app/domain/entities/destination.dart';
import 'package:numpang_app/domain/repositories/destination_repository.dart';
import 'package:numpang_app/domain/usecases/add_destination_usecase.dart';
import 'add_destination_usecase_test.mocks.dart';

@GenerateMocks([DestinationRepository])
void main() {
  late AddDestinationUseCase useCase;
  late MockDestinationRepository mockRepository;

  setUp(() {
    mockRepository = MockDestinationRepository();
    useCase = AddDestinationUseCase(mockRepository);
  });

  final tDestination = Destination(
    id: '1',
    name: 'Test Location',
    address: '123 Test St',
    latitude: 37.7749,
    longitude: -122.4194,
    createdAt: DateTime(2024, 1, 1),
  );

  test('should add destination through repository', () async {
    when(mockRepository.addDestination(tDestination))
        .thenAnswer((_) async => Right(tDestination));

    final result = await useCase(tDestination);

    expect(result, Right(tDestination));
    verify(mockRepository.addDestination(tDestination));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when adding destination fails', () async {
    const tFailure = ServerFailure(message: 'Server error');
    when(mockRepository.addDestination(tDestination))
        .thenAnswer((_) async => const Left(tFailure));

    final result = await useCase(tDestination);

    expect(result, const Left(tFailure));
    verify(mockRepository.addDestination(tDestination));
  });
}
