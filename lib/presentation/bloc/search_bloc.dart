import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:numpang_app/data/datasources/recent_searches_local_datasource.dart';
import 'package:numpang_app/domain/repositories/geocoding_repository.dart';

import 'package:numpang_app/presentation/bloc/search_event.dart';
import 'package:numpang_app/presentation/bloc/search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc({
    required GeocodingRepository geocodingRepository,
    RecentSearchesLocalDataSource? recentSearchesDataSource,
  }) : _geocodingRepository = geocodingRepository,
       _recentSearchesDataSource = recentSearchesDataSource,
       super(SearchState.initial()) {
    on<QueryChanged>(_onQueryChanged);
    on<SearchDebounced>(_onSearchDebounced);
    on<SearchSubmitted>(_onSearchSubmitted);
    on<SuggestionSelected>(_onSuggestionSelected);
    on<ClearSearch>(_onClearSearch);
    on<LoadRecentSearches>(_onLoadRecentSearches);
    on<AddRecentSearch>(_onAddRecentSearch);
    on<RemoveRecentSearch>(_onRemoveRecentSearch);
    on<ClearRecentSearches>(_onClearRecentSearches);
  }
  final GeocodingRepository _geocodingRepository;
  final RecentSearchesLocalDataSource? _recentSearchesDataSource;
  Timer? _debounceTimer;
  static const Duration _debounceDelay = Duration(milliseconds: 300);

  void _onQueryChanged(QueryChanged event, Emitter<SearchState> emit) {
    _debounceTimer?.cancel();

    if (event.query.isEmpty) {
      emit(
        state.copyWith(
          query: '',
          suggestions: [],
          clearSelected: true,
        ),
      );
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

    emit(state.copyWith(isLoading: true));

    final result = await _geocodingRepository.autocomplete(event.query);

    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoading: false,
          error: failure,
          suggestions: [],
        ),
      ),
      (suggestions) => emit(
        state.copyWith(
          isLoading: false,
          suggestions: suggestions,
        ),
      ),
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

    emit(
      state.copyWith(
        query: event.query,
        isLoading: true,
      ),
    );

    final result = await _geocodingRepository.searchAddress(event.query);

    await result.fold(
      (failure) async => emit(
        state.copyWith(
          isLoading: false,
          error: failure,
        ),
      ),
      (position) async {
        final reverseResult = await _geocodingRepository.reverseGeocode(
          position,
        );

        reverseResult.fold(
          (failure) => emit(
            state.copyWith(
              isLoading: false,
              error: failure,
            ),
          ),
          (address) => emit(
            state.copyWith(
              isLoading: false,
              resultPosition: position,
              resultAddress: address,
            ),
          ),
        );
      },
    );
  }

  void _onSuggestionSelected(
    SuggestionSelected event,
    Emitter<SearchState> emit,
  ) {
    _debounceTimer?.cancel();
    emit(
      state.copyWith(
        selectedSuggestion: event.suggestion,
        query: event.suggestion.name,
        suggestions: [],
        resultPosition: LatLng(
          event.suggestion.latitude,
          event.suggestion.longitude,
        ),
        resultAddress: event.suggestion.address,
      ),
    );
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

  Future<void> _onLoadRecentSearches(
    LoadRecentSearches event,
    Emitter<SearchState> emit,
  ) async {
    if (_recentSearchesDataSource == null) return;

    emit(state.copyWith(isLoadingRecent: true));
    final searches = await _recentSearchesDataSource.getRecentSearches();
    emit(state.copyWith(recentSearches: searches, isLoadingRecent: false));
  }

  Future<void> _onAddRecentSearch(
    AddRecentSearch event,
    Emitter<SearchState> emit,
  ) async {
    if (_recentSearchesDataSource == null) return;

    await _recentSearchesDataSource.addSearch(
      event.query,
      suggestion: event.suggestion,
    );
    final searches = await _recentSearchesDataSource.getRecentSearches();
    emit(state.copyWith(recentSearches: searches));
  }

  Future<void> _onRemoveRecentSearch(
    RemoveRecentSearch event,
    Emitter<SearchState> emit,
  ) async {
    if (_recentSearchesDataSource == null) return;

    await _recentSearchesDataSource.removeSearch(event.searchId);
    final searches = await _recentSearchesDataSource.getRecentSearches();
    emit(state.copyWith(recentSearches: searches));
  }

  Future<void> _onClearRecentSearches(
    ClearRecentSearches event,
    Emitter<SearchState> emit,
  ) async {
    if (_recentSearchesDataSource == null) return;

    await _recentSearchesDataSource.clearAllSearches();
    emit(state.copyWith(recentSearches: []));
  }
}
