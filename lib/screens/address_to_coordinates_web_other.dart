// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

// import '../custom_widget/custom_drawer.dart';
import '../network/remote/dio_network_repos.dart';

class AddressToCoordinatesOther extends StatefulWidget {
  const AddressToCoordinatesOther({super.key});

  @override
  AddressToCoordinatesOtherState createState() =>
      AddressToCoordinatesOtherState();
}

class AddressToCoordinatesOtherState extends State<AddressToCoordinatesOther> {
  final Completer<GoogleMapController> _controller = Completer();
  final TextEditingController addressController = TextEditingController();

  String coordinates = "";
  LatLng alexandriaCoordinates = const LatLng(31.205753, 29.924526);
  double latitude = 0.0, longitude = 0.0;
  var pickMarkers = HashSet<Marker>();
  late Future<List<Map<String, dynamic>>> getAllHotLineAddresses;
  bool isLoading = false;

  // Load this from secure storage or environment variables
  static const String googleMapsApiKey =
      "AIzaSyDRaJJnyvmDSU8OgI8M20C5nmwHNc_AMvk";
  @override
  void dispose() {
    addressController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      setState(() {
        getAllHotLineAddresses = _loadHotlineData();
      });
    } catch (e) {
      log("Error initializing app: $e");
      _showErrorSnackbar("Failed to initialize application");
    }
  }

  Future<List<Map<String, dynamic>>> _loadHotlineData() async {
    try {
      final token = await DioNetworkRepos().getHotLineTokenByUserAndPassword();
      return DioNetworkRepos().getHotLineData(token);
    } catch (e) {
      log("Error loading hotline data: $e");
      _showErrorSnackbar("Failed to load hotline data");
      return [];
    }
  }

  Future<void> _getCoordinatesFromAddress(String address) async {
    if (address.isEmpty) return;

    setState(() => isLoading = true);

    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?'
        'address=${Uri.encodeComponent(address)}&key=$googleMapsApiKey',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception("Failed to fetch data (${response.statusCode})");
      }

      final data = json.decode(response.body);

      if (data['results'].isEmpty) {
        throw Exception("No results found for this address");
      }

      final location = data['results'][0]['geometry']['location'];
      final lat = location['lat'] as double;
      final lng = location['lng'] as double;

      await _updateMapWithNewLocation(address, lat, lng);
      await _processGisData(address, lat, lng);

      // Refresh data after update
      setState(() {
        getAllHotLineAddresses = _loadHotlineData();
      });
    } catch (e) {
      _showErrorSnackbar("Error: ${e.toString()}");
      log("Error getting coordinates: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateMapWithNewLocation(
      String address, double lat, double lng) async {
    setState(() {
      coordinates = "Latitude: $lat, Longitude: $lng";
      latitude = lat;
      longitude = lng;

      pickMarkers.clear();
      pickMarkers.add(
        Marker(
          markerId: MarkerId(address),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
            title: address,
            snippet: coordinates,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      );
    });

    // Move camera to new location
    final controller = await _controller.future;
    await controller.animateCamera(
      CameraUpdate.newLatLng(LatLng(lat, lng)),
    );
  }

  Future<void> _processGisData(String address, double lat, double lng) async {
    try {
      final lastRecordNumber = await DioNetworkRepos().getLastRecordNumberWeb();
      final newRecordNumber = lastRecordNumber + 1;

      final mapLink = await DioNetworkRepos().createNewGisPointAndGetMapLink(
        newRecordNumber,
        lng.toString(),
        lat.toString(),
      );

      final addressExists = await DioNetworkRepos().checkAddressExists(address);

      if (addressExists) {
        await DioNetworkRepos().updateLocations(
          address,
          lng,
          lat,
          mapLink,
        );
      } else {
        await DioNetworkRepos().createNewLocation(
          address,
          lng,
          lat,
          mapLink,
        );
      }
    } catch (e) {
      log("Error processing GIS data: $e");
      rethrow;
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "شكاوى خارجية",
          style: TextStyle(color: Colors.indigo),
        ),
        centerTitle: true,
        elevation: 7,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Colors.indigo,
          size: 17,
        ),
        actions: [
          IconButton(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            tooltip: "تحديث شكاوى الخط الساخن",
            hoverColor: Colors.yellow,
            onPressed: () {
              _initializeApp();
            },
            icon: const Icon(
              Icons.refresh,
              color: Colors.indigo,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: alexandriaCoordinates,
              zoom: 10.4746,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            markers: pickMarkers,
            zoomControlsEnabled: true,
          ),
          if (isLoading) const Center(child: CircularProgressIndicator()),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          constraints: BoxConstraints(
                            maxHeight: 70,
                            minWidth: 200,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                          ),
                          hintText: "فضلا أدخل العنوان",
                          hintStyle: TextStyle(
                            color: Colors.indigo,
                            fontSize: 11,
                          ),
                        ),
                        controller: addressController,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.indigo,
                        ),
                        cursorColor: Colors.amber,
                        keyboardType: TextInputType.text,
                        maxLength: 250,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 17.0),
                      child: IconButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                if (addressController.text.isEmpty) {
                                  _showErrorSnackbar("فضلا أدخل العنوان");
                                  return;
                                }

                                await _getCoordinatesFromAddress(
                                    addressController.text);
                              },
                        icon: CircleAvatar(
                          backgroundColor:
                              isLoading ? Colors.grey : Colors.indigo,
                          radius: 20,
                          child: isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.search_outlined,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (coordinates.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      coordinates,
                      style: const TextStyle(
                        backgroundColor: Colors.white,
                        color: Colors.indigo,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      // drawer: CustomDrawer(
      //   title: 'الاعطال الواردة من الخط الساخن',
      //   getLocs: getAllHotLineAddresses,
      // ),
    );
  }
}
