import 'package:dartz/dartz.dart';
import 'package:numpang_app/core/errors/failures.dart';
import 'package:numpang_app/domain/entities/destination.dart';
import 'package:numpang_app/domain/repositories/destination_repository.dart';

class GetDestinationsUseCase {

  GetDestinationsUseCase(this.repository);
  final DestinationRepository repository;

  Future<Either<Failure, List<Destination>>> call() {
    return repository.getDestinations();
  }
}
