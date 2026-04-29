import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:numpang_app/presentation/screens/map/map_screen.dart';
import 'package:numpang_app/presentation/bloc/map_bloc.dart';
import 'package:numpang_app/presentation/bloc/map_state.dart';
import 'package:numpang_app/data/repositories/location_repository_impl.dart';

void main() {
  group('MapScreen', () {
    late MapBloc mockMapBloc;
    final testLocation = const LatLng(37.7749, -122.4194); // San Francisco

    setUp(() {
      mockMapBloc = MapBloc(locationService: LocationService());
      // Set initial state with test location
      mockMapBloc.emit(
        MapState(
          center: testLocation,
          zoom: 13.0,
          destinations: [],
          isFollowingUser: true,
          isLoading: false,
        ),
      );
    });

    testWidgets('renders map screen with core components', (WidgetTester tester) async {
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

    testWidgets('taps recenter FAB and toggles follow mode', (WidgetTester tester) async {
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