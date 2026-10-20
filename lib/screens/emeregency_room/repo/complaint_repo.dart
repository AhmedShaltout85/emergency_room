// lib/screens/manage_system/control/complaint_repo.dart

import 'package:dio/dio.dart';
import 'package:emergency_room/network/remote/remote_network_repos.dart';
import 'package:emergency_room/screens/manage_system/repo/handasah_repo.dart';
import 'package:flutter/foundation.dart';

import '../model/complaint_model.dart';

class ComplaintRepo {
  ComplaintRepo({Dio? dio}) : _dio = dio ?? DioNetworkRepos().dio;

  final Dio _dio;

  // Android emulator → http://10.0.2.2:9999 ; real device → your PC's LAN IP.
  static const String baseUrl =
      'http://localhost:9999/pick-location/api/v1/complaints';

  static String _e(String v) => Uri.encodeComponent(v);

  // ------------------------------------------------------------- queries

  /// GET /all
  Future<List<ComplaintModel>> getAll() => _list('$baseUrl/all');

  /// GET /{id}
  Future<ComplaintModel> findById(int id) =>
      _one(() => _dio.get('$baseUrl/$id'));

  /// GET /neighborhood/{neighborhood}
  Future<List<ComplaintModel>> findByNeighborhood(String neighborhood) =>
      _list('$baseUrl/neighborhood/${_e(neighborhood)}');

  /// GET /status/{complaintStatus}
  Future<List<ComplaintModel>> findByComplaintStatus(String status) =>
      _list('$baseUrl/status/${_e(status)}');

  /// GET /user/{currentUsername}
  Future<List<ComplaintModel>> findByCurrentUsername(String username) =>
      _list('$baseUrl/user/${_e(username)}');

  /// GET /finished/{isFinished}   (0 = open, 1 = finished)
  Future<List<ComplaintModel>> findByIsFinished(int isFinished) =>
      _list('$baseUrl/finished/$isFinished');

  /// GET /complaint-type/{complaintType}
  Future<List<ComplaintModel>> findByComplaintType(String type) =>
      _list('$baseUrl/complaint-type/${_e(type)}');

  /// GET /sector-name/{sectorName}
  Future<List<ComplaintModel>> findBySectorName(String sector) =>
      _list('$baseUrl/sector-name/${_e(sector)}');

  // ----------------------------------------------------------- mutations

  /// POST /create
  Future<ComplaintModel> create(ComplaintModel c) =>
      _one(() => _dio.post('$baseUrl/create', data: c.toJson()));

  /// PUT /{id}
  Future<ComplaintModel> update(int id, ComplaintModel c) =>
      _one(() => _dio.put('$baseUrl/$id', data: c.toJson()));

  // The partial-update endpoints all take a ComplaintDTO body. The full
  // model is sent (with the changed value already applied) so it works no
  // matter which DTO field(s) each service method reads.

  /// PUT /{id}/repeat-complaint-number
  Future<ComplaintModel> updateRepeatComplaintNumber(
          int id, ComplaintModel c) =>
      _one(() =>
          _dio.put('$baseUrl/$id/repeat-complaint-number', data: c.toJson()));

  /// PUT /{id}/urgency-number
  Future<ComplaintModel> updateUrgencyNumber(int id, ComplaintModel c) =>
      _one(() => _dio.put('$baseUrl/$id/urgency-number', data: c.toJson()));

  /// PUT /{id}/recipient
  Future<ComplaintModel> updateRecipient(int id, ComplaintModel c) =>
      _one(() => _dio.put('$baseUrl/$id/recipient', data: c.toJson()));

  /// PUT /{id}/tracked
  Future<ComplaintModel> updateTracked(int id, ComplaintModel c) =>
      _one(() => _dio.put('$baseUrl/$id/tracked', data: c.toJson()));

  /// PUT /{id}/status-flags
  Future<ComplaintModel> updateStatusFlags(int id, ComplaintModel c) =>
      _one(() => _dio.put('$baseUrl/$id/status-flags', data: c.toJson()));

  /// PUT /{id}/approval-authority
  Future<ComplaintModel> updateApprovalAuthority(int id, ComplaintModel c) =>
      _one(() => _dio.put('$baseUrl/$id/approval-authority', data: c.toJson()));

  /// PUT /{id}/recipient-destination
  Future<ComplaintModel> updateRecipientDestination(int id, ComplaintModel c) =>
      _one(() =>
          _dio.put('$baseUrl/$id/recipient-destination', data: c.toJson()));

  /// PUT /{id}/finish   (no body)
  Future<ComplaintModel> finish(int id) =>
      _one(() => _dio.put('$baseUrl/$id/finish'));

  /// PUT /{id}/delete   (soft delete, no body)
  Future<ComplaintModel> softDelete(int id) =>
      _one(() => _dio.put('$baseUrl/$id/delete'));

  /// DELETE /{id}   (permanent)
  Future<String> remove(int id) => _guard(() async {
        final res = await _dio.delete('$baseUrl/$id');
        return res.data?.toString() ?? '';
      });

  // ------------------------------------------------------------ plumbing

  Future<List<ComplaintModel>> _list(String url) => _guard(() async {
        final res = await _dio.get(url);
        final data = res.data;
        if (data is! List) return <ComplaintModel>[];
        return data
            .map((e) => ComplaintModel.fromJson(e as Map<String, dynamic>))
            .toList();
      });

  Future<ComplaintModel> _one(Future<Response<dynamic>> Function() call) =>
      _guard(() async {
        final res = await call();
        return ComplaintModel.fromJson(res.data as Map<String, dynamic>);
      });

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
    debugPrint('── ComplaintRepo error ──────────────────────');
    debugPrint('${e.requestOptions.method} ${e.requestOptions.uri}');
    debugPrint('status: ${e.response?.statusCode}');
    debugPrint('response: ${e.response?.data}');
    debugPrint('─────────────────────────────────────────────');
  }

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
          return AppFailure(serverMsg ?? 'البلاغ غير موجود (404)',
              statusCode: code);
        }
        if (code == 409) {
          return AppFailure(serverMsg ?? 'البلاغ موجود بالفعل',
              statusCode: code);
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
