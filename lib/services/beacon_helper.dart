// @dart=2.9
import 'dart:async';
import 'dart:io';
import 'package:beacons_plugin/beacons_plugin.dart';
import 'package:path_provider/path_provider.dart';

class BeaconHelper {

  static const LOCAL_CACHE = 'beacons.json';
  static final BeaconHelper _instance = BeaconHelper._privateConstructor();
  BeaconHelper._privateConstructor();

  factory BeaconHelper() {
    return _instance;
  }

  bool initialized = false;// TODO: use completer
  final StreamController<String> beaconEventsController = StreamController<String>.broadcast();
  Future<void> initialize() async {
    if(initialized)
    {
      return;
    }
    initialized = true;
    BeaconsPlugin.listenToBeacons(beaconEventsController);
    // if you need to monitor also major and minor use the original version and not this fork
    await BeaconsPlugin.addRegion("myRegion", "01022022-f88f-0000-00ae-9605fd9bb620");
    await BeaconsPlugin.runInBackground(true);
  }

  void startListening(Function(String) onBeaconReceived) async 
  {
    print('BeaconsPlugin.listenToBeacons ...');
    beaconEventsController.stream.listen((data) {
      onBeaconReceived(data);
    });
    if (Platform.isAndroid) {
      BeaconsPlugin.channel.setMethodCallHandler((call) async {
        if (call.method == 'scannerReady') {
          await BeaconsPlugin.startMonitoring;
        }
      });
    } else if (Platform.isIOS) {
      print('BeaconsPlugin.startMonitoring...');
      await BeaconsPlugin.startMonitoring;
    }
    
  }
  void stopListenning() async
  {
    await BeaconsPlugin.stopMonitoring;
  }

  Future<File> get cacheFile async {
    final directory = await getApplicationDocumentsDirectory();
    final fullPath = '${directory.path}/$LOCAL_CACHE';
    print('cacheFile = $fullPath');
    return File(fullPath);
  }

}