import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHelper {

  static final NotificationHelper _instance = NotificationHelper._privateConstructor();
  NotificationHelper._privateConstructor();

  factory NotificationHelper() {
    return _instance;
  }
  
  final notificationPlugin = FlutterLocalNotificationsPlugin();
  bool initialized = false;// TODO: use completer

  void initialize() {
    if(initialized)
    {
      return;
    }
    initialized = true;
    notificationPlugin.initialize(
      InitializationSettings(
        android: AndroidInitializationSettings('app_icon'), 
        iOS: IOSInitializationSettings(onDidReceiveLocalNotification: null)
      ), 
      onSelectNotification: null);
  }


  void scheduleNotification(String title, String subtitle) {
    initialize();
    print("scheduling notification with $title and $subtitle");
    var rng = new Random();
    Future.delayed(Duration(seconds: 1)).then((result) async {
      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
          'pop_experiment', 'Pop Experiment', 'default channel for pop application',
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'ticker');
      var iOSPlatformChannelSpecifics = IOSNotificationDetails();
      var platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: iOSPlatformChannelSpecifics);
      await notificationPlugin.show(
          rng.nextInt(100000), title, subtitle, platformChannelSpecifics,
          payload: 'item x');
    });
  }

}