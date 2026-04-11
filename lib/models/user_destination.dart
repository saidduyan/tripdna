import 'package:google_maps_flutter/google_maps_flutter.dart';

enum DestinationStatus { visited, wishlist }

class UserDestination {
  final String id;
  final String name;
  final String country;
  final LatLng coordinates;
  final DestinationStatus status;

  const UserDestination({
    required this.id,
    required this.name,
    required this.country,
    required this.coordinates,
    required this.status,
  });

  UserDestination copyWith({DestinationStatus? status}) {
    return UserDestination(
      id: id,
      name: name,
      country: country,
      coordinates: coordinates,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'country': country,
        'lat': coordinates.latitude,
        'lng': coordinates.longitude,
        'status': status.name,
      };

  factory UserDestination.fromJson(Map<String, dynamic> json) =>
      UserDestination(
        id: json['id'],
        name: json['name'],
        country: json['country'],
        coordinates: LatLng(json['lat'], json['lng']),
        status: DestinationStatus.values.byName(json['status']),
      );
}
