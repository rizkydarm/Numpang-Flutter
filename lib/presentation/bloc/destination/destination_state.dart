import 'package:equatable/equatable.dart';
import 'package:numpang_app/core/errors/failures.dart';
import 'package:numpang_app/domain/entities/destination.dart';

class DestinationState extends Equatable {
  const DestinationState({
    this.destinations = const [],
    this.isLoading = false,
    this.error,
    this.selectedDestination,
    this.destinationAddresses = const {},
  });

  factory DestinationState.initial() {
    return const DestinationState();
  }
  final List<Destination> destinations;
  final bool isLoading;
  final Failure? error;
  final Destination? selectedDestination;
  final Map<String, String> destinationAddresses;

  DestinationState copyWith({
    List<Destination>? destinations,
    bool? isLoading,
    Failure? error,
    Destination? selectedDestination,
    Map<String, String>? destinationAddresses,
    bool clearError = false,
    bool clearSelected = false,
  }) {
    return DestinationState(
      destinations: destinations ?? this.destinations,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      selectedDestination: clearSelected
          ? null
          : selectedDestination ?? this.selectedDestination,
      destinationAddresses: destinationAddresses ?? this.destinationAddresses,
    );
  }

  @override
  List<Object?> get props => [
    destinations,
    isLoading,
    error,
    selectedDestination,
    destinationAddresses,
  ];
}
