import 'package:flutter/material.dart';
import 'package:pop_template/screens/message_detail.dart';
import 'package:pop_template/screens/private_messages.dart';

class PrivateMessagesNavigator extends StatelessWidget {
  static const String root = '/';
  static const String detail = '/detail';
  PrivateMessagesNavigator({this.navigatorKey});
  final GlobalKey<NavigatorState> navigatorKey;
static const opacityCurve =
      const Interval(0.0, 0.75, curve: Curves.fastOutSlowIn);

void transitionToMessageDetail(context, id, imageName, content) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return AnimatedBuilder(
              animation: animation,
              builder: (BuildContext context, Widget child) {
                return Opacity(
                  opacity: opacityCurve.transform(animation.value),
                  child: MessageDetail(
                      id: id, banner: imageName, content: content),
                );
              });
        },
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Navigator(
        key: navigatorKey,
        initialRoute: root,
        onGenerateRoute: (routeSettings)
        {
          // if(routeSettings.name == detail)
          // {
          //   return MaterialPageRoute(
          //     builder: (context) => MessageDetail(),
          //     );
          // }
          return MaterialPageRoute(
              builder: (context) => PrivateMessages(),
              );
        }
    );
  }
}