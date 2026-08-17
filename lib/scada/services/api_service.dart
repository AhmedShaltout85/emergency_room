
import 'dart:convert';

import 'package:http/http.dart' as http;
import '../../labs/utils/extract_lab_value.dart';
import '../../network/remote/remote_network_repos.dart';
import '../../utils/app_constants.dart';
import '../models/station_data.dart';

// Test codes used by the labs API (see labs_reports_dashboard_screen.dart).
const String _turbidityTestCode = '1'; // العكارة
const String _residualChlorineTestCode = '82'; // الكلور المتبقى

class ApiService {
  // Static fields not yet provided by the live API.
  // Keyed by the same station key used in the API's "data" map.
  static const Map<String, Map<String, dynamic>> _staticStationInfo = {
    "Manshia": {
      "min_pressure": 0.00,
      "max_pressure": 0.00,
      "location": "31.185514, 29.934137",
      "desgin_capacity": 380.000,
      "actual_capacity": 356.045,
      "lab_code": 11,
    },
    "Manshia2": {
       "min_pressure": 0.00,
      "max_pressure": 0.00,
      "location": "31.175664, 29.986611",
      "desgin_capacity": 240.000,
      "actual_capacity": 204.579,
      "lab_code": 8,
    },
    "Roundpoint": {
       "min_pressure": 0.00,
      "max_pressure": 0.00,
      "location": "31.200825, 29.919157",
      "desgin_capacity": 510.000,
      "actual_capacity": 356.796,
      "lab_code": 9,
    },
    "Siouf": {
       "min_pressure": 0.00,
      "max_pressure": 0.00,
      "location": "31.222324, 29.988280",
      "desgin_capacity": 840.000,
      "actual_capacity": 709.139,
      "lab_code": 10,
    },
    "Nozha": {
       "min_pressure": 2.00,
      "max_pressure": 2.00,
      "location": "31.198524, 29.952943",
      "desgin_capacity": 200.000,
      "actual_capacity": 117.595,
      "lab_code": 13,
    },
    "Maamoura": {
       "min_pressure": 1.00,
      "max_pressure": 1.00,
      "location": "31.290460, 30.050855",
      "desgin_capacity": 240.000,
      "actual_capacity": 132.445,
      "lab_code": 7,
    },
    "NobariaExtension": {
       "min_pressure": 0.00,
      "max_pressure": 0.00,
      "location": null,
      "desgin_capacity": null,
      "actual_capacity": null,
      "lab_code": null,
    },
  };

  final DioNetworkRepos _labs = DioNetworkRepos();

  Future<List<StationData>> fetchStationsData() async {
    try {
      final response = await http.get(Uri.parse(skadaStationsReportbaseUrl));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return _parseApiResponse(jsonData);
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
  }

  Future<List<StationData>> _parseApiResponse(
      Map<String, dynamic> jsonData) async {
    final stationsJson = jsonData['data'] as Map<String, dynamic>;

    final entries = stationsJson.entries.toList();
    // Build each station with its lab values in parallel.
    return Future.wait(entries.map((entry) async {
      final stationName = entry.key;
      final stationData = entry.value;

      // Merge in static fields (location / design & actual capacity / labCode)
      // that the live API doesn't return yet.
      final staticInfo = _staticStationInfo[stationName];
      final labCode = staticInfo?['lab_code'] as int?;

      double? turbidity;
      double? residualChlorine;
      if (labCode != null) {
        try {
          final results = await Future.wait([
            _safeFetchLab(labCode, _turbidityTestCode),
            _safeFetchLab(labCode, _residualChlorineTestCode),
          ]);
          turbidity = results[0];
          residualChlorine = results[1];
        } catch (_) {
          // Keep both null on any lab failure; SCADA data still renders.
        }
      }

      return StationData(
        name: stationName,
        minPressure: _parseDouble(staticInfo?['min_pressure']),
        pressure: _parseDouble(stationData['pressure']),
        maxPressure: _parseDouble(staticInfo?['max_pressure']),
        rawPumps: _parseInt(stationData['total_raw_pumps']),
        treatedPumps: _parseInt(stationData['total_treated_pumps']),
        level: _parseDouble(stationData['level']),
        location: staticInfo?['location'] as String?,
        desginCapacity: _parseDouble(staticInfo?['desgin_capacity']),
        actualCapacity: _parseDouble(staticInfo?['actual_capacity']),
        turbidity: turbidity,
        residualChlorine: residualChlorine,
        labCode: labCode,
      );
    }));
  }

  Future<double?> _safeFetchLab(int labCode, String testCode) async {
    try {
      final items =
          await _labs.getAllLabsItemsByTestValueAndDate(labCode, testCode);
      return extractLastLabValueByDate(items);
    } catch (_) {
      return null;
    }
  }

  double? _parseDouble(dynamic value) {
    if (value == null || value == '---') return null;
    final str = value.toString().split('/').first.trim();
    return double.tryParse(str);
  }

  int? _parseInt(dynamic value) {
    if (value == null || value == '---') return null;
    return int.tryParse(value.toString());
  }
}
