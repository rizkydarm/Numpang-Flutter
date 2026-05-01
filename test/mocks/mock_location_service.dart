import 'dart:async';
import 'dart:math' as math;
import 'package:numpang_app/data/repositories/location_repository_impl.dart';
import 'package:numpang_app/domain/entities/user_location.dart';

/// A mock implementation of [LocationService] for testing purposes.
///
/// This mock allows tests to:
/// - Control permission status responses
/// - Set mock location values
/// - Emit location updates via stream
/// - Simulate permission denied scenarios
class MockLocationService {
  LocationPermissionStatus _permissionStatus = LocationPermissionStatus.granted;
  UserLocation? _mockLocation;
  StreamController<UserLocation>? _locationStreamController;

  MockLocationService({
    LocationPermissionStatus permissionStatus =
        LocationPermissionStatus.granted,
    UserLocation? mockLocation,
  }) : _permissionStatus = permissionStatus,
       _mockLocation = mockLocation ?? _defaultLocation {
    _initStreamController();
  }

  static final UserLocation _defaultLocation = UserLocation(
    latitude: 40.7128,
    longitude: -74.0060,
    accuracy: 10.0,
    timestamp: DateTime.now(),
  );

  void _initStreamController() {
    _locationStreamController = StreamController<UserLocation>.broadcast(
      onCancel: () {
        // Stream cancelled, can add cleanup logic here if needed
      },
    );
  }

  /// Resets the mock to its initial state. Call this in setUp or tearDown.
  void reset({
    LocationPermissionStatus? permissionStatus,
    UserLocation? mockLocation,
  }) {
    _permissionStatus = permissionStatus ?? LocationPermissionStatus.granted;
    _mockLocation = mockLocation ?? _defaultLocation;
    _disposeStreamController();
    _initStreamController();
  }

  /// Sets the permission status to return from [checkPermission].
  void setPermissionStatus(LocationPermissionStatus status) {
    _permissionStatus = status;
  }

  /// Sets the mock location to return from [getCurrentLocation].
  void setMockLocation(UserLocation? location) {
    _mockLocation = location;
  }

  /// Emits a location update to the stream.
  /// Throws if the stream controller is closed.
  void emitLocation(UserLocation location) {
    if (_locationStreamController == null ||
        _locationStreamController!.isClosed) {
      throw StateError(
        'Cannot emit location: stream controller is closed. Call reset() first.',
      );
    }
    _locationStreamController!.add(location);
  }

  /// Simulates a permission denied error on the stream.
  void emitPermissionError() {
    if (_locationStreamController == null ||
        _locationStreamController!.isClosed) {
      throw StateError(
        'Cannot emit error: stream controller is closed. Call reset() first.',
      );
    }
    _locationStreamController!.addError(
      Exception('Location permission not granted'),
    );
  }

  Future<LocationPermissionStatus> checkPermission() async {
    return _permissionStatus;
  }

  Future<UserLocation?> getCurrentLocation() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (_permissionStatus != LocationPermissionStatus.granted) {
      return null;
    }
    return _mockLocation;
  }

  Stream<UserLocation> getLocationStream() {
    if (_permissionStatus != LocationPermissionStatus.granted) {
      return Stream.error(Exception('Location permission not granted'));
    }
    if (_locationStreamController == null ||
        _locationStreamController!.isClosed) {
      return Stream.error(
        StateError('Stream controller is closed. Call reset() first.'),
      );
    }
    return _locationStreamController!.stream;
  }

  /// Returns a periodic stream of random locations for testing live updates.
  /// This is a test utility method, not part of the original LocationService.
  Stream<UserLocation> getPeriodicLocationStream({
    Duration period = const Duration(seconds: 1),
    double latitudeVariance = 0.01,
    double baseLatitude = 40.7128,
    double baseLongitude = -74.0060,
  }) {
    return Stream.periodic(
      period,
      (count) => UserLocation(
        latitude:
            baseLatitude +
            (math.Random().nextDouble() * latitudeVariance -
                latitudeVariance / 2),
        longitude:
            baseLongitude +
            (math.Random().nextDouble() * latitudeVariance -
                latitudeVariance / 2),
        accuracy: 10.0 + (math.Random().nextDouble() * 5.0),
        timestamp: DateTime.now(),
      ),
    );
  }

  void _disposeStreamController() {
    if (_locationStreamController != null &&
        !_locationStreamController!.isClosed) {
      _locationStreamController!.close();
    }
    _locationStreamController = null;
  }

  /// Disposes the mock service. Call this in tearDown.
  void dispose() {
    _disposeStreamController();
  }
}
