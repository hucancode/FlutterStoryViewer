import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:beacons_plugin/beacons_plugin.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pop_experiment/models/beacon.dart';
import 'package:pop_experiment/services/server_config.dart';

class BeaconService extends ChangeNotifier {

  static const LOCAL_CACHE = 'beacons.json';
  static const CACHE_MAX_AGE_HOUR = 12;
  static const SERVER_ENDPOINT = 'pop-ex.atpop.info:3100';
  static const READ_API = '/beacon/read';
  static const DEFAULT_BEACON_NAME = "MyBeacon";

  bool initialized = false;// TODO: use completer
  final StreamController<String> beaconEventsController = StreamController<String>.broadcast();
  List<Beacon> beacons = List<Beacon>.empty();

  Future<void> initialize() async {
    if(initialized)
    {
      return;
    }
    initialized = true;
    // Put this before calling any beacon operation. This method should be named "initializePlugin"
    // This plugin needs more works. Improve it or use different plugin if possible
    BeaconsPlugin.listenToBeacons(beaconEventsController); 
    await BeaconsPlugin.runInBackground(true);
  }

  Future<void> registerAllBeacons() async {
    await BeaconsPlugin.clearRegions();
    beacons.forEach((beacon) {
      registerBeacon(beacon.uuid, beacon.title??DEFAULT_BEACON_NAME);
    });
  }

  Future<void> registerBeacon(String uuid, String title) async {
    await initialize();
    await BeaconsPlugin.addRegion(title, uuid);
  }

  Future<void> startListening(Function(String) onBeaconReceived) async 
  {
    await initialize();
    print('BeaconsPlugin.listenToBeacons ...');
    beaconEventsController.stream.listen((data) {
      onBeaconReceived(data);
    });
    if (Platform.isAndroid) {
      BeaconsPlugin.channel.setMethodCallHandler((call) async {
        if (call.method == 'scannerReady') {
          await BeaconsPlugin.startMonitoring();
        }
      });
    } else if (Platform.isIOS) {
      print('BeaconsPlugin.startMonitoring...');
      await BeaconsPlugin.startMonitoring();
    }
  }
  Future<void> stopListenning() async
  {
    await BeaconsPlugin.stopMonitoring();
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
  
  Future<void> readFromCache() async {
    print("BeaconHelper readFromCache()");
    try {
      final cache = await cacheFile;
      String response = await cache.readAsString();
      Iterable it = json.decode(response);
      beacons = List<Beacon>.from(it.map((model) => Beacon.fromJson(model)));
    } on Exception catch (e) {
      print('error while fetching json ${e.toString()}');
    }
    registerAllBeacons();
  }

  Future<void> writeToCache(dynamic jsonData) async {
    final file = await cacheFile;
    file.writeAsString(json.encode(jsonData));
  }

  Future<void> fetch() async {
    print("BeaconHelper fetch()");
    try {
      final uri = Uri.parse('${ServerConfig.ENDPOINT}$READ_API');
      final response = await http.get(uri).timeout(Duration(seconds: ServerConfig.TIMEOUT_IN_SECOND));
      print('response(${response.statusCode}) = ${response.body}');
      if (response.statusCode == 200)
      {
        Iterable it = json.decode(response.body);
        beacons = List<Beacon>.from(it.map((model) => Beacon.fromJson(model)));
        writeToCache(it);
      }
    } on Exception catch (e) {
      print('error while fetching json ${e.toString()}');
    }
    registerAllBeacons();
  }
}