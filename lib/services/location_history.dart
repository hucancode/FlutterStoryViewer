import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pop_experiment/models/location_hit.dart';

class LocationHistory extends ChangeNotifier {
  List<LocationHit> entries = List<LocationHit>.empty(growable: true);

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
    return;
    //TODO: rewrite serialization logic
    final file = await cacheFile;
    var jsonData = json.encode(entries);
    file.writeAsString(jsonData);
  }

  void add(LocationHit entry)
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
}