import 'dart:async';
import 'package:numpang_app/core/services/location_service.dart';
import 'package:numpang_app/domain/entities/user_location.dart';

class MockLocationService implements LocationService {
  LocationPermissionStatus _permissionStatus = LocationPermissionStatus.granted;
  UserLocation? _mockLocation = UserLocation(
    latitude: 40.7128,
    longitude: -74.0060,
    accuracy: 10.0,
    timestamp: DateTime.now(),
  );

  final StreamController<UserLocation> _locationStreamController = StreamController<UserLocation>.broadcast();

  void setPermissionStatus(LocationPermissionStatus status) {
    _permissionStatus = status;
  }

  void setMockLocation(UserLocation? location) {
    _mockLocation = location;
  }

  void emitLocation(UserLocation location) {
    _locationStreamController.add(location);
  }

  @override
  Future<LocationPermissionStatus> checkPermission() async {
    return _permissionStatus;
  }

  @override
  Future<UserLocation?> getCurrentLocation() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _mockLocation;
  }

  @override
  Stream<UserLocation> getLocationStream() async* {
    if (_permissionStatus != LocationPermissionStatus.granted) {
      throw Exception('Location permission not granted');
    }
    yield* _locationStreamController.stream;
  }

  void dispose() {
    _locationStreamController.close();
  }
}
