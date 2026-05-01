import 'package:dartz/dartz.dart';
import 'package:numpang_app/core/errors/failures.dart';
import 'package:numpang_app/domain/entities/destination.dart';

abstract class DestinationRepository {
  Future<Either<Failure, Destination>> addDestination(Destination destination);
  Future<Either<Failure, List<Destination>>> getDestinations();
  Future<Either<Failure, void>> deleteDestination(String id);
}
