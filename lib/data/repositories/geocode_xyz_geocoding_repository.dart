import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import 'package:numpang_app/core/errors/failures.dart';
import 'package:numpang_app/data/datasources/geocoding_cache.dart';
import 'package:numpang_app/domain/entities/place_details.dart';
import 'package:numpang_app/domain/entities/place_suggestion.dart';
import 'package:numpang_app/domain/repositories/geocoding_repository.dart';

class GeocodeXyzGeocodingRepository implements GeocodingRepository {
  GeocodeXyzGeocodingRepository(this._dio, this._cache, {String? apiKey})
    : _apiKey = apiKey;
  final Dio _dio;
  final GeocodingCache _cache;
  final String? _apiKey;
  static const String _baseUrl = 'https://geocode.xyz';

  @override
  Future<Either<Failure, LatLng>> searchAddress(String query) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/${Uri.encodeComponent(query)}',
        queryParameters: {
          'json': '1',
          if (_apiKey != null) 'auth': _apiKey,
        },
      );

      if (response.statusCode != null && response.statusCode! >= 400) {
        // Return empty result for throttling errors to allow fallback
        if (response.statusCode == 429) {
          return const Left(
            ServerFailure(message: 'Rate limit exceeded', code: 429),
          );
        }
        return Left(
          ServerFailure(message: 'Server error', code: response.statusCode),
        );
      }

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!;

        // Check for error response
        if (data['error'] != null) {
          final errorDesc = data['error']['description']?.toString();
          // Return empty result for throttling errors
          if (errorDesc?.contains('Throttled') == true) {
            return const Left(
              ServerFailure(message: 'Rate limit exceeded', code: 429),
            );
          }
          return Left(
            ServerFailure(
              message: errorDesc ?? 'No results found',
            ),
          );
        }

        final lat = double.tryParse(data['latt']?.toString() ?? '');
        final lon = double.tryParse(data['longt']?.toString() ?? '');

        if (lat != null && lon != null) {
          return Right(LatLng(lat, lon));
        }
      }

      return const Left(ServerFailure(message: 'No results found'));
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } on Exception catch (_) {
      return const Left(UnknownFailure(message: 'Unexpected error'));
    }
  }

  @override
  Future<Either<Failure, String>> reverseGeocode(LatLng position) async {
    final cached = _cache.getReverseGeocode(position);
    if (cached != null) {
      return Right(cached);
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/${position.latitude},${position.longitude}',
        queryParameters: {
          'json': '1',
          if (_apiKey != null) 'auth': _apiKey,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!;

        // Check for error response
        if (data['error'] != null) {
          return Left(
            ServerFailure(
              message:
                  data['error']['description']?.toString() ??
                  'No address found',
            ),
          );
        }

        // Build address from components
        final street = data['stnumber']?.toString();
        final streetName = data['staddress']?.toString();
        final city = data['city']?.toString();
        final state = data['state']?.toString();
        final country = data['country']?.toString();

        final addressParts = <String>[];
        if (street != null && streetName != null) {
          addressParts.add('$street $streetName');
        } else if (streetName != null) {
          addressParts.add(streetName);
        }
        if (city != null) addressParts.add(city);
        if (state != null) addressParts.add(state);
        if (country != null) addressParts.add(country);

        final address = addressParts.join(', ');

        if (address.isNotEmpty) {
          _cache.setReverseGeocode(position, address);
          return Right(address);
        }
      }

      return const Left(ServerFailure(message: 'No address found'));
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } on Exception catch (_) {
      return const Left(UnknownFailure(message: 'Unexpected error'));
    }
  }

  @override
  Future<Either<Failure, PlaceDetails>> getPlaceDetails(String placeId) async {
    // Geocode.xyz doesn't have a specific place details endpoint
    // We can use search with the place_id if available, otherwise return basic info
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/${Uri.encodeComponent(placeId)}',
        queryParameters: {
          'json': '1',
          'jsonp': '1',
          if (_apiKey != null) 'auth': _apiKey,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!;

        if (data['error'] != null) {
          return Left(
            ServerFailure(
              message:
                  data['error']['description']?.toString() ?? 'Place not found',
            ),
          );
        }

        final lat = double.tryParse(data['latt']?.toString() ?? '0') ?? 0;
        final lon = double.tryParse(data['longt']?.toString() ?? '0') ?? 0;

        // Build address from components
        final street = data['stnumber']?.toString();
        final streetName = data['staddress']?.toString();
        final city = data['city']?.toString();
        final state = data['state']?.toString();
        final country = data['country']?.toString();
        final postal = data['postal']?.toString();

        final addressParts = <String>[];
        if (street != null && streetName != null) {
          addressParts.add('$street $streetName');
        } else if (streetName != null) {
          addressParts.add(streetName);
        }
        if (city != null) addressParts.add(city);
        if (state != null) addressParts.add(state);
        if (postal != null) addressParts.add(postal);
        if (country != null) addressParts.add(country);

        final address = addressParts.join(', ');
        final name =
            data['standard']?['addresst']?.toString() ??
            data['alt']?['loc']?['addresst']?.toString() ??
            addressParts.firstOrNull ??
            'Unknown';

        return Right(
          PlaceDetails(
            id: placeId,
            name: name,
            address: address,
            latitude: lat,
            longitude: lon,
          ),
        );
      }

      return const Left(ServerFailure(message: 'Place not found'));
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } on Exception catch (_) {
      return const Left(UnknownFailure(message: 'Unexpected error'));
    }
  }

  @override
  Future<Either<Failure, List<PlaceSuggestion>>> autocomplete(
    String input,
  ) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/${Uri.encodeComponent(input)}',
        queryParameters: {
          'json': '1',
          'autocomplete': '1',
          'jsonp': '1',
          if (_apiKey != null) 'auth': _apiKey,
        },
      );

      if (response.statusCode != null && response.statusCode! >= 400) {
        // Return empty result for throttling errors to allow fallback
        if (response.statusCode == 429) {
          return const Right([]);
        }
        return Left(
          ServerFailure(message: 'Server error', code: response.statusCode),
        );
      }

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!;

        // Check for error or empty results
        if (data['error'] != null) {
          final errorDesc = data['error']['description']?.toString();
          // Return empty result for throttling errors
          if (errorDesc?.contains('Throttled') == true) {
            return const Right([]);
          }
          return const Right([]);
        }

        // Geocode.xyz autocomplete returns suggestions in 'suggestions' field
        final suggestions = data['suggestions'] as List<dynamic>?;
        if (suggestions != null && suggestions.isNotEmpty) {
          final results = suggestions.map((item) {
            final address = item.toString();
            return PlaceSuggestion(
              id: address.hashCode.toString(),
              name: address.split(',').first,
              address: address,
              latitude: 0, // Geocode.xyz autocomplete doesn't return coords
              longitude: 0,
            );
          }).toList();

          return Right(results);
        }

        // If no suggestions but we have a direct match
        if (data['latt'] != null && data['longt'] != null) {
          final address = _buildAddressFromComponents(data);
          final lat = double.tryParse(data['latt']?.toString() ?? '0') ?? 0;
          final lon = double.tryParse(data['longt']?.toString() ?? '0') ?? 0;

          return Right([
            PlaceSuggestion(
              id: '${lat}_$lon',
              name: address.split(',').first,
              address: address,
              latitude: lat,
              longitude: lon,
            ),
          ]);
        }
      }

      return const Right([]);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } on Exception catch (_) {
      return const Left(UnknownFailure(message: 'Unexpected error'));
    }
  }

  String _buildAddressFromComponents(Map<String, dynamic> data) {
    final street = data['stnumber']?.toString();
    final streetName = data['staddress']?.toString();
    final city = data['city']?.toString();
    final state = data['state']?.toString();
    final country = data['country']?.toString();

    final parts = <String>[];
    if (street != null && streetName != null) {
      parts.add('$street $streetName');
    } else if (streetName != null) {
      parts.add(streetName);
    }
    if (city != null) parts.add(city);
    if (state != null) parts.add(state);
    if (country != null) parts.add(country);

    return parts.join(', ');
  }

  Failure _handleDioError(DioException e) {
    if (e.response?.statusCode == 429 || e.response?.statusCode == 403) {
      return const ServerFailure(message: 'Rate limit exceeded', code: 429);
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const NetworkFailure(message: 'Connection timeout');
    }
    if (e.type == DioExceptionType.connectionError) {
      return const NetworkFailure(message: 'No internet connection');
    }
    return ServerFailure(
      message: e.message ?? 'Server error',
      code: e.response?.statusCode,
    );
  }

  @override
  void setPrimaryProvider(String provider) {
    // Geocode.xyz is always the primary for this repository
  }
}
