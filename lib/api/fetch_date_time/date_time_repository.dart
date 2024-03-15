import 'package:dio/dio.dart';

import './date_time_response_entity.dart';
import './date_time_api.dart';
import '../../generated/json/base/json_convert_content.dart';

class DateTimeRepository {
  Future<DateTimeResponseEntity?> fetchDateTime() async {
    try {
      final response =
          await FetchDateTimeApi().fetchDateTimeApiRequest.get('/ip');
      if (response.statusCode == 200) {
        final data = response.data;
        return JsonConvert.fromJsonAsT(data);
      }
      return null;
    } on DioException catch (_) {
      return null;
    }
  }
}
