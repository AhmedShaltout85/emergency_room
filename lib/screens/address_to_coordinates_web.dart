// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'package:emergency_room/screens/emeregency_room/controller/complaint_live_updates.dart';
import 'package:emergency_room/screens/emeregency_room/controller/complaint_provider.dart';
import 'package:emergency_room/screens/emeregency_room/model/complaint_model.dart';
import 'package:emergency_room/screens/emeregency_room/repo/complaint_repo.dart';
import 'package:emergency_room/screens/manage_system/control/handasah_provider.dart';
import 'package:emergency_room/screens/manage_system/repo/approval_authority_repo.dart';
import 'package:emergency_room/screens/manage_system/repo/complaint_type_repo.dart';
import 'package:emergency_room/screens/manage_system/repo/handasah_repo.dart';
import 'package:emergency_room/screens/manage_system/repo/important_status_repo.dart';
import 'package:emergency_room/screens/manage_system/repo/neighborhood_repo.dart';
import 'package:emergency_room/screens/manage_system/repo/repaire_status_repo.dart';
import 'package:emergency_room/screens/manage_system/repo/risk_status_repo.dart';
import 'package:emergency_room/screens/manage_system/repo/sector_repo.dart';
import 'package:emergency_room/screens/widgets/reusable_widgets/create_reusable_complaint.dart';
import 'package:emergency_room/screens/widgets/update_close_complaint.dart';
import 'package:emergency_room/screens/widgets/update_delete_complaint.dart';
import 'package:emergency_room/screens/widgets/update_join_as_repeated_address.dart';
import 'package:emergency_room/screens/widgets/update_obtain_approval.dart';
import 'package:emergency_room/screens/widgets/update_recipient_destination.dart';
import 'package:emergency_room/screens/widgets/update_urgency_number.dart';
import 'package:emergency_room/utils/cache_helper.dart';
import 'package:emergency_room/utils/whatsapp/main_whatsapp_dialog.dart';
import 'package:emergency_room/utils/whatsapp/main_whatsapp_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

// ── manage_system data layer (model / repo / provider) ───────────────────

import '../custom_widget/custom_browser_redirect.dart';
import '../custom_widget/custom_drawer.dart';
import '../custom_widget/custom_text_button_drop_down_menu.dart';
import '../custom_widget/no_internet_widget.dart';
import '../custom_widget/offline_banner.dart';

import '../network/remote/remote_network_repos.dart';
import '../services/connection_dialog_service.dart';
import '../services/connectivity_service.dart';
import '../utils/app_constants.dart';

class AddressToCoordinates extends StatefulWidget {
  const AddressToCoordinates({super.key});

  @override
  AddressToCoordinatesState createState() => AddressToCoordinatesState();
}

class AddressToCoordinatesState extends State<AddressToCoordinates> {
  //TODO: adding complaints

  String storeName = "";
  final Completer<GoogleMapController> _controller = Completer();
  bool _isMapControllerReady = false;

  String address = "";
  String coordinates = "";
  String getAddress = "";
  LatLng alexandriaCoordinates = const LatLng(31.205753, 29.924526);
  double latitude = 0.0, longitude = 0.0;
  var pickMarkers = HashSet<Marker>();

  // ── Data layer ───────────────────────────────────────────────────────────
  // Open (not finished) complaints live in this provider. sortNewestFirst is
  // false so the list keeps the server's order — exactly what the old
  // FutureBuilder + `reverse: true` list displayed.
  final ComplaintProvider _complaints = ComplaintProvider(
    ComplaintRepo(),
    sortNewestFirst: false,
  );
  final HandasahRepo _handasahRepo = HandasahRepo();
  final ApprovalAuthorityRepo _approvalRepo = ApprovalAuthorityRepo();
  final NeighborhoodRepo _neighborhoodRepo = NeighborhoodRepo();
  final RepaireStatusRepo _repaireStatusRepo = RepaireStatusRepo();
  final RiskStatusRepo _riskStatusRepo = RiskStatusRepo();
  final ImportantStatusRepo _importantStatusRepo = ImportantStatusRepo();
  final ComplaintTypeRepo _complaintTypeRepo = ComplaintTypeRepo();
  final SectorRepo _sectorRepo = SectorRepo();

  final TextEditingController addressController = TextEditingController();
  List<String> handasatItemsDropdownMenu = [];
  List<String> addHandasahToAddressList = [];
  //TODO:all complaint dropdown lists
  List<String> approvalAuthorities = [];
  List<String> neighborhoodNames = [];
  List<String> complaintRepairStatuses = [];
  List<String> seriousStatuses = [];
  List<String> complaintStatuses = [];
  List<String> complaintTypes = [];
  List<String> sectorNames = [];
//
  Future<List<Map<String, dynamic>>> getAllHotLineAddresses = Future.value([]);

  // Replace with your actual Google Maps API key
  String googleMapsApiKey = "AIzaSyDRaJJnyvmDSU8OgI8M20C5nmwHNc_AMvk";
  double fontSize = 12.0;
  int numberOfAffectedPeople = 4;
  double aproxTimeFixing = 1;
  String pipDim = '4 mm';

  // --- Internet connection state (mirrors ComplaintsReportsScreen) ---
  bool _isLoading = true;
  bool _isOnline = true;
  bool _isOnlineChecked = false;
  bool _hasData = false;
  List<Map<String, dynamic>> _hotlineData = [];

  //
  // field, next to _complaints
  final ComplaintLiveUpdates _live = ComplaintLiveUpdates();

  @override
  void dispose() {
    addressController.dispose();
    _complaints.dispose();
    _live.stop();
    if (!_controller.isCompleted) {
      _controller.future.ignore(); // nobody awaiting → don't report it
      _controller.completeError('Widget disposed');
    }
    super.dispose();
  }

  // @override
  // void dispose() {
  //   addressController.dispose();
  //   _complaints.dispose();
  //   if (!_controller.isCompleted) {
  //     _controller.completeError('Widget disposed');
  //   }
  //    // dispose(), before super.dispose();
  //   _live.stop();
  //   super.dispose();
  // }

  //TODO:convert GIS-HANDASAH-NAME-TO-EMERGENCY-HANDASAH-NAME(inprogress-21-02-2026)
  String convertGisHandasahNameToEmergencyHandasahName(
      String emergencyHandasahPattern) {
    const Map<String, String> patternToName = {
      'ABUKEER/ابو قير': 'هندسة فرع أبو قير',
      'MANDARA/المندرة': 'هندسة فرع المندرة',
      'SIDIBISHR/سيدى بشر': 'هندسة فرع سيدى بشر',
      'ELRAML/الرمل': 'هندسة فرع الرمل',
      'ELBRAHEMIA/الابراهمية': 'هندسة فرع الابراهيمية',
      'ELNOZHA/النزهه': 'هندسة فرع النزهه',
      'ELBALAD_MOHERMBK/البلد ومحرم بك': 'هندسة فرع البلد',
      'ELQABBARI/القبارى': 'هندسة فرع القبارى',
      'ELAGAMI/ العجمى': 'هندسة فرع العجمى',
      'MADINET_NOUBARIA_ELGDIDA/مدينة النوباريه الجديدة': 'هندسة النوبارية',
      'ELAMREYA/العامريه': 'هندسة فرع العامريه',
      'ELBANGER/البنجر': 'هندسة بنجر السكر',
      'BORGELARAB/برج العرب': 'هندسة برج العرب الجديده',
      '6OCTOBER/6 اكتوبر': 'هندسة فرع 6 اكتوبر',
      'ELMINA/الميناء': 'هندسة فرع الميناء',
      'MARIOUT1/مريوط 1': 'هندسة فرع مريوط 1',
    };

    for (final entry in patternToName.entries) {
      if (emergencyHandasahPattern.contains(entry.key)) {
        return entry.value;
      }
    }

    return emergencyHandasahPattern;
  }

  // ==========================================================================
  // Open complaints → ComplaintProvider
  // ==========================================================================

  /// Reloads the "not finished" complaints into the provider.
  Future<void> _refreshOpenComplaints() => _complaints.loadByFinished(false);

  /// Creates a complaint through the provider. The provider reports failures
  /// as `false` + `failure`; the callers below rely on exceptions (as the old
  /// DioNetworkRepos.createNewComplaint did), so rethrow it here.
  Future<void> _createComplaint(ComplaintModel complaint) async {
    final ok = await _complaints.create(complaint);
    if (!ok) {
      throw _complaints.failure ?? Exception('تعذر إنشاء البلاغ');
    }
  }

  /// Builds a ComplaintModel from the add-complaint form values. Missing
  /// values default to 'لم يدرج' (same defaults the screen always used).
  ComplaintModel _complaintFromForm({
    required String address,
    required String gisLink,
    required String longitude,
    required String latitude,
    required String recipientDestination,
    Map<String, dynamic> formData = const {},
    bool keepRecipientUser = true,
  }) {
    String f(String key) => (formData[key] ?? 'لم يدرج').toString();

    return ComplaintModel(
      complaintAddress: address,
      gisLink: gisLink,
      longitude: longitude,
      latitude: latitude,
      currentUsername:
          (CacheHelper.getData(key: 'username') ?? 'لم يدرج').toString(),
      recipientName: f('recipientName'),
      recipientDestination: recipientDestination,
      recipientUser: keepRecipientUser ? f('recipientUser') : 'لم يدرج',
      approvalAuthority: f('approvalAuthority'),
      neighborhood: f('neighborhood'),
      complaintSource: f('complaintSource'),
      reporterName: f('reporterName'),
      reporterPhone: f('reporterPhone'),
      complaintRepairStatus: f('complaintRepairStatus'),
      pumpDiameter: f('pumpDiameter'),
      seriousStatus: f('seriousStatus'),
      complaintStatus: f('complaintStatus'),
      complaintType: f('complaintType'),
      sectorName: f('sectorName'),
      complaintNote: f('complaintNote'),
      reportNumber:
          int.tryParse((formData['reportNumber'] ?? '0').toString()) ?? 0,
    );
  }

  // ==========================================================================
  // Unified data fetch — single connectivity check + single fetch pass,
  // matching ComplaintsReportsScreen.fetchData(). Replaces the old trio of
  // _initializeApp / _fetchInitialData / _fetchHandasatItems, which each ran
  // their own connectivity checks and could show duplicate dialogs.
  // ==========================================================================
  Future<void> fetchData() async {
    final online = await ConnectivityService.instance.hasConnection();
    if (!mounted) return;
    setState(() {
      _isOnline = online;
      _isOnlineChecked = true;
    });

    if (!online) {
      setState(() {
        _isLoading = false;
      });
      // Only interrupt with a blocking dialog when there's truly nothing
      // on screen yet. If we already have cached hotline/complaint data,
      // the OfflineBanner alone is enough — showing the dialog on top of
      // a populated screen is exactly the confusing behavior we want to
      // avoid.
      if (!_hasData) {
        await ConnectionDialogService.showNoInternetDialog(
          context,
          onRetry: fetchData,
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final token = await DioNetworkRepos().getHotLineTokenByUserAndPassword();
      final hotlineData = await DioNetworkRepos().getHotLineData(token);

      //TODO:UPDATE_COMPLAINTS — open complaints now come from ComplaintProvider
      await _refreshOpenComplaints();
      if (_complaints.state == LoadState.error && _complaints.failure != null) {
        // Same behaviour as before: a failed complaints request aborts the
        // fetch and is handled by the catch block below.
        throw _complaints.failure!;
      }

      //TODO: load complaint all dropdown lists
      log('before load all dropdown list ==================================>');
      List<String> handasatItems = [];
      await Future.wait([
        _handasahRepo.getAllNames().then((v) => handasatItems = v),
        _approvalRepo.getAll().then(
            (v) => approvalAuthorities = v.map((e) => e.approvalName).toList()),
        _neighborhoodRepo.getAll().then((v) =>
            neighborhoodNames = v.map((e) => e.neighborhoodName).toList()),
        _repaireStatusRepo.getAll().then((v) =>
            complaintRepairStatuses = v.map((e) => e.repaireType).toList()),
        _riskStatusRepo
            .getAll()
            .then((v) => seriousStatuses = v.map((e) => e.riskName).toList()),
        _importantStatusRepo.getAll().then(
            (v) => complaintStatuses = v.map((e) => e.importantName).toList()),
        _complaintTypeRepo.getAll().then(
            (v) => complaintTypes = v.map((e) => e.complaintName).toList()),
        _sectorRepo
            .getAll()
            .then((v) => sectorNames = v.map((e) => e.sectorName).toList()),
      ]);
      log('approvalAuthorities: $approvalAuthorities');
      log('neighborhoodNames: $neighborhoodNames');
      log('complaintRepairStatuses: $complaintRepairStatuses');
      log('seriousStatuses: $seriousStatuses');
      log('complaintStatuses: $complaintStatuses');
      log('complaintTypes: $complaintTypes');
      log('sectorNames: $sectorNames');
      log('after load all dropdown lists ==================================>');

      if (!mounted) return;

      final hotlineList = (hotlineData as List).cast<Map<String, dynamic>>();
      final bool locsHasData = _complaints.visibleComplaints.isNotEmpty;

      setState(() {
        _hotlineData = hotlineList;
        getAllHotLineAddresses = Future.value(hotlineList);
        handasatItemsDropdownMenu =
            handasatItems.map<String>((e) => e.toString()).toList();
        _hasData = hotlineList.isNotEmpty || locsHasData;
        _isLoading = false;
      });

      log("handasatItemsDropdownMenu from UI: $handasatItemsDropdownMenu");
      log("GET ALL HOTLINE LOCATIONS: $hotlineList");
    } catch (e) {
      log("Error fetching data: $e");
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      final onlineAgain = await ConnectivityService.instance.hasConnection();
      if (!mounted) return;
      setState(() {
        _isOnline = onlineAgain;
      });
      // Same rule here: only block with a dialog if there's no data to
      // fall back on. Otherwise let the banner communicate it.
      if (!onlineAgain && !_hasData) {
        await ConnectionDialogService.showNoInternetDialog(
          context,
          onRetry: fetchData,
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    Timer? _fallbackTimer; // field, next to _live

    // initState(), replace the _live.start(...) block with:
    _live.start(() {
      if (mounted && !_isLoading) _complaints.refreshQuietly();
    });
    _fallbackTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (mounted) _complaints.refreshQuietly();
    });
    fetchData();

    // dispose(): add
    _fallbackTimer?.cancel();

    //    // initState(), after _startPeriodicFetch();
    //  _live.start(() {
    //    if (mounted) _complaints.refreshQuietly();
    //  });
    //   fetchData();
  }

  // ==================== UI: _getCoordinatesFromAddress ====================

  /// Waits for the map controller to be ready AND for the web map view to be
  /// built before allowing camera animations. Returns null if not ready.
  Future<GoogleMapController?> _safeController({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (!_isMapControllerReady) return null;
    try {
      return await _controller.future.timeout(timeout);
    } catch (e) {
      log("Map controller not ready: $e");
      return null;
    }
  }

  /// Animates the camera only if the platform view has been built. On web,
  /// calling animateCamera before buildView throws an assertion
  /// ("Maps cannot be retrieved before calling buildView!"), so we swallow
  /// any error here — the camera move is purely cosmetic.
  Future<void> _safeAnimateCamera(LatLng target, {double zoom = 15.0}) async {
    if (!mounted || !_isMapControllerReady || !_controller.isCompleted) return;
    try {
      final controller = await _controller.future;
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: target, zoom: zoom),
        ),
      );
    } catch (e) {
      // Ignore: camera animation is best-effort on web.
      log("_safeAnimateCamera skipped: $e");
    }
  }

  Future<void> _getCoordinatesFromAddress(String address) async {
    if (!mounted) return;

    final online = await ConnectivityService.instance.hasConnection();
    if (!online) {
      if (!mounted) return;
      // Direct user action being blocked — an explicit notice is
      // appropriate here regardless of what's already on screen.
      ConnectionDialogService.showNoInternetDialog(context);
      setState(() {
        _isOnline = false;
        _isOnlineChecked = true;
      });
      return;
    }

    setState(() {
      _isOnline = true;
      _isOnlineChecked = true;
      _isLoading = true;
    });

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$googleMapsApiKey',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode != 200) {
        setState(() => coordinates = "Error: Failed to fetch data");
        return;
      }

      final data = json.decode(response.body);

      if (data['results'] == null || data['results'].isEmpty) {
        setState(() => coordinates = "Error: No results found");
        return;
      }

      final location = data['results'][0]['geometry']['location'];
      latitude = location['lat'];
      longitude = location['lng'];
      coordinates = "Latitude: $latitude, Longitude: $longitude";

      log("Address     :>> $address");
      log("Coordinates :>> $coordinates");
      log("Longitude   :>> $longitude");
      log("Latitude    :>> $latitude");

      setState(() {
        pickMarkers.add(
          Marker(
            markerId: MarkerId(address),
            position: LatLng(latitude, longitude),
            infoWindow: InfoWindow(title: address, snippet: coordinates),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
          ),
        );
      });

      // Best-effort camera move; never throws.
      await _safeAnimateCamera(LatLng(latitude, longitude));

      log('START-GIS-INTEGRATIONS');
      await _runGisIntegration(address);

      if (!mounted) return;
      unawaited(_refreshOpenComplaints());
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      log("_getCoordinatesFromAddress error: $e");
      setState(() => coordinates = "Error: Unable to get coordinates");
      if (!mounted) return;
      final onlineAgain = await ConnectivityService.instance.hasConnection();
      if (!mounted) return;
      setState(() {
        _isOnline = onlineAgain;
        _isLoading = false;
      });
      if (!onlineAgain && !_hasData) {
        await ConnectionDialogService.showNoInternetDialog(
          context,
          onRetry: fetchData,
        );
      }
    }
  }

  // ── GIS Integration ─────────────────────────────────────────────────────────
  Future<void> _runGisIntegration(String address) async {
    log("=== _runGisIntegration STARTED ===");
    try {
      log("=== CALLING getLastRecordNumberWeb ===");
      final lastRecordNumber = await DioNetworkRepos().getLastRecordNumberWeb();
      log("=== getLastRecordNumberWeb SUCCESS: $lastRecordNumber ===");

      final newRecordNumber = lastRecordNumber + 1;

      log("=== CALLING createNewGisPointAndGetMapLinkAndHandasah ===");
      final result =
          await DioNetworkRepos().createNewGisPointAndGetMapLinkAndHandasah(
        newRecordNumber,
        longitude.toString(),
        latitude.toString(),
      );
      log("=== createNewGisPoint SUCCESS: $result ===");

      final gisUrl = result['url'] as String? ?? 'لم يدرج';
      final branch = result['engineering_branch'] as String? ?? 'لم يدرج';
      final service = result['wtp_service'] as String? ?? 'لم يدرج';

      log("GIS MAP LINK :>> $gisUrl");
      log("GIS BRANCH   :>> $branch");
      log("GIS SERVICE  :>> $service");

      final handasahBranch =
          convertGisHandasahNameToEmergencyHandasahName(branch);

      log("=== CALLING _saveOrUpdateLocation WITH REAL DATA ===");
      await _saveOrUpdateLocation(address, gisUrl, handasahBranch);
      log("=== _saveOrUpdateLocation DONE ===");
    } catch (gisError, stackTrace) {
      log("=== GIS CATCH BLOCK REACHED ===");
      log("=== gisError: $gisError ===");
      log("=== stackTrace: $stackTrace ===");
      log("=== CALLING _saveOrUpdateLocation WITH FALLBACK ===");
      await _saveOrUpdateLocation(address, 'لم يدرج', 'لم يدرج');
      log("=== FALLBACK _saveOrUpdateLocation DONE ===");
    }

    log("=== _runGisIntegration ENDED ===");
  }

  // ── Helper: save new or update existing location ──────────────────────────

  Future<void> _saveOrUpdateLocation(
    String address,
    String gisUrl,
    String handasahBranch,
  ) async {
    try {
      log("START creating new location...");

      await _createComplaint(
        _complaintFromForm(
          address: address,
          gisLink: gisUrl,
          longitude: longitude.toString(),
          latitude: latitude.toString(),
          recipientDestination: handasahBranch,
        ),
      );
      log("Complaint created successfully. \n ADDRESS $address \n ===> GIS-LINK $gisUrl \n ===> RECIPIENT-DESTINATION $handasahBranch \n ==> LOGINTUDE $longitude \n ===> LATITUDE $latitude \n ===> USERNAME ${CacheHelper.getData(key: username)}\n");
      await DioNetworkRepos().createNewLocation(
        address,
        longitude,
        latitude,
        gisUrl,
        handasahBranch,
      );
      log("New location created successfully.");
    } catch (e) {
      log("_saveOrUpdateLocation error: $e");
    }
  }

  //handle dropdown click
  void handleOptionClick(String value) {
    log("Clicked: $value");
    if (value == 'عرض التقارير') {
      context.go('/report');
    } else if (value == 'عرض البلاغات المفتوحة') {
      context.go('/monitor-complaints');
    } else if (value == 'عرض لوحة التحكم') {
      context.go('/report-dashboard');
    } else if (value == 'الربط مع المعامل') {
      context.go('/integration-with-labs');
    } else if (value == 'عرض جرد المخزن') {
      // DioNetworkRepos().excuteTempStoreQty('مخزن فرع البلد');
      context.go('/stores-qty');
    } else if (value == 'عرض تقرير الاسكادا') {
      context.go('/dashboard');
    } else if (value == 'الربط مع الاسكادا') {
      CustomBrowserRedirect.openInBrowser(
        'http://41.33.226.211:8070/roundpoint',
      );
    } else if (value == 'عرض المناطق المزدحمة بالبلاغات') {
      CustomBrowserRedirect.openInBrowser(
        'http://196.219.231.3:8000/webmap/breaks-hot-spots',
      );
    } else if (value == 'عرض تقرير الاسكادا Dashboard') {
      context.go('/dashboard');
    }
  }

  // //TODO://add alexandria to the address(6-8-2026)

  String _normalizeAlexandriaAddress(String input) {
    const variants = [
      'الاسكندرية',
      'الإسكندرية',
      'الاسكندريه',
      'اسكندرية',
      'اسكندريه',
      'إسكندرية',
      'الإسكندريه', // fixed: was missing leading "ال"
    ];
    const correct = 'الإسكندرية';

    var address = input.trim();

    final hasVariant = variants.any((v) => address.contains(v));

    if (hasVariant) {
      for (final v in variants) {
        address = address.replaceAll(v, correct);
      }
    } else {
      address = address.isEmpty ? correct : '$address $correct';
    }

    return address;
  }

//TODO: Handle adding complaint(2-9-2026)
  // Enhanced method that uses all form data
  Future<void> _handleSaveWithFullData(Map<String, dynamic> formData) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final String address = formData['complaintAddress'];

      if (address.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "فضلاً أدخل العنوان",
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Normalize address
      final normalizedAddress = _normalizeAlexandriaAddress(address);

      // Get coordinates and perform GIS integration
      final result = await _getCoordinatesAndCreateComplaint(
        normalizedAddress,
        formData, // Pass all form data
      );

      // Show success message
      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "تم حفظ الشكوى بنجاح",
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.green,
          ),
        );
        // Optionally navigate back or reset form
        // _controller.resetForm();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "فضلا قم بتعيين الهندسة يدويا, نظرا لعدم التعيين من خلال GIS",
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.orange,
        ),
      );
    } finally {
      setState(() {
        //call get complaints again
        fetchData();
        _isLoading = false;
      });
    }
  }

  // Combined method that gets coordinates AND creates complaint with full data
  Future<bool> _getCoordinatesAndCreateComplaint(
    String address,
    Map<String, dynamic> formData,
  ) async {
    // Your existing geocoding logic here
    // But modified to use formData instead of default values
    try {
      // 1. Check connectivity
      final online = await ConnectivityService.instance.hasConnection();
      if (!online) {
        await ConnectionDialogService.showNoInternetDialog(context);
        return false;
      }
      log('ADDRESS: $address - FORM DATA: $formData before encoding');
      // 2. Get coordinates from Google Maps
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$googleMapsApiKey',
      );
      log('URL: $url - ADDRESS: $address after encoding');

      final response = await http.get(url);
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch coordinates');
      }

      final data = json.decode(response.body);
      if (data['results'] == null || data['results'].isEmpty) {
        throw Exception('No results found for this address');
      }

      final location = data['results'][0]['geometry']['location'];
      final latitude = location['lat'];
      final longitude = location['lng'];
      log('LATITUDE: $latitude - LONGITUDE: $longitude');
      coordinates = "Latitude: $latitude, Longitude: $longitude";

// TODO: PIN LOCATION TO MAP
      setState(() {
        pickMarkers.add(
          Marker(
            markerId: MarkerId(address),
            position: LatLng(latitude, longitude),
            infoWindow: InfoWindow(title: address, snippet: coordinates),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
          ),
        );
      });

      // Best-effort camera move; never throws on web.
      await _safeAnimateCamera(LatLng(latitude, longitude));

      // 3. Perform GIS integration
      final lastRecordNumber = await DioNetworkRepos().getLastRecordNumberWeb();
      final newRecordNumber = lastRecordNumber + 1;

      final gisResult =
          await DioNetworkRepos().createNewGisPointAndGetMapLinkAndHandasah(
        newRecordNumber,
        longitude.toString(),
        latitude.toString(),
      );

      final gisUrl = gisResult['url'] as String? ?? 'لم يدرج';
      final branch = gisResult['engineering_branch'] as String? ?? 'لم يدرج';
      final handasahBranch =
          convertGisHandasahNameToEmergencyHandasahName(branch);

      // 4. Create complaint with ALL form data (not just defaults)
      await _createComplaint(
        _complaintFromForm(
          address: address,
          gisLink: gisUrl,
          longitude: location['lng'].toString(),
          latitude: location['lat'].toString(),
          recipientDestination: handasahBranch,
          formData: formData,
        ),
      );

      return true;
    } catch (e) {
      log("Error in _getCoordinatesAndCreateComplaint: $e");
      // Fallback: create complaint with default GIS values
      // 2. Get coordinates from Google Maps
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$googleMapsApiKey',
      );
      log('URL: $url - ADDRESS: $address after encoding');

      final response = await http.get(url);
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch coordinates');
      }

      final data = json.decode(response.body);
      if (data['results'] == null || data['results'].isEmpty) {
        throw Exception('No results found for this address');
      }

      final location = data['results'][0]['geometry']['location'];
      final latitude = location['lat'];
      final longitude = location['lng'];
      log('LATITUDE FROM CATCH: $latitude - LONGITUDE FROM CATCH: $longitude');
      coordinates = "Latitude: $latitude, Longitude: $longitude";

//TODO: PIN LOCATION TO MAP
      setState(() {
        pickMarkers.add(
          Marker(
            markerId: MarkerId(address),
            position: LatLng(latitude, longitude),
            infoWindow: InfoWindow(title: address, snippet: coordinates),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
          ),
        );
      });
      await _createComplaint(
        _complaintFromForm(
          address: address,
          gisLink: 'لم يدرج',
          longitude: longitude.toString(),
          latitude: latitude.toString(),
          recipientDestination: 'لم يدرج',
          formData: formData,
          keepRecipientUser: false,
        ),
      );
      rethrow;
    }
  }

  // ==========================================================================
  // UI helpers for the complaint card
  // ==========================================================================

  /// The small coloured status pill used four times on every card.
  Widget _statusBadge(
    String text,
    Color color, {
    double horizontalPadding = 3.0,
    bool overflowVisible = false,
  }) {
    return Container(
      margin: const EdgeInsets.all(3.0),
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1.0),
        borderRadius: BorderRadius.circular(5.0),
        color: color,
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          overflow: overflowVisible ? TextOverflow.visible : null,
          fontSize: fontSize,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildComplaintCard(BuildContext context, ComplaintModel item) {
    // The action handlers / dialogs / WhatsApp helpers still take the
    // complaint as a Map, so hand them the model's JSON (same keys).
    final Map<String, dynamic> itemMap = item.toJson();

    return Card(
      child: Column(
        children: [
          ListTile(
            title: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 7.0, horizontal: 3.0),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        item.complaintAddress,
                        style: const TextStyle(
                          color: Colors.indigo,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            subtitle: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 7.0, horizontal: 3.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: item.recipientDestination == 'لم يدرج'
                            ? _statusBadge('قيد تخصيص هندسة', Colors.orange,
                                overflowVisible: true)
                            : _statusBadge(
                                item.recipientDestination,
                                Colors.green,
                                horizontalPadding: 1.0,
                              ),
                      ),
                      Expanded(
                        child: item.recipientUser == 'لم يدرج'
                            ? _statusBadge('قيد تخصيص فنى', Colors.orange,
                                overflowVisible: true)
                            : _statusBadge(item.recipientUser, Colors.green),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: item.isTracked == 1
                            ? _statusBadge('تم قبول البلاغ', Colors.green)
                            : _statusBadge('قيد قبول البلاغ', Colors.orange),
                      ),
                      Expanded(
                        child: item.complaintType != 'لم يدرج نوع الكسر'
                            ? _statusBadge(item.complaintType, Colors.green)
                            : _statusBadge('لم يدرج نوع الكسر', Colors.orange),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // ALL ICON BUTTONS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // GIS Map
              Expanded(
                child: IconButton(
                  tooltip: 'التوجهه للخريطة GIS Map',
                  hoverColor: Colors.yellow,
                  onPressed: () {
                    log("Start Gis Map ${item.gisLink}");
                    if (item.gisLink == 'لم يدرج') {
                      //TODO:REDIRECT-TO-GOOGLE-MAP
                      CustomBrowserRedirect.openInBrowser(
                          'https://www.google.com/maps/search/?api=1&query=${item.latitude},${item.longitude}');
                    } else {
                      CustomBrowserRedirect.openInBrowser(item.gisLink);
                    }
                  },
                  icon: const Icon(Icons.open_in_browser, color: Colors.blue),
                ),
              ),
              // Voice Call
              Expanded(
                child: IconButton(
                  tooltip: 'اجراء مكالمة صوتية',
                  hoverColor: Colors.yellow,
                  onPressed: () => CustomBrowserRedirect.openInBrowser(
                      "https://meet.jit.si/${item.complaintAddress}"),
                  icon: const Icon(Icons.call, color: Colors.green),
                ),
              ),
              // Tracking
              Expanded(
                child: IconButton(
                  tooltip: 'بدء تتبع فنى الهندسة',
                  hoverColor: Colors.yellow,
                  onPressed: () {
                    log("Start Traking ${item.complaintId}");
                    if (item.isTracked == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'البلاغ قيد القبول وجارى التفعيل',
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    } else {
                      context.go(
                          '/tracking/${item.complaintAddress}/${item.latitude}/${item.longitude}/${item.recipientUser}');
                    }
                  },
                  icon: const Icon(Icons.location_on, color: Colors.red),
                ),
              ),
              // Store Inventory
              // Expanded(
              //   child: IconButton(
              //     tooltip: 'جرد مخزن',
              //     hoverColor: Colors.yellow,
              //     onPressed: () async {
              //   if (item.recipientDestination == 'لم يدرج') {
              //     ScaffoldMessenger.of(context).showSnackBar(
              //       const SnackBar(
              //         content: Text(
              //           'عفوا, لايمكن إظهار جرد المخزن قبل تخصيص الهندسه',
              //           textDirection: TextDirection.rtl,
              //           textAlign: TextAlign.center,
              //         ),
              //       ),
              //     );
              //   } else {
              //     try {
              //       final handasah = await _handasahRepo
              //           .findByName(item.recipientDestination);
              //       storeName = handasah.storeName;
              //     } catch (e) {
              //       log("Store name lookup error: $e");
              //       storeName = "";
              //     }
              //     //TODO: 17-10-2026

              //     if (storeName == "0" || storeName == "") {
              //       ScaffoldMessenger.of(context).showSnackBar(
              //         const SnackBar(
              //           content: Text(
              //             'عفوا, لايمكن إظهار جرد المخزن ',
              //             textDirection: TextDirection.rtl,
              //             textAlign: TextAlign.center,
              //           ),
              //         ),
              //       );
              //     } else {
              //       DioNetworkRepos().excuteTempStoreQty(storeName);
              // context.go('/integrate-with-stores/$storeName');
              //     }
              //   }
              //     },
              //     icon: const Icon(Icons.store_outlined, color: Colors.indigo),
              //   ),
              // ),
              // GPS Car Tracking
              Expanded(
                child: IconButton(
                  tooltip: 'تتبع سيارة GPS',
                  hoverColor: Colors.yellow,
                  onPressed: () {},
                  icon: const Icon(Icons.car_rental, color: Colors.indigo),
                ),
              ),
              // Mobile Emergency Room
              Expanded(
                child: IconButton(
                  tooltip: "غرفة الطوارئ المتحركة",
                  hoverColor: Colors.yellow,
                  onPressed: () {
                    CustomBrowserRedirect.openInBrowser(
                        "https://meet.jit.si/mobileEmergencyRoom");
                  },
                  icon: const Icon(Icons.car_crash, color: Colors.purple),
                ),
              ),
              // Camera System
              Expanded(
                child: IconButton(
                  tooltip: 'نظام الكاميرات',
                  hoverColor: Colors.yellow,
                  onPressed: () {
                    const url = mobileCarIpCameratbaseUrlLocalHost;
                    CustomBrowserRedirect.openInBrowser(url);
                  },
                  icon:
                      const Icon(Icons.video_camera_back, color: Colors.black),
                ),
              ),
              // SCADA Integration
              // Expanded(
              //   child: IconButton(
              //     tooltip: 'الربط مع الاسكادا',
              //     hoverColor: Colors.yellow,
              //     onPressed: () {
              //       CustomBrowserRedirect.openInBrowser(
              //           'http://41.33.226.211:8070/roundpoint');
              //     },
              //     icon: const Icon(Icons.dashboard_customize_outlined,
              //         color: Colors.orange),
              //   ),
              // ),
              // Complaint Info - Using PopupMenuButton for reliable menu
              Expanded(
                child: PopupMenuButton<String>(
                  tooltip: 'عرض بيانات البلاغ',
                  offset: const Offset(0, -10),
                  color: Colors.white,
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  onSelected: (value) => _handleAction(value, itemMap),
                  itemBuilder: (context) => [
                    _buildPopupMenuItem(
                      value: 'details',
                      icon: Icons.remove_red_eye_outlined,
                      iconColor: Colors.blue,
                      label: 'عرض التفاصيل',
                    ),
                    _buildPopupMenuItem(
                      value: 'location',
                      icon: Icons.location_on_outlined,
                      iconColor: Colors.teal,
                      label: 'عرض الموقع',
                    ),
                    _buildPopupMenuItem(
                      value: 'whatsapp',
                      icon: Icons.chat_outlined,
                      iconColor: Colors.green,
                      label: 'إرسال إلى واتساب',
                    ),
                    _buildPopupMenuItem(
                      value: 'urgent',
                      icon: Icons.bolt_outlined,
                      iconColor: Colors.deepOrange,
                      label: 'استعجال',
                    ),
                    _buildPopupMenuItem(
                      value: 'forward',
                      icon: Icons.forward_outlined,
                      iconColor: Colors.cyan.shade700,
                      label: 'إعادة توجيه',
                    ),
                    _buildPopupMenuItem(
                      value: 'link_informant',
                      icon: Icons.link,
                      iconColor: Colors.purple,
                      label: 'ربط كمكرر',
                    ),
                    _buildPopupMenuItem(
                      value: 'approval',
                      icon: Icons.check_circle_outline,
                      iconColor: Colors.green.shade700,
                      label: 'تم الحصول على الموافقة',
                    ),
                    const PopupMenuItem<String>(
                      enabled: false,
                      height: 1,
                      padding: EdgeInsets.zero,
                      child: Divider(height: 1),
                    ),
                    _buildPopupMenuItem(
                      value: 'close',
                      icon: Icons.close_outlined,
                      iconColor: Colors.red.shade600,
                      label: 'إغلاق البلاغ',
                    ),
                    _buildPopupMenuItem(
                      value: 'delete',
                      icon: Icons.delete_outline,
                      iconColor: Colors.red,
                      label: 'حذف',
                      labelColor: Colors.red,
                    ),
                  ],
                  child: const Icon(
                    Icons.info,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

//
  @override
  Widget build(BuildContext context) {
    // Nothing useful is on screen only when we're offline AND we have no
    // cached hotline/complaint data to fall back on.
    final showNoInternet = !_isOnline && _isOnlineChecked && !_hasData;

    return ChangeNotifierProvider<ComplaintProvider>.value(
      value: _complaints,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            " غرفة الطوارئ",
            style: TextStyle(
              color: Colors.indigo,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          elevation: 7,
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(
            color: Colors.indigo,
            size: 17,
          ),
          actions: [
            //TODO: ADD CHANGE PASSWORD ROUTE(20-10-2026-NOT_TESTED)
            IconButton(
              iconSize: 30,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              tooltip: "تغيير كلمة المرور",
              hoverColor: Colors.yellow,
              onPressed: () {
                final userName =
                    (CacheHelper.getData(key: 'username') ?? '').toString();
                if (userName.isEmpty) return;
                context.push<bool>('/change-user-password', extra: userName);
              },
              icon: const Icon(
                Icons.password,
                color: Colors.indigo,
                size: 30,
              ),
            ),
            IconButton(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              tooltip: "تحديث الشكاوى",
              hoverColor: Colors.yellow,
              onPressed: () {
                fetchData();
              },
              icon: const Icon(
                Icons.refresh,
                color: Colors.indigo,
                size: 30,
              ),
            ),
            IconButton(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              tooltip: "الادارة والاعدادت",
              iconSize: 30,
              hoverColor: Colors.yellow,
              //TODO: VISIBILITY OF ADMIN BUTTON
              icon: CacheHelper.getData(key: 'username') == 'admin' ? const Icon(
                Icons.miscellaneous_services,
                color: Colors.indigo,
                // size: 30,
              ) : SizedBox.shrink(),
              onPressed: () {
                // Navigating to the Manage system Screen
                context.go('/manage-system'); // TODO: ADD MANAGE SYSTEM ROUTE
              },
            ),
            TextButtonDropdown(
              label: 'متابعة البلاغات الواردة',
              options: const [
                'عرض البلاغات المفتوحة',
                'عرض التقارير',
                'عرض لوحة التحكم',
                'الربط مع المعامل',
                'عرض جرد المخزن',
                'عرض تقرير الاسكادا',
                'الربط مع الاسكادا',
                'عرض المناطق المزدحمة بالبلاغات',
              ],
              onSelected: handleOptionClick,
            ),
            IconButton(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              tooltip: "تسجيل الخروج",
              hoverColor: Colors.yellow,
              icon: const Row(
                children: [
                  Text(
                    'تسجيل الخروج',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(width: 5),
                  Icon(
                    Icons.logout,
                    color: Colors.red,
                  ),
                ],
              ),
              onPressed: () {
                CacheHelper.removeData(key: 'username');
                CacheHelper.removeData(key: 'handasahName');
                CacheHelper.clearAllData();
                context.go('/login');
              },
            ),
          ],
        ),
        body: Column(
          children: [
            OfflineBanner(visible: !_isOnline && _isOnlineChecked),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : showNoInternet
                      ? NoInternetWidget(onRetry: fetchData)
                      : Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: CreateReusableComplaint(
                                approvalAuthorities: approvalAuthorities,
                                neighboorsName: neighborhoodNames,
                                complaintRepairStatuses:
                                    complaintRepairStatuses,
                                complaintStatuses: complaintStatuses,
                                complaintTypes: complaintTypes,
                                seriousStatuses: seriousStatuses,
                                sectorNames: sectorNames,
                                onSave: _handleSaveWithFullData,
                                initialData: null,
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Stack(
                                  children: [
                                    GoogleMap(
                                      initialCameraPosition: CameraPosition(
                                        target: alexandriaCoordinates,
                                        zoom: 10.4746,
                                      ),
                                      onMapCreated:
                                          (GoogleMapController controller) {
                                        if (!mounted) return;
                                        if (!_controller.isCompleted) {
                                          _controller.complete(controller);
                                        }
                                        setState(() {
                                          _isMapControllerReady = true;
                                        });
                                      },
                                      markers: pickMarkers,
                                      zoomControlsEnabled: true,
                                      // NOTE: Removed onCameraMoveStarted camera
                                      // animation — it fired on initial build
                                      // and on web threw the assertion
                                      // "Maps cannot be retrieved before calling
                                      // buildView!". The camera is moved
                                      // explicitly via _safeAnimateCamera.
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 8),
                                width: 220,
                                height: MediaQuery.of(context).size.height,
                                color: Colors.black45,
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 40,
                                        color: Colors.indigo,
                                        child: const Center(
                                          child: Text(
                                            textDirection: TextDirection.rtl,
                                            textAlign: TextAlign.center,
                                            'جميع البلاغات غير المغلقة',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Open complaints — driven by ComplaintProvider
                                      Consumer<ComplaintProvider>(
                                        builder: (context, complaints, _) {
                                          if (complaints.state ==
                                              LoadState.loading) {
                                            return const Center(
                                                child:
                                                    CircularProgressIndicator());
                                          }
                                          if (complaints.state ==
                                              LoadState.error) {
                                            return Center(
                                              child: Column(
                                                children: [
                                                  const Text(
                                                      'حدث خطأ في تحميل البيانات'),
                                                  ElevatedButton(
                                                    onPressed:
                                                        _refreshOpenComplaints,
                                                    child: const Text(
                                                        'إعادة المحاولة'),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                          final items =
                                              complaints.visibleComplaints;
                                          if (items.isNotEmpty) {
                                            return ListView.builder(
                                              reverse: true,
                                              shrinkWrap: true,
                                              itemCount: items.length,
                                              itemBuilder: (context, index) =>
                                                  _buildComplaintCard(
                                                      context, items[index]),
                                            );
                                          }
                                          return const Center(
                                            child:
                                                Text('لا يوجد بلاغات مفتوحة'),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
            ),
          ],
        ),
        drawer: CustomDrawer(
          title: 'الاعطال الواردة من الخط الساخن',
          getLocs: getAllHotLineAddresses,
          onTap: (itemData) {
            try {
              StaticVariables.hotlineAddress = itemData['address'];
              StaticVariables.hotlineId = itemData['id'];
              StaticVariables.hotlineX = itemData['x'];
              StaticVariables.hotlineY = itemData['y'];
              StaticVariables.hotlinecaseReportDateTime =
                  itemData['caseReportDateTime'];
              StaticVariables.hotlinefinalClosed = itemData['finalClosed'];
              StaticVariables.hotlinereporterName = itemData['reporterName'];
              StaticVariables.hotlinemainStreet = itemData['mainStreet'];
              StaticVariables.hotlineStreet = itemData['street'];
              StaticVariables.hotlinecaseType = itemData['caseType'];

              DioNetworkRepos().postHotLineDataList(
                id: StaticVariables.hotlineId,
                caseReportDateTime: StaticVariables.hotlinecaseReportDateTime,
                caseType: StaticVariables.hotlinecaseType,
                finalClosed: StaticVariables.hotlinefinalClosed,
                mainStreet: StaticVariables.hotlinemainStreet,
                reporterName: StaticVariables.hotlinereporterName,
                street: StaticVariables.hotlineStreet,
                x: StaticVariables.hotlineX,
                y: StaticVariables.hotlineY,
                address: StaticVariables.hotlineAddress,
              );
              _getCoordinatesFromAddress(StaticVariables.hotlineAddress);

              _refreshOpenComplaints();
            } catch (e) {
              log(e.toString());
            }
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  // ==========================================================================
  // Action handlers
  // ==========================================================================

  void _handleAction(String selected, Map<String, dynamic> item) {
    switch (selected) {
      case 'details':
        _showDetailsDialog(item);
        break;
      case 'location':
        _handleShowLocation(item);
        break;
      case 'whatsapp':
        _handleSendToWhatsapp(item);
        break;
      case 'close':
        _handleCloseComplaint(item);
        break;
      case 'urgent':
        _handleMarkUrgent(item);
        break;
      case 'forward':
        _handleForwardComplaint(item);
        break;
      case 'link_informant':
        _handleLinkAsInformant(item);
        break;
      case 'approval':
        _handleApprovalObtained(item);
        break;
      case 'delete':
        _handleDeleteComplaint(item);
        break;
    }
  }

  PopupMenuItem<String> _buildPopupMenuItem({
    required String value,
    required IconData icon,
    required Color iconColor,
    required String label,
    Color? labelColor,
  }) {
    return PopupMenuItem<String>(
      value: value,
      height: 42,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: iconColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w500,
                  color: labelColor ?? Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Action handlers ---------------------------------------------------
  void _handleShowLocation(Map<String, dynamic> item) {
    final lat = item['latitude']?.toString();
    final lng = item['longitude']?.toString();
    final gisUrl = item['gisLink']?.toString();
    if (lat == null || lng == null || lat.isEmpty || lng.isEmpty) {
      _showActionSnackbar('لا يوجد إحداثيات مسجلة لهذا البلاغ', isError: true);
      return;
    }
    debugPrint('gisUrl:--> $gisUrl');

    if (gisUrl != null &&
        gisUrl != 'لم يدرج' &&
        gisUrl.isNotEmpty &&
        lng.isNotEmpty &&
        lat.isNotEmpty) {
      CustomBrowserRedirect.openInBrowser(gisUrl);
    } else {
      CustomBrowserRedirect.openInBrowser(
          'https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    }
  }

  Future<void> _handleSendToWhatsapp(Map<String, dynamic> item) async {
    try {
      final whatsAppInstalled = await MainWhatsAppService.isWhatsAppInstalled();
      if (!whatsAppInstalled) {
        await MainWhatsAppDialog.showCopyDialog(
          context: context,
          complaint: item,
        );
        return;
      }

      String phoneNumber = '00201032743609';

      final userPhone = await MainWhatsAppDialog.showPhoneNumberDialog(
        context: context,
        initialPhoneNumber:
            phoneNumber.isNotEmpty ? phoneNumber : '00201032743609',
        complaint: item,
      );

      if (userPhone == null || userPhone.isEmpty) {
        _showActionSnackbar('تم إلغاء الإرسال');
        return;
      }

      phoneNumber = userPhone;

      await MainWhatsAppService.sendToWhatsAppNumber(
        complaint: item,
        phoneNumber: phoneNumber,
      );

      _showActionSnackbar('تم فتح واتساب بنجاح');
    } catch (e) {
      debugPrint('WhatsApp error: $e');

      try {
        await MainWhatsAppService.copyComplaintToClipboard(item);
        _showActionSnackbar(
          'حدث خطأ، تم نسخ البيانات إلى الحافظة',
          isError: true,
        );
      } catch (copyError) {
        _showActionSnackbar(
          'حدث خطأ: ${e.toString()}',
          isError: true,
        );
      }
    }
  }

  void _handleCloseComplaint(Map<String, dynamic> item) {
    handleCloseComplaint(
      context,
      item,
      fetchData,
    );
  }

  void _handleMarkUrgent(Map<String, dynamic> item) {
    handleMarkUrgent(
      context,
      item,
      fetchData,
    );
  }

  void _handleForwardComplaint(Map<String, dynamic> item) {
    handleForwardComplaint(
      context,
      item,
      fetchData,
    );
  }

  void _handleLinkAsInformant(Map<String, dynamic> item) {
    handleLinkAsInformant(
      context,
      item,
      fetchData,
    );
  }

  void _handleApprovalObtained(Map<String, dynamic> item) {
    handleApprovalObtained(
      context,
      item,
      fetchData,
    );
  }

  void _handleDeleteComplaint(Map<String, dynamic> item) {
    handleDeleteComplaint(
      context,
      item,
      fetchData,
    );
  }

  void _showActionSnackbar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: isError ? Colors.red : Colors.indigo,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showDetailsDialog(Map<String, dynamic> item) {
    final entries = <MapEntry<String, String>>[
      MapEntry('رقم البلاغ', item['complaintId']?.toString() ?? ''),
      MapEntry('رقم البلاغ المرجعي', item['reportNumber']?.toString() ?? ''),
      MapEntry('الحي', item['neighborhood']?.toString() ?? ''),
      MapEntry('ربط مكرر', item['repeatComplaintNumber']?.toString() ?? ''),
      MapEntry('مصدر البلاغ', item['complaintSource']?.toString() ?? ''),
      MapEntry('إسم المبلغ', item['reporterName']?.toString() ?? ''),
      MapEntry('موبيل المبلغ', item['reporterPhone']?.toString() ?? ''),
      MapEntry('العنوان', item['complaintAddress']?.toString() ?? ''),
      MapEntry('حالة الإصلاح', item['complaintRepairStatus']?.toString() ?? ''),
      MapEntry('جهة الاعتماد', item['approvalAuthority']?.toString() ?? ''),
      MapEntry('نوع الكسر', item['pumpDiameter']?.toString() ?? ''),
      MapEntry('نوع البلاغ', item['complaintType']?.toString() ?? ''),
      MapEntry('مدى الخطورة', item['seriousStatus']?.toString() ?? ''),
      MapEntry('الحالة', item['complaintStatus']?.toString() ?? ''),
      MapEntry('ملاحظات البلاغ', item['complaintNote']?.toString() ?? ''),
      MapEntry('جهة الاستلام', item['recipientDestination']?.toString() ?? ''),
      MapEntry('فنى الهندسة', item['recipientUser']?.toString() ?? ''),
      MapEntry('إسم المستلم', item['recipientName']?.toString() ?? ''),
      MapEntry(
          'إسم المستخدم الحالي', item['currentUsername']?.toString() ?? ''),
      MapEntry('رابط الخريطة (GIS)', item['gisLink']?.toString() ?? ''),
      MapEntry('خط الطول', item['longitude']?.toString() ?? ''),
      MapEntry('خط العرض', item['latitude']?.toString() ?? ''),
      MapEntry('القطاع', item['sectorName']?.toString() ?? ''),
      MapEntry('رقم الاستعجال', item['urgencyNumber']?.toString() ?? ''),
      MapEntry('تاريخ الإنشاء', _formatDateOnly(item['createdAt'])),
      MapEntry('آخر تحديث', _formatDateOnly(item['updatedAt'])),
      MapEntry('تاريخ الانتهاء', _formatDateOnly(item['finishedAt'])),
    ];

    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          title: Row(
            children: [
              const Icon(Icons.assignment_outlined, color: Colors.indigo),
              const SizedBox(width: 8),
              const Text(
                'تفاصيل البلاغ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                  fontSize: 18,
                  fontFamily: 'Cairo',
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      _statusColor(item['complaintStatus']).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _statusColor(item['complaintStatus']),
                  ),
                ),
                child: Text(
                  item['complaintStatus']?.toString() ?? '',
                  style: TextStyle(
                    color: _statusColor(item['complaintStatus']),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: entries
                    .where((e) => e.value.isNotEmpty)
                    .map(
                      (e) => Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 130,
                              child: Text(
                                e.key,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                  fontSize: 13,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ),
                            Expanded(
                              child: SelectableText(
                                e.value,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.of(dialogContext).pop(),
              icon: const Icon(Icons.close, size: 18),
              label: const Text(
                'إغلاق',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
              style: TextButton.styleFrom(foregroundColor: Colors.indigo),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateOnly(dynamic raw) {
    if (raw == null) return '';
    final parsed = DateTime.tryParse(raw.toString());
    if (parsed == null) return raw.toString();
    return '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'مفتوح':
      case 'عالى الأهمية':
        return Colors.red;
      case 'متوسط الأهمية':
        return Colors.orange;
      case 'مغلق':
      case 'عادى':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}


// // ignore_for_file: use_build_context_synchronously

// import 'dart:async';
// import 'dart:collection';
// import 'dart:convert';
// import 'dart:developer';
// import 'package:emergency_room/screens/widgets/reusable_widgets/create_reusable_complaint.dart';
// import 'package:emergency_room/screens/widgets/update_close_complaint.dart';
// import 'package:emergency_room/screens/widgets/update_delete_complaint.dart';
// import 'package:emergency_room/screens/widgets/update_join_as_repeated_address.dart';
// import 'package:emergency_room/screens/widgets/update_obtain_approval.dart';
// import 'package:emergency_room/screens/widgets/update_recipient_destination.dart';
// import 'package:emergency_room/screens/widgets/update_urgency_number.dart';
// import 'package:emergency_room/utils/cache_helper.dart';
// import 'package:emergency_room/utils/whatsapp/main_whatsapp_dialog.dart';
// import 'package:emergency_room/utils/whatsapp/main_whatsapp_service.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;

// import '../custom_widget/custom_browser_redirect.dart';
// import '../custom_widget/custom_drawer.dart';
// import '../custom_widget/custom_text_button_drop_down_menu.dart';
// import '../custom_widget/no_internet_widget.dart';
// import '../custom_widget/offline_banner.dart';
// import '../labs/widget/convert_handasah_to_lab_code.dart';
// import '../labs/widget/convert_lab_code_to_lab_name.dart';
// import '../network/remote/remote_network_repos.dart';
// import '../services/connection_dialog_service.dart';
// import '../services/connectivity_service.dart';
// import '../utils/app_constants.dart';

// class AddressToCoordinates extends StatefulWidget {
//   const AddressToCoordinates({super.key});

//   @override
//   AddressToCoordinatesState createState() => AddressToCoordinatesState();
// }

// class AddressToCoordinatesState extends State<AddressToCoordinates> {
//   //TODO: adding complaints

//   String storeName = "";
//   final Completer<GoogleMapController> _controller = Completer();
//   bool _isMapControllerReady = false;

//   String address = "";
//   String coordinates = "";
//   String getAddress = "";
//   LatLng alexandriaCoordinates = const LatLng(31.205753, 29.924526);
//   double latitude = 0.0, longitude = 0.0;
//   var pickMarkers = HashSet<Marker>();

//   // Data futures consumed by FutureBuilder / drawers.
//   // Initialized empty to avoid late-initialization errors before the
//   // first fetchData() completes.
//   Future getLocsAfterGetCoordinatesAndGis = Future.value([]);
//   // Future getLocsByHandasahNameAndTechinicianName = Future.value([]);
//   final TextEditingController addressController = TextEditingController();
//   List<String> handasatItemsDropdownMenu = [];
//   List<String> addHandasahToAddressList = [];
//   //TODO:all complaint dropdown lists
//   List<String> approvalAuthorities = [];
//   List<String> neighborhoodNames = [];
//   List<String> complaintRepairStatuses = [];
//   List<String> seriousStatuses = [];
//   List<String> complaintStatuses = [];
//   List<String> complaintTypes = [];
//   List<String> sectorNames = [];
// //
//   Future<List<Map<String, dynamic>>> getAllHotLineAddresses = Future.value([]);

//   // Replace with your actual Google Maps API key
//   String googleMapsApiKey = "AIzaSyDRaJJnyvmDSU8OgI8M20C5nmwHNc_AMvk";
//   double fontSize = 12.0;
//   Timer? _timer; // Timer for periodic fetching
//   int numberOfAffectedPeople = 4;
//   double aproxTimeFixing = 1;
//   String pipDim = '4 mm';

//   // --- Internet connection state (mirrors ComplaintsReportsScreen) ---
//   bool _isLoading = true;
//   bool _isOnline = true;
//   bool _isOnlineChecked = false;
//   bool _hasData = false;
//   List<Map<String, dynamic>> _hotlineData = [];

//   @override
//   void dispose() {
//     _timer?.cancel();
//     addressController.dispose();
//     if (!_controller.isCompleted) {
//       _controller.completeError('Widget disposed');
//     }
//     super.dispose();
//   }

//   //TODO:convert GIS-HANDASAH-NAME-TO-EMERGENCY-HANDASAH-NAME(inprogress-21-02-2026)
//   String convertGisHandasahNameToEmergencyHandasahName(
//       String emergencyHandasahPattern) {
//     const Map<String, String> patternToName = {
//       'ABUKEER/ابو قير': 'هندسة فرع أبو قير',
//       'MANDARA/المندرة': 'هندسة فرع المندرة',
//       'SIDIBISHR/سيدى بشر': 'هندسة فرع سيدى بشر',
//       'ELRAML/الرمل': 'هندسة فرع الرمل',
//       'ELBRAHEMIA/الابراهمية': 'هندسة فرع الابراهمية',
//       'ELNOZHA/النزهه': 'هندسة فرع النزهه',
//       'ELBALAD_MOHERMBK/البلد ومحرم بك': 'هندسة فرع البلد',
//       'ELQABBARI/القبارى': 'هندسة فرع القبارى',
//       'ELAGAMI/ العجمى': 'هندسة فرع العجمى',
//       'MADINET_NOUBARIA_ELGDIDA/مدينة النوباريه الجديدة': 'هندسة النوبارية',
//       'ELAMREYA/العامريه': 'هندسة فرع العامريه',
//       'ELBANGER/البنجر': 'هندسة بنجر السكر',
//       'BORGELARAB/برج العرب': 'هندسة برج العرب الجديده',
//       '6OCTOBER/6 اكتوبر': 'هندسة فرع 6 اكتوبر',
//       'ELMINA/الميناء': 'هندسة فرع الميناء',
//       'MARIOUT1/مريوط 1': 'هندسة فرع مريوط 1',
//     };

//     for (final entry in patternToName.entries) {
//       if (emergencyHandasahPattern.contains(entry.key)) {
//         return entry.value;
//       }
//     }

//     return emergencyHandasahPattern;
//   }

//   // ==========================================================================
//   // Unified data fetch — single connectivity check + single fetch pass,
//   // matching ComplaintsReportsScreen.fetchData(). Replaces the old trio of
//   // _initializeApp / _fetchInitialData / _fetchHandasatItems, which each ran
//   // their own connectivity checks and could show duplicate dialogs.
//   // ==========================================================================
//   Future<void> fetchData() async {
//     final online = await ConnectivityService.instance.hasConnection();
//     if (!mounted) return;
//     setState(() {
//       _isOnline = online;
//       _isOnlineChecked = true;
//     });

//     if (!online) {
//       setState(() {
//         _isLoading = false;
//       });
//       // Only interrupt with a blocking dialog when there's truly nothing
//       // on screen yet. If we already have cached hotline/complaint data,
//       // the OfflineBanner alone is enough — showing the dialog on top of
//       // a populated screen is exactly the confusing behavior we want to
//       // avoid.
//       if (!_hasData) {
//         await ConnectionDialogService.showNoInternetDialog(
//           context,
//           onRetry: fetchData,
//         );
//       }
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final token = await DioNetworkRepos().getHotLineTokenByUserAndPassword();
//       final hotlineData = await DioNetworkRepos().getHotLineData(token);
//       //TODO:UPDATE_COMPLAINTS
//       final locsData = await DioNetworkRepos().getAllComplaintsNotFinished();
//       // final locsData = await DioNetworkRepos().getAllComplaintsNotFinished();
//       // final locsByHandasah = await DioNetworkRepos()
//       //     .getLocByHandasahAndTechnician("لم يدرج", "لم يدرج");

//       final handasatItems =
//           await DioNetworkRepos().fetchHandasatItemsDropdownMenu();
//       //TODO: load complaint all dropdown lists
//       log('before load all dropdown list ==================================>');
//       approvalAuthorities = await DioNetworkRepos()
//           .getAllDropdownListNamesOnly('approval-authorities', 'approvalName');
//       neighborhoodNames = await DioNetworkRepos()
//           .getAllDropdownListNamesOnly('neighborhoods', 'neighborhoodName');
//       complaintRepairStatuses = await DioNetworkRepos()
//           .getAllDropdownListNamesOnly('repaire-status', 'repaireType');
//       seriousStatuses = await DioNetworkRepos()
//           .getAllDropdownListNamesOnly('risk-status', 'riskName');
//       complaintStatuses = await DioNetworkRepos()
//           .getAllDropdownListNamesOnly('important-status', 'importantName');
//       complaintTypes = await DioNetworkRepos()
//           .getAllDropdownListNamesOnly('complaint-types', 'complaintName');
//       sectorNames = await DioNetworkRepos()
//           .getAllDropdownListNamesOnly('sectors', 'sectorName');
//       log('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
//       log(approvalAuthorities.toString());
//       log('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
//       log(neighborhoodNames.toString());
//       log('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
//       log(complaintRepairStatuses.toString());
//       log('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
//       log(seriousStatuses.toString());
//       log('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
//       log(complaintStatuses.toString());
//       log('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
//       log(complaintTypes.toString());
//       log('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
//       log(sectorNames.toString());
//       log('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
//       log('after load all dropdown lists ==================================>');

//       if (!mounted) return;

//       final hotlineList = (hotlineData as List).cast<Map<String, dynamic>>();
//       final bool locsHasData = locsData.isNotEmpty;

//       setState(() {
//         _hotlineData = hotlineList;
//         getAllHotLineAddresses = Future.value(hotlineList);
//         getLocsAfterGetCoordinatesAndGis = Future.value(locsData);
//         // getLocsByHandasahNameAndTechinicianName = Future.value(locsByHandasah);
//         handasatItemsDropdownMenu =
//             handasatItems.map<String>((e) => e.toString()).toList();
//         _hasData = hotlineList.isNotEmpty || locsHasData;
//         _isLoading = false;
//       });

//       log("handasatItemsDropdownMenu from UI: $handasatItemsDropdownMenu");
//       log("GET ALL HOTLINE LOCATIONS: $hotlineList");
//     } catch (e) {
//       log("Error fetching data: $e");
//       if (!mounted) return;
//       setState(() {
//         _isLoading = false;
//       });
//       final onlineAgain = await ConnectivityService.instance.hasConnection();
//       if (!mounted) return;
//       setState(() {
//         _isOnline = onlineAgain;
//       });
//       // Same rule here: only block with a dialog if there's no data to
//       // fall back on. Otherwise let the banner communicate it.
//       if (!onlineAgain && !_hasData) {
//         await ConnectionDialogService.showNoInternetDialog(
//           context,
//           onRetry: fetchData,
//         );
//       }
//     }
//   }

//   //update in periodic time — refreshes silently, defers to the banner
//   //instead of ever showing a blocking dialog on its own.
//   void _startPeriodicFetch() {
//     const Duration fetchInterval = Duration(seconds: 30);
//     _timer = Timer.periodic(fetchInterval, (Timer timer) async {
//       if (!mounted) {
//         timer.cancel();
//         return;
//       }

//       final online = await ConnectivityService.instance.hasConnection();
//       if (!mounted) {
//         timer.cancel();
//         return;
//       }

//       setState(() {
//         _isOnline = online;
//         _isOnlineChecked = true;
//       });

//       if (online) {
//         setState(() {
//           getLocsAfterGetCoordinatesAndGis =
//               DioNetworkRepos().getAllComplaintsNotFinished();
//           // getLocsByHandasahNameAndTechinicianName = DioNetworkRepos()
//           //     .getLocByHandasahAndTechnician("لم يدرج", "لم يدرج");
//         });
//       }
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     fetchData();
//     _startPeriodicFetch();
//   }

//   // ==================== UI: _getCoordinatesFromAddress ====================

//   Future<void> _getCoordinatesFromAddress(String address) async {
//     if (!mounted) return;

//     final online = await ConnectivityService.instance.hasConnection();
//     if (!online) {
//       if (!mounted) return;
//       // Direct user action being blocked — an explicit notice is
//       // appropriate here regardless of what's already on screen.
//       ConnectionDialogService.showNoInternetDialog(context);
//       setState(() {
//         _isOnline = false;
//         _isOnlineChecked = true;
//       });
//       return;
//     }

//     setState(() {
//       _isOnline = true;
//       _isOnlineChecked = true;
//       _isLoading = true;
//     });

//     final url = Uri.parse(
//       'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$googleMapsApiKey',
//     );

//     try {
//       // Wait for map controller to be ready with timeout
//       GoogleMapController controller;
//       try {
//         controller = await _controller.future.timeout(
//           const Duration(seconds: 10),
//           onTimeout: () {
//             log("Map controller timeout");
//             throw Exception("Map controller timeout");
//           },
//         );
//       } catch (e) {
//         log("Error getting map controller: $e");
//         setState(() {
//           _isLoading = false;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text(
//               "خطأ في تحميل الخريطة، يرجى إعادة المحاولة",
//               textDirection: TextDirection.rtl,
//               textAlign: TextAlign.center,
//             ),
//             backgroundColor: Colors.red,
//           ),
//         );
//         return;
//       }

//       final response = await http.get(url);

//       if (response.statusCode != 200) {
//         setState(() => coordinates = "Error: Failed to fetch data");
//         return;
//       }

//       final data = json.decode(response.body);

//       if (data['results'] == null || data['results'].isEmpty) {
//         setState(() => coordinates = "Error: No results found");
//         return;
//       }

//       final location = data['results'][0]['geometry']['location'];
//       latitude = location['lat'];
//       longitude = location['lng'];
//       coordinates = "Latitude: $latitude, Longitude: $longitude";

//       log("Address     :>> $address");
//       log("Coordinates :>> $coordinates");
//       log("Longitude   :>> $longitude");
//       log("Latitude    :>> $latitude");

//       setState(() {
//         pickMarkers.add(
//           Marker(
//             markerId: MarkerId(address),
//             position: LatLng(latitude, longitude),
//             infoWindow: InfoWindow(title: address, snippet: coordinates),
//             icon: BitmapDescriptor.defaultMarkerWithHue(
//               BitmapDescriptor.hueGreen,
//             ),
//           ),
//         );
//       });

//       // Only animate camera if controller is ready
//       if (mounted && !_controller.isCompleted) {
//         try {
//           await controller.animateCamera(
//             CameraUpdate.newCameraPosition(
//               CameraPosition(target: LatLng(latitude, longitude), zoom: 15.0),
//             ),
//           );
//         } catch (e) {
//           log("Error animating camera: $e");
//         }
//       }

//       log('START-GIS-INTEGRATIONS');
//       await _runGisIntegration(address);

//       if (!mounted) return;
//       setState(() {
//         getLocsAfterGetCoordinatesAndGis =
//             DioNetworkRepos().getAllComplaintsNotFinished();
//         // getLocsByHandasahNameAndTechinicianName = DioNetworkRepos()
//         //     .getLocByHandasahAndTechnician("لم يدرج", "لم يدرج");
//         _isLoading = false;
//       });
//     } catch (e) {
//       log("_getCoordinatesFromAddress error: $e");
//       setState(() => coordinates = "Error: Unable to get coordinates");
//       if (!mounted) return;
//       final onlineAgain = await ConnectivityService.instance.hasConnection();
//       if (!mounted) return;
//       setState(() {
//         _isOnline = onlineAgain;
//         _isLoading = false;
//       });
//       if (!onlineAgain && !_hasData) {
//         await ConnectionDialogService.showNoInternetDialog(
//           context,
//           onRetry: fetchData,
//         );
//       }
//     }
//   }

//   // ── GIS Integration ─────────────────────────────────────────────────────────
//   Future<void> _runGisIntegration(String address) async {
//     log("=== _runGisIntegration STARTED ===");
//     try {
//       log("=== CALLING getLastRecordNumberWeb ===");
//       final lastRecordNumber = await DioNetworkRepos().getLastRecordNumberWeb();
//       log("=== getLastRecordNumberWeb SUCCESS: $lastRecordNumber ===");

//       final newRecordNumber = lastRecordNumber + 1;

//       log("=== CALLING createNewGisPointAndGetMapLinkAndHandasah ===");
//       final result =
//           await DioNetworkRepos().createNewGisPointAndGetMapLinkAndHandasah(
//         newRecordNumber,
//         longitude.toString(),
//         latitude.toString(),
//       );
//       log("=== createNewGisPoint SUCCESS: $result ===");

//       final gisUrl = result['url'] as String? ?? 'لم يدرج';
//       final branch = result['engineering_branch'] as String? ?? 'لم يدرج';
//       final service = result['wtp_service'] as String? ?? 'لم يدرج';

//       log("GIS MAP LINK :>> $gisUrl");
//       log("GIS BRANCH   :>> $branch");
//       log("GIS SERVICE  :>> $service");

//       final handasahBranch =
//           convertGisHandasahNameToEmergencyHandasahName(branch);

//       log("=== CALLING _saveOrUpdateLocation WITH REAL DATA ===");
//       await _saveOrUpdateLocation(address, gisUrl, handasahBranch);
//       log("=== _saveOrUpdateLocation DONE ===");
//     } catch (gisError, stackTrace) {
//       log("=== GIS CATCH BLOCK REACHED ===");
//       log("=== gisError: $gisError ===");
//       log("=== stackTrace: $stackTrace ===");
//       log("=== CALLING _saveOrUpdateLocation WITH FALLBACK ===");
//       await _saveOrUpdateLocation(address, 'لم يدرج', 'لم يدرج');
//       log("=== FALLBACK _saveOrUpdateLocation DONE ===");
//     }

//     log("=== _runGisIntegration ENDED ===");
//   }

//   // ── Helper: save new or update existing location ──────────────────────────

//   Future<void> _saveOrUpdateLocation(
//     String address,
//     String gisUrl,
//     String handasahBranch,
//   ) async {
//     try {
//       // final addressExists = await DioNetworkRepos().checkAddressExists(address);
//       // log("addressExists: $addressExists");

//       // if (addressExists == true) {
//       //   log("Address already exists — updating...");
//       //   await DioNetworkRepos().updateLocations(
//       //     address,
//       //     longitude,
//       //     latitude,
//       //     gisUrl,
//       //     handasahBranch,
//       //   );
//       //   log("Location updated successfully.");
//       // } else {
//       log("START creating new location...");

//       await DioNetworkRepos().createNewComplaint(
//         complaintAddress: address,
//         gisLink: gisUrl,
//         longitude: longitude.toString(),
//         latitude: latitude.toString(),
//         currentUsername: CacheHelper.getData(key: 'username') ?? 'لم يدرج',
//         recipientName: 'لم يدرج',
//         recipientDestination: handasahBranch ?? 'لم يدرج',
//         approvalAuthority: 'لم يدرج',
//         neighborhood: 'لم يدرج',
//         complaintSource: 'لم يدرج',
//         reporterName: 'لم يدرج',
//         reporterPhone: 'لم يدرج',
//         complaintRepairStatus: 'لم يدرج',
//         pumpDiameter: 'لم يدرج',
//         seriousStatus: 'لم يدرج',
//         complaintStatus: 'لم يدرج',
//         recipientUser: 'لم يدرج',
//         complaintType: 'لم يدرج',
//         sectorName: 'لم يدرج',
//         reportNumber: 'لم يدرج',
//         complaintNote: 'لم يدرج',
//       );
//       log("Complaint created successfully. \n ADDRESS $address \n ===> GIS-LINK $gisUrl \n ===> RECIPIENT-DESTINATION $handasahBranch \n ==> LOGINTUDE $longitude \n ===> LATITUDE $latitude \n ===> USERNAME ${CacheHelper.getData(key: username)}\n");
//       await DioNetworkRepos().createNewLocation(
//         address,
//         longitude,
//         latitude,
//         gisUrl,
//         handasahBranch,
//       );
//       log("New location created successfully.");
//       // }
//     } catch (e) {
//       log("_saveOrUpdateLocation error: $e");
//     }
//   }

//   // //show bottom sheet Redirect to Handasat
//   // void showCustomBottomSheet(
//   //     BuildContext context, String title, String message, String address) {
//   //   showModalBottomSheet(
//   //     context: context,
//   //     isScrollControlled: false,
//   //     builder: (context) {
//   //       return CustomBottomSheet(
//   //         title: title,
//   //         message: message,
//   //         hintText: "اختر الهندسة",
//   //         dropdownItems: handasatItemsDropdownMenu,
//   //         onItemSelected: (value) {
//   //           log("Selected: $value");
//   //           setState(() {
//   //             DioNetworkRepos().updateLocAddHandasah(address, value);
//   //           });
//   //         },
//   //         onPressed: () async {
//   //           Navigator.of(context).pop();
//   //           await DioNetworkRepos().updateLocAddTechnician(address, "لم يدرج");
//   //           await DioNetworkRepos().updateLocAddIsApproved(address, 0);
//   //         },
//   //       );
//   //     },
//   //   );
//   // }

//   //handle dropdown click
//   void handleOptionClick(String value) {
//     log("Clicked: $value");
//     if (value == 'عرض التقارير') {
//       context.go('/report');
//     } else if (value == 'عرض البلاغات المفتوحة') {
//       context.go('/monitor-complaints');
//     } else if (value == 'عرض لوحة التحكم') {
//       context.go('/report-dashboard');
//     } else if (value == 'الربط مع المعامل') {
//       context.go('/integration-with-labs');
//     } else if (value == 'عرض تقرير الاسكادا') {
//       context.go('/dashboard');
//     } else if (value == 'الربط مع الاسكادا') {
//       CustomBrowserRedirect.openInBrowser(
//         'http://41.33.226.211:8070/roundpoint',
//       );
//     } else if (value == 'عرض المناطق المزدحمة بالبلاغات') {
//       CustomBrowserRedirect.openInBrowser(
//         'http://196.219.231.3:8000/webmap/breaks-hot-spots',
//       );
//     } else if (value == 'عرض تقرير الاسكادا Dashboard') {
//       context.go('/dashboard');
//     }
//   }

//   // //TODO://add alexandria to the address(6-8-2026)

//   String _normalizeAlexandriaAddress(String input) {
//     const variants = [
//       'الاسكندرية',
//       'الإسكندرية',
//       'الاسكندريه',
//       'اسكندرية',
//       'اسكندريه',
//       'إسكندرية',
//       'الإسكندريه', // fixed: was missing leading "ال"
//     ];
//     const correct = 'الإسكندرية';

//     var address = input.trim();

//     final hasVariant = variants.any((v) => address.contains(v));

//     if (hasVariant) {
//       for (final v in variants) {
//         address = address.replaceAll(v, correct);
//       }
//     } else {
//       address = address.isEmpty ? correct : '$address $correct';
//     }

//     return address;
//   }

// //TODO: Handle adding complaint(2-9-2026)
//   // Enhanced method that uses all form data
//   Future<void> _handleSaveWithFullData(Map<String, dynamic> formData) async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final String address = formData['complaintAddress'];

//       if (address.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text(
//               "فضلاً أدخل العنوان",
//               textDirection: TextDirection.rtl,
//               textAlign: TextAlign.center,
//             ),
//             backgroundColor: Colors.red,
//           ),
//         );
//         setState(() {
//           _isLoading = false;
//         });
//         return;
//       }

//       // Normalize address
//       final normalizedAddress = _normalizeAlexandriaAddress(address);

//       // Get coordinates and perform GIS integration
//       final result = await _getCoordinatesAndCreateComplaint(
//         normalizedAddress,
//         formData, // Pass all form data
//       );

//       // Show success message
//       if (result) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text(
//               "تم حفظ الشكوى بنجاح",
//               textDirection: TextDirection.rtl,
//               textAlign: TextAlign.center,
//             ),
//             backgroundColor: Colors.green,
//           ),
//         );
//         // Optionally navigate back or reset form
//         // _controller.resetForm();
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//             "فضلا قم بتعيين الهندسة يدويا, نظرا لعدم التعيين من خلال GIS",
//             textDirection: TextDirection.rtl,
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 20,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           backgroundColor: Colors.orange,
//         ),
//       );
//     } finally {
//       setState(() {
//         //call get complaints again
//         fetchData();
//         _isLoading = false;
//       });
//     }
//   }

//   // Combined method that gets coordinates AND creates complaint with full data
//   Future<bool> _getCoordinatesAndCreateComplaint(
//     String address,
//     Map<String, dynamic> formData,
//   ) async {
//     // Your existing geocoding logic here
//     // But modified to use formData instead of default values
//     try {
//       // 1. Check connectivity
//       final online = await ConnectivityService.instance.hasConnection();
//       if (!online) {
//         await ConnectionDialogService.showNoInternetDialog(context);
//         return false;
//       }
//       log('ADDRESS: $address - FORM DATA: $formData before encoding');
//       // 2. Get coordinates from Google Maps
//       final url = Uri.parse(
//         'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$googleMapsApiKey',
//       );
//       log('URL: $url - ADDRESS: $address after encoding');

//       final response = await http.get(url);
//       if (response.statusCode != 200) {
//         throw Exception('Failed to fetch coordinates');
//       }

//       final data = json.decode(response.body);
//       if (data['results'] == null || data['results'].isEmpty) {
//         throw Exception('No results found for this address');
//       }

//       final location = data['results'][0]['geometry']['location'];
//       final latitude = location['lat'];
//       final longitude = location['lng'];
//       log('LATITUDE: $latitude - LONGITUDE: $longitude');
//       coordinates = "Latitude: $latitude, Longitude: $longitude";

// // TODO: PIN LOCATION TO MAP
//       pickMarkers.add(
//         Marker(
//           markerId: MarkerId(address),
//           position: LatLng(latitude, longitude),
//           infoWindow: InfoWindow(title: address, snippet: coordinates),
//           icon: BitmapDescriptor.defaultMarkerWithHue(
//             BitmapDescriptor.hueGreen,
//           ),
//         ),
//       );
//       // 3. Perform GIS integration
//       final lastRecordNumber = await DioNetworkRepos().getLastRecordNumberWeb();
//       final newRecordNumber = lastRecordNumber + 1;

//       final gisResult =
//           await DioNetworkRepos().createNewGisPointAndGetMapLinkAndHandasah(
//         newRecordNumber,
//         longitude.toString(),
//         latitude.toString(),
//       );

//       final gisUrl = gisResult['url'] as String? ?? 'لم يدرج';
//       final branch = gisResult['engineering_branch'] as String? ?? 'لم يدرج';
//       final handasahBranch =
//           convertGisHandasahNameToEmergencyHandasahName(branch);

//       // 4. Create complaint with ALL form data (not just defaults)
//       final username = CacheHelper.getData(key: 'username') ?? 'لم يدرج';

//       await DioNetworkRepos().createNewComplaint(
//         complaintAddress: address,
//         gisLink: gisUrl,
//         longitude: location['lng'].toString(),
//         latitude: location['lat'].toString(),
//         currentUsername: username,
//         recipientName: formData['recipientName'] ?? 'لم يدرج',
//         recipientDestination: handasahBranch ?? 'لم يدرج',
//         recipientUser: formData['recipientUser'] ?? 'لم يدرج',
//         approvalAuthority: formData['approvalAuthority'] ?? 'لم يدرج',
//         neighborhood: formData['neighborhood'] ?? 'لم يدرج',
//         complaintSource: formData['complaintSource'] ?? 'لم يدرج',
//         reporterName: formData['reporterName'] ?? 'لم يدرج',
//         reporterPhone: formData['reporterPhone'] ?? 'لم يدرج',
//         complaintRepairStatus: formData['complaintRepairStatus'] ?? 'لم يدرج',
//         pumpDiameter: formData['pumpDiameter'] ?? 'لم يدرج',
//         seriousStatus: formData['seriousStatus'] ?? 'لم يدرج',
//         complaintStatus: formData['complaintStatus'] ?? 'لم يدرج',
//         complaintType: formData['complaintType'] ?? 'لم يدرج',
//         sectorName: formData['sectorName'] ?? 'لم يدرج',
//         reportNumber: formData['reportNumber'] ?? '0',
//         complaintNote: formData['complaintNote'] ?? 'لم يدرج',
//       );

//       return true;
//     } catch (e) {
//       log("Error in _getCoordinatesAndCreateComplaint: $e");
//       // Fallback: create complaint with default GIS values
//       // 2. Get coordinates from Google Maps
//       final url = Uri.parse(
//         'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$googleMapsApiKey',
//       );
//       log('URL: $url - ADDRESS: $address after encoding');

//       final response = await http.get(url);
//       if (response.statusCode != 200) {
//         throw Exception('Failed to fetch coordinates');
//       }

//       final data = json.decode(response.body);
//       if (data['results'] == null || data['results'].isEmpty) {
//         throw Exception('No results found for this address');
//       }

//       final location = data['results'][0]['geometry']['location'];
//       final latitude = location['lat'];
//       final longitude = location['lng'];
//       log('LATITUDE FROM CATCH: $latitude - LONGITUDE FROM CATCH: $longitude');
//       coordinates = "Latitude: $latitude, Longitude: $longitude";

// //TODO: PIN LOCATION TO MAP
//       pickMarkers.add(
//         Marker(
//           markerId: MarkerId(address),
//           position: LatLng(latitude, longitude),
//           infoWindow: InfoWindow(title: address, snippet: coordinates),
//           icon: BitmapDescriptor.defaultMarkerWithHue(
//             BitmapDescriptor.hueGreen,
//           ),
//         ),
//       );
//       await DioNetworkRepos().createNewComplaint(
//         complaintAddress: address,
//         gisLink: 'لم يدرج',
//         longitude: longitude.toString(),
//         latitude: latitude.toString(),
//         currentUsername: CacheHelper.getData(key: 'username') ?? 'لم يدرج',
//         recipientName: formData['recipientName'] ?? 'لم يدرج',
//         recipientDestination: 'لم يدرج',
//         approvalAuthority: formData['approvalAuthority'] ?? 'لم يدرج',
//         neighborhood: formData['neighborhood'] ?? 'لم يدرج',
//         complaintSource: formData['complaintSource'] ?? 'لم يدرج',
//         reporterName: formData['reporterName'] ?? 'لم يدرج',
//         reporterPhone: formData['reporterPhone'] ?? 'لم يدرج',
//         complaintRepairStatus: formData['complaintRepairStatus'] ?? 'لم يدرج',
//         pumpDiameter: formData['pumpDiameter'] ?? 'لم يدرج',
//         seriousStatus: formData['seriousStatus'] ?? 'لم يدرج',
//         complaintStatus: formData['complaintStatus'] ?? 'لم يدرج',
//         recipientUser: 'لم يدرج',
//         complaintType: formData['complaintType'] ?? 'لم يدرج',
//         sectorName: formData['sectorName'] ?? 'لم يدرج',
//         complaintNote: formData['complaintNote'] ?? 'لم يدرج',
//         reportNumber: formData['reportNumber'] ?? '0',
//       );
//       rethrow;
//     }
//   }

// //
//   @override
//   Widget build(BuildContext context) {
//     // Nothing useful is on screen only when we're offline AND we have no
//     // cached hotline/complaint data to fall back on.
//     final showNoInternet = !_isOnline && _isOnlineChecked && !_hasData;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           " غرفة الطوارئ",
//           style: TextStyle(
//             color: Colors.indigo,
//             fontWeight: FontWeight.bold,
//             fontSize: 20,
//           ),
//         ),
//         centerTitle: true,
//         elevation: 7,
//         backgroundColor: Colors.white,
//         iconTheme: const IconThemeData(
//           color: Colors.indigo,
//           size: 17,
//         ),
//         actions: [
//           IconButton(
//             padding: const EdgeInsets.symmetric(horizontal: 5),
//             tooltip: "تحديث الشكاوى",
//             hoverColor: Colors.yellow,
//             onPressed: () {
//               fetchData();
//             },
//             icon: const Icon(
//               Icons.refresh,
//               color: Colors.indigo,
//             ),
//           ),
//           IconButton(
//             padding: const EdgeInsets.symmetric(horizontal: 5),
//             tooltip: "الادارة والاعدادت",
//             hoverColor: Colors.yellow,
//             icon: const Icon(
//               Icons.miscellaneous_services,
//               color: Colors.indigo,
//             ),
//             onPressed: () {
//               // Navigating to the Manage system Screen
//               // context.go('/manage-handasah'); // TODO: ADD MANAGE HANDASAH ROUTE
//               // context.go('/manage-users'); // TODO: ADD MANAGE USERS ROUTE
//               // context.go('/manage-approval-authorities'); // TODO: ADD MANAGE APPROVAL AUTHORITIES ROUTE
//               // context.go('/manage-important-status'); // TODO: ADD MANAGE IMPORTANT STATUS ROUTE
//               // context.go('/manage-neighborhoods'); // TODO: ADD MANAGE NEIGHBORHOODS ROUTE
//               // context.go('/manage-repaire-status'); // TODO: ADD MANAGE REPAIRE STATUS ROUTE
//               // context.go('/manage-risk-status'); // TODO: ADD MANAGE RISK STATUS ROUTE
//               // context.go('/manage-sectors'); // TODO: ADD MANAGE SECTORS ROUTE
//               // context.go('/manage-complaint-types'); // TODO: ADD MANAGE COMPLAINT TYPES ROUTE
//               context.go('/manage-system'); // TODO: ADD MANAGE SYSTEM ROUTE
//               // showDialog(
//               //     context: context,
//               //     builder: (context) {
//               //       return CustomReusableAlertDialog(
//               //           title: 'اضافة مستخدمين الطوارئ',
//               //           fieldLabels: const [
//               //             'اسم المستخدم',
//               //             'كلمة المرور',
//               //             'مطابقة كلمة المرور',
//               //           ],
//               //           onSubmit: (values) {
//               //             DioNetworkRepos().createNewUser(
//               //                 values[0], values[1], 1, 'غرفة الطوارئ');
//               //           });
//               //     });
//             },
//           ),
//           TextButtonDropdown(
//             label: 'متابعة البلاغات الواردة',
//             options: const [
//               'عرض البلاغات المفتوحة',
//               'عرض التقارير',
//               'عرض لوحة التحكم',
//               'الربط مع المعامل',
//               'عرض تقرير الاسكادا',
//               'الربط مع الاسكادا',
//               'عرض المناطق المزدحمة بالبلاغات',
//             ],
//             onSelected: handleOptionClick,
//           ),
//           IconButton(
//             padding: const EdgeInsets.symmetric(horizontal: 15),
//             tooltip: "تسجيل الخروج",
//             hoverColor: Colors.yellow,
//             icon: const Icon(
//               Icons.logout,
//               color: Colors.red,
//             ),
//             onPressed: () {
//               context.go('/login');
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           OfflineBanner(visible: !_isOnline && _isOnlineChecked),
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : showNoInternet
//                     ? NoInternetWidget(onRetry: fetchData)
//                     : Row(
//                         children: [
//                           Expanded(
//                             flex: 1,
//                             child: CreateReusableComplaint(
//                               approvalAuthorities: approvalAuthorities,
//                               neighboorsName: neighborhoodNames,
//                               complaintRepairStatuses: complaintRepairStatuses,
//                               complaintStatuses: complaintStatuses,
//                               complaintTypes: complaintTypes,
//                               seriousStatuses: seriousStatuses,
//                               sectorNames: sectorNames,

//                               onSave: _handleSaveWithFullData,
//                               // onSave: (formData) {
//                               //   log(formData['complaintAddress']);
//                               //   log(formData['recipientName']);
//                               //   log(formData['recipientDestination']);
//                               //   log(formData['approvalAuthority']);
//                               //   log(formData['neighborhood']);
//                               //   log(formData['complaintSource']);
//                               //   log(formData['reporterName']);
//                               //   log(formData['reporterPhone']);
//                               //   log(formData['complaintRepairStatus']);
//                               //   log(formData['pumpDiameter']);
//                               //   log(formData['seriousStatus']);
//                               //   log(formData['complaintStatus']);
//                               //   log(formData['recipientUser']);
//                               //   log(formData['complaintType']);
//                               //   log(formData['sectorName']);

//                               // },
//                               initialData: null,
//                             ),
//                           ),
//                           // Expanded(
//                           //   flex: 1,
//                           //   child: Container(
//                           //     margin: const EdgeInsets.symmetric(
//                           //         horizontal: 8, vertical: 8),
//                           //     width: 220,
//                           //     height: MediaQuery.of(context).size.height,
//                           //     child: CustomEndDrawer(
//                           //       title: 'تخصيص بلاغات الهندسة',
//                           //       getLocs:
//                           //           getLocsByHandasahNameAndTechinicianName,
//                           //       stringListItems: handasatItemsDropdownMenu,
//                           //       onPressed: () {
//                           //         setState(() {
//                           //           // getLocsByHandasahNameAndTechinicianName =
//                           //           //     DioNetworkRepos()
//                           //           //         .getLocByHandasahAndTechnician(
//                           //           //             "لم يدرج", "لم يدرج");
//                           //           getLocsAfterGetCoordinatesAndGis =
//                           //               DioNetworkRepos()
//                           //                   .getAllComplaintsNotFinished();
//                           //         });
//                           //       },
//                           //       hintText: 'فضلا أختار الهندسة',
//                           //     ),
//                           //   ),
//                           // ),
//                           Expanded(
//                             flex: 3,
//                             child: Padding(
//                               padding: const EdgeInsets.only(top: 8.0),
//                               child: Stack(
//                                 children: [
//                                   GoogleMap(
//                                     initialCameraPosition: CameraPosition(
//                                       target: alexandriaCoordinates,
//                                       zoom: 10.4746,
//                                     ),
//                                     onMapCreated:
//                                         (GoogleMapController controller) {
//                                           if (!mounted) return;
//                                       if (!_controller.isCompleted) {
//                                         _controller.complete(controller);
//                                       }
//                                       setState(() {
//                                         _isMapControllerReady = true;
//                                       });
//                                     },
//                                     markers: pickMarkers,
//                                     zoomControlsEnabled: true,
//                                     onCameraMoveStarted: () async {
//                                       // Only try to animate if controller is ready
//                                       if (_controller.isCompleted && mounted) {
//                                         try {
//                                           final GoogleMapController controller =
//                                               await _controller.future;
//                                           CameraPosition cameraPosition =
//                                               CameraPosition(
//                                             target: LatLng(latitude, longitude),
//                                             zoom: 14,
//                                           );
//                                           await controller.animateCamera(
//                                               CameraUpdate.newCameraPosition(
//                                                   cameraPosition));
//                                         } catch (e) {
//                                           log("Camera move error: $e");
//                                         }
//                                       }
//                                     },
//                                   ),
                                 
//                                 ],
//                               ),
//                             ),
//                           ),
//                           Expanded(
//                             flex: 1,
//                             child: Container(
//                               margin: const EdgeInsets.symmetric(
//                                   horizontal: 8, vertical: 8),
//                               width: 220,
//                               height: MediaQuery.of(context).size.height,
//                               color: Colors.black45,
//                               child: SingleChildScrollView(
//                                 child: Column(
//                                   children: [
//                                     Container(
//                                       height: 40,
//                                       color: Colors.indigo,
//                                       child: const Center(
//                                         child: Text(
//                                           textDirection: TextDirection.rtl,
//                                           textAlign: TextAlign.center,
//                                           'جميع البلاغات غير المغلقة',
//                                           style: TextStyle(
//                                             color: Colors.white,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                     FutureBuilder(
//                                         future:
//                                             getLocsAfterGetCoordinatesAndGis,
//                                         builder: (context, snapshot) {
//                                           if (snapshot.connectionState ==
//                                               ConnectionState.waiting) {
//                                             return const Center(
//                                                 child:
//                                                     CircularProgressIndicator());
//                                           }
//                                           if (snapshot.hasError) {
//                                             return Center(
//                                               child: Column(
//                                                 children: [
//                                                   const Text(
//                                                       'حدث خطأ في تحميل البيانات'),
//                                                   ElevatedButton(
//                                                     onPressed: () {
//                                                       setState(() {
//                                                         getLocsAfterGetCoordinatesAndGis =
//                                                             DioNetworkRepos()
//                                                                 .getAllComplaintsNotFinished();
//                                                       });
//                                                     },
//                                                     child: const Text(
//                                                         'إعادة المحاولة'),
//                                                   ),
//                                                 ],
//                                               ),
//                                             );
//                                           }
//                                           if (snapshot.hasData &&
//                                               snapshot.data!.isNotEmpty) {
//                                             return ListView.builder(
//                                               reverse: true,
//                                               shrinkWrap: true,
//                                               itemCount: snapshot.data!.length,
//                                               itemBuilder: (context, index) {
//                                                 final item =
//                                                     snapshot.data![index];
//                                                 return Card(
//                                                   child: Column(
//                                                     children: [
//                                                       ListTile(
//                                                         title: Padding(
//                                                           padding:
//                                                               const EdgeInsets
//                                                                   .symmetric(
//                                                                   vertical: 7.0,
//                                                                   horizontal:
//                                                                       3.0),
//                                                           child: Row(
//                                                             children: [
                                                             

//                                                               Expanded(
//                                                                 child: Padding(
//                                                                   padding:
//                                                                       const EdgeInsets
//                                                                           .only(
//                                                                           right:
//                                                                               8.0),
//                                                                   child: Text(
//                                                                     textAlign:
//                                                                         TextAlign
//                                                                             .right,
//                                                                     textDirection:
//                                                                         TextDirection
//                                                                             .rtl,
//                                                                     item[
//                                                                         'complaintAddress'],
//                                                                     style: const TextStyle(
//                                                                         color: Colors
//                                                                             .indigo,
//                                                                         fontWeight:
//                                                                             FontWeight
//                                                                                 .bold,
//                                                                         fontSize:
//                                                                             13),
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                             ],
//                                                           ),
//                                                         ),
//                                                         subtitle: Padding(
//                                                           padding:
//                                                               const EdgeInsets
//                                                                   .symmetric(
//                                                                   vertical: 7.0,
//                                                                   horizontal:
//                                                                       3.0),
//                                                           child: Column(
//                                                             children: [
//                                                               Row(
//                                                                 mainAxisAlignment:
//                                                                     MainAxisAlignment
//                                                                         .spaceBetween,
//                                                                 children: [
//                                                                   item['recipientDestination'] ==
//                                                                           'لم يدرج'
//                                                                       ? Expanded(
//                                                                           child:
//                                                                               Container(
//                                                                             margin:
//                                                                                 const EdgeInsets.all(3.0),
//                                                                             padding:
//                                                                                 const EdgeInsets.symmetric(horizontal: 3.0),
//                                                                             decoration:
//                                                                                 BoxDecoration(
//                                                                               border: Border.all(color: Colors.orange, width: 1.0),
//                                                                               borderRadius: BorderRadius.circular(5.0),
//                                                                               color: Colors.orange,
//                                                                             ),
//                                                                             child:
//                                                                                 Text(
//                                                                               textAlign: TextAlign.center,
//                                                                               "قيد تخصيص هندسة",
//                                                                               style: TextStyle(
//                                                                                 overflow: TextOverflow.visible,
//                                                                                 fontSize: fontSize,
//                                                                                 color: Colors.white,
//                                                                               ),
//                                                                             ),
//                                                                           ),
//                                                                         )
//                                                                       : Expanded(
//                                                                           child:
//                                                                               Container(
//                                                                             margin:
//                                                                                 const EdgeInsets.all(3.0),
//                                                                             padding:
//                                                                                 const EdgeInsets.symmetric(horizontal: 1.0),
//                                                                             decoration:
//                                                                                 BoxDecoration(
//                                                                               border: Border.all(color: Colors.green, width: 1.0),
//                                                                               borderRadius: BorderRadius.circular(5.0),
//                                                                               color: Colors.green,
//                                                                             ),
//                                                                             child:
//                                                                                 Text(
//                                                                               textAlign: TextAlign.center,
//                                                                               "${item['recipientDestination']}",
//                                                                               style: TextStyle(
//                                                                                 fontSize: fontSize,
//                                                                                 color: Colors.white,
//                                                                               ),
//                                                                             ),
//                                                                           ),
//                                                                         ),
//                                                                   item['recipientUser'] ==
//                                                                           "لم يدرج"
//                                                                       ? Expanded(
//                                                                           child:
//                                                                               Container(
//                                                                             margin:
//                                                                                 const EdgeInsets.all(3.0),
//                                                                             padding:
//                                                                                 const EdgeInsets.symmetric(horizontal: 3.0),
//                                                                             decoration:
//                                                                                 BoxDecoration(
//                                                                               border: Border.all(color: Colors.orange, width: 1.0),
//                                                                               borderRadius: BorderRadius.circular(5.0),
//                                                                               color: Colors.orange,
//                                                                             ),
//                                                                             child:
//                                                                                 Text(
//                                                                               textAlign: TextAlign.center,
//                                                                               "قيد تخصيص فنى",
//                                                                               style: TextStyle(
//                                                                                 overflow: TextOverflow.visible,
//                                                                                 fontSize: fontSize,
//                                                                                 color: Colors.white,
//                                                                               ),
//                                                                             ),
//                                                                           ),
//                                                                         )
//                                                                       : Expanded(
//                                                                           child:
//                                                                               Container(
//                                                                             margin:
//                                                                                 const EdgeInsets.all(3.0),
//                                                                             padding:
//                                                                                 const EdgeInsets.symmetric(horizontal: 3.0),
//                                                                             decoration:
//                                                                                 BoxDecoration(
//                                                                               border: Border.all(color: Colors.green, width: 1.0),
//                                                                               borderRadius: BorderRadius.circular(5.0),
//                                                                               color: Colors.green,
//                                                                             ),
//                                                                             child:
//                                                                                 Text(
//                                                                               textAlign: TextAlign.center,
//                                                                               "${item['recipientUser']}",
//                                                                               style: TextStyle(
//                                                                                 fontSize: fontSize,
//                                                                                 color: Colors.white,
//                                                                               ),
//                                                                             ),
//                                                                           ),
//                                                                         ),
//                                                                 ],
//                                                               ),
//                                                               Row(
//                                                                 children: [
//                                                                   Expanded(
//                                                                     child: item['isTracked'] ==
//                                                                             1
//                                                                         ? Container(
//                                                                             margin:
//                                                                                 const EdgeInsets.all(3.0),
//                                                                             padding:
//                                                                                 const EdgeInsets.symmetric(horizontal: 3.0),
//                                                                             decoration:
//                                                                                 BoxDecoration(
//                                                                               border: Border.all(color: Colors.green, width: 1.0),
//                                                                               borderRadius: BorderRadius.circular(5.0),
//                                                                               color: Colors.green,
//                                                                             ),
//                                                                             child:
//                                                                                 Text(
//                                                                               textAlign: TextAlign.center,
//                                                                               'تم قبول البلاغ',
//                                                                               style: TextStyle(
//                                                                                 fontSize: fontSize,
//                                                                                 color: Colors.white,
//                                                                               ),
//                                                                             ),
//                                                                           )
//                                                                         : Container(
//                                                                             margin:
//                                                                                 const EdgeInsets.all(3.0),
//                                                                             padding:
//                                                                                 const EdgeInsets.symmetric(horizontal: 3.0),
//                                                                             decoration:
//                                                                                 BoxDecoration(
//                                                                               border: Border.all(color: Colors.orange, width: 1.0),
//                                                                               borderRadius: BorderRadius.circular(5.0),
//                                                                               color: Colors.orange,
//                                                                             ),
//                                                                             child:
//                                                                                 Text(
//                                                                               textAlign: TextAlign.center,
//                                                                               'قيد قبول البلاغ',
//                                                                               style: TextStyle(
//                                                                                 fontSize: fontSize,
//                                                                                 color: Colors.white,
//                                                                               ),
//                                                                             ),
//                                                                           ),
//                                                                   ),
//                                                                   Expanded(
//                                                                     child: item['complaintType'] !=
//                                                                             "لم يدرج نوع الكسر"
//                                                                         ? Container(
//                                                                             margin:
//                                                                                 const EdgeInsets.all(3.0),
//                                                                             padding:
//                                                                                 const EdgeInsets.symmetric(horizontal: 3.0),
//                                                                             decoration:
//                                                                                 BoxDecoration(
//                                                                               border: Border.all(color: Colors.green, width: 1.0),
//                                                                               borderRadius: BorderRadius.circular(5.0),
//                                                                               color: Colors.green,
//                                                                             ),
//                                                                             child:
//                                                                                 Text(
//                                                                               textAlign: TextAlign.center,
//                                                                               '${item['complaintType']}',
//                                                                               style: TextStyle(
//                                                                                 fontSize: fontSize,
//                                                                                 color: Colors.white,
//                                                                               ),
//                                                                             ),
//                                                                           )
//                                                                         : Container(
//                                                                             margin:
//                                                                                 const EdgeInsets.all(3.0),
//                                                                             padding:
//                                                                                 const EdgeInsets.symmetric(horizontal: 3.0),
//                                                                             decoration:
//                                                                                 BoxDecoration(
//                                                                               border: Border.all(color: Colors.orange, width: 1.0),
//                                                                               borderRadius: BorderRadius.circular(5.0),
//                                                                               color: Colors.orange,
//                                                                             ),
//                                                                             child:
//                                                                                 Text(
//                                                                               textAlign: TextAlign.center,
//                                                                               'لم يدرج نوع الكسر',
//                                                                               style: TextStyle(
//                                                                                 fontSize: fontSize,
//                                                                                 color: Colors.white,
//                                                                               ),
//                                                                             ),
//                                                                           ),
//                                                                   ),
//                                                                 ],
//                                                               )
//                                                             ],
//                                                           ),
//                                                         ),
//                                                       ),
//                                                       // ALL ICON BUTTONS
//                                                       Row(
//                                                         mainAxisAlignment:
//                                                             MainAxisAlignment
//                                                                 .spaceAround,
//                                                         children: [
//                                                           // GIS Map
//                                                           Expanded(
//                                                             child: IconButton(
//                                                               tooltip:
//                                                                   'التوجهه للخريطة GIS Map',
//                                                               hoverColor:
//                                                                   Colors.yellow,
//                                                               onPressed: () {
//                                                                 log("Start Gis Map ${item['gisLink']}");
//                                                                 if (item[
//                                                                         'gisLink'] ==
//                                                                     'لم يدرج') {
//                                                                   //TODO:REDIRECT-TO-GOOGLE-MAP
//                                                                   CustomBrowserRedirect
//                                                                       .openInBrowser(
//                                                                           'https://www.google.com/maps/search/?api=1&query=${item['latitude']},${item['longitude']}');
//                                                                 } else {
//                                                                   CustomBrowserRedirect
//                                                                       .openInBrowser(
//                                                                           item[
//                                                                               'gisLink']);
//                                                                 }
//                                                               },
//                                                               icon: const Icon(
//                                                                   Icons
//                                                                       .open_in_browser,
//                                                                   color: Colors
//                                                                       .blue),
//                                                             ),
//                                                           ),
//                                                           // Voice Call
//                                                           Expanded(
//                                                             child: IconButton(
//                                                               tooltip:
//                                                                   'اجراء مكالمة صوتية',
//                                                               hoverColor:
//                                                                   Colors.yellow,
//                                                               onPressed: () =>
//                                                                   CustomBrowserRedirect
//                                                                       .openInBrowser(
//                                                                           "https://meet.jit.si/${item['complaintAddress']}"),
//                                                               icon: const Icon(
//                                                                   Icons.call,
//                                                                   color: Colors
//                                                                       .green),
//                                                             ),
//                                                           ),
//                                                           // Tracking
//                                                           Expanded(
//                                                             child: IconButton(
//                                                               tooltip:
//                                                                   'بدء تتبع فنى الهندسة',
//                                                               hoverColor:
//                                                                   Colors.yellow,
//                                                               onPressed: () {
//                                                                 log("Start Traking ${item['complaintId']}");
//                                                                 if (item[
//                                                                         'isTracked'] ==
//                                                                     0) {
//                                                                   ScaffoldMessenger.of(
//                                                                           context)
//                                                                       .showSnackBar(
//                                                                     const SnackBar(
//                                                                       content:
//                                                                           Text(
//                                                                         'البلاغ قيد القبول وجارى التفعيل',
//                                                                         textDirection:
//                                                                             TextDirection.rtl,
//                                                                         textAlign:
//                                                                             TextAlign.center,
//                                                                       ),
//                                                                     ),
//                                                                   );
//                                                                 } else {
//                                                                   context.go(
//                                                                       '/tracking/${item['complaintAddress']}/${item['latitude']}/${item['longitude']}/${item['recipientUser']}');
//                                                                 }
//                                                               },
//                                                               icon: const Icon(
//                                                                   Icons
//                                                                       .location_on,
//                                                                   color: Colors
//                                                                       .red),
//                                                             ),
//                                                           ),
//                                                           // Store Inventory
//                                                           Expanded(
//                                                             child: IconButton(
//                                                               tooltip:
//                                                                   'جرد مخزن',
//                                                               hoverColor:
//                                                                   Colors.yellow,
//                                                               onPressed:
//                                                                   () async {
//                                                                 if (item[
//                                                                         'recipientDestination'] ==
//                                                                     'لم يدرج') {
//                                                                   ScaffoldMessenger.of(
//                                                                           context)
//                                                                       .showSnackBar(
//                                                                     const SnackBar(
//                                                                       content:
//                                                                           Text(
//                                                                         'عفوا, لايمكن إظهار جرد المخزن قبل تخصيص الهندسه',
//                                                                         textDirection:
//                                                                             TextDirection.rtl,
//                                                                         textAlign:
//                                                                             TextAlign.center,
//                                                                       ),
//                                                                     ),
//                                                                   );
//                                                                 } else {
//                                                                   await DioNetworkRepos()
//                                                                       .getStoreNameByHandasahName(
//                                                                           item[
//                                                                               'recipientDestination'])
//                                                                       .then(
//                                                                           (value) {
//                                                                     storeName =
//                                                                         value[
//                                                                             'storeName'];
//                                                                   });
//                                                                   DioNetworkRepos()
//                                                                       .excuteTempStoreQty(
//                                                                           storeName);
//                                                                   //TODO: 17-10-2026
//                                                                   storeName !=
//                                                                           ""
//                                                                       ? context.go(
//                                                                           '/integrate-with-stores/$storeName')
//                                                                       : ScaffoldMessenger.of(
//                                                                               context)
//                                                                           .showSnackBar(
//                                                                           const SnackBar(
//                                                                             content:
//                                                                                 Text(
//                                                                               'عفوا, لايمكن إظهار جرد المخزن ',
//                                                                               textDirection: TextDirection.rtl,
//                                                                               textAlign: TextAlign.center,
//                                                                             ),
//                                                                           ),
//                                                                         );
//                                                                 }
//                                                               },
//                                                               icon: const Icon(
//                                                                   Icons
//                                                                       .store_outlined,
//                                                                   color: Colors
//                                                                       .indigo),
//                                                             ),
//                                                           ),
//                                                           // Labs Integration
//                                                           // Expanded(
//                                                           //   child: IconButton(
//                                                           //     tooltip:
//                                                           //         'الربط مع المعامل',
//                                                           //     hoverColor:
//                                                           //         Colors.yellow,
//                                                           //     onPressed: () {
//                                                           //       StaticVariables
//                                                           //               .labCode =
//                                                           //           convertHandasahToLabCode(
//                                                           //               item[
//                                                           //                   'recipientUser']);
//                                                           //       StaticVariables
//                                                           //               .labName =
//                                                           //           convertLabCodeToLabName(
//                                                           //               StaticVariables
//                                                           //                   .labCode);
//                                                           //       log("LAB_CODE: ${StaticVariables.labCode}");
//                                                           //       log("LAB_NAME: ${StaticVariables.labName}");
//                                                           //       //TODO: 17-10-2026
//                                                           //       StaticVariables
//                                                           //                   .labName !=
//                                                           //               ""
//                                                           //           ? context.go(
//                                                           //               '/integration-with-labs')
//                                                           //           : ScaffoldMessenger.of(
//                                                           //                   context)
//                                                           //               .showSnackBar(
//                                                           //               const SnackBar(
//                                                           //                 content:
//                                                           //                     Text(
//                                                           //                   'عفوا, لايمكن إظهار بيانات هذا المعمل ',
//                                                           //                   textDirection:
//                                                           //                       TextDirection.rtl,
//                                                           //                   textAlign:
//                                                           //                       TextAlign.center,
//                                                           //                 ),
//                                                           //               ),
//                                                           //             );
//                                                           //     },
//                                                           //     icon: const Icon(
//                                                           //         Icons
//                                                           //             .report_gmailerrorred,
//                                                           //         color: Colors
//                                                           //             .cyan),
//                                                           //   ),
//                                                           // ),
//                                                           // GPS Car Tracking
//                                                           Expanded(
//                                                             child: IconButton(
//                                                               tooltip:
//                                                                   'تتبع سيارة GPS',
//                                                               hoverColor:
//                                                                   Colors.yellow,
//                                                               onPressed: () {},
//                                                               icon: const Icon(
//                                                                   Icons
//                                                                       .car_rental,
//                                                                   color: Colors
//                                                                       .indigo),
//                                                             ),
//                                                           ),
//                                                           // Mobile Emergency Room
//                                                           Expanded(
//                                                             child: IconButton(
//                                                               tooltip:
//                                                                   "غرفة الطوارئ المتحركة",
//                                                               hoverColor:
//                                                                   Colors.yellow,
//                                                               onPressed: () {
//                                                                 CustomBrowserRedirect
//                                                                     .openInBrowser(
//                                                                         "https://meet.jit.si/mobileEmergencyRoom");
//                                                               },
//                                                               icon: const Icon(
//                                                                   Icons
//                                                                       .car_crash,
//                                                                   color: Colors
//                                                                       .purple),
//                                                             ),
//                                                           ),
//                                                           // Camera System
//                                                           Expanded(
//                                                             child: IconButton(
//                                                               tooltip:
//                                                                   'نظام الكاميرات',
//                                                               hoverColor:
//                                                                   Colors.yellow,
//                                                               onPressed: () {
//                                                                 const url =
//                                                                     mobileCarIpCameratbaseUrlLocalHost;
//                                                                 CustomBrowserRedirect
//                                                                     .openInBrowser(
//                                                                         url);
//                                                               },
//                                                               icon: const Icon(
//                                                                   Icons
//                                                                       .video_camera_back,
//                                                                   color: Colors
//                                                                       .black),
//                                                             ),
//                                                           ),
//                                                           // SCADA Integration
//                                                           Expanded(
//                                                             child: IconButton(
//                                                               tooltip:
//                                                                   'الربط مع الاسكادا',
//                                                               hoverColor:
//                                                                   Colors.yellow,
//                                                               onPressed: () {
//                                                                 CustomBrowserRedirect
//                                                                     .openInBrowser(
//                                                                         'http://41.33.226.211:8070/roundpoint');
//                                                               },
//                                                               icon: const Icon(
//                                                                   Icons
//                                                                       .dashboard_customize_outlined,
//                                                                   color: Colors
//                                                                       .orange),
//                                                             ),
//                                                           ),
//                                                           // Complaint Info - Using PopupMenuButton for reliable menu
//                                                           Expanded(
//                                                             child:
//                                                                 PopupMenuButton<
//                                                                     String>(
//                                                               tooltip:
//                                                                   'عرض بيانات البلاغ',
//                                                               offset:
//                                                                   const Offset(
//                                                                       0, -10),
//                                                               color:
//                                                                   Colors.white,
//                                                               elevation: 6,
//                                                               shape:
//                                                                   RoundedRectangleBorder(
//                                                                 borderRadius:
//                                                                     BorderRadius
//                                                                         .circular(
//                                                                             14),
//                                                               ),
//                                                               onSelected: (value) =>
//                                                                   _handleAction(
//                                                                       value,
//                                                                       item),
//                                                               itemBuilder:
//                                                                   (context) => [
//                                                                 _buildPopupMenuItem(
//                                                                   value:
//                                                                       'details',
//                                                                   icon: Icons
//                                                                       .remove_red_eye_outlined,
//                                                                   iconColor:
//                                                                       Colors
//                                                                           .blue,
//                                                                   label:
//                                                                       'عرض التفاصيل',
//                                                                 ),
//                                                                 _buildPopupMenuItem(
//                                                                   value:
//                                                                       'location',
//                                                                   icon: Icons
//                                                                       .location_on_outlined,
//                                                                   iconColor:
//                                                                       Colors
//                                                                           .teal,
//                                                                   label:
//                                                                       'عرض الموقع',
//                                                                 ),
//                                                                 _buildPopupMenuItem(
//                                                                   value:
//                                                                       'whatsapp',
//                                                                   icon: Icons
//                                                                       .chat_outlined,
//                                                                   iconColor:
//                                                                       Colors
//                                                                           .green,
//                                                                   label:
//                                                                       'إرسال إلى واتساب',
//                                                                 ),
//                                                                 _buildPopupMenuItem(
//                                                                   value:
//                                                                       'urgent',
//                                                                   icon: Icons
//                                                                       .bolt_outlined,
//                                                                   iconColor: Colors
//                                                                       .deepOrange,
//                                                                   label:
//                                                                       'استعجال',
//                                                                 ),
//                                                                 _buildPopupMenuItem(
//                                                                   value:
//                                                                       'forward',
//                                                                   icon: Icons
//                                                                       .forward_outlined,
//                                                                   iconColor: Colors
//                                                                       .cyan
//                                                                       .shade700,
//                                                                   label:
//                                                                       'إعادة توجيه',
//                                                                 ),
//                                                                 _buildPopupMenuItem(
//                                                                   value:
//                                                                       'link_informant',
//                                                                   icon: Icons
//                                                                       .link,
//                                                                   iconColor:
//                                                                       Colors
//                                                                           .purple,
//                                                                   label:
//                                                                       'ربط كمكرر',
//                                                                 ),
//                                                                 _buildPopupMenuItem(
//                                                                   value:
//                                                                       'approval',
//                                                                   icon: Icons
//                                                                       .check_circle_outline,
//                                                                   iconColor: Colors
//                                                                       .green
//                                                                       .shade700,
//                                                                   label:
//                                                                       'تم الحصول على الموافقة',
//                                                                 ),
//                                                                 const PopupMenuItem<
//                                                                     String>(
//                                                                   enabled:
//                                                                       false,
//                                                                   height: 1,
//                                                                   padding:
//                                                                       EdgeInsets
//                                                                           .zero,
//                                                                   child: Divider(
//                                                                       height:
//                                                                           1),
//                                                                 ),
//                                                                 _buildPopupMenuItem(
//                                                                     value:
//                                                                         'close',
//                                                                     icon: Icons
//                                                                         .close_outlined,
//                                                                     iconColor:
//                                                                         Colors
//                                                                             .red
//                                                                             .shade600,
//                                                                     label:
//                                                                         'إغلاق البلاغ'),
//                                                                 _buildPopupMenuItem(
//                                                                   value:
//                                                                       'delete',
//                                                                   icon: Icons
//                                                                       .delete_outline,
//                                                                   iconColor:
//                                                                       Colors
//                                                                           .red,
//                                                                   label: 'حذف',
//                                                                   labelColor:
//                                                                       Colors
//                                                                           .red,
//                                                                 ),
//                                                               ],
//                                                               child: const Icon(
//                                                                 Icons.info,
//                                                                 color: Colors
//                                                                     .blueAccent,
//                                                               ),
//                                                             ),
//                                                           ),
//                                                         ],
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 );
//                                               },
//                                             );
//                                           }
//                                           return const Center(
//                                             child:
//                                                 Text('لا يوجد بلاغات مفتوحة'),
//                                           );
//                                         }),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//           ),
//         ],
//       ),
//       drawer: CustomDrawer(
//         title: 'الاعطال الواردة من الخط الساخن',
//         getLocs: getAllHotLineAddresses,
//         onTap: (itemData) {
//           try {
//             StaticVariables.hotlineAddress = itemData['address'];
//             StaticVariables.hotlineId = itemData['id'];
//             StaticVariables.hotlineX = itemData['x'];
//             StaticVariables.hotlineY = itemData['y'];
//             StaticVariables.hotlinecaseReportDateTime =
//                 itemData['caseReportDateTime'];
//             StaticVariables.hotlinefinalClosed = itemData['finalClosed'];
//             StaticVariables.hotlinereporterName = itemData['reporterName'];
//             StaticVariables.hotlinemainStreet = itemData['mainStreet'];
//             StaticVariables.hotlineStreet = itemData['street'];
//             StaticVariables.hotlinecaseType = itemData['caseType'];

//             DioNetworkRepos().postHotLineDataList(
//               id: StaticVariables.hotlineId,
//               caseReportDateTime: StaticVariables.hotlinecaseReportDateTime,
//               caseType: StaticVariables.hotlinecaseType,
//               finalClosed: StaticVariables.hotlinefinalClosed,
//               mainStreet: StaticVariables.hotlinemainStreet,
//               reporterName: StaticVariables.hotlinereporterName,
//               street: StaticVariables.hotlineStreet,
//               x: StaticVariables.hotlineX,
//               y: StaticVariables.hotlineY,
//               address: StaticVariables.hotlineAddress,
//             );
//             _getCoordinatesFromAddress(StaticVariables.hotlineAddress);

//             getLocsAfterGetCoordinatesAndGis =
//                 DioNetworkRepos().getAllComplaintsNotFinished();
//             // DioNetworkRepos().getAllComplaintsNotFinished();
//             // getLocsByHandasahNameAndTechinicianName = DioNetworkRepos()
//             //     .getLocByHandasahAndTechnician("لم يدرج", "لم يدرج");
//           } catch (e) {
//             log(e.toString());
//           }
//           Navigator.of(context).pop();
//         },
//       ),
//     );
//   }

//   // ==========================================================================
//   // Action handlers
//   // ==========================================================================

//   void _handleAction(String selected, Map<String, dynamic> item) {
//     switch (selected) {
//       case 'details':
//         _showDetailsDialog(item);
//         break;
//       case 'location':
//         _handleShowLocation(item);
//         break;
//       case 'whatsapp':
//         _handleSendToWhatsapp(item);
//         break;
//       case 'close':
//         _handleCloseComplaint(item);
//         break;
//       case 'urgent':
//         _handleMarkUrgent(item);
//         break;
//       case 'forward':
//         _handleForwardComplaint(item);
//         break;
//       case 'link_informant':
//         _handleLinkAsInformant(item);
//         break;
//       case 'approval':
//         _handleApprovalObtained(item);
//         break;
//       case 'delete':
//         _handleDeleteComplaint(item);
//         break;
//     }
//   }

//   PopupMenuItem<String> _buildPopupMenuItem({
//     required String value,
//     required IconData icon,
//     required Color iconColor,
//     required String label,
//     Color? labelColor,
//   }) {
//     return PopupMenuItem<String>(
//       value: value,
//       height: 42,
//       child: Directionality(
//         textDirection: TextDirection.rtl,
//         child: Row(
//           children: [
//             Container(
//               width: 28,
//               height: 28,
//               alignment: Alignment.center,
//               decoration: BoxDecoration(
//                 color: iconColor.withOpacity(0.12),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(icon, size: 16, color: iconColor),
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: Text(
//                 label,
//                 textAlign: TextAlign.right,
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontFamily: 'Cairo',
//                   fontWeight: FontWeight.w500,
//                   color: labelColor ?? Colors.black87,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // --- Action handlers ---------------------------------------------------
//   void _handleShowLocation(Map<String, dynamic> item) {
//     final lat = item['latitude']?.toString();
//     final lng = item['longitude']?.toString();
//     final gisUrl = item['gisLink']?.toString();
//     if (lat == null || lng == null || lat.isEmpty || lng.isEmpty) {
//       _showActionSnackbar('لا يوجد إحداثيات مسجلة لهذا البلاغ', isError: true);
//       return;
//     }
//     debugPrint('gisUrl:--> $gisUrl');

//     if (gisUrl != null &&
//         gisUrl != 'لم يدرج' &&
//         gisUrl.isNotEmpty &&
//         lng.isNotEmpty &&
//         lat.isNotEmpty) {
//       CustomBrowserRedirect.openInBrowser(gisUrl);
//     } else {
//       CustomBrowserRedirect.openInBrowser(
//           'https://www.google.com/maps/search/?api=1&query=$lat,$lng');
//     }
//   }

//   Future<void> _handleSendToWhatsapp(Map<String, dynamic> item) async {
//     try {
//       final whatsAppInstalled = await MainWhatsAppService.isWhatsAppInstalled();
//       if (!whatsAppInstalled) {
//         await MainWhatsAppDialog.showCopyDialog(
//           context: context,
//           complaint: item,
//         );
//         return;
//       }

//       String phoneNumber = '00201032743609';

//       final userPhone = await MainWhatsAppDialog.showPhoneNumberDialog(
//         context: context,
//         initialPhoneNumber:
//             phoneNumber.isNotEmpty ? phoneNumber : '00201032743609',
//         complaint: item,
//       );

//       if (userPhone == null || userPhone.isEmpty) {
//         _showActionSnackbar('تم إلغاء الإرسال');
//         return;
//       }

//       phoneNumber = userPhone;

//       await MainWhatsAppService.sendToWhatsAppNumber(
//         complaint: item,
//         phoneNumber: phoneNumber,
//       );

//       _showActionSnackbar('تم فتح واتساب بنجاح');
//     } catch (e) {
//       debugPrint('WhatsApp error: $e');

//       try {
//         await MainWhatsAppService.copyComplaintToClipboard(item);
//         _showActionSnackbar(
//           'حدث خطأ، تم نسخ البيانات إلى الحافظة',
//           isError: true,
//         );
//       } catch (copyError) {
//         _showActionSnackbar(
//           'حدث خطأ: ${e.toString()}',
//           isError: true,
//         );
//       }
//     }
//   }

//   void _handleCloseComplaint(Map<String, dynamic> item) {
//     handleCloseComplaint(
//       context,
//       item,
//       fetchData,
//     );
//   }

//   void _handleMarkUrgent(Map<String, dynamic> item) {
//     handleMarkUrgent(
//       context,
//       item,
//       fetchData,
//     );
//   }

//   void _handleForwardComplaint(Map<String, dynamic> item) {
//     handleForwardComplaint(
//       context,
//       item,
//       fetchData,
//     );
//   }

//   void _handleLinkAsInformant(Map<String, dynamic> item) {
//     handleLinkAsInformant(
//       context,
//       item,
//       fetchData,
//     );
//   }

//   void _handleApprovalObtained(Map<String, dynamic> item) {
//     handleApprovalObtained(
//       context,
//       item,
//       fetchData,
//     );
//   }

//   void _handleDeleteComplaint(Map<String, dynamic> item) {
//     handleDeleteComplaint(
//       context,
//       item,
//       fetchData,
//     );
//   }

//   void _showActionSnackbar(String message, {bool isError = false}) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           message,
//           textDirection: TextDirection.rtl,
//           textAlign: TextAlign.center,
//           style: const TextStyle(fontFamily: 'Cairo'),
//         ),
//         backgroundColor: isError ? Colors.red : Colors.indigo,
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }

//   void _showDetailsDialog(Map<String, dynamic> item) {
//     final entries = <MapEntry<String, String>>[
//       MapEntry('رقم البلاغ', item['complaintId']?.toString() ?? ''),
//       MapEntry('رقم البلاغ المرجعي', item['reportNumber']?.toString() ?? ''),
//       MapEntry('الحي', item['neighborhood']?.toString() ?? ''),
//       MapEntry('ربط مكرر', item['repeatComplaintNumber']?.toString() ?? ''),
//       MapEntry('مصدر البلاغ', item['complaintSource']?.toString() ?? ''),
//       MapEntry('إسم المبلغ', item['reporterName']?.toString() ?? ''),
//       MapEntry('موبيل المبلغ', item['reporterPhone']?.toString() ?? ''),
//       MapEntry('العنوان', item['complaintAddress']?.toString() ?? ''),
//       MapEntry('حالة الإصلاح', item['complaintRepairStatus']?.toString() ?? ''),
//       MapEntry('جهة الاعتماد', item['approvalAuthority']?.toString() ?? ''),
//       MapEntry('نوع الكسر', item['pumpDiameter']?.toString() ?? ''),
//       MapEntry('نوع البلاغ', item['complaintType']?.toString() ?? ''),
//       MapEntry('مدى الخطورة', item['seriousStatus']?.toString() ?? ''),
//       MapEntry('الحالة', item['complaintStatus']?.toString() ?? ''),
//       MapEntry('ملاحظات البلاغ', item['complaintNote']?.toString() ?? ''),
//       MapEntry('جهة الاستلام', item['recipientDestination']?.toString() ?? ''),
//       MapEntry('فنى الهندسة', item['recipientUser']?.toString() ?? ''),
//       MapEntry('إسم المستلم', item['recipientName']?.toString() ?? ''),
//       MapEntry(
//           'إسم المستخدم الحالي', item['currentUsername']?.toString() ?? ''),
//       MapEntry('رابط الخريطة (GIS)', item['gisLink']?.toString() ?? ''),
//       MapEntry('خط الطول', item['longitude']?.toString() ?? ''),
//       MapEntry('خط العرض', item['latitude']?.toString() ?? ''),
//       MapEntry('القطاع', item['sectorName']?.toString() ?? ''),
//       MapEntry('رقم الاستعجال', item['urgencyNumber']?.toString() ?? ''),
//       MapEntry('تاريخ الإنشاء', _formatDateOnly(item['createdAt'])),
//       MapEntry('آخر تحديث', _formatDateOnly(item['updatedAt'])),
//       MapEntry('تاريخ الانتهاء', _formatDateOnly(item['finishedAt'])),
//     ];

//     showDialog(
//       context: context,
//       builder: (dialogContext) => Directionality(
//         textDirection: TextDirection.rtl,
//         child: AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(14),
//           ),
//           titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
//           title: Row(
//             children: [
//               const Icon(Icons.assignment_outlined, color: Colors.indigo),
//               const SizedBox(width: 8),
//               const Text(
//                 'تفاصيل البلاغ',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Colors.indigo,
//                   fontSize: 18,
//                   fontFamily: 'Cairo',
//                 ),
//               ),
//               const Spacer(),
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                 decoration: BoxDecoration(
//                   color:
//                       _statusColor(item['complaintStatus']).withOpacity(0.12),
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(
//                     color: _statusColor(item['complaintStatus']),
//                   ),
//                 ),
//                 child: Text(
//                   item['complaintStatus']?.toString() ?? '',
//                   style: TextStyle(
//                     color: _statusColor(item['complaintStatus']),
//                     fontWeight: FontWeight.bold,
//                     fontSize: 12,
//                     fontFamily: 'Cairo',
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           content: SizedBox(
//             width: 440,
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: entries
//                     .where((e) => e.value.isNotEmpty)
//                     .map(
//                       (e) => Container(
//                         margin: const EdgeInsets.only(bottom: 6),
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 10, vertical: 8),
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade50,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             SizedBox(
//                               width: 130,
//                               child: Text(
//                                 e.key,
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.indigo,
//                                   fontSize: 13,
//                                   fontFamily: 'Cairo',
//                                 ),
//                               ),
//                             ),
//                             Expanded(
//                               child: SelectableText(
//                                 e.value,
//                                 textAlign: TextAlign.right,
//                                 style: const TextStyle(
//                                   fontSize: 13,
//                                   fontFamily: 'Cairo',
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     )
//                     .toList(),
//               ),
//             ),
//           ),
//           actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
//           actions: [
//             TextButton.icon(
//               onPressed: () => Navigator.of(dialogContext).pop(),
//               icon: const Icon(Icons.close, size: 18),
//               label: const Text(
//                 'إغلاق',
//                 style: TextStyle(fontFamily: 'Cairo'),
//               ),
//               style: TextButton.styleFrom(foregroundColor: Colors.indigo),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   String _formatDateOnly(dynamic raw) {
//     if (raw == null) return '';
//     final parsed = DateTime.tryParse(raw.toString());
//     if (parsed == null) return raw.toString();
//     return '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
//   }

//   Color _statusColor(String? status) {
//     switch (status) {
//       case 'مفتوح':
//       case 'عالى الأهمية':
//         return Colors.red;
//       case 'متوسط الأهمية':
//         return Colors.orange;
//       case 'مغلق':
//       case 'عادى':
//         return Colors.green;
//       default:
//         return Colors.grey;
//     }
//   }
// }
