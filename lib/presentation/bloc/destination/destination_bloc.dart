import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:numpang_app/domain/entities/destination.dart';
import 'package:numpang_app/domain/repositories/destination_repository.dart';
import 'package:numpang_app/domain/repositories/geocoding_repository.dart';
import 'package:numpang_app/domain/usecases/add_destination_usecase.dart';
import 'package:numpang_app/domain/usecases/delete_destination_usecase.dart';
import 'package:numpang_app/domain/usecases/get_destinations_usecase.dart';
import 'package:numpang_app/presentation/bloc/destination/destination_event.dart';
import 'package:numpang_app/presentation/bloc/destination/destination_state.dart';

class DestinationBloc extends Bloc<DestinationEvent, DestinationState> {
  DestinationBloc({
    required GetDestinationsUseCase getDestinations,
    required AddDestinationUseCase addDestination,
    required DeleteDestinationUseCase deleteDestination,
    required GeocodingRepository geocodingRepository,
    required DestinationRepository destinationRepository,
  }) : _getDestinations = getDestinations,
       _addDestination = addDestination,
       _deleteDestination = deleteDestination,
       _geocodingRepository = geocodingRepository,
       _destinationRepository = destinationRepository,
       super(DestinationState.initial()) {
    on<LoadDestinations>(_onLoadDestinations);
    on<AddDestination>(_onAddDestination);
    on<DeleteDestination>(_onDeleteDestination);
    on<SelectDestination>(_onSelectDestination);
    on<ClearDestinationError>(_onClearError);
    on<RefreshDestinations>(_onLoadDestinations);
    on<LoadDestinationAddress>(_onLoadDestinationAddress);
    on<ClearAllDestinations>(_onClearAllDestinations);

    // Load destinations on init
    add(const LoadDestinations());
  }
  final GetDestinationsUseCase _getDestinations;
  final AddDestinationUseCase _addDestination;
  final DeleteDestinationUseCase _deleteDestination;
  final GeocodingRepository _geocodingRepository;
  final DestinationRepository _destinationRepository;

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

  Future<void> _onLoadDestinationAddress(
    LoadDestinationAddress event,
    Emitter<DestinationState> emit,
  ) async {
    // Skip if already loaded
    if (state.destinationAddresses.containsKey(event.destinationId)) {
      return;
    }

    final destination = state.destinations.firstWhere(
      (d) => d.id == event.destinationId,
      orElse: () => throw Exception('Destination not found'),
    );

    final position = LatLng(
      destination.latitude,
      destination.longitude,
    );

    final result = await _geocodingRepository.reverseGeocode(position);
    result.fold(
      (failure) => null, // Keep original address on failure
      (address) {
        final updatedAddresses = Map<String, String>.from(
          state.destinationAddresses,
        )..[event.destinationId] = address;
        emit(state.copyWith(destinationAddresses: updatedAddresses));
      },
    );
  }

  Future<void> _onClearAllDestinations(
    ClearAllDestinations event,
    Emitter<DestinationState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _destinationRepository.deleteAllDestinations();

    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure)),
      (_) => emit(
        state.copyWith(
          destinations: [],
          isLoading: false,
          clearSelected: true,
          destinationAddresses: {},
        ),
      ),
    );
  }
}
