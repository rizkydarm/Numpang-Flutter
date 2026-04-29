import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/entities/destination.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object?> get props => [];
}

class InitializeMap extends MapEvent {
  final LatLng? initialCenter;
  final double initialZoom;

  const InitializeMap({this.initialCenter, this.initialZoom = 13.0});

  @override
  List<Object?> get props => [initialCenter, initialZoom];
}

class CenterOnLocation extends MapEvent {
  final LatLng position;
  final double? zoom;

  const CenterOnLocation(this.position, {this.zoom});

  @override
  List<Object?> get props => [position, zoom];
}

class TapOnMap extends MapEvent {
  final LatLng position;
  final String? address;

  const TapOnMap(this.position, {this.address});

  @override
  List<Object?> get props => [position, address];
}

class AddMarker extends MapEvent {
  final Destination destination;

  const AddMarker(this.destination);

  @override
  List<Object?> get props => [destination];
}

class RemoveMarker extends MapEvent {
  final String destinationId;

  const RemoveMarker(this.destinationId);

  @override
  List<Object?> get props => [destinationId];
}

class UpdateZoom extends MapEvent {
  final double zoom;

  const UpdateZoom(this.zoom);

  @override
  List<Object?> get props => [zoom];
}

class ToggleFollowMode extends MapEvent {
  const ToggleFollowMode();
}

class UserLocationUpdated extends MapEvent {
  final LatLng position;

  const UserLocationUpdated(this.position);

  @override
  List<Object?> get props => [position];
}

class MapMoved extends MapEvent {
  final LatLng center;
  final double zoom;

  const MapMoved(this.center, this.zoom);

  @override
  List<Object?> get props => [center, zoom];
}
