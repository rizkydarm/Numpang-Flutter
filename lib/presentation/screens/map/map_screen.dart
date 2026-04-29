import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:numpang_app/core/theme/app_theme.dart';
import 'package:numpang_app/presentation/widgets/map/user_location_marker.dart';
import 'package:numpang_app/presentation/bloc/map_bloc.dart';
import 'package:numpang_app/presentation/bloc/map_event.dart';
import 'package:numpang_app/presentation/bloc/map_state.dart';
import 'package:numpang_app/domain/entities/destination.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return BlocBuilder<MapBloc, MapState>(
      builder: (context, state) {
        return Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: state.center,
                initialZoom: state.zoom,
                onTap: (tapPosition, point) {
                  // Handle map tap to add destination
                  context.read<MapBloc>().add(TapOnMap(point, address: null));
                },
                onPositionChanged: (position, hasGesture) {
                  if (hasGesture) {
                    context.read<MapBloc>().add(
                       MapMoved(position.center, position.zoom),
                    );
                  }
                },
                // Disable interaction when following user
                interactionOptions: InteractionOptions(
                  flags: !state.isFollowingUser
                      ? InteractiveFlag.all
                      : InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'dev.fleaflet.flutter_map',
                ),
                // Destination markers
                MarkerLayer(
                  markers: _buildDestinationMarkers(context, state.destinations),
                ),
                // User location marker
                if (state.isFollowingUser)
                  MarkerLayer(
                    markers: [
                      UserLocationMarker(point: state.center),
                    ],
                  ),
              ],
            ),
            // Crosshair FAB for recenter
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                mini: true,
                child: const Icon(Icons.center_focus_strong),
                onPressed: () {
                  // Recenter on user location
                  context.read<MapBloc>().add(
                    const ToggleFollowMode(),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  List<Marker> _buildDestinationMarkers(
      BuildContext context, List<Destination> destinations) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return destinations.map((destination) {
      return Marker(
        point: LatLng(destination.latitude, destination.longitude),
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () {
            // Show add destination dialog
            _showAddDestinationDialog(context, destination);
          },
          child: Icon(
            Icons.location_pin,
            color: theme.colorScheme.primary,
            size: 40,
          ),
        ),
      );
    }).toList();
  }

  void _showAddDestinationDialog(
      BuildContext context, Destination destination) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark 
            ? theme.colorScheme.surface 
            : theme.colorScheme.surface,
        title: Text(
          'Add Destination',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              destination.name,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              destination.address,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            onPressed: () {
              // Add destination to the list
              context
                  .read<MapBloc>()
                  .add(AddMarker(destination));
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}