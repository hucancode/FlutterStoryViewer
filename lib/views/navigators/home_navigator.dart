import 'package:flutter/material.dart';
import 'package:pop_experiment/models/entry.dart';
import 'package:pop_experiment/views/pages/home.dart';
import 'package:pop_experiment/views/pages/entry_detail.dart';
import 'package:pop_experiment/views/pages/qr_scan.dart';
import 'package:pop_experiment/views/pages/qr_scan_result.dart';

class HomeNavigator extends StatelessWidget {
  static const String root = '/';
  static const String detail = '/detail';
  static const String qr = '/qr';
  static const String qrResult = '/qr_result';
  final HeroController heroController;
  
  HomeNavigator({required this.heroController});
  
  static const opacityCurve =
      const Interval(0.0, 0.75, curve: Curves.fastOutSlowIn);
  
  PageRoute<void> routeToDetail(RouteSettings settings)
  {
    if(settings.arguments is! Entry)
    {
      return routeToRoot(settings);
    }
    Entry model = settings.arguments as Entry;
    return PageRouteBuilder<void>(
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return AnimatedBuilder(
            animation: animation,
            builder: (BuildContext context, Widget? child) {
              return Opacity(
                opacity: opacityCurve.transform(animation.value),
                child: EntryDetail(model: model),
              );
            });
      },
    );
  }

  PageRoute<void> routeToQR(RouteSettings settings) {
    Widget widget = QRScan();
    return MaterialPageRoute<void>(builder: (context) => widget);
  }

  PageRoute<void> routeToQRResult(RouteSettings settings) {
    Widget widget = QRScanResult();
    return MaterialPageRoute<void>(builder: (context) => widget);
  }

  PageRoute<void> routeToRoot(RouteSettings settings) {
    Widget widget = HomePage();
    return MaterialPageRoute<void>(builder: (context) => widget);
  }

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator(
        observers: [heroController],
        initialRoute: root,
        onGenerateRoute: (RouteSettings routeSettings)
        {
          if(routeSettings.name == detail)
          {
            return routeToDetail(routeSettings);
          }
          if(routeSettings.name == qr)
          {
            return routeToQR(routeSettings);
          }
          if(routeSettings.name == qrResult)
          {
            return routeToQRResult(routeSettings);
          }
          return routeToRoot(routeSettings);
        }
    );
    return navigator;
  }
}