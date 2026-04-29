import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:numpang_app/core/errors/failures.dart';
import 'package:numpang_app/domain/entities/place_suggestion.dart';
import 'package:numpang_app/domain/repositories/geocoding_repository.dart';
import 'package:numpang_app/presentation/bloc/search_bloc.dart';
import 'package:numpang_app/presentation/bloc/search_event.dart';
import 'package:numpang_app/presentation/bloc/search_state.dart';

import 'search_bloc_test.mocks.dart';

@GenerateMocks([GeocodingRepository])
void main() {
  late MockGeocodingRepository mockGeocodingRepository;

  final testSuggestions = [
    const PlaceSuggestion(
      id: '1',
      name: 'Central Park',
      address: 'Central Park, New York, NY',
      latitude: 40.7829,
      longitude: -73.9654,
    ),
    const PlaceSuggestion(
      id: '2',
      name: 'Times Square',
      address: 'Times Square, New York, NY',
      latitude: 40.7580,
      longitude: -73.9855,
    ),
  ];

  setUp(() {
    mockGeocodingRepository = MockGeocodingRepository();
  });

  group('QueryChanged', () {
    blocTest<SearchBloc, SearchState>(
      'emits empty state for empty query',
      build: () => SearchBloc(geocodingRepository: mockGeocodingRepository),
      act: (bloc) => bloc.add(const QueryChanged('')),
      expect: () => [
        isA<SearchState>()
            .having((s) => s.query, 'query', '')
            .having((s) => s.suggestions, 'suggestions', []),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'updates query and triggers debounced search',
      setUp: () {
        when(
          mockGeocodingRepository.autocomplete('New York'),
        ).thenAnswer((_) async => Right(testSuggestions));
      },
      build: () => SearchBloc(geocodingRepository: mockGeocodingRepository),
      act: (bloc) => bloc.add(const QueryChanged('New York')),
      wait: const Duration(milliseconds: 350),
      expect: () => [
        isA<SearchState>().having((s) => s.query, 'query', 'New York'),
        isA<SearchState>()
            .having((s) => s.isLoading, 'isLoading', true)
            .having((s) => s.query, 'query', 'New York'),
        isA<SearchState>()
            .having((s) => s.suggestions.length, 'suggestions count', 2)
            .having((s) => s.isLoading, 'isLoading', false),
      ],
    );
  });

  group('SearchSubmitted', () {
    blocTest<SearchBloc, SearchState>(
      'emits empty state for empty query',
      build: () => SearchBloc(geocodingRepository: mockGeocodingRepository),
      act: (bloc) => bloc.add(const SearchSubmitted('')),
      expect: () => [
        isA<SearchState>()
            .having((s) => s.suggestions, 'suggestions', [])
            .having((s) => s.selectedSuggestion, 'selectedSuggestion', null),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'performs immediate search without debounce',
      setUp: () {
        when(
          mockGeocodingRepository.searchAddress('Central Park'),
        ).thenAnswer((_) async => const Right(LatLng(40.7829, -73.9654)));
        when(
          mockGeocodingRepository.reverseGeocode(any),
        ).thenAnswer((_) async => const Right('Central Park, New York'));
      },
      build: () => SearchBloc(geocodingRepository: mockGeocodingRepository),
      act: (bloc) => bloc.add(const SearchSubmitted('Central Park')),
      expect: () => [
        isA<SearchState>()
            .having((s) => s.query, 'query', 'Central Park')
            .having((s) => s.isLoading, 'isLoading', true),
        isA<SearchState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.error, 'error', null),
      ],
    );
  });

  group('SuggestionSelected', () {
    blocTest<SearchBloc, SearchState>(
      'selects suggestion and clears suggestions list',
      build: () => SearchBloc(geocodingRepository: mockGeocodingRepository),
      seed: () => SearchState(query: 'Central', suggestions: testSuggestions),
      act: (bloc) => bloc.add(SuggestionSelected(testSuggestions.first)),
      expect: () => [
        isA<SearchState>()
            .having(
              (s) => s.selectedSuggestion,
              'selectedSuggestion',
              testSuggestions.first,
            )
            .having((s) => s.query, 'query', 'Central Park')
            .having((s) => s.suggestions, 'suggestions', []),
      ],
    );
  });

  group('ClearSearch', () {
    blocTest<SearchBloc, SearchState>(
      'resets to initial state',
      build: () => SearchBloc(geocodingRepository: mockGeocodingRepository),
      seed: () => SearchState(
        query: 'test',
        suggestions: testSuggestions,
        selectedSuggestion: testSuggestions.first,
      ),
      act: (bloc) => bloc.add(const ClearSearch()),
      expect: () => [
        isA<SearchState>()
            .having((s) => s.query, 'query', '')
            .having((s) => s.suggestions, 'suggestions', [])
            .having((s) => s.selectedSuggestion, 'selectedSuggestion', null),
      ],
    );
  });

  group('Error handling', () {
    blocTest<SearchBloc, SearchState>(
      'emits error state on geocoding failure',
      setUp: () {
        when(mockGeocodingRepository.autocomplete('Unknown')).thenAnswer(
          (_) async =>
              const Left(ServerFailure(message: 'Service unavailable')),
        );
      },
      build: () => SearchBloc(geocodingRepository: mockGeocodingRepository),
      act: (bloc) => bloc.add(const QueryChanged('Unknown')),
      wait: const Duration(milliseconds: 350),
      expect: () => [
        isA<SearchState>().having((s) => s.query, 'query', 'Unknown'),
        isA<SearchState>()
            .having((s) => s.isLoading, 'isLoading', true)
            .having((s) => s.query, 'query', 'Unknown'),
        isA<SearchState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.error, 'error', isA<ServerFailure>())
            .having((s) => s.suggestions, 'suggestions', []),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'emits error state on network failure',
      setUp: () {
        when(mockGeocodingRepository.autocomplete('Test')).thenAnswer(
          (_) async => const Left(NetworkFailure(message: 'No connection')),
        );
      },
      build: () => SearchBloc(geocodingRepository: mockGeocodingRepository),
      act: (bloc) => bloc.add(const QueryChanged('Test')),
      wait: const Duration(milliseconds: 350),
      expect: () => [
        isA<SearchState>().having((s) => s.query, 'query', 'Test'),
        isA<SearchState>().having((s) => s.isLoading, 'isLoading', true),
        isA<SearchState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.error, 'error', isA<NetworkFailure>()),
      ],
    );
  });
}
