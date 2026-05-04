import 'package:equatable/equatable.dart';
import 'package:numpang_app/data/models/recent_search_model.dart';
import 'package:numpang_app/domain/entities/place_suggestion.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class QueryChanged extends SearchEvent {
  const QueryChanged(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

class SearchSubmitted extends SearchEvent {
  const SearchSubmitted(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

class SuggestionSelected extends SearchEvent {
  const SuggestionSelected(this.suggestion);
  final PlaceSuggestion suggestion;

  @override
  List<Object?> get props => [suggestion];
}

class ClearSearch extends SearchEvent {
  const ClearSearch();
}

class SearchDebounced extends SearchEvent {
  const SearchDebounced(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

class LoadRecentSearches extends SearchEvent {
  const LoadRecentSearches();
}

class AddRecentSearch extends SearchEvent {
  const AddRecentSearch(this.query, {this.suggestion});
  final String query;
  final PlaceSuggestion? suggestion;

  @override
  List<Object?> get props => [query, suggestion];
}

class RemoveRecentSearch extends SearchEvent {
  const RemoveRecentSearch(this.searchId);
  final String searchId;

  @override
  List<Object?> get props => [searchId];
}

class ClearRecentSearches extends SearchEvent {
  const ClearRecentSearches();
}

class SetGeocodingProvider extends SearchEvent {
  const SetGeocodingProvider(this.provider);
  final String provider; // 'mapbox', 'nominatim', 'geocodeXyz'

  @override
  List<Object?> get props => [provider];
}
