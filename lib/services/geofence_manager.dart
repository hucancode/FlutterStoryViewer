import 'dart:convert';
import 'dart:io';
import 'package:flutter_geofence/geofence.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class GeofenceManager {
  static const LOCAL_CACHE = 'geofences.json';
  static const CACHE_MAX_AGE_HOUR = 12;
  static const SERVER_ENDPOINT = 'pop-ex.atpop.info:3100';
  static const READ_API = '/geofence/read';

  static final GeofenceManager _instance = GeofenceManager._privateConstructor();
  GeofenceManager._privateConstructor();

  factory GeofenceManager() {
    return _instance;
  }

  Future<void> initialize() async {
    Geofence.initialize();
    Geofence.requestPermissions();
    await readOrFetch();
    await addGeofences();
  }

  Future<File> get cacheFile async {
    final directory = await getApplicationDocumentsDirectory();
    final fullPath = '${directory.path}/$LOCAL_CACHE';
    print('cacheFile = $fullPath');
    return File(fullPath);
  }

  Future<void> readOrFetch() async {
    try
    {
      final file = await cacheFile;
      final date = await file.lastModified();
      final now = DateTime.now();
      if(now.difference(date).inHours < CACHE_MAX_AGE_HOUR)
      {
        return await readFromCache();
      }
    } on Exception catch (e) {
      print('error while reading cache ${e.toString()}');
    }
    return await fetch();
  }

  Future<void> readFromCache() async {
    print("MessageFetcher readFromCache()");
    try {
      final cache = await cacheFile;
      String response = await cache.readAsString();
      Iterable it = json.decode(response);
    } on Exception catch (e) {
      print('error while fetching json ${e.toString()}');
    }
  }

  Future<void> writeToCache(dynamic jsonData) async {
    final file = await cacheFile;
    file.writeAsString(jsonEncode(jsonData));
  }

  Future<void> fetch() async {
    print("MessageFetcher fetch()");
    try {
      var uri = Uri.https(SERVER_ENDPOINT, READ_API);
      var response = await http.get(uri).timeout(Duration(seconds: 10));
      //print('response(${response.statusCode}) = ${response.body}');
      if (response.statusCode == 200)
      {
        var responseJson = jsonDecode(response.body);
        
        writeToCache(responseJson);
      }
    } on Exception catch (e) {
      print('error while fetching json ${e.toString()}');
    }
  }

  Future<void> addGeofences() async {
    
  }
}