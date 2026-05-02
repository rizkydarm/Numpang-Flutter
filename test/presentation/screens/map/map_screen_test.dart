import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:numpang_app/data/repositories/location_repository_impl.dart';
import 'package:numpang_app/presentation/bloc/map_bloc.dart';
import 'package:numpang_app/presentation/bloc/map_state.dart';
import 'package:numpang_app/presentation/screens/map/map_screen.dart';

void main() {
  group('MapScreen', () {
    late MapBloc mockMapBloc;
    const testLocation = LatLng(37.7749, -122.4194); // San Francisco

    setUp(() {
      mockMapBloc = MapBloc(locationService: LocationService());
      // Set initial state with test location
      mockMapBloc.emit(
        const MapState(
          center: testLocation,
          zoom: 13,
          isFollowingUser: true,
        ),
      );
    });

    testWidgets('renders map screen with core components', (tester) async {
      await tester.pumpWidget(
        BlocProvider.value(
          value: mockMapBloc,
          child: const MaterialApp(
            home: MapScreen(),
          ),
        ),
      );

      expect(find.byType(MapScreen), findsOneWidget);
      expect(find.byType(FlutterMap), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('taps recenter FAB and toggles follow mode', (tester) async {
      await tester.pumpWidget(
        BlocProvider.value(
          value: mockMapBloc,
          child: const MaterialApp(
            home: MapScreen(),
          ),
        ),
      );

      // Verify initial follow mode is true
      expect(mockMapBloc.state.isFollowingUser, true);

      // Tap recenter FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      // Verify follow mode was toggled
      expect(mockMapBloc.state.isFollowingUser, false);
    });
  });
}