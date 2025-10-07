// lib/providers/station_provider.dart
import 'package:flutter/foundation.dart';
import '../models/station_data.dart';
import '../services/api_service.dart';

class StationProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<StationData> _stations = [];
  bool _isLoading = false;
  String _error = '';

  List<StationData> get stations => _stations;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchStationsData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _stations = await _apiService.fetchStationsData();
      _error = '';
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
