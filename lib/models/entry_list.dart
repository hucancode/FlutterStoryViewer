import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pop_experiment/models/entry.dart';
import 'package:pop_experiment/services/entry_service.dart';

enum EntryListEventType
{
  insert, delete, favorite, select
}

class EntryListEvent
{
  final EntryListEventType type;
  final int index;

  EntryListEvent(this.type, this.index);
}

class EntryList extends ChangeNotifier {
  List<Entry> entries = [];
  var eventController = StreamController<EntryListEvent>.broadcast();

  Future<void> load() async
  {
    entries = await EntryService().readOrFetch();
  }

  Entry readById(int id) => entries.singleWhere((element) => element.id == id);

  void add(Entry entry) {
    entries.insert(0, entry);
    notifyListeners();
    eventController.add(EntryListEvent(EntryListEventType.insert, 0));
  }

  void selectNone()
  {
    entries.forEach((element) {
      element.isSelected = false;
      });
    notifyListeners();
  }

  void toggleSelect(int id)
  {
    final entry = entries.singleWhere((element) => element.id == id);
    entry.isSelected = !entry.isSelected;
    notifyListeners();
  }

  int get totalSelected => entries.fold(0, (total, element) => total + (element.isSelected?1:0));

  void deleteSelected()
  {
    final int lengthBefore = entries.length;
    entries.asMap().forEach((index, element) {
      if(element.isSelected)
      {
        eventController.add(EntryListEvent(EntryListEventType.delete, index));
      }
    });
    entries.removeWhere((element) => element.isSelected);
    print('deleteSelected entries count = $lengthBefore -> ${entries.length}');
    notifyListeners();
  }

  void delete(int id) {
    print('delete $id');
    final index = entries.indexWhere((element) => element.id == id);
    entries.removeWhere((element) => element.id == id);
    eventController.add(EntryListEvent(EntryListEventType.delete, index));
    notifyListeners();
  }

  void addToFavorite(int id) {
    final entry = entries.singleWhere((element) => element.id == id);
    entry.isFavorite = true;
    notifyListeners();
  }
  
}