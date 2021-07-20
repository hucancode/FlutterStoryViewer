import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pop_experiment/models/filter.dart';
import 'package:pop_experiment/models/geofence_hit.dart';
import 'package:pop_experiment/models/hit_query_mode.dart';

class GeofenceHistory extends ChangeNotifier {
  List<GeofenceHit> entries = List<GeofenceHit>.empty(growable: true);
  List<int> actives = List<int>.empty(growable: true);
  DateTime lastSaveTimeStamp = DateTime.now();

  static const int SAVE_VERSION = 1;// TODO: mark save version, for easier file format upgrade
  static const LOCAL_CACHE = 'geofence_history.json';
  static const SAVE_CACHE_COOLDOWN_IN_MINUTE = 1;
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
      Iterable models = json.decode(response);
      entries = List<GeofenceHit>.from(models.map((e) => GeofenceHit.fromJson(e)));
    } on Exception catch (e) {
      print('error while loading json ${e.toString()}');
    }
  }

  Future<void> save({bool force = false}) async {
    final now = DateTime.now();
    if(!force && now.difference(lastSaveTimeStamp).inMinutes < SAVE_CACHE_COOLDOWN_IN_MINUTE)
    {
      return;
    }
    lastSaveTimeStamp = now;
    final file = await cacheFile;
    var jsonData = json.encode(entries.map((e) => e.toJson()).toList());
    print('GeofenceHistory save() data = $jsonData');
    file.writeAsString(jsonData);
  }

  Future<void> enter(int id) async
  {
    if(!actives.contains(id))
    {
      actives.add(id);
    }
    entries.add(GeofenceHit(geofenceID: id));
    notifyListeners();
    save();
  }

  Future<void> exit(int id) async
  {
    if(!actives.contains(id))
    {
      return;
    }
    markSeenSingle(id);
    actives.remove(id);
    notifyListeners();
    save();
  }

  void markSeenActive()
  {
    actives.forEach((id) {
      markSeenSingle(id);
    });
    save();
  }
  
  void markSeenSingle(int id)
  {
      final lastMatch = entries.lastWhere((e) => e.geofenceID == id, orElse: () => GeofenceHit(geofenceID: -1));
      if(lastMatch.geofenceID == -1)
      {
        return;
      }
      final now = DateTime.now();
      final sameDay = lastMatch.hitDay.year == now.year && 
      lastMatch.hitDay.month == now.month && 
      lastMatch.hitDay.day == now.day;
      if(sameDay)
      {
        lastMatch.leaveDay = now;
      }
      else
      {
        lastMatch.leaveDay = DateTime(
          lastMatch.hitDay.year, lastMatch.hitDay.month, lastMatch.hitDay.day, 
          23, 59);
        final newDayEntry = GeofenceHit(geofenceID: id);
        newDayEntry.hitDay = DateTime(
          now.year, now.month, now.day, 
          0, 0);
        newDayEntry.leaveDay = now;
        entries.add(newDayEntry);
      }
  }

  int applyFilter(Filter filter)
  {
    var matched = false;
    var failed = false;
    const FULL_DAY_IN_MINUTE = 24*60;
    // TODO: handle edge case, numDaysToQuery = 0
    filter.geofences.forEach((filter) {
      final queryThisMoment = filter.numDayToQuery == 0;
      if(queryThisMoment)
      {
        matched = actives.contains(filter.geofenceID);
        return;
      }
      final passedEntries = entries.where((hit) {
        return hit.match(filter);
      });
      int time = 0;
      passedEntries.forEach((e) {
        final lowerBound = max(e.hitDay.hour*60+e.hitDay.minute, 
          filter.hitTimeMin.hour*60+filter.hitTimeMin.minute);
        final upperBound = min(e.leaveDay.hour*60+e.leaveDay.minute, 
          filter.hitTimeMax.hour*60+filter.hitTimeMax.minute);
        time += max(0, filter.isTwoDaySpan?FULL_DAY_IN_MINUTE:0 + upperBound - lowerBound);
      });
      int days = passedEntries.map((e) => e.hitDay.year*10000 + e.hitDay.month*1000 + e.hitDay.day).toSet().length;
      int result = 0;
      switch(filter.queryMode)
      {
        case HitQueryMode.averageDuration:
          result = (days==0)?0:(time~/days);
          break;
        case HitQueryMode.countNumberOfDay:
          result = days;
          break;
      }
      matched = result >= filter.queryMin && result <= filter.queryMax;
      if(matched)
      {
        return;
      }
    });
    failed = (!matched && filter.geofenceMode == FilterMode.include) || 
      (matched && filter.geofenceMode == FilterMode.exclude);
    if(failed)
    {
      print('apply filter ${filter.title}, return false because geofence history was not satified');
      return 6;
    }
    return 0;
  }
}