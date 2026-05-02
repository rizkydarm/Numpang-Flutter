import 'package:flutter_test/flutter_test.dart';
import 'package:numpang_app/data/repositories/location_repository_impl.dart';
import 'package:numpang_app/domain/entities/user_location.dart';
import 'mock_location_service.dart';

void main() {
  late MockLocationService mockLocationService;

  final testLocation = UserLocation(
    latitude: 51.5074,
    longitude: -0.1278,
    accuracy: 5,
    timestamp: DateTime(2026, 5),
  );

  group('MockLocationService', () {
    setUp(() {
      mockLocationService = MockLocationService();
    });

    tearDown(() {
      mockLocationService.dispose();
    });

    group('Constructor', () {
      test('creates with default location and granted permission', () async {
        final location = await mockLocationService.getCurrentLocation();
        expect(location, isNotNull);
        expect(location!.latitude, 40.7128);
        expect(location.longitude, -74.0060);

        final permission = await mockLocationService.checkPermission();
        expect(permission, LocationPermissionStatus.granted);
      });

      test('creates with custom location and permission', () async {
        final customMock = MockLocationService(
          permissionStatus: LocationPermissionStatus.denied,
          mockLocation: testLocation,
        );
        addTearDown(customMock.dispose);

        final location = await customMock.getCurrentLocation();
        expect(location, isNull); // denied permission returns null

        final permission = await customMock.checkPermission();
        expect(permission, LocationPermissionStatus.denied);
      });
    });

    group('checkPermission', () {
      test('returns granted by default', () async {
        final result = await mockLocationService.checkPermission();
        expect(result, LocationPermissionStatus.granted);
      });

      test('returns set permission status', () async {
        mockLocationService.setPermissionStatus(
          LocationPermissionStatus.denied,
        );
        final result = await mockLocationService.checkPermission();
        expect(result, LocationPermissionStatus.denied);
      });

      test('returns deniedForever', () async {
        mockLocationService.setPermissionStatus(
          LocationPermissionStatus.deniedForever,
        );
        final result = await mockLocationService.checkPermission();
        expect(result, LocationPermissionStatus.deniedForever);
      });

      test('returns serviceDisabled', () async {
        mockLocationService.setPermissionStatus(
          LocationPermissionStatus.serviceDisabled,
        );
        final result = await mockLocationService.checkPermission();
        expect(result, LocationPermissionStatus.serviceDisabled);
      });
    });

    group('getCurrentLocation', () {
      test('returns mock location after delay', () async {
        final stopwatch = Stopwatch()..start();
        final location = await mockLocationService.getCurrentLocation();
        stopwatch.stop();

        expect(location, isNotNull);
        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(100));
      });

      test('returns null when permission denied', () async {
        mockLocationService.setPermissionStatus(
          LocationPermissionStatus.denied,
        );
        final location = await mockLocationService.getCurrentLocation();
        expect(location, isNull);
      });

      test('returns custom location when set', () async {
        mockLocationService.setMockLocation(testLocation);
        final location = await mockLocationService.getCurrentLocation();
        expect(location, equals(testLocation));
      });

      test('returns null when location is set to null', () async {
        mockLocationService.setMockLocation(null);
        final location = await mockLocationService.getCurrentLocation();
        expect(location, isNull);
      });
    });

    group('getLocationStream', () {
      test('emits location when permission granted', () async {
        final locations = <UserLocation>[];
        final subscription = mockLocationService.getLocationStream().listen(
          locations.add,
        );

        mockLocationService.emitLocation(testLocation);

        await Future.delayed(const Duration(milliseconds: 50));
        await subscription.cancel();

        expect(locations, hasLength(1));
        expect(locations.first, equals(testLocation));
      });

      test('returns error stream when permission not granted', () async {
        mockLocationService.setPermissionStatus(
          LocationPermissionStatus.denied,
        );
        final stream = mockLocationService.getLocationStream();

        Object? capturedError;
        final subscription = stream.listen(
          (_) {},
          onError: (error) => capturedError = error,
        );

        await Future.delayed(const Duration(milliseconds: 50));
        await subscription.cancel();

        expect(capturedError, isNotNull);
        expect(
          capturedError.toString(),
          contains('Location permission not granted'),
        );
      });

      test('emits multiple locations', () async {
        final locations = <UserLocation>[];
        final subscription = mockLocationService.getLocationStream().listen(
          locations.add,
        );

        mockLocationService.emitLocation(testLocation);
        mockLocationService.emitLocation(
          UserLocation(
            latitude: 52.5200,
            longitude: 13.4050,
            accuracy: 8,
            timestamp: DateTime(2026, 5, 1, 12),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 50));
        await subscription.cancel();

        expect(locations, hasLength(2));
      });

      test('returns error stream when controller is closed', () async {
        mockLocationService.dispose();
        final stream = mockLocationService.getLocationStream();

        Object? capturedError;
        final subscription = stream.listen(
          (_) {},
          onError: (error) => capturedError = error,
        );

        await Future.delayed(const Duration(milliseconds: 50));
        await subscription.cancel();

        expect(capturedError, isA<StateError>());
        expect(
          capturedError.toString(),
          contains('Stream controller is closed'),
        );
      });
    });

    group('emitPermissionError', () {
      test('emits error to stream listeners', () async {
        Object? capturedError;
        final subscription = mockLocationService.getLocationStream().listen(
          (_) {},
          onError: (error) => capturedError = error,
        );

        mockLocationService.emitPermissionError();

        await Future.delayed(const Duration(milliseconds: 50));
        await subscription.cancel();

        expect(capturedError, isNotNull);
        expect(
          capturedError.toString(),
          contains('Location permission not granted'),
        );
      });

      test('throws StateError when stream is closed', () {
        mockLocationService.dispose();
        expect(
          () => mockLocationService.emitPermissionError(),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('reset', () {
      test('resets to defaults', () async {
        mockLocationService.setPermissionStatus(
          LocationPermissionStatus.denied,
        );
        mockLocationService.setMockLocation(testLocation);

        mockLocationService.reset();

        final permission = await mockLocationService.checkPermission();
        expect(permission, LocationPermissionStatus.granted);

        final location = await mockLocationService.getCurrentLocation();
        expect(location!.latitude, 40.7128); // default
      });

      test('resets with custom values', () async {
        mockLocationService.reset(
          permissionStatus: LocationPermissionStatus.granted,
          mockLocation: testLocation,
        );

        final permission = await mockLocationService.checkPermission();
        expect(permission, LocationPermissionStatus.granted);

        final location = await mockLocationService.getCurrentLocation();
        expect(location, equals(testLocation));
      });

      test('recreates stream controller after reset', () async {
        final locations = <UserLocation>[];
        final subscription = mockLocationService.getLocationStream().listen(
          locations.add,
        );
        await subscription.cancel();

        mockLocationService.reset();

        // Should be able to listen again after reset
        final newLocations = <UserLocation>[];
        final newSubscription = mockLocationService.getLocationStream().listen(
          newLocations.add,
        );

        mockLocationService.emitLocation(testLocation);

        await Future.delayed(const Duration(milliseconds: 50));
        await newSubscription.cancel();

        expect(newLocations, hasLength(1));
      });
    });

    group('getPeriodicLocationStream', () {
      test('emits locations periodically', () async {
        final locations = <UserLocation>[];
        final subscription = mockLocationService
            .getPeriodicLocationStream(
              period: const Duration(milliseconds: 100),
            )
            .listen(locations.add);

        await Future.delayed(const Duration(milliseconds: 350));
        await subscription.cancel();

        expect(locations.length, greaterThanOrEqualTo(2));
        // Each location should be slightly different (random)
        expect(locations.first.latitude, closeTo(40.7128, 0.01));
        expect(locations.first.longitude, closeTo(-74.0060, 0.01));
      });

      test('uses custom base coordinates', () async {
        final locations = <UserLocation>[];
        final subscription = mockLocationService
            .getPeriodicLocationStream(
              period: const Duration(milliseconds: 100),
              baseLatitude: 51.5074,
              baseLongitude: -0.1278,
            )
            .listen(locations.add);

        await Future.delayed(const Duration(milliseconds: 150));
        await subscription.cancel();

        expect(locations.first.latitude, closeTo(51.5074, 0.01));
        expect(locations.first.longitude, closeTo(-0.1278, 0.01));
      });
    });

    group('dispose', () {
      test('closes stream controller', () async {
        mockLocationService.dispose();

        expect(
          () => mockLocationService.emitLocation(testLocation),
          throwsA(isA<StateError>()),
        );
      });

      test('safe to call multiple times', () {
        mockLocationService.dispose();
        mockLocationService.dispose(); // Should not throw
        expect(true, isTrue); // Reached here means no exception
      });
    });
  });
}
