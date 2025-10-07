// ignore_for_file: unused_field

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:emergency_room/network/remote/remote_network_repos.dart';

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
  Timer? _timer; // Timer for periodic fetching
  final Completer<GoogleMapController> _controller = Completer();
  LatLng alexandriaCoordinates = const LatLng(31.205753, 29.924526);
  double currentLatitude = 0.0;
  double currentLongitude = 0.0;
  BitmapDescriptor? pinLocationIcon;

  final Set<Marker> markers = {};
  final String googleMapsApiKey =
      "AIzaSyDRaJJnyvmDSU8OgI8M20C5nmwHNc_AMvk"; // Replace with your API key
  late Future getCurrentLocation;
  Polyline _addPolyline() {
    LatLng end =
        LatLng(double.parse(widget.latitude), double.parse(widget.longitude));
    LatLng current = LatLng(currentLatitude, currentLongitude);

    return Polyline(
      polylineId: const PolylineId('polyline'),
      points: [current, end],
      color: Colors.blue,
      width: 5,
    );
  }

  @override
  void initState() {
    super.initState();
    BitmapDescriptor.asset(
            const ImageConfiguration(
              size: Size(40, 40),
            ),
            'assets/green_marker.png')
        .then((onValue) {
      pinLocationIcon = onValue;
    });
    setState(() {
      _getCurrentLocation();
      _startFetchingLocation();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel periodic fetch and location update timer
    super.dispose();
  }

  /// current and start latitude and longitude.
  Future<void> _getCurrentLocation() async {
    log(widget.address);
    log(widget.technicianName);

    getCurrentLocation = DioNetworkRepos().getLocationByAddressAndTechnician(
        widget.address, widget.technicianName);

    getCurrentLocation.then((value) {
      log("print from ui: in Location Tracking $value");
      log("Address: ${value['address']}");
      log("Latitude: ${value['latitude']}");
      log("Longitude: ${value['longitude']}");
      log("Technical Name: ${value['technicalName']}");
      log("Start Latitude: ${value['startLatitude']}");
      log("Start Longitude: ${value['startLongitude']}");
      log("Current Latitude: ${value['currentLatitude']}");
      log("Current Longitude: ${value['currentLongitude']}");
      setState(() {
        currentLatitude = double.parse(value['currentLatitude']);
        currentLongitude = double.parse(value['currentLongitude']);
      });
    });
    // }
  }

  Future<void> _moveCamera() async {
    final GoogleMapController controller = await _controller.future;
    CameraPosition cameraPosition = CameraPosition(
      target: LatLng(currentLatitude, currentLongitude),
      zoom: 14,
    );
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  //Function to start fetching updated location
  void _startFetchingLocation() {
    const updateInterval = Duration(minutes: 1);
    _timer = Timer.periodic(updateInterval, (Timer timer) {
      _getCurrentLocation();
      _moveCamera(); // Move camera to the updated location
    });
  }

  //draw polyline bet

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        elevation: 7,
        // backgroundColor: Colors.white,
        // iconTheme: const IconThemeData(color: Colors.indigo, size: 17),
        title: Text(
          'تتبع عنوان : ${widget.address}',
          style: const TextStyle(
            color: Colors.indigo,
          ),
        ),
      ),
      body: currentLatitude == 0.0 || currentLongitude == 0.0
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              initialCameraPosition: CameraPosition(
                target: alexandriaCoordinates,
                zoom: 13,
              ),
              markers: {
                Marker(
                    markerId: MarkerId(widget.address),
                    position: LatLng(double.parse(widget.latitude),
                        double.parse(widget.longitude)),
                    infoWindow: InfoWindow(
                        title: widget.address,
                        snippet: "${widget.latitude}, ${widget.longitude}"),
                    icon: pinLocationIcon!
                    // BitmapDescriptor.defaultMarkerWithHue(
                    //     BitmapDescriptor.hueGreen),
                    ),
                Marker(
                  markerId: const MarkerId("موقع الفنى الحالى"),
                  position: LatLng(currentLatitude, currentLongitude),
                  infoWindow: InfoWindow(
                      title: "موقع الفنى الحالى",
                      // title: widget.address,
                      snippet: "$currentLatitude, $currentLongitude"),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed),
                ),
              },
              polylines: {
                _addPolyline(),
              },
            ),
    );
  }
}

// // ignore_for_file: unused_field

// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'package:pick_location/network/remote/dio_network_repos.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart'; // Add this package

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
//   final Completer<GoogleMapController> _controller = Completer();
//   LatLng alexandriaCoordinates = const LatLng(31.205753, 29.924526);
//   double currentLatitude = 0.0;
//   double currentLongitude = 0.0;
//   double startLatitude = 0.0;
//   double startLongitude = 0.0;
//   final Set<Marker> markers = {};
//   final Set<Polyline> polylines = {};
//   final String googleMapsApiKey =
//       "AIzaSyDRaJJnyvmDSU8OgI8M20C5nmwHNc_AMvk"; // Replace with your API key
//   PolylinePoints polylinePoints = PolylinePoints(); // For decoding polyline

//   @override
//   void initState() {
//     super.initState();
//     _initializeTracking();
//   }

//   Future<void> _initializeTracking() async {
//     await _getCurrentLocation();
//     _startFetchingLocation();
//   }

//   Future<void> _getCurrentLocation() async {
//     try {
//       var value = await DioNetworkRepos().getLocationByAddressAndTechnician(
//           widget.address, widget.technicianName);

//       if (mounted) {
//         setState(() {
//           currentLatitude = double.parse(value['currentLatitude']);
//           currentLongitude = double.parse(value['currentLongitude']);
//           startLatitude = double.parse(value['startLatitude']);
//           startLongitude = double.parse(value['startLongitude']);
//         });
//         await _fetchRoute();
//       }
//     } catch (e) {
//       log("Error fetching location: $e");
//     }
//   }

//   Future<void> _fetchRoute() async {
//     try {
//       // Use your Spring Boot backend as the proxy server
//       String apiUrl =
//           'http://localhost:9999/api/directions?origin=$startLatitude,$startLongitude&destination=${widget.latitude},${widget.longitude}';
//       var response = await http.get(Uri.parse(apiUrl));

//       if (response.statusCode == 200) {
//         var data = jsonDecode(response.body);
//         if (data['status'] == 'OK') {
//           String encodedPolyline =
//               data['routes'][0]['overview_polyline']['points'];
//           List<LatLng> routePoints = _decodePolyline(encodedPolyline);

//           setState(() {
//             polylines.clear();
//             polylines.add(Polyline(
//               polylineId: const PolylineId('route'),
//               points: routePoints,
//               color: Colors.blue,
//               width: 5,
//             ));
//           });
//         } else {
//           log("Failed to fetch route: ${data['status']}");
//         }
//       } else {
//         log("Failed to fetch route: ${response.body}");
//       }
//     } catch (e) {
//       log("Error fetching route: $e");
//     }
//   }

//   List<LatLng> _decodePolyline(String encoded) {
//     List<PointLatLng> points = polylinePoints.decodePolyline(encoded);
//     return points
//         .map((point) => LatLng(point.latitude, point.longitude))
//         .toList();
//   }

//   void _startFetchingLocation() {
//     const updateInterval = Duration(minutes: 1);
//     _timer = Timer.periodic(updateInterval, (Timer timer) async {
//       await _getCurrentLocation();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: const IconThemeData(color: Colors.indigo),
//         centerTitle: true,
//         title: Text(
//           'تتبع عنوان : ${widget.address}',
//           style: const TextStyle(color: Colors.indigo),
//         ),
//       ),
//       body: GoogleMap(
//         onMapCreated: (GoogleMapController controller) {
//           _controller.complete(controller);
//         },
//         initialCameraPosition: CameraPosition(
//           target: alexandriaCoordinates,
//           zoom: 13,
//         ),
//         markers: {
//           Marker(
//             markerId: MarkerId(widget.address),
//             position: LatLng(
//                 double.parse(widget.latitude), double.parse(widget.longitude)),
//             infoWindow: InfoWindow(
//                 title: widget.address,
//                 snippet: "${widget.latitude}, ${widget.longitude}"),
//             icon:
//                 BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
//           ),
//           Marker(
//             markerId: const MarkerId("موقع الفنى الحالى"),
//             position: LatLng(currentLatitude, currentLongitude),
//             infoWindow: InfoWindow(
//                 title: "موقع الفنى الحالى",
//                 snippet: "$currentLatitude, $currentLongitude"),
//             icon: BitmapDescriptor.defaultMarkerWithHue(
//                 BitmapDescriptor.hueOrange),
//           ),
//         },
//         polylines: polylines,
//       ),
//     );
//   }
// }