import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum PlaceCategoryType {
  restaurant,
  cafe,
  gas,
  hotel,
  parking,
  hospital,
  pharmacy,
  atm,
  supermarket,
  shopping,
  tourist,
  entertainment,
}

class PlaceCategory extends Equatable {
  const PlaceCategory({
    required this.type,
    required this.name,
    required this.icon,
    required this.displayName,
    this.searchKeywords = const [],
  });

  final PlaceCategoryType type;
  final String name;
  final IconData icon;
  final String displayName;
  final List<String> searchKeywords;

  static const List<PlaceCategory> all = [
    PlaceCategory(
      type: PlaceCategoryType.restaurant,
      name: 'restaurant',
      icon: Icons.restaurant,
      displayName: 'Restaurant',
      searchKeywords: ['restaurant', 'food', 'dining', 'eat'],
    ),
    PlaceCategory(
      type: PlaceCategoryType.cafe,
      name: 'cafe',
      icon: Icons.local_cafe,
      displayName: 'Cafe',
      searchKeywords: ['cafe', 'coffee', 'bakery'],
    ),
    PlaceCategory(
      type: PlaceCategoryType.gas,
      name: 'gas',
      icon: Icons.local_gas_station,
      displayName: 'Gas Station',
      searchKeywords: ['gas', 'fuel', 'petrol', 'gas station'],
    ),
    PlaceCategory(
      type: PlaceCategoryType.hotel,
      name: 'hotel',
      icon: Icons.hotel,
      displayName: 'Hotel',
      searchKeywords: ['hotel', 'motel', 'inn', 'lodging'],
    ),
    PlaceCategory(
      type: PlaceCategoryType.parking,
      name: 'parking',
      icon: Icons.local_parking,
      displayName: 'Parking',
      searchKeywords: ['parking', 'car park', 'garage'],
    ),
    PlaceCategory(
      type: PlaceCategoryType.hospital,
      name: 'hospital',
      icon: Icons.local_hospital,
      displayName: 'Hospital',
      searchKeywords: ['hospital', 'clinic', 'medical center', 'emergency'],
    ),
    PlaceCategory(
      type: PlaceCategoryType.pharmacy,
      name: 'pharmacy',
      icon: Icons.local_pharmacy,
      displayName: 'Pharmacy',
      searchKeywords: ['pharmacy', 'drugstore', 'chemist'],
    ),
    PlaceCategory(
      type: PlaceCategoryType.atm,
      name: 'atm',
      icon: Icons.local_atm,
      displayName: 'ATM',
      searchKeywords: ['atm', 'cash machine', 'bank'],
    ),
    PlaceCategory(
      type: PlaceCategoryType.supermarket,
      name: 'supermarket',
      icon: Icons.local_grocery_store,
      displayName: 'Supermarket',
      searchKeywords: ['supermarket', 'grocery', 'market', 'store'],
    ),
    PlaceCategory(
      type: PlaceCategoryType.shopping,
      name: 'shopping',
      icon: Icons.shopping_bag,
      displayName: 'Shopping',
      searchKeywords: ['shopping', 'mall', 'retail', 'store'],
    ),
    PlaceCategory(
      type: PlaceCategoryType.tourist,
      name: 'tourist',
      icon: Icons.photo_camera,
      displayName: 'Tourist',
      searchKeywords: ['tourist', 'attraction', 'landmark', 'sightseeing'],
    ),
    PlaceCategory(
      type: PlaceCategoryType.entertainment,
      name: 'entertainment',
      icon: Icons.movie,
      displayName: 'Entertainment',
      searchKeywords: ['cinema', 'theater', 'entertainment', 'movie'],
    ),
  ];

  static PlaceCategory? fromType(PlaceCategoryType type) {
    try {
      return all.firstWhere((c) => c.type == type);
    } catch (_) {
      return null;
    }
  }

  static PlaceCategory? fromName(String name) {
    try {
      return all.firstWhere(
        (c) => c.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  List<Object?> get props => [type, name, icon, displayName, searchKeywords];
}
