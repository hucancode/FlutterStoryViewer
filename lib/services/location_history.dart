import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pop_experiment/models/filter.dart';
import 'package:pop_experiment/models/location_hit.dart';

class LocationHistory extends ChangeNotifier {
  List<LocationHit> entries = List<LocationHit>.empty(growable: true);
  Placemark? active;

  static const LOCAL_CACHE = 'location_history.json';
  static const RECENT_THRESHOLD_IN_DAY = 90;

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

  Future<void> save() async {
    final file = await cacheFile;
    var jsonData = json.encode(entries);
    //TODO: rewrite serialization logic
    return;
    file.writeAsString(jsonData);
  }

  int applyFilter(Filter filter)
  {
    var matched = false;
    var failed = false;
    filter.locations.forEach((filter) {
      int time = 0;
      entries.forEach((hit) {
        if(!hit.country.contains(filter.country))
        {
          return;
        }
        if(!hit.areaLevel1.contains(filter.areaLevel1))
        {
          return;
        }
        if(!hit.areaLevel2.contains(filter.areaLevel2))
        {
          return;
        }
        if(!hit.locality.contains(filter.locality))
        {
          return;
        }
        if(!hit.route.contains(filter.route))
        {
          return;
        }
        if(!hit.street.contains(filter.street))
        {
          return;
        }
        if(hit.postalCode != filter.postalCode)
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
      print('apply filter ${filter.title}, return false because location history was not satified');
      return 6;
    }
    return 0;
  }

  void updateLocationWithPlacemark(Placemark place, double lat, double long)
  {
    final hit = LocationHit(latitude: lat, longitude: long);
    hit.country = place.country??"";
    hit.areaLevel1 = place.administrativeArea??"";
    hit.areaLevel2 = place.subAdministrativeArea??"";
    hit.locality = place.locality??"";
    hit.route = place.subLocality??"";
    hit.street = place.thoroughfare??"";
    hit.street += place.subThoroughfare??"";
    hit.postalCode = place.postalCode??"";
    if(active == null)
    {
      active = place;
    }
    if(entries.isEmpty)
    {
      entries.add(hit);
      return;
    }
    if(place != active)
    {
      entries.add(hit);
      return;
    }
    final today = DateTime.now();
    final sameDay = entries.last.hitDay.year == today.year && 
    entries.last.hitDay.month == today.month && 
    entries.last.hitDay.day == today.day;
    if(sameDay)
    {
      entries.last.lastSeen = TimeOfDay.now();
    }
    else
    {
      entries.last.lastSeen = TimeOfDay(hour: 23, minute: 59);
      final newDayEntry = LocationHit(latitude: lat, longitude: long);
      newDayEntry.hitTime = TimeOfDay(hour: 0, minute: 0);
      newDayEntry.lastSeen = TimeOfDay.now();
      entries.add(newDayEntry);
    }
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
    notifyListeners();
    save();
  }
}