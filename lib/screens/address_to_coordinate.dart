import 'dart:async';
import 'dart:collection';
import 'dart:developer';

// import 'package:pick_location/custom_widget/custom_drawer.dart';
import 'package:emergency_room/screens/draggable_scrollable_sheet_screen.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../custom_widget/custom_end_drawer.dart';
import '../network/remote/remote_network_repos.dart';

class AddressToCoordinates extends StatefulWidget {
  const AddressToCoordinates({super.key});

  @override
  AddressToCoordinatesState createState() => AddressToCoordinatesState();
}

class AddressToCoordinatesState extends State<AddressToCoordinates> {
  //declare vars
  final Completer<GoogleMapController> _controller = Completer();
  String address = "";
  String coordinates = "";
  String getAddress = "";
  LatLng alexandriaCoordinates = const LatLng(31.205753, 29.924526);
  double latitude = 0.0, longitude = 0.0;
  var pickMarkers = HashSet<Marker>();
  late Future getLocs; //get addresses from db(HotLine)
  late Future
      getLocsAfterGetCoordinatesAndGis; //get addresses from db(after getting coordinates and gis link)
  late Future getLocsByHandasahNameAndTechinicianName;
  final TextEditingController addressController = TextEditingController();
  late Future getHandasatItemsDropdownMenu;
  List<String> handasatItemsDropdownMenu = [];
  List<String> addHandasahToAddressList = [];

  @override
  void dispose() {
    // Dispose the controller when the widget is disposed
    addressController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      getLocs = DioNetworkRepos().getLoc();
      getLocsAfterGetCoordinatesAndGis =
          DioNetworkRepos().getLocByFlagAndIsFinished();
      getLocsByHandasahNameAndTechinicianName =
          DioNetworkRepos().getLocByHandasahAndTechnician("free", "free");
    });

    getLocs.then((value) => log("GET ALL HOTlINE LOCATIONS: $value"));

    getLocsByHandasahNameAndTechinicianName.then(
        (value) => log("NO HANDASAH AND TECHNICIAN ARE ASSIGNED: $value"));

    //get handasat items dropdown menu from db
    getHandasatItemsDropdownMenu =
        DioNetworkRepos().fetchHandasatItemsDropdownMenu();

    //load list
    getHandasatItemsDropdownMenu.then((value) {
      value.forEach((element) {
        element = element.toString();
        //add to list
        handasatItemsDropdownMenu.add(element);
      });
      //debug print
      log("handasatItemsDropdownMenu from UI: $handasatItemsDropdownMenu");
      log(value.toString());
    });

    // _getCoordinatesFromAddress(address); // Convert on startup

    // getLocs = DioNetworkRepos().getLoc();

    // getLocs.then((value) => log("FUTUTRE: $value[0].['address']"));

    // getLocs.then((value) {
    // if (value.isEmpty) {
    //   return Timer(
    //     const Duration(seconds: 10),
    //     () => getLocs = DioNetworkRepos().getLoc(),
    //   );
    // }
    //   value.forEach((element) {
    //     address = element['address'];
    //     _getCoordinatesFromAddress(address);
    //   });
    // }).catchError((e) {
    //   return e + "List is empty";
    // });

    // log(address);
  }

// Function to get latitude and longitude from an address using Google Geocoding API
  Future<void> _getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);

      setState(() {
        coordinates =
            "${locations.first.latitude}, ${locations.first.longitude}";
        latitude = locations.first.latitude; // latitude=y
        longitude = locations.first.longitude; // longitude=x

        //add marker
        pickMarkers.add(
          Marker(
            markerId: MarkerId(address),
            position: LatLng(latitude, longitude),
            infoWindow: InfoWindow(
              title: address,
              snippet: coordinates,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
          ),
        );
        //
        log(address);
        log(coordinates);
        log(longitude.toString());
        log(latitude.toString());

        //update locations after getting coordinates
        getLocs = DioNetworkRepos().getLoc();
        //update locations after getting coordinates and gis link
        getLocsAfterGetCoordinatesAndGis =
            DioNetworkRepos().getLocByFlagAndIsFinished();
        getLocsByHandasahNameAndTechinicianName =
            DioNetworkRepos().getLocByHandasahAndTechnician("free", "free");
      });

      //get last gis record from GIS server
      int lastRecordNumber = await DioNetworkRepos().getLastRecordNumber();
      log("lastRecordNumber :>> $lastRecordNumber");
      int newRecordNumber = lastRecordNumber + 1;
      log("newRecordNumber :>> $newRecordNumber");
      //
      //create new gis point
      String mapLink = await DioNetworkRepos().createNewGisPointAndGetMapLink(
        newRecordNumber,
        longitude.toString(),
        latitude.toString(),
      );
      log("gis_longitude :>> $longitude");
      log("gis_latitude :>> $latitude");
      log("GIS MAP LINK :>> $mapLink");

      // check if address already exist(UPDATED-IN-29-01-2025)
      var addressInList = await DioNetworkRepos().checkAddressExists(address);
      log("PRINTED DATA FROM UI:  ${await DioNetworkRepos().checkAddressExists(address)}");
      log("PRINTED BY USING VAR: $addressInList");
      // log("PRINTED BY USING STRING: $addressInListString");
      //
      //
      if (addressInList == true) {
        //  call the function to update locations in database
        log("address already exist >>>>>> $addressInList");

        //  call the function to update locations in database
        //update Locations list after getting coordinates and gis link
        await DioNetworkRepos().updateLocations(
          address,
          longitude,
          latitude,
          mapLink,
        );
        //
        log("updated Locations list after getting coordinates and gis link");
      } else {
        //  call the function to post locations in database
        log("address not exist >>>>>>>>> $addressInList");

        //  call the function to post locations in database
        await DioNetworkRepos().createNewLocation(
          address,
          longitude,
          latitude,
          mapLink,
        );
        //
        log("POSTED new Location In Locations list after getting coordinates and gis link");
      }

      //update Locations list after getting coordinates

      setState(() {
        getLocs = DioNetworkRepos().getLoc();
        //update locations after getting coordinates and gis link
        getLocsAfterGetCoordinatesAndGis =
            DioNetworkRepos().getLocByFlagAndIsFinished();
        getLocsByHandasahNameAndTechinicianName =
            DioNetworkRepos().getLocByHandasahAndTechnician("free", "free");
      });
    } catch (e) {
      setState(() {
        coordinates = "Error: Unable to get coordinates";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "تحويل العنوان الى إحداثيات",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 7,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.indigo, size: 17),
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
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
                      hintText: "فضلا أدخل النعنوان",
                      hintStyle: TextStyle(
                        color: Colors.indigo,
                        fontSize: 11,
                      ),
                    ),
                    controller:
                        addressController, // set the controller to get address input
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.indigo,
                    ),
                    cursorColor: Colors.amber,
                    keyboardType: TextInputType.text,
                    maxLength: 250,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 17.0,
                  ),
                  child: IconButton(
                    // constraints: const BoxConstraints.tightFor(
                    //   width: 20,
                    //   height: 50,
                    // ),
                    onPressed: () async {
                      if (addressController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text("فضلا أدخل العنوان"),
                            backgroundColor: Colors.indigo.shade300,
                          ),
                        );
                      }
                      setState(() {
                        pickMarkers.clear();
                        address = addressController.text;
                        _getCoordinatesFromAddress(address);
                        addressController.clear();
                        //update locations after getting coordinates
                        getLocs = DioNetworkRepos().getLoc();
                        //update locations after getting coordinates and gis link
                        getLocsAfterGetCoordinatesAndGis =
                            DioNetworkRepos().getLocByFlagAndIsFinished();
                        getLocsByHandasahNameAndTechinicianName =
                            DioNetworkRepos()
                                .getLocByHandasahAndTechnician("free", "free");
                      });
                    },
                    icon: const CircleAvatar(
                      backgroundColor: Colors.indigo,
                      radius: 20,
                      child: Icon(
                        Icons.search_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          //CustomDraggableSheet
          DraggableScrollableSheetScreen(
            getLocs: getLocsAfterGetCoordinatesAndGis,
          ), //call draggable sheet
          //CustomDraggableSheet
        ],
      ),
      // drawer: CustomDrawer(
      //   title: 'العناوين الواردة من الخط الساخن',
      //   getLocs: getLocs,
      // ),
      endDrawer: CustomEndDrawer(
        title: 'تخصيص الهندسة',
        getLocs: getLocsByHandasahNameAndTechinicianName,
        stringListItems: handasatItemsDropdownMenu,
        onPressed: () {
          //
          setState(() {
            getLocsByHandasahNameAndTechinicianName =
                DioNetworkRepos().getLocByHandasahAndTechnician("free", "free");
          });
        },
        hintText: 'فضلا أختار الهندسة',
        //(08-02-2025-not-working as expected)
        // onChanged: (value) {
        //   if (value != null) {
        //     log('Selected item: $value');
        //     //updateLocAddHandasah
        //     setState(() {
        //       DioNetworkRepos().updateLocAddHandasah(
        //         getAddress,
        //         value,
        //       );
        //     });
        //   }
        // },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        onPressed: () {
          // pickMarkers.clear();
          setState(() {
            getLocs = DioNetworkRepos().getLoc();
            //update locations after getting coordinates
            getLocsAfterGetCoordinatesAndGis =
                DioNetworkRepos().getLocByFlagAndIsFinished();
            getLocsByHandasahNameAndTechinicianName =
                DioNetworkRepos().getLocByHandasahAndTechnician("free", "free");
          });
        },
        mini: true,
        child: const Icon(
          Icons.refresh,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}

// Retrieve the copied text from the clipboard
// ClipboardData? data = await Clipboard.getData('text/plain');
// // Paste the text into the TextField
// if (data != null && data.text != null) {
//   log("Pasted text: ${data.text}");
// }
