import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/place_suggestion.dart';
import '../../domain/repositories/geocoding_repository.dart';
import '../datasources/geocoding_cache.dart';
import 'mapbox_geocoding_repository.dart';
import 'nominatim_geocoding_repository.dart';

enum GeocodingProvider { nominatim, mapbox }

class GeocodingRepositoryImpl implements GeocodingRepository {
  final NominatimGeocodingRepository _nominatimRepo;
  final MapboxGeocodingRepository? _mapboxRepo;
  final GeocodingProvider _primaryProvider;

  GeocodingRepositoryImpl({
    required Dio dio,
    required GeocodingCache cache,
    String? mapboxAccessToken,
    GeocodingProvider primaryProvider = GeocodingProvider.nominatim,
  })  : _nominatimRepo = NominatimGeocodingRepository(dio, cache),
        _mapboxRepo = mapboxAccessToken != null
            ? MapboxGeocodingRepository(dio, cache, mapboxAccessToken)
            : null,
        _primaryProvider = primaryProvider;

  @override
  Future<Either<Failure, LatLng>> searchAddress(String query) async {
    if (_primaryProvider == GeocodingProvider.mapbox && _mapboxRepo != null) {
      final result = await _mapboxRepo!.searchAddress(query);
      if (result.isRight()) return result;
    }

    final nominatimResult = await _nominatimRepo.searchAddress(query);
    if (nominatimResult.isRight()) return nominatimResult;

    if (_mapboxRepo != null && _primaryProvider == GeocodingProvider.nominatim) {
      return await _mapboxRepo!.searchAddress(query);
    }

    return nominatimResult;
  }

  @override
  Future<Either<Failure, String>> reverseGeocode(LatLng position) async {
    if (_primaryProvider == GeocodingProvider.mapbox && _mapboxRepo != null) {
      final result = await _mapboxRepo!.reverseGeocode(position);
      if (result.isRight()) return result;
    }

    final nominatimResult = await _nominatimRepo.reverseGeocode(position);
    if (nominatimResult.isRight()) return nominatimResult;

    if (_mapboxRepo != null && _primaryProvider == GeocodingProvider.nominatim) {
      return await _mapboxRepo!.reverseGeocode(position);
    }

    return nominatimResult;
  }

  @override
  Future<Either<Failure, List<PlaceSuggestion>>> autocomplete(String input) async {
    if (_primaryProvider == GeocodingProvider.mapbox && _mapboxRepo != null) {
      final result = await _mapboxRepo!.autocomplete(input);
      if (result.isRight()) return result;
    }

    final nominatimResult = await _nominatimRepo.autocomplete(input);
    if (nominatimResult.isRight()) return nominatimResult;

    if (_mapboxRepo != null && _primaryProvider == GeocodingProvider.nominatim) {
      return await _mapboxRepo!.autocomplete(input);
    }

    return nominatimResult;
  }
}
