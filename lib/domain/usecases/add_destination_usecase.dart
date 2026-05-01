import 'package:dartz/dartz.dart';
import 'package:numpang_app/core/errors/failures.dart';
import 'package:numpang_app/domain/entities/destination.dart';
import 'package:numpang_app/domain/repositories/destination_repository.dart';

class AddDestinationUseCase {

  AddDestinationUseCase(this.repository);
  final DestinationRepository repository;

  Future<Either<Failure, Destination>> call(Destination destination) {
    return repository.addDestination(destination);
  }
}
