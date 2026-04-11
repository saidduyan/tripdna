import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/user_destination.dart';
import '../models/travel_dna_tag.dart';

class ProfileProvider extends ChangeNotifier {
  // ── Kullanıcı bilgisi ──────────────────────────────────────
  String userName = 'ali riza';

  // ── Destinasyonlar ─────────────────────────────────────────
  final List<UserDestination> _destinations = [
    UserDestination(
      id: '1',
      name: 'İstanbul',
      country: 'Türkiye',
      coordinates: const LatLng(41.0082, 28.9784),
      status: DestinationStatus.visited,
    ),
    UserDestination(
      id: '2',
      name: 'Amsterdam',
      country: 'Hollanda',
      coordinates: const LatLng(52.3676, 4.9041),
      status: DestinationStatus.visited,
    ),
    UserDestination(
      id: '3',
      name: 'Roma',
      country: 'İtalya',
      coordinates: const LatLng(41.9028, 12.4964),
      status: DestinationStatus.visited,
    ),
    UserDestination(
      id: '4',
      name: 'Dubai',
      country: 'BAE',
      coordinates: const LatLng(25.2048, 55.2708),
      status: DestinationStatus.visited,
    ),
    UserDestination(
      id: '5',
      name: 'New York',
      country: 'ABD',
      coordinates: const LatLng(40.7128, -74.0060),
      status: DestinationStatus.visited,
    ),
    UserDestination(
      id: '6',
      name: 'Bali',
      country: 'Endonezya',
      coordinates: const LatLng(-8.3405, 115.0920),
      status: DestinationStatus.wishlist,
    ),
    UserDestination(
      id: '7',
      name: 'Tokyo',
      country: 'Japonya',
      coordinates: const LatLng(35.6762, 139.6503),
      status: DestinationStatus.wishlist,
    ),
    UserDestination(
      id: '8',
      name: 'Sydney',
      country: 'Avustralya',
      coordinates: const LatLng(-33.8688, 151.2093),
      status: DestinationStatus.wishlist,
    ),
  ];

  List<UserDestination> get destinations => List.unmodifiable(_destinations);

  List<UserDestination> get visited => _destinations
      .where((d) => d.status == DestinationStatus.visited)
      .toList();

  List<UserDestination> get wishlist => _destinations
      .where((d) => d.status == DestinationStatus.wishlist)
      .toList();

  int get visitedCount => visited.length;
  int get wishlistCount => wishlist.length;

  // ── DNA Tagları ────────────────────────────────────────────
  final List<TravelDnaTag> _selectedTags = [
    allDnaTags[0], // Doğa
    allDnaTags[1], // Şehir kaçamağı
    allDnaTags[2], // Kültür
    allDnaTags[3], // Yemek turu
    allDnaTags[4], // Sahil
  ];

  List<TravelDnaTag> get selectedTags => List.unmodifiable(_selectedTags);

  // ── Aksiyonlar ─────────────────────────────────────────────

  void addDestination(
      LatLng coords, String name, String country, DestinationStatus status) {
    final destination = UserDestination(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      country: country,
      coordinates: coords,
      status: status,
    );
    _destinations.add(destination);
    notifyListeners();
  }

  void removeDestination(String id) {
    _destinations.removeWhere((d) => d.id == id);
    notifyListeners();
  }

  void toggleDestinationStatus(String id) {
    final index = _destinations.indexWhere((d) => d.id == id);
    if (index == -1) return;
    final current = _destinations[index];
    final newStatus = current.status == DestinationStatus.visited
        ? DestinationStatus.wishlist
        : DestinationStatus.visited;
    _destinations[index] = current.copyWith(status: newStatus);
    notifyListeners();
  }

  void toggleDnaTag(TravelDnaTag tag) {
    if (_selectedTags.contains(tag)) {
      _selectedTags.remove(tag);
    } else {
      _selectedTags.add(tag);
    }
    notifyListeners();
  }

  bool isDnaTagSelected(TravelDnaTag tag) => _selectedTags.contains(tag);
}
