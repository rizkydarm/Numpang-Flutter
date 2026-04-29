import '../../domain/entities/destination.dart';

class DestinationModel extends Destination {
  const DestinationModel({
    required super.id,
    required super.name,
    required super.address,
    required super.latitude,
    required super.longitude,
    required super.createdAt,
  });

  factory DestinationModel.fromJson(Map<String, dynamic> json) {
    return DestinationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory DestinationModel.fromEntity(Destination entity) {
    return DestinationModel(
      id: entity.id,
      name: entity.name,
      address: entity.address,
      latitude: entity.latitude,
      longitude: entity.longitude,
      createdAt: entity.createdAt,
    );
  }

  Destination toEntity() {
    return Destination(
      id: id,
      name: name,
      address: address,
      latitude: latitude,
      longitude: longitude,
      createdAt: createdAt,
    );
  }
}
