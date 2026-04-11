import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../models/user_destination.dart';
import '../providers/profile_provider.dart';
import 'add_destination_sheet.dart';

class TravelMapWidget extends StatefulWidget {
  const TravelMapWidget({super.key});

  @override
  State<TravelMapWidget> createState() => _TravelMapWidgetState();
}

class _TravelMapWidgetState extends State<TravelMapWidget> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  static const String _mapStyle = '''[
    {"featureType":"water","elementType":"geometry","stylers":[{"color":"#C8DFF0"}]},
    {"featureType":"landscape","elementType":"geometry","stylers":[{"color":"#B8D4A0"}]},
    {"featureType":"road","stylers":[{"visibility":"off"}]},
    {"featureType":"poi","stylers":[{"visibility":"off"}]},
    {"featureType":"transit","stylers":[{"visibility":"off"}]},
    {"featureType":"administrative","elementType":"labels","stylers":[{"visibility":"simplified"}]},
    {"featureType":"administrative.country","elementType":"geometry.stroke","stylers":[{"color":"#ffffff"},{"weight":1}]}
  ]''';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _buildMarkers();
  }

  Future<void> _buildMarkers() async {
    final provider = context.read<ProfileProvider>();
    final Set<Marker> markers = {};

    for (final dest in provider.destinations) {
      final icon = await _createPinIcon(dest.status);
      markers.add(
        Marker(
          markerId: MarkerId(dest.id),
          position: dest.coordinates,
          icon: icon,
          infoWindow: InfoWindow(
            title: dest.name,
            snippet: dest.country,
          ),
          onTap: () => _showDestinationOptions(dest),
        ),
      );
    }

    if (mounted) setState(() => _markers = markers);
  }

  Future<BitmapDescriptor> _createPinIcon(DestinationStatus status) async {
    final color = status == DestinationStatus.visited
        ? AppColors.primary
        : AppColors.wishlist;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = 28.0;

    canvas.drawCircle(
      const Offset(size / 2, size / 2),
      size / 2,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      const Offset(size / 2, size / 2),
      size / 2 - 3,
      Paint()..color = color,
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  void _showDestinationOptions(UserDestination dest) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _DestinationOptionsSheet(destination: dest),
    );
  }

  void _onMapTap(LatLng coords) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddDestinationSheet(
        coordinates: coords,
        onConfirm: (name, country, status) {
          context.read<ProfileProvider>().addDestination(
                coords,
                name,
                country,
                status,
              );
          _buildMarkers();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, _) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    const Text(
                      'Seyahat haritam',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                                'Haritaya dokunarak destinasyon ekleyebilirsin'),
                            backgroundColor: AppColors.primary,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primary),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '+ Ekle',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Harita
              ClipRRect(
                borderRadius: BorderRadius.zero,
                child: SizedBox(
                  height: 200,
                  child: GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(20, 20),
                      zoom: 1.5,
                    ),
                    markers: _markers,
                    onMapCreated: (controller) {
                      _mapController = controller;
                      controller.setMapStyle(_mapStyle);
                    },
                    onTap: _onMapTap,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    compassEnabled: false,
                    rotateGesturesEnabled: false,
                    tiltGesturesEnabled: false,
                  ),
                ),
              ),

              // Lejant
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Row(
                  children: [
                    _LegendDot(color: AppColors.primary, label: 'Gittim'),
                    const SizedBox(width: 14),
                    _LegendDot(
                        color: AppColors.wishlist, label: 'Gitmek istiyorum'),
                    const Spacer(),
                    Text(
                      '${provider.visitedCount} gidilen · '
                      '${provider.wishlistCount} bucket list',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style:
                const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _DestinationOptionsSheet extends StatelessWidget {
  final UserDestination destination;

  const _DestinationOptionsSheet({required this.destination});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${destination.name}, ${destination.country}',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.swap_horiz_rounded,
                  color: AppColors.primary, size: 20),
            ),
            title: Text(
              destination.status == DestinationStatus.visited
                  ? 'Bucket list\'e taşı'
                  : 'Gidildi olarak işaretle',
              style: const TextStyle(fontSize: 14),
            ),
            onTap: () {
              context
                  .read<ProfileProvider>()
                  .toggleDestinationStatus(destination.id);
              Navigator.pop(context);
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFFCEBEB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.delete_outline_rounded,
                  color: Color(0xFFA32D2D), size: 20),
            ),
            title: const Text('Kaldır', style: TextStyle(fontSize: 14)),
            onTap: () {
              context.read<ProfileProvider>().removeDestination(destination.id);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
