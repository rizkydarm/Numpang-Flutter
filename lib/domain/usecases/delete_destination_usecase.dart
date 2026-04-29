import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../repositories/destination_repository.dart';

class DeleteDestinationUseCase {
  final DestinationRepository repository;

  DeleteDestinationUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) {
    return repository.deleteDestination(id);
  }
}
