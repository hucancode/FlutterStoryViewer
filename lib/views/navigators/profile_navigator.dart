import 'package:flutter/material.dart';
import 'package:pop_experiment/models/prefecture_list.dart';
import 'package:pop_experiment/models/profile.dart';
import 'package:pop_experiment/views/pages/profile.dart';
import 'package:provider/provider.dart';

class ProfileNavigator extends StatelessWidget {
  static const String root = '/';
  static const String edit = '/edit';
  
  @override
  Widget build(BuildContext context) {
    final navigator = Navigator(
      initialRoute: root,
      onGenerateRoute: (routeSettings)
      {
        if(routeSettings.name == edit)
        {
          // return edit page here
        }
        return MaterialPageRoute(
            builder: (context) => ProfilePage(),
            );
      }
    );
    final provider = MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PrefectureList()),
        ChangeNotifierProvider(create: (context) => Profile()),
      ],
      child: navigator,
    );
    return provider;
    
  }
}