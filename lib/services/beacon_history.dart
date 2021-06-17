import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pop_experiment/models/beacon_hit.dart';
import 'package:pop_experiment/models/filter.dart';

class BeaconHistory extends ChangeNotifier {
  List<BeaconHit> entries = List<BeaconHit>.empty(growable: true);

  static const LOCAL_CACHE = 'beacon_history.json';
  static const RECENT_THRESHOLD_IN_DAY = 90;

  Future<File> get cacheFile async {
    final directory = await getApplicationDocumentsDirectory();
    final fullPath = '${directory.path}/$LOCAL_CACHE';
    print('cacheFile = $fullPath');
    return File(fullPath);
  }

  Future<void> load() async {
    print("BeaconHistory load()");
    try {
      final cache = await cacheFile;
      String response = await cache.readAsString();
      print('BeaconHistory load() response = $response');
      Iterable models = json.decode(response);
      entries = List<BeaconHit>.from(models.map((e) => BeaconHit.fromJson(e)));
    } on Exception catch (e) {
      print('error while loading json ${e.toString()}');
    }
  }

  Future<void> save() async {
    return;
    //TODO: rewrite serialization logic
    final file = await cacheFile;
    var jsonData = json.encode(entries);
    file.writeAsString(jsonData);
  }

  void add(BeaconHit entry)
  {
    return;
    //TODO: rewrite add entry logic
    if(entries.contains(entry))
    {
      return;
    }
    entries.add(entry);
    notifyListeners();
    save();
  }

  int applyFilter(Filter filter)
  {
    var matched = false;
    var failed = false;
    filter.beacons.forEach((filter) {
      int time = 0;
      entries.forEach((hit) {
        if(hit.beaconID != filter.beaconID)
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
      matched |= time >= filter.hitDurationMin && time <= filter.hitDurationMax;
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