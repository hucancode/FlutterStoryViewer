import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pop_experiment/models/message.dart';
import 'package:pop_experiment/services/message_fetcher.dart';

enum MessageListEventType
{
  insert, delete, favorite, select
}

class MessageListEvent
{
  final MessageListEventType type;
  final int index;

  MessageListEvent(this.type, this.index);
}

class MessageList extends ChangeNotifier {
  var availableId = 99;
  static const DUMMY_TITLE = 'Integer quis mi a sit amet id turpis. ';
  static const DUMMY_CONTENT = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum ac vulputate est. Etiam a dolor vel sem dictum molestie. Morbi quis venenatis orci, eu euismod lorem. Proin rutrum odio vel luctus interdum. Suspendisse pellentesque orci rutrum semper sagittis. Integer quis mi a massa tempus luctus sit amet id turpis. Quisque facilisis sapien eu erat tincidunt commodo. Morbi sodales felis eu orci venenatis rutrum. Donec eu dictum ante, et varius sapien. Curabitur convallis erat leo, in sagittis nulla auctor sit amet. Maecenas a iaculis lacus.';
  List<Message> messages = [];
  var eventController = StreamController<MessageListEvent>.broadcast();

  String getRandomString(int len) {
    return String.fromCharCodes(
      List.generate(len, (index) => Random().nextInt(33) + 89)
    );
  }

  Future<void> loadMessages() async
  {
    messages = await MessageFetcher().readOrFetch();
  }

  Message readById(int id) => messages.singleWhere((element) => element.id == id);

  void addMessage({String title = DUMMY_TITLE, String content = DUMMY_CONTENT}) {
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
    notifyListeners();
    eventController.add(MessageListEvent(MessageListEventType.insert, 0));
  }

  void selectNone()
  {
    messages.forEach((element) {
      element.isSelected = false;
      });
    notifyListeners();
  }

  void toggleSelect(int id)
  {
    final message = messages.singleWhere((element) => element.id == id);
    message.isSelected = !message.isSelected;
    notifyListeners();
  }

  int get totalSelected => messages.fold(0, (total, element) => total + (element.isSelected?1:0));

  void deleteSelected()
  {
    final int lengthBefore = messages.length;
    messages.asMap().forEach((index, element) {
      if(element.isSelected)
      {
        eventController.add(MessageListEvent(MessageListEventType.delete, index));
      }
    });
    messages.removeWhere((element) => element.isSelected);
    print('deleteSelected messages count = $lengthBefore -> ${messages.length}');
    notifyListeners();
  }

  void deleteMessage(int id) {
    print('deleteMessage $id');
    final index = messages.indexWhere((element) => element.id == id);
    messages.removeWhere((element) => element.id == id);
    eventController.add(MessageListEvent(MessageListEventType.delete, index));
    notifyListeners();
  }

  void addToFavorite(int id) {
    final message = messages.singleWhere((element) => element.id == id);
    message.isFavorite = true;
    notifyListeners();
  }
  
}