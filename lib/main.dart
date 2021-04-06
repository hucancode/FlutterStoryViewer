import 'package:flutter/material.dart';
// import 'package:animations/animations.dart';
// import 'package:flutter_geofence/Geolocation.dart';
// import 'package:flutter_geofence/geofence.dart';
// import 'package:flutter_beacon/flutter_beacon.dart';

import 'package:pop_template/views/master.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MasterPage(),
    );
  }
}
