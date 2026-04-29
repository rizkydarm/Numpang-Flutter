import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:numpang_app/core/services/location_service.dart';
import 'package:numpang_app/domain/entities/destination.dart';
import 'package:numpang_app/domain/entities/user_location.dart';
import 'package:numpang_app/presentation/bloc/map_bloc.dart';
import 'package:numpang_app/presentation/bloc/map_event.dart';
import 'package:numpang_app/presentation/bloc/map_state.dart';

import 'map_bloc_test.mocks.dart';

@GenerateMocks([LocationService])
void main() {
  late MockLocationService mockLocationService;
  late MapBloc mapBloc;

  final testLocation = UserLocation(
    latitude: 40.7128,
    longitude: -74.0060,
    accuracy: 10.0,
    timestamp: DateTime.now(),
  );

  final testDestination = Destination(
    id: '1',
    name: 'Test Destination',
    address: '123 Test St',
    latitude: 40.7128,
    longitude: -74.0060,
    createdAt: DateTime.now(),
  );

  setUp(() {
    mockLocationService = MockLocationService();
    mapBloc = MapBloc(locationService: mockLocationService);
  });

  tearDown(() {
    mapBloc.close();
  });

  group('InitializeMap', () {
    blocTest<MapBloc, MapState>(
      'emits MapState with user location when available',
      build: () {
        when(mockLocationService.getCurrentLocation())
            .thenAnswer((_) async => testLocation);
        return mapBloc;
      },
      act: (bloc) => bloc.add(const InitializeMap()),
      expect: () => [
        isA<MapState>().having((s) => s.isLoading, 'isLoading', true),
        isA<MapState>()
            .having((s) => s.center.latitude, 'lat', 40.7128)
            .having((s) => s.center.longitude, 'lng', -74.0060)
            .having((s) => s.isFollowingUser, 'isFollowingUser', true)
            .having((s) => s.isLoading, 'isLoading', false),
      ],
    );

    blocTest<MapBloc, MapState>(
      'emits MapState with default center when location unavailable',
      build: () {
        when(mockLocationService.getCurrentLocation())
            .thenAnswer((_) async => null);
        return mapBloc;
      },
      act: (bloc) => bloc.add(const InitializeMap(initialCenter: LatLng(51.5, -0.1))),
      expect: () => [
        isA<MapState>().having((s) => s.isLoading, 'isLoading', true),
        isA<MapState>()
            .having((s) => s.center.latitude, 'lat', 51.5)
            .having((s) => s.center.longitude, 'lng', -0.1)
            .having((s) => s.isFollowingUser, 'isFollowingUser', false),
      ],
    );
  });

  group('CenterOnLocation', () {
    blocTest<MapBloc, MapState>(
      'updates center position',
      build: () => mapBloc,
      seed: () => MapState.initial(),
      act: (bloc) => bloc.add(const CenterOnLocation(LatLng(51.5, -0.1))),
      expect: () => [
        isA<MapState>()
            .having((s) => s.center.latitude, 'lat', 51.5)
            .having((s) => s.center.longitude, 'lng', -0.1),
      ],
    );
  });

  group('AddMarker', () {
    blocTest<MapBloc, MapState>(
      'adds destination and marker to state',
      build: () => mapBloc,
      seed: () => MapState.initial(),
      act: (bloc) => bloc.add(AddMarker(testDestination)),
      expect: () => [
        isA<MapState>()
            .having((s) => s.destinations.length, 'destinations count', 1)
            .having((s) => s.markers.length, 'markers count', 1)
            .having((s) => s.destinations.first.id, 'destination id', '1'),
      ],
    );

    blocTest<MapBloc, MapState>(
      'centers map on new destination',
      build: () => mapBloc,
      seed: () => MapState.initial(),
      act: (bloc) => bloc.add(AddMarker(testDestination)),
      expect: () => [
        isA<MapState>()
            .having((s) => s.center.latitude, 'lat', testDestination.latitude)
            .having((s) => s.center.longitude, 'lng', testDestination.longitude),
      ],
    );
  });

  group('RemoveMarker', () {
    blocTest<MapBloc, MapState>(
      'removes destination and marker by id',
      build: () => mapBloc,
      seed: () => MapState.initial().copyWith(
        destinations: [testDestination],
        markers: [],
      ),
      act: (bloc) => bloc.add(const RemoveMarker('1')),
      expect: () => [
        isA<MapState>()
            .having((s) => s.destinations.length, 'destinations count', 0),
      ],
    );

    blocTest<MapBloc, MapState>(
      'does nothing if destination not found',
      build: () => mapBloc,
      seed: () => MapState.initial().copyWith(
        destinations: [testDestination],
        markers: [],
      ),
      act: (bloc) => bloc.add(const RemoveMarker('999')),
      expect: () => [],
    );
  });

  group('ToggleFollowMode', () {
    blocTest<MapBloc, MapState>(
      'toggles isFollowingUser from false to true',
      build: () => mapBloc,
      seed: () => MapState.initial().copyWith(isFollowingUser: false),
      act: (bloc) => bloc.add(const ToggleFollowMode()),
      expect: () => [
        isA<MapState>().having((s) => s.isFollowingUser, 'isFollowingUser', true),
      ],
    );

    blocTest<MapBloc, MapState>(
      'toggles isFollowingUser from true to false',
      build: () => mapBloc,
      seed: () => MapState.initial().copyWith(isFollowingUser: true),
      act: (bloc) => bloc.add(const ToggleFollowMode()),
      expect: () => [
        isA<MapState>().having((s) => s.isFollowingUser, 'isFollowingUser', false),
      ],
    );
  });

  group('UserLocationUpdated', () {
    blocTest<MapBloc, MapState>(
      'updates center when following user',
      build: () => mapBloc,
      seed: () => MapState.initial().copyWith(isFollowingUser: true),
      act: (bloc) => bloc.add(const UserLocationUpdated(LatLng(40.7, -74.0))),
      expect: () => [
        isA<MapState>()
            .having((s) => s.center.latitude, 'lat', 40.7)
            .having((s) => s.center.longitude, 'lng', -74.0),
      ],
    );

    blocTest<MapBloc, MapState>(
      'does not update center when not following user',
      build: () => mapBloc,
      seed: () => MapState.initial().copyWith(
        isFollowingUser: false,
        center: const LatLng(0, 0),
      ),
      act: (bloc) => bloc.add(const UserLocationUpdated(LatLng(40.7, -74.0))),
      expect: () => [],
    );
  });

  group('UpdateZoom', () {
    blocTest<MapBloc, MapState>(
      'updates zoom level',
      build: () => mapBloc,
      seed: () => MapState.initial(),
      act: (bloc) => bloc.add(const UpdateZoom(15.0)),
      expect: () => [
        isA<MapState>().having((s) => s.zoom, 'zoom', 15.0),
      ],
    );
  });

  group('MapMoved', () {
    blocTest<MapBloc, MapState>(
      'updates center and zoom',
      build: () => mapBloc,
      seed: () => MapState.initial(),
      act: (bloc) => bloc.add(const MapMoved(LatLng(51.5, -0.1), 12.0)),
      expect: () => [
        isA<MapState>()
            .having((s) => s.center.latitude, 'lat', 51.5)
            .having((s) => s.center.longitude, 'lng', -0.1)
            .having((s) => s.zoom, 'zoom', 12.0),
      ],
    );
  });
}
