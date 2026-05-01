import 'package:dartz/dartz.dart';
import 'package:latlong2/latlong.dart';
import 'package:numpang_app/core/errors/failures.dart';
import 'package:numpang_app/domain/entities/place_suggestion.dart';

abstract class GeocodingRepository {
  Future<Either<Failure, LatLng>> searchAddress(String query);
  Future<Either<Failure, String>> reverseGeocode(LatLng position);
  Future<Either<Failure, List<PlaceSuggestion>>> autocomplete(String input);
}
