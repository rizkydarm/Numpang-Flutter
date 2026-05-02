import 'package:equatable/equatable.dart';

class PlaceSuggestion extends Equatable {

  const PlaceSuggestion({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  @override
  List<Object?> get props => [id, name, address, latitude, longitude];
}
