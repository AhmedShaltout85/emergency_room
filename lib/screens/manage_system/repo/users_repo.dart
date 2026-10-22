// lib/screens/manage_system/control/users_repo.dart

import 'package:dio/dio.dart';
import 'package:emergency_room/network/remote/remote_network_repos.dart';
import 'package:emergency_room/utils/app_constants.dart';
import 'package:flutter/foundation.dart';

import '../model/user_model.dart';
import 'handasah_repo.dart' show AppFailure; // reuse the same failure class

class UsersRepo {
  UsersRepo({Dio? dio}) : _dio = dio ?? DioNetworkRepos().dio;

  final Dio _dio;

  // Android emulator → http://10.0.2.2:9999 ; real device → your PC's LAN IP.
  static const String baseUrl =
      '$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/users';

  /// GET /all
  Future<List<UserModel>> getAllUsers() => _guard(() async {
        final res = await _dio.get('$baseUrl/all');
        final data = res.data;
        if (data is! List) return <UserModel>[];
        return data
            .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
            .toList();
      });

  /// GET /{id}
  Future<UserModel> findById(int id) => _guard(() async {
        final res = await _dio.get('$baseUrl/$id');
        return UserModel.fromJson(res.data as Map<String, dynamic>);
      });

  /// POST /create-user
  Future<UserModel> create(UserModel user) => _guard(() async {
        final res =
            await _dio.post('$baseUrl/create-user', data: user.toJson());
        return UserModel.fromJson(res.data as Map<String, dynamic>);
      });

  /// GET /role/{role}/control-unit/{controlUnit} → list of names
  Future<List<String>> getNamesByRoleAndControlUnit(
    int role,
    String controlUnit,
  ) =>
      _guard(() async {
        final res = await _dio.get(
          '$baseUrl/role/$role/control-unit/${Uri.encodeComponent(controlUnit)}',
        );
        final data = res.data;
        if (data is List) return data.map((e) => e.toString()).toList();
        return <String>[];
      });

  /// DELETE /remove-user/{id}
  Future<String> remove(int id) => _guard(() async {
        final res = await _dio.delete('$baseUrl/remove-user/$id');
        return res.data?.toString() ?? '';
      });

  /// PUT /change-password
  Future<String> changePassword({
    required String userName,
    required String oldPassword,
    required String newPassword,
  }) =>
      _guard(() async {
        final res = await _dio.put(
          '$baseUrl/change-password',
          data: {
            'userName': userName,
            'oldPassword': oldPassword,
            'newPassword': newPassword,
          },
        );
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

  /// Prints the request and the server's raw response in debug mode only,
  /// so you can see exactly why the backend rejected a request.
  void _debugLog(DioException e) {
    if (!kDebugMode) return;
    debugPrint('── UsersRepo error ──────────────────────────');
    debugPrint('${e.requestOptions.method} ${e.requestOptions.uri}');
    debugPrint('status: ${e.response?.statusCode}');
    debugPrint('response: ${e.response?.data}');
    debugPrint('─────────────────────────────────────────────');
  }

  /// Extracts a readable message from the server's error body, if any.
  /// Works with Spring's default error JSON ({"message": ...}),
  /// with a plain-text body, and with ResponseStatusException messages.
  String? _serverMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final msg = data['message'];
      if (msg is String && msg.trim().isNotEmpty) return msg.trim();
    }
    if (data is String) {
      final text = data.trim();
      // Ignore HTML error pages and very long bodies.
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
        if (code == 401) {
          return AppFailure(
            serverMsg ?? 'كلمة المرور الحالية غير صحيحة',
            statusCode: code,
          );
        }
        if (code == 400) {
          return AppFailure(
            serverMsg ?? 'البيانات غير صحيحة',
            statusCode: code,
          );
        }
        if (code == 404) {
          return AppFailure(
            serverMsg ?? 'المسار أو العنصر غير موجود (404)',
            statusCode: code,
          );
        }
        if (code == 409) {
          return AppFailure(
            serverMsg ?? 'المستخدم موجود بالفعل',
            statusCode: code,
          );
        }
        if (code != null && code >= 500) {
          return AppFailure(
            serverMsg ?? 'حدث خطأ في الخادم',
            statusCode: code,
          );
        }
        return AppFailure(
          serverMsg ?? 'تعذر تنفيذ الطلب (${code ?? '-'})',
          statusCode: code,
        );
      case DioExceptionType.cancel:
        return const AppFailure('تم إلغاء الطلب');
      default:
        return const AppFailure('حدث خطأ غير متوقع');
    }
  }
}
