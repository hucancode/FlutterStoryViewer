import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pop_experiment/models/message.dart';
import 'package:pop_experiment/models/message_list.dart';
import 'package:pop_experiment/views/widgets/radial_expansion.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class MessageListView extends StatefulWidget {
  
  MessageListView({Key? key}) : super(key: key);
  MessageListViewState createState()
  {
    return MessageListViewState();
  }
}

class MessageListViewState extends State<MessageListView> {
  final GlobalKey<AnimatedListState> listRef = GlobalKey();

  @override
  void initState()
  {
    super.initState();
    final provider = Provider.of<MessageList>(context, listen: false);
    provider.eventController.stream.listen((event) {
      print('MessageListState got event ${event.type}');
      switch (event.type) {
        case MessageListEventType.insert:
          listRef.currentState?.insertItem(event.index, duration: Duration(milliseconds: 300));
          break;
        case MessageListEventType.delete:
          listRef.currentState?.removeItem(
            event.index,
            (context, animation) {
              return FadeTransition(
                opacity:
                    CurvedAnimation(parent: animation, curve: Interval(0.5, 1.0)),
                child: SizeTransition(
                  sizeFactor:
                      CurvedAnimation(parent: animation, curve: Interval(0.0, 1.0)),
                  axisAlignment: 0.0,
                  child: buildItem(provider.messages[event.index], context),
                ),
              );
            },
            duration: Duration(milliseconds: 600),
          );
          break;
        default:
      }
    });
  }

  Widget buildItem(Message message, BuildContext context) {
    final provider = Provider.of<MessageList>(context, listen: false);
    print('buildItem for message ${message.id}');
    return Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        child: buildItemContent(message, context),
        actions: [
          IconSlideAction(
            caption: 'Delete',
            color: Colors.red,
            icon: Icons.delete,
            onTap: () => provider.deleteMessage(message.id),
          ),
          IconSlideAction(
            caption: 'Favorite',
            color: Colors.amber,
            icon: Icons.favorite,
            onTap: () => provider.addToFavorite(message.id),
          ),
        ],
        secondaryActions: [
          IconSlideAction(
            caption: 'Delete',
            color: Colors.red,
            icon: Icons.delete,
            onTap: () => provider.deleteMessage(message.id),
          ),
          IconSlideAction(
            caption: 'Favorite',
            color: Colors.amber,
            icon: Icons.favorite,
            onTap: () => provider.addToFavorite(message.id),
          ),
        ],
      );
  }

  Widget buildItemContent(Message message, BuildContext context) {
    print('buildItemContent for message ${message.id}');
    final provider = Provider.of<MessageList>(context, listen: false);
    return ListTile(
        key: ValueKey<Message>(message),
        selected: message.isSelected,
        title: Text(message.title??"Untitled"),
        subtitle: Text(message.date.toString()),
        selectedTileColor: Colors.amber,
        leading: CircleAvatar(
          child: buildHeroWidget(context, message.id, message.icon??"no_icon"),
        ),
        trailing: Visibility(
          child: Icon(Icons.favorite),
          visible: message.isFavorite,
        ),
        onTap: () {
          if(provider.totalSelected > 0)
          {
            provider.toggleSelect(message.id);
          }
          else
          {
            Navigator.pushNamed(context, '/detail', arguments: message);
          }
        },
        onLongPress: () {
          provider.toggleSelect(message.id);
        },
      );
  }

  @override
  Widget build(BuildContext context) {
    final messages = Provider.of<MessageList>(context).messages;
    print('build message_list ${messages.length}');
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

  static RectTween customTween(Rect? begin, Rect? end) {
    return MaterialRectCenterArcTween(begin: begin, end: end);
  }
  static Tween<Offset> introTween(Offset? begin, Offset? end) {
    return MaterialPointArcTween(begin: begin, end: end);
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
    return CachedNetworkImage(
      imageUrl: iconPath,
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => Icon(Icons.error),
      fit: BoxFit.cover,
    );
    //return Image.network(iconPath, fit: BoxFit.cover);
    //return Image.asset(iconPath, fit: BoxFit.cover);
  }
}
