import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:numpang_app/core/errors/failures.dart';
import 'package:numpang_app/domain/repositories/destination_repository.dart';
import 'package:numpang_app/domain/usecases/delete_destination_usecase.dart';
import 'delete_destination_usecase_test.mocks.dart';

@GenerateMocks([DestinationRepository])
void main() {
  late DeleteDestinationUseCase useCase;
  late MockDestinationRepository mockRepository;

  setUp(() {
    mockRepository = MockDestinationRepository();
    useCase = DeleteDestinationUseCase(mockRepository);
  });

  const tId = '1';

  test('should delete destination through repository', () async {
    when(mockRepository.deleteDestination(tId))
        .thenAnswer((_) async => const Right(null));

    final result = await useCase(tId);

    expect(result, const Right(null));
    verify(mockRepository.deleteDestination(tId));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when deleting destination fails', () async {
    const tFailure = CacheFailure(message: 'Cache error');
    when(mockRepository.deleteDestination(tId))
        .thenAnswer((_) async => const Left(tFailure));

    final result = await useCase(tId);

    expect(result, const Left(tFailure));
    verify(mockRepository.deleteDestination(tId));
  });
}
