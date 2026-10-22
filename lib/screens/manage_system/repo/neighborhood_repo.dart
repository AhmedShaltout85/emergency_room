// lib/screens/manage_system/control/neighborhood_repo.dart

import 'package:dio/dio.dart';
import 'package:emergency_room/network/remote/remote_network_repos.dart';
import 'package:emergency_room/utils/app_constants.dart';
import 'package:flutter/foundation.dart';

import '../model/neighborhood_model.dart';
import 'handasah_repo.dart' show AppFailure; // reuse the same failure class

class NeighborhoodRepo {
  NeighborhoodRepo({Dio? dio}) : _dio = dio ?? DioNetworkRepos().dio;

  final Dio _dio;

  // Android emulator → http://10.0.2.2:9999 ; real device → your PC's LAN IP.
  static const String baseUrl =
      '$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/neighborhoods';

  /// GET /all
  Future<List<NeighborhoodModel>> getAll() => _guard(() async {
        final res = await _dio.get('$baseUrl/all');
        final data = res.data;
        if (data is! List) return <NeighborhoodModel>[];
        return data
            .map((e) => NeighborhoodModel.fromJson(e as Map<String, dynamic>))
            .toList();
      });

  /// GET /{id}
  Future<NeighborhoodModel> findById(int id) => _guard(() async {
        final res = await _dio.get('$baseUrl/$id');
        return NeighborhoodModel.fromJson(res.data as Map<String, dynamic>);
      });

  /// POST /create
  Future<NeighborhoodModel> create(NeighborhoodModel model) => _guard(() async {
        final res = await _dio.post('$baseUrl/create', data: model.toJson());
        return NeighborhoodModel.fromJson(res.data as Map<String, dynamic>);
      });

  /// PUT /{id}
  Future<NeighborhoodModel> update(int id, NeighborhoodModel model) =>
      _guard(() async {
        final res = await _dio.put('$baseUrl/$id', data: model.toJson());
        return NeighborhoodModel.fromJson(res.data as Map<String, dynamic>);
      });

  /// DELETE /{id}
  Future<String> remove(int id) => _guard(() async {
        final res = await _dio.delete('$baseUrl/$id');
        return res.data?.toString() ?? '';
      });

  // ---------------------------------------------------------------------

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      _debugLog(e);
      throw _mapDioError(e);
    } on TypeError {
      throw const AppFailure('تعذر قراءة البيانات القادمة من الخادم');
    }
  }

  /// Debug-only: prints the request and the server's raw error body.
  void _debugLog(DioException e) {
    if (!kDebugMode) return;
    debugPrint('── NeighborhoodRepo error ──────────────');
    debugPrint('${e.requestOptions.method} ${e.requestOptions.uri}');
    debugPrint('status: ${e.response?.statusCode}');
    debugPrint('response: ${e.response?.data}');
    debugPrint('─────────────────────────────────────────────');
  }

  /// Extracts a readable message from the server's error body, if any.
  String? _serverMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final msg = data['message'];
      if (msg is String && msg.trim().isNotEmpty) return msg.trim();
    }
    if (data is String) {
      final text = data.trim();
      if (text.isNotEmpty && text.length < 200 && !text.startsWith('<')) {
        return text;
      }
    }
    return null;
  }

  AppFailure _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const AppFailure('انتهت مهلة الاتصال بالخادم، حاول مرة أخرى');
      case DioExceptionType.connectionError:
        return const AppFailure('تعذر الوصول إلى الخادم');
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        final serverMsg = _serverMessage(e);
        if (code == 404) {
          return AppFailure(serverMsg ?? 'الحي غير موجود (404)',
              statusCode: code);
        }
        if (code == 409) {
          return AppFailure(serverMsg ?? 'الحي موجود بالفعل', statusCode: code);
        }
        if (code != null && code >= 500) {
          return AppFailure(serverMsg ?? 'حدث خطأ في الخادم', statusCode: code);
        }
        return AppFailure(serverMsg ?? 'تعذر تنفيذ الطلب (${code ?? '-'})',
            statusCode: code);
      case DioExceptionType.cancel:
        return const AppFailure('تم إلغاء الطلب');
      default:
        return const AppFailure('حدث خطأ غير متوقع');
    }
  }
}
