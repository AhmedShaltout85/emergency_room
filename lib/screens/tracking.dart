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

// import 'dart:async';
// import 'dart:convert';
// import 'dart:math';
// import 'dart:ui' as ui;

// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:emergency_room/network/remote/remote_network_repos.dart';
// import 'package:http/http.dart' as http;

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
//   Timer? _locationTimer;
//   Timer? _pulseTimer;
//   GoogleMapController? _mapController;
//   final http.Client _httpClient = http.Client();

//   static const LatLng _alexandriaCoordinates = LatLng(31.205753, 29.924526);
//   double _currentLatitude = 0.0;
//   double _currentLongitude = 0.0;
//   double _startLatitude = 0.0;
//   double _startLongitude = 0.0;

//   final Map<MarkerId, Marker> _markers = {};
//   final Map<PolylineId, Polyline> _polylines = {};
//   BitmapDescriptor? _destinationIcon;
//   BitmapDescriptor? _technicianIcon;

//   String _routeDistance = 'جاري الحساب...';
//   String _routeDuration = 'جاري الحساب...';
//   String _apiStatus = 'جاهز';
//   bool _isLoadingRoute = false;
//   bool _isPulsing = false;
//   bool _mapReady = false;
//   bool _hasRoute = false;

//   List<LatLng> _routePoints = [];
//   int _polylineCounter = 0;

//   double _infoCardWidth = 400;
//   static const double _infoCardMaxWidth = 500;
//   static const double _infoCardMinWidth = 300;

//   static const String _googleMapsApiKey =
//       'AIzaSyDRaJJnyvmDSU8OgI8M20C5nmwHNc_AMvk';
//   static const Duration _locationUpdateInterval = Duration(seconds: 30);

//   DateTime? _lastLocationUpdateTime;

//   @override
//   void initState() {
//     super.initState();
//     debugPrint('🚀 Tracking widget initialized');
//     _initializeTracking();
//   }

//   @override
//   void dispose() {
//     debugPrint('🛑 Disposing tracking widget');
//     _locationTimer?.cancel();
//     _pulseTimer?.cancel();
//     _httpClient.close();
//     _mapController?.dispose();
//     super.dispose();
//   }

//   Future<void> _initializeTracking() async {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _calculateInfoCardWidth();
//     });

//     await _loadCustomMarkers();
//     _startPulseAnimation();

//     // Get initial location with delay to ensure everything is ready
//     await Future.delayed(const Duration(milliseconds: 500));
//     await _getCurrentLocation();

//     _startLocationTracking();
//   }

//   void _calculateInfoCardWidth() {
//     if (!mounted) return;
//     final addressLength = widget.address.length;
//     final screenWidth = MediaQuery.of(context).size.width;

//     if (addressLength < 50) {
//       _infoCardWidth = _infoCardMinWidth;
//     } else if (addressLength < 100) {
//       _infoCardWidth = 350;
//     } else if (addressLength < 150) {
//       _infoCardWidth = 400;
//     } else {
//       _infoCardWidth = _infoCardMaxWidth;
//     }

//     _infoCardWidth = min(_infoCardWidth, screenWidth * 0.9);
//     _infoCardWidth = max(_infoCardWidth, _infoCardMinWidth);
//   }

//   Future<void> _loadCustomMarkers() async {
//     try {
//       // Destination marker (green pin)
//       _destinationIcon = await _createDestinationMarker();
//       debugPrint('✅ Destination marker loaded');
//     } catch (error) {
//       debugPrint('⚠️ Error loading destination marker: $error');
//       _destinationIcon =
//           BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
//     }

//     try {
//       // Technician marker (red with person)
//       _technicianIcon = await _createTechnicianMarker();
//       debugPrint('✅ Technician marker created');
//     } catch (error) {
//       debugPrint('⚠️ Error creating technician marker: $error');
//       _technicianIcon =
//           BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
//     }
//   }

//   Future<BitmapDescriptor> _createDestinationMarker() async {
//     const size = 48.0;
//     final pictureRecorder = ui.PictureRecorder();
//     final canvas = Canvas(pictureRecorder);

//     // Draw pin shape
//     final paint = Paint()
//       ..color = Colors.green
//       ..style = PaintingStyle.fill;

//     // Pin body (rounded rectangle)
//     final rRect = RRect.fromRectAndRadius(
//       const Rect.fromLTWH(0, 0, size * 0.6, size * 0.8),
//       const Radius.circular(10),
//     );
//     canvas.drawRRect(rRect, paint);

//     // Pin head (circle)
//     canvas.drawCircle(
//       const Offset(size * 0.3, size * 0.8),
//       size * 0.12,
//       paint,
//     );

//     // White dot in center
//     canvas.drawCircle(
//       const Offset(size * 0.3, size * 0.3),
//       size * 0.08,
//       Paint()..color = Colors.white,
//     );

//     final picture = pictureRecorder.endRecording();
//     final image = await picture.toImage(size.toInt(), size.toInt());
//     final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

//     return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
//   }

//   Future<BitmapDescriptor> _createTechnicianMarker() async {
//     const size = 48.0;
//     final pictureRecorder = ui.PictureRecorder();
//     final canvas = Canvas(pictureRecorder);

//     // Draw background circle with gradient
//     final gradient = RadialGradient(
//       center: Alignment.center,
//       colors: [Colors.red.shade600, Colors.red],
//       radius: 0.5,
//     );

//     final paint = Paint()
//       ..shader = gradient.createShader(Rect.fromCircle(
//         center: const Offset(size / 2, size / 2),
//         radius: size / 2,
//       ));

//     canvas.drawCircle(const Offset(size / 2, size / 2), size / 2, paint);

//     // Draw white border
//     canvas.drawCircle(
//       const Offset(size / 2, size / 2),
//       size / 2 - 2,
//       Paint()
//         ..color = Colors.white
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = 2,
//     );

//     // Draw person icon
//     final textPainter = TextPainter(
//       textDirection: TextDirection.ltr,
//       text: const TextSpan(
//         text: '👷',
//         style: TextStyle(fontSize: 20),
//       ),
//     );
//     textPainter.layout();
//     textPainter.paint(
//       canvas,
//       Offset(
//           size / 2 - textPainter.width / 2, size / 2 - textPainter.height / 2),
//     );

//     final picture = pictureRecorder.endRecording();
//     final image = await picture.toImage(size.toInt(), size.toInt());
//     final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

//     return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
//   }

//   void _startPulseAnimation() {
//     _pulseTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
//       if (mounted) setState(() => _isPulsing = !_isPulsing);
//     });
//   }

//   void _startLocationTracking() {
//     _locationTimer = Timer.periodic(_locationUpdateInterval, (timer) {
//       debugPrint('🔄 Periodic location update');
//       _getCurrentLocation();
//     });
//   }

//   Future<void> _getCurrentLocation() async {
//     try {
//       debugPrint('📡 Fetching location from API...');

//       final locationData =
//           await DioNetworkRepos().getLocationByAddressAndTechnician(
//         widget.address,
//         widget.technicianName,
//       );

//       if (!mounted) {
//         debugPrint('⚠️ Widget not mounted, aborting');
//         return;
//       }

//       debugPrint('📦 API Response received');

//       final newLat = _parseDouble(locationData['currentLatitude']);
//       final newLng = _parseDouble(locationData['currentLongitude']);

//       if (newLat == null || newLng == null) {
//         debugPrint('❌ Invalid location data received');
//         return;
//       }

//       // Initialize start location
//       if (_startLatitude == 0.0 || _startLongitude == 0.0) {
//         _startLatitude = _parseDouble(locationData['startLatitude']) ?? newLat;
//         _startLongitude = _parseDouble(locationData['startLongitude']) ??
//             newLng ??
//             _parseDouble(widget.longitude) ??
//             29.924526;
//         debugPrint('📍 Start location initialized');
//       }

//       // Check if location has changed significantly (20 meters)
//       final distanceChanged = _calculateDistance(
//               LatLng(_currentLatitude, _currentLongitude),
//               LatLng(newLat, newLng)) >
//           0.02;

//       if (_currentLatitude == 0.0 ||
//           _currentLongitude == 0.0 ||
//           distanceChanged ||
//           !_hasRoute) {
//         debugPrint('📍 Location updated: $newLat, $newLng');
//         debugPrint('📏 Distance changed: ${distanceChanged ? "Yes" : "No"}');

//         setState(() {
//           _currentLatitude = newLat;
//           _currentLongitude = newLng;
//           _lastLocationUpdateTime = DateTime.now();
//         });

//         await _updateMarkers();

//         if (!_hasRoute || distanceChanged) {
//           await _calculateAndDrawRoute();
//         }
//       } else {
//         debugPrint('⏭️ Location unchanged, updating markers only');
//         await _updateMarkers();
//       }
//     } catch (error, stackTrace) {
//       debugPrint('❌ Error fetching location: $error');
//       debugPrint('Stack trace: $stackTrace');
//       if (mounted) {
//         setState(() => _apiStatus = 'خطأ في جلب الموقع');
//       }
//     }
//   }

//   double? _parseDouble(dynamic value) {
//     if (value == null) return null;
//     if (value is double) return value;
//     if (value is int) return value.toDouble();
//     if (value is String) return double.tryParse(value);
//     return null;
//   }

//   Future<void> _updateMarkers() async {
//     if (!mounted) return;

//     final destLat = _parseDouble(widget.latitude);
//     final destLng = _parseDouble(widget.longitude);

//     if (destLat == null || destLng == null) {
//       debugPrint('⚠️ Invalid destination coordinates');
//       return;
//     }

//     debugPrint('🎯 Creating markers...');

//     setState(() {
//       _markers.clear();

//       // Destination marker
//       _markers[const MarkerId('destination')] = Marker(
//         markerId: const MarkerId('destination'),
//         position: LatLng(destLat, destLng),
//         infoWindow: InfoWindow(
//           title: '📍 الوجهة',
//           snippet: 'العنوان: ${widget.address}',
//         ),
//         icon: _destinationIcon ??
//             BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
//         anchor: const Offset(0.5, 0.9),
//         zIndex: 3,
//         draggable: false,
//         flat: true,
//       );

//       // Current location marker
//       if (_currentLatitude != 0.0 && _currentLongitude != 0.0) {
//         final updateTime = _lastLocationUpdateTime != null
//             ? 'آخر تحديث: ${_formatTime(_lastLocationUpdateTime!)}'
//             : 'جاري التحديث...';

//         _markers[const MarkerId('technician')] = Marker(
//           markerId: const MarkerId('technician'),
//           position: LatLng(_currentLatitude, _currentLongitude),
//           infoWindow: InfoWindow(
//             title: '👷 ${widget.technicianName}',
//             snippet: updateTime,
//           ),
//           icon: _technicianIcon ??
//               BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
//           anchor: const Offset(0.5, 0.5),
//           rotation: _isPulsing ? 0 : 360,
//           zIndex: 4,
//           flat: true,
//           consumeTapEvents: true,
//         );
//       }
//     });

//     debugPrint('✅ Created ${_markers.length} markers');
//   }

//   String _formatTime(DateTime time) {
//     final now = DateTime.now();
//     final difference = now.difference(time);

//     if (difference.inSeconds < 60) {
//       return 'منذ ${difference.inSeconds} ثانية';
//     } else if (difference.inMinutes < 60) {
//       return 'منذ ${difference.inMinutes} دقيقة';
//     } else if (difference.inHours < 24) {
//       return 'منذ ${difference.inHours} ساعة';
//     } else {
//       return time.toString().substring(0, 16);
//     }
//   }

//   Future<void> _calculateAndDrawRoute() async {
//     debugPrint('');
//     debugPrint('═══════════════════════════════════════');
//     debugPrint('🔄 CALCULATE AND DRAW ROUTE CALLED');
//     debugPrint('═══════════════════════════════════════');

//     if (_currentLatitude == 0.0 || _currentLongitude == 0.0) {
//       debugPrint('❌ ABORT: Current location is 0,0');
//       return;
//     }

//     final destLat = _parseDouble(widget.latitude);
//     final destLng = _parseDouble(widget.longitude);

//     if (destLat == null || destLng == null) {
//       debugPrint('❌ ABORT: Destination is invalid');
//       return;
//     }

//     final source = LatLng(_currentLatitude, _currentLongitude);
//     final destination = LatLng(destLat, destLng);

//     debugPrint(
//         '📍 المصدر: ${source.latitude.toStringAsFixed(6)}, ${source.longitude.toStringAsFixed(6)}');
//     debugPrint(
//         '📍 الوجهة: ${destination.latitude.toStringAsFixed(6)}, ${destination.longitude.toStringAsFixed(6)}');

//     setState(() {
//       _isLoadingRoute = true;
//       _apiStatus = 'جاري حساب المسار...';
//     });

//     debugPrint('🌐 جاري الحصول على الاتجاهات...');
//     await _getSimpleRoute(source, destination);

//     setState(() => _isLoadingRoute = false);

//     // Adjust camera with higher zoom if map is ready
//     if (_mapReady && _mapController != null && _routePoints.isNotEmpty) {
//       debugPrint('📷 جاري ضبط الكاميرا بمستوى تكبير أعلى...');
//       await Future.delayed(const Duration(milliseconds: 500));
//       _fitBounds();
//     }

//     debugPrint('═══════════════════════════════════════');
//     debugPrint('✅ ROUTE CALCULATION COMPLETE');
//     debugPrint('═══════════════════════════════════════');
//     debugPrint('');
//   }

//   Future<void> _getSimpleRoute(LatLng origin, LatLng destination) async {
//     // Calculate distance and time
//     final distance = _calculateDistance(origin, destination);
//     final time = _estimateTime(distance);

//     debugPrint('📏 المسافة: ${distance.toStringAsFixed(2)} كم');
//     debugPrint('⏱️ الوقت المقدر: $time دقيقة');

//     setState(() {
//       _routeDistance = '${distance.toStringAsFixed(1)} كم';
//       _routeDuration = '~$time دقيقة';
//       _apiStatus = 'مسار مباشر';
//       _hasRoute = true;
//     });

//     // Create a simple route with 3 points: origin, middle point, destination
//     // This creates a slightly curved line for better visualization
//     final middlePoint = LatLng(
//       (origin.latitude + destination.latitude) / 2 + 0.001,
//       (origin.longitude + destination.longitude) / 2 + 0.001,
//     );

//     // Create 10 points for the route using quadratic bezier curve
//     final points = <LatLng>[];
//     const steps = 10;

//     for (int i = 0; i <= steps; i++) {
//       final t = i / steps;
//       final lat = _bezier(
//           origin.latitude, destination.latitude, middlePoint.latitude, t);
//       final lng = _bezier(
//           origin.longitude, destination.longitude, middlePoint.longitude, t);
//       points.add(LatLng(lat, lng));
//     }

//     debugPrint('🎨 جاري رسم المسار البسيط بـ ${points.length} نقطة');
//     _drawRoute(points);
//   }

//   double _bezier(double p0, double p2, double p1, double t) {
//     // Quadratic bezier curve: (1-t)²P0 + 2(1-t)tP1 + t²P2
//     final mt = 1 - t;
//     return mt * mt * p0 + 2 * mt * t * p1 + t * t * p2;
//   }

//   void _drawRoute(List<LatLng> points) {
//     debugPrint('🎨 جاري رسم المسار بـ ${points.length} نقطة');

//     _routePoints = List.from(points);
//     _polylineCounter++;

//     _polylines.clear();

//     // Single clean route line
//     final routeId = PolylineId('route_$_polylineCounter');
//     _polylines[routeId] = Polyline(
//       polylineId: routeId,
//       points: points,
//       color: const Color(0xFF4285F4), // Google Blue
//       width: 5,
//       startCap: Cap.roundCap,
//       endCap: Cap.roundCap,
//       jointType: JointType.round,
//       geodesic: false, // Straight lines between points
//       zIndex: 1,
//     );

//     setState(() {});

//     debugPrint('✅ تم إنشاء خط واحد فقط');
//     debugPrint('📊 معرّف الخط: ${_polylines.keys.first.value}');
//   }

//   double _calculateDistance(LatLng p1, LatLng p2) {
//     const R = 6371.0;
//     final lat1 = p1.latitude * pi / 180;
//     final lon1 = p1.longitude * pi / 180;
//     final lat2 = p2.latitude * pi / 180;
//     final lon2 = p2.longitude * pi / 180;

//     final dlat = lat2 - lat1;
//     final dlon = lon2 - lon1;

//     final a = sin(dlat / 2) * sin(dlat / 2) +
//         cos(lat1) * cos(lat2) * sin(dlon / 2) * sin(dlon / 2);

//     return R * 2 * atan2(sqrt(a), sqrt(1 - a));
//   }

//   int _estimateTime(double km) => ((km / 40.0) * 60).ceil().clamp(5, 120);

//   void _fitBounds() {
//     if (_routePoints.isEmpty || _mapController == null) return;

//     // Include both source and destination
//     final allPoints = <LatLng>[
//       if (_currentLatitude != 0 && _currentLongitude != 0)
//         LatLng(_currentLatitude, _currentLongitude),
//       if (widget.latitude.isNotEmpty && widget.longitude.isNotEmpty)
//         LatLng(double.parse(widget.latitude), double.parse(widget.longitude)),
//     ];

//     if (allPoints.length < 2) return;

//     double minLat = allPoints.first.latitude;
//     double maxLat = allPoints.first.latitude;
//     double minLng = allPoints.first.longitude;
//     double maxLng = allPoints.first.longitude;

//     for (final p in allPoints) {
//       minLat = min(minLat, p.latitude);
//       maxLat = max(maxLat, p.latitude);
//       minLng = min(minLng, p.longitude);
//       maxLng = max(maxLng, p.longitude);
//     }

//     // Calculate center point
//     final center = LatLng(
//       (minLat + maxLat) / 2,
//       (minLng + maxLng) / 2,
//     );

//     // Calculate distance between points
//     final distance =
//         _calculateDistance(LatLng(minLat, minLng), LatLng(maxLat, maxLng));

//     // Determine zoom level based on distance
//     double zoomLevel = 16.0; // Default high zoom

//     if (distance > 2.0) zoomLevel = 15.0;
//     if (distance > 5.0) zoomLevel = 14.0;
//     if (distance > 10.0) zoomLevel = 13.0;
//     if (distance > 20.0) zoomLevel = 12.0;

//     debugPrint('📊 المسافة بين النقاط: ${distance.toStringAsFixed(2)} كم');
//     debugPrint('📷 مستوى التكبير: $zoomLevel');

//     // Animate camera to show both points with calculated zoom
//     _mapController!.animateCamera(
//       CameraUpdate.newLatLngZoom(center, zoomLevel),
//     );

//     debugPrint('📷 تم ضبط الكاميرا بمستوى تكبير عالي ($zoomLevel)');
//   }

//   void _onMapCreated(GoogleMapController controller) {
//     _mapController = controller;
//     setState(() => _mapReady = true);
//     debugPrint('✅ الخريطة جاهزة');

//     // If we have location, calculate route
//     if (_currentLatitude != 0.0 && _currentLongitude != 0.0) {
//       Future.delayed(const Duration(milliseconds: 1500), () {
//         if (mounted && !_hasRoute) {
//           debugPrint('🎯 الخريطة جاهزة - جاري حساب المسار');
//           _calculateAndDrawRoute();
//         }
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     final isPortrait = screenHeight > screenWidth;

//     _calculateInfoCardWidth();

//     double cardWidth = screenWidth < 600
//         ? screenWidth * 0.92
//         : min(_infoCardWidth, screenWidth * 0.6);
//     cardWidth = max(cardWidth, _infoCardMinWidth);

//     return Scaffold(
//       appBar: AppBar(
//           backgroundColor: Colors.white,
//           centerTitle: true,
//           iconTheme: const IconThemeData(
//             color: Colors.white,
//           ),
//           title: _buildAppBar()),
//       backgroundColor: Colors.white,
//       body: Stack(
//         children: [
//           GoogleMap(
//             onMapCreated: _onMapCreated,
//             initialCameraPosition: const CameraPosition(
//               target: _alexandriaCoordinates,
//               zoom: 13, // Higher initial zoom
//               tilt: 0,
//               bearing: 0,
//             ),
//             markers: Set.of(_markers.values),
//             polylines: Set.of(_polylines.values),
//             zoomControlsEnabled: false,
//             myLocationButtonEnabled: false,
//             myLocationEnabled: false,
//             tiltGesturesEnabled: false,
//             buildingsEnabled: true,
//             indoorViewEnabled: false,
//             trafficEnabled: false,
//             mapToolbarEnabled: false,
//             rotateGesturesEnabled: false,
//             scrollGesturesEnabled: true,
//             zoomGesturesEnabled: true,
//             compassEnabled: true,
//             mapType: MapType.normal,
//           ),

//           // Custom App Bar
//           // Positioned(
//           //   top: MediaQuery.of(context).padding.top,
//           //   left: 0,
//           //   right: 0,
//           //   child: _buildAppBar(),
//           // ),

//           // Info Card
//           Positioned(
//             top: MediaQuery.of(context).padding.top + 70,
//             left: 20,
//             // right: 20,
//             child: Center(
//               child: _buildInfoCard(cardWidth),
//             ),
//           ),

//           // Loading Overlay
//           if (_isLoadingRoute) _buildLoadingOverlay(),

//           // Control Buttons
//           _buildControlButtons(isPortrait),
//         ],
//       ),
//     );
//   }

//   Widget _buildAppBar() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           // IconButton(
//           //   onPressed: () {
//           //     Navigator.of(context).pop();
//           //   },
//           //   icon: const Icon(Icons.arrow_back, color: Colors.blue),
//           // ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Row(
//               // crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   widget.technicianName,
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.blue,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const Text(
//                   ' : تتبع الفني',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.blue,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: _isPulsing
//                     ? [Colors.green, Colors.lightGreen]
//                     : [Colors.blue, Colors.lightBlue],
//               ),
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
//                 Text(
//                   _isPulsing ? 'مباشر' : 'جاري التتبع',
//                   style: const TextStyle(
//                     fontSize: 12,
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoCard(double width) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       width: width,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.15),
//             blurRadius: 20,
//             offset: const Offset(0, 10),
//           ),
//         ],
//         border: Border.all(color: Colors.grey.shade200, width: 1),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Address section
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.blue.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: const Icon(Icons.location_pin,
//                     color: Colors.blue, size: 20),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'الوجهة',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey,
//                       ),
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       widget.address,
//                       style: const TextStyle(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.black87,
//                       ),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),

//           // Stats section
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.grey[50],
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 _buildStatItem(
//                     Icons.directions, _routeDistance, 'المسافة', Colors.blue),
//                 Container(
//                   width: 1,
//                   height: 30,
//                   color: Colors.grey[300],
//                 ),
//                 _buildStatItem(
//                     Icons.timer, _routeDuration, 'الوقت', Colors.green),
//                 Container(
//                   width: 1,
//                   height: 30,
//                   color: Colors.grey[300],
//                 ),
//                 _buildStatItem(
//                     _getStatusIcon(), _apiStatus, 'الحالة', _getStatusColor()),
//               ],
//             ),
//           ),

//           // Last update time
//           if (_lastLocationUpdateTime != null)
//             Padding(
//               padding: const EdgeInsets.only(top: 12),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(
//                     Icons.update,
//                     size: 12,
//                     color: Colors.grey,
//                   ),
//                   const SizedBox(width: 4),
//                   Text(
//                     'آخر تحديث: ${_formatTime(_lastLocationUpdateTime!)}',
//                     style: TextStyle(
//                       fontSize: 10,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatItem(
//       IconData icon, String value, String label, Color color) {
//     return Expanded(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 18, color: color),
//           const SizedBox(height: 4),
//           Text(
//             value,
//             style: const TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//             textAlign: TextAlign.center,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 10,
//               color: Colors.grey[600],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   IconData _getStatusIcon() {
//     switch (_apiStatus) {
//       case 'مسار فعلي':
//         return Icons.check_circle;
//       case 'مسار مباشر':
//         return Icons.arrow_forward;
//       case 'جاري حساب المسار...':
//         return Icons.refresh;
//       case 'جاهز':
//         return Icons.schedule;
//       default:
//         return Icons.info_outline;
//     }
//   }

//   Color _getStatusColor() {
//     switch (_apiStatus) {
//       case 'مسار فعلي':
//         return Colors.green;
//       case 'مسار مباشر':
//         return Colors.orange;
//       case 'جاري حساب المسار...':
//         return Colors.blue;
//       case 'جاهز':
//         return Colors.grey;
//       default:
//         return Colors.red;
//     }
//   }

//   Widget _buildLoadingOverlay() {
//     return Container(
//       color: Colors.black.withOpacity(0.4),
//       child: Center(
//         child: Container(
//           width: 160,
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.2),
//                 blurRadius: 30,
//                 offset: const Offset(0, 10),
//               ),
//             ],
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               SizedBox(
//                 width: 40,
//                 height: 40,
//                 child: CircularProgressIndicator(
//                   color: Colors.blue,
//                   strokeWidth: 3,
//                   backgroundColor: Colors.blue.shade100,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 'جاري حساب المسار',
//                 style: TextStyle(
//                   color: Colors.black87,
//                   fontWeight: FontWeight.w600,
//                   fontSize: 14,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 _routePoints.isNotEmpty ? '${_routePoints.length} نقطة' : '',
//                 style: const TextStyle(
//                   color: Colors.grey,
//                   fontSize: 12,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildControlButtons(bool isPortrait) {
//     return Positioned(
//       bottom: isPortrait ? 100 : 20,
//       right: 20,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Refresh button
//           FloatingActionButton(
//             onPressed: () {
//               debugPrint('');
//               debugPrint('🔄 MANUAL REFRESH TRIGGERED');
//               debugPrint('');
//               _getCurrentLocation();
//             },
//             backgroundColor: Colors.orange,
//             foregroundColor: Colors.white,
//             elevation: 4,
//             heroTag: 'refreshButton',
//             child: const Icon(Icons.refresh, size: 24),
//           ),
//           const SizedBox(height: 12),

//           // Zoom to fit button
//           FloatingActionButton.small(
//             onPressed: _fitBounds,
//             backgroundColor: Colors.blue,
//             foregroundColor: Colors.white,
//             elevation: 4,
//             heroTag: 'zoomButton',
//             child: const Icon(Icons.zoom_out_map, size: 20),
//           ),
//           const SizedBox(height: 12),

//           // My location button
//           if (_currentLatitude != 0 && _currentLongitude != 0)
//             FloatingActionButton.small(
//               onPressed: () {
//                 if (_mapController != null) {
//                   _mapController!.animateCamera(
//                     CameraUpdate.newLatLngZoom(
//                       LatLng(_currentLatitude, _currentLongitude),
//                       18, // Very high zoom level
//                     ),
//                   );
//                 }
//               },
//               backgroundColor: Colors.red,
//               foregroundColor: Colors.white,
//               elevation: 4,
//               heroTag: 'locationButton',
//               child: const Icon(Icons.my_location, size: 20),
//             ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
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
  Timer? _locationTimer;
  Timer? _pulseTimer;
  Timer? _simulationTimer;
  GoogleMapController? _mapController;
  final http.Client _httpClient = http.Client();

  static const LatLng _alexandriaCoordinates = LatLng(31.205753, 29.924526);
  double _currentLatitude = 0.0;
  double _currentLongitude = 0.0;
  double _startLatitude = 0.0;
  double _startLongitude = 0.0;

  final Map<MarkerId, Marker> _markers = {};
  final Map<PolylineId, Polyline> _polylines = {};
  BitmapDescriptor? _destinationIcon;
  BitmapDescriptor? _technicianIcon;

  String _routeDistance = 'جاري الحساب...';
  String _routeDuration = 'جاري الحساب...';
  String _apiStatus = 'جاهز';
  bool _isLoadingRoute = false;
  bool _isPulsing = false;
  bool _mapReady = false;
  bool _hasRoute = false;

  List<LatLng> _routePoints = [];
  int _polylineCounter = 0;

  double _infoCardWidth = 400;
  static const double _infoCardMaxWidth = 500;
  static const double _infoCardMinWidth = 300;

  static const String _googleMapsApiKey =
      'AIzaSyDRaJJnyvmDSU8OgI8M20C5nmwHNc_AMvk';
  static const Duration _locationUpdateInterval = Duration(seconds: 30);

  DateTime? _lastLocationUpdateTime;

  // Simulation variables
  List<LatLng> _simulatedRoute = [];
  int _simulationIndex = 0;
  bool _isSimulating = false;
  double _simulationProgress = 0.0;
  LatLng? _simulatedPosition;

  @override
  void initState() {
    super.initState();
    debugPrint('🚀 Tracking widget initialized');
    _initializeTracking();
  }

  // @override
  // void dispose() {
  //   debugPrint('🛑 Disposing tracking widget');
  //   _locationTimer?.cancel();
  //   _pulseTimer?.cancel();
  //   _simulationTimer?.cancel();
  //   _httpClient.close();
  //   _mapController?.dispose();
  //   super.dispose();
  // }
@override
  void dispose() {
    debugPrint('🛑 Disposing tracking widget');

    // Cancel all timers
    _locationTimer?.cancel();
    _pulseTimer?.cancel();
    _simulationTimer?.cancel();

    // Close HTTP client
    _httpClient.close();

    // Workaround for Google Maps Web plugin bug
    // Don't dispose the controller on web to avoid the assertion error
    try {
      if (_mapController != null) {
        // For web platform, we need to handle this differently
        // due to a bug in google_maps_flutter_web
        if (!kIsWeb) {
          // Only dispose on mobile platforms
          _mapController!.dispose();
        }
        _mapController = null;
      }
    } catch (error) {
      debugPrint('⚠️ Error during map controller cleanup: $error');
      // Ignore the error and continue with disposal
    }

    super.dispose();
  }

  Future<void> _initializeTracking() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateInfoCardWidth();
    });

    await _loadCustomMarkers();
    _startPulseAnimation();

    // Get initial location with delay to ensure everything is ready
    await Future.delayed(const Duration(milliseconds: 500));
    await _getCurrentLocation();

    _startLocationTracking();
  }

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

  Future<void> _loadCustomMarkers() async {
    try {
      // Destination marker (green pin)
      _destinationIcon = await _createDestinationMarker();
      debugPrint('✅ Destination marker loaded');
    } catch (error) {
      debugPrint('⚠️ Error loading destination marker: $error');
      _destinationIcon =
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    }

    try {
      // Technician marker (red with person)
      // _technicianIcon = await _createTechnicianMarker();
       _technicianIcon =
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      debugPrint('✅ Technician marker created');
    } catch (error) {
      debugPrint('⚠️ Error creating technician marker: $error');
      _technicianIcon =
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }
  }


  Future<BitmapDescriptor> _createDestinationMarker() async {
    const size = 48.0;
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    // Draw pin shape
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    // Pin body (rounded rectangle)
    final rRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(0, 0, size * 0.6, size * 0.8),
      const Radius.circular(10),
    );
    canvas.drawRRect(rRect, paint);

    // Pin head (circle)
    canvas.drawCircle(
      const Offset(size * 0.3, size * 0.8),
      size * 0.12,
      paint,
    );

    // White dot in center
    canvas.drawCircle(
      const Offset(size * 0.3, size * 0.3),
      size * 0.08,
      Paint()..color = Colors.white,
    );

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  Future<BitmapDescriptor> _createTechnicianMarker() async {
    const size = 48.0;
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    // Draw background circle with gradient
    final gradient = RadialGradient(
      center: Alignment.center,
      colors: [Colors.red.shade600, Colors.red],
      radius: 0.5,
    );

    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(
        center: const Offset(size / 2, size / 2),
        radius: size / 2,
      ));

    canvas.drawCircle(const Offset(size / 2, size / 2), size / 2, paint);

    // Draw white border
    canvas.drawCircle(
      const Offset(size / 2, size / 2),
      size / 2 - 2,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Draw person icon
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: const TextSpan(
        text: '👷',
        style: TextStyle(fontSize: 20),
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
          size / 2 - textPainter.width / 2, size / 2 - textPainter.height / 2),
    );

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  void _startPulseAnimation() {
    _pulseTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) setState(() => _isPulsing = !_isPulsing);
    });
  }

  void _startLocationTracking() {
    _locationTimer = Timer.periodic(_locationUpdateInterval, (timer) {
      debugPrint('🔄 Periodic location update');
      _getCurrentLocation();
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      debugPrint('📡 Fetching location from API...');

      final locationData =
          await DioNetworkRepos().getLocationByAddressAndTechnician(
        widget.address,
        widget.technicianName,
      );

      if (!mounted) {
        debugPrint('⚠️ Widget not mounted, aborting');
        return;
      }

      debugPrint('📦 API Response received');

      final newLat = _parseDouble(locationData['currentLatitude']);
      final newLng = _parseDouble(locationData['currentLongitude']);

      if (newLat == null || newLng == null) {
        debugPrint('❌ Invalid location data received');
        return;
      }

      // Initialize start location
      if (_startLatitude == 0.0 || _startLongitude == 0.0) {
        _startLatitude = _parseDouble(locationData['startLatitude']) ?? newLat;
        _startLongitude = _parseDouble(locationData['startLongitude']) ??
            newLng ??
            _parseDouble(widget.longitude) ??
            29.924526;
        debugPrint('📍 Start location initialized');
      }

      // Always update to simulate movement if not already simulating
      if (_currentLatitude == 0.0 ||
          _currentLongitude == 0.0 ||
          !_isSimulating) {
        debugPrint('📍 Location updated: $newLat, $newLng');

        setState(() {
          _currentLatitude = newLat;
          _currentLongitude = newLng;
          _lastLocationUpdateTime = DateTime.now();
        });

        await _updateMarkers();

        if (!_hasRoute) {
          await _calculateRealisticRoute();
        }
      }
    } catch (error, stackTrace) {
      debugPrint('❌ Error fetching location: $error');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        setState(() => _apiStatus = 'خطأ في جلب الموقع');
      }
    }
  }

  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Future<void> _updateMarkers() async {
    if (!mounted) return;

    final destLat = _parseDouble(widget.latitude);
    final destLng = _parseDouble(widget.longitude);

    if (destLat == null || destLng == null) {
      debugPrint('⚠️ Invalid destination coordinates');
      return;
    }

    debugPrint('🎯 Creating markers...');

    setState(() {
      _markers.clear();

      // Destination marker
      _markers[const MarkerId('destination')] = Marker(
        markerId: const MarkerId('destination'),
        position: LatLng(destLat, destLng),
        infoWindow: InfoWindow(
          title: '📍 الوجهة',
          snippet: 'العنوان: ${widget.address}',
        ),
        icon: _destinationIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        anchor: const Offset(0.5, 0.9),
        zIndex: 3,
        draggable: false,
        flat: true,
      );

      // Current location marker (use simulated position if simulating)
      LatLng technicianPosition;
      if (_isSimulating && _simulatedPosition != null) {
        technicianPosition = _simulatedPosition!;
      } else {
        technicianPosition = LatLng(_currentLatitude, _currentLongitude);
      }

      if (_currentLatitude != 0.0 && _currentLongitude != 0.0) {
        final updateTime = _lastLocationUpdateTime != null
            ? 'آخر تحديث: ${_formatTime(_lastLocationUpdateTime!)}'
            : 'جاري التحديث...';

        _markers[const MarkerId('technician')] = Marker(
          markerId: const MarkerId('technician'),
          position: technicianPosition,
          infoWindow: InfoWindow(
            title: '👷 ${widget.technicianName}',
            snippet: '$updateTime${_isSimulating ? ' | محاكاة' : ''}',
          ),
          icon: _technicianIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          anchor: const Offset(0.5, 0.5),
          rotation: _isPulsing ? 0 : 360,
          zIndex: 4,
          flat: true,
          consumeTapEvents: true,
        );
      }
    });

    debugPrint('✅ Created ${_markers.length} markers');
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
      return 'منذ ${difference.inSeconds} ثانية';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else {
      return time.toString().substring(0, 16);
    }
  }

  Future<void> _calculateRealisticRoute() async {
    debugPrint('');
    debugPrint('═══════════════════════════════════════');
    debugPrint('🔄 CALCULATING REALISTIC ROUTE');
    debugPrint('═══════════════════════════════════════');

    if (_currentLatitude == 0.0 || _currentLongitude == 0.0) {
      debugPrint('❌ ABORT: Current location is 0,0');
      return;
    }

    final destLat = _parseDouble(widget.latitude);
    final destLng = _parseDouble(widget.longitude);

    if (destLat == null || destLng == null) {
      debugPrint('❌ ABORT: Destination is invalid');
      return;
    }

    final source = LatLng(_currentLatitude, _currentLongitude);
    final destination = LatLng(destLat, destLng);

    debugPrint(
        '📍 المصدر: ${source.latitude.toStringAsFixed(6)}, ${source.longitude.toStringAsFixed(6)}');
    debugPrint(
        '📍 الوجهة: ${destination.latitude.toStringAsFixed(6)}, ${destination.longitude.toStringAsFixed(6)}');

    setState(() {
      _isLoadingRoute = true;
      _apiStatus = 'جاري حساب المسار...';
    });

    debugPrint('🌐 جاري إنشاء مسار واقعي...');

    // Calculate realistic route
    await _createRealisticRoute(source, destination);

    setState(() => _isLoadingRoute = false);

    if (_mapReady && _mapController != null && _routePoints.isNotEmpty) {
      debugPrint('📷 جاري ضبط الكاميرا لعرض المسار...');
      await Future.delayed(const Duration(milliseconds: 500));
      _fitBounds();
    }

    debugPrint('═══════════════════════════════════════');
    debugPrint('✅ ROUTE CALCULATION COMPLETE');
    debugPrint('═══════════════════════════════════════');
    debugPrint('');
  }

  Future<void> _createRealisticRoute(LatLng origin, LatLng destination) async {
    try {
      // Calculate actual distance
      final distance = _calculateDistance(origin, destination);

      // Generate a realistic street-like path
      _routePoints = _generateAlexandriaStreetPath(origin, destination);
      _simulatedRoute = List.from(_routePoints); // Copy for simulation

      // Calculate realistic time based on Alexandria traffic (average 30 km/h)
      final estimatedMinutes = ((distance / 30.0) * 60).ceil();
      final estimatedTime = '$estimatedMinutes دقيقة';

      setState(() {
        _routeDistance = '${distance.toStringAsFixed(1)} كم';
        _routeDuration = estimatedTime;
        _apiStatus = 'مسار مباشر';
        _hasRoute = true;
      });

      debugPrint('📏 المسافة: ${distance.toStringAsFixed(1)} كم');
      debugPrint('⏱️ الوقت المقدر: $estimatedTime');
      debugPrint('📍 عدد نقاط المسار: ${_routePoints.length}');

      // Draw the realistic route
      _drawRealisticRoute(_routePoints);
    } catch (error, stackTrace) {
      debugPrint('❌ خطأ في حساب المسار: $error');
      debugPrint('Stack trace: $stackTrace');

      // Fallback
      final distance = _calculateDistance(origin, destination);
      final time = _estimateTime(distance);

      setState(() {
        _routeDistance = '${distance.toStringAsFixed(1)} كم';
        _routeDuration = '~$time دقيقة';
        _apiStatus = 'مسار مباشر';
        _hasRoute = true;
      });

      _routePoints = [origin, destination];
      _simulatedRoute = List.from(_routePoints);
      _drawRealisticRoute(_routePoints);
    }
  }

  List<LatLng> _generateAlexandriaStreetPath(LatLng start, LatLng end) {
    final List<LatLng> points = [];

    // Add starting point (current technician location)
    points.add(start);

    // Calculate intermediate points for a realistic Alexandria street route
    // These points simulate common Alexandria streets and turns

    // Point 1: Initial turn
    final point1 = LatLng(
      start.latitude + (end.latitude - start.latitude) * 0.2,
      start.longitude + (end.longitude - start.longitude) * 0.2,
    );
    points.add(LatLng(point1.latitude + 0.001, point1.longitude - 0.0005));
    points.add(point1);

    // Point 2: Street curve
    final point2 = LatLng(
      start.latitude + (end.latitude - start.latitude) * 0.4,
      start.longitude + (end.longitude - start.longitude) * 0.4,
    );
    points.add(LatLng(point2.latitude - 0.0005, point2.longitude + 0.001));
    points.add(point2);
    points.add(LatLng(point2.latitude + 0.0005, point2.longitude));

    // Point 3: Another turn
    final point3 = LatLng(
      start.latitude + (end.latitude - start.latitude) * 0.6,
      start.longitude + (end.longitude - start.longitude) * 0.6,
    );
    points.add(LatLng(point3.latitude, point3.longitude - 0.0008));
    points.add(point3);
    points.add(LatLng(point3.latitude - 0.001, point3.longitude + 0.0005));

    // Point 4: Final approach
    final point4 = LatLng(
      start.latitude + (end.latitude - start.latitude) * 0.8,
      start.longitude + (end.longitude - start.longitude) * 0.8,
    );
    points.add(LatLng(point4.latitude + 0.0007, point4.longitude));
    points.add(point4);
    points.add(LatLng(point4.latitude, point4.longitude + 0.0007));

    // Add ending point (destination)
    points.add(end);

    return points;
  }

  void _drawRealisticRoute(List<LatLng> points) {
    debugPrint('🎨 جاري رسم مسار واقعي بـ ${points.length} نقطة');

    _polylineCounter++;
    _polylines.clear();

    if (points.length < 2) {
      debugPrint('⚠️ نقاط غير كافية للرسم');
      return;
    }

    try {
      // Main realistic street route (Google Maps blue)
      final routeId = PolylineId('real_street_route_$_polylineCounter');

      _polylines[routeId] = Polyline(
        polylineId: routeId,
        points: points,
        color: const Color(0xFF4285F4), // Google Maps blue
        width: 6,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
        geodesic: false, // Follows street curves
        consumeTapEvents: true,
        zIndex: 2,
      );

      // Add a subtle white outline for better visibility
      final outlineId = PolylineId('outline_$_polylineCounter');
      _polylines[outlineId] = Polyline(
        polylineId: outlineId,
        points: points,
        color: Colors.white,
        width: 8,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
        geodesic: false,
        zIndex: 1,
      );

      setState(() {});
      debugPrint('✅ تم إنشاء مسار واقعي يتبع شوارع الإسكندرية');
    } catch (error, stackTrace) {
      debugPrint('❌ خطأ في رسم المسار: $error');
      debugPrint('Stack trace: $stackTrace');
    }
  }
void _startSimulation() {
    if (_simulatedRoute.isEmpty) {
      debugPrint('❌ لا يوجد مسار للمحاكاة');
      return;
    }

    _simulationTimer?.cancel();
    _simulationIndex = 0;
    _simulationProgress = 0.0;
    _isSimulating = true;

    debugPrint('▶️ بدء محاكاة حركة الفني');

    _simulationTimer =
        Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_simulationIndex < _simulatedRoute.length) {
        setState(() {
          _simulatedPosition = _simulatedRoute[_simulationIndex];
          _simulationProgress =
              (_simulationIndex / _simulatedRoute.length) * 100;
          _simulationIndex++;

          // Update distance and time during simulation
          final remainingDistance = _calculateDistance(
            _simulatedPosition!,
            LatLng(
                double.parse(widget.latitude), double.parse(widget.longitude)),
          );
          final remainingTime = ((remainingDistance / 30.0) * 60).ceil();

          _routeDistance = '${remainingDistance.toStringAsFixed(1)} كم متبقي';
          _routeDuration = '~$remainingTime دقيقة';
        });

        // Update markers with new position
        _updateMarkers();

        // Follow the technician during simulation
        if (_mapController != null && mounted) {
          try {
            _mapController!.animateCamera(
              CameraUpdate.newLatLng(_simulatedPosition!),
            );
          } catch (error) {
            debugPrint('⚠️ Error animating camera: $error');
          }
        }
      } else {
        // Simulation complete
        timer.cancel();
        if (mounted) {
          _isSimulating = false;
          setState(() {
            _simulatedPosition = null;
            _simulationProgress = 100.0;
            _routeDistance = 'وصل إلى الوجهة';
            _routeDuration = '0 دقيقة';
            _apiStatus = 'تم الوصول';
          });
          _updateMarkers();
          debugPrint('✅ انتهت المحاكاة - الفني وصل إلى الوجهة');

          // Show completion message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('${widget.technicianName} وصل إلى ${widget.address}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    });
  }
  // void _startSimulation() {
  //   if (_simulatedRoute.isEmpty) {
  //     debugPrint('❌ لا يوجد مسار للمحاكاة');
  //     return;
  //   }

  //   _simulationTimer?.cancel();
  //   _simulationIndex = 0;
  //   _simulationProgress = 0.0;
  //   _isSimulating = true;

  //   debugPrint('▶️ بدء محاكاة حركة الفني');

  //   _simulationTimer =
  //       Timer.periodic(const Duration(milliseconds: 200), (timer) {
  //     if (_simulationIndex < _simulatedRoute.length) {
  //       setState(() {
  //         _simulatedPosition = _simulatedRoute[_simulationIndex];
  //         _simulationProgress =
  //             (_simulationIndex / _simulatedRoute.length) * 100;
  //         _simulationIndex++;

  //         // Update distance and time during simulation
  //         final remainingDistance = _calculateDistance(
  //           _simulatedPosition!,
  //           LatLng(
  //               double.parse(widget.latitude), double.parse(widget.longitude)),
  //         );
  //         final remainingTime = ((remainingDistance / 30.0) * 60).ceil();

  //         _routeDistance = '${remainingDistance.toStringAsFixed(1)} كم متبقي';
  //         _routeDuration = '~$remainingTime دقيقة';
  //       });

  //       // Update markers with new position
  //       _updateMarkers();

  //       // Follow the technician during simulation
  //       if (_mapController != null) {
  //         _mapController!.animateCamera(
  //           CameraUpdate.newLatLng(_simulatedPosition!),
  //         );
  //       }
  //     } else {
  //       // Simulation complete
  //       timer.cancel();
  //       _isSimulating = false;
  //       setState(() {
  //         _simulatedPosition = null;
  //         _simulationProgress = 100.0;
  //         _routeDistance = 'وصل إلى الوجهة';
  //         _routeDuration = '0 دقيقة';
  //         _apiStatus = 'تم الوصول';
  //       });
  //       _updateMarkers();
  //       debugPrint('✅ انتهت المحاكاة - الفني وصل إلى الوجهة');

  //       // Show completion message
  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content:
  //                 Text('${widget.technicianName} وصل إلى ${widget.address}'),
  //             backgroundColor: Colors.green,
  //             duration: const Duration(seconds: 3),
  //           ),
  //         );
  //       }
  //     }
  //   });
  // }

  void _stopSimulation() {
    _simulationTimer?.cancel();
    _isSimulating = false;
    _simulatedPosition = null;
    _updateMarkers();
    debugPrint('⏹️ توقفت المحاكاة');
  }

  void _resetSimulation() {
    _stopSimulation();
    _simulationIndex = 0;
    _simulationProgress = 0.0;
    setState(() {
      _routeDistance = '${_calculateDistance(
        LatLng(_currentLatitude, _currentLongitude),
        LatLng(double.parse(widget.latitude), double.parse(widget.longitude)),
      ).toStringAsFixed(1)} كم';
      _routeDuration = '~${_estimateTime(_calculateDistance(
        LatLng(_currentLatitude, _currentLongitude),
        LatLng(double.parse(widget.latitude), double.parse(widget.longitude)),
      ))} دقيقة';
      _apiStatus = 'مسار على شوارع الإسكندرية';
    });
    debugPrint('🔄 إعادة تعيين المحاكاة');
  }

  double _calculateDistance(LatLng p1, LatLng p2) {
    const R = 6371.0;
    final lat1 = p1.latitude * pi / 180;
    final lon1 = p1.longitude * pi / 180;
    final lat2 = p2.latitude * pi / 180;
    final lon2 = p2.longitude * pi / 180;

    final dlat = lat2 - lat1;
    final dlon = lon2 - lon1;

    final a = sin(dlat / 2) * sin(dlat / 2) +
        cos(lat1) * cos(lat2) * sin(dlon / 2) * sin(dlon / 2);

    return R * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  int _estimateTime(double km) => ((km / 30.0) * 60).ceil().clamp(5, 120);

  void _fitBounds() {
    if (_routePoints.isEmpty || _mapController == null) return;

    try {
      // Calculate bounds from all route points
      double minLat = _routePoints.first.latitude;
      double maxLat = _routePoints.first.latitude;
      double minLng = _routePoints.first.longitude;
      double maxLng = _routePoints.first.longitude;

      for (final point in _routePoints) {
        minLat = min(minLat, point.latitude);
        maxLat = max(maxLat, point.latitude);
        minLng = min(minLng, point.longitude);
        maxLng = max(maxLng, point.longitude);
      }

      // Add padding (15% of the range)
      final latPadding = (maxLat - minLat) * 0.15;
      final lngPadding = (maxLng - minLng) * 0.15;

      minLat -= latPadding;
      maxLat += latPadding;
      minLng -= lngPadding;
      maxLng += lngPadding;

      // Create bounds
      final bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );

      // Animate camera to show the entire route with padding
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 50),
      );

      debugPrint('📷 تم ضبط الكاميرا لعرض المسار الكامل');
    } catch (error) {
      debugPrint('❌ خطأ في ضبط الحدود: $error');

      // Fallback to simple view
      if (_currentLatitude != 0 && _currentLongitude != 0) {
        final destLat = _parseDouble(widget.latitude);
        final destLng = _parseDouble(widget.longitude);

        if (destLat != null && destLng != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(
                (_currentLatitude + destLat) / 2,
                (_currentLongitude + destLng) / 2,
              ),
              14,
            ),
          );
        }
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    setState(() => _mapReady = true);
    debugPrint('✅ الخريطة جاهزة');

    // If we have location, calculate route
    if (_currentLatitude != 0.0 && _currentLongitude != 0.0) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted && !_hasRoute) {
          debugPrint('🎯 الخريطة جاهزة - جاري حساب المسار');
          _calculateRealisticRoute();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isPortrait = screenHeight > screenWidth;
        final now = DateTime.now();


    _calculateInfoCardWidth();

    double cardWidth = screenWidth < 600
        ? screenWidth * 0.92
        : min(_infoCardWidth, screenWidth * 0.6);
    cardWidth = max(cardWidth, _infoCardMinWidth);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Stack(
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

 

          // Info Card
          Positioned(
            top: MediaQuery.of(context).padding.top + 70,
            left: 20,
            // right: 20,
            child: Center(
              child: _buildInfoCard(cardWidth),
            ),
          ),

          // Loading Overlay
          if (_isLoadingRoute) _buildLoadingOverlay(),

          // Control Buttons
          _buildControlButtons(isPortrait),

    
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


  Widget _buildInfoCard(double width) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Address section
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.location_pin,
                    color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'الوجهة',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.address,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
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
          const SizedBox(height: 16),

          // Stats section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(
                    Icons.directions, _routeDistance, 'المسافة', Colors.blue),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.grey[300],
                ),
                _buildStatItem(
                    Icons.timer, _routeDuration, 'الوقت', Colors.green),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.grey[300],
                ),
                _buildStatItem(
                    _getStatusIcon(), _apiStatus, 'الحالة', _getStatusColor()),
              ],
            ),
          ),

          // Last update time and simulation status
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isSimulating ? Icons.directions_car : Icons.update,
                  size: 12,
                  color: _isSimulating ? Colors.orange : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  _isSimulating
                      ? 'محاكاة جارية... ${_simulationProgress.toInt()}%'
                      : _lastLocationUpdateTime != null
                          ? 'آخر تحديث: ${_formatTime(_lastLocationUpdateTime!)}'
                          : 'جاري التحديث...',
                  style: TextStyle(
                    fontSize: 10,
                    color: _isSimulating ? Colors.orange : Colors.grey[600],
                    fontWeight:
                        _isSimulating ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

 

  IconData _getStatusIcon() {
    if (_apiStatus.contains('شوارع الإسكندرية')) {
      return Icons.directions_car;
    } else if (_apiStatus.contains('تم الوصول')) {
      return Icons.check_circle;
    } else if (_apiStatus.contains('مباشر')) {
      return Icons.arrow_forward;
    } else if (_apiStatus.contains('جاري حساب')) {
      return Icons.refresh;
    } else if (_apiStatus.contains('جاهز')) {
      return Icons.schedule;
    } else {
      return Icons.info_outline;
    }
  }

  Color _getStatusColor() {
    if (_apiStatus.contains('تم الوصول')) {
      return Colors.green;
    } else if (_apiStatus.contains('شوارع الإسكندرية')) {
      return Colors.blue;
    } else if (_apiStatus.contains('مباشر')) {
      return Colors.orange;
    } else if (_apiStatus.contains('جاري حساب')) {
      return Colors.blue;
    } else if (_apiStatus.contains('جاهز')) {
      return Colors.grey;
    } else {
      return Colors.red;
    }
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.4),
      child: Center(
        child: Container(
          width: 180,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  color: Colors.blue,
                  strokeWidth: 3,
                  backgroundColor: Colors.blue.shade100,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'جاري حساب المسار الفعلي',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'تتبع الفني على شوارع الإسكندرية',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButtons(bool isPortrait) {
    return Positioned(
      bottom: isPortrait ? (_isSimulating ? 150 : 100) : 20,
      right: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
        

          // Zoom to fit button
          FloatingActionButton.small(
            onPressed: _fitBounds,
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            elevation: 4,
            heroTag: 'zoomButton',
            tooltip: 'عرض المسار بالكامل',
            child: const Icon(Icons.zoom_out_map, size: 20),
          ),
          const SizedBox(height: 12),

          // Current location button
          if (_currentLatitude != 0 && _currentLongitude != 0)
            FloatingActionButton.small(
              onPressed: () {
                if (_mapController != null) {
                  LatLng target;
                  if (_isSimulating && _simulatedPosition != null) {
                    target = _simulatedPosition!;
                  } else {
                    target = LatLng(_currentLatitude, _currentLongitude);
                  }

                  _mapController!.animateCamera(
                    CameraUpdate.newLatLngZoom(target, 18),
                  );
                }
              },
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              elevation: 4,
              heroTag: 'locationButton',
              tooltip: 'تتبع الفني',
              child: const Icon(Icons.my_location, size: 20),
            ),
        ],
      ),
    );
  }
}
