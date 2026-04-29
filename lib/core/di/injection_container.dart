import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numpang_app/flavors.dart';
import 'package:provider/provider.dart';
import '../../presentation/bloc/map_bloc.dart';
import '../../presentation/bloc/search_bloc.dart';
import '../services/location_service.dart';

class InjectionContainer extends StatelessWidget {
  final Widget child;

  const InjectionContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final locationService = LocationService();

    return MultiProvider(
      providers: [
        Provider<Flavor>.value(value: F.appFlavor),
        Provider<LocationService>.value(value: locationService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => MapBloc(locationService: locationService),
          ),
          BlocProvider(
            create: (context) =>
                SearchBloc(geocodingRepository: context.read()),
          ),
        ],
        child: child,
      ),
    );
  }
}
