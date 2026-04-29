import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/repositories/geocoding_repository.dart';

import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final GeocodingRepository _geocodingRepository;
  Timer? _debounceTimer;
  static const Duration _debounceDelay = Duration(milliseconds: 300);

  SearchBloc({required GeocodingRepository geocodingRepository})
      : _geocodingRepository = geocodingRepository,
        super(SearchState.initial()) {
    on<QueryChanged>(_onQueryChanged);
    on<SearchDebounced>(_onSearchDebounced);
    on<SearchSubmitted>(_onSearchSubmitted);
    on<SuggestionSelected>(_onSuggestionSelected);
    on<ClearSearch>(_onClearSearch);
  }

  void _onQueryChanged(QueryChanged event, Emitter<SearchState> emit) {
    _debounceTimer?.cancel();

    if (event.query.isEmpty) {
      emit(state.copyWith(
        query: '',
        suggestions: [],
        clearSelected: true,
      ));
      return;
    }

    emit(state.copyWith(query: event.query));

    _debounceTimer = Timer(_debounceDelay, () {
      add(SearchDebounced(event.query));
    });
  }

  Future<void> _onSearchDebounced(
    SearchDebounced event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.isEmpty) return;

    emit(state.copyWith(isLoading: true, error: null));

    final result = await _geocodingRepository.autocomplete(event.query);

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        error: failure,
        suggestions: [],
      )),
      (suggestions) => emit(state.copyWith(
        isLoading: false,
        suggestions: suggestions,
        error: null,
      )),
    );
  }

  Future<void> _onSearchSubmitted(
    SearchSubmitted event,
    Emitter<SearchState> emit,
  ) async {
    _debounceTimer?.cancel();

    if (event.query.isEmpty) {
      emit(state.copyWith(suggestions: [], clearSelected: true));
      return;
    }

    emit(state.copyWith(
      query: event.query,
      isLoading: true,
      error: null,
    ));

    final result = await _geocodingRepository.searchAddress(event.query);

    await result.fold(
      (failure) async => emit(state.copyWith(
        isLoading: false,
        error: failure,
      )),
      (position) async {
        final reverseResult =
            await _geocodingRepository.reverseGeocode(position);

        reverseResult.fold(
          (failure) => emit(state.copyWith(
            isLoading: false,
            error: failure,
          )),
          (address) => emit(state.copyWith(
            isLoading: false,
            error: null,
            resultPosition: position,
            resultAddress: address,
          )),
        );
      },
    );
  }

  void _onSuggestionSelected(
    SuggestionSelected event,
    Emitter<SearchState> emit,
  ) {
    _debounceTimer?.cancel();
    emit(state.copyWith(
      selectedSuggestion: event.suggestion,
      query: event.suggestion.name,
      suggestions: [],
      error: null,
      resultPosition: LatLng(event.suggestion.latitude, event.suggestion.longitude),
      resultAddress: event.suggestion.address,
    ));
  }

  void _onClearSearch(ClearSearch event, Emitter<SearchState> emit) {
    _debounceTimer?.cancel();
    emit(SearchState.initial());
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
