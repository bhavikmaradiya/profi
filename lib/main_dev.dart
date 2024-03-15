import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './env.dart';
import './firebase_options.dart';
import './main.dart';
import './notification/notification_helper.dart';
import './notification/notification_permission_helper.dart';

main() async {
  AppEnvironment.setupEnvironment(Environment.dev);
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationPermissionHelper.getNotificationPermission();
  await Firebase.initializeApp(
    name: defaultTargetPlatform == TargetPlatform.iOS ? 'Profi-Dev' : null,
    options: DefaultFirebaseOptions.currentPlatform,
  );
  notificationLaunch =
      (await notificationPlugin.getNotificationAppLaunchDetails())!;
  await NotificationHelper.initNotifications(notificationPlugin);
  await SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
    ],
  );
  runApp(const MyApp());
}
