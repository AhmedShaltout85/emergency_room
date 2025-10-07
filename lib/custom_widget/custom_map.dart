import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomMap extends StatefulWidget {
  final String address;
  final String coordinates;
  final LatLng alexandriaCoordinates;
  final double latitude;
  final double longitude;
  final HashSet<Marker> pickMarkers;

  const CustomMap(
      {super.key,
      required this.address,
      required this.coordinates,
      required this.alexandriaCoordinates,
      required this.latitude,
      required this.longitude,
      required this.pickMarkers});

  @override
  State<CustomMap> createState() => _CustomMapState();
}

class _CustomMapState extends State<CustomMap> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Google Map
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: widget.alexandriaCoordinates,
            zoom: 13.4746,
          ),
          onMapCreated: (GoogleMapController controller) {
            setState(
              () {
                widget.pickMarkers.add(
                  Marker(
                    markerId: MarkerId(widget.coordinates),
                    position: LatLng(widget.latitude, widget.longitude),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueGreen),
                    infoWindow: InfoWindow(
                        title: widget.address, snippet: widget.coordinates),
                  ),
                );
              },
            );
          },
          markers: widget.pickMarkers,
          zoomControlsEnabled: true,
        ),
      ],
    );
  }
}
