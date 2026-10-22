// lib/features/handasah/repos/handasah_repo.dart

import 'package:dio/dio.dart';
import 'package:emergency_room/network/remote/remote_network_repos.dart';
import 'package:emergency_room/screens/manage_system/model/handasah_model.dart';
import 'package:emergency_room/utils/app_constants.dart';


/// A user-friendly failure the UI/provider can display.
class AppFailure implements Exception {
  final String message;
  final bool isNoInternet;
  final int? statusCode;

  const AppFailure(this.message, {this.isNoInternet = false, this.statusCode});

  factory AppFailure.noInternet() => const AppFailure(
        'لا يوجد اتصال بالإنترنت',
        isNoInternet: true,
      );

  @override
  String toString() => message;
}

class HandasahRepo {
  HandasahRepo({Dio? dio}) : _dio = dio ?? DioNetworkRepos().dio;

  final Dio _dio;

  // Android emulator → http://10.0.2.2:9999 ; real device → your PC's LAN IP.
  static const String baseUrl =
      '$BASE_URI_IP_ADDRESS_LOCAL_HOST/pick-location/api/v1/handasah';

  /// GET /all → list of handasah names
  Future<List<String>> getAllNames() => _guard(() async {
        final res = await _dio.get('$baseUrl/all');
        final data = res.data;
        if (data is List) return data.map((e) => e.toString()).toList();
        return <String>[];
      });

  /// GET /{id}
  Future<HandasahModel> findById(int id) => _guard(() async {
        final res = await _dio.get('$baseUrl/$id');
        return HandasahModel.fromJson(res.data as Map<String, dynamic>);
      });

  /// GET /handasah-name/{handasahName}
  Future<HandasahModel> findByName(String name) => _guard(() async {
        final res = await _dio
            .get('$baseUrl/handasah-name/${Uri.encodeComponent(name)}');
        return HandasahModel.fromJson(res.data as Map<String, dynamic>);
      });

  /// POST /create-handasah
  Future<HandasahModel> create(HandasahModel model) => _guard(() async {
        final res = await _dio.post(
          '$baseUrl/create-handasah',
          data: model.toJson(),
        );
        return HandasahModel.fromJson(res.data as Map<String, dynamic>);
      });

  /// DELETE /remove-handasah/{id}
  Future<String> remove(int id) => _guard(() async {
        final res = await _dio.delete('$baseUrl/remove-handasah/$id');
        return res.data?.toString() ?? '';
      });

  // ---------------------------------------------------------------------

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw _mapDioError(e);
    } on TypeError {
      throw const AppFailure('تعذر قراءة البيانات القادمة من الخادم');
    }
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
        if (code == 404) {
          return AppFailure('العنصر غير موجود', statusCode: code);
        }
        if (code != null && code >= 500) {
          return AppFailure('حدث خطأ في الخادم', statusCode: code);
        }
        return AppFailure('تعذر تنفيذ الطلب (${code ?? '-'})',
            statusCode: code);
      case DioExceptionType.cancel:
        return const AppFailure('تم إلغاء الطلب');
      default:
        return const AppFailure('حدث خطأ غير متوقع');
    }
  }
}
