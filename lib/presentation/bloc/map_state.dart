import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/destination.dart';

class MapState extends Equatable {
  final LatLng center;
  final double zoom;
  final List<Destination> destinations;
  final bool isFollowingUser;
  final bool isLoading;
  final Failure? error;

  const MapState({
    required this.center,
    required this.zoom,
    this.destinations = const [],
    this.isFollowingUser = false,
    this.isLoading = false,
    this.error,
  });

  factory MapState.initial() {
    return const MapState(
      center: LatLng(0, 0),
      zoom: 13.0,
      destinations: [],
      isFollowingUser: false,
      isLoading: true,
    );
  }

  MapState copyWith({
    LatLng? center,
    double? zoom,
    List<Destination>? destinations,
    bool? isFollowingUser,
    bool? isLoading,
    Failure? error,
  }) {
    return MapState(
      center: center ?? this.center,
      zoom: zoom ?? this.zoom,
      destinations: destinations ?? this.destinations,
      isFollowingUser: isFollowingUser ?? this.isFollowingUser,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        center,
        zoom,
        destinations,
        isFollowingUser,
        isLoading,
        error,
      ];
}
