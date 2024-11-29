import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

class BackgroundNotificationService extends GetxController
    with WidgetsBindingObserver {
  static BackgroundNotificationService get instance => Get.find();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  AppLifecycleState currentState = AppLifecycleState.resumed;
  int notificationId = 0;

  @override
  Future<void> onInit() async {
    await initializeNotifications();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    currentState = state;
  }

  Future<void> initializeNotifications() async {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    final androidInit = AndroidInitializationSettings("@mipmap/ic_launcher");
    final initalizeSettings = InitializationSettings(android: androidInit);
    await flutterLocalNotificationsPlugin.initialize(
      initalizeSettings,
    );
  }

  Future<void> showNotification(String title, String body,
      {bool showIfResumed = false}) async {
    if (!showIfResumed && currentState == AppLifecycleState.resumed) return;
    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails("channel_id_0", "messages",
            importance: Importance.max, priority: Priority.high);
    final NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
        notificationId++, title, body, notificationDetails);
  }

  // String collectionName = "user-tokens";
  // final _db = FirebaseFirestore.instance;
  // static BackgroundNotificationService get instance => Get.find();
  // final _firebaseMessaging = FirebaseMessaging.instance;
  // String? tokenValue;
  //
  // @override
  // void onInit() {
  //   super.onInit();
  //   initNotifications();
  // }
  //
  // Future<void> initNotifications() async {
  //   await _firebaseMessaging.requestPermission(
  //     alert: true,
  //     announcement: false,
  //     badge: true,
  //     carPlay: false,
  //     criticalAlert: false,
  //     provisional: false,
  //     sound: true,
  //   );
  //   tokenValue = await _firebaseMessaging.getToken();
  // }
  //
  // Future<void> setUserToken(String? userId) async {
  //   if (userId == null) return;
  //   return _db.collection(collectionName).doc(userId).set({
  //     'userId': userId,
  //     'token': tokenValue,
  //   })
  //     .then()
  //     .catchError((error) {});
  // }
}
