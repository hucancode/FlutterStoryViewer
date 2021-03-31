import 'package:flutter/material.dart';
import 'package:pop_template/screens/profile.dart';

class ProfileNavigator extends StatelessWidget {
  static const String root = '/';
  static const String edit = '/edit';
  
  @override
  Widget build(BuildContext context) {
    return Navigator(
        initialRoute: root,
        onGenerateRoute: (routeSettings)
        {
          if(routeSettings.name == edit)
          {
            // return edit page here
          }
          return MaterialPageRoute(
              builder: (context) => Profile(),
              );
        }
    );
  }
}