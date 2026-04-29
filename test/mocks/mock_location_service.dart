import 'dart:async';
import 'package:numpang_app/core/services/location_service.dart';
import 'package:numpang_app/domain/entities/user_location.dart';

class MockLocationService implements LocationService {
  final UserLocation _mockLocation = UserLocation(
    latitude: 40.7128,
    longitude: -74.0060,
    accuracy: 10.0,
    timestamp: DateTime.now(),
  );

  @override
  Future<LocationPermissionStatus> checkPermission() async {
    return LocationPermissionStatus.granted;
  }

  @override
  Future<UserLocation?> getCurrentLocation() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _mockLocation;
  }

  @override
  Stream<UserLocation> getLocationStream() {
    return Stream.periodic(
      const Duration(seconds: 5),
      (_) => UserLocation(
        latitude: 40.7128 + (DateTime.now().millisecond % 100) / 10000,
        longitude: -74.0060 + (DateTime.now().millisecond % 100) / 10000,
        accuracy: 10.0,
        timestamp: DateTime.now(),
      ),
    );
  }
}
