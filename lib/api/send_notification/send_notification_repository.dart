import 'package:dio/dio.dart';

import './send_notification_api.dart';

class SendNotificationRepository {
  // Ref. https://www.youtube.com/watch?v=oNoRw69ro2k
  // Ref. https://console.cloud.google.com/iam-admin/serviceaccounts/details/115354595907456117054/keys?authuser=1&project=profi-406ea
  // https://firebase.google.com/docs/cloud-messaging/migrate-v1?hl=en&authuser=1
  sendNotification(dynamic data) async {
    try {
      final response =
          await SendNotificationApi().sendNotificationApiRequest.post(
                'v1/projects/profi-406ea/messages:send',
                data: data,
                options: Options(
                  headers: {
                    'Host': 'fcm.googleapis.com',
                    'Authorization': 'Bearer 12296210d9c921d3aadae6513e6aef90ee1db4e5',
                    'Content-Type': 'application/json',
                  },
                ),
              );
      if (response.statusCode == 200) {
        // success
      }
    } on DioException catch (_) {}
  }
}
