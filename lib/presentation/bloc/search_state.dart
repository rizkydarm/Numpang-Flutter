import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/place_suggestion.dart';

class SearchState extends Equatable {
  final String query;
  final List<PlaceSuggestion> suggestions;
  final bool isLoading;
  final Failure? error;
  final PlaceSuggestion? selectedSuggestion;
  final LatLng? resultPosition;
  final String? resultAddress;

  const SearchState({
    this.query = '',
    this.suggestions = const [],
    this.isLoading = false,
    this.error,
    this.selectedSuggestion,
    this.resultPosition,
    this.resultAddress,
  });

  factory SearchState.initial() {
    return const SearchState();
  }

  SearchState copyWith({
    String? query,
    List<PlaceSuggestion>? suggestions,
    bool? isLoading,
    Failure? error,
    PlaceSuggestion? selectedSuggestion,
    LatLng? resultPosition,
    String? resultAddress,
    bool clearSelected = false,
  }) {
    return SearchState(
      query: query ?? this.query,
      suggestions: suggestions ?? this.suggestions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedSuggestion:
          clearSelected ? null : (selectedSuggestion ?? this.selectedSuggestion),
      resultPosition: resultPosition ?? this.resultPosition,
      resultAddress: resultAddress ?? this.resultAddress,
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
      ];
}
