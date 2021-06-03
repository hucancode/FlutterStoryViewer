import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class GeofenceHistory extends ChangeNotifier {
  List<int> entries = List<int>.empty(growable: true);

  static const LOCAL_CACHE = 'geofence_history.json';
  static const RECENT_THRESHOLD_IN_DAY = 90;

  Future<File> get cacheFile async {
    final directory = await getApplicationDocumentsDirectory();
    final fullPath = '${directory.path}/$LOCAL_CACHE';
    print('cacheFile = $fullPath');
    return File(fullPath);
  }

  Future<void> load() async {
    print("DiscoveryHistory load()");
    try {
      final cache = await cacheFile;
      String response = await cache.readAsString();
      entries = json.decode(response);
    } on Exception catch (e) {
      print('error while loading json ${e.toString()}');
    }
  }

  Future<void> save() async {
    final file = await cacheFile;
    var jsonData = json.encode(entries);
    file.writeAsString(json.encode(jsonData));
  }

  void add(int entry)
  {
    if(entries.contains(entry))
    {
      return;
    }
    entries.add(entry);
    notifyListeners();
    save();
  }

  void remove(int entry)
  {
    entries.remove(entry);
    notifyListeners();
    save();
  }
}