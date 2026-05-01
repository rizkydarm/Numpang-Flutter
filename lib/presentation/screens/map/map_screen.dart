import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:numpang_app/core/theme/app_theme.dart';
import 'package:numpang_app/core/services/map_service.dart';
import 'package:numpang_app/presentation/widgets/map/user_location_marker.dart';
import 'package:numpang_app/presentation/widgets/destination/destination_widgets.dart';
import 'package:numpang_app/presentation/bloc/destination/destination_bloc.dart';
import 'package:numpang_app/presentation/bloc/destination/destination_event.dart';
import 'package:numpang_app/presentation/bloc/destination/destination_state.dart';
import 'package:numpang_app/presentation/bloc/map_bloc.dart';
import 'package:numpang_app/presentation/bloc/map_event.dart';
import 'package:numpang_app/presentation/bloc/map_state.dart';
import 'package:numpang_app/domain/entities/destination.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    // Initialize MapService with controller after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapBloc>().mapService.initialize(_mapController);
      context.read<MapBloc>().add(const InitializeMap());
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocListener<MapBloc, MapState>(
      listenWhen: (previous, current) => previous.error != current.error,
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error!.message)));
        }
      },
      child: BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: state.center,
                  initialZoom: state.zoom,
                  onTap: (tapPosition, point) async {
                    // Show dialog to name destination
                    final name = await AddDestinationDialog.show(
                      context,
                      address:
                          '${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}',
                    );
                    if (name != null && context.mounted) {
                      context.read<DestinationBloc>().add(
                        AddDestination(
                          name: name,
                          address:
                              '${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}',
                          position: point,
                        ),
                      );
                      // Also add to MapBloc for markers
                      context.read<MapBloc>().add(
                        TapOnMap(point, address: name),
                      );
                    }
                  },
                  onPositionChanged: (position, hasGesture) {
                    // if (hasGesture) {
                    //   context.read<MapBloc>().add(
                    //     MapMoved(position.center, position.zoom),
                    //   );
                    // }
                  },
                  // Disable interaction when following user
                  // interactionOptions: InteractionOptions(
                  //   flags: !state.isFollowingUser
                  //       ? InteractiveFlag.all
                  //       : InteractiveFlag.none,
                  // ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.rizkyeky.numpang',
                    maxZoom: 19,
                    minZoom: 0,
                    tileDisplay: const TileDisplay.fadeIn(),
                    errorTileCallback: (tile, error, stackTrace) {
                      debugPrint('Tile error at ${tile.coordinates}: $error');
                    },
                  ),
                  // Destination markers
                  MarkerLayer(
                    markers: _buildDestinationMarkers(
                      context,
                      state.destinations,
                    ),
                  ),
                  // User location marker
                  if (state.isFollowingUser)
                    MarkerLayer(
                      markers: [UserLocationMarker(point: state.center)],
                    ),
                  RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution(
                        'OpenStreetMap contributors',
                        onTap: () => launchUrl(
                          Uri.parse('https://www.openstreetmap.org/copyright'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // My Location FAB
              Positioned(
                bottom: 100,
                right: 20,
                child: FloatingActionButton(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  mini: true,
                  child: const Icon(Icons.my_location),
                  onPressed: () {
                    // Center on my location
                    context.read<MapBloc>().add(const RequestMyLocation());
                  },
                ),
              ),

              // Destination Bottom Sheet
              const Positioned.fill(child: DestinationBottomSheet()),
            ],
          );
        },
      ),
    );
  }

  List<Marker> _buildDestinationMarkers(
    BuildContext context,
    List<Destination> destinations,
  ) {
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
            // _showAddDestinationDialog(context, destination);
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
    BuildContext context,
    Destination destination,
  ) {
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
              context.read<MapBloc>().add(AddMarker(destination));
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
