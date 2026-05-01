import 'package:dartz/dartz.dart';
import 'package:numpang_app/core/errors/failures.dart';
import 'package:numpang_app/domain/repositories/destination_repository.dart';

class DeleteDestinationUseCase {

  DeleteDestinationUseCase(this.repository);
  final DestinationRepository repository;

  Future<Either<Failure, void>> call(String id) {
    return repository.deleteDestination(id);
  }
}
