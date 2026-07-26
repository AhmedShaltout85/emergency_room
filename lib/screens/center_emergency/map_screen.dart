import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  final String latitude;
  final String longitude;

  const MapScreen({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;

  static const LatLng _alexandriaCoordinates = LatLng(31.205753, 29.924526);
 

  final Map<MarkerId, Marker> _markers = {};
  final Map<PolylineId, Polyline> _polylines = {};

  /// AWCO's 9 official water treatment stations (per Wikipedia + AWCO
  /// sources). Coordinates below are geocoded from public map listings;
  /// 2 stations (مريوط 2 / الكيلو 40, and فرن الجراية) could not be
  /// confidently located and are left commented out rather than guessed.
  final Map<String, LatLng> awcoStationsLocations = {
    'محطة السيوف': const LatLng(31.222324, 29.988280), // 840,000 m³/day
    'محطة مريوط 1': const LatLng(30.911413, 29.974326), // 510,000 m³/day
    'محطة شرقي': const LatLng(31.200825, 29.919157), // 510,000 m³/day
    'محطة المنشية 1': const LatLng(31.185514, 29.934137), // 380,000 m³/day
    'محطة المنشية 2': const LatLng(31.175664, 29.986611), // 240,000 m³/day
    'محطة المعمورة': const LatLng(31.290460, 30.050855), // 240,000 m³/day
    'محطة النزهة': const LatLng(31.198524, 29.952943), // 200,000 m³/day
    // 'محطة مريوط 2 (الكيلو 40)': not confidently located yet — 636,000 m³/day
    // 'محطة فرن الجراية': not confidently located yet — 50,000 m³/day
  };

  bool _mapReady = false;
  final BitmapDescriptor _stationIcon =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);

  // Currently selected station, shown in the info card on the left.
  // Defaults to the first station so the card has content on first
  // launch; becomes whichever marker the user last tapped.
  String? _selectedStationName;
  LatLng? _selectedStationPosition;

  @override
  void initState() {
    super.initState();
    _addStationMarkers();
    if (awcoStationsLocations.isNotEmpty) {
      final firstEntry = awcoStationsLocations.entries.first;
      _selectedStationName = firstEntry.key;
      _selectedStationPosition = firstEntry.value;
    }
  }

  @override
  void dispose() {
    try {
      if (_mapController != null) {
        if (!kIsWeb) {
          _mapController!.dispose();
        }
        _mapController = null;
      }
    } catch (error) {
      debugPrint('⚠️ Error during map controller cleanup: $error');
    }
    super.dispose();
  }

  /// Populate _markers with all AWCO station locations using the default
  /// Google Maps pin in purple (BitmapDescriptor.hueViolet). Tapping a
  /// marker selects it, which updates the info card.
  void _addStationMarkers() {
    for (final entry in awcoStationsLocations.entries) {
      final markerId = MarkerId(entry.key);
      _markers[markerId] = Marker(
        markerId: markerId,
        position: entry.value,
        infoWindow: InfoWindow(
          title: entry.key,
          snippet:
              '${entry.value.latitude.toStringAsFixed(6)}, ${entry.value.longitude.toStringAsFixed(6)}',
        ),
        icon: _stationIcon,
        onTap: () => _selectStation(entry.key, entry.value),
      );
    }
  }

  /// Selects a station, updating the info card and centering the camera
  /// on it.
  void _selectStation(String name, LatLng position) {
    setState(() {
      _selectedStationName = name;
      _selectedStationPosition = position;
    });

    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(position, 15),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    setState(() => _mapReady = true);
    debugPrint('✅ الخريطة جاهزة');

    if (awcoStationsLocations.isNotEmpty) {
      // Small delay ensures the map has finished laying out before we
      // animate the camera to fit bounds.
      Future.delayed(const Duration(milliseconds: 300), _fitBoundsToStations);
    }
  }

  /// Animate the camera to fit all AWCO station markers on screen.
  void _fitBoundsToStations() {
    if (_mapController == null || !_mapReady || awcoStationsLocations.isEmpty) {
      return;
    }

    final positions = awcoStationsLocations.values.toList();

    // Single location: just center on it, bounds don't make sense.
    if (positions.length == 1) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(positions.first, 14),
      );
      return;
    }

    double minLat = positions.first.latitude;
    double maxLat = positions.first.latitude;
    double minLng = positions.first.longitude;
    double maxLng = positions.first.longitude;

    for (final p in positions) {
      minLat = min(minLat, p.latitude);
      maxLat = max(maxLat, p.latitude);
      minLng = min(minLng, p.longitude);
      maxLng = max(maxLng, p.longitude);
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    try {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 60),
      );
      debugPrint('📷 تم ضبط الكاميرا لعرض جميع المحطات');
    } catch (error) {
      debugPrint('⚠️ Error fitting bounds to stations: $error');
      // Fallback: center on the first station.
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(positions.first, 12),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: const CameraPosition(
            target: _alexandriaCoordinates,
            zoom: 13,
            tilt: 0,
            bearing: 0,
          ),
          markers: Set.of(_markers.values),
          polylines: Set.of(_polylines.values),
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
          myLocationEnabled: false,
          tiltGesturesEnabled: true,
          buildingsEnabled: true,
          indoorViewEnabled: false,
          trafficEnabled: true,
          mapToolbarEnabled: false,
          rotateGesturesEnabled: true,
          scrollGesturesEnabled: true,
          zoomGesturesEnabled: true,
          compassEnabled: true,
          mapType: MapType.normal,
        ),

        // Station info card, pinned to the left side of the map.
        if (_selectedStationName != null && _selectedStationPosition != null)
          Positioned(
            left: 16,
            top: 16,
            bottom: 16,
            child: _buildStationInfoCard(
              _selectedStationName!,
              _selectedStationPosition!,
            ),
          ),
      ],
    );
  }

  /// Card shown on the left edge of the map with details for the
  /// currently selected AWCO station.
  Widget _buildStationInfoCard(String name, LatLng position) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.water_drop,
                    color: Colors.deepPurple,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _infoRow(
              Icons.my_location,
              'خط العرض',
              position.latitude.toStringAsFixed(6),
            ),
            const SizedBox(height: 8),
            _infoRow(
              Icons.explore,
              'خط الطول',
              position.longitude.toStringAsFixed(6),
            ),
            const SizedBox(height: 14),
            Divider(color: Colors.grey.shade200, height: 1),
            const SizedBox(height: 10),
            Text(
              'إجمالي المحطات: ${awcoStationsLocations.length}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// One labeled row of station detail inside the info card.
  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: Colors.grey.shade500),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// import 'dart:math';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class MapScreen extends StatefulWidget {
//   final String latitude;
//   final String longitude;

//   const MapScreen({
//     super.key,
//     required this.latitude,
//     required this.longitude,
//   });

//   @override
//   State<MapScreen> createState() => _MapScreenState();
// }

// class _MapScreenState extends State<MapScreen> {
//   GoogleMapController? _mapController;

//   static const LatLng _alexandriaCoordinates = LatLng(31.205753, 29.924526);
//   final double _currentLatitude = 0.0;
//   final double _currentLongitude = 0.0;

//   final Map<MarkerId, Marker> _markers = {};
//   final Map<PolylineId, Polyline> _polylines = {};

//   /// AWCO's 9 official water treatment stations (per Wikipedia + AWCO
//   /// sources). Coordinates below are geocoded from public map listings;
//   /// 2 stations (مريوط 2 / الكيلو 40, and فرن الجراية) could not be
//   /// confidently located and are left commented out rather than guessed.
//   final Map<String, LatLng> awcoStationsLocations = {
//     'محطة السيوف': const LatLng(31.222324, 29.988280), // 840,000 m³/day
//     'محطة مريوط 1': const LatLng(30.911413, 29.974326), // 510,000 m³/day
//     'محطة شرقي': const LatLng(31.200825, 29.919157), // 510,000 m³/day
//     'محطة المنشية 1': const LatLng(31.185514, 29.934137), // 380,000 m³/day
//     'محطة المنشية 2': const LatLng(31.175664, 29.986611), // 240,000 m³/day
//     'محطة المعمورة': const LatLng(31.290460, 30.050855), // 240,000 m³/day
//     'محطة النزهة': const LatLng(31.198524, 29.952943), // 200,000 m³/day
//     // 'محطة مريوط 2 (الكيلو 40)': not confidently located yet — 636,000 m³/day
//     // 'محطة فرن الجراية': not confidently located yet — 50,000 m³/day
//   };

//   bool _mapReady = false;
//   final BitmapDescriptor _stationIcon =
//       BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);

//   @override
//   void initState() {
//     super.initState();
//     _addStationMarkers();
//   }

//   @override
//   void dispose() {
//     try {
//       if (_mapController != null) {
//         if (!kIsWeb) {
//           _mapController!.dispose();
//         }
//         _mapController = null;
//       }
//     } catch (error) {
//       debugPrint('⚠️ Error during map controller cleanup: $error');
//     }
//     super.dispose();
//   }

//   /// Populate _markers with all AWCO station locations using the default
//   /// Google Maps pin in purple (BitmapDescriptor.hueViolet).
//   void _addStationMarkers() {
//     for (final entry in awcoStationsLocations.entries) {
//       final markerId = MarkerId(entry.key);
//       _markers[markerId] = Marker(
//         markerId: markerId,
//         position: entry.value,
//         infoWindow: InfoWindow(
//           title: entry.key,
//           snippet:
//               '${entry.value.latitude.toStringAsFixed(6)}, ${entry.value.longitude.toStringAsFixed(6)}',
//         ),
//         icon: _stationIcon,
//       );
//     }
//   }

//   void _onMapCreated(GoogleMapController controller) {
//     _mapController = controller;
//     setState(() => _mapReady = true);
//     debugPrint('✅ الخريطة جاهزة');

//     if (awcoStationsLocations.isNotEmpty) {
//       // Small delay ensures the map has finished laying out before we
//       // animate the camera to fit bounds.
//       Future.delayed(const Duration(milliseconds: 300), _fitBoundsToStations);
//     }
//   }

//   /// Animate the camera to fit all AWCO station markers on screen.
//   void _fitBoundsToStations() {
//     if (_mapController == null || !_mapReady || awcoStationsLocations.isEmpty) {
//       return;
//     }

//     final positions = awcoStationsLocations.values.toList();

//     // Single location: just center on it, bounds don't make sense.
//     if (positions.length == 1) {
//       _mapController!.animateCamera(
//         CameraUpdate.newLatLngZoom(positions.first, 14),
//       );
//       return;
//     }

//     double minLat = positions.first.latitude;
//     double maxLat = positions.first.latitude;
//     double minLng = positions.first.longitude;
//     double maxLng = positions.first.longitude;

//     for (final p in positions) {
//       minLat = min(minLat, p.latitude);
//       maxLat = max(maxLat, p.latitude);
//       minLng = min(minLng, p.longitude);
//       maxLng = max(maxLng, p.longitude);
//     }

//     final bounds = LatLngBounds(
//       southwest: LatLng(minLat, minLng),
//       northeast: LatLng(maxLat, maxLng),
//     );

//     try {
//       _mapController!.animateCamera(
//         CameraUpdate.newLatLngBounds(bounds, 60),
//       );
//       debugPrint('📷 تم ضبط الكاميرا لعرض جميع المحطات');
//     } catch (error) {
//       debugPrint('⚠️ Error fitting bounds to stations: $error');
//       // Fallback: center on the first station.
//       _mapController!.animateCamera(
//         CameraUpdate.newLatLngZoom(positions.first, 12),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         GoogleMap(
//           onMapCreated: _onMapCreated,
//           initialCameraPosition: const CameraPosition(
//             target: _alexandriaCoordinates,
//             zoom: 13,
//             tilt: 0,
//             bearing: 0,
//           ),
//           markers: Set.of(_markers.values),
//           polylines: Set.of(_polylines.values),
//           zoomControlsEnabled: false,
//           myLocationButtonEnabled: false,
//           myLocationEnabled: false,
//           tiltGesturesEnabled: true,
//           buildingsEnabled: true,
//           indoorViewEnabled: false,
//           trafficEnabled: true,
//           mapToolbarEnabled: false,
//           rotateGesturesEnabled: true,
//           scrollGesturesEnabled: true,
//           zoomGesturesEnabled: true,
//           compassEnabled: true,
//           mapType: MapType.normal,
//         ),
//       ],
//     );
//   }
// }
