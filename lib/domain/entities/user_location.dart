import 'package:equatable/equatable.dart';

class UserLocation extends Equatable {

  const UserLocation({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
  });
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime timestamp;

  @override
  List<Object?> get props => [latitude, longitude, accuracy, timestamp];
}
