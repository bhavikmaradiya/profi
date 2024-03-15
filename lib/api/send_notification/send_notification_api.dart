import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class SendNotificationApi {
  late Dio _dio;

  SendNotificationApi() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://fcm.googleapis.com/',
        connectTimeout: const Duration(
          seconds: 25,
        ),
        receiveTimeout: const Duration(
          seconds: 25,
        ),
        responseType: ResponseType.json,
        validateStatus: (_) => true,
      ),
    )..interceptors.add(PrettyDioLogger());
  }

  Dio get sendNotificationApiRequest => _dio;
}
