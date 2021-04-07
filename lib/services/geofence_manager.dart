import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter_geofence/geofence.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class GeofenceManager {
  static const LOCAL_CACHE = 'geofences.json';
  static const CACHE_MAX_AGE_HOUR = 12;
  static const SERVER_ENDPOINT = 'pop-ex.atpop.info:3100';
  static const READ_API = '/geofence/read';
  static const NEAR_LOCATION_THRESHOLD = 10000;

  static final GeofenceManager _instance = GeofenceManager._privateConstructor();
  GeofenceManager._privateConstructor();

  factory GeofenceManager() {
    return _instance;
  }

  List<Geolocation> geofences = List<Geolocation>.empty();

  Future<void> initialize() async {
    Geofence.initialize();
    Geofence.requestPermissions();
    await readOrFetch();
  }

  Future<File> get cacheFile async {
    final directory = await getApplicationDocumentsDirectory();
    final fullPath = '${directory.path}/$LOCAL_CACHE';
    print('cacheFile = $fullPath');
    return File(fullPath);
  }

  Future<void> readOrFetch() async {
    return fetch();
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
      geofences = List<Geolocation>.from(it.map((model) => jsonToGeolocation(model)));
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
      print('response(${response.statusCode}) = ${response.body}');
      if (response.statusCode == 200)
      {
        Iterable it = jsonDecode(response.body);
        geofences = List<Geolocation>.from(it.map((model) => jsonToGeolocation(model)));
        writeToCache(it);
      }
    } on Exception catch (e) {
      print('error while fetching json ${e.toString()}');
    }
  }

  Geolocation jsonToGeolocation(Map<String, dynamic> json)
  {
    return Geolocation(
      id: json["id"].toString(), 
      latitude: json["latitude"], 
      longitude: json["longitude"], 
      radius: double.parse(json["radius"].toString()),
      );
  }

  double distance(Coordinate location, Geolocation fence)
  {
    const RADIAN = pi/180;
    const EARTH_RADIUS_IN_METER = 6371000;
    final blat = location.latitude*RADIAN;
    final blong = location.longitude*RADIAN;
    final alat = fence.latitude*RADIAN;
    final along = fence.longitude*RADIAN;
    final dlat = blat - alat;
    final dlong = blong - along;
    final distance = pow(sin(dlat / 2), 2) + 
      pow(sin(dlong / 2), 2) * cos(alat) * cos(blat);
    final ret = EARTH_RADIUS_IN_METER * 2 * asin(sqrt(distance));
    print('distance Coordinate - ${location.latitude} - ${location.longitude} to Geolocation(${fence.id}) - ${fence.latitude} - ${fence.longitude} returns $ret');
    return ret;
  }

  List<Geolocation> getNearByGeofences(Coordinate location) {
    return geofences.where((fence) {
      return distance(location, fence) < NEAR_LOCATION_THRESHOLD;
    }).toList();
  }
}