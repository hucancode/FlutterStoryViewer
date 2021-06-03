import 'package:flutter/material.dart';
import 'package:pop_experiment/models/geofence.dart';
import 'package:pop_experiment/views/pages/geofence_detail.dart';
import 'package:pop_experiment/views/pages/geofence_map.dart';

class MapNavigator extends StatelessWidget {
  static const String root = '/';
  static const String detail = '/detail';

  PageRoute<void> routeToDetail(RouteSettings settings)
  {
    if(settings.arguments is! Geofence)
    {
      return routeToRoot(settings);
    }
    Geofence model = settings.arguments as Geofence;
    Widget widget = GeofenceDetail(model: model);
    return MaterialPageRoute<void>(builder: (context) => widget);
  }

  PageRoute<void> routeToRoot(RouteSettings settings) {
    Widget widget = GeofenceMap();
    return MaterialPageRoute<void>(builder: (context) => widget);
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
        initialRoute: root,
        onGenerateRoute: (routeSettings)
        {
          if(routeSettings.name == detail)
          {
            return routeToDetail(routeSettings);
          }
          return routeToRoot(routeSettings);
        }
    );
  }
}