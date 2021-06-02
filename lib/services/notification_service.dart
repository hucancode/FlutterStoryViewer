import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {

  static final NotificationService _instance = NotificationService._privateConstructor();
  NotificationService._privateConstructor();

  factory NotificationService() {
    return _instance;
  }
  
  final plugin = FlutterLocalNotificationsPlugin();
  bool initialized = false;

  void initialize() {
    if(initialized)
    {
      return;
    }
    plugin.initialize(
      InitializationSettings(
        android: AndroidInitializationSettings('mipmap/ic_launcher'), 
        iOS: IOSInitializationSettings()
      ));
    initialized = true;
  }


  void send(String title, String body, {String? payload}) {
    initialize();
    print("sending notification with $title and $body");
    final rng = Random();
    final androidDetail = AndroidNotificationDetails(
        'pop_experiment', 'Pop Experiment', 'default channel for pop application',
        importance: Importance.max,
        priority: Priority.max,);
    final iOSDetail = IOSNotificationDetails();
    final defail = NotificationDetails(
        android: androidDetail,
        iOS: iOSDetail);
    plugin.show(rng.nextInt(100000), title, body, defail, payload: payload);
  }

}