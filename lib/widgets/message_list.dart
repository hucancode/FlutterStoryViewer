import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pop_template/models/message.dart';
import 'package:pop_template/screens/message_detail.dart';
import 'package:pop_template/widgets/radial_expansion.dart';

String getRandomString(int len) {
  var r = Random();
  return String.fromCharCodes(List.generate(len, (index) => r.nextInt(33) + 89));
}

class MessageList extends StatefulWidget {
  final List<Message> initialMessages;
  MessageList({Key key, this.initialMessages}) : super(key: key);
  MessageListState createState() => MessageListState(initialMessages);
}

class MessageListState extends State<MessageList> {
  final GlobalKey<AnimatedListState> listRef = GlobalKey();
  bool showDeleteButton = false;
  List<Message> messages = [];
  MessageListState(this.messages);
  void setMessage(List<Message> msg) {
    messages = msg;
  }

  var availableId = 4;
  void addMessage() {
    setState(() {
      messages.insert(
        0,
        Message(
            id: ++availableId,
            //icon: 'assets/amber.jpg',
            icon: 'https://picsum.photos/seed/'+getRandomString(5)+'/640/360',
            title: 'Integer quis mi a sit amet id turpis. ',
            date: DateTime.now(),
            content:
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum ac vulputate est. Etiam a dolor vel sem dictum molestie. Morbi quis venenatis orci, eu euismod lorem. Proin rutrum odio vel luctus interdum. Suspendisse pellentesque orci rutrum semper sagittis. Integer quis mi a massa tempus luctus sit amet id turpis. Quisque facilisis sapien eu erat tincidunt commodo. Morbi sodales felis eu orci venenatis rutrum. Donec eu dictum ante, et varius sapien. Curabitur convallis erat leo, in sagittis nulla auctor sit amet. Maecenas a iaculis lacus.'),
      );
      listRef.currentState.insertItem(0, duration: Duration(milliseconds: 300));
    });
  }

  void toggleDeleteButton() {
    setState(() {
      showDeleteButton = !showDeleteButton;
    });
  }

  void deleteMessage(int id) {
    setState(() {
      final index = messages.indexWhere((u) => u.id == id);
      var message = messages.removeAt(index);
      listRef.currentState.removeItem(
        index,
        (context, animation) {
          return FadeTransition(
            opacity:
                CurvedAnimation(parent: animation, curve: Interval(0.5, 1.0)),
            child: SizeTransition(
              sizeFactor:
                  CurvedAnimation(parent: animation, curve: Interval(0.0, 1.0)),
              axisAlignment: 0.0,
              child: buildItem(message, context),
            ),
          );
        },
        duration: Duration(milliseconds: 600),
      );
    });
  }

  void transitionToMessageDetail(id, title, imageName, content) {
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
                      id: id,
                      title: title,
                      banner: imageName,
                      content: content),
                );
              });
        },
      ),
    );
  }

  Widget buildItem(Message message, BuildContext context) {
    return ListTile(
      key: ValueKey<Message>(message),
      title: Text(message.title),
      subtitle: Text(message.date.toString()),
      leading: CircleAvatar(
        child: buildHeroWidget(context, message.id, message.icon),
      ),
      trailing: Visibility(
        child: IconButton(
          icon: Icon(Icons.delete),
          onPressed: () => deleteMessage(message.id),
        ),
        visible: showDeleteButton,
      ),
      onTap: () => Navigator.pushNamed(context, '/detail', arguments: message),
      //transitionToMessageDetail(message.id, message.title, message.icon, message.content),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: AnimatedList(
            key: listRef,
            initialItemCount: messages.length,
            itemBuilder: (context, index, animation) {
              return FadeTransition(
                opacity: animation,
                child: buildItem(messages[index], context),
              );
            }));
  }

  static const double kMinRadius = 32.0;
  static const double kMaxRadius = 128.0;
  static const opacityCurve =
      const Interval(0.0, 0.75, curve: Curves.fastOutSlowIn);

  static RectTween customTween(Rect begin, Rect end) {
    return MaterialRectCenterArcTween(begin: begin, end: end);
  }

  Widget buildHeroWidget(BuildContext context, int id, String iconPath) {
    return Container(
      width: kMinRadius * 2.0,
      height: kMinRadius * 2.0,
      child: Hero(
        createRectTween: customTween,
        tag: id,
        child: RadialExpansion(
          maxRadius: kMaxRadius,
          child: buildMessageIcon(iconPath),
        ),
      ),
    );
  }

  Widget buildMessageIcon(String iconPath) {
    //return Image.asset(iconPath, fit: BoxFit.contain);
    return CachedNetworkImage(
      imageUrl: iconPath,
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => Icon(Icons.error),
      fit: BoxFit.cover,
    );
  }
}
