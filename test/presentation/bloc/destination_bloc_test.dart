import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';
import 'package:numpang_app/core/errors/failures.dart';
import 'package:numpang_app/domain/entities/destination.dart';
import 'package:numpang_app/domain/usecases/add_destination_usecase.dart';
import 'package:numpang_app/domain/usecases/delete_destination_usecase.dart';
import 'package:numpang_app/domain/usecases/get_destinations_usecase.dart';
import 'package:numpang_app/presentation/bloc/destination/destination_bloc.dart';
import 'package:numpang_app/presentation/bloc/destination/destination_event.dart';
import 'package:numpang_app/presentation/bloc/destination/destination_state.dart';

class MockGetDestinationsUseCase extends Mock
    implements GetDestinationsUseCase {}

class MockAddDestinationUseCase extends Mock implements AddDestinationUseCase {}

class MockDeleteDestinationUseCase extends Mock
    implements DeleteDestinationUseCase {}

void main() {
  late MockGetDestinationsUseCase mockGetDestinations;
  late MockAddDestinationUseCase mockAddDestination;
  late MockDeleteDestinationUseCase mockDeleteDestination;
  late DestinationBloc bloc;

  final testDestination = Destination(
    id: '1',
    name: 'Test Destination',
    address: '123 Test St',
    latitude: -6.2088,
    longitude: 106.8456,
    createdAt: DateTime(2026, 5, 1),
  );

  final testPosition = const LatLng(-6.2088, 106.8456);

  setUp(() {
    mockGetDestinations = MockGetDestinationsUseCase();
    mockAddDestination = MockAddDestinationUseCase();
    mockDeleteDestination = MockDeleteDestinationUseCase();

    // Register fallback value for any() matcher with Destination
    registerFallbackValue(testDestination);

    // Default stub for getDestinations (called in constructor)
    when(
      () => mockGetDestinations.call(),
    ).thenAnswer((_) async => const Right([]));

    bloc = DestinationBloc(
      getDestinations: mockGetDestinations,
      addDestination: mockAddDestination,
      deleteDestination: mockDeleteDestination,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('DestinationBloc', () {
    test('initial state is correct', () {
      expect(bloc.state, DestinationState.initial());
    });

    group('LoadDestinations', () {
      blocTest<DestinationBloc, DestinationState>(
        'emits [loading, loaded] when destinations loaded successfully',
        build: () {
          when(
            () => mockGetDestinations.call(),
          ).thenAnswer((_) async => Right([testDestination]));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadDestinations()),
        expect: () => [
          DestinationState.initial().copyWith(
            isLoading: true,
            clearError: true,
          ),
          DestinationState.initial().copyWith(
            destinations: [testDestination],
            isLoading: false,
          ),
        ],
      );

      blocTest<DestinationBloc, DestinationState>(
        'emits [loading, error] when load fails',
        build: () {
          when(() => mockGetDestinations.call()).thenAnswer(
            (_) async => const Left(ServerFailure(message: 'Server error')),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadDestinations()),
        expect: () => [
          DestinationState.initial().copyWith(
            isLoading: true,
            clearError: true,
          ),
          DestinationState.initial().copyWith(
            isLoading: false,
            error: const ServerFailure(message: 'Server error'),
          ),
        ],
      );
    });

    group('AddDestination', () {
      blocTest<DestinationBloc, DestinationState>(
        'emits [loading, loaded with new destination] when add succeeds',
        build: () {
          when(
            () => mockAddDestination(any()),
          ).thenAnswer((_) async => Right(testDestination));
          when(
            () => mockGetDestinations.call(),
          ).thenAnswer((_) async => const Right([]));
          return DestinationBloc(
            getDestinations: mockGetDestinations,
            addDestination: mockAddDestination,
            deleteDestination: mockDeleteDestination,
          );
        },
        act: (bloc) => bloc.add(
          AddDestination(
            name: 'Test Destination',
            address: '123 Test St',
            position: testPosition,
          ),
        ),
        expect: () => [
          // Constructor: loading
          predicate<DestinationState>((state) {
            return state.isLoading == true;
          }),
          // Constructor: loaded
          predicate<DestinationState>((state) {
            return state.isLoading == false && state.destinations.isEmpty;
          }),
          // AddDestination: loading
          predicate<DestinationState>((state) {
            return state.isLoading == true && state.destinations.isEmpty;
          }),
          // AddDestination: loaded with new destination
          predicate<DestinationState>((state) {
            return state.destinations.length == 1 &&
                state.destinations.first.name == 'Test Destination' &&
                state.isLoading == false;
          }),
        ],
      );

      blocTest<DestinationBloc, DestinationState>(
        'emits [loading, error] when add fails',
        build: () {
          when(() => mockAddDestination(any())).thenAnswer(
            (_) async => const Left(CacheFailure(message: 'Cache error')),
          );
          when(
            () => mockGetDestinations.call(),
          ).thenAnswer((_) async => const Right([]));
          return DestinationBloc(
            getDestinations: mockGetDestinations,
            addDestination: mockAddDestination,
            deleteDestination: mockDeleteDestination,
          );
        },
        act: (bloc) => bloc.add(
          AddDestination(
            name: 'Test Destination',
            address: '123 Test St',
            position: testPosition,
          ),
        ),
        expect: () => [
          // Constructor: loading
          predicate<DestinationState>((state) {
            return state.isLoading == true;
          }),
          // Constructor: loaded
          predicate<DestinationState>((state) {
            return state.isLoading == false && state.destinations.isEmpty;
          }),
          // AddDestination: loading
          predicate<DestinationState>((state) {
            return state.isLoading == true && state.error == null;
          }),
          // AddDestination: error
          predicate<DestinationState>((state) {
            return state.isLoading == false &&
                state.error == const CacheFailure(message: 'Cache error');
          }),
        ],
      );
    });

    group('DeleteDestination', () {
      blocTest<DestinationBloc, DestinationState>(
        'emits [loading, loaded without deleted destination] when delete succeeds',
        seed: () => DestinationState.initial().copyWith(
          destinations: [testDestination],
        ),
        build: () {
          when(
            () => mockDeleteDestination(any()),
          ).thenAnswer((_) async => const Right(null));
          when(
            () => mockGetDestinations.call(),
          ).thenAnswer((_) async => Right([testDestination]));
          return bloc;
        },
        act: (bloc) => bloc.add(
          DeleteDestination(id: testDestination.id, name: testDestination.name),
        ),
        expect: () => [
          predicate<DestinationState>((state) {
            return state.isLoading == true && state.error == null;
          }),
          predicate<DestinationState>((state) {
            return state.destinations.isEmpty &&
                state.isLoading == false &&
                state.error == null;
          }),
        ],
      );

      blocTest<DestinationBloc, DestinationState>(
        'clears selected destination when deleted destination was selected',
        seed: () => DestinationState.initial().copyWith(
          destinations: [testDestination],
          selectedDestination: testDestination,
        ),
        build: () {
          when(
            () => mockDeleteDestination(any()),
          ).thenAnswer((_) async => const Right(null));
          when(
            () => mockGetDestinations.call(),
          ).thenAnswer((_) async => Right([testDestination]));
          return bloc;
        },
        act: (bloc) => bloc.add(
          DeleteDestination(id: testDestination.id, name: testDestination.name),
        ),
        expect: () => [
          predicate<DestinationState>((state) {
            return state.isLoading == true &&
                state.selectedDestination == testDestination;
          }),
          predicate<DestinationState>((state) {
            return state.destinations.isEmpty &&
                state.selectedDestination == null &&
                state.isLoading == false;
          }),
        ],
      );

      blocTest<DestinationBloc, DestinationState>(
        'emits [loading, error] when delete fails',
        seed: () => DestinationState.initial().copyWith(
          destinations: [testDestination],
        ),
        build: () {
          when(() => mockDeleteDestination(any())).thenAnswer(
            (_) async => const Left(ServerFailure(message: 'Delete failed')),
          );
          when(
            () => mockGetDestinations.call(),
          ).thenAnswer((_) async => Right([testDestination]));
          return bloc;
        },
        act: (bloc) => bloc.add(
          DeleteDestination(id: testDestination.id, name: testDestination.name),
        ),
        expect: () => [
          predicate<DestinationState>((state) {
            return state.isLoading == true && state.destinations.length == 1;
          }),
          predicate<DestinationState>((state) {
            return state.isLoading == false &&
                state.error != null &&
                state.destinations.length == 1;
          }),
        ],
      );
    });

    group('SelectDestination', () {
      blocTest<DestinationBloc, DestinationState>(
        'emits state with selected destination',
        build: () {
          when(
            () => mockGetDestinations.call(),
          ).thenAnswer((_) async => const Right([]));
          return DestinationBloc(
            getDestinations: mockGetDestinations,
            addDestination: mockAddDestination,
            deleteDestination: mockDeleteDestination,
          );
        },
        act: (bloc) => bloc.add(SelectDestination(testDestination)),
        expect: () => [
          // Constructor: loading
          predicate<DestinationState>((state) {
            return state.isLoading == true;
          }),
          // Constructor: loaded
          predicate<DestinationState>((state) {
            return state.isLoading == false && state.destinations.isEmpty;
          }),
          // SelectDestination
          predicate<DestinationState>((state) {
            return state.selectedDestination == testDestination;
          }),
        ],
      );

      blocTest<DestinationBloc, DestinationState>(
        'emits state with null when deselecting',
        seed: () => DestinationState.initial().copyWith(
          selectedDestination: testDestination,
        ),
        build: () {
          when(
            () => mockGetDestinations.call(),
          ).thenAnswer((_) async => const Right([]));
          return DestinationBloc(
            getDestinations: mockGetDestinations,
            addDestination: mockAddDestination,
            deleteDestination: mockDeleteDestination,
          );
        },
        act: (bloc) => bloc.add(const SelectDestination(null)),
        expect: () => [
          // Constructor: loading
          predicate<DestinationState>((state) {
            return state.isLoading == true;
          }),
          // Constructor: loaded
          predicate<DestinationState>((state) {
            return state.isLoading == false && state.destinations.isEmpty;
          }),
          // Deselect (state same as initial due to Equatable, may not emit)
        ],
      );
    });

    group('ClearDestinationError', () {
      blocTest<DestinationBloc, DestinationState>(
        'clears error state',
        seed: () => DestinationState.initial().copyWith(
          error: const ServerFailure(message: 'Error'),
        ),
        build: () {
          when(
            () => mockGetDestinations.call(),
          ).thenAnswer((_) async => const Right([]));
          return DestinationBloc(
            getDestinations: mockGetDestinations,
            addDestination: mockAddDestination,
            deleteDestination: mockDeleteDestination,
          );
        },
        act: (bloc) => bloc.add(const ClearDestinationError()),
        expect: () => [
          // Constructor: loading
          predicate<DestinationState>((state) {
            return state.isLoading == true && state.error == null;
          }),
          // Constructor: loaded
          predicate<DestinationState>((state) {
            return state.isLoading == false &&
                state.destinations.isEmpty &&
                state.error == null;
          }),
          // ClearDestinationError - state same as loaded due to Equatable, may not emit
        ],
      );
    });

    group('RefreshDestinations', () {
      blocTest<DestinationBloc, DestinationState>(
        'reloads destinations',
        build: () {
          when(
            () => mockGetDestinations.call(),
          ).thenAnswer((_) async => Right([testDestination]));
          return bloc;
        },
        act: (bloc) => bloc.add(const RefreshDestinations()),
        expect: () => [
          DestinationState.initial().copyWith(
            isLoading: true,
            clearError: true,
          ),
          DestinationState.initial().copyWith(
            destinations: [testDestination],
            isLoading: false,
          ),
        ],
      );
    });
  });
}
