import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class GeofenceHistory extends ChangeNotifier {
  Set<int> history = Set<int>.identity();

  static const LOCAL_CACHE = 'geofence_history.json';
  static const RECENT_THRESHOLD_IN_DAY = 90;

  static final GeofenceHistory _instance = GeofenceHistory._privateConstructor();
  GeofenceHistory._privateConstructor();

  factory GeofenceHistory() {
    return _instance;
  }

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
      history = json.decode(response);
    } on Exception catch (e) {
      print('error while loading json ${e.toString()}');
    }
  }

  Future<void> save() async {
    final file = await cacheFile;
    var jsonData = jsonEncode(history);
    file.writeAsString(jsonEncode(jsonData));
  }

  void add(int entry)
  {
    history.add(entry);
    notifyListeners();
  }

  void remove(int entry)
  {
    history.remove(entry);
    notifyListeners();
  }
}