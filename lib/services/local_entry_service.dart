import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pop_experiment/models/entry.dart';
import 'package:pop_experiment/models/profile.dart';
import 'package:pop_experiment/services/beacon_history.dart';
import 'package:pop_experiment/services/filter_service.dart';
import 'package:pop_experiment/services/geofence_history.dart';
import 'package:pop_experiment/services/location_history.dart';

// TODO: merge services and provider to one, name it as Service

enum EntryEventType
{
  insert, delete, favorite, select
}

class EntryEvent
{
  final EntryEventType type;
  final int index;

  EntryEvent(this.type, this.index);
}

class LocalEntryService extends ChangeNotifier {
  List<Entry> entries = [];
  var eventController = StreamController<EntryEvent>.broadcast();

  void loadWithProvider(List<Entry> data, 
    {
      required FilterService filterProvider, 
      required Profile profileProvider, 
      required GeofenceHistory geofenceHistoryProvider, 
      required LocationHistory locationHistoryProvider, 
      required BeaconHistory beaconHistoryProvider, 
    })
  {
    loadWithCallback(data, 
      profileCheck: (filterID)
      {
        final filter = filterProvider.readById(filterID);
        final error = profileProvider.applyFilter(filter);
        if(error != 0)
        {
          print('entry filtered out, filter result = $error');
          return false;
        }
        return true;
      },
      geofenceCheck: (filterID)
      {
        final filter = filterProvider.readById(filterID);
        final error = geofenceHistoryProvider.applyFilter(filter);
        if(error != 0)
        {
          print('entry filtered out, filter result = $error');
          return false;
        }
        return true;
      },
      beaconCheck: (filterID)
      {
        final filter = filterProvider.readById(filterID);
        final error = geofenceHistoryProvider.applyFilter(filter);
        if(error != 0)
        {
          print('entry filtered out, filter result = $error');
          return false;
        }
        return true;
      },
    );
  }

  void loadWithCallback(List<Entry> data, 
  {
    bool Function(int filterID)? profileCheck, 
    bool Function(int filterID)? geofenceCheck, 
    bool Function(int filterID)? beaconCheck
  })
  {
    entries = data.where((e) {
      if(e.filterID == null)
      {
        return true;
      }
      var success;
      success = profileCheck?.call(e.filterID!)??true;
      if(!success)
      {
        return false;
      }
      success = geofenceCheck?.call(e.filterID!)??true;
      if(!success)
      {
        return false;
      }
      success = beaconCheck?.call(e.filterID!)??true;
      if(!success)
      {
        return false;
      }
      return true;
    }).toList();
  }

  Entry readById(int id) => entries.singleWhere((element) => element.id == id);

  void add(Entry entry) {
    entries.insert(0, entry);
    notifyListeners();
    eventController.add(EntryEvent(EntryEventType.insert, 0));
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

  List<Entry> forGeofence(int id)
  {
    return entries.where((e) => e.geofences.contains(id)).toList();
  }

  void deleteSelected()
  {
    final int lengthBefore = entries.length;
    entries.asMap().forEach((index, element) {
      if(element.isSelected)
      {
        eventController.add(EntryEvent(EntryEventType.delete, index));
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
    eventController.add(EntryEvent(EntryEventType.delete, index));
    notifyListeners();
  }

  void addToFavorite(int id) {
    final entry = entries.singleWhere((element) => element.id == id);
    entry.isFavorite = true;
    notifyListeners();
  }
}