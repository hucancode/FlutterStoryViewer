import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pop_experiment/models/filter.dart';
import 'package:pop_experiment/models/hit_query_mode.dart';
import 'package:pop_experiment/models/location_hit.dart';

class LocationHistory extends ChangeNotifier {
  List<LocationHit> entries = List<LocationHit>.empty(growable: true);
  LocationHit? active;
  DateTime lastSaveTimeStamp = DateTime.now();

  // TODO: This file could accumulate up to 500k records, so consider using sqlite
  static const int SAVE_VERSION = 1;// TODO: mark save version, for easier file format upgrade
  static const LOCAL_CACHE = 'location_history.json';
  static const SAVE_CACHE_COOLDOWN_IN_MINUTE = 1;
  static const RECENT_THRESHOLD_IN_DAY = 90;
  static const FUZZY_LOCATION_THRESHOLD_IN_MINUTE = 1;
  static const LOCATION_MERGE_TOLERANCE_IN_MINUTE = 5;

  Future<File> get cacheFile async {
    final directory = await getApplicationDocumentsDirectory();
    final fullPath = '${directory.path}/$LOCAL_CACHE';
    print('cacheFile = $fullPath');
    return File(fullPath);
  }

  Future<void> load() async {
    print("LocationHistory load()");
    try {
      final cache = await cacheFile;
      String response = await cache.readAsString();
      print('LocationHistory load() response = $response');
      Iterable models = json.decode(response);
      entries = List<LocationHit>.from(models.map((e) => LocationHit.fromJson(e)));
    } on Exception catch (e) {
      print('error while loading json ${e.toString()}');
    }
  }

  Future<void> save({bool force = false}) async {
    final now = DateTime.now();
    if(!force && lastSaveTimeStamp.difference(now).inMinutes < SAVE_CACHE_COOLDOWN_IN_MINUTE)
    {
      return;
    }
    cleanFuzzyLocation();
    lastSaveTimeStamp = now;
    final file = await cacheFile;
    var jsonData = json.encode(entries.map((e) => e.toJson()).toList());
    print('LocationHistory save() data = $jsonData');
    file.writeAsString(jsonData);
  }

  int applyFilter(Filter filter)
  {
    var matched = false;
    var failed = false;
    const FULL_DAY_IN_MINUTE = 24*60;
    // TODO: handle edge case, numDaysToQuery = 0
    filter.locations.forEach((filter) {
      final queryThisMoment = filter.numDayToQuery == 0;
      if(queryThisMoment)
      {
        matched = active?.matchLocationData(filter)??false;
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
    failed = (!matched && filter.locationMode == FilterMode.include) || 
      (matched && filter.locationMode == FilterMode.exclude);
    if(failed)
    {
      print('apply filter ${filter.title}, return false because location history was not satified');
      return 6;
    }
    return 0;
  }

  void swallowFuzzyLocation()
  {
    final beforeTodayIndex = max(0, entries.lastIndexWhere((e) => e.hitDay.day != DateTime.now().day || 
      e.hitDay.month != DateTime.now().month || e.hitDay.year != DateTime.now().year));
    //print('swallowFuzzyLocation() today mark: $today');
    int i = entries.length - 1;
    for(;i>beforeTodayIndex+1;i--)
    {
      if(entries[i].stayTimeInMinute <= FUZZY_LOCATION_THRESHOLD_IN_MINUTE)
      {
        //print('swallowFuzzyLocation() entry i($i) is insignificant');
        continue;
      }
      int j = i - 1;
      for(;j>beforeTodayIndex;j--)
      {
        final after = entries[i].hitDay;
        final before = entries[j].leaveDay;
        final interrupted = after.difference(before).inMinutes > LOCATION_MERGE_TOLERANCE_IN_MINUTE; 
        if(interrupted)
        {
          break;
        }
        final sameEntry = entries[i] == entries[j];
        if(sameEntry)
        {
          entries[j].leaveDay = entries[i].leaveDay;
          for(int k = i;k>j;k--)
          {
            entries.removeAt(k);
          }
          i = j;
          continue;
        }
        if(entries[j].stayTimeInMinute > FUZZY_LOCATION_THRESHOLD_IN_MINUTE)
        {
          break;
        }
      }
    }
  }

  void cleanFuzzyLocation()
  {
    var today = max(0, entries.lastIndexWhere((e) => e.hitDay.difference(DateTime.now()).inDays > 0));
    int i = entries.length - 2;
    for(;i>today;i--)
    {
      if(entries[i].stayTimeInMinute < 1)
      {
        entries.removeAt(i);
      }
    }
  }

  void updateLocationWithPlacemark(Placemark place, double lat, double long)
  {
    final hit = LocationHit(latitude: lat, longitude: long);
    hit.country = place.country??"";
    hit.area = '${place.administrativeArea} ${place.subAdministrativeArea}';
    hit.locality = place.locality??"";
    hit.route = place.thoroughfare??"";
    hit.street = place.subThoroughfare??"";
    hit.postalCode = place.postalCode??"";
    if(active == null)
    {
      active = hit;
    }
    if(entries.isEmpty)
    {
      entries.add(hit);
      return;
    }
    if(hit != active)
    {
      print('comparing current hit with last active place, place = $hit , active = $active');
      active = hit;
      entries.add(hit);
      return;
    }
    entries.last.leaveDay = DateTime.now();
  }

  Future<void> updateLocation(double lat, double long) async
  {
    final places = await placemarkFromCoordinates(lat, long, localeIdentifier: "jp");
    if(places.isEmpty)
    {
      return;
    }
    final place = places.first;
    updateLocationWithPlacemark(place, lat, long);
    swallowFuzzyLocation();
    notifyListeners();
    save();
  }
}