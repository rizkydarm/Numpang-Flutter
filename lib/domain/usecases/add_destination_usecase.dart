import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/destination.dart';
import '../repositories/destination_repository.dart';

class AddDestinationUseCase {
  final DestinationRepository repository;

  AddDestinationUseCase(this.repository);

  Future<Either<Failure, Destination>> call(Destination destination) {
    return repository.addDestination(destination);
  }
}
