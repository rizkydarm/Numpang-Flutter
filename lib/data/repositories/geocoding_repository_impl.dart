import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import 'package:numpang_app/core/errors/failures.dart';
import 'package:numpang_app/data/datasources/geocoding_cache.dart';
import 'package:numpang_app/data/repositories/geocode_xyz_geocoding_repository.dart';
import 'package:numpang_app/data/repositories/mapbox_geocoding_repository.dart';
import 'package:numpang_app/data/repositories/nominatim_geocoding_repository.dart';
import 'package:numpang_app/domain/entities/place_details.dart';
import 'package:numpang_app/domain/entities/place_suggestion.dart';
import 'package:numpang_app/domain/repositories/geocoding_repository.dart';

enum GeocodingProvider { nominatim, mapbox, geocodeXyz }

class GeocodingRepositoryImpl implements GeocodingRepository {
  GeocodingRepositoryImpl({
    required Dio dio,
    required GeocodingCache cache,
    String? mapboxAccessToken,
    String? geocodeXyzApiKey,
    GeocodingProvider primaryProvider = GeocodingProvider.nominatim,
  }) : _nominatimRepo = NominatimGeocodingRepository(dio, cache),
       _mapboxRepo = mapboxAccessToken != null
           ? MapboxGeocodingRepository(dio, cache, mapboxAccessToken)
           : null,
       _geocodeXyzRepo = GeocodeXyzGeocodingRepository(
         dio,
         cache,
         apiKey: geocodeXyzApiKey,
       ),
       _primaryProvider = primaryProvider;
  final NominatimGeocodingRepository _nominatimRepo;
  final MapboxGeocodingRepository? _mapboxRepo;
  final GeocodeXyzGeocodingRepository _geocodeXyzRepo;
  final GeocodingProvider _primaryProvider;

  @override
  Future<Either<Failure, LatLng>> searchAddress(String query) async {
    // Helper to check if error is auth error (403/401)
    bool isAuthError(Either<Failure, dynamic> result) => result.fold(
      (failure) =>
          failure is ServerFailure &&
          (failure.code == 403 || failure.code == 401),
      (_) => false,
    );

    // Try primary provider first
    if (_primaryProvider == GeocodingProvider.mapbox && _mapboxRepo != null) {
      final result = await _mapboxRepo.searchAddress(query);
      if (!isAuthError(result) && result.isRight()) return result;
    } else if (_primaryProvider == GeocodingProvider.geocodeXyz) {
      final result = await _geocodeXyzRepo.searchAddress(query);
      if (result.isRight()) return result;
    }

    // Try Mapbox if available (new order: 1st fallback)
    if (_mapboxRepo != null) {
      final mapboxResult = await _mapboxRepo.searchAddress(query);
      if (!isAuthError(mapboxResult) && mapboxResult.isRight())
        return mapboxResult;
    }

    // Geocode.xyz disabled due to throttling - skip to Nominatim

    // Fallback to Nominatim
    return _nominatimRepo.searchAddress(query);
  }

  @override
  Future<Either<Failure, String>> reverseGeocode(LatLng position) async {
    // Helper to check if error is auth error (403/401)
    bool isAuthError(Either<Failure, dynamic> result) => result.fold(
      (failure) =>
          failure is ServerFailure &&
          (failure.code == 403 || failure.code == 401),
      (_) => false,
    );

    // Try primary provider first
    if (_primaryProvider == GeocodingProvider.mapbox && _mapboxRepo != null) {
      final result = await _mapboxRepo.reverseGeocode(position);
      if (!isAuthError(result) && result.isRight()) return result;
    } else if (_primaryProvider == GeocodingProvider.geocodeXyz) {
      final result = await _geocodeXyzRepo.reverseGeocode(position);
      if (result.isRight()) return result;
    }

    // Try Mapbox if available (new order: 1st fallback)
    if (_mapboxRepo != null) {
      final mapboxResult = await _mapboxRepo.reverseGeocode(position);
      if (!isAuthError(mapboxResult) && mapboxResult.isRight())
        return mapboxResult;
    }

    // Geocode.xyz disabled due to throttling - skip to Nominatim

    // Fallback to Nominatim
    return _nominatimRepo.reverseGeocode(position);
  }

  @override
  Future<Either<Failure, List<PlaceSuggestion>>> autocomplete(
    String input,
  ) async {
    // Helper to check if error is auth error (403/401)
    bool isAuthError(Either<Failure, dynamic> result) => result.fold(
      (failure) =>
          failure is ServerFailure &&
          (failure.code == 403 || failure.code == 401),
      (_) => false,
    );

    log('[GeocodingRepository] autocomplete: "$input"');

    // Try primary provider first
    if (_primaryProvider == GeocodingProvider.mapbox && _mapboxRepo != null) {
      log('[GeocodingRepository] Trying Mapbox (primary)...');
      final result = await _mapboxRepo.autocomplete(input);
      if (!isAuthError(result) &&
          result.isRight() &&
          result.getOrElse(() => []).isNotEmpty) {
        log('[GeocodingRepository] Mapbox success');
        return result;
      }
      log(
        '[GeocodingRepository] Mapbox failed (auth error or empty), falling back...',
      );
    }

    // Try Mapbox if available (new order: 1st fallback)
    if (_mapboxRepo != null) {
      log('[GeocodingRepository] Trying Mapbox (fallback)...');
      final mapboxResult = await _mapboxRepo.autocomplete(input);
      if (!isAuthError(mapboxResult) &&
          mapboxResult.isRight() &&
          mapboxResult.getOrElse(() => []).isNotEmpty) {
        log('[GeocodingRepository] Mapbox fallback success');
        return mapboxResult;
      }
      log(
        '[GeocodingRepository] Mapbox fallback failed (auth error or empty), falling back...',
      );
    }

    // Geocode.xyz disabled due to throttling - skip to Nominatim
    log('[GeocodingRepository] Skipping Geocode.xyz (disabled)');

    // Fallback to Nominatim
    log('[GeocodingRepository] Trying Nominatim...');
    final nominatimResult = await _nominatimRepo.autocomplete(input);
    nominatimResult.fold(
      (failure) =>
          log('[GeocodingRepository] Nominatim failed: ${failure.message}'),
      (suggestions) => log(
        '[GeocodingRepository] Nominatim success: ${suggestions.length} suggestions',
      ),
    );
    return nominatimResult;
  }

  @override
  Future<Either<Failure, PlaceDetails>> getPlaceDetails(String placeId) async {
    // Helper to check if error is auth error (403/401)
    bool isAuthError(Either<Failure, dynamic> result) => result.fold(
      (failure) =>
          failure is ServerFailure &&
          (failure.code == 403 || failure.code == 401),
      (_) => false,
    );

    // Try primary provider first
    if (_primaryProvider == GeocodingProvider.mapbox && _mapboxRepo != null) {
      final result = await _mapboxRepo.getPlaceDetails(placeId);
      if (!isAuthError(result) && result.isRight()) return result;
    } else if (_primaryProvider == GeocodingProvider.geocodeXyz) {
      final result = await _geocodeXyzRepo.getPlaceDetails(placeId);
      if (result.isRight()) return result;
    }

    // Try Mapbox if available (new order: 1st fallback)
    if (_mapboxRepo != null) {
      final mapboxResult = await _mapboxRepo.getPlaceDetails(placeId);
      if (!isAuthError(mapboxResult) && mapboxResult.isRight())
        return mapboxResult;
    }

    // Geocode.xyz disabled due to throttling - skip to Nominatim

    // Fallback to Nominatim
    return _nominatimRepo.getPlaceDetails(placeId);
  }
}
