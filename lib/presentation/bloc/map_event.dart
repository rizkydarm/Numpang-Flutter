import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import 'package:numpang_app/domain/entities/destination.dart';

abstract class MapBlocEvent extends Equatable {
  const MapBlocEvent();

  @override
  List<Object?> get props => [];
}

class InitializeMap extends MapBlocEvent {

  const InitializeMap({this.initialCenter, this.initialZoom = 13.0});
  final LatLng? initialCenter;
  final double initialZoom;

  @override
  List<Object?> get props => [initialCenter, initialZoom];
}

class CenterOnLocation extends MapBlocEvent {

  const CenterOnLocation(this.position, {this.zoom});
  final LatLng position;
  final double? zoom;

  @override
  List<Object?> get props => [position, zoom];
}

class TapOnMap extends MapBlocEvent {

  const TapOnMap(this.position, {this.address});
  final LatLng position;
  final String? address;

  @override
  List<Object?> get props => [position, address];
}

class AddMarker extends MapBlocEvent {

  const AddMarker(this.destination);
  final Destination destination;

  @override
  List<Object?> get props => [destination];
}

class RemoveMarker extends MapBlocEvent {

  const RemoveMarker(this.destinationId);
  final String destinationId;

  @override
  List<Object?> get props => [destinationId];
}

class UpdateZoom extends MapBlocEvent {

  const UpdateZoom(this.zoom);
  final double zoom;

  @override
  List<Object?> get props => [zoom];
}

class ToggleFollowMode extends MapBlocEvent {
  const ToggleFollowMode();
}

class RequestMyLocation extends MapBlocEvent {
  const RequestMyLocation();
}

class UserLocationUpdated extends MapBlocEvent {

  const UserLocationUpdated(this.position);
  final LatLng position;

  @override
  List<Object?> get props => [position];
}

class MapMoved extends MapBlocEvent {

  const MapMoved(this.center, this.zoom);
  final LatLng center;
  final double zoom;

  @override
  List<Object?> get props => [center, zoom];
}
