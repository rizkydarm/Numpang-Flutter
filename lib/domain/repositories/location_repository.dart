import 'package:dartz/dartz.dart';
import 'package:numpang_app/core/errors/failures.dart';
import 'package:numpang_app/domain/entities/user_location.dart';

abstract class LocationRepository {
  Future<Either<Failure, UserLocation>> getCurrentLocation();
  Stream<UserLocation> getLocationStream();
}
