import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numpang_app/flavors.dart';
import 'package:provider/provider.dart';
import '../../presentation/bloc/destination/destination_bloc.dart';
import '../../presentation/bloc/map_bloc.dart';
import '../../presentation/bloc/search_bloc.dart';
import '../../data/repositories/location_repository_impl.dart';
import '../../data/datasources/destination_local_datasource.dart';
import '../../data/datasources/destination_remote_datasource.dart';
import '../../data/datasources/geocoding_cache.dart';
import '../../data/repositories/destination_repository_impl.dart';
import '../../data/repositories/geocoding_repository_impl.dart';
import '../../domain/repositories/destination_repository.dart';
import '../../domain/repositories/geocoding_repository.dart';
import '../../domain/usecases/add_destination_usecase.dart';
import '../../domain/usecases/delete_destination_usecase.dart';
import '../../domain/usecases/get_destinations_usecase.dart';
import '../utils/dio_client.dart';

class InjectionContainer extends StatelessWidget {
  final Widget child;

  const InjectionContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final dio = DioClient.create();
    final geocodingCache = GeocodingCache();

    final geocodingRepository = GeocodingRepositoryImpl(
      dio: dio,
      cache: geocodingCache,
    );

    final destinationLocalDataSource = InMemoryDestinationDataSource();
    final destinationRemoteDataSource = DestinationRemoteDataSourceImpl();

    final destinationRepository = DestinationRepositoryImpl(
      localDataSource: destinationLocalDataSource,
      remoteDataSource: destinationRemoteDataSource,
    );

    final getDestinationsUseCase = GetDestinationsUseCase(
      destinationRepository,
    );
    final addDestinationUseCase = AddDestinationUseCase(destinationRepository);
    final deleteDestinationUseCase = DeleteDestinationUseCase(
      destinationRepository,
    );

    final locationService = LocationService();

    return MultiProvider(
      providers: [
        Provider<Flavor>.value(value: F.appFlavor),
        Provider<Dio>.value(value: dio),
        Provider<GeocodingRepository>.value(value: geocodingRepository),
        Provider<DestinationRepository>.value(value: destinationRepository),
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
          BlocProvider(
            create: (context) => DestinationBloc(
              getDestinations: getDestinationsUseCase,
              addDestination: addDestinationUseCase,
              deleteDestination: deleteDestinationUseCase,
            ),
          ),
        ],
        child: child,
      ),
    );
  }
}
