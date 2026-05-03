import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:numpang_app/core/errors/failures.dart';
import 'package:numpang_app/data/datasources/geocoding_cache.dart';
import 'package:numpang_app/data/repositories/geocode_xyz_geocoding_repository.dart';

import 'geocode_xyz_geocoding_repository_test.mocks.dart';

@GenerateMocks([Dio, GeocodingCache])
void main() {
  late GeocodeXyzGeocodingRepository repository;
  late MockDio mockDio;
  late MockGeocodingCache mockCache;

  setUp(() {
    mockDio = MockDio();
    mockCache = MockGeocodingCache();
    repository = GeocodeXyzGeocodingRepository(mockDio, mockCache);
  });

  group('searchAddress (Forward Geocoding)', () {
    test('should return LatLng on successful response', () async {
      when(
        mockDio.get<Map<String, dynamic>>(
          any,
          queryParameters: anyNamed('queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {
            'latt': '40.7128',
            'longt': '-74.0060',
          },
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );

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

    test('should return ServerFailure on error response', () async {
      when(
        mockDio.get<Map<String, dynamic>>(
          any,
          queryParameters: anyNamed('queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {
            'error': {
              'description': 'Location not found',
            },
          },
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );

      final result = await repository.searchAddress('Unknown Place XYZ');

      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<ServerFailure>()),
        (r) => fail('Should not succeed'),
      );
    });

    test('should return ServerFailure on empty coordinates', () async {
      when(
        mockDio.get<Map<String, dynamic>>(
          any,
          queryParameters: anyNamed('queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {},
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );

      final result = await repository.searchAddress('Unknown');

      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<ServerFailure>()),
        (r) => fail('Should not succeed'),
      );
    });

    test('should return NetworkFailure on connection error', () async {
      when(
        mockDio.get<Map<String, dynamic>>(
          any,
          queryParameters: anyNamed('queryParameters'),
        ),
      ).thenThrow(
        DioException(
          type: DioExceptionType.connectionError,
          requestOptions: RequestOptions(),
        ),
      );

      final result = await repository.searchAddress('New York');

      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<NetworkFailure>()),
        (r) => fail('Should not succeed'),
      );
    });

    test('should use API key when provided', () async {
      final repoWithKey = GeocodeXyzGeocodingRepository(
        mockDio,
        mockCache,
        apiKey: 'test_api_key',
      );

      when(
        mockDio.get<Map<String, dynamic>>(
          any,
          queryParameters: anyNamed('queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {
            'latt': '40.7128',
            'longt': '-74.0060',
          },
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );

      await repoWithKey.searchAddress('New York');

      verify(
        mockDio.get<Map<String, dynamic>>(
          any,
          queryParameters: argThat(
            containsPair('auth', 'test_api_key'),
            named: 'queryParameters',
          ),
        ),
      ).called(1);
    });
  });

  group('reverseGeocode (Reverse Geocoding)', () {
    const testPosition = LatLng(40.7128, -74.0060);

    test('should return cached value if available', () async {
      when(
        mockCache.getReverseGeocode(testPosition),
      ).thenReturn('Cached Address');

      final result = await repository.reverseGeocode(testPosition);

      verify(mockCache.getReverseGeocode(testPosition)).called(1);
      verifyNever(
        mockDio.get<Map<String, dynamic>>(
          any,
          queryParameters: anyNamed('queryParameters'),
        ),
      );

      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Should not fail'),
        (r) => expect(r, 'Cached Address'),
      );
    });

    test('should fetch and cache on cache miss', () async {
      when(mockCache.getReverseGeocode(testPosition)).thenReturn(null);
      when(
        mockDio.get<Map<String, dynamic>>(
          any,
          queryParameters: anyNamed('queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {
            'stnumber': '123',
            'staddress': 'Test Street',
            'city': 'New York',
            'state': 'NY',
            'country': 'USA',
          },
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );

      final result = await repository.reverseGeocode(testPosition);

      verify(
        mockCache.setReverseGeocode(
          testPosition,
          '123 Test Street, New York, NY, USA',
        ),
      ).called(1);
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Should not fail'),
        (r) => expect(r, '123 Test Street, New York, NY, USA'),
      );
    });

    test('should return ServerFailure on error response', () async {
      when(mockCache.getReverseGeocode(testPosition)).thenReturn(null);
      when(
        mockDio.get<Map<String, dynamic>>(
          any,
          queryParameters: anyNamed('queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {
            'error': {
              'description': 'No results found',
            },
          },
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );

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
      when(
        mockDio.get<Map<String, dynamic>>(
          any,
          queryParameters: anyNamed('queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {
            'suggestions': [
              'Central Park, New York, NY',
              'Central Park West, New York, NY',
            ],
          },
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );

      final result = await repository.autocomplete('Central');

      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Should not fail'),
        (r) {
          expect(r.length, 2);
          expect(r[0].name, 'Central Park');
          expect(r[0].address, 'Central Park, New York, NY');
        },
      );
    });

    test(
      'should return direct match if no suggestions but has coordinates',
      () async {
        when(
          mockDio.get<Map<String, dynamic>>(
            any,
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: {
              'latt': '40.7829',
              'longt': '-73.9654',
              'staddress': 'Central Park',
              'city': 'New York',
            },
            statusCode: 200,
            requestOptions: RequestOptions(),
          ),
        );

        final result = await repository.autocomplete('Central Park');

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
      },
    );

    test('should return empty list on error', () async {
      when(
        mockDio.get<Map<String, dynamic>>(
          any,
          queryParameters: anyNamed('queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {
            'error': {
              'description': 'No results',
            },
          },
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );

      final result = await repository.autocomplete('xyzunknown123');

      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Should not fail'),
        (r) => expect(r.isEmpty, true),
      );
    });

    test('should include autocomplete parameter', () async {
      when(
        mockDio.get<Map<String, dynamic>>(
          any,
          queryParameters: anyNamed('queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {'suggestions': []},
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );

      await repository.autocomplete('test');

      verify(
        mockDio.get<Map<String, dynamic>>(
          any,
          queryParameters: argThat(
            containsPair('autocomplete', '1'),
            named: 'queryParameters',
          ),
        ),
      ).called(1);
    });
  });

  group('getPlaceDetails', () {
    test('should return PlaceDetails on successful response', () async {
      when(
        mockDio.get<Map<String, dynamic>>(
          any,
          queryParameters: anyNamed('queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {
            'latt': '40.7589',
            'longt': '-73.9851',
            'stnumber': '123',
            'staddress': 'Times Square',
            'city': 'New York',
            'state': 'NY',
            'country': 'USA',
            'postal': '10036',
          },
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );

      final result = await repository.getPlaceDetails('times_square_nyc');

      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Should not fail'),
        (r) {
          expect(r.name, '123 Times Square');
          expect(r.latitude, 40.7589);
          expect(r.longitude, -73.9851);
          expect(r.address, '123 Times Square, New York, NY, 10036, USA');
        },
      );
    });

    test('should return ServerFailure on error', () async {
      when(
        mockDio.get<Map<String, dynamic>>(
          any,
          queryParameters: anyNamed('queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {
            'error': {
              'description': 'Place not found',
            },
          },
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );

      final result = await repository.getPlaceDetails('invalid_place_id');

      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<ServerFailure>()),
        (r) => fail('Should not succeed'),
      );
    });
  });
}
