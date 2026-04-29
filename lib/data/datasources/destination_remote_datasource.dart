import '../models/destination_model.dart';

abstract class DestinationRemoteDataSource {
  Future<List<DestinationModel>> getDestinations();
  Future<DestinationModel> addDestination(DestinationModel destination);
  Future<void> deleteDestination(String id);
}

class DestinationRemoteDataSourceImpl implements DestinationRemoteDataSource {
  @override
  Future<List<DestinationModel>> getDestinations() async {
    return [];
  }

  @override
  Future<DestinationModel> addDestination(DestinationModel destination) async {
    return destination;
  }

  @override
  Future<void> deleteDestination(String id) async {
    // No-op - cloud sync out of scope
  }
}
