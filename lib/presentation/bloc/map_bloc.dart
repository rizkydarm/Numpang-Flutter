import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:stream_transform/stream_transform.dart';
import '../../domain/entities/user_location.dart';
import '../../../data/repositories/location_repository_impl.dart';
import 'map_event.dart';
import 'map_state.dart';

class MapBloc extends Bloc<MapBlocEvent, MapState> {
  final LocationService _locationService;
  StreamSubscription<UserLocation>? _locationSubscription;

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
        destinations: [],
        isFollowingUser: location != null,
        isLoading: false,
      ),
    );

    // Start listening to location updates
    _locationSubscription = _locationService.getLocationStream().listen(
      (userLocation) {
        add(UserLocationUpdated(
          LatLng(userLocation.latitude, userLocation.longitude),
        ));
      },
      onError: (error) {
        // Handle location errors (permission denied, etc.)
        // For now, we'll just ignore them to keep the map functional
      },
    );
  }

  void _onCenterOnLocation(CenterOnLocation event, Emitter<MapState> emit) {
    emit(
      state.copyWith(center: event.position, zoom: event.zoom ?? state.zoom),
    );
  }

  void _onTapOnMap(TapOnMap event, Emitter<MapState> emit) {
    emit(state.copyWith(center: event.position));
  }

  void _onAddMarker(AddMarker event, Emitter<MapState> emit) {
    final newDestination = event.destination;
    final updatedDestinations = [...state.destinations, newDestination];

    emit(
      state.copyWith(
        destinations: updatedDestinations,
        center: LatLng(newDestination.latitude, newDestination.longitude),
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
}
