import 'package:flutter/material.dart';
import 'package:pop_experiment/models/message.dart';
import 'package:pop_experiment/views/pages/message_detail.dart';
import 'package:pop_experiment/views/pages/private_messages.dart';

class PrivateMessagesNavigator extends StatelessWidget {
  static const String root = '/';
  static const String detail = '/detail';
  final HeroController heroController;
  
  PrivateMessagesNavigator({required this.heroController});
  
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