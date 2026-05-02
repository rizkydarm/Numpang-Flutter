import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:numpang_app/data/models/destination_model.dart';

abstract class DestinationLocalDataSource {
  Future<List<DestinationModel>> getDestinations();
  Future<DestinationModel> addDestination(DestinationModel destination);
  Future<void> deleteDestination(String id);
  Future<void> clearAll();
}

class DestinationLocalDataSourceImpl implements DestinationLocalDataSource {
  static const String _boxName = 'destinations';
  static const String _key = 'destination_list';

  Box<String>? _box;

  Future<Box<String>> _getBox() async {
    _box ??= await Hive.openBox<String>(_boxName);
    return _box!;
  }

  @override
  Future<List<DestinationModel>> getDestinations() async {
    final box = await _getBox();
    final jsonString = box.get(_key);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => DestinationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<DestinationModel> addDestination(DestinationModel destination) async {
    final destinations = await getDestinations();
    destinations.add(destination);
    await _saveDestinations(destinations);
    return destination;
  }

  @override
  Future<void> deleteDestination(String id) async {
    final destinations = await getDestinations();
    destinations.removeWhere((d) => d.id == id);
    await _saveDestinations(destinations);
  }

  @override
  Future<void> clearAll() async {
    final box = await _getBox();
    await box.delete(_key);
  }

  Future<void> _saveDestinations(List<DestinationModel> destinations) async {
    final box = await _getBox();
    final jsonList = destinations.map((d) => d.toJson()).toList();
    await box.put(_key, jsonEncode(jsonList));
  }
}

class InMemoryDestinationDataSource implements DestinationLocalDataSource {
  final List<DestinationModel> _destinations = [];

  @override
  Future<List<DestinationModel>> getDestinations() async {
    return List.unmodifiable(_destinations);
  }

  @override
  Future<DestinationModel> addDestination(DestinationModel destination) async {
    _destinations.add(destination);
    return destination;
  }

  @override
  Future<void> deleteDestination(String id) async {
    _destinations.removeWhere((d) => d.id == id);
  }

  @override
  Future<void> clearAll() async {
    _destinations.clear();
  }
}
