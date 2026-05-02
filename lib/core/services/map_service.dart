import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:numpang_app/domain/entities/destination.dart';

class MapService {
  MapController? _controller;

  void initialize(MapController controller) {
    _controller = controller;
  }

  void dispose() {
    _controller?.dispose();
    _controller = null;
  }

  bool get isInitialized => _controller != null;

  void moveTo(LatLng position, double zoom) {
    _controller?.move(position, zoom);
  }

  LatLng? get center => _controller?.camera.center;

  double? get zoom => _controller?.camera.zoom;

  void fitToMarkers(List<LatLng> positions, {double padding = 0.1}) {
    if (positions.isEmpty || _controller == null) return;

    if (positions.length == 1) {
      moveTo(positions.first, 15);
      return;
    }

    var minLat = positions.first.latitude;
    var maxLat = positions.first.latitude;
    var minLng = positions.first.longitude;
    var maxLng = positions.first.longitude;

    for (final pos in positions.skip(1)) {
      if (pos.latitude < minLat) minLat = pos.latitude;
      if (pos.latitude > maxLat) maxLat = pos.latitude;
      if (pos.longitude < minLng) minLng = pos.longitude;
      if (pos.longitude > maxLng) maxLng = pos.longitude;
    }

    final latPadding = (maxLat - minLat) * padding;
    final lngPadding = (maxLng - minLng) * padding;

    final bounds = LatLngBounds(
      LatLng(minLat - latPadding, minLng - lngPadding),
      LatLng(maxLat + latPadding, maxLng + lngPadding),
    );

    _controller?.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(50),
      ),
    );
  }

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
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2196F3).withAlpha(102),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }

  double calculateZoomForRadius(double radiusInMeters) {
    const earthCircumference = 40075016.686;
    const double tileSize = 256;
    final scale = radiusInMeters * 4 / earthCircumference;
    return math.log(earthCircumference * tileSize / scale) / math.log(2);
  }
}
