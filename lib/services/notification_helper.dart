import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHelper {

  static final NotificationHelper _instance = NotificationHelper._privateConstructor();
  NotificationHelper._privateConstructor();

  factory NotificationHelper() {
    return _instance;
  }
  
  final plugin = FlutterLocalNotificationsPlugin();
  bool initialized = false;// TODO: use completer

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