import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:numpang_app/domain/entities/destination.dart';
import 'package:numpang_app/flavors.dart';
import 'package:numpang_app/presentation/bloc/destination/destination_bloc.dart';
import 'package:numpang_app/presentation/bloc/destination/destination_event.dart';
import 'package:numpang_app/presentation/bloc/map_bloc.dart';
import 'package:numpang_app/presentation/bloc/map_event.dart';
import 'package:numpang_app/presentation/bloc/map_state.dart';
import 'package:numpang_app/presentation/widgets/destination/destination_widgets.dart';
import 'package:numpang_app/presentation/widgets/map/user_location_marker.dart';
import 'package:url_launcher/url_launcher.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(F.title)),
      body: const MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

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

    return BlocListener<MapBloc, MapState>(
      listenWhen: (previous, current) => previous.error != current.error,
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!.message)),
          );
        }
      },
      child: Stack(
        children: [
          BlocBuilder<MapBloc, MapState>(
            buildWhen: (prev, curr) =>
                prev.center != curr.center ||
                prev.zoom != curr.zoom ||
                prev.destinations != curr.destinations,
            builder: (context, state) => FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: state.center,
                initialZoom: state.zoom,
                onTap: (tapPosition, point) async {
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
                    context.read<MapBloc>().add(TapOnMap(point, address: name));
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.rizkyeky.numpang',
                  maxZoom: 19,
                ),
                MarkerLayer(
                  markers: _buildDestinationMarkers(
                    context,
                    state.destinations,
                  ),
                ),
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
          ),
          _MyLocationFab(theme: theme),
          const Positioned.fill(child: DestinationBottomSheet()),
        ],
      ),
    );
  }

  List<Marker> _buildDestinationMarkers(
    BuildContext context,
    List<Destination> destinations,
  ) {
    final theme = Theme.of(context);

    return destinations.map((destination) {
      return Marker(
        point: LatLng(destination.latitude, destination.longitude),
        width: 40,
        height: 40,
        child: Icon(
          Icons.location_pin,
          color: theme.colorScheme.primary,
          size: 40,
        ),
      );
    }).toList();
  }
}

class _MyLocationFab extends StatelessWidget {
  final ThemeData theme;

  const _MyLocationFab({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 100,
      right: 20,
      child: FloatingActionButton(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        mini: true,
        child: const Icon(Icons.my_location),
        onPressed: () {
          context.read<MapBloc>().add(const RequestMyLocation());
        },
      ),
    );
  }
}
