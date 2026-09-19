import 'package:dio/dio.dart';
import 'package:khabark/core/constants/api_constants.dart';
class DioClient {
  DioClient._();

  static Dio create() {
    return Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        headers: {'X-Api-Key': ApiConstants.apiKey},
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
  }
}