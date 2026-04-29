import 'package:equatable/equatable.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/place_suggestion.dart';

class SearchState extends Equatable {
  final String query;
  final List<PlaceSuggestion> suggestions;
  final bool isLoading;
  final Failure? error;
  final PlaceSuggestion? selectedSuggestion;

  const SearchState({
    this.query = '',
    this.suggestions = const [],
    this.isLoading = false,
    this.error,
    this.selectedSuggestion,
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
    bool clearSelected = false,
  }) {
    return SearchState(
      query: query ?? this.query,
      suggestions: suggestions ?? this.suggestions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedSuggestion:
          clearSelected ? null : (selectedSuggestion ?? this.selectedSuggestion),
    );
  }

  @override
  List<Object?> get props => [
        query,
        suggestions,
        isLoading,
        error,
        selectedSuggestion,
      ];
}
