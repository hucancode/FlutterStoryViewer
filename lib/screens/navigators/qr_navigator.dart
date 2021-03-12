import 'package:flutter/material.dart';
import 'package:pop_template/screens/qr_scan.dart';
import 'package:pop_template/screens/qr_scan_result.dart';

class QRScanNavigator extends StatelessWidget {
  static const String root = '/';
  static const String result = '/result';
  QRScanNavigator({this.navigatorKey});
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) {
    return Navigator(
        key: navigatorKey,
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
              builder: (context) => QRScan(),
              );
        }
    );
  }
}