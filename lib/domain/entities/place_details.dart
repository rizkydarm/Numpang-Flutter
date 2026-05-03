import 'package:equatable/equatable.dart';

class PlaceDetails extends Equatable {
  const PlaceDetails({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.phone,
    this.website,
    this.openingHours,
    this.categories = const [],
    this.rating,
    this.photoUrls = const [],
  });

  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String? phone;
  final String? website;
  final List<String>? openingHours;
  final List<String> categories;
  final double? rating;
  final List<String> photoUrls;

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        latitude,
        longitude,
        phone,
        website,
        openingHours,
        categories,
        rating,
        photoUrls,
      ];
}
