import 'package:equatable/equatable.dart';
import '../../domain/entities/place_suggestion.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class QueryChanged extends SearchEvent {
  final String query;

  const QueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class SearchSubmitted extends SearchEvent {
  final String query;

  const SearchSubmitted(this.query);

  @override
  List<Object?> get props => [query];
}

class SuggestionSelected extends SearchEvent {
  final PlaceSuggestion suggestion;

  const SuggestionSelected(this.suggestion);

  @override
  List<Object?> get props => [suggestion];
}

class ClearSearch extends SearchEvent {
  const ClearSearch();
}

class SearchDebounced extends SearchEvent {
  final String query;

  const SearchDebounced(this.query);

  @override
  List<Object?> get props => [query];
}
