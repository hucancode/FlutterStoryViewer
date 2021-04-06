import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:pop_experiment/models/message.dart';
import 'package:pop_experiment/views/widgets/radial_expansion.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:enough_mail/enough_mail.dart';

String getRandomString(int len) {
  var r = Random();
  return String.fromCharCodes(List.generate(len, (index) => r.nextInt(33) + 89));
}

typedef SelectionCountCallback = void Function(int);
typedef MessageDeletedCallback = void Function(int);
typedef SingleMessageDeletedCallback = void Function();
typedef FavoriteChangedCallback = void Function(int, bool);

class MimeMessageList extends StatefulWidget {
  final List<MimeMessage>? initialMessages;
  final SelectionCountCallback? onSelectionCountChanged;
  final MessageDeletedCallback? onMessageDeleted;
  final SingleMessageDeletedCallback? onSingleMessageDeleted;
  final FavoriteChangedCallback? onFavoriteChanged;
  
  MimeMessageList({
    Key? key, 
    this.initialMessages, 
    this.onSelectionCountChanged,
    this.onMessageDeleted,
    this.onSingleMessageDeleted,
    this.onFavoriteChanged,
    }) : super(key: key);
  MimeMessageListState createState()
  {
    return MimeMessageListState(
      messages: initialMessages??[], 
    );
  }
}

class MimeMessageListState extends State<MimeMessageList> {
  final GlobalKey<AnimatedListState> listRef = GlobalKey();
  List<bool> isSelected = [];
  List<bool> favorites = [];
  int selectionCount = 0;
  List<MimeMessage> messages;
  MimeMessageListState({
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

  void addMessage(MimeMessage message) {
    setState(() {
      messages.insert(0, message);
      listRef.currentState?.insertItem(0, duration: Duration(milliseconds: 300));
      isSelected.insert(0, false);
      favorites.insert(0, false);
    });
  }

  void enterMultiSelect(int id) {
    print('enterMultiSelect '+id.toString());
    final index = messages.indexWhere((u) => u.uid == id);
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
    final index = messages.indexWhere((u) => u.uid == id);
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
          deleteMessage(messages[i].uid, popEvent: false);
          deleted++;
        }
      }
      widget.onMessageDeleted?.call(deleted);
    //});
  }

  void deleteMessage(int id,{bool popEvent = true}) {
    final index = messages.indexWhere((u) => u.uid == id);
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
    final index = messages.indexWhere((u) => u.uid == id);
    var message = messages.elementAt(index);
    setState(() {
      favorites[index] = true;
    });
    widget.onFavoriteChanged?.call(message.uid, true);
  }

  Widget buildItem(int index, MimeMessage message, BuildContext context) {
    print('mime_message_list - buildItem');
    String title = message.decodeSubject()??"Untitled";
    DateTime date = message.decodeDate()??DateTime.now();
    String dateStr = DateFormat('yyyy-MM-dd hh:mm').format(date);
    String iconUrl = 'https://picsum.photos/seed/'+index.toString()+'/128/128';
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: ListTile(
        key: ValueKey<MimeMessage>(message),
        selected: index<isSelected.length?isSelected[index]:false,
        title: Text(title),
        subtitle: Text(dateStr),
        selectedTileColor: Colors.amber,
        leading: CircleAvatar(
          child: buildMessageIcon(iconUrl),
        ),
        trailing: Visibility(
          child: Icon(Icons.favorite),
          visible: index<favorites.length?favorites[index]:false,
        ),
        onTap: () {
          if(selectionCount > 0)
          {
            toggleSelect(message.uid);
          }
          else
          {
            Navigator.pushNamed(context, '/mime_detail', arguments: message);
          }
        },
        onLongPress: () {
          toggleSelect(message.uid);
        },
      ),
      actions: <Widget>[
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () => deleteMessage(message.uid),
        ),
        IconSlideAction(
          caption: 'Favorite',
          color: Colors.amber,
          icon: Icons.favorite,
          onTap: () => addToFavorite(message.uid),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    print('mime_message_list build');
    return Expanded(
      child: AnimatedList(
        key: listRef,
        initialItemCount: messages.length,
        itemBuilder: (context, index, animation) {
          return FadeTransition(
            opacity: animation,
            child: buildItem(index, messages[index], context),
          );
        },
      ),
    );
  }

  Widget buildMessageIcon(String iconPath) {
    return ClipOval(child: Image.network(iconPath, fit: BoxFit.cover));
  }
}
