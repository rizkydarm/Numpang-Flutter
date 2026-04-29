import 'package:dartz/dartz.dart';
import 'package:latlong2/latlong.dart';
import 'package:numpang_app/core/errors/failures.dart';
import 'package:numpang_app/domain/entities/place_suggestion.dart';
import 'package:numpang_app/domain/repositories/geocoding_repository.dart';

class MockGeocodingRepository implements GeocodingRepository {
  final List<PlaceSuggestion> _mockSuggestions = [
    const PlaceSuggestion(
      id: '1',
      name: 'Central Park',
      address: 'Central Park, New York, NY, USA',
      latitude: 40.7829,
      longitude: -73.9654,
    ),
    const PlaceSuggestion(
      id: '2',
      name: 'Times Square',
      address: 'Times Square, New York, NY, USA',
      latitude: 40.7580,
      longitude: -73.9855,
    ),
  ];

  bool shouldFail = false;
  Failure? failureToReturn;

  @override
  Future<Either<Failure, LatLng>> searchAddress(String query) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (shouldFail) {
      return Left(failureToReturn ?? const ServerFailure(message: 'Mock error'));
    }
    return const Right(LatLng(40.7128, -74.0060));
  }

  @override
  Future<Either<Failure, String>> reverseGeocode(LatLng position) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (shouldFail) {
      return Left(failureToReturn ?? const ServerFailure(message: 'Mock error'));
    }
    return const Right('Mock Address, New York, NY, USA');
  }

  @override
  Future<Either<Failure, List<PlaceSuggestion>>> autocomplete(String input) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (shouldFail) {
      return Left(failureToReturn ?? const ServerFailure(message: 'Mock error'));
    }
    if (input.isEmpty) return const Right([]);
    return Right(_mockSuggestions
        .where((s) => s.name.toLowerCase().contains(input.toLowerCase()))
        .toList());
  }

  void reset() {
    shouldFail = false;
    failureToReturn = null;
  }
}
