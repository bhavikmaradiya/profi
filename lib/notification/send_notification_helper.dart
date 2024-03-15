import '../api/send_notification/send_notification_repository.dart';

class SendNotificationHelper {
  static sendNotificationOnProjectAdded() {}

  static sendNotificationOnMilestoneChanged() {}

  static sendNotificationOnPaid(
    String projectName,
    String amount,
    String receivedBy,
  ) {
    final title = '$projectName - Paid';
    final body = 'Payment of $amount received ($receivedBy)';
    final tokens = [
      'f1XG6tpbQ0CZTIUUDLe4_1:APA91bFA3aPl6FEGiE7yx88IZ5sLTu9KWP9QnrmR5x0GIwaRwm7X3ftKxoMgdd13XYrbJoq7BatX1q_4CbNBxHLvmCpaq_nQyWbhdXI1GZ0Z4SlZ1AZTEO8wudgvHKj9d9g70qSnH1dM',
      'fRewE4SfTZCKakfP-f8fHi:APA91bG0L1_V1f2oENZ8pjEd9cXP-ym_2Qjk9u_u3fVlRXFzHGJKta6O3iBYAZ-XiSY8jtmO6gFVkPrcfomPmoA8AMNLfyw-5gC0MJuEf3ZmCUlp9kChYwLoX1lQCqwEsxxMkgpxnGkF'
    ];
    _sendNotifications(tokens, title, body);
  }

  static sendNotificationOnUnPaid() {}

  static Future<void> _sendNotifications(
    List<String> tokens,
    String title,
    String body,
  ) async {
    for (final token in tokens) {
      final data = {
        'message': {
          'token': token,
          'notification': {
            'title': title,
            'body': body,
          },
        },
      };
      final notificationRepository = SendNotificationRepository();
      notificationRepository.sendNotification(data);
    }
  }
}
