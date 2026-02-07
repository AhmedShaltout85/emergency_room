// // ignore_for_file: unused_field

// import 'dart:async';
// import 'dart:math';
// import 'dart:ui' as ui;

// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:emergency_room/network/remote/remote_network_repos.dart';

// class Tracking extends StatefulWidget {
//   final String latitude;
//   final String longitude;
//   final String address;
//   final String technicianName;
//   const Tracking({
//     super.key,
//     required this.latitude,
//     required this.longitude,
//     required this.address,
//     required this.technicianName,
//   });

//   @override
//   State<Tracking> createState() => _TrackingState();
// }

// class _TrackingState extends State<Tracking> {
//   Timer? _timer;
//   Timer? _pulseTimer;
//   final Completer<GoogleMapController> _controller = Completer();
//   LatLng alexandriaCoordinates = const LatLng(31.205753, 29.924526);
//   double currentLatitude = 0.0;
//   double currentLongitude = 0.0;
//   double startLatitude = 0.0;
//   double startLongitude = 0.0;
//   BitmapDescriptor? pinLocationIcon;
//   BitmapDescriptor? directionIcon;

//   // Route tracking
//   final Set<Polyline> polylines = {};
//   final PolylineId routePolylineId = const PolylineId('route');
//   bool isLoadingRoute = false;
//   bool _isPulsing = false;
//   String routeDistance = 'جاري الحساب...';
//   String routeDuration = 'جاري الحساب...';
//   String apiStatus = 'جاهز';

//   // Optimization variables
//   DateTime _lastRouteDraw = DateTime.now();
//   static const _minRouteDrawInterval = Duration(seconds: 5);
//   LatLng _lastStartPoint = const LatLng(0, 0);
//   LatLng _lastEndPoint = const LatLng(0, 0);

//   // Responsive UI variables
//   double _infoCardWidth = 400;
//   double _infoCardMaxWidth = 500;
//   double _infoCardMinWidth = 300;
//   final Set<Marker> markers = {};
//   late Future getCurrentLocation;

//   // Fix for JitsiMeetAPI conflict
//   static bool _scriptsLoaded = false;

//   @override
//   void initState() {
//     super.initState();

//     // Fix for JitsiMeetAPI conflict
//     _checkAndFixJitsiConflict();

//     // Calculate initial card width based on address length
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _calculateInfoCardWidth();
//     });

//     // Load custom markers
//     _loadCustomMarker();
//     _createDirectionIcon().then((icon) {
//       directionIcon = icon;
//     });

//     // Start location tracking
//     _getCurrentLocation();
//     _startFetchingLocation();
//     _startPulseAnimation();
//   }

//   // Fix for JitsiMeetAPI JavaScript conflict
//   void _checkAndFixJitsiConflict() {
//     if (!_scriptsLoaded) {
//       _scriptsLoaded = true;
//     } else {
//       // If scripts are already loaded, we need to handle the conflict
//       Future.delayed(const Duration(milliseconds: 100), () {
//         // Try to access the global variable safely
//         try {
//           // This is a workaround for the JavaScript conflict
//           // We'll prevent the plugin from trying to load scripts again
//           debugPrint(
//               '⚠️ Jitsi scripts already loaded, using existing instance');
//         } catch (e) {
//           debugPrint('⚠️ Jitsi conflict handled: $e');
//         }
//       });
//     }
//   }

//   void _calculateInfoCardWidth() {
//     if (!mounted) return;

//     // Calculate width based on address length
//     final addressLength = widget.address.length;

//     if (addressLength < 50) {
//       _infoCardWidth = _infoCardMinWidth;
//     } else if (addressLength < 100) {
//       _infoCardWidth = 350;
//     } else if (addressLength < 150) {
//       _infoCardWidth = 400;
//     } else {
//       _infoCardWidth = _infoCardMaxWidth;
//     }

//     // Adjust based on screen width
//     final screenWidth = MediaQuery.of(context).size.width;
//     _infoCardWidth = min(_infoCardWidth, screenWidth * 0.9);
//     _infoCardWidth = max(_infoCardWidth, _infoCardMinWidth);
//   }

//   void _loadCustomMarker() {
//     BitmapDescriptor.fromAssetImage(
//       const ImageConfiguration(size: Size(40, 40)),
//       'assets/green_marker.png',
//     ).then((icon) {
//       setState(() {
//         pinLocationIcon = icon;
//       });
//     }).catchError((error) {
//       debugPrint('Error loading marker icon: $error');
//       pinLocationIcon = BitmapDescriptor.defaultMarkerWithHue(
//         BitmapDescriptor.hueGreen,
//       );
//     });
//   }

//   Future<BitmapDescriptor> _createDirectionIcon() async {
//     final pictureRecorder = ui.PictureRecorder();
//     final canvas = ui.Canvas(pictureRecorder);
//     final paint = ui.Paint()
//       ..color = Colors.blue
//       ..style = ui.PaintingStyle.fill;

//     final path = ui.Path();
//     path.moveTo(0, 20);
//     path.lineTo(10, 0);
//     path.lineTo(20, 20);
//     path.close();

//     canvas.drawPath(path, paint);

//     final picture = pictureRecorder.endRecording();
//     final image = await picture.toImage(20, 20);
//     final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

//     return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     _pulseTimer?.cancel();
//     super.dispose();
//   }

//   void _startPulseAnimation() {
//     _pulseTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
//       if (mounted) {
//         setState(() {
//           _isPulsing = !_isPulsing;
//         });

//         // Update polyline color without redrawing
//         if (polylines.isNotEmpty) {
//           _updatePolylineColor();
//         }
//       }
//     });
//   }

//   void _updatePolylineColor() {
//     if (polylines.isEmpty) return;

//     final polyline = polylines.first;
//     final updatedPolyline = polyline.copyWith(
//       colorParam:
//           _isPulsing ? const Color(0xFF4285F4) : const Color(0xFF34A853),
//       widthParam: _isPulsing ? 6 : 5,
//       patternsParam:
//           _isPulsing ? [PatternItem.dash(10), PatternItem.gap(5)] : [],
//     );

//     setState(() {
//       polylines.clear();
//       polylines.add(updatedPolyline);
//     });
//   }

//   /// Fetch current technician location
//   Future<void> _getCurrentLocation() async {
//     try {
//       getCurrentLocation = DioNetworkRepos().getLocationByAddressAndTechnician(
//         widget.address,
//         widget.technicianName,
//       );

//       getCurrentLocation.then((value) {
//         final newLat = double.parse(value['currentLatitude'].toString());
//         final newLng = double.parse(value['currentLongitude'].toString());

//         // Store start location if not set
//         if (startLatitude == 0.0) {
//           startLatitude = double.parse(
//               value['startLatitude']?.toString() ?? newLat.toString());
//           startLongitude = double.parse(
//               value['startLongitude']?.toString() ?? newLng.toString());
//         }

//         // Calculate distance moved
//         final distanceMoved = _calculateHaversineDistance(
//           LatLng(currentLatitude, currentLongitude),
//           LatLng(newLat, newLng),
//         );

//         // Only update if moved more than 10 meters or it's the first update
//         if (distanceMoved > 0.01 || currentLatitude == 0.0) {
//           debugPrint(
//               '📍 Technician Location Updated: $newLat, $newLng (Moved: ${distanceMoved.toStringAsFixed(2)} km)');

//           setState(() {
//             currentLatitude = newLat;
//             currentLongitude = newLng;
//           });

//           // Update markers and calculate route
//           _updateMarkers();
//           _calculateAndDrawRoute();
//         } else {
//           debugPrint(
//               '📍 Location unchanged (movement: ${distanceMoved.toStringAsFixed(4)} km)');
//         }
//       }).catchError((error) {
//         debugPrint('❌ Error fetching technician location: $error');
//       });
//     } catch (e) {
//       debugPrint('❌ Exception in _getCurrentLocation: $e');
//     }
//   }

//   /// Update markers on map
//   Future<void> _updateMarkers() async {
//     if (directionIcon == null) {
//       directionIcon = await _createDirectionIcon();
//     }

//     setState(() {
//       markers.clear();

//       // Destination marker (Green)
//       markers.add(
//         Marker(
//           markerId: MarkerId('dest_${widget.address}'),
//           position: LatLng(
//             double.parse(widget.latitude),
//             double.parse(widget.longitude),
//           ),
//           infoWindow: InfoWindow(
//             title: '📍 الوجهة النهائية',
//             snippet: widget.address,
//           ),
//           icon: pinLocationIcon ??
//               BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
//         ),
//       );

//       // Current location marker (Red)
//       if (currentLatitude != 0.0 && currentLongitude != 0.0) {
//         markers.add(
//           Marker(
//             markerId: const MarkerId('current_technician'),
//             position: LatLng(currentLatitude, currentLongitude),
//             infoWindow: InfoWindow(
//               title: '👷 الموقع الحالي للفني',
//               snippet:
//                   '${widget.technicianName}\n${currentLatitude.toStringAsFixed(6)}, ${currentLongitude.toStringAsFixed(6)}',
//             ),
//             icon:
//                 BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
//           ),
//         );

//         // Add direction arrow at 75% of the route
//         final start = LatLng(currentLatitude, currentLongitude);
//         final end = LatLng(
//           double.parse(widget.latitude),
//           double.parse(widget.longitude),
//         );

//         final arrowPoint = _calculatePointAlongRoute(start, end, 0.75);
//         final bearing = _calculateBearing(
//           currentLatitude,
//           currentLongitude,
//           double.parse(widget.latitude),
//           double.parse(widget.longitude),
//         );

//         markers.add(
//           Marker(
//             markerId: const MarkerId('direction_arrow'),
//             position: arrowPoint,
//             icon: directionIcon!,
//             anchor: const Offset(0.5, 0.5),
//             rotation: bearing,
//           ),
//         );
//       }
//     });
//   }

//   /// Calculate a point along the route
//   LatLng _calculatePointAlongRoute(
//       LatLng start, LatLng end, double percentage) {
//     final lat = start.latitude + (end.latitude - start.latitude) * percentage;
//     final lng =
//         start.longitude + (end.longitude - start.longitude) * percentage;
//     return LatLng(lat, lng);
//   }

//   /// Calculate bearing between two points
//   double _calculateBearing(
//       double startLat, double startLng, double endLat, double endLng) {
//     final startLatRad = startLat * pi / 180;
//     final startLngRad = startLng * pi / 180;
//     final endLatRad = endLat * pi / 180;
//     final endLngRad = endLng * pi / 180;

//     final y = sin(endLngRad - startLngRad) * cos(endLatRad);
//     final x = cos(startLatRad) * sin(endLatRad) -
//         sin(startLatRad) * cos(endLatRad) * cos(endLngRad - startLngRad);

//     final bearing = atan2(y, x);
//     return (bearing * 180 / pi + 360) % 360;
//   }

//   /// MAIN ROUTE CALCULATION - Optimized
//   Future<void> _calculateAndDrawRoute() async {
//     if (currentLatitude == 0.0 || currentLongitude == 0.0) return;

//     setState(() {
//       isLoadingRoute = true;
//       apiStatus = 'جاري حساب المسار...';
//     });

//     // Create source and destination points
//     final source = LatLng(currentLatitude, currentLongitude);
//     final destination = LatLng(
//       double.parse(widget.latitude),
//       double.parse(widget.longitude),
//     );

//     // Check if we need to redraw the route
//     final sourceChanged =
//         _calculateHaversineDistance(source, _lastStartPoint) > 0.05;
//     final destChanged =
//         _calculateHaversineDistance(destination, _lastEndPoint) > 0.001;

//     if (!sourceChanged && !destChanged && polylines.isNotEmpty) {
//       // Only update distance and time calculations
//       final distanceKm = _calculateHaversineDistance(source, destination);
//       final estimatedTime = _estimateTravelTime(distanceKm);

//       setState(() {
//         routeDistance = '${distanceKm.toStringAsFixed(1)} كم';
//         routeDuration = '~${estimatedTime} دقيقة';
//         apiStatus = 'المسار محدث';
//         isLoadingRoute = false;
//       });
//       return;
//     }

//     debugPrint('📍 Calculating route...');

//     // Calculate distance
//     final distanceKm = _calculateHaversineDistance(source, destination);
//     final estimatedTime = _estimateTravelTime(distanceKm);

//     setState(() {
//       routeDistance = '${distanceKm.toStringAsFixed(1)} كم';
//       routeDuration = '~${estimatedTime} دقيقة';
//       apiStatus = 'تم حساب المسار';
//     });

//     // Draw curved route for better visual effect
//     _drawCurvedRoute(source, destination);

//     // Adjust camera if route changed significantly
//     if (sourceChanged) {
//       _adjustCameraToRoute(source, destination);
//     }

//     // Store last points
//     _lastStartPoint = source;
//     _lastEndPoint = destination;

//     setState(() {
//       isLoadingRoute = false;
//     });
//   }

//   /// Calculate distance using Haversine formula
//   double _calculateHaversineDistance(LatLng point1, LatLng point2) {
//     const R = 6371.0; // Earth's radius in km

//     final lat1 = point1.latitude * pi / 180;
//     final lon1 = point1.longitude * pi / 180;
//     final lat2 = point2.latitude * pi / 180;
//     final lon2 = point2.longitude * pi / 180;

//     final dlat = lat2 - lat1;
//     final dlon = lon2 - lon1;

//     final a = sin(dlat / 2) * sin(dlat / 2) +
//         cos(lat1) * cos(lat2) * sin(dlon / 2) * sin(dlon / 2);

//     final c = 2 * atan2(sqrt(a), sqrt(1 - a));

//     return R * c;
//   }

//   /// Estimate travel time based on distance
//   int _estimateTravelTime(double distanceKm) {
//     // Average speed in city: 30 km/h
//     const averageSpeed = 30.0;
//     final hours = distanceKm / averageSpeed;
//     final minutes = (hours * 60).ceil();

//     // Minimum 5 minutes, maximum 120 minutes
//     return minutes.clamp(5, 120);
//   }

//   /// Draw a curved route between two points (optimized)
//   void _drawCurvedRoute(LatLng start, LatLng end) {
//     // Debounce: Only draw if enough time has passed or route changed significantly
//     final now = DateTime.now();
//     if (now.difference(_lastRouteDraw) < _minRouteDrawInterval &&
//         polylines.isNotEmpty &&
//         _calculateHaversineDistance(start, _lastStartPoint) < 0.05) {
//       debugPrint('⏭️ Skipping route redraw (debounced)');
//       return;
//     }

//     _lastRouteDraw = now;

//     final List<LatLng> routePoints = [];

//     // Calculate midpoint with slight curve
//     final midLat = (start.latitude + end.latitude) / 2;
//     final midLng = (start.longitude + end.longitude) / 2;

//     // Create a curved path by adding intermediate points
//     const steps = 20;
//     for (int i = 0; i <= steps; i++) {
//       final t = i / steps;

//       // Bezier curve calculation for smooth path
//       final lat = _bezierCurve(start.latitude, end.latitude, midLat + 0.001, t);
//       final lng =
//           _bezierCurve(start.longitude, end.longitude, midLng + 0.001, t);

//       routePoints.add(LatLng(lat, lng));
//     }

//     // Draw the polyline with animation
//     final Polyline polyline = Polyline(
//       polylineId: routePolylineId,
//       color: _isPulsing ? const Color(0xFF4285F4) : const Color(0xFF34A853),
//       width: _isPulsing ? 6 : 5,
//       points: routePoints,
//       startCap: Cap.roundCap,
//       endCap: Cap.roundCap,
//       jointType: JointType.round,
//       patterns: _isPulsing ? [PatternItem.dash(10), PatternItem.gap(5)] : [],
//     );

//     setState(() {
//       polylines.clear();
//       polylines.add(polyline);
//     });

//     debugPrint('✅ Route drawn with ${routePoints.length} points');
//   }

//   /// Bezier curve calculation for smooth path
//   double _bezierCurve(double start, double end, double control, double t) {
//     final mt = 1 - t;
//     return mt * mt * start + 2 * mt * t * control + t * t * end;
//   }

//   /// Calculate progress percentage
//   double _calculateProgressPercentage() {
//     // Use start location from API or current as fallback
//     final startPoint = startLatitude != 0.0
//         ? LatLng(startLatitude, startLongitude)
//         : LatLng(31.2049664, 29.9237376);

//     final endPoint = LatLng(
//       double.parse(widget.latitude),
//       double.parse(widget.longitude),
//     );
//     final currentPoint = LatLng(currentLatitude, currentLongitude);

//     final totalDistance = _calculateHaversineDistance(startPoint, endPoint);
//     final traveledDistance =
//         _calculateHaversineDistance(startPoint, currentPoint);

//     if (totalDistance == 0) return 0;

//     // Safety check: traveled shouldn't exceed total by more than 10%
//     if (traveledDistance > totalDistance * 1.1) {
//       return 100.0;
//     }

//     final progress = (traveledDistance / totalDistance * 100);
//     return progress.clamp(0, 100);
//   }

//   /// Calculate arrival time
//   String _calculateArrivalTime() {
//     final minutes = _estimateTravelTime(
//       _calculateHaversineDistance(
//         LatLng(currentLatitude, currentLongitude),
//         LatLng(double.parse(widget.latitude), double.parse(widget.longitude)),
//       ),
//     );

//     final now = DateTime.now();
//     final arrivalTime = now.add(Duration(minutes: minutes));

//     // Format time in 12-hour format with AM/PM
//     final hour = arrivalTime.hour;
//     final minute = arrivalTime.minute;

//     if (hour < 12) {
//       return '${hour == 0 ? 12 : hour}:${minute.toString().padLeft(2, '0')} ص';
//     } else {
//       final pmHour = hour > 12 ? hour - 12 : hour;
//       return '$pmHour:${minute.toString().padLeft(2, '0')} م';
//     }
//   }

//   /// Adjust camera to show both points
//   Future<void> _adjustCameraToRoute(LatLng start, LatLng end) async {
//     try {
//       final GoogleMapController controller = await _controller.future;

//       // Calculate bounds
//       final minLat = min(start.latitude, end.latitude);
//       final maxLat = max(start.latitude, end.latitude);
//       final minLng = min(start.longitude, end.longitude);
//       final maxLng = max(start.longitude, end.longitude);

//       // Add padding based on distance
//       final distance = _calculateHaversineDistance(start, end);
//       final padding = distance < 1.0 ? 0.02 : 0.01;

//       final bounds = LatLngBounds(
//         southwest: LatLng(minLat - padding, minLng - padding),
//         northeast: LatLng(maxLat + padding, maxLng + padding),
//       );

//       await controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));

//       debugPrint('✅ Camera adjusted to show route');
//     } catch (e) {
//       debugPrint('❌ Error adjusting camera: $e');
//     }
//   }

//   /// Move camera to technician location
//   Future<void> _moveCameraToTechnician() async {
//     try {
//       final GoogleMapController controller = await _controller.future;
//       await controller.animateCamera(CameraUpdate.newLatLngZoom(
//         LatLng(currentLatitude, currentLongitude),
//         16,
//       ));
//       debugPrint('✅ Camera moved to technician');
//     } catch (e) {
//       debugPrint('❌ Error moving camera: $e');
//     }
//   }

//   /// Move camera to destination
//   Future<void> _moveCameraToDestination() async {
//     try {
//       final GoogleMapController controller = await _controller.future;
//       await controller.animateCamera(CameraUpdate.newLatLngZoom(
//         LatLng(double.parse(widget.latitude), double.parse(widget.longitude)),
//         16,
//       ));
//       debugPrint('✅ Camera moved to destination');
//     } catch (e) {
//       debugPrint('❌ Error moving camera: $e');
//     }
//   }

//   /// Show entire route
//   Future<void> _showEntireRoute() async {
//     try {
//       final source = LatLng(currentLatitude, currentLongitude);
//       final destination = LatLng(
//         double.parse(widget.latitude),
//         double.parse(widget.longitude),
//       );

//       await _adjustCameraToRoute(source, destination);
//       debugPrint('✅ Showing entire route');
//     } catch (e) {
//       debugPrint('❌ Error showing route: $e');
//     }
//   }

//   /// Start periodic location updates
//   void _startFetchingLocation() {
//     const updateInterval = Duration(seconds: 30);
//     _timer = Timer.periodic(updateInterval, (Timer timer) {
//       debugPrint('🔄 Periodic location update');
//       _getCurrentLocation();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final progressPercentage = _calculateProgressPercentage();
//     final arrivalTime = _calculateArrivalTime();
//     final now = DateTime.now();
//     final screenWidth = MediaQuery.of(context).size.width;

//     // Recalculate card width if needed
//     _calculateInfoCardWidth();

//     // Calculate card width based on screen size
//     double cardWidth;
//     if (screenWidth < 600) {
//       cardWidth = screenWidth * 0.9;
//     } else if (screenWidth < 900) {
//       cardWidth = min(_infoCardWidth, screenWidth * 0.8);
//     } else {
//       cardWidth = min(_infoCardWidth, screenWidth * 0.7);
//     }

//     // Ensure minimum width
//     cardWidth = max(cardWidth, _infoCardMinWidth);

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         centerTitle: true,
//         elevation: 7,
//         title: Text(
//           'تتبع الفني: ${widget.technicianName}',
//           style: const TextStyle(color: Colors.blue),
//         ),
//         backgroundColor: Colors.white,
//         iconTheme: const IconThemeData(color: Colors.blue),
//         actions: [
//           Container(
//             margin: const EdgeInsets.only(right: 16),
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               color: _isPulsing
//                   ? Colors.green.withOpacity(0.8)
//                   : Colors.blue.withOpacity(0.8),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   _isPulsing ? Icons.location_on : Icons.location_searching,
//                   size: 16,
//                   color: Colors.white,
//                 ),
//                 const SizedBox(width: 6),
//                 const Text(
//                   'متابعة مباشرة',
//                   style: TextStyle(fontSize: 12, color: Colors.white),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           // Google Map
//           GoogleMap(
//             onMapCreated: (GoogleMapController controller) {
//               _controller.complete(controller);
//               debugPrint('✅ Map created');
//               Future.delayed(const Duration(seconds: 1), () {
//                 if (currentLatitude != 0.0 && currentLongitude != 0.0) {
//                   _calculateAndDrawRoute();
//                 }
//               });
//             },
//             initialCameraPosition: CameraPosition(
//               target: alexandriaCoordinates,
//               zoom: 12,
//             ),
//             markers: markers,
//             // polylines: polylines,
//             zoomControlsEnabled: true,
//             myLocationButtonEnabled: false,
//             compassEnabled: true,
//             rotateGesturesEnabled: true,
//             scrollGesturesEnabled: true,
//             zoomGesturesEnabled: true,
//             tiltGesturesEnabled: true,
//           ),

//           // Fixed Height Info Card - COMPLETELY FIXED with IntrinsicHeight
//           Positioned(
//             top: 20,
//             left: 20,
//             child: SizedBox(
//               width: cardWidth,
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 10,
//                       spreadRadius: 2,
//                     ),
//                   ],
//                 ),
//                 child: IntrinsicHeight(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Address Section - FIXED: No fixed height, uses intrinsic height
//                       Container(
//                         padding: const EdgeInsets.all(12),
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Container(
//                               width: 36,
//                               height: 36,
//                               decoration: BoxDecoration(
//                                 color: Colors.blue.withOpacity(0.1),
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: const Icon(Icons.location_on,
//                                   color: Colors.blue, size: 20),
//                             ),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   const Text(
//                                     'الوجهة',
//                                     style: TextStyle(
//                                         fontSize: 11, color: Colors.grey),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   ConstrainedBox(
//                                     constraints: const BoxConstraints(
//                                       maxHeight:
//                                           50, // Maximum height for address
//                                     ),
//                                     child: SingleChildScrollView(
//                                       physics:
//                                           const NeverScrollableScrollPhysics(),
//                                       child: Text(
//                                         widget.address,
//                                         style: const TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 13,
//                                           color: Colors.blue,
//                                         ),
//                                         maxLines: 2,
//                                         overflow: TextOverflow.ellipsis,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                       // Divider
//                       Container(
//                         height: 1,
//                         color: Colors.grey[200],
//                         margin: const EdgeInsets.symmetric(horizontal: 12),
//                       ),

//                       // Technician Info
//                       Container(
//                         padding: const EdgeInsets.all(12),
//                         child: Row(
//                           children: [
//                             Container(
//                               width: 36,
//                               height: 36,
//                               decoration: BoxDecoration(
//                                 color: Colors.green.withOpacity(0.1),
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: const Icon(Icons.person,
//                                   color: Colors.green, size: 20),
//                             ),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   const Text(
//                                     'الفني المسؤول',
//                                     style: TextStyle(
//                                         fontSize: 11, color: Colors.grey),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     widget.technicianName,
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 14,
//                                       color: Colors.blue,
//                                     ),
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                       // Divider
//                       Container(
//                         height: 1,
//                         color: Colors.grey[200],
//                         margin: const EdgeInsets.symmetric(horizontal: 12),
//                       ),

//                       // Route Info - FIXED with proper constraints
//                       Container(
//                         padding: const EdgeInsets.all(12),
//                         child: Container(
//                           padding: const EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             color: Colors.blue[50],
//                             borderRadius: BorderRadius.circular(8),
//                             border: Border.all(color: Colors.blue[100]!),
//                           ),
//                           child: _buildRouteInfoLayout(
//                               cardWidth - 40), // Subtract padding
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           // Loading overlay
//           if (isLoadingRoute)
//             Container(
//               color: Colors.black.withOpacity(0.4),
//               child: Center(
//                 child: Container(
//                   width: 140,
//                   height: 140,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.2),
//                         blurRadius: 20,
//                         spreadRadius: 2,
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const CircularProgressIndicator(
//                         color: Colors.blue,
//                         strokeWidth: 3,
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         'جاري تحديث الموقع',
//                         style: TextStyle(
//                           color: Colors.blue[800],
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         '${now.second.toString().padLeft(2, '0')}:${now.millisecond.toString().padLeft(3, '0')}',
//                         style: const TextStyle(
//                           fontSize: 11,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),

//           // Floating action buttons
//           Positioned(
//             bottom: 180,
//             right: 20,
//             child: Column(
//               children: [
//                 _buildFloatingButton(
//                   icon: Icons.person_pin_circle,
//                   color: Colors.red,
//                   heroTag: 'tech_fab',
//                   tooltip: 'ركز على الفني',
//                   onPressed: _moveCameraToTechnician,
//                 ),
//                 const SizedBox(height: 12),
//                 _buildFloatingButton(
//                   icon: Icons.location_on,
//                   color: Colors.green,
//                   heroTag: 'dest_fab',
//                   tooltip: 'ركز على الوجهة',
//                   onPressed: _moveCameraToDestination,
//                 ),
//                 const SizedBox(height: 12),
//                 _buildFloatingButton(
//                   icon: Icons.zoom_out_map,
//                   color: Colors.blue,
//                   heroTag: 'route_fab',
//                   tooltip: 'عرض المسار كاملاً',
//                   onPressed: _showEntireRoute,
//                 ),
//               ],
//             ),
//           ),

//           // Main refresh button
//           Positioned(
//             bottom: 20,
//             right: 20,
//             child: FloatingActionButton(
//               onPressed: _calculateAndDrawRoute,
//               backgroundColor: Colors.orange,
//               heroTag: 'refresh_fab',
//               elevation: 4,
//               child: const Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.refresh, color: Colors.white, size: 24),
//                   SizedBox(height: 2),
//                   Text(
//                     'تحديث',
//                     style: TextStyle(fontSize: 9, color: Colors.white),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//       // Bottom info bar
//       bottomNavigationBar: Container(
//         height: 50,
//         decoration: BoxDecoration(
//           color: Colors.grey[100],
//           border: const Border(top: BorderSide(color: Colors.grey, width: 0.5)),
//         ),
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             // Technician info
//             Flexible(
//               child: Row(
//                 children: [
//                   Container(
//                     width: 24,
//                     height: 24,
//                     decoration: BoxDecoration(
//                       color: Colors.red.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: Colors.red, width: 1.5),
//                     ),
//                     child: const Center(
//                       child: Icon(Icons.person, size: 12, color: Colors.red),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Flexible(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           widget.technicianName,
//                           style: const TextStyle(
//                               fontSize: 11, fontWeight: FontWeight.bold),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         Text(
//                           '${currentLatitude.toStringAsFixed(5)}, ${currentLongitude.toStringAsFixed(5)}',
//                           style:
//                               const TextStyle(fontSize: 9, color: Colors.grey),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Time and status
//             Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Text(
//                   '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}',
//                   style: const TextStyle(
//                       fontSize: 11,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.blue),
//                 ),
//                 Text(
//                   apiStatus,
//                   style: TextStyle(
//                     fontSize: 9,
//                     color: apiStatus.contains('جاري')
//                         ? Colors.orange
//                         : apiStatus.contains('خطأ')
//                             ? Colors.red
//                             : Colors.green,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// Helper method to build route info layout
//   Widget _buildRouteInfoLayout(double availableWidth) {
//     // Make layout responsive based on available width
//     if (availableWidth < 250) {
//       return Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _buildCompactInfoItem(
//             icon: Icons.directions_car,
//             iconColor: Colors.orange,
//             value: routeDistance,
//             label: 'المسافة',
//           ),
//           Container(height: 30, width: 1, color: Colors.blue[200]),
//           _buildCompactInfoItem(
//             icon: Icons.access_time,
//             iconColor: Colors.red,
//             value: routeDuration,
//             label: 'الوقت',
//           ),
//           Container(height: 30, width: 1, color: Colors.blue[200]),
//           _buildCompactInfoItem(
//             icon: Icons.schedule,
//             iconColor: Colors.green,
//             value: _calculateArrivalTime(),
//             label: 'الوصول',
//           ),
//         ],
//       );
//     } else {
//       return Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _buildInfoItem(
//             icon: Icons.directions_car,
//             iconColor: Colors.orange,
//             value: routeDistance,
//             label: 'المسافة',
//           ),
//           Container(height: 30, width: 1, color: Colors.blue[200]),
//           _buildInfoItem(
//             icon: Icons.access_time,
//             iconColor: Colors.red,
//             value: routeDuration,
//             label: 'الوقت',
//           ),
//           Container(height: 30, width: 1, color: Colors.blue[200]),
//           _buildInfoItem(
//             icon: Icons.schedule,
//             iconColor: Colors.green,
//             value: _calculateArrivalTime(),
//             label: 'الوصول',
//           ),
//         ],
//       );
//     }
//   }

//   // Helper widget for info items
//   Widget _buildInfoItem({
//     required IconData icon,
//     required Color iconColor,
//     required String value,
//     required String label,
//   }) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Icon(icon, color: iconColor, size: 20),
//         const SizedBox(height: 2),
//         SizedBox(
//           width: 70,
//           child: Text(
//             value,
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 12,
//             ),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//             textAlign: TextAlign.center,
//           ),
//         ),
//         SizedBox(
//           width: 70,
//           child: Text(
//             label,
//             style: const TextStyle(fontSize: 10, color: Colors.grey),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//             textAlign: TextAlign.center,
//           ),
//         ),
//       ],
//     );
//   }

//   // Helper widget for compact info items
//   Widget _buildCompactInfoItem({
//     required IconData icon,
//     required Color iconColor,
//     required String value,
//     required String label,
//   }) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Icon(icon, color: iconColor, size: 16),
//         const SizedBox(height: 2),
//         SizedBox(
//           width: 60,
//           child: Text(
//             value,
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 11,
//               color: Colors.blue,
//             ),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//             textAlign: TextAlign.center,
//           ),
//         ),
//         SizedBox(
//           width: 60,
//           child: Text(
//             label,
//             style: const TextStyle(fontSize: 9, color: Colors.grey),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//             textAlign: TextAlign.center,
//           ),
//         ),
//       ],
//     );
//   }

//   // Helper widget for floating buttons
//   Widget _buildFloatingButton({
//     required IconData icon,
//     required Color color,
//     required String heroTag,
//     required String tooltip,
//     required VoidCallback onPressed,
//   }) {
//     return Tooltip(
//       message: tooltip,
//       preferBelow: false,
//       child: FloatingActionButton(
//         onPressed: onPressed,
//         backgroundColor: color,
//         heroTag: heroTag,
//         mini: true,
//         elevation: 3,
//         child: Icon(icon, color: Colors.white, size: 20),
//       ),
//     );
//   }
// }
// ignore_for_file: unused_field

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:emergency_room/network/remote/remote_network_repos.dart';
import 'package:http/http.dart' as http;

class Tracking extends StatefulWidget {
  final String latitude;
  final String longitude;
  final String address;
  final String technicianName;

  const Tracking({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.technicianName,
  });

  @override
  State<Tracking> createState() => _TrackingState();
}

class _TrackingState extends State<Tracking> {
  // Controllers and Timers
  Timer? _locationTimer;
  Timer? _pulseTimer;
  GoogleMapController? _mapController;

  // HTTP Client
  final http.Client _httpClient = http.Client();

  // Location Data
  static const LatLng _alexandriaCoordinates = LatLng(31.205753, 29.924526);
  double _currentLatitude = 0.0;
  double _currentLongitude = 0.0;
  double _startLatitude = 0.0;
  double _startLongitude = 0.0;

  // Map Markers and Polylines
  final Map<MarkerId, Marker> _markers = {};
  final Map<PolylineId, Polyline> _polylines = {};
  BitmapDescriptor? _pinLocationIcon;
  BitmapDescriptor? _directionIcon;

  // Route Information
  String _routeDistance = 'جاري الحساب...';
  String _routeDuration = 'جاري الحساب...';
  String _apiStatus = 'جاهز';
  bool _isLoadingRoute = false;
  bool _isPulsing = false;
  bool _mapReady = false;

  // Optimization Variables
  DateTime _lastRouteDraw = DateTime.now();
  static const Duration _minRouteDrawInterval = Duration(seconds: 3);
  LatLng _lastStartPoint = const LatLng(0, 0);
  LatLng _lastEndPoint = const LatLng(0, 0);

  // UI Variables
  double _infoCardWidth = 400;
  static const double _infoCardMaxWidth = 500;
  static const double _infoCardMinWidth = 300;

  // API Configuration
  static const String _googleMapsApiKey =
      'AIzaSyDRaJJnyvmDSU8OgI8M20C5nmwHNc_AMvk';
  static const Duration _locationUpdateInterval = Duration(seconds: 30);
  static const double _movementThreshold = 0.01; // km

  // Polyline counter for unique IDs
  int _polylineCounter = 0;

  @override
  void initState() {
    super.initState();
    debugPrint('🚀 Tracking widget initialized');
    _initializeTracking();
  }

  @override
  void dispose() {
    debugPrint('🛑 Disposing tracking widget');
    _locationTimer?.cancel();
    _pulseTimer?.cancel();
    _httpClient.close();
    _mapController?.dispose();
    super.dispose();
  }

  /// Initialize all tracking components
  Future<void> _initializeTracking() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateInfoCardWidth();
    });

    await _loadCustomMarker();
    _directionIcon = await _createDirectionIcon();

    await _getCurrentLocation();
    _startLocationTracking();
    _startPulseAnimation();
  }

  /// Calculate responsive card width
  void _calculateInfoCardWidth() {
    if (!mounted) return;

    final addressLength = widget.address.length;
    final screenWidth = MediaQuery.of(context).size.width;

    if (addressLength < 50) {
      _infoCardWidth = _infoCardMinWidth;
    } else if (addressLength < 100) {
      _infoCardWidth = 350;
    } else if (addressLength < 150) {
      _infoCardWidth = 400;
    } else {
      _infoCardWidth = _infoCardMaxWidth;
    }

    _infoCardWidth = min(_infoCardWidth, screenWidth * 0.9);
    _infoCardWidth = max(_infoCardWidth, _infoCardMinWidth);
  }

  /// Load custom marker icon
  Future<void> _loadCustomMarker() async {
    try {
      _pinLocationIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(40, 40)),
        'assets/green_marker.png',
      );
      debugPrint('✅ Custom marker loaded');
    } catch (error) {
      debugPrint('⚠️ Error loading marker icon: $error');
      _pinLocationIcon = BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueGreen,
      );
    }
  }

  /// Create direction icon
  Future<BitmapDescriptor> _createDirectionIcon() async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = ui.Canvas(pictureRecorder);
    final paint = ui.Paint()
      ..color = Colors.blue
      ..style = ui.PaintingStyle.fill;

    final path = ui.Path();
    path.moveTo(0, 20);
    path.lineTo(10, 0);
    path.lineTo(20, 20);
    path.close();

    canvas.drawPath(path, paint);

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(20, 20);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  /// Start pulse animation
  void _startPulseAnimation() {
    _pulseTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          _isPulsing = !_isPulsing;
        });
      }
    });
  }

  /// Start periodic location tracking
  void _startLocationTracking() {
    _locationTimer = Timer.periodic(_locationUpdateInterval, (timer) {
      debugPrint('🔄 Periodic location update');
      _getCurrentLocation();
    });
  }

  /// Fetch current technician location
  Future<void> _getCurrentLocation() async {
    try {
      final locationData =
          await DioNetworkRepos().getLocationByAddressAndTechnician(
        widget.address,
        widget.technicianName,
      );

      if (!mounted) return;

      debugPrint('[log] Location API Response: $locationData');

      // Parse location data safely
      final newLat = _parseDouble(locationData['currentLatitude']);
      final newLng = _parseDouble(locationData['currentLongitude']);

      if (newLat == null || newLng == null) {
        debugPrint('⚠️ Invalid location data received');
        return;
      }

      // Initialize start location if first time
      if (_startLatitude == 0.0) {
        _startLatitude = _parseDouble(locationData['startLatitude']) ?? newLat;
        _startLongitude =
            _parseDouble(locationData['startLongitude']) ?? newLng;
      }

      // Calculate movement distance
      final distanceMoved = _calculateHaversineDistance(
        LatLng(_currentLatitude, _currentLongitude),
        LatLng(newLat, newLng),
      );

      // Update location if moved significantly or first time
      if (distanceMoved > _movementThreshold || _currentLatitude == 0.0) {
        debugPrint(
            '📍 Technician Location Updated: $newLat, $newLng (Moved: ${distanceMoved.toStringAsFixed(2)} km)');

        setState(() {
          _currentLatitude = newLat;
          _currentLongitude = newLng;
        });

        await _updateMarkers();

        // Wait a bit if map is still initializing
        if (_mapReady) {
          await _calculateAndDrawRoute();
        } else {
          debugPrint('⏳ Waiting for map to be ready...');
        }
      } else {
        debugPrint(
            '📍 Location unchanged (movement: ${distanceMoved.toStringAsFixed(4)} km)');
      }
    } catch (error) {
      debugPrint('❌ Error fetching technician location: $error');
      if (mounted) {
        setState(() {
          _apiStatus = 'خطأ في جلب الموقع';
        });
      }
    }
  }

  /// Safely parse double from dynamic value
  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Update map markers
  Future<void> _updateMarkers() async {
    if (!mounted) return;

    final destinationLat = _parseDouble(widget.latitude);
    final destinationLng = _parseDouble(widget.longitude);

    if (destinationLat == null || destinationLng == null) {
      debugPrint('⚠️ Invalid destination coordinates');
      return;
    }

    setState(() {
      _markers.clear();

      // Destination marker
      final destMarkerId = const MarkerId('destination_marker');
      _markers[destMarkerId] = Marker(
        markerId: destMarkerId,
        position: LatLng(destinationLat, destinationLng),
        infoWindow: InfoWindow(
          title: '📍 الوجهة النهائية',
          snippet: widget.address,
        ),
        icon: _pinLocationIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      );

      // Current technician location marker
      if (_currentLatitude != 0.0 && _currentLongitude != 0.0) {
        final techMarkerId = const MarkerId('technician_marker');
        _markers[techMarkerId] = Marker(
          markerId: techMarkerId,
          position: LatLng(_currentLatitude, _currentLongitude),
          infoWindow: InfoWindow(
            title: '👷 الموقع الحالي للفني',
            snippet: '${widget.technicianName}\n'
                '${_currentLatitude.toStringAsFixed(6)}, '
                '${_currentLongitude.toStringAsFixed(6)}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        );
      }
    });

    debugPrint('✅ Markers updated: ${_markers.length} markers');
  }

  /// Calculate and draw route
  Future<void> _calculateAndDrawRoute() async {
    if (_currentLatitude == 0.0 || _currentLongitude == 0.0) {
      debugPrint('⚠️ Cannot calculate route: Invalid current location');
      return;
    }

    final destinationLat = _parseDouble(widget.latitude);
    final destinationLng = _parseDouble(widget.longitude);

    if (destinationLat == null || destinationLng == null) {
      debugPrint('⚠️ Cannot calculate route: Invalid destination');
      return;
    }

    final source = LatLng(_currentLatitude, _currentLongitude);
    final destination = LatLng(destinationLat, destinationLng);

    // Check if route needs to be recalculated
    final sourceChanged =
        _calculateHaversineDistance(source, _lastStartPoint) > 0.05;
    final destChanged =
        _calculateHaversineDistance(destination, _lastEndPoint) > 0.001;
    final timeSinceLastDraw = DateTime.now().difference(_lastRouteDraw);

    if (!sourceChanged &&
        !destChanged &&
        _polylines.isNotEmpty &&
        timeSinceLastDraw < _minRouteDrawInterval) {
      debugPrint('⏭️ Skipping route calculation (no significant change)');
      return;
    }

    if (mounted) {
      setState(() {
        _isLoadingRoute = true;
        _apiStatus = 'جاري حساب المسار...';
      });
    }

    debugPrint('📍 Calculating route...');
    debugPrint('📍 Source: ${source.latitude}, ${source.longitude}');
    debugPrint(
        '📍 Destination: ${destination.latitude}, ${destination.longitude}');

    // Get directions
    await _getDirectionsWithCorsWorkaround(source, destination);

    // Adjust camera if source changed
    if (sourceChanged && _mapController != null) {
      await Future.delayed(const Duration(milliseconds: 300));
      await _adjustCameraToRoute(source, destination);
    }

    _lastStartPoint = source;
    _lastEndPoint = destination;
    _lastRouteDraw = DateTime.now();

    if (mounted) {
      setState(() {
        _isLoadingRoute = false;
      });
    }
  }

  /// Get directions with CORS workaround
  Future<void> _getDirectionsWithCorsWorkaround(
    LatLng origin,
    LatLng destination,
  ) async {
    try {
      debugPrint('🔄 Getting directions via CORS proxy...');
      await _getDirectionsWithProxy(origin, destination);
    } catch (error) {
      debugPrint('❌ All API attempts failed: $error');
      _useFallbackRoute(origin, destination);
    }
  }

  /// Get directions using CORS proxy
  Future<void> _getDirectionsWithProxy(
    LatLng origin,
    LatLng destination,
  ) async {
    final originStr = '${origin.latitude},${origin.longitude}';
    final destinationStr = '${destination.latitude},${destination.longitude}';

    final apiUrl = 'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=$originStr'
        '&destination=$destinationStr'
        '&mode=driving'
        '&language=ar'
        '&key=$_googleMapsApiKey';

    // Try multiple CORS proxies
    final proxies = [
      'https://api.allorigins.win/raw?url=',
      'https://corsproxy.io/?',
    ];

    bool success = false;

    for (final proxy in proxies) {
      if (success) break;

      try {
        debugPrint('🌐 Trying proxy: $proxy');
        final url = Uri.parse('$proxy${Uri.encodeComponent(apiUrl)}');

        final response =
            await _httpClient.get(url).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final status = data['status'] as String;

          debugPrint('🔄 API Response status: $status');

          if (status == 'OK') {
            debugPrint('✅ Proxy worked!');
            _processDirectionsResponse(data, origin, destination);
            success = true;
            break;
          } else {
            debugPrint('❌ API status: $status');
            if (data['error_message'] != null) {
              debugPrint('Error message: ${data['error_message']}');
            }
          }
        } else {
          debugPrint('❌ HTTP ${response.statusCode}');
        }
      } catch (error) {
        debugPrint('❌ Proxy error: $error');
      }
    }

    if (!success) {
      debugPrint('❌ All CORS proxies failed, using fallback route');
      _useFallbackRoute(origin, destination);
    }
  }

  /// Process directions API response
  void _processDirectionsResponse(
    Map<String, dynamic> data,
    LatLng origin,
    LatLng destination,
  ) {
    try {
      final status = data['status'] as String;

      if (status != 'OK') {
        debugPrint('❌ API status: $status');
        _useFallbackRoute(origin, destination);
        return;
      }

      final routes = data['routes'] as List?;
      if (routes == null || routes.isEmpty) {
        debugPrint('⚠️ No routes found');
        _useFallbackRoute(origin, destination);
        return;
      }

      final route = routes[0] as Map<String, dynamic>;
      final legs = route['legs'] as List?;

      if (legs == null || legs.isEmpty) {
        debugPrint('⚠️ No legs found in route');
        _useFallbackRoute(origin, destination);
        return;
      }

      final leg = legs[0] as Map<String, dynamic>;
      final distance = leg['distance']?['text'] as String? ?? 'غير متوفر';
      final duration = leg['duration']?['text'] as String? ?? 'غير متوفر';

      debugPrint('✅ Route found: $distance, $duration');

      // Update UI with route info
      if (mounted) {
        setState(() {
          _routeDistance = distance;
          _routeDuration = duration;
          _apiStatus = 'تم حساب المسار الفعلي';
        });
      }

      // Extract and draw the route polyline
      final overviewPolyline =
          route['overview_polyline'] as Map<String, dynamic>?;
      final encodedPolyline = overviewPolyline?['points'] as String?;

      if (encodedPolyline == null || encodedPolyline.isEmpty) {
        debugPrint('⚠️ No polyline found');
        _useFallbackRoute(origin, destination);
        return;
      }

      debugPrint('🔄 Decoding polyline (length: ${encodedPolyline.length})...');
      final points = _decodePolyline(encodedPolyline);

      if (points.isNotEmpty) {
        debugPrint('✅ Decoded ${points.length} points');
        _drawRoutePolyline(points);
      } else {
        debugPrint('⚠️ No points decoded, using fallback');
        _useFallbackRoute(origin, destination);
      }
    } catch (error) {
      debugPrint('❌ Error processing response: $error');
      _useFallbackRoute(origin, destination);
    }
  }

  /// Decode Google's encoded polyline
  List<LatLng> _decodePolyline(String encoded) {
    final points = <LatLng>[];
    int index = 0;
    final len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;

      do {
        if (index >= len) break;
        b = encoded.codeUnitAt(index++) - 63;
        if (b < 0 || b > 31) break;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      final dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;

      do {
        if (index >= len) break;
        b = encoded.codeUnitAt(index++) - 63;
        if (b < 0 || b > 31) break;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      final dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  /// Draw route polyline on map - WEB OPTIMIZED VERSION
  void _drawRoutePolyline(List<LatLng> points) {
    if (points.isEmpty || !mounted) {
      debugPrint(
          '⚠️ Cannot draw polyline: ${points.isEmpty ? "No points" : "Not mounted"}');
      return;
    }

    try {
      // CRITICAL: Use Map instead of Set for web compatibility
      // Increment counter for unique ID on each draw
      _polylineCounter++;
      final polylineId = PolylineId('route_$_polylineCounter');

      debugPrint('🎨 Creating polyline with ID: route_$_polylineCounter');

      // Create a highly visible polyline with web-optimized settings
      final polyline = Polyline(
        polylineId: polylineId,
        points: points,
        color: const Color(0xFF2196F3), // Material Blue - highly visible
        width: 8, // Thicker for better visibility on web
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
        geodesic: true, // Follow Earth's curvature
        visible: true,
        consumeTapEvents: false,
        zIndex: 999, // Make sure it's on top
      );

      // CRITICAL: Clear old polylines and add new one
      setState(() {
        _polylines.clear();
        _polylines[polylineId] = polyline;
      });

      debugPrint('✅ Route polyline drawn with ${points.length} points');
      debugPrint('🎨 Polyline ID: route_$_polylineCounter');
      debugPrint('🎨 Color: #2196F3 (Material Blue), width: 8');
      debugPrint('📊 Polylines map size: ${_polylines.length}');
      debugPrint(
          '📍 First point: ${points.first.latitude}, ${points.first.longitude}');
      debugPrint(
          '📍 Last point: ${points.last.latitude}, ${points.last.longitude}');

      // Force a rebuild after a short delay to ensure rendering
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {
            // Trigger rebuild
          });
          debugPrint('🔄 Forced UI rebuild for polyline visibility');
        }
      });
    } catch (error) {
      debugPrint('❌ Error drawing polyline: $error');
      debugPrint('Stack trace: ${StackTrace.current}');
    }
  }

  /// Use fallback route calculation
  void _useFallbackRoute(LatLng origin, LatLng destination) {
    debugPrint('🔄 Using fallback route calculation');

    final distanceKm = _calculateHaversineDistance(origin, destination);
    final estimatedTime = _estimateTravelTime(distanceKm);

    if (mounted) {
      setState(() {
        _routeDistance = '${distanceKm.toStringAsFixed(1)} كم';
        _routeDuration = '~$estimatedTime دقيقة';
        _apiStatus = 'مسار تقريبي';
      });
    }

    _drawCurvedRoute(origin, destination);
  }

  /// Draw curved fallback route
  void _drawCurvedRoute(LatLng start, LatLng end) {
    if (!mounted) return;

    final routePoints = <LatLng>[];
    final midLat = (start.latitude + end.latitude) / 2;
    final midLng = (start.longitude + end.longitude) / 2;

    // Create more points for smoother curve
    const steps = 30;
    for (int i = 0; i <= steps; i++) {
      final t = i / steps;
      final lat = _bezierCurve(start.latitude, end.latitude, midLat + 0.001, t);
      final lng =
          _bezierCurve(start.longitude, end.longitude, midLng + 0.001, t);
      routePoints.add(LatLng(lat, lng));
    }

    // Increment counter for unique ID
    _polylineCounter++;
    final polylineId = PolylineId('fallback_route_$_polylineCounter');

    final polyline = Polyline(
      polylineId: polylineId,
      points: routePoints,
      color: const Color(0xFF2196F3), // Material Blue
      width: 7,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      jointType: JointType.round,
      patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      geodesic: true,
      visible: true,
      zIndex: 998,
    );

    setState(() {
      _polylines.clear();
      _polylines[polylineId] = polyline;
    });

    debugPrint('✅ Fallback route drawn with ${routePoints.length} points');

    // Force rebuild
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {});
        debugPrint('🔄 Forced UI rebuild for fallback route');
      }
    });
  }

  /// Calculate Bezier curve point
  double _bezierCurve(double start, double end, double control, double t) {
    final mt = 1 - t;
    return mt * mt * start + 2 * mt * t * control + t * t * end;
  }

  /// Calculate distance using Haversine formula
  double _calculateHaversineDistance(LatLng point1, LatLng point2) {
    const R = 6371.0; // Earth's radius in km

    final lat1 = point1.latitude * pi / 180;
    final lon1 = point1.longitude * pi / 180;
    final lat2 = point2.latitude * pi / 180;
    final lon2 = point2.longitude * pi / 180;

    final dlat = lat2 - lat1;
    final dlon = lon2 - lon1;

    final a = sin(dlat / 2) * sin(dlat / 2) +
        cos(lat1) * cos(lat2) * sin(dlon / 2) * sin(dlon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }

  /// Estimate travel time
  int _estimateTravelTime(double distanceKm) {
    const averageSpeed = 30.0; // km/h
    final hours = distanceKm / averageSpeed;
    final minutes = (hours * 60).ceil();
    return minutes.clamp(5, 120);
  }

  /// Calculate estimated arrival time
  String _calculateArrivalTime() {
    try {
      final destinationLat = _parseDouble(widget.latitude);
      final destinationLng = _parseDouble(widget.longitude);

      if (destinationLat == null || destinationLng == null) {
        return '--:--';
      }

      final minutes = _estimateTravelTime(
        _calculateHaversineDistance(
          LatLng(_currentLatitude, _currentLongitude),
          LatLng(destinationLat, destinationLng),
        ),
      );

      final now = DateTime.now();
      final arrivalTime = now.add(Duration(minutes: minutes));

      final hour = arrivalTime.hour;
      final minute = arrivalTime.minute;

      if (hour < 12) {
        return '${hour == 0 ? 12 : hour}:${minute.toString().padLeft(2, '0')} ص';
      } else {
        final pmHour = hour > 12 ? hour - 12 : hour;
        return '$pmHour:${minute.toString().padLeft(2, '0')} م';
      }
    } catch (error) {
      debugPrint('❌ Error calculating arrival time: $error');
      return '--:--';
    }
  }

  /// Adjust camera to show entire route
  Future<void> _adjustCameraToRoute(LatLng start, LatLng end) async {
    try {
      if (_mapController == null) {
        debugPrint('⚠️ Map controller not ready');
        return;
      }

      final minLat = min(start.latitude, end.latitude);
      final maxLat = max(start.latitude, end.latitude);
      final minLng = min(start.longitude, end.longitude);
      final maxLng = max(start.longitude, end.longitude);

      final distance = _calculateHaversineDistance(start, end);
      final padding = distance < 1.0 ? 0.02 : 0.01;

      final bounds = LatLngBounds(
        southwest: LatLng(minLat - padding, minLng - padding),
        northeast: LatLng(maxLat + padding, maxLng + padding),
      );

      await _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 80),
      );
      debugPrint('✅ Camera adjusted to show route');
    } catch (error) {
      debugPrint('❌ Error adjusting camera: $error');
    }
  }

  /// Move camera to technician location
  Future<void> _moveCameraToTechnician() async {
    try {
      if (_mapController == null) return;

      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentLatitude, _currentLongitude),
          16,
        ),
      );
      debugPrint('✅ Camera moved to technician');
    } catch (error) {
      debugPrint('❌ Error moving camera: $error');
    }
  }

  /// Move camera to destination
  Future<void> _moveCameraToDestination() async {
    try {
      if (_mapController == null) return;

      final destinationLat = _parseDouble(widget.latitude);
      final destinationLng = _parseDouble(widget.longitude);

      if (destinationLat == null || destinationLng == null) return;

      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(destinationLat, destinationLng),
          16,
        ),
      );
      debugPrint('✅ Camera moved to destination');
    } catch (error) {
      debugPrint('❌ Error moving camera: $error');
    }
  }

  /// Show entire route on map
  Future<void> _showEntireRoute() async {
    try {
      if (_mapController == null) return;

      final destinationLat = _parseDouble(widget.latitude);
      final destinationLng = _parseDouble(widget.longitude);

      if (destinationLat == null || destinationLng == null) return;

      final source = LatLng(_currentLatitude, _currentLongitude);
      final destination = LatLng(destinationLat, destinationLng);

      await _adjustCameraToRoute(source, destination);
      debugPrint('✅ Showing entire route');
    } catch (error) {
      debugPrint('❌ Error showing route: $error');
    }
  }

  /// Handle map creation
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _mapReady = true;
    debugPrint('✅ Google Map created and ready');

    // Calculate route after map is ready with longer delay for web
    Future.delayed(const Duration(milliseconds: 800), () {
      if (_currentLatitude != 0.0 && _currentLongitude != 0.0 && mounted) {
        debugPrint('🎯 Triggering initial route calculation');
        _calculateAndDrawRoute();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final screenWidth = MediaQuery.of(context).size.width;

    _calculateInfoCardWidth();

    double cardWidth;
    if (screenWidth < 600) {
      cardWidth = screenWidth * 0.9;
    } else if (screenWidth < 900) {
      cardWidth = min(_infoCardWidth, screenWidth * 0.8);
    } else {
      cardWidth = min(_infoCardWidth, screenWidth * 0.7);
    }

    cardWidth = max(cardWidth, _infoCardMinWidth);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          _buildGoogleMap(),
          _buildInfoCard(cardWidth),
          if (_isLoadingRoute) _buildLoadingOverlay(),
          _buildCameraControls(),
          _buildRefreshButton(),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(now),
    );
  }

  /// Build AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      centerTitle: true,
      elevation: 7,
      title: Text(
        'تتبع الفني: ${widget.technicianName}',
        style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.blue),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _isPulsing
                ? Colors.green.withOpacity(0.8)
                : Colors.blue.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(
                _isPulsing ? Icons.location_on : Icons.location_searching,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 6),
              const Text(
                'متابعة مباشرة',
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build Google Map - WEB OPTIMIZED
  Widget _buildGoogleMap() {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: const CameraPosition(
        target: _alexandriaCoordinates,
        zoom: 12,
      ),
      markers: Set<Marker>.of(_markers.values),
      polylines: Set<Polyline>.of(_polylines.values),
      zoomControlsEnabled: true,
      myLocationButtonEnabled: false,
      compassEnabled: true,
      rotateGesturesEnabled: true,
      scrollGesturesEnabled: true,
      zoomGesturesEnabled: true,
      tiltGesturesEnabled: true,
      mapToolbarEnabled: false,
      trafficEnabled: false,
      buildingsEnabled: true,
      indoorViewEnabled: false,
      myLocationEnabled: false,
      liteModeEnabled: false, // CRITICAL for web polyline visibility
    );
  }

  /// Build info card overlay
  Widget _buildInfoCard(double cardWidth) {
    return Positioned(
      top: 20,
      left: 20,
      child: Container(
        width: cardWidth,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDestinationSection(),
            _buildDivider(),
            _buildTechnicianSection(),
            _buildDivider(),
            _buildRouteInfoSection(cardWidth - 40),
          ],
        ),
      ),
    );
  }

  /// Build destination section
  Widget _buildDestinationSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.location_on, color: Colors.blue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'الوجهة',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.address,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.blue,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build technician section
  Widget _buildTechnicianSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.person, color: Colors.green, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'الفني المسؤول',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.technicianName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.blue,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build route info section
  Widget _buildRouteInfoSection(double availableWidth) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue[100]!),
        ),
        child: _buildRouteInfoLayout(availableWidth),
      ),
    );
  }

  /// Build route info layout
  Widget _buildRouteInfoLayout(double availableWidth) {
    final arrivalTime = _calculateArrivalTime();

    if (availableWidth < 250) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCompactInfoItem(
            icon: Icons.directions_car,
            iconColor: Colors.orange,
            value: _routeDistance,
            label: 'المسافة',
          ),
          _buildVerticalDivider(),
          _buildCompactInfoItem(
            icon: Icons.access_time,
            iconColor: Colors.red,
            value: _routeDuration,
            label: 'الوقت',
          ),
          _buildVerticalDivider(),
          _buildCompactInfoItem(
            icon: Icons.schedule,
            iconColor: Colors.green,
            value: arrivalTime,
            label: 'الوصول',
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(
            icon: Icons.directions_car,
            iconColor: Colors.orange,
            value: _routeDistance,
            label: 'المسافة المتبقية',
          ),
          _buildVerticalDivider(),
          _buildInfoItem(
            icon: Icons.access_time,
            iconColor: Colors.red,
            value: _routeDuration,
            label: 'الوقت المتوقع',
          ),
          _buildVerticalDivider(),
          _buildInfoItem(
            icon: Icons.schedule,
            iconColor: Colors.green,
            value: arrivalTime,
            label: 'وقت الوصول',
          ),
        ],
      );
    }
  }

  /// Build info item
  Widget _buildInfoItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(height: 2),
        SizedBox(
          width: 70,
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  /// Build compact info item
  Widget _buildCompactInfoItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: iconColor, size: 16),
        const SizedBox(height: 2),
        SizedBox(
          width: 60,
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(fontSize: 9, color: Colors.grey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  /// Build divider
  Widget _buildDivider() {
    return Container(
      height: 1,
      color: Colors.grey[200],
      margin: const EdgeInsets.symmetric(horizontal: 12),
    );
  }

  /// Build vertical divider
  Widget _buildVerticalDivider() {
    return Container(height: 30, width: 1, color: Colors.blue[200]);
  }

  /// Build loading overlay
  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.4),
      child: Center(
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: Colors.blue,
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              Text(
                'جاري حساب المسار...',
                style: TextStyle(
                  color: Colors.blue[800],
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _apiStatus,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build camera controls
  Widget _buildCameraControls() {
    return Positioned(
      bottom: 180,
      right: 20,
      child: Column(
        children: [
          _buildFloatingButton(
            icon: Icons.person_pin_circle,
            color: Colors.red,
            heroTag: 'tech_fab',
            tooltip: 'ركز على الفني',
            onPressed: _moveCameraToTechnician,
          ),
          const SizedBox(height: 12),
          _buildFloatingButton(
            icon: Icons.location_on,
            color: Colors.green,
            heroTag: 'dest_fab',
            tooltip: 'ركز على الوجهة',
            onPressed: _moveCameraToDestination,
          ),
          const SizedBox(height: 12),
          _buildFloatingButton(
            icon: Icons.zoom_out_map,
            color: Colors.blue,
            heroTag: 'route_fab',
            tooltip: 'عرض المسار كاملاً',
            onPressed: _showEntireRoute,
          ),
        ],
      ),
    );
  }

  /// Build refresh button
  Widget _buildRefreshButton() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: FloatingActionButton(
        onPressed: () {
          debugPrint('🔄 Manual refresh triggered');
          _getCurrentLocation();
          if (_currentLatitude != 0.0 && _currentLongitude != 0.0) {
            _calculateAndDrawRoute();
          }
        },
        backgroundColor: Colors.orange,
        heroTag: 'refresh_fab',
        elevation: 4,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.refresh, color: Colors.white, size: 24),
            SizedBox(height: 2),
            Text(
              'تحديث',
              style: TextStyle(fontSize: 9, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  /// Build floating button
  Widget _buildFloatingButton({
    required IconData icon,
    required Color color,
    required String heroTag,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      preferBelow: false,
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: color,
        heroTag: heroTag,
        mini: true,
        elevation: 3,
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  /// Build bottom navigation bar
  Widget _buildBottomBar(DateTime now) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: const Border(top: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red, width: 1.5),
                  ),
                  child: const Center(
                    child: Icon(Icons.person, size: 12, color: Colors.red),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.technicianName,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${_currentLatitude.toStringAsFixed(5)}, '
                        '${_currentLongitude.toStringAsFixed(5)}',
                        style: const TextStyle(fontSize: 9, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${now.hour.toString().padLeft(2, '0')}:'
                '${now.minute.toString().padLeft(2, '0')}:'
                '${now.second.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              Text(
                _apiStatus,
                style: TextStyle(
                  fontSize: 9,
                  color: _apiStatus.contains('جاري')
                      ? Colors.orange
                      : _apiStatus.contains('خطأ') ||
                              _apiStatus.contains('تقريبي')
                          ? Colors.orange
                          : Colors.green,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
