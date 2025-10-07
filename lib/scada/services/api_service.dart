// import 'dart:convert';
import 'dart:convert';

import 'package:http/http.dart' as http;
import '../../utils/dio_http_constants.dart';
import '../models/station_data.dart';

class ApiService {
  // static const String _baseUrl =
  //     'http://41.33.226.211:8070/api/data/stations-report';

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

      return StationData(
        name: stationName,
        pressure: _parseDouble(stationData['pressure']),
        rawPumps: _parseInt(stationData['total_raw_pumps']),
        treatedPumps: _parseInt(stationData['total_treated_pumps']),
        level: _parseDouble(stationData['level']),
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
