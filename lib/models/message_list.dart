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