import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_geofence/geofence.dart' as FlutterGeofence;
import 'package:path_provider/path_provider.dart';
import 'package:pop_experiment/services/server_config.dart';
import 'package:pop_experiment/models/geofence.dart';

class GeofenceService extends ChangeNotifier {
  static const LOCAL_CACHE = 'geofences.json';
  static const CACHE_MAX_AGE_HOUR = 12;
  static const READ_API = '/geofence/read';
  static const GEOFENCE_SCAN_RADIUS = 30000.0;
  static const FAKE_GEOFENCE_COUNT = 700000;

  List<Geofence> geofences = List<Geofence>.empty(growable: true);

  Future<void> load() async {
    
    //await generateFakeGeofence(FAKE_GEOFENCE_COUNT);
    await readOrFetch();
  }

  Future<File> get cacheFile async {
    final directory = await getApplicationDocumentsDirectory();
    final fullPath = '${directory.path}/$LOCAL_CACHE';
    print('cacheFile = $fullPath');
    return File(fullPath);
  }

  Future<void> readOrFetch() async {
    return await fetch();
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

  Future<void> generateFakeGeofence(int count) async
  {
    final start = DateTime.now();
    const LAT_SEED = 30.0;
    const LAT_VAR = 15.0;
    const LONG_SEED = 130.0;
    const LONG_VAR = 15.0;
    const THICKNESS_SEED = -0.3;
    const THICKNESS_VAR = 0.6;
    const RADIUS_SEED = 50.0;
    const RADIUS_VAR = 500.0;
    geofences = List<Geofence>.generate(count, (index)
    {
      final latOffset = Random().nextDouble()*LAT_VAR;
      final longOffset = latOffset/LAT_VAR*LONG_VAR + LONG_VAR*(THICKNESS_SEED + Random().nextDouble()*THICKNESS_VAR);
      final lat = LAT_SEED + latOffset;
      final long = LONG_SEED + longOffset;
      final radius = RADIUS_SEED + Random().nextDouble()*RADIUS_VAR;
      return Geofence(id: index, latitude: lat,longitude: long, radius: radius);
    });
    print('generateFakeGeofence costs ${DateTime.now().difference(start).inMilliseconds} ms');
  }

  Future<void> readFromCache() async {
    print("GeofenceHelper readFromCache()");
    try {
      final cache = await cacheFile;
      String response = await cache.readAsString();
      Iterable models = json.decode(response);
      geofences = models.map((model) => Geofence.fromJson(model)).toList();
    } on Exception catch (e) {
      print('error while fetching json ${e.toString()}');
    }
  }

  Future<void> writeToCache(dynamic jsonData) async {
    final file = await cacheFile;
    file.writeAsString(json.encode(jsonData));
  }

  Future<void> fetch() async {
    print("GeofenceService fetch()");
    try {
      final uri = Uri.parse('${ServerConfig.ENDPOINT}$READ_API');
      final response = await http.get(uri).timeout(Duration(seconds: ServerConfig.TIMEOUT_IN_SECOND));
      if (response.statusCode == 200)
      {
        final responseJson = json.decode(response.body);
        Iterable models = responseJson['data'];
        writeToCache(models);
        print('GeofenceService, got ${models.length}');
        geofences = models.map((model) => Geofence.fromJson(model)).toList();
      }
    } on Exception catch (e) {
      print('error while fetching json ${e.toString()}');
    }
  }

  double distance(FlutterGeofence.Coordinate a, FlutterGeofence.Coordinate b)
  {
    const RADIAN = pi/180;
    const EARTH_RADIUS_IN_METER = 6371000;
    final blat = a.latitude*RADIAN;
    final blong = a.longitude*RADIAN;
    final alat = b.latitude*RADIAN;
    final along = b.longitude*RADIAN;
    final dlat = blat - alat;
    final dlong = blong - along;
    final distance = pow(sin(dlat / 2), 2) + 
      pow(sin(dlong / 2), 2) * cos(alat) * cos(blat);
    final ret = EARTH_RADIUS_IN_METER * 2 * asin(sqrt(distance));
    //print('distance Coordinate - ${location.latitude} - ${location.longitude} to Geolocation(${fence.id}) - ${fence.latitude} - ${fence.longitude} returns $ret');
    return ret;
  }
  
  List<Geofence> getNearByGeofences({required FlutterGeofence.Coordinate location, double radius = GEOFENCE_SCAN_RADIUS}) {
    final start = DateTime.now();
    final ret = geofences.where((fence) {
      final a = location;
      final b = FlutterGeofence.Coordinate(fence.latitude, fence.longitude);
      return distance(a, b) < radius + fence.radius;
    }).toList();
    print('getNearByGeofences returns ${ret.length} fences, costs ${DateTime.now().difference(start).inMilliseconds} ms');
    return ret;
  }

  Geofence? getFirstOverlap(FlutterGeofence.Coordinate location)
  {
    geofences.firstWhere((fence) {
      final a = location;
      final b = FlutterGeofence.Coordinate(fence.latitude, fence.longitude);
      return distance(a, b) < fence.radius;
    });
  }
}