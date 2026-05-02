import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import 'package:numpang_app/domain/entities/destination.dart';

abstract class DestinationEvent extends Equatable {
  const DestinationEvent();

  @override
  List<Object?> get props => [];
}

/// Load all destinations from repository
class LoadDestinations extends DestinationEvent {
  const LoadDestinations();
}

/// Add a new destination
class AddDestination extends DestinationEvent {

  const AddDestination({
    required this.name,
    required this.address,
    required this.position,
  });
  final String name;
  final String address;
  final LatLng position;

  @override
  List<Object?> get props => [name, address, position];
}

/// Delete a destination by ID
class DeleteDestination extends DestinationEvent { // For confirmation dialog

  const DeleteDestination({
    required this.id,
    required this.name,
  });
  final String id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}

/// Select a destination to highlight on map
class SelectDestination extends DestinationEvent {

  const SelectDestination(this.destination);
  final Destination? destination;

  @override
  List<Object?> get props => [destination];
}

/// Clear error state
class ClearDestinationError extends DestinationEvent {
  const ClearDestinationError();
}

/// Refresh destinations list
class RefreshDestinations extends DestinationEvent {
  const RefreshDestinations();
}
