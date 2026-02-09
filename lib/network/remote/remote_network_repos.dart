import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';

import '../../utils/app_constants.dart';

class DioNetworkRepos {
  // Singleton
  DioNetworkRepos._internal();

  static final DioNetworkRepos _instance = DioNetworkRepos._internal();

  factory DioNetworkRepos() => _instance;
  //
  final dio = Dio();

//1-- GET locations(GET by flag 0 (address not set yet)--HOTLINE)
  Future getLoc() async {
    try {
      var response = await dio.get(urlGetHotlineAddress);
      if (response.statusCode == 200) {
        return response.data;
      } else {
        log('List is empty');
        return [];
        // throw Exception('List is empty');
      }
    } catch (e) {
      log(e.toString());
      // throw Exception(e);
    }
  }

//2-- GET locations(GET by flag 1 and isFinished 0)
  Future getLocByFlagAndIsFinished() async {
    try {
      var response = await dio.get(urlGetAllByFlagAndIsFinished);
      if (response.statusCode == 200) {
        return response.data;
      } else {
        log('List is empty');
        return [];
        // throw Exception('List is empty');
      }
    } catch (e) {
      log(e.toString());
      // throw Exception(e);
    }
  }

//3-- GET locationsBy handasah(GET by handasah (handasah) and  isFinished 0)
  Future getLocByHandasahAndIsFinished(String handasah, int isFinished) async {
    var urlGetAllByHandasahAndIsFinished =
        '$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/get-loc/handasah/$handasah/is-finished/$isFinished';
    try {
      var response = await dio.get(urlGetAllByHandasahAndIsFinished);
      if (response.statusCode == 200) {
        return response.data;
      } else {
        log('List is empty');
        return [];
        // throw Exception('List is empty');
      }
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

//4-- GET locations(GET by Handasah free and Technician free)

  Future getLocByHandasahAndTechnician(
      String handasah, String technician) async {
    var urlGetAllByHandasahAndTechnician =
        '$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/get-loc/handasah/$handasah/technical/$technician';

    try {
      var response = await dio.get(
        urlGetAllByHandasahAndTechnician,
        options: Options(
          validateStatus: (status) {
            return status! < 500; // Accept all status codes below 500
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else if (response.statusCode == 404) {
        log('No locations found for handasah: $handasah and technician: $technician');
        return []; // Return empty list for 404
      } else {
        log('Unexpected status code: ${response.statusCode}');
        return []; // Return empty list for other non-200 status codes
      }
    } catch (e) {
      log('Error fetching locations: $e');
      return []; // Return empty list on any other error
    }
  }

//5-- UPDATE locations(by longitude and latitude)
  Future updateLoc(String address, double longitude, double latitude) async {
    try {
      final response = await dio.put(
          "$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/get-loc/address/$address",
          data: {
            "longitude": longitude,
            "latitude": latitude,
            "flag": 1,
          });
      return response.data;
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

//6-- UPDATE locations By address (add handasahName)
  Future updateLocAddHandasah(String address, String? handasahName) async {
    try {
      final response = await dio.put(
          "$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/get-loc/handasah/$address",
          data: {
            "handasah_name": handasahName,
          });
      log(response.data.toString());

      return response.data;
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

//7-- UPDATE locations By address (add technicianName)
  Future updateLocAddTechnician(String address, String? technicianName) async {
    try {
      final response = await dio.put(
          "$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/get-loc/technical/$address",
          data: {
            "technical_name": technicianName,
          });
      log(response.data.toString());

      return response.data;
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

//8-- UPDATE locations By address (add isFinished)
  Future updateLocAddIsFinished(String address, int isFinished) async {
    try {
      final response = await dio.put(
          "$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/get-loc/is-finished/$address",
          data: {
            "is_finished": isFinished,
          });
      log(response.data.toString());

      return response.data;
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

//9-- UPDATE locations By address(wiht-url)
  Future<void> updateLocations(
      String address, double longitude, double latitude, String url) async {
    try {
      var response = await dio.put(
          "$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/get-loc/address/$address",
          data: {
            "longitude": longitude,
            "latitude": latitude,
            "flag": 1,
            "gis_url": url,
            "is_finished": 0,
            "is_approved": 0,
            "handasah_name": "free",
            "technical_name": "free",
            "broker_type": "لم يدرج نوع الكسر",
          });
      return response.data;
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  //10-- POST in GIS Server and GET MAP Link
  Future<String> createNewGisPointAndGetMapLink(
      int id, String longitude, String latitude) async {
    // Encode credentials to Base64
    final basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';
    try {
      final response = await dio.post(gisUrl,
          data: {
            "uid": id,
            "x": longitude,
            "y": latitude,
          },
          options: Options(
            headers: {
              'authorization': basicAuth,
            },
          ));
      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Failed to post data');
      }
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  //11-- GET USERNAME AND PASSWORD
  //Login User using username and password(working)
  Future<bool> loginByUsernameAndPassword(
      String username, String password) async {
    try {
      final response = await dio.get(
          "$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/users/$username/$password");
      if (response.statusCode == 200) {
        log("${response.data} from loginByUsernameAndPassword");
        final usernameResponse = response.data['username'];
        final passwordResponse = response.data['password'];
        StaticVariables.userRole = response.data['role'];
        StaticVariables.handasahName = response.data['handasah_name'];
        log('Login successful! Username: $usernameResponse, Password: $passwordResponse , ID: $StaticVariables.userRole');
        return true;
      } else {
        log('Login failed: ${response.data}');
        return false;
      }
    } on DioException catch (e) {
      log('Error: ${e.response?.data ?? e.message}');
      return false;
    } catch (e) {
      log('Unexpected error: $e');
      return false;
    }
  }

//12-- LOGIN User using username and password(working)
  Future<Map<String, dynamic>> login(String username, String password) async {
    // Replace with your API endpoint

    try {
      // Sending GET request with query parameters
      Response response = await dio.get(
          "$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/users/$username/$password");

      if (response.statusCode == 200) {
        // Assuming the API returns JSON data
        StaticVariables.userRole = response.data['role'];
        StaticVariables.handasahName = response.data['controlUnit'];
        StaticVariables.username = response.data['username'];
        // handasahName = response.data['controlUnit'];
        // userName = response.data['username'];
        log("PRINTED DATA FROM API: ${response.data['role']}");
        log("PRINTED DATA FROM API: ${response.data['controlUnit']}");
        log("PRINTED DATA FROM API: ${response.data['username']}");
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Invalid status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      // Handling Dio errors
      if (e is DioException) {
        return {
          'success': false,
          'message': e.response?.data['message'] ?? e.message,
        };
      } else {
        return {
          'success': false,
          'message': 'An unexpected error occurred',
        };
      }
    }
  }

  //13-- CHECK if address exists
  Future<bool> checkAddressExists(String address) async {
    String encodedAddress = Uri.encodeComponent(address);
    String getAddressUrl =
        '$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/get-loc/address/$encodedAddress';

    try {
      var response = await dio.get(getAddressUrl);

      if (response.statusCode == 200) {
        log("PRINTED DATA FROM API: ${response.data}");
        return true;
      } else {
        log('Address not found');
        return false;
      }
    } on DioException catch (e) {
      log("Dio error: ${e.response?.statusCode} - ${e.message}");
      return false;
    } catch (e) {
      log("Unexpected error: $e");
      return false;
    }
  }

  //14-- CHECK if address exists BY ADDRESS And HANDASAH
  Future<bool> checkAddressExistsByAddressAndHandasah(
      String address, String handasah) async {
    String encodedAddress = Uri.encodeComponent(address);
    String getAddressUrl =
        '$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/get-loc/flag/0/address/$encodedAddress/handasah/$handasah';

    try {
      var response = await dio.get(getAddressUrl);

      if (response.statusCode == 200) {
        log("PRINTED DATA FROM API: ${response.data}");
        return true;
      } else {
        log('Address not found');
        return false;
      }
    } on DioException catch (e) {
      log("Dio error: ${e.response?.statusCode} - ${e.message}");
      return false;
    } catch (e) {
      log("Unexpected error: $e");
      return false;
    }
  }

  //15-- POST locations(wiht-url)
  Future createNewLocation(
      String address, double longitude, double latitude, String url) async {
    try {
      var response = await dio.post(
          "$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/get-loc",
          data: {
            "address": address,
            "longitude": longitude,
            "latitude": latitude,
            "flag": 1,
            "gis_url": url,
            "is_finished": 0,
            "handasah_name": "free",
            "technical_name": "free",
            "caller_name": "لم يدرج",
            "caller_phone": "لم يدرج",
            "broker_type": "لم يدرج نوع الكسر",
            "video_call": 0
          });
      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Failed to post data');
      }
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

//16-- FETCH Data from the Database(GET dropdown items for handasat)
  Future fetchHandasatItemsDropdownMenu() async {
    var getHandasatUrl =
        '$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/handasah/all';
    try {
      var response = await dio.get(getHandasatUrl);
      if (response.statusCode == 200) {
        // log(dataList);
        log("PRINTED DATA FROM API:  ${response.data}");

        return response.data;
      } else {
        log('List is empty');
        return [];
      }
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  //17-- FETCH Data from the Database(GET dropdown items for handasat users)
  Future fetchHandasatUsersItemsDropdownMenu(String handasahName) async {
    var getHnadasatUsersUrl =
        '$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/users/role/3/control-unit/$handasahName';
    try {
      var response = await dio.get(getHnadasatUsersUrl);
      if (response.statusCode == 200) {
        // log(dataList);
        log("PRINTED DATA FROM API:  ${response.data}");

        return response.data;
      } else {
        log('List is empty');
        return [];
      }
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

//18-- FETCH Data from the Database(GET broken items for technicians users in handasat)

  Future<List<Map<String, dynamic>>> fetchHandasatUsersItemsBroken(
      String handasahName, String technicianName, int isFinished) async {
    var getHnadasatUsersListUrl =
        '$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/get-loc/handasah/$handasahName/technical/$technicianName/is-finished/$isFinished';
    try {
      var response = await dio.get(getHnadasatUsersListUrl);

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is List) {
          // If it's already a List, return it directly
          // log(dataList);
          log("PRINTED DATA FROM API:  ${[response.data]}");
          return List<Map<String, dynamic>>.from(response.data);
        } else if (response.data is Map<String, dynamic>) {
          // If it's a single Map, wrap it in a List
          return [response.data];
        } else {
          log("Unexpected response format: ${response.data}");
          return []; // Return an empty list if the format is unexpected
        }
      } else {
        log('List is empty');
        return [];
      }
    } catch (e) {
      log("API Error: $e");
      return []; // Return empty list on error
    }
  }

//19-- GET last record number from GIS server (broken-number-generator)
  Future<int> getLastRecordNumber() async {
    var getLastRecordUrl = 'http://196.219.231.3:8000/lab-api/lab-id';
    final basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';
    try {
      var response = await dio.get(
        getLastRecordUrl,
        data: {"category": "gis_lab_api"},
        options: Options(
          headers: {
            'authorization': basicAuth,
          },
        ),
      );
      if (response.statusCode == 201) {
        // log(dataList);
        log("PRINTED DATA FROM API:  ${response.data}");

        return response.data;
      } else {
        log('List is empty');
        return 0;
        // throw Exception('List is empty');
      }
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

//20-- GET last record number from GIS serverWEB (broken-number-generator)
  Future<int> getLastRecordNumberWeb() async {
    var getLastRecordUrlWeb = 'http://196.219.231.3:8000/lab-api/web-lab-id';
    final basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';
    try {
      var response = await dio.get(
        getLastRecordUrlWeb,
        // data: {"category": "gis_lab_api"},
        options: Options(
          headers: {
            'authorization': basicAuth,
          },
        ),
      );
      if (response.statusCode == 201) {
        // log(dataList);
        log("PRINTED DATA FROM API:  ${response.data}");

        return response.data;
      } else {
        log('List is empty');
        return 0;
        // throw Exception('List is empty');
      }
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  //21-- UPDATE locations By address (add isApproved)
  Future updateLocAddIsApproved(String address, int isApproved) async {
    try {
      final response = await dio.put(
          "$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/get-loc/is-approved/$address",
          data: {
            "is_approved": isApproved,
          });
      log(response.data.toString());

      return response.data;
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

//22-- POST locations for tracking (sendLocationToBackend)
  Future<void> sendLocationToBackend(
      String address,
      String technicianName,
      double latitude,
      double longitude,
      double? currentLatitude,
      double? currentLongitude) async {
    final response = await dio.post(
      '$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/track-location',
      data: {
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'technicalName': technicianName,
        'startLatitude': currentLatitude,
        'startLongitude': currentLongitude,
        'currentLatitude': currentLatitude,
        'currentLongitude': currentLongitude,
      },
    );

    if (response.statusCode == 200) {
      log('Location sent successfully');
    } else {
      log('Failed to send location');
    }
  }

//23-- UPDATE locations for tracking (update currentLocation To Backend)
  Future<void> updateLocationToBackend(
      String address, double currentLatitude, double currentLongitude) async {
    final response = await dio.put(
      '$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/track-location/address/$address',
      data: {
        'currentLatitude': currentLatitude,
        'currentLongitude': currentLongitude,
      },
    );

    if (response.statusCode == 200) {
      log('Location sent successfully');
    } else {
      log('Failed to send location');
    }
  }

  //24-- Get location for tracking By address And Technician (FETCH-LocationToBackend)
  Future getLocationByAddressAndTechnician(
      String address, String technicianName) async {
    var urlGetCertainLocationByAddressAndTechnician =
        '$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/track-location/address/$address/tech-name/$technicianName';
    try {
      var response = await dio.get(urlGetCertainLocationByAddressAndTechnician);
      if (response.statusCode == 200) {
        log("PRINTED DATA FROM API:  ${response.data}");
        return response.data;
      } else {
        log('List is empty');
        return [];
      }
    } catch (e) {
      log(e.toString());
      // throw Exception(e);
    }
  }

  //25-- CHECK if address exists(checkAddressExistsInTracking)
  Future<bool> checkAddressExistsInTracking(String address) async {
    String encodedAddress = Uri.encodeComponent(address);
    String getAddressUrl =
        '$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/track-location/get-address/$encodedAddress';

    try {
      var response = await dio.get(getAddressUrl);

      if (response.statusCode == 200) {
        log("PRINTED DATA FROM API: ${response.data}");
        return true;
      } else {
        log('Address not found');
        return false;
      }
    } on DioException catch (e) {
      log("Dio error: ${e.response?.statusCode} - ${e.message}");
      return false;
    } catch (e) {
      log("Unexpected error: $e");
      return false;
    }
  }

//26-- UPDATE TrackingLocations By address (with ALL DATA)

  Future<void> updateTrackingLocations(
      String address,
      double longitude,
      double latitude,
      double currentLatitude,
      double currentLongitude,
      double? startLatitude,
      double? startLongitude,
      String technicianName) async {
    try {
      var response = await dio.put(
          "$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/track-location/put-address/$address",
          data: {
            "longitude": longitude,
            "latitude": latitude,
            "currentLatitude": currentLatitude,
            "currentLongitude": currentLongitude,
            "startLatitude": startLatitude,
            "startLongitude": startLongitude,
            "technicianName": technicianName
          });
      return response.data;
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  //27-- GET StoreNameByHandsah_Name(GET STRORE NAME BY HANDASAH NAME)
  Future getStoreNameByHandasahName(String handasahName) async {
    var storesNameByHandasahUrl =
        '$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/handasah/handasah-name/$handasahName';
    try {
      var response = await dio.get(storesNameByHandasahUrl);
      if (response.statusCode == 200) {
        log("PRINTED DATA FROM API :  ${response.data}");
        return response.data;
      } else {
        log('List is empty');
        return [];
        // throw Exception('List is empty');
      }
    } catch (e) {
      log(e.toString());
      // throw Exception(e);
    }
  }

  //28-- GET StoreQty(GET STORE QTY)
  Future excuteTempStoreQty(String storeName) async {
    var tempStoresQtyUrl =
        '$BASE_URI_IP_ADDRESS_LOCAL_HOST_STORES/pick-location-integration-w-stores/api/v1/pick-loc-w-stores/t-store-name/$storeName';
    try {
      var response = await dio.get(tempStoresQtyUrl);
      if (response.statusCode == 200) {
        log("PRINTED STORE ALL DATA FROM API :  ${response.data}");

        return response.data;
      } else {
        log('List is empty');
        return [];
        // throw Exception('List is empty');
      }
    } catch (e) {
      log(e.toString());
      // throw Exception(e);
    }
  }

  //29-- GET StoreQty(GET STORE QTY)
  Future getStoreAllItemsQtyFromStoreServer() async {
    var storesQtyUrl =
        '$BASE_URI_IP_ADDRESS_LOCAL_HOST_STORES/pick-location-integration-w-stores/api/v1/pick-loc-w-stores/all';
    try {
      var response = await dio.get(storesQtyUrl);
      if (response.statusCode == 200) {
        log("PRINTED STORE ALL DATA FROM API :  ${response.data}");

        return response.data;
      } else {
        log('List is empty');
        return [];
        // throw Exception('List is empty');
      }
    } catch (e) {
      log(e.toString());
      // throw Exception(e);
    }
  }

//30-- update Location Broken By address(ADD Caller Name, Caller phone, Broken type)

  Future updateLocationBrokenByAddress(String address, String callerName,
      String brokenType, String callerPhone) async {
    try {
      final response = await dio.put(
          "$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/get-loc/add-details/$address",
          data: {
            "caller_name": callerName,
            "caller_phone": callerPhone,
            "broker_type": brokenType
          });
      log(response.data.toString());
      return response.data;
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }
//31-- update Location Broken By address(update Video Call)

  Future updateLocationBrokenByAddressUpdateVideoCall(
      String address, int videoCall) async {
    try {
      final response = await dio.put(
          "$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/get-loc/update-video-call/$address",
          data: {"video_call": videoCall});
      log(response.data.toString());
      return response.data;
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  //32-- POST Create New User(CREATE NEW USER)
  Future createNewUser(
      String username, String password, int role, String controlUnit) async {
    try {
      var response = await dio.post(
          "$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/users/create-user",
          data: {
            "username": username,
            "password": password,
            "role": role,
            "controlUnit": controlUnit,
            "technicalId": 555551
          });
      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Failed to post data');
      }
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  //33-- FETCH LOGIN USERS DROPDWON ITEMS from the Database(GET dropdown users items for  login)
  Future<List<dynamic>> fetchLoginUsersItemsDropdownMenu(
      int role, String controlUnit) async {
    var getLoginUsersUrl =
        '$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/users/role/$role/control-unit/$controlUnit';
    try {
      var response = await dio.get(getLoginUsersUrl);
      if (response.statusCode == 200) {
        // log(dataList);
        log("PRINTED DATA FROM API:  ${response.data}");

        return response.data;
      } else {
        log('List is empty');
        return [];
      }
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  //34-- GET Reprots(GET by flag 1 and isFinished 1= CLOSED)
  Future getLocByFlagAndIsFinishedForReports() async {
    var urlGetAllEndedReportsByFlagAndIsFinished =
        '$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/get-loc/flag/1/is-finished/1';
    try {
      var response = await dio.get(urlGetAllEndedReportsByFlagAndIsFinished);
      if (response.statusCode == 200) {
        return response.data;
      } else {
        log('List is empty');
        return [];
        // throw Exception('List is empty');
      }
    } catch (e) {
      log(e.toString());
      // throw Exception(e);
    }
  }

  //35-- POST Create New TOOLS(CREATE NEW TOOLS)
  Future createNewHandasahTools(
      String handasahName, String toolName, int toolQty) async {
    try {
      var response = await dio.post(
          "$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/handasat-tools/create-tool",
          data: {
            "handasahName": handasahName,
            "toolName": toolName,
            "toolQty": toolQty
          });
      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Failed to post data');
      }
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  //36-- Get Tools request for user By address And Handasah Name and Request Status (FETCH- users-requests-tools)
  Future<List<Map<String, dynamic>>>
      getHandasahToolsByAddressAndHandasahAndRequestStatus(
          String address, String handasahName, int requestStatus) async {
    final url =
        '$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/users-requests-tools/handasah/$handasahName/address/$address/requestStatus/$requestStatus';

    try {
      final response = await dio.get(url);

      if (response.statusCode == 200) {
        log("API Response: ${response.data}");

        // Handle different response formats
        if (response.data is List) {
          return List<Map<String, dynamic>>.from(response.data);
        } else if (response.data is Map<String, dynamic>) {
          return [response.data as Map<String, dynamic>];
        } else {
          log('Unexpected response format');
          return [];
        }
      } else {
        log('Request failed with status: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      log('Error fetching tools: $e');
      throw Exception('Failed to load tools: $e');
    }
  }

  //37-- FETCH HANDASAT TOOLS DROPDWON ITEMS from the Database(GET dropdown HANDASAT TOOLS items FOR USER REQUESTS)
  Future<List<String>> fetchHandasatToolsItemsDropdownMenu(
      String handasahName) async {
    final url =
        '$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/handasat-tools/all/$handasahName';

    try {
      final response = await dio.get(url);

      if (response.statusCode == 200) {
        // Ensure we have a List and convert each item to String
        final List<dynamic> data = response.data;
        log("API Response: ${data.toString()}");

        // Convert each item to String safely
        return data.map((item) => item.toString()).toList();
      } else {
        log('Request failed with status: ${response.statusCode}');
        return []; // Return empty list for non-200 status
      }
    } catch (e) {
      log('Error fetching tools: $e');
      throw Exception('Failed to load tools: $e'); // More descriptive error
    }
  }

  //38-create new Request tools(CREATE NEW REQUEST TOOLS)
  Future createNewRequestTools({
    required String handasahName,
    required String toolName,
    required String address,
    required String techName,
    required int requestStatus,
    required int toolQty,
    required int isApproved,
    required String date,
  }) async {
    try {
      var response = await dio.post(
          "$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/users-requests-tools/create-new-request",
          data: {
            "handasahName": handasahName,
            "toolName": toolName,
            "toolQty": toolQty,
            "techName": techName,
            "date": date,
            "requestStatus": requestStatus,
            "isApproved": isApproved,
            "address": address
          });
      if (response.statusCode == 201) {
        return response.data;
      } else {
        // log('List is empty');
        throw Exception('Failed to post data');
      }
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  //39-- UPDATE USER REQUEST TOOLS BY ADDRESS(UPDATE USER QTYTOOL AND ISAPPROVED BY ADDRESS)
  Future updateUserRequestToolsByAddress(
    String address,
    String toolName,
    int toolQty,
  ) async {
    try {
      final response = await dio.put(
          // "http://localhost:9999/pick-location/api/v1/users-requests-tools/address/$address/tool-name/$toolName",
          "$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/users-requests-tools/address/$address/tool-name/$toolName",
          data: {
            "toolQty": toolQty,
            "isApproved": 1,
          });
      log(response.data.toString());
      return response.data;
    } catch (e) {
      log(e.toString());
      throw Exception(e);
    }
  }

  //40-- GET Hotline Address Locally(GET Hotline Address Locally--HOTLINE)
  Future<List<Map<String, dynamic>>> getHotlineAllAddress() async {
    var url =
        '$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/hot-address/all';
    log('Calling API: $url');

    try {
      final response = await dio.get(url);

      if (response.statusCode == 200) {
        log("API Response: ${response.data}");

        if (response.data is List) {
          return List<Map<String, dynamic>>.from(response.data);
        } else if (response.data is Map<String, dynamic>) {
          return [response.data as Map<String, dynamic>];
        } else {
          log('Unexpected response format');
          return [];
        }
      } else {
        log('Request failed with status: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      log('Error fetching hot addresses: $e');
      return [];
    }
  }

  //41-- GET HOTLINE TOKEN (GET HOTLINE TOKEN BY USER AND PASSWORD)

  Future<String> getHotLineTokenByUserAndPassword() async {
    const getHotLineTokenUrlWeb =
        '$CMS_BASE_URI_IP_ADDRESS_RESOLVER:8081/api/Login';
    // const getHotLineTokenUrlWeb = 'http://192.168.2.170:8081/api/Login';

    try {
      final response = await dio.post(
        getHotLineTokenUrlWeb,
        data: {
          "userName": hotLineUsername,
          "password": HotLinePassword,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Extract token from response data
        final token = response.data['token'] as String;
        log("EXTRACTED HOTLINE TOKEN: $token");
        return token;
      } else {
        log('Failed to get token. Status code: ${response.statusCode}');
        throw Exception(
            'Failed to get token. Status code: ${response.statusCode}');
      }
    } catch (e) {
      log('Error getting hotline token: $e');
      throw Exception('Error getting hotline token: $e');
    }
  }

//42-- GET HOT LINE DATA (GET HOT LINE DATA)

  Future<List<Map<String, dynamic>>> getHotLineData(String token) async {
    // var getHotLineDataUrl = 'http://192.168.2.170:8081/api/GetOpendCases';
    var getHotLineDataUrl =
        '$CMS_BASE_URI_IP_ADDRESS_RESOLVER:8081/api/GetOpendCases';
    try {
      final response = await dio.get(
        getHotLineDataUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        log("API Response: ${response.data}");

        // Check if the response data is a List
        if (response.data is List) {
          // Try to cast each item to Map<String, dynamic>
          final List<dynamic> dataList = response.data as List;
          return dataList.map<Map<String, dynamic>>((item) {
            if (item is Map<String, dynamic>) {
              return item;
            } else {
              // If items aren't Maps, convert them or handle accordingly
              log('Item is not a Map: $item');
              return {'data': item}; // Fallback conversion
            }
          }).toList();
        } else if (response.data is Map<String, dynamic>) {
          // If the API returns a single object instead of array, wrap it in a list
          return [response.data as Map<String, dynamic>];
        } else {
          log('Unexpected response format: ${response.data.runtimeType}');
          return [];
        }
      } else {
        log('Request failed with status: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      log('Error in getHotLineData: ${e.toString()}');
      return [];
    }
  }

  //43-- POST HOT LINE DATA (POST HOT LINE DATA)
  Future<void> postHotLineDataList({
    required int id,
    required String caseReportDateTime,
    required bool finalClosed,
    required String reporterName,
    required String street,
    required String mainStreet,
    required String caseType,
    required String x,
    required String y,
    required String address,
  }) async {
    try {
      final response = await dio.post(
        '$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/hot-address/create', // Update with your endpoint

        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
        data: {
          "id": id,
          "caseReportDateTime": caseReportDateTime,
          "finalClosed": finalClosed,
          "reporterName": reporterName,
          "street": street,
          "mainStreet": mainStreet,
          "caseType": caseType,
          "x": x,
          "y": y,
          "address": address,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        log('Data posted successfully');
      } else {
        throw Exception('Failed to post data: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Dio error: ${e.message}');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

//44-- remove address from Locations
  // http: //localhost:9999/pick-location/api/v1/get-loc/remove-address/{id}
  Future<void> deleteAddressFromLocations(int id) async {
    try {
      await dio.delete(
        '$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/get-loc/remove-address/$id',
      );

      log('Address deleted successfully');
    } on DioException catch (e) {
      throw Exception('Dio error: ${e.message}');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

//45-- Get LABS testValue with date By labCode And testCode  (FETCH- for 7 days)
// http://localhost:9997/labs-integration-with-emergency/api/v1/labs-w-emergency/test-values-last/11/84 (LOACL HOST)
// $BASE_URI_IP_ADDRESS_LOCAL_HOST/labs-integration-with-emergency/api/v1/labs-w-emergency/test-values-last/11/84 (PUBLIC SERVER)
  Future<List<Map<String, dynamic>>> getAllLabsItemsByTestValueAndDate(
      int labCode, String testCode) async {
    final url =
        '$BASE_URI_IP_ADDRESS_LOCAL_HOST/labs-integration-with-emergency/api/v1/labs-w-emergency/test-values-last/$labCode/$testCode';
        // 'http://localhost:9999/labs-integration-with-emergency/api/v1/labs-w-emergency/test-values-last/$labCode/$testCode';

    try {
      final response = await dio.get(url);

      if (response.statusCode == 200) {
        log("API Response: ${response.data}");

        // Handle different response formats
        if (response.data is List) {
          return List<Map<String, dynamic>>.from(response.data);
        } else if (response.data is Map<String, dynamic>) {
          return [response.data as Map<String, dynamic>];
        } else {
          log('Unexpected response format');
          return [];
        }
      } else {
        log('Request failed with status: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      log('Error fetching tools: $e');
      throw Exception('Failed to load tools: $e');
    }
  }
}

// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:pick_location/utils/dio_http_constants.dart';
// import 'package:flutter/material.dart';

// class DioNetworkRepos {
//   // Helper method for common GET requests
//   Future<dynamic> _getRequest(String url) async {
//     try {
//       final response = await http.get(Uri.parse(url));
//       if (response.statusCode == 200) {
//         return (json.decode(utf8.decode(response.bodyBytes)));
//       } else {
//         log('List is empty');
//         return [];
//       }
//     } catch (e) {
//       log(e.toString());
//       return [];
//     }
//   }

//   // Helper method for common PUT requests
//   Future<dynamic> _putRequest(String url, Map<String, dynamic> data) async {
//     try {
//       final response = await http.put(
//         Uri.parse(url),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode(data),
//       );
//       log(response.body.toString());
//       return (json.decode(utf8.decode(response.bodyBytes)));
//     } catch (e) {
//       log(e.toString());
//       throw Exception(e);
//     }
//   }

//   // Helper method for common POST requests
//   Future<dynamic> _postRequest(String url, Map<String, dynamic> data) async {
//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode(data),
//       );
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return (json.decode(utf8.decode(response.bodyBytes)));
//       } else {
//         throw Exception('Failed to post data');
//       }
//     } catch (e) {
//       log(e.toString());
//       throw Exception(e);
//     }
//   }

//   //1-- GET locations(GET by flag 0 (address not set yet)--HOTLINE)
//   Future getLoc() async {
//     return await _getRequest(urlGetHotlineAddress);
//   }

//   //2-- GET locations(GET by flag 1 and isFinished 0)
//   Future getLocByFlagAndIsFinished() async {
//     return await _getRequest(urlGetAllByFlagAndIsFinished);
//   }

//   //3-- GET locationsBy handasah(GET by handasah (handasah) and isFinished 0)
//   Future getLocByHandasahAndIsFinished(String handasah, int isFinished) async {
//     var urlGetAllByHandasahAndIsFinished =
//         '$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/get-loc/handasah/$handasah/is-finished/$isFinished';
//     return await _getRequest(urlGetAllByHandasahAndIsFinished);
//   }

//   //4-- GET locations(GET by Handasah free and Technician free)
//   Future getLocByHandasahAndTechnician(
//       String handasah, String technician) async {
//     var urlGetAllByHandasahAndTechnician =
//         '$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/get-loc/handasah/$handasah/technical/$technician';
//     return await _getRequest(urlGetAllByHandasahAndTechnician);
//   }

//   //5-- UPDATE locations(by longitude and latitude)
//   Future updateLoc(String address, double longitude, double latitude) async {
//     var url =
//         "$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/get-loc/address/$address";
//     return await _putRequest(url, {
//       "longitude": longitude,
//       "latitude": latitude,
//       "flag": 1,
//     });
//   }

//   //6-- UPDATE locations By address (add handasahName)
//   Future updateLocAddHandasah(String address, String? handasahName) async {
//     var url =
//         "$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/get-loc/handasah/$address";
//     return await _putRequest(url, {
//       "handasah_name": handasahName,
//     });
//   }

//   //7-- UPDATE locations By address (add technicianName)
//   Future updateLocAddTechnician(String address, String? technicianName) async {
//     var url =
//         "$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/get-loc/technical/$address";
//     return await _putRequest(url, {
//       "technical_name": technicianName,
//     });
//   }

//   //8-- UPDATE locations By address (add isFinished)
//   Future updateLocAddIsFinished(String address, int isFinished) async {
//     var url =
//         "$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/get-loc/is-finished/$address";
//     return await _putRequest(url, {
//       "is_finished": isFinished,
//     });
//   }

//   //9-- UPDATE locations By address(with-url)
//   Future<void> updateLocations(
//       String address, double longitude, double latitude, String url) async {
//     var apiUrl =
//         "$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/get-loc/address/$address";
//     await _putRequest(apiUrl, {
//       "longitude": longitude,
//       "latitude": latitude,
//       "flag": 1,
//       "gis_url": url,
//       "is_finished": 0,
//       "handasah_name": "free",
//       "technical_name": "free",
//     });
//   }

//   //10-- POST in GIS Server and GET MAP Link
//   Future<String> createNewGisPointAndGetMapLink(
//       int id, String longitude, String latitude) async {
//     final basicAuth =
//         'Basic ${base64Encode(utf8.encode('$username:$password'))}';
//     try {
//       final response = await http.post(
//         Uri.parse(gisUrl),
//         headers: {
//           'authorization': basicAuth,
//           'Content-Type': 'application/json',
//         },
//         body: json.encode({
//           "uid": id,
//           "x": longitude,
//           "y": latitude,
//         }),
//       );
//       if (response.statusCode == 201) {
//         return response.body;
//       } else {
//         throw Exception('Failed to post data');
//       }
//     } catch (e) {
//       log(e.toString());
//       throw Exception(e);
//     }
//   }

//   //11-- GET USERNAME AND PASSWORD
//   Future<bool> loginByUsernameAndPassword(
//       String username, String password) async {
//     try {
//       final response = await http.get(Uri.parse(
//           "$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/users/$username/$password"));
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         log("$data from loginByUsernameAndPassword");
//         final usernameResponse = data['username'];
//         final passwordResponse = data['password'];
//         StaticVariables.userRole = data['role'];
//         StaticVariables.handasahName = data['handasah_name'];
//         log(
//             'Login successful! Username: $usernameResponse, Password: $passwordResponse , ID: ${StaticVariables.userRole}');
//         return true;
//       } else {
//         log('Login failed: ${response.body}');
//         return false;
//       }
//     } catch (e) {
//       log('Unexpected error: $e');
//       return false;
//     }
//   }

//   //12-- LOGIN User using username and password(working)
//   Future<Map<String, dynamic>> login(String username, String password) async {
//     try {
//       final response = await http.get(Uri.parse(
//           "$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/users/$username/$password"));

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         StaticVariables.userRole = data['role'];
//         StaticVariables.handasahName = data['controlUnit'];
//         StaticVariables.username = data['username'];
//         log("PRINTED DATA FROM API: ${data['role']}");
//         log("PRINTED DATA FROM API: ${data['controlUnit']}");
//         log("PRINTED DATA FROM API: ${data['username']}");
//         return {
//           'success': true,
//           'data': data,
//         };
//       } else {
//         return {
//           'success': false,
//           'message': 'Invalid status code: ${response.statusCode}',
//         };
//       }
//     } catch (e) {
//       return {
//         'success': false,
//         'message': 'An unexpected error occurred',
//       };
//     }
//   }

//   //13-- CHECK if address exists
//   Future<bool> checkAddressExists(String address) async {
//     String encodedAddress = Uri.encodeComponent(address);
//     String getAddressUrl =
//         '$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/get-loc/address/$encodedAddress';

//     try {
//       var response = await http.get(Uri.parse(getAddressUrl));

//       if (response.statusCode == 200) {
//         log("PRINTED DATA FROM API: ${response.body}");
//         return true;
//       } else {
//         log('Address not found');
//         return false;
//       }
//     } catch (e) {
//       log("Unexpected error: $e");
//       return false;
//     }
//   }

//   //14-- CHECK if address exists BY ADDRESS And HANDASAH
//   Future<bool> checkAddressExistsByAddressAndHandasah(
//       String address, String handasah) async {
//     String encodedAddress = Uri.encodeComponent(address);
//     String getAddressUrl =
//         '$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/get-loc/flag/0/address/$encodedAddress/handasah/$handasah';

//     try {
//       var response = await http.get(Uri.parse(getAddressUrl));

//       if (response.statusCode == 200) {
//         log("PRINTED DATA FROM API: ${response.body}");
//         return true;
//       } else {
//         log('Address not found');
//         return false;
//       }
//     } catch (e) {
//       log("Unexpected error: $e");
//       return false;
//     }
//   }

//   //15-- POST locations(with-url)
//   Future createNewLocation(
//       String address, double longitude, double latitude, String url) async {
//     var apiUrl = "$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/get-loc";
//     return await _postRequest(apiUrl, {
//       "address": address,
//       "longitude": longitude,
//       "latitude": latitude,
//       "flag": 1,
//       "gis_url": url,
//       "is_finished": 0,
//       "handasah_name": "free",
//       "technical_name": "free",
//       "caller_name": "لم يدرج",
//       "caller_phone": "لم يدرج",
//       "broker_type": "لم يدرج نوع الكسر",
//       "video_call": 0
//     });
//   }

//   //16-- FETCH Data from the Database(GET dropdown items for handasat)
//   Future fetchHandasatItemsDropdownMenu() async {
//     var getHandasatUrl =
//         '$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/handasah/all';
//     return await _getRequest(getHandasatUrl);
//   }

//   //17-- FETCH Data from the Database(GET dropdown items for handasat users)
//   Future fetchHandasatUsersItemsDropdownMenu(String handasahName) async {
//     var getHnadasatUsersUrl =
//         '$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/users/role/3/control-unit/$handasahName';
//     return await _getRequest(getHnadasatUsersUrl);
//   }

//   //18-- FETCH Data from the Database(GET broken items for technicians users in handasat)
//   Future<List<Map<String, dynamic>>> fetchHandasatUsersItemsBroken(
//       String handasahName, String technicianName, int isFinished) async {
//     var getHnadasatUsersListUrl =
//         '$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/get-loc/handasah/$handasahName/technical/$technicianName/is-finished/$isFinished';
//     try {
//       var response = await http.get(Uri.parse(getHnadasatUsersListUrl));

//       if (response.statusCode == 200 && response.body.isNotEmpty) {
//         final data = json.decode(response.body);
//         if (data is List) {
//           return List<Map<String, dynamic>>.from(data);
//         } else if (data is Map<String, dynamic>) {
//           return [data];
//         } else {
//           log("Unexpected response format: $data");
//           return [];
//         }
//       } else {
//         log('List is empty');
//         return [];
//       }
//     } catch (e) {
//       log("API Error: $e");
//       return [];
//     }
//   }

//   //19-- GET last record number from GIS server (broken-number-generator)
//   Future<int> getLastRecordNumber() async {
//     var getLastRecordUrl = 'http://196.219.231.3:8000/lab-api/lab-id';
//     final basicAuth =
//         'Basic ${base64Encode(utf8.encode('$username:$password'))}';
//     try {
//       var response = await http.post(
//         Uri.parse(getLastRecordUrl),
//         headers: {
//           'authorization': basicAuth,
//           'Content-Type': 'application/json',
//         },
//         body: json.encode({"category": "gis_lab_api"}),
//       );
//       if (response.statusCode == 201) {
//         log("PRINTED DATA FROM API:  ${response.body}");
//         return json.decode(response.body);
//       } else {
//         log('List is empty');
//         return 0;
//       }
//     } catch (e) {
//       log(e.toString());
//       throw Exception(e);
//     }
//   }

//   //20-- GET last record number from GIS serverWEB (broken-number-generator)
//   Future<int> getLastRecordNumberWeb() async {
//     var getLastRecordUrlWeb = 'http://196.219.231.3:8000/lab-api/web-lab-id';
//     final basicAuth =
//         'Basic ${base64Encode(utf8.encode('$username:$password'))}';
//     try {
//       var response = await http.get(
//         Uri.parse(getLastRecordUrlWeb),
//         headers: {
//           'authorization': basicAuth,
//         },
//       );
//       if (response.statusCode == 201) {
//         log("PRINTED DATA FROM API:  ${response.body}");
//         return json.decode(response.body);
//       } else {
//         log('List is empty');
//         return 0;
//       }
//     } catch (e) {
//       log(e.toString());
//       throw Exception(e);
//     }
//   }

//   //21-- UPDATE locations By address (add isApproved)
//   Future updateLocAddIsApproved(String address, int isApproved) async {
//     var url =
//         "$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/get-loc/is-approved/$address";
//     return await _putRequest(url, {
//       "is_approved": isApproved,
//     });
//   }

//   //22-- POST locations for tracking (sendLocationToBackend)
//   Future<void> sendLocationToBackend(
//       String address,
//       String technicianName,
//       double latitude,
//       double longitude,
//       double? currentLatitude,
//       double? currentLongitude) async {
//     var url =
//         '$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/track-location';
//     await _postRequest(url, {
//       'address': address,
//       'latitude': latitude,
//       'longitude': longitude,
//       'technicalName': technicianName,
//       'startLatitude': currentLatitude,
//       'startLongitude': currentLongitude,
//       'currentLatitude': currentLatitude,
//       'currentLongitude': currentLongitude,
//     });
//   }

//   //23-- UPDATE locations for tracking (update currentLocation To Backend)
//   Future<void> updateLocationToBackend(
//       String address, double currentLatitude, double currentLongitude) async {
//     var url =
//         '$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/track-location/address/$address';
//     await _putRequest(url, {
//       'currentLatitude': currentLatitude,
//       'currentLongitude': currentLongitude,
//     });
//   }

//   //24-- Get location for tracking By address And Technician (FETCH-LocationToBackend)
//   Future getLocationByAddressAndTechnician(
//       String address, String technicianName) async {
//     var urlGetCertainLocationByAddressAndTechnician =
//         '$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/track-location/address/$address/tech-name/$technicianName';
//     return await _getRequest(urlGetCertainLocationByAddressAndTechnician);
//   }

//   //25-- CHECK if address exists(checkAddressExistsInTracking)
//   Future<bool> checkAddressExistsInTracking(String address) async {
//     String encodedAddress = Uri.encodeComponent(address);
//     String getAddressUrl =
//         '$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/track-location/get-address/$encodedAddress';

//     try {
//       var response = await http.get(Uri.parse(getAddressUrl));

//       if (response.statusCode == 200) {
//         log("PRINTED DATA FROM API: ${response.body}");
//         return true;
//       } else {
//         log('Address not found');
//         return false;
//       }
//     } catch (e) {
//       log("Unexpected error: $e");
//       return false;
//     }
//   }

//   //26-- UPDATE TrackingLocations By address (with ALL DATA)
//   Future<void> updateTrackingLocations(
//       String address,
//       double longitude,
//       double latitude,
//       double currentLatitude,
//       double currentLongitude,
//       double? startLatitude,
//       double? startLongitude,
//       String technicianName) async {
//     var url =
//         "$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/track-location/put-address/$address";
//     await _putRequest(url, {
//       "longitude": longitude,
//       "latitude": latitude,
//       "currentLatitude": currentLatitude,
//       "currentLongitude": currentLongitude,
//       "startLatitude": startLatitude,
//       "startLongitude": startLongitude,
//       "technicianName": technicianName
//     });
//   }

//   //27-- GET StoreNameByHandsah_Name(GET STRORE NAME BY HANDASAH NAME)
//   Future getStoreNameByHandasahName(String handasahName) async {
//     var storesNameByHandasahUrl =
//         '$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/handasah/handasah-name/$handasahName';
//     return await _getRequest(storesNameByHandasahUrl);
//   }

//   //28-- GET StoreQty(GET STORE QTY)
//   Future excuteTempStoreQty(String storeName) async {
//     var tempStoresQtyUrl =
//         '$BASE_URI_IP_ADDRESS_LOCAL_HOST_STORES/pick-location-integration-w-stores/api/v1/pick-loc-w-stores/t-store-name/$storeName';
//     return await _getRequest(tempStoresQtyUrl);
//   }

//   //29-- GET StoreQty(GET STORE QTY)
//   Future getStoreAllItemsQtyFromStoreServer() async {
//     var storesQtyUrl =
//         '$BASE_URI_IP_ADDRESS_LOCAL_HOST_STORES/pick-location-integration-w-stores/api/v1/pick-loc-w-stores/all';
//     return await _getRequest(storesQtyUrl);
//   }

//   //30-- update Location Broken By address(ADD Caller Name, Caller phone, Broken type)
//   Future updateLocationBrokenByAddress(String address, String callerName,
//       String brokenType, String callerPhone) async {
//     var url =
//         "$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/get-loc/add-details/$address";
//     return await _putRequest(url, {
//       "caller_name": callerName,
//       "caller_phone": callerPhone,
//       "broker_type": brokenType
//     });
//   }

//   //31-- update Location Broken By address(update Video Call)
//   Future updateLocationBrokenByAddressUpdateVideoCall(
//       String address, int videoCall) async {
//     var url =
//         "$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/get-loc/update-video-call/$address";
//     return await _putRequest(url, {"video_call": videoCall});
//   }

//   //32-- POST Create New User(CREATE NEW USER)
//   Future createNewUser(
//       String username, String password, int role, String controlUnit) async {
//     var url =
//         "$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/users/create-user";
//     return await _postRequest(url, {
//       "username": username,
//       "password": password,
//       "role": role,
//       "controlUnit": controlUnit,
//       "technicalId": 555551
//     });
//   }

//   //33-- FETCH LOGIN USERS DROPDWON ITEMS from the Database(GET dropdown users items for login)
//   Future<List<dynamic>> fetchLoginUsersItemsDropdownMenu(
//       int role, String controlUnit) async {
//     var getLoginUsersUrl =
//         '$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/users/role/$role/control-unit/$controlUnit';
//     try {
//       var response = await http.get(Uri.parse(getLoginUsersUrl));
//       if (response.statusCode == 200) {
//         log("PRINTED DATA FROM API:  ${response.body}");
//         return json.decode(response.body);
//       } else {
//         log('List is empty');
//         return [];
//       }
//     } catch (e) {
//       log(e.toString());
//       throw Exception(e);
//     }
//   }

//   //34-- GET Reprots(GET by flag 1 and isFinished 1= CLOSED)
//   Future getLocByFlagAndIsFinishedForReports() async {
//     var urlGetAllEndedReportsByFlagAndIsFinished =
//         '$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/get-loc/flag/1/is-finished/1';
//     return await _getRequest(urlGetAllEndedReportsByFlagAndIsFinished);
//   }

//   //35-- POST Create New TOOLS(CREATE NEW TOOLS)
//   Future createNewHandasahTools(
//       String handasahName, String toolName, int toolQty) async {
//     var url =
//         "$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/handasat-tools/create-tool";
//     return await _postRequest(url, {
//       "handasahName": handasahName,
//       "toolName": toolName,
//       "toolQty": toolQty
//     });
//   }

//   //36-- Get Tools request for user By address And Handasah Name and Request Status
//   Future<List<Map<String, dynamic>>>
//       getHandasahToolsByAddressAndHandasahAndRequestStatus(
//           String address, String handasahName, int requestStatus) async {
//     final url =
//         '$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/users-requests-tools/handasah/$handasahName/address/$address/requestStatus/$requestStatus';

//     try {
//       final response = await http.get(Uri.parse(url));

//       if (response.statusCode == 200) {
//         log("API Response: ${response.body}");
//         final data = json.decode(response.body);
//         if (data is List) {
//           return List<Map<String, dynamic>>.from(data);
//         } else if (data is Map<String, dynamic>) {
//           return [data];
//         } else {
//           log('Unexpected response format');
//           return [];
//         }
//       } else {
//         log('Request failed with status: ${response.statusCode}');
//         return [];
//       }
//     } catch (e) {
//       log('Error fetching tools: $e');
//       throw Exception('Failed to load tools: $e');
//     }
//   }

//   //37-- FETCH HANDASAT TOOLS DROPDWON ITEMS
//   Future<List<String>> fetchHandasatToolsItemsDropdownMenu(
//       String handasahName) async {
//     final url =
//         '$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/handasat-tools/all/$handasahName';

//     try {
//       final response = await http.get(Uri.parse(url));

//       if (response.statusCode == 200) {
//         final List<dynamic> data = json.decode(response.body);
//         log("API Response: ${data.toString()}");
//         return data.map((item) => item.toString()).toList();
//       } else {
//         log('Request failed with status: ${response.statusCode}');
//         return [];
//       }
//     } catch (e) {
//       log('Error fetching tools: $e');
//       throw Exception('Failed to load tools: $e');
//     }
//   }

//   //38-create new Request tools(CREATE NEW REQUEST TOOLS)
//   Future createNewRequestTools({
//     required String handasahName,
//     required String toolName,
//     required String address,
//     required String techName,
//     required int requestStatus,
//     required int toolQty,
//     required int isApproved,
//     required String date,
//   }) async {
//     var url =
//         "$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/users-requests-tools/create-new-request";
//     return await _postRequest(url, {
//       "handasahName": handasahName,
//       "toolName": toolName,
//       "toolQty": toolQty,
//       "techName": techName,
//       "date": date,
//       "requestStatus": requestStatus,
//       "isApproved": isApproved,
//       "address": address
//     });
//   }

//   //39-- UPDATE USER REQUEST TOOLS BY ADDRESS
//   Future updateUserRequestToolsByAddress(
//       String address, int toolQty, int isApproved) async {
//     var url =
//         "$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/users-requests-tools/address/$address";
//     return await _putRequest(url, {
//       "toolQty": toolQty,
//       "isApproved": isApproved,
//     });
//   }

//   //40-- GET Hotline Address Locally(GET Hotline Address Locally--HOTLINE)
//   Future<List<Map<String, dynamic>>> getHotlineAllAddress() async {
//     var url =
//         '$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/hot-address/all';
//     log('Calling API: $url');

//     try {
//       final response = await http.get(Uri.parse(url));

//       if (response.statusCode == 200) {
//         log("API Response: ${response.body}");
//         final data = json.decode(response.body);
//         if (data is List) {
//           return List<Map<String, dynamic>>.from(data);
//         } else if (data is Map<String, dynamic>) {
//           return [data];
//         } else {
//           log('Unexpected response format');
//           return [];
//         }
//       } else {
//         log('Request failed with status: ${response.statusCode}');
//         return [];
//       }
//     } catch (e) {
//       log('Error fetching hot addresses: $e');
//       return [];
//     }
//   }

//   //41-- GET HOTLINE TOKEN (GET HOTLINE TOKEN BY USER AND PASSWORD)
//   Future<String> getHotLineTokenByUserAndPassword() async {
//     const getHotLineTokenUrlWeb = 'http://192.168.2.170:8081/api/Login';

//     try {
//       final response = await http.post(
//         Uri.parse(getHotLineTokenUrlWeb),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({
//           "userName": hotLineUsername,
//           "password": HotLinePassword,
//         }),
//       );

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final data = json.decode(response.body);
//         final token = data['token'] as String;
//         log("EXTRACTED HOTLINE TOKEN: $token");
//         return token;
//       } else {
//         log('Failed to get token. Status code: ${response.statusCode}');
//         throw Exception(
//             'Failed to get token. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       log('Error getting hotline token: $e');
//       throw Exception('Error getting hotline token: $e');
//     }
//   }

//   //42-- GET HOT LINE DATA (GET HOT LINE DATA)
//   Future<List<Map<String, dynamic>>> getHotLineData(String token) async {
//     var getHotLineDataUrl = 'http://192.168.2.170:8081/api/GetOpendCases';
//     try {
//       final response = await http.get(
//         Uri.parse(getHotLineDataUrl),
//         headers: {
//           'Authorization': 'Bearer $token',
//         },
//       );

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         log("API Response: ${response.body}");
//         final data = json.decode(response.body);
//         if (data is List) {
//           return List<Map<String, dynamic>>.from(data);
//         } else if (data is Map<String, dynamic>) {
//           return [data];
//         } else {
//           log('Unexpected response format: ${data.runtimeType}');
//           return [];
//         }
//       } else {
//         log('Request failed with status: ${response.statusCode}');
//         return [];
//       }
//     } catch (e) {
//       log('Error in getHotLineData: ${e.toString()}');
//       return [];
//     }
//   }

//   //43-- POST HOT LINE DATA (POST HOT LINE DATA)
//   Future<void> postHotLineDataList({
//     required int id,
//     required String caseReportDateTime,
//     required bool finalClosed,
//     required String reporterName,
//     required String street,
//     required String mainStreet,
//     required String caseType,
//     required String x,
//     required String y,
//     required String address,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse(
//             '$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/hot-address/create'),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: json.encode({
//           "id": id,
//           "caseReportDateTime": caseReportDateTime,
//           "finalClosed": finalClosed,
//           "reporterName": reporterName,
//           "street": street,
//           "mainStreet": mainStreet,
//           "caseType": caseType,
//           "x": x,
//           "y": y,
//           "address": address,
//         }),
//       );

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         log('Data posted successfully');
//       } else {
//         throw Exception('Failed to post data: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Error: $e');
//     }
//   }
// }
