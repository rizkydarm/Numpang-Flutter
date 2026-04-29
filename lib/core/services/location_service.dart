import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../../domain/entities/user_location.dart';

enum LocationPermissionStatus {
  granted,
  denied,
  deniedForever,
  serviceDisabled,
}

class LocationService {
  final GeolocatorPlatform _geolocator;

  LocationService({GeolocatorPlatform? geolocator})
    : _geolocator = geolocator ?? GeolocatorPlatform.instance;

  Future<LocationPermissionStatus> checkPermission() async {
    final serviceEnabled = await _geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermissionStatus.serviceDisabled;
    }

    var permission = await _geolocator.checkPermission();

    if (permission == LocationPermission.deniedForever) {
      return LocationPermissionStatus.deniedForever;
    }

    if (permission == LocationPermission.denied) {
      permission = await _geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return LocationPermissionStatus.denied;
      }
      if (permission == LocationPermission.deniedForever) {
        return LocationPermissionStatus.deniedForever;
      }
    }

    return LocationPermissionStatus.granted;
  }

  Future<UserLocation?> getCurrentLocation() async {
    final permission = await checkPermission();
    if (permission != LocationPermissionStatus.granted) {
      return null;
    }

    try {
      final position = await _geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
      );

      return UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        timestamp: position.timestamp ?? DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  Stream<UserLocation> getLocationStream() async* {
    final permission = await checkPermission();
    if (permission != LocationPermissionStatus.granted) {
      throw Exception('Location permission not granted');
    }

    await for (final position in _geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 10,
      ),
    )) {
      yield UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        timestamp: position.timestamp ?? DateTime.now(),
      );
    }
  }
}
