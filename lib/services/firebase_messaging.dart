// ignore_for_file: depend_on_referenced_packages
import 'dart:convert';
import 'dart:io';
import 'package:chat_application/features/chat/screens/mobile_chat_screen.dart';
import 'package:chat_application/features/remainder/screens/notify_page.dart';
import 'package:chat_application/models/task.dart';
import 'package:chat_application/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationServices {
  static const key =
      'AAAArkTB-2U:APA91bH6kl_d4Kg6Ha2kN0YtFROd4jbxffzN6AlS7-yWXkJngGvRCs95qqDsizS4eyW6QzV3-hLlFQQ7ZVDOhSNDYpv6_l8Bos-3otcShvEjFRFnAAU8Mt1p7sP7p1QcrQFzzq6iWkqZ';

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  initializeNotification() async {
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      requestCriticalPermission: true,
    );

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      iOS: initializationSettingsIOS,
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint(response.payload.toString());
      },
    );
  }

  Future<void> requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.requestNotificationsPermission();
    }
  }

  initializeRemainderNotification() async {
    _configureLocalTimeZone();
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      requestCriticalPermission: true,
    );

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      iOS: initializationSettingsIOS,
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {
      // ignore: avoid_print
      // print('notification(${notificationResponse.id}) action tapped: '
      //     '${notificationResponse.actionId} with'
      //     ' payload: ${notificationResponse.payload}');
      if (notificationResponse.input?.isNotEmpty ?? false) {
        // ignore: avoid_print
        // print(
        //     'notification action tapped with input: ${notificationResponse.input}');
      }
      Get.to(
        () => NotifiedPage(
          label: notificationResponse.payload,
        ),
        transition: Transition.zoom,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut,
      );
    });
  }

  displayNotification({required String title, required String body}) async {
    final styleInformation = BigTextStyleInformation(
      body,
      htmlFormatBigText: true,
      contentTitle: title,
      htmlFormatTitle: true,
    );

    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'com.example.chat_app.urgent',
      'my_channel_id',
      importance: Importance.max,
      styleInformation: styleInformation,
      priority: Priority.high,
    );

    const iOSPlatformChannelSpecifics = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
    );

    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: title,
    );
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String timezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezone));
  }

  Future<void> scheduledNotification(int id, int year, int month, int day,
      int hour, int minutes, String repeat, Task task) async {
    final styleInformation = BigTextStyleInformation(
      task.note!,
      htmlFormatBigText: true,
      contentTitle: task.title,
      htmlFormatTitle: true,
    );

    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'com.example.chat_app.urgent',
      'my_channel_id',
      importance: Importance.max,
      styleInformation: styleInformation,
      priority: Priority.high,
    );

    const iOSPlatformChannelSpecifics = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
    );

    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      task.title,
      task.note,
      _convertTime(year, month, day, hour, minutes, repeat),
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: "${task.title}|${task.note}|",
    );
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  tz.TZDateTime _convertTime(
    int year,
    int month,
    int day,
    int hour,
    int minutes,
    String repeat,
  ) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.getLocation('Asia/Colombo'));
    tz.TZDateTime scheduleDate = tz.TZDateTime(tz.getLocation('Asia/Colombo'),
        year, month, day, hour, minutes, 0, 0, 0);
    switch (repeat) {
      case "Daily":
        if (scheduleDate.isBefore(now)) {
          scheduleDate = scheduleDate.add(const Duration(days: 1));
        }
        break;
      case "Weekly":
        if (scheduleDate.isBefore(now)) {
          scheduleDate = scheduleDate.add(const Duration(days: 7));
        }
        break;
      case "Monthly":
        if (scheduleDate.isBefore(now)) {
          scheduleDate = scheduleDate.add(const Duration(days: 30));
        }
        break;
      default:
        break;
    }
    return scheduleDate;
  }

  Future<void> requestPermission() async {
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User Granted Permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('User Granted Provisional Permission');
    } else {
      debugPrint('User Declined or has not accepted permission');
    }
  }

  Future<void> showLocalNotification(RemoteMessage message) async {
    final styleInformation = BigTextStyleInformation(
      message.notification!.body.toString(),
      htmlFormatBigText: true,
      contentTitle: message.notification!.title,
      htmlFormatTitle: true,
    );

    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'com.example.chat_app.urgent',
      'my_channel_id',
      importance: Importance.max,
      styleInformation: styleInformation,
      priority: Priority.high,
    );
    const iOSPlatformChannelSpecifics = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
    );

    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      message.notification!.title,
      message.notification!.body,
      platformChannelSpecifics,
      payload: message.data['body'],
    );
  }

  Future<void> getToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    saveToken(token!);
  }

  Future<void> saveToken(String token) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({'token': token}, SetOptions(merge: true));
  }

  firebaseNotification(BuildContext context) {
    initializeNotification();

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      var userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(message.data['senderId'])
          .get();
      UserModel? user;

      if (userData.data() != null) {
        user = UserModel.fromMap(userData.data()!);
        Get.to(
          () => MobileChatScreen(
            name: user!.name,
            uid: user.uid,
            profilePic: user.profilePic,
            isGroup: false,
          ),
          transition: Transition.zoom,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
        );
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await showLocalNotification(message);
    });
  }

  String receiverToken = "";

  Future<void> getRecieverToken(String? receiverId) async {
    final getToken = await FirebaseFirestore.instance
        .collection('users')
        .doc(receiverId)
        .get();

    receiverToken = await getToken.data()!['token'];
  }

  Future<void> sendNotification(
      {required String body, required String senderId}) async {
    try {
      await post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$key',
        },
        body: jsonEncode(
          <String, dynamic>{
            "to": receiverToken,
            "priority": "high",
            "notification": <String, dynamic>{
              "body": body,
              "title": 'New Message',
            },
            "data": <String, String>{
              "click_action": "FLUTTER_NOTIFICATION_CLICK",
              "status": "done",
              'senderId': senderId,
            }
          },
        ),
      );
    } catch (err) {
      debugPrint(err.toString());
    }
  }
}
