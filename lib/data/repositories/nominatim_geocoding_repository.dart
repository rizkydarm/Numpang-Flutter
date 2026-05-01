import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import 'package:numpang_app/core/errors/failures.dart';
import 'package:numpang_app/data/datasources/geocoding_cache.dart';
import 'package:numpang_app/domain/entities/place_suggestion.dart';
import 'package:numpang_app/domain/repositories/geocoding_repository.dart';

class NominatimGeocodingRepository implements GeocodingRepository {

  NominatimGeocodingRepository(this._dio, this._cache);
  final Dio _dio;
  final GeocodingCache _cache;
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';

  @override
  Future<Either<Failure, LatLng>> searchAddress(String query) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/search',
        queryParameters: {'q': query, 'format': 'json', 'limit': 1},
      );

      if (response.statusCode != null && response.statusCode! >= 400) {
        return Left(
          ServerFailure(message: 'Server error', code: response.statusCode),
        );
      }

      if (response.statusCode == 200 &&
          response.data is List &&
          response.data?.isNotEmpty == true) {
        final result = response.data![0];
        final lat = double.tryParse(result['lat'].toString());
        final lon = double.tryParse(result['lon'].toString());

        if (lat != null && lon != null) {
          return Right(LatLng(lat, lon));
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
          'lat': position.latitude,
          'lon': position.longitude,
          'format': 'json',
        },
      );

      if (response.statusCode == 200 && response.data is Map) {
        final displayName = response.data['display_name'] as String?;
        if (displayName != null) {
          _cache.setReverseGeocode(position, displayName);
          return Right(displayName);
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
  Future<Either<Failure, List<PlaceSuggestion>>> autocomplete(
    String input,
  ) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/search',
        queryParameters: {'q': input, 'format': 'json', 'limit': 5},
      );

      if (response.statusCode == 200 && response.data is List) {
        final results = (response.data as List).map((item) {
          final placeId = item['place_id']?.toString() ?? '';
          final name =
              item['name']?.toString() ??
              item['display_name']?.toString() ??
              '';
          final address = item['display_name']?.toString() ?? '';
          final lat = double.tryParse(item['lat']?.toString() ?? '0') ?? 0;
          final lon = double.tryParse(item['lon']?.toString() ?? '0') ?? 0;

          return PlaceSuggestion(
            id: placeId,
            name: name,
            address: address,
            latitude: lat,
            longitude: lon,
          );
        }).toList();

        return Right(results);
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
