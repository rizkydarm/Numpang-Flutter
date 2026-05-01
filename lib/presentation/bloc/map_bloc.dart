import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:numpang_app/core/errors/failures.dart';
import 'package:numpang_app/core/services/map_service.dart';
import 'package:numpang_app/data/repositories/location_repository_impl.dart';
import 'package:numpang_app/domain/entities/destination.dart';
import 'package:numpang_app/domain/entities/user_location.dart';
import 'package:numpang_app/presentation/bloc/map_event.dart';
import 'package:numpang_app/presentation/bloc/map_state.dart';

class MapBloc extends Bloc<MapBlocEvent, MapState> {

  MapBloc({required LocationService locationService, MapService? mapService})
    : _locationService = locationService,
      _mapService = mapService ?? MapService(),
      super(MapState.initial()) {
    on<InitializeMap>(_onInitializeMap);
    on<CenterOnLocation>(_onCenterOnLocation);
    on<TapOnMap>(_onTapOnMap);
    on<AddMarker>(_onAddMarker);
    on<RemoveMarker>(_onRemoveMarker);
    on<UpdateZoom>(_onUpdateZoom);
    on<ToggleFollowMode>(_onToggleFollowMode);
    on<RequestMyLocation>(_onRequestMyLocation);
    on<UserLocationUpdated>(_onUserLocationUpdated);
    on<MapMoved>(_onMapMoved);
  }
  final LocationService _locationService;
  final MapService _mapService;
  StreamSubscription<UserLocation>? _locationSubscription;

  MapService get mapService => _mapService;

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    return super.close();
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
        isFollowingUser: location != null,
      ),
    );

    // Start listening to location updates
    _locationSubscription = _locationService.getLocationStream().listen(
      (userLocation) {
        add(
          UserLocationUpdated(
            LatLng(userLocation.latitude, userLocation.longitude),
          ),
        );
      },
      onError: (error) {
        debugPrint('Location stream error: $error');
      },
    );
  }

  void _onCenterOnLocation(CenterOnLocation event, Emitter<MapState> emit) {
    final zoom = event.zoom ?? state.zoom;
    _mapService.moveTo(event.position, zoom);
    emit(state.copyWith(center: event.position, zoom: zoom));
  }

  void _onTapOnMap(TapOnMap event, Emitter<MapState> emit) {
    // Create destination from tap position
    final destination = Destination(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: event.address ?? 'Pinned Location',
      address:
          event.address ??
          '${event.position.latitude.toStringAsFixed(4)}, ${event.position.longitude.toStringAsFixed(4)}',
      latitude: event.position.latitude,
      longitude: event.position.longitude,
      createdAt: DateTime.now(),
    );

    final updatedDestinations = [...state.destinations, destination];

    emit(
      state.copyWith(destinations: updatedDestinations),
    );
  }

  void _onAddMarker(AddMarker event, Emitter<MapState> emit) {
    final newDestination = event.destination;
    final updatedDestinations = [...state.destinations, newDestination];

    emit(
      state.copyWith(
        destinations: updatedDestinations,
      ),
    );
  }

  void _onRemoveMarker(RemoveMarker event, Emitter<MapState> emit) {
    final updatedDestinations = state.destinations
        .where((d) => d.id != event.destinationId)
        .toList();

    if (updatedDestinations.length == state.destinations.length) return;

    emit(state.copyWith(destinations: updatedDestinations));
  }

  void _onUpdateZoom(UpdateZoom event, Emitter<MapState> emit) {
    emit(state.copyWith(zoom: event.zoom));
  }

  void _onToggleFollowMode(ToggleFollowMode event, Emitter<MapState> emit) {
    emit(state.copyWith(isFollowingUser: !state.isFollowingUser));
  }

  Future<void> _onRequestMyLocation(
    RequestMyLocation event,
    Emitter<MapState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final location = await _locationService.getCurrentLocation();

    if (location != null) {
      final position = LatLng(location.latitude, location.longitude);
      _mapService.moveTo(position, state.zoom);
      emit(
        state.copyWith(
          center: position,
          isFollowingUser: true,
          isLoading: false,
        ),
      );
    } else {
      emit(
        state.copyWith(
          isLoading: false,
          error: const PermissionFailure(message: 'Location permission denied'),
        ),
      );
    }
  }

  void _onUserLocationUpdated(
    UserLocationUpdated event,
    Emitter<MapState> emit,
  ) {
    if (state.isFollowingUser) {
      _mapService.moveTo(event.position, state.zoom);
      emit(state.copyWith(center: event.position));
    }
  }

  void _onMapMoved(MapMoved event, Emitter<MapState> emit) {
    emit(state.copyWith(center: event.center, zoom: event.zoom));
  }
}
