import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pop_experiment/models/discovery_entry.dart';

class DiscoveryHistory extends ChangeNotifier {
  List<DiscoveryEntry> history = List<DiscoveryEntry>.empty();

  static const LOCAL_CACHE = 'discovery_history.json';
  static const RECENT_THRESHOLD_IN_DAY = 90;

  static final DiscoveryHistory _instance = DiscoveryHistory._privateConstructor();
  DiscoveryHistory._privateConstructor();

  factory DiscoveryHistory() {
    return _instance;
  }

  Future<File> get cacheFile async {
    final directory = await getApplicationDocumentsDirectory();
    final fullPath = '${directory.path}/$LOCAL_CACHE';
    print('cacheFile = $fullPath');
    return File(fullPath);
  }

  Future<void> load() async {
    print("MessageFetcher readFromCache()");
    try {
      final cache = await cacheFile;
      String response = await cache.readAsString();
      Iterable it = json.decode(response);
      history = List<DiscoveryEntry>.from(it.map((model) => DiscoveryEntry.fromJson(model)));
    } on Exception catch (e) {
      print('error while fetching json ${e.toString()}');
    }
  }

  Future<void> save() async {
    final file = await cacheFile;
    var jsonData = jsonEncode(history);
    file.writeAsString(jsonEncode(jsonData));
  }

  List<DiscoveryEntry> getEntries()
  {
    return history;
  }

  List<DiscoveryEntry> getRecentEntries()
  {
    final now = DateTime.now();
    return history.takeWhile((entry) {
      return now.difference(entry.date).inDays < RECENT_THRESHOLD_IN_DAY;
    }).toList(growable: false);
  }

  void addEntry(DiscoveryEntry entry)
  {
    history.add(entry);
    notifyListeners();
  }
}