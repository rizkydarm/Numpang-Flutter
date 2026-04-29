import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/user_location.dart';

abstract class LocationRepository {
  Future<Either<Failure, UserLocation>> getCurrentLocation();
  Stream<UserLocation> getLocationStream();
}
