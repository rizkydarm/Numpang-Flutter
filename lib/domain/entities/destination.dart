import 'package:equatable/equatable.dart';

class Destination extends Equatable {

  const Destination({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
  });
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, name, address, latitude, longitude, createdAt];
}
