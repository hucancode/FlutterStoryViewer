import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pop_experiment/models/filter.dart';
import 'package:pop_experiment/models/geofence_hit.dart';

class GeofenceHistory extends ChangeNotifier {
  List<GeofenceHit> entries = List<GeofenceHit>.empty(growable: true);
  List<int> actives = List<int>.empty(growable: true);

  static const LOCAL_CACHE = 'geofence_history.json';
  static const RECENT_THRESHOLD_IN_DAY = 90;

  Future<File> get cacheFile async {
    final directory = await getApplicationDocumentsDirectory();
    final fullPath = '${directory.path}/$LOCAL_CACHE';
    print('cacheFile = $fullPath');
    return File(fullPath);
  }

  Future<void> load() async {
    print("GeofenceHistory load()");
    try {
      final cache = await cacheFile;
      String response = await cache.readAsString();
      print('GeofenceHistory load() response = $response');
      return;
      Iterable models = json.decode(response);
      entries = List<GeofenceHit>.from(models.map((e) => GeofenceHit.fromJson(e)));
    } on Exception catch (e) {
      print('error while loading json ${e.toString()}');
    }
  }

  Future<void> save() async {
    final file = await cacheFile;
    var jsonData = json.encode(entries);
    print('GeofenceHistory save() data = $jsonData');
    return;
    //TODO: rewrite serialization logic
    file.writeAsString(jsonData);
  }

  Future<void> enterGeofence(int id) async
  {
    if(!actives.contains(id))
    {
      actives.add(id);
    }
    entries.add(GeofenceHit(geofenceID: id));
    notifyListeners();
    save();
  }

  Future<void> exitGeofence(int id) async
  {
    if(!actives.contains(id))
    {
      return;
    }
    markSeenSingleGeofences(id);
    actives.remove(id);
    notifyListeners();
    save();
  }

  void markSeenActiveGeofences()
  {
    actives.forEach((id) {
      markSeenSingleGeofences(id);
    });
    save();
  }
  void markSeenSingleGeofences(int id)
  {
      final lastMatch = entries.lastWhere((e) => e.geofenceID == id, orElse: () => GeofenceHit(geofenceID: -1));
      if(lastMatch.geofenceID == -1)
      {
        return;
      }
      final today = DateTime.now();
      final sameDay = lastMatch.hitDay.year == today.year && 
      lastMatch.hitDay.month == today.month && 
      lastMatch.hitDay.day == today.day;
      if(sameDay)
      {
        lastMatch.lastSeen = TimeOfDay.now();
      }
      else
      {
        lastMatch.lastSeen = TimeOfDay(hour: 23, minute: 59);
        final newDayEntry = GeofenceHit(geofenceID: id);
        newDayEntry.hitTime = TimeOfDay(hour: 0, minute: 0);
        newDayEntry.lastSeen = TimeOfDay.now();
        entries.add(newDayEntry);
      }
  }

  int applyFilter(Filter filter)
  {
    var matched = false;
    var failed = false;
    filter.geofences.forEach((filter) {
      int time = 0;
      entries.forEach((hit) {
        if(hit.geofenceID != filter.geofenceID)
        {
          return;
        }
        if(hit.hitDay.isBefore(filter.hitDayMin) || hit.hitDay.isAfter(filter.hitDayMax))
        {
          return;
        }
        int a = hit.hitTime.hour * 60 + hit.hitTime.minute;
        int amin = filter.hitTimeMin.hour * 60 + filter.hitTimeMin.minute;
        int b = hit.lastSeen.hour * 60 + hit.lastSeen.minute;
        int bmax = filter.hitTimeMax.hour * 60 + filter.hitTimeMax.minute;
        time += min(bmax, b) - max(a, amin);
        if(time > filter.hitDurationMax)
        {
          return;
        }
      });
      matched = time >= filter.hitDurationMin && time <= filter.hitDurationMax;
      if(matched)
      {
        return;
      }
    });
    failed = (!matched && filter.genderMode == FilterMode.include) || 
      (matched && filter.genderMode == FilterMode.exclude);
    if(failed)
    {
      print('apply filter ${filter.title}, return false because geofence history was not satified');
      return 6;
    }
    return 0;
  }
}