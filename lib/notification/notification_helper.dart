import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as notification;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../main.dart';

//https://itnext.io/local-notifications-in-flutter-6136235e1b51

class NotificationHelper {
  static initNotifications(
      notification.FlutterLocalNotificationsPlugin notificationPlugin) async {
    var initializationSettingsAndroid =
        const notification.AndroidInitializationSettings('ic_notification');
    var initializationSettingsIOS = notification.DarwinInitializationSettings(
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async =>
                _onNotificationClicked(payload));
    var initializationSettings = notification.InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await notificationPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) =>
          _onNotificationClicked(response.payload),
      onDidReceiveBackgroundNotificationResponse:
          onDidReceiveBackgroundNotificationResponse,
    );
    await notificationPlugin
        .resolvePlatformSpecificImplementation<
            notification.IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    listenFCM();
  }

  static _createFCMChannel() async {
    const AndroidNotificationChannel fcmChannel = AndroidNotificationChannel(
      'profi_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications',
      importance: Importance.max,
      enableLights: true,
      enableVibration: false,
      playSound: true,
      showBadge: true,
    );
    await notificationPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(fcmChannel);
  }

  static listenFCM() async {
    await _createFCMChannel();
    FirebaseMessaging.onBackgroundMessage(fcmBackgroundMessageHandler);
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      _onFCMNotificationClicked(message);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage notification) async {
      if (!Platform.isIOS &&
          notification.notification != null &&
          notification.notification!.title != null &&
          notification.notification!.body != null) {
        notificationPlugin.show(
          notification.hashCode,
          notification.notification!.title,
          notification.notification!.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'profi_channel',
              'High Importance Notifications',
              channelDescription:
                  'This channel is used for important notifications',
              visibility: NotificationVisibility.public,
              enableVibration: false,
              enableLights: true,
              playSound: true,
              channelShowBadge: true,
              priority: Priority.high,
              importance: Importance.high,
            ),
            iOS: DarwinNotificationDetails(
              presentBadge: true,
              presentSound: true,
            ),
          ),
        );
      }
    });
  }

  static void _onNotificationClicked(String? payload) {}

  @pragma('vm:entry-point')
  static Future<void> fcmBackgroundMessageHandler(RemoteMessage message) async {
    debugPrint('background message: ${message.notification?.title ?? ''}');
  }

  static _onFCMNotificationClicked(RemoteMessage message) {}

  @pragma('vm:entry-point')
  static void onDidReceiveBackgroundNotificationResponse(
    notification.NotificationResponse response,
  ) {
    //when notification clicked from bg
  }
}
