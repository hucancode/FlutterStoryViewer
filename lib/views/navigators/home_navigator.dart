import 'package:flutter/material.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:pop_template/models/message.dart';
import 'package:pop_template/views/pages/home_legacy.dart';
import 'package:pop_template/views/pages/home_pop.dart';
import 'package:pop_template/views/pages/message_detail.dart';
import 'package:pop_template/views/pages/mime_message_detail.dart';
import 'package:pop_template/views/pages/qr_scan.dart';
import 'package:pop_template/views/pages/qr_scan_result.dart';

class HomeNavigator extends StatelessWidget {
  static const String root = '/';
  static const String detail = '/detail';
  static const String mimeDetail = '/mime_detail';
  static const String qr = '/qr';
  static const String qrResult = '/qr_result';
  final HeroController heroController;
  
  HomeNavigator({required this.heroController});
  
  static const opacityCurve =
      const Interval(0.0, 0.75, curve: Curves.fastOutSlowIn);
  
  PageRoute<void> routeToDetail(RouteSettings settings)
  {
    Widget widget;
    if(settings.arguments is! Message)
    {
      widget = MessageDetail(id: -1);
    }
    else
    {
      Message model = settings.arguments as Message;
      widget = MessageDetail(id: model.id, title: model.title, banner: model.icon, content: model.content);
    }
    return PageRouteBuilder<void>(
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return AnimatedBuilder(
            animation: animation,
            builder: (BuildContext context, Widget? child) {
              return Opacity(
                opacity: opacityCurve.transform(animation.value),
                child: widget,
              );
            });
      },
    );
  }

  PageRoute<void> routeToMimeDetail(RouteSettings settings)
  {
    Widget widget;
    if(settings.arguments is! MimeMessage)
    {
      MimeMessage model = MimeMessage();
      widget = MimeMessageDetail(model);
    }
    else
    {
      MimeMessage model = settings.arguments as MimeMessage;
      widget = MimeMessageDetail(model);
    }    
    return MaterialPageRoute<void>(builder: (context) => widget);
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
    return Navigator(
        observers: [heroController],
        initialRoute: root,
        onGenerateRoute: (RouteSettings routeSettings)
        {
          if(routeSettings.name == detail)
          {
            return routeToDetail(routeSettings);
          }
          if(routeSettings.name == mimeDetail)
          {
            return routeToMimeDetail(routeSettings);
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
  }
}