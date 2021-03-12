import 'package:flutter/material.dart';
import 'package:pop_template/models/message.dart';
import 'package:pop_template/screens/message_detail.dart';
import 'package:pop_template/screens/private_messages.dart';

class PrivateMessagesNavigator extends StatelessWidget {
  static const String root = '/';
  static const String detail = '/detail';
  final GlobalKey<NavigatorState> navigatorKey;
  final HeroController heroController;
  
  PrivateMessagesNavigator({this.navigatorKey, this.heroController});
  
  static const opacityCurve =
      const Interval(0.0, 0.75, curve: Curves.fastOutSlowIn);
  
  PageRoute<void> routeToDetail(RouteSettings settings)
  {
    Message model = settings.arguments;
    Widget widget = MessageDetail(id: model.id, title: model.title, banner: model.icon, content: model.content);

    return PageRouteBuilder<void>(
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return AnimatedBuilder(
            animation: animation,
            builder: (BuildContext context, Widget child) {
              return Opacity(
                opacity: opacityCurve.transform(animation.value),
                child: widget,
              );
            });
      },
    );
  }

  // PageRoute<void> routeToDetailSimple(RouteSettings settings)
  // {
  //   Message model = settings.arguments;
  //   Widget widget = MessageDetail(id: model.id, title: model.title, banner: model.icon, content: model.content);
  //   return MaterialPageRoute<void>(builder: (context) => widget);
  // }

  PageRoute<void> routeToRoot(RouteSettings settings) {
    Widget widget = PrivateMessages();
    return MaterialPageRoute<void>(builder: (context) => widget);
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
        key: navigatorKey,
        observers: [heroController],
        initialRoute: root,
        onGenerateRoute: (RouteSettings routeSettings)
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