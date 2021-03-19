import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:pop_template/models/message.dart';
import 'package:pop_template/widgets/radial_expansion.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

String getRandomString(int len) {
  var r = Random();
  return String.fromCharCodes(List.generate(len, (index) => r.nextInt(33) + 89));
}

typedef SelectionCountCallback = void Function(int);
typedef MessageDeletedCallback = void Function(int);
typedef SingleMessageDeletedCallback = void Function();
typedef FavoriteChangedCallback = void Function(int, bool);

class MessageList extends StatefulWidget {
  final List<Message>? initialMessages;
  final SelectionCountCallback? onSelectionCountChanged;
  final MessageDeletedCallback? onMessageDeleted;
  final SingleMessageDeletedCallback? onSingleMessageDeleted;
  final FavoriteChangedCallback? onFavoriteChanged;
  
  MessageList({
    Key? key, 
    this.initialMessages, 
    this.onSelectionCountChanged,
    this.onMessageDeleted,
    this.onSingleMessageDeleted,
    this.onFavoriteChanged,
    }) : super(key: key);
  MessageListState createState()
  {
    return MessageListState(
      messages: initialMessages??[], 
    );
  }
}

class MessageListState extends State<MessageList> {
  static const DUMMY_TITLE = 'Integer quis mi a sit amet id turpis. ';
  static const DUMMY_CONTENT = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum ac vulputate est. Etiam a dolor vel sem dictum molestie. Morbi quis venenatis orci, eu euismod lorem. Proin rutrum odio vel luctus interdum. Suspendisse pellentesque orci rutrum semper sagittis. Integer quis mi a massa tempus luctus sit amet id turpis. Quisque facilisis sapien eu erat tincidunt commodo. Morbi sodales felis eu orci venenatis rutrum. Donec eu dictum ante, et varius sapien. Curabitur convallis erat leo, in sagittis nulla auctor sit amet. Maecenas a iaculis lacus.';
  final GlobalKey<AnimatedListState> listRef = GlobalKey();
  List<bool> isSelected = [];
  List<bool> favorites = [];
  int selectionCount = 0;
  List<Message> messages;
  MessageListState({
    required this.messages, 
  })
  {
    isSelected = List.filled(messages.length, false, growable: true);
    favorites = List.filled(messages.length, false, growable: true);
    print("isSelected.length "+ isSelected.length.toString());
  }

  void clearAll()
  {
    setState(() {
      for (var i = 0; i <= messages.length - 1; i++) {
        listRef.currentState?.removeItem(0,
          (BuildContext context, Animation<double> animation) {
        return Container();
      });
      }
    });
    messages.clear();
    isSelected.clear();
    favorites.clear();
  }

  var availableId = 4;
  void addMessage({String title = DUMMY_TITLE, String content = DUMMY_CONTENT}) {
    setState(() {
      messages.insert(
        0,
        Message(
            id: ++availableId,
            //icon: 'assets/amber.jpg',
            icon: 'https://picsum.photos/seed/'+getRandomString(5)+'/640/360',
            title: title,
            date: DateTime.now(),
            content: content),
      );
      listRef.currentState?.insertItem(0, duration: Duration(milliseconds: 300));
      isSelected.insert(0, false);
      favorites.insert(0, false);
    });
  }

  void enterMultiSelect(int id) {
    print('enterMultiSelect '+id.toString());
    final index = messages.indexWhere((u) => u.id == id);
    if(index >= 0)
    {
      //setState(() {
        selectionCount = 1;
        widget.onSelectionCountChanged?.call(selectionCount);
      //});
    }
  }

  void exitMultiSelect()
  {
    selectionCount = 0;
    print('exitMultiSelect');
    widget.onSelectionCountChanged?.call(selectionCount);
    setState(() {
      isSelected = List.filled(messages.length, false, growable: true);
      });
  }

  void toggleSelect(int id)
  {
    final index = messages.indexWhere((u) => u.id == id);
    print('toggleSelect '+ id.toString());
    if(index >= 0)
    {
      setState(() {
        isSelected[index] = !isSelected[index];
      });
      if(isSelected[index])
      {
        selectionCount++;
      }
      else
      {
        selectionCount--;
      }
      widget.onSelectionCountChanged?.call(selectionCount);
    }
  }

  void deleteSelected()
  {
    //setState(() {
      selectionCount = 0;
      widget.onSelectionCountChanged?.call(selectionCount);
      int deleted = 0;
      for(var i = messages.length - 1; i >= 0; i--){
        if(isSelected[i])
        {
          deleteMessage(messages[i].id, popEvent: false);
          deleted++;
        }
      }
      widget.onMessageDeleted?.call(deleted);
    //});
  }

  void deleteMessage(int id,{bool popEvent = true}) {
    final index = messages.indexWhere((u) => u.id == id);
    var message = messages.removeAt(index);
    if(popEvent)
    {
      widget.onSingleMessageDeleted?.call();
    }
    isSelected.removeAt(index);
    favorites.removeAt(index);
    setState(() {
      print("isSelected.length "+ isSelected.length.toString());
      listRef.currentState?.removeItem(
        index,
        (context, animation) {
          return FadeTransition(
            opacity:
                CurvedAnimation(parent: animation, curve: Interval(0.5, 1.0)),
            child: SizeTransition(
              sizeFactor:
                  CurvedAnimation(parent: animation, curve: Interval(0.0, 1.0)),
              axisAlignment: 0.0,
              child: buildItem(index, message, context),
            ),
          );
        },
        duration: Duration(milliseconds: 600),
      );
    });
  }

  void addToFavorite(int id) {
    final index = messages.indexWhere((u) => u.id == id);
    var message = messages.elementAt(index);
    setState(() {
      favorites[index] = true;
    });
    widget.onFavoriteChanged?.call(message.id, true);
  }
  Widget buildItem(int index, Message message, BuildContext context) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child:
        ListTile(
          key: ValueKey<Message>(message),
          selected: index<isSelected.length?isSelected[index]:false,
          title: Text(message.title??"Untitled"),
          subtitle: Text(message.date.toString()),
          selectedTileColor: Colors.amber,
          leading: CircleAvatar(
            child: buildHeroWidget(context, message.id, message.icon??"no_icon"),
          ),
          trailing: Visibility(
            child: Icon(Icons.favorite),
            visible: index<favorites.length?favorites[index]:false,
          ),
          onTap: () {
            if(selectionCount > 0)
            {
              toggleSelect(message.id);
            }
            else
            {
              Navigator.pushNamed(context, '/detail', arguments: message);
            }
          },
          onLongPress: () {
            toggleSelect(message.id);
          },
        ),
        actions: <Widget>[
          IconSlideAction(
            caption: 'Delete',
            color: Colors.red,
            icon: Icons.delete,
            onTap: () => deleteMessage(message.id),
          ),
          IconSlideAction(
            caption: 'Favorite',
            color: Colors.amber,
            icon: Icons.favorite,
            onTap: () => addToFavorite(message.id),
          ),
        ],
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
                child: buildItem(index, messages[index], context),
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
    //return Image.asset(iconPath, fit: BoxFit.cover);
    // return CachedNetworkImage(
    //   imageUrl: iconPath,
    //   placeholder: (context, url) => CircularProgressIndicator(),
    //   errorWidget: (context, url, error) => Icon(Icons.error),
    //   fit: BoxFit.cover,
    // );
    return Image.network(iconPath, fit: BoxFit.cover);
  }
}
