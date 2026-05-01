import 'package:dartz/dartz.dart';
import 'package:numpang_app/core/errors/failures.dart';
import 'package:numpang_app/data/datasources/destination_local_datasource.dart';
import 'package:numpang_app/data/datasources/destination_remote_datasource.dart';
import 'package:numpang_app/data/models/destination_model.dart';
import 'package:numpang_app/domain/entities/destination.dart';
import 'package:numpang_app/domain/repositories/destination_repository.dart';

class DestinationRepositoryImpl implements DestinationRepository {

  DestinationRepositoryImpl({
    required DestinationLocalDataSource localDataSource,
    required DestinationRemoteDataSource remoteDataSource,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource;
  final DestinationLocalDataSource _localDataSource;
  final DestinationRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, Destination>> addDestination(Destination destination) async {
    try {
      final model = DestinationModel.fromEntity(destination);
      final result = await _localDataSource.addDestination(model);

      try {
        await _remoteDataSource.addDestination(model);
      } catch (_) {
        // Cloud sync failure shouldn't block local operation
      }

      return Right(result.toEntity());
    } catch (e) {
      return const Left(CacheFailure(message: 'Failed to save destination'));
    }
  }

  @override
  Future<Either<Failure, List<Destination>>> getDestinations() async {
    try {
      final models = await _localDataSource.getDestinations();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return const Left(CacheFailure(message: 'Failed to load destinations'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDestination(String id) async {
    try {
      await _localDataSource.deleteDestination(id);

      try {
        await _remoteDataSource.deleteDestination(id);
      } catch (_) {
        // Cloud sync failure shouldn't block local operation
      }

      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure(message: 'Failed to delete destination'));
    }
  }
}
