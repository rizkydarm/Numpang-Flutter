import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/place_suggestion.dart';
import '../../domain/repositories/geocoding_repository.dart';
import '../datasources/geocoding_cache.dart';

class MapboxGeocodingRepository implements GeocodingRepository {
  final Dio _dio;
  final GeocodingCache _cache;
  final String _accessToken;
  static const String _baseUrl = 'https://api.mapbox.com/search/geocode/v6';

  MapboxGeocodingRepository(this._dio, this._cache, this._accessToken);

  @override
  Future<Either<Failure, LatLng>> searchAddress(String query) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/forward',
        queryParameters: {
          'q': query,
          'access_token': _accessToken,
          'limit': 1,
        },
      );

      if (response.statusCode == 200 && response.data is Map) {
        final features = response.data['features'] as List?;
        if (features != null && features.isNotEmpty) {
          final geometry = features[0]['geometry'] as Map?;
          if (geometry != null) {
            final coordinates = geometry['coordinates'] as List?;
            if (coordinates != null && coordinates.length >= 2) {
              final lon = double.tryParse(coordinates[0].toString());
              final lat = double.tryParse(coordinates[1].toString());
              if (lat != null && lon != null) {
                return Right(LatLng(lat, lon));
              }
            }
          }
        }
      }

      return const Left(ServerFailure(message: 'No results found'));
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
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
      final response = await _dio.get(
        '$_baseUrl/reverse',
        queryParameters: {
          'longitude': position.longitude,
          'latitude': position.latitude,
          'access_token': _accessToken,
        },
      );

      if (response.statusCode == 200 && response.data is Map) {
        final features = response.data['features'] as List?;
        if (features != null && features.isNotEmpty) {
          final properties = features[0]['properties'] as Map?;
          final fullAddress = properties?['full_address'] as String?;
          if (fullAddress != null) {
            _cache.setReverseGeocode(position, fullAddress);
            return Right(fullAddress);
          }
        }
      }

      return const Left(ServerFailure(message: 'No address found'));
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return const Left(UnknownFailure(message: 'Unexpected error'));
    }
  }

  @override
  Future<Either<Failure, List<PlaceSuggestion>>> autocomplete(String input) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/forward',
        queryParameters: {
          'q': input,
          'access_token': _accessToken,
          'limit': 5,
          'autocomplete': true,
        },
      );

      if (response.statusCode == 200 && response.data is Map) {
        final features = response.data['features'] as List?;
        if (features != null) {
          final results = features.map((item) {
            final id = item['id']?.toString() ?? '';
            final properties = item['properties'] as Map? ?? {};
            final name = properties['name']?.toString() ?? '';
            final fullAddress = properties['full_address']?.toString() ?? '';

            final geometry = item['geometry'] as Map? ?? {};
            final coordinates = geometry['coordinates'] as List? ?? [0, 0];
            final lon = double.tryParse(coordinates[0].toString()) ?? 0;
            final lat = double.tryParse(coordinates[1].toString()) ?? 0;

            return PlaceSuggestion(
              id: id,
              name: name,
              address: fullAddress,
              latitude: lat,
              longitude: lon,
            );
          }).toList();

          return Right(results);
        }
      }

      return const Right([]);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return const Left(UnknownFailure(message: 'Unexpected error'));
    }
  }

  Failure _handleDioError(DioException e) {
    if (e.response?.statusCode == 429) {
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
}
