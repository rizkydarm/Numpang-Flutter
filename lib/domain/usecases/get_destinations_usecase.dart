import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/destination.dart';
import '../repositories/destination_repository.dart';

class GetDestinationsUseCase {
  final DestinationRepository repository;

  GetDestinationsUseCase(this.repository);

  Future<Either<Failure, List<Destination>>> call() {
    return repository.getDestinations();
  }
}
