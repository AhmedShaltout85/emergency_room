
import 'dart:convert';

import 'package:http/http.dart' as http;
import '../../utils/app_constants.dart';
import '../models/station_data.dart';

class ApiService {
  // Static fields not yet provided by the live API.
  // Keyed by the same station key used in the API's "data" map.
  static const Map<String, Map<String, dynamic>> _staticStationInfo = {
    "Manshia": {
      "location": "31.185514, 29.934137",
      "desgin_capacity": 380.000,
      "actual_capacity": 356.045,
    },
    "Manshia2": {
      "location": "31.175664, 29.986611",
      "desgin_capacity": 240.000,
      "actual_capacity": 204.579,
    },
    "Roundpoint": {
      "location": "31.200825, 29.919157",
      "desgin_capacity": 510.000,
      "actual_capacity": 356.796,
    },
    "Siouf": {
      "location": "31.222324, 29.988280",
      "desgin_capacity": 840.000,
      "actual_capacity": 709.139,
    },
    "Nozha": {
      "location": "31.198524, 29.952943",
      "desgin_capacity": 200.000,
      "actual_capacity": 117.595,
    },
    "Maamoura": {
      "location": "31.290460, 30.050855",
      "desgin_capacity": 240.000,
      "actual_capacity": 132.445,
    },
    "NobariaExtension": {
      "location": null,
      "desgin_capacity": null,
      "actual_capacity": null,
    },
  };

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

  List<StationData> _parseApiResponse(Map<String, dynamic> jsonData) {
    final stationsJson = jsonData['data'] as Map<String, dynamic>;

    return stationsJson.entries.map((entry) {
      final stationName = entry.key;
      final stationData = entry.value;

      // Merge in static fields (location / design & actual capacity)
      // that the live API doesn't return yet.
      final staticInfo = _staticStationInfo[stationName];

      return StationData(
        name: stationName,
        pressure: _parseDouble(stationData['pressure']),
        rawPumps: _parseInt(stationData['total_raw_pumps']),
        treatedPumps: _parseInt(stationData['total_treated_pumps']),
        level: _parseDouble(stationData['level']),
        location: staticInfo?['location'] as String?,
        desginCapacity: _parseDouble(staticInfo?['desgin_capacity']),
        actualCapacity: _parseDouble(staticInfo?['actual_capacity']),
      );
    }).toList();
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
