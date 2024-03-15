import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class FetchDateTimeApi {
  late Dio _dio;

  FetchDateTimeApi() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'http://worldtimeapi.org/api',
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

  Dio get fetchDateTimeApiRequest => _dio;
}
