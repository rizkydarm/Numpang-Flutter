import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/destination.dart';
import '../../../domain/usecases/add_destination_usecase.dart';
import '../../../domain/usecases/delete_destination_usecase.dart';
import '../../../domain/usecases/get_destinations_usecase.dart';
import 'destination_event.dart';
import 'destination_state.dart';

class DestinationBloc extends Bloc<DestinationEvent, DestinationState> {
  final GetDestinationsUseCase _getDestinations;
  final AddDestinationUseCase _addDestination;
  final DeleteDestinationUseCase _deleteDestination;

  DestinationBloc({
    required GetDestinationsUseCase getDestinations,
    required AddDestinationUseCase addDestination,
    required DeleteDestinationUseCase deleteDestination,
  }) : _getDestinations = getDestinations,
       _addDestination = addDestination,
       _deleteDestination = deleteDestination,
       super(DestinationState.initial()) {
    on<LoadDestinations>(_onLoadDestinations);
    on<AddDestination>(_onAddDestination);
    on<DeleteDestination>(_onDeleteDestination);
    on<SelectDestination>(_onSelectDestination);
    on<ClearDestinationError>(_onClearError);
    on<RefreshDestinations>(_onLoadDestinations);

    // Load destinations on init
    add(const LoadDestinations());
  }

  Future<void> _onLoadDestinations(
    DestinationEvent event,
    Emitter<DestinationState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _getDestinations();

    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure)),
      (destinations) =>
          emit(state.copyWith(destinations: destinations, isLoading: false)),
    );
  }

  Future<void> _onAddDestination(
    AddDestination event,
    Emitter<DestinationState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final destination = Destination(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: event.name,
      address: event.address,
      latitude: event.position.latitude,
      longitude: event.position.longitude,
      createdAt: DateTime.now(),
    );

    final result = await _addDestination(destination);

    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure)),
      (newDestination) {
        final updated = [...state.destinations, newDestination];
        emit(
          state.copyWith(
            destinations: updated,
            isLoading: false,
            selectedDestination: newDestination,
          ),
        );
      },
    );
  }

  Future<void> _onDeleteDestination(
    DeleteDestination event,
    Emitter<DestinationState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _deleteDestination(event.id);

    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure)),
      (_) {
        final updated = state.destinations
            .where((d) => d.id != event.id)
            .toList();

        // Clear selection if deleted was selected
        final clearSelected = state.selectedDestination?.id == event.id;

        emit(
          state.copyWith(
            destinations: updated,
            isLoading: false,
            clearSelected: clearSelected,
          ),
        );
      },
    );
  }

  void _onSelectDestination(
    SelectDestination event,
    Emitter<DestinationState> emit,
  ) {
    emit(state.copyWith(selectedDestination: event.destination));
  }

  void _onClearError(
    ClearDestinationError event,
    Emitter<DestinationState> emit,
  ) {
    emit(state.copyWith(clearError: true));
  }
}
