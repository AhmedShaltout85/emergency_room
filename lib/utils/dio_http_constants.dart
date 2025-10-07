// ignore_for_file: constant_identifier_names

const String url2 =
    "$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/get-loc/filter";
const String urlGetHotlineAddress =
    "$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/get-loc/flag/0"; //GET by flag 0 (address not set yet)
const String urlGetAllByFlagAndIsFinished =
    '$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/get-loc/flag/1/is-finished/0'; //GET by flag 0 and isFinished 0
// const String urlGetAllByHandasahAndIsFinished =
//     '$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/get-loc/handasah/handasah/is-finished/0'; //GET by handasah (handasah) and isFinished 0
// const String urlGetAllByHandasahAndTechnician =
//     '$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/get-loc/handasah/free/technical/free'; //GET by Handasah free and Technician free
const String urlPut =
    "$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/get-loc/address/"; //PUT update locations

//to run on phone (the host and phone in the same network)
//const String url2 = "http://10.0.2.2:9999/pick-location/api/v1/get-loc/filter"; for emulator

//GIS Server URL
const String gisUrl = "http://196.219.231.3:8000/lab-api/create-marker";

const String googleMapsApiKey = "AIzaSyDRaJJnyvmDSU8OgI8M20C5nmwHNc_AMvk";

// const String BASE_URI_IP_ADDRESS = "http://192.168.17.250:9999";
// const String BASE_URI_IP_ADDRESS_LOCAL_HOST = "http://192.168.17.250:9999"; //debug server
// const String BASE_URI_IP_ADDRESS_LOCAL_HOST_STORES =
//     "http://192.168.17.250:9998"; //debug server
// const String BASE_URI_IP_ADDRESS_LOCAL_HOST = "http://localhost:9999";
// const String BASE_URI_IP_ADDRESS_LOCAL_HOST = "http://172.18.0.101:9999"; //publish online server
// const String BASE_URI_IP_ADDRESS_LOCAL_HOST_STORES = "http://172.18.0.101:9999"; //publish online server
// const String BASE_URI_IP_ADDRESS_LOCAL_HOST = "http://172.18.0.102:9999"; //publish TEST server
// const String BASE_URI_IP_ADDRESS_LOCAL_HOST_STORES = "http://172.18.0.102:9999"; //publish TEST server
// const String BASE_URI_IP_ADDRESS_LOCAL_HOST = "http://41.33.226.211:8099"; //publish and handheld online server
// const String BASE_URI_IP_ADDRESS_LOCAL_HOST_STORES = "http://41.33.226.211:8099"; //publish and handheld online server
// const String BASE_URI_IP_ADDRESS_LOCAL_HOST = "http://41.33.226.211:9999"; //publish and handheld TEST server
// const String BASE_URI_IP_ADDRESS_LOCAL_HOST_STORES = "41.33.226.211:9999"; // publish and handheld TEST server
////////
const String CMS_BASE_URI_IP_ADDRESS_RESOLVER =
    "http://apicms.awcoprod.com"; // publish CMS (hotline) RESOLVER

/////////    TEST SERVER ///////
// const String WEBRTC_BASE_URI_IP_ADDRESS_WEB_SOCKET =
//     'ws://dr.awcoprod.com:4090'; // publish WEBRTC WEB SOCKET TEST server
// const String BASE_URI_IP_ADDRESS_LOCAL_HOST =
//     "http://dr.awcoprod.com:9999"; //publish and handheld TEST server
// const String BASE_URI_IP_ADDRESS_LOCAL_HOST_STORES =
//     "http://dr.awcoprod.com:9999"; // publish and handheld TEST server

/////////    ONLINE SERVER ///////
const String WEBRTC_BASE_URI_IP_ADDRESS_WEB_SOCKET =
    'ws://dr.awcoprod.com:5090'; // publish WEBRTC WEB SOCKET ONLINE server
const String BASE_URI_IP_ADDRESS_LOCAL_HOST =
    "http://dr.awcoprod.com:8099"; //publish and handheld online server
    // "http://41.33.226.211:8099"; //publish and handheld online server
const String BASE_URI_IP_ADDRESS_LOCAL_HOST_STORES =
    "http://dr.awcoprod.com:8099"; // publish and handheld online server

//Agora Constants for Video Call
// const appId = "ffd898c8ae5d4d96be499de1166e6229";
// const token = "";
// const channel = "pick_location";

// //Agora Constants for Video Call updated
const appId = 'c7f8762224f147b2b446ba97543e2eaa';
const token = '';
const channel = 'control_room_location';

// //Agora Constants for Audio Call
// const appIdAudio = '179f3d65e03e4d40a6900cb55a51f154';
// const tokenAudio = '';
// const channelAudio = 'control_location_voice';

// Basic Authentication credentials
const username = 'gis';
const password = 'gislab1257910';
// Basic Authentication credentials for hotline
const hotLineUsername = "IT1234";
const HotLinePassword = "it2020";

//skada constants
const String skadaStationsReportbaseUrl =
    'http://41.33.226.211:8070/api/data/stations-report';

class DataStatic {
//Assign HandasahName
  static String handasahName = '';
  static int setectedIndax = 0;
//get user info
  static String username = '';
  static String password = '';
  static int userRole = 0;
  static String token = '';

//hotline info
  static String hotlineAddress = '';
  static int hotlineId = 0;
  static String hotlinecaseReportDateTime = '';
  static bool hotlinefinalClosed = false;
  static String hotlinereporterName = '';
  static String hotlineX = '';
  static String hotlineY = '';
  static String hotlinecaseType = '';
  static String hotlinemainStreet = '';
  static String hotlineStreet = '';

  //labs info
  static int labCode = 0;
  static String labName = "";
}
