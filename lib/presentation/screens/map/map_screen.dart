import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:numpang_app/domain/entities/destination.dart';
import 'package:numpang_app/flavors.dart';
import 'package:numpang_app/presentation/bloc/destination/destination_bloc.dart';
import 'package:numpang_app/presentation/bloc/destination/destination_event.dart';
import 'package:numpang_app/presentation/bloc/destination/destination_state.dart';
import 'package:numpang_app/presentation/bloc/map_bloc.dart';
import 'package:numpang_app/presentation/bloc/map_event.dart';
import 'package:numpang_app/presentation/bloc/map_state.dart';
import 'package:numpang_app/presentation/bloc/search_bloc.dart';
import 'package:numpang_app/presentation/bloc/search_event.dart';
import 'package:numpang_app/presentation/bloc/search_state.dart';
import 'package:numpang_app/presentation/responsive/breakpoints.dart';
import 'package:numpang_app/presentation/widgets/destination/destination_widgets.dart';
import 'package:numpang_app/presentation/widgets/map/user_location_marker.dart';
import 'package:numpang_app/presentation/widgets/search/floating_search_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(F.title),
        actions: [
          BlocBuilder<SearchBloc, SearchState>(
            buildWhen: (p, n) => p.selectedProvider != n.selectedProvider,
            builder: (context, state) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.settings),
                tooltip: 'Select Geocoding Provider',
                onSelected: (provider) {
                  context.read<SearchBloc>().add(
                    SetGeocodingProvider(provider),
                  );
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'mapbox',
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: state.selectedProvider == 'mapbox'
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Mapbox',
                          style: TextStyle(
                            fontWeight: state.selectedProvider == 'mapbox'
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'nominatim',
                    child: Row(
                      children: [
                        Icon(
                          Icons.map,
                          color: state.selectedProvider == 'nominatim'
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Nominatim',
                          style: TextStyle(
                            fontWeight: state.selectedProvider == 'nominatim'
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'geocodeXyz',
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_searching,
                          color: state.selectedProvider == 'geocodeXyz'
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Geocode.xyz',
                          style: TextStyle(
                            fontWeight: state.selectedProvider == 'geocodeXyz'
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
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
      context.read<MapBloc>().mapService.controller = _mapController;
      context.read<MapBloc>().add(const InitializeMap());
      context.read<MapBloc>().add(const RequestMyLocation());
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                prev.center != curr.center || prev.zoom != curr.zoom,
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
                BlocBuilder<DestinationBloc, DestinationState>(
                  buildWhen: (prev, curr) =>
                      prev.destinations != curr.destinations,
                  builder: (context, destState) => MarkerLayer(
                    markers: _buildDestinationMarkers(
                      context,
                      destState.destinations,
                    ),
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
          const FloatingSearchBar(),
          const _ResponsiveMyLocationFab(),
          const _ResponsiveBottomSheetWrapper(),
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

class _ResponsiveBottomSheetWrapper extends StatelessWidget {
  const _ResponsiveBottomSheetWrapper();

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenType) {
        final maxWidth = BottomSheetConstraints.maxWidth(screenType);
        final alignment = BottomSheetConstraints.alignment(screenType);
        final sideMargin = BottomSheetConstraints.bottomSheetSideMargin(
          screenType,
        );

        return Align(
          alignment: alignment,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: sideMargin),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: const DestinationBottomSheet(),
            ),
          ),
        );
      },
    );
  }
}

class _ResponsiveMyLocationFab extends StatelessWidget {
  const _ResponsiveMyLocationFab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned(
      bottom: 120,
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
