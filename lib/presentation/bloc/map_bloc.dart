import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/services/location_service.dart';
import '../../domain/entities/destination.dart';
import 'map_event.dart';
import 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final LocationService _locationService;

  MapBloc({required LocationService locationService})
    : _locationService = locationService,
      super(MapState.initial()) {
    on<InitializeMap>(_onInitializeMap);
    on<CenterOnLocation>(_onCenterOnLocation);
    on<TapOnMap>(_onTapOnMap);
    on<AddMarker>(_onAddMarker);
    on<RemoveMarker>(_onRemoveMarker);
    on<UpdateZoom>(_onUpdateZoom);
    on<ToggleFollowMode>(_onToggleFollowMode);
    on<UserLocationUpdated>(_onUserLocationUpdated);
    on<MapMoved>(_onMapMoved);
  }

  Future<void> _onInitializeMap(
    InitializeMap event,
    Emitter<MapState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final location = await _locationService.getCurrentLocation();
    final center = location != null
        ? LatLng(location.latitude, location.longitude)
        : event.initialCenter ?? const LatLng(0, 0);

    emit(
      MapState(
        center: center,
        zoom: event.initialZoom,
        destinations: [],
        markers: [],
        isFollowingUser: location != null,
        isLoading: false,
      ),
    );
  }

  void _onCenterOnLocation(CenterOnLocation event, Emitter<MapState> emit) {
    emit(
      state.copyWith(center: event.position, zoom: event.zoom ?? state.zoom),
    );
  }

  void _onTapOnMap(TapOnMap event, Emitter<MapState> emit) {
    // Just update center - marker is added via AddMarker event
    emit(state.copyWith(center: event.position));
  }

  void _onAddMarker(AddMarker event, Emitter<MapState> emit) {
    final newDestination = event.destination;
    final updatedDestinations = [...state.destinations, newDestination];
    final newMarker = _createMarker(newDestination);
    final updatedMarkers = [...state.markers, newMarker];

    emit(
      state.copyWith(
        destinations: updatedDestinations,
        markers: updatedMarkers,
        center: LatLng(newDestination.latitude, newDestination.longitude),
      ),
    );
  }

  void _onRemoveMarker(RemoveMarker event, Emitter<MapState> emit) {
    final index = state.destinations.indexWhere(
      (d) => d.id == event.destinationId,
    );
    if (index < 0) return;

    final updatedDestinations = [...state.destinations]..removeAt(index);
    final updatedMarkers = [...state.markers]..removeAt(index);

    emit(
      state.copyWith(
        destinations: updatedDestinations,
        markers: updatedMarkers,
      ),
    );
  }

  void _onUpdateZoom(UpdateZoom event, Emitter<MapState> emit) {
    emit(state.copyWith(zoom: event.zoom));
  }

  void _onToggleFollowMode(ToggleFollowMode event, Emitter<MapState> emit) {
    emit(state.copyWith(isFollowingUser: !state.isFollowingUser));
  }

  void _onUserLocationUpdated(
    UserLocationUpdated event,
    Emitter<MapState> emit,
  ) {
    if (state.isFollowingUser) {
      emit(state.copyWith(center: event.position));
    }
  }

  void _onMapMoved(MapMoved event, Emitter<MapState> emit) {
    emit(state.copyWith(center: event.center, zoom: event.zoom));
  }

  Marker _createMarker(Destination destination) {
    return Marker(
      point: LatLng(destination.latitude, destination.longitude),
      width: 40,
      height: 40,
      child: Icon(Icons.location_pin, color: const Color(0xFFFFCA28), size: 40),
    );
  }
}
