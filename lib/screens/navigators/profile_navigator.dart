import 'package:flutter/material.dart';
import 'package:pop_template/screens/profile.dart';
import 'package:pop_template/screens/profile_edit.dart';

class ProfileNavigator extends StatelessWidget {
  static const String root = '/';
  static const String edit = '/edit';
  ProfileNavigator({required this.navigatorKey});
  final GlobalKey<NavigatorState> navigatorKey;
  
  @override
  Widget build(BuildContext context) {
    return Navigator(
        key: navigatorKey,
        initialRoute: root,
        onGenerateRoute: (routeSettings)
        {
          if(routeSettings.name == edit)
          {
            return MaterialPageRoute(
              builder: (context) => ProfileEdit(),
              );
          }
          return MaterialPageRoute(
              builder: (context) => Profile(),
              );
        }
    );
  }
}