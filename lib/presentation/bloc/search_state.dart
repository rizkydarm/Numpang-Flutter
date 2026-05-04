import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import 'package:numpang_app/core/errors/failures.dart';
import 'package:numpang_app/data/models/recent_search_model.dart';
import 'package:numpang_app/domain/entities/place_suggestion.dart';

class SearchState extends Equatable {
  const SearchState({
    this.query = '',
    this.suggestions = const [],
    this.isLoading = false,
    this.error,
    this.selectedSuggestion,
    this.resultPosition,
    this.resultAddress,
    this.recentSearches = const [],
    this.isLoadingRecent = false,
    this.selectedProvider = 'mapbox', // Default to Mapbox
  });

  factory SearchState.initial() {
    return const SearchState();
  }
  final String query;
  final List<PlaceSuggestion> suggestions;
  final bool isLoading;
  final Failure? error;
  final PlaceSuggestion? selectedSuggestion;
  final LatLng? resultPosition;
  final String? resultAddress;
  final List<RecentSearchModel> recentSearches;
  final bool isLoadingRecent;
  final String selectedProvider;

  SearchState copyWith({
    String? query,
    List<PlaceSuggestion>? suggestions,
    bool? isLoading,
    Failure? error,
    PlaceSuggestion? selectedSuggestion,
    LatLng? resultPosition,
    String? resultAddress,
    bool clearSelected = false,
    List<RecentSearchModel>? recentSearches,
    bool? isLoadingRecent,
    String? selectedProvider,
  }) {
    return SearchState(
      query: query ?? this.query,
      suggestions: suggestions ?? this.suggestions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedSuggestion: clearSelected
          ? null
          : (selectedSuggestion ?? this.selectedSuggestion),
      resultPosition: resultPosition ?? this.resultPosition,
      resultAddress: resultAddress ?? this.resultAddress,
      recentSearches: recentSearches ?? this.recentSearches,
      isLoadingRecent: isLoadingRecent ?? this.isLoadingRecent,
      selectedProvider: selectedProvider ?? this.selectedProvider,
    );
  }

  @override
  List<Object?> get props => [
    query,
    suggestions,
    isLoading,
    error,
    selectedSuggestion,
    resultPosition,
    resultAddress,
    recentSearches,
    isLoadingRecent,
    selectedProvider,
  ];
}
