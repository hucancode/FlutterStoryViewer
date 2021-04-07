import 'package:flutter/material.dart';
import 'package:pop_experiment/views/pages/geofence_map.dart';
import 'package:pop_experiment/views/pages/qr_scan_result.dart';

class MapNavigator extends StatelessWidget {
  static const String root = '/';
  static const String result = '/result';

  @override
  Widget build(BuildContext context) {
    return Navigator(
        initialRoute: root,
        onGenerateRoute: (routeSettings)
        {
          if(routeSettings.name == result)
          {
            return MaterialPageRoute(
              builder: (context) => QRScanResult(),
              );
          }
          return MaterialPageRoute(
              builder: (context) => GeofenceMap(),
              );
        }
    );
  }
}