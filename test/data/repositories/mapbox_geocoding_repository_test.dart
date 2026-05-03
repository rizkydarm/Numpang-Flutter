import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:numpang_app/core/errors/failures.dart';
import 'package:numpang_app/data/datasources/geocoding_cache.dart';
import 'package:numpang_app/data/repositories/mapbox_geocoding_repository.dart';

import 'mapbox_geocoding_repository_test.mocks.dart';

@GenerateMocks([Dio, GeocodingCache])
void main() {
  late MapboxGeocodingRepository repository;
  late MockDio mockDio;
  late MockGeocodingCache mockCache;

  setUp(() {
    mockDio = MockDio();
    mockCache = MockGeocodingCache();
    repository = MapboxGeocodingRepository(mockDio, mockCache, 'fake_token');
  });

  group('searchAddress (Forward Geocoding)', () {
    test('should return LatLng on successful response', () async {
      when(mockDio.get<Map<String, dynamic>>(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response(
            data: {
              'features': [
                {
                  'geometry': {
                    'coordinates': [-74.0060, 40.7128],
                  },
                },
              ],
            },
            statusCode: 200,
            requestOptions: RequestOptions(),
          ));

      final result = await repository.searchAddress('New York');

      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Should not fail'),
        (r) {
          expect(r.latitude, 40.7128);
          expect(r.longitude, -74.0060);
        },
      );
    });

    test('should return ServerFailure on empty response', () async {
      when(mockDio.get<Map<String, dynamic>>(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response(
            data: {'features': []},
            statusCode: 200,
            requestOptions: RequestOptions(),
          ));

      final result = await repository.searchAddress('Unknown Place');

      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<ServerFailure>()),
        (r) => fail('Should not succeed'),
      );
    });

    test('should return NetworkFailure on connection error', () async {
      when(mockDio.get<Map<String, dynamic>>(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenThrow(DioException(
        type: DioExceptionType.connectionError,
        requestOptions: RequestOptions(),
      ));

      final result = await repository.searchAddress('New York');

      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<NetworkFailure>()),
        (r) => fail('Should not succeed'),
      );
    });

    test('should return ServerFailure with code 429 on rate limit', () async {
      when(mockDio.get<Map<String, dynamic>>(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response(
            data: {},
            statusCode: 429,
            requestOptions: RequestOptions(),
          ));

      final result = await repository.searchAddress('New York');

      expect(result.isLeft(), true);
      result.fold(
        (l) {
          expect(l, isA<ServerFailure>());
          expect((l as ServerFailure).code, 429);
        },
        (r) => fail('Should not succeed'),
      );
    });
  });

  group('reverseGeocode (Reverse Geocoding)', () {
    const testPosition = LatLng(40.7128, -74.0060);

    test('should return cached value if available', () async {
      when(mockCache.getReverseGeocode(testPosition))
          .thenReturn('Cached Address');

      final result = await repository.reverseGeocode(testPosition);

      verify(mockCache.getReverseGeocode(testPosition)).called(1);
      verifyNever(mockDio.get<Map<String, dynamic>>(
        any,
        queryParameters: anyNamed('queryParameters'),
      ));

      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Should not fail'),
        (r) => expect(r, 'Cached Address'),
      );
    });

    test('should fetch and cache on cache miss', () async {
      when(mockCache.getReverseGeocode(testPosition)).thenReturn(null);
      when(mockDio.get<Map<String, dynamic>>(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response(
            data: {
              'features': [
                {
                  'properties': {
                    'full_address': '123 Test St, New York',
                  },
                },
              ],
            },
            statusCode: 200,
            requestOptions: RequestOptions(),
          ));

      final result = await repository.reverseGeocode(testPosition);

      verify(mockCache.setReverseGeocode(testPosition, '123 Test St, New York'))
          .called(1);
      expect(result.isRight(), true);
    });

    test('should return ServerFailure on no address found', () async {
      when(mockCache.getReverseGeocode(testPosition)).thenReturn(null);
      when(mockDio.get<Map<String, dynamic>>(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response(
            data: {'features': []},
            statusCode: 200,
            requestOptions: RequestOptions(),
          ));

      final result = await repository.reverseGeocode(testPosition);

      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<ServerFailure>()),
        (r) => fail('Should not succeed'),
      );
    });
  });

  group('autocomplete', () {
    test('should return list of suggestions', () async {
      when(mockDio.get<Map<String, dynamic>>(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response(
            data: {
              'features': [
                {
                  'id': '1',
                  'properties': {
                    'name': 'Central Park',
                    'full_address': 'Central Park, NY',
                  },
                  'geometry': {
                    'coordinates': [-73.9654, 40.7829],
                  },
                },
              ],
            },
            statusCode: 200,
            requestOptions: RequestOptions(),
          ));

      final result = await repository.autocomplete('Central');

      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Should not fail'),
        (r) {
          expect(r.length, 1);
          expect(r[0].name, 'Central Park');
          expect(r[0].latitude, 40.7829);
          expect(r[0].longitude, -73.9654);
        },
      );
    });

    test('should return empty list when no suggestions', () async {
      when(mockDio.get<Map<String, dynamic>>(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response(
            data: {'features': []},
            statusCode: 200,
            requestOptions: RequestOptions(),
          ));

      final result = await repository.autocomplete('xyzunknown');

      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Should not fail'),
        (r) => expect(r.isEmpty, true),
      );
    });
  });

  group('getPlaceDetails', () {
    test('should return PlaceDetails on successful response', () async {
      when(mockDio.get<Map<String, dynamic>>(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response(
            data: {
              'features': [
                {
                  'properties': {
                    'name': 'Test Place',
                    'full_address': '123 Test St',
                    'context': {
                      'poi': {
                        'category': 'restaurant',
                      },
                    },
                  },
                  'geometry': {
                    'coordinates': [-74.0, 40.7],
                  },
                },
              ],
            },
            statusCode: 200,
            requestOptions: RequestOptions(),
          ));

      final result = await repository.getPlaceDetails('place_123');

      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Should not fail'),
        (r) {
          expect(r.name, 'Test Place');
          expect(r.address, '123 Test St');
          expect(r.latitude, 40.7);
          expect(r.longitude, -74.0);
          expect(r.categories, ['restaurant']);
        },
      );
    });

    test('should return ServerFailure on place not found', () async {
      when(mockDio.get<Map<String, dynamic>>(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response(
            data: {'features': []},
            statusCode: 200,
            requestOptions: RequestOptions(),
          ));

      final result = await repository.getPlaceDetails('invalid_id');

      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<ServerFailure>()),
        (r) => fail('Should not succeed'),
      );
    });
  });
}
