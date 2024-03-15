import 'package:permission_handler/permission_handler.dart';

class NotificationPermissionHelper {
  static Future<bool?> getNotificationPermission() async {
    if (await Permission.notification.request().isGranted) {
      return true;
    } else if (await Permission.notification.request().isPermanentlyDenied) {
      return null;
    } else if (await Permission.notification.request().isDenied) {
      return false;
    }
    return false;
  }
}
