import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import '../../../domain/entities/destination.dart';

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
  final String name;
  final String address;
  final LatLng position;

  const AddDestination({
    required this.name,
    required this.address,
    required this.position,
  });

  @override
  List<Object?> get props => [name, address, position];
}

/// Delete a destination by ID
class DeleteDestination extends DestinationEvent {
  final String id;
  final String name; // For confirmation dialog

  const DeleteDestination({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];
}

/// Select a destination to highlight on map
class SelectDestination extends DestinationEvent {
  final Destination? destination;

  const SelectDestination(this.destination);

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
