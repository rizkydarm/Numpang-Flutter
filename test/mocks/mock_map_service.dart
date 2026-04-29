import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:numpang_app/core/services/map_service.dart';
import 'package:numpang_app/domain/entities/destination.dart';

class MockMapService implements MapService {
  LatLng? _lastMovePosition;
  double? _lastMoveZoom;
  final List<LatLng> _fittedPositions = [];

  LatLng? get lastMovePosition => _lastMovePosition;
  double? get lastMoveZoom => _lastMoveZoom;
  List<LatLng> get fittedPositions => List.unmodifiable(_fittedPositions);

  @override
  void initialize(MapController controller) {}

  @override
  void dispose() {}

  @override
  bool get isInitialized => true;

  @override
  void moveTo(LatLng position, double zoom) {
    _lastMovePosition = position;
    _lastMoveZoom = zoom;
  }

  @override
  void animateTo(LatLng position, double zoom, {Duration duration = const Duration(milliseconds: 500)}) {
    _lastMovePosition = position;
    _lastMoveZoom = zoom;
  }

  @override
  LatLng? get center => _lastMovePosition;

  @override
  double? get zoom => _lastMoveZoom;

  @override
  void fitToMarkers(List<LatLng> positions, {double padding = 0.1}) {
    _fittedPositions.clear();
    _fittedPositions.addAll(positions);
    if (positions.isNotEmpty) {
      _lastMovePosition = positions.first;
    }
  }

  @override
  Marker createDestinationMarker(
    Destination destination, {
    VoidCallback? onTap,
    bool isSelected = false,
  }) {
    return Marker(
      point: LatLng(destination.latitude, destination.longitude),
      width: isSelected ? 50 : 40,
      height: isSelected ? 50 : 40,
      child: GestureDetector(
        onTap: onTap,
        child: Icon(
          Icons.location_pin,
          color: isSelected ? const Color(0xFF2196F3) : const Color(0xFFFFCA28),
          size: isSelected ? 50 : 40,
        ),
      ),
    );
  }

  @override
  Marker createUserLocationMarker(LatLng position) {
    return Marker(
      point: position,
      width: 20,
      height: 20,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2196F3),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
        ),
      ),
    );
  }

  @override
  double calculateZoomForRadius(double radiusInMeters) => 13.0;
}
