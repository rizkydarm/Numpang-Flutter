import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/destination.dart';

class DestinationState extends Equatable {
  final List<Destination> destinations;
  final bool isLoading;
  final Failure? error;
  final Destination? selectedDestination;

  const DestinationState({
    this.destinations = const [],
    this.isLoading = false,
    this.error,
    this.selectedDestination,
  });

  factory DestinationState.initial() {
    return const DestinationState();
  }

  DestinationState copyWith({
    List<Destination>? destinations,
    bool? isLoading,
    Failure? error,
    Destination? selectedDestination,
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
    );
  }

  @override
  List<Object?> get props => [
        destinations,
        isLoading,
        error,
        selectedDestination,
      ];
}
