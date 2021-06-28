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
  LocationHit? active;

  // TODO: This file could accumulate up to 500k records, so consider using sqlite
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
    var jsonData = json.encode(entries.map((e) => e.toJson()).toList());
    print('LocationHistory save() data = $jsonData');
    file.writeAsString(jsonData);
  }

  int applyFilter(Filter filter)
  {
    var matched = false;
    var failed = false;
    const FULL_DAY_IN_MINUTE = 24*60;
    filter.locations.forEach((filter) {
      int time = 0;
      final twoDaySpan = filter.hitTimeMin.hour > filter.hitTimeMax.hour || 
          (filter.hitTimeMin.hour == filter.hitTimeMax.hour && filter.hitTimeMin.minute > filter.hitTimeMax.minute);
      entries.where((hit) {
        if(!hit.country.contains(filter.country)) {
          return false;
        }
        if(!hit.area.contains(filter.area)) {
          return false;
        }
        if(!hit.locality.contains(filter.locality)) {
          return false;
        }
        if(!hit.route.contains(filter.route)) {
          return false;
        }
        if(!hit.street.contains(filter.street)) {
          return false;
        }
        if(filter.postalCode.isNotEmpty && hit.postalCode != filter.postalCode) {
          return false;
        }
        if(hit.hitDay.isBefore(filter.hitDayMin) || hit.hitDay.isAfter(filter.hitDayMax)) {
          return false;
        }
        final afterMin = hit.hitDay.hour >= filter.hitTimeMin.hour && hit.hitDay.minute <= filter.hitTimeMin.minute;
        final beforeMax = hit.hitDay.hour <= filter.hitTimeMax.hour && hit.hitDay.minute <= filter.hitTimeMax.minute;
        final inRange = twoDaySpan?(afterMin || beforeMax):(afterMin && beforeMax);
        if(!inRange)
        {
          return false;
        }
        return true;
      }).forEach((e) {
        final lowerBound = max(e.hitDay.hour*60+e.hitDay.minute, 
          filter.hitTimeMin.hour*60+filter.hitTimeMin.minute);
        final upperBound = min(e.leaveDay.hour*60+e.leaveDay.minute, 
          filter.hitTimeMax.hour*60+filter.hitTimeMax.minute);
        time += max(0, twoDaySpan?FULL_DAY_IN_MINUTE:0 + upperBound - lowerBound);
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
    notifyListeners();
    save();
  }
}