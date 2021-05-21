import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_geofence/geofence.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pop_experiment/services/beacon_helper.dart';
import 'package:pop_experiment/services/geofence_helper.dart';
import 'package:pop_experiment/services/notification_helper.dart';

class GeofenceMap extends StatefulWidget {
  GeofenceMapState createState() => GeofenceMapState();
}

class GeofenceMapState extends State<GeofenceMap> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const DEFAULT_ZOOM = 14.4746;
  static const DEFAULT_LAT = 34.2237964;
  static const DEFAULT_LONG = 133.8622095;
  static const LOCATION_UPDATE_INTERVAL = 2000; // Only affects android
  static const LOCATION_UPDATE_BG_INTERVAL = 6000; // Only affects android
  static const USE_LOCATION_LIBRARY = true;
  Coordinate lastKnownLocation = Coordinate(DEFAULT_LAT, DEFAULT_LONG);//TODO: save this value to file
  Coordinate fencePivot = Coordinate(DEFAULT_LAT, DEFAULT_LONG);
  Completer<GoogleMapController> controller = Completer();
  Set<Circle> fenceCircles = Set<Circle>.identity();
  bool showDebugControls = false;

  final distanceCtrl = TextEditingController();
  final fenceCountCtrl = TextEditingController();
  
  static final CameraPosition marugameOffice = CameraPosition(
    target: LatLng(34.2237964, 133.8622095),
    zoom: DEFAULT_ZOOM,
  );


  @override
  void initState()
  {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    Geofence.startListening(GeolocationEvent.entry, (location)
    {
      print("Entry of a georegion ${location.id}");
      NotificationHelper().send("Entry of a georegion", "Welcome to: ${location.id}");
    });
    if(USE_LOCATION_LIBRARY)
    {
      Location().enableBackgroundMode(enable: true);
      Location().changeSettings(
        accuracy: LocationAccuracy.high,
        interval: LOCATION_UPDATE_INTERVAL);
      Location().getLocation().then((value) {
        if(value.latitude != null && value.longitude != null)
        {
          handleLocationInitialized(Coordinate(value.latitude!, value.longitude!));
        }
      });
      Location().onLocationChanged.listen((value) {
        handleLocationUpdate(Coordinate(value.latitude!, value.longitude!));
      });
    }
    else
    {
      Geofence.getCurrentLocation().then((location) {
        if(location == null)
        {
          return;
        }
        handleLocationInitialized(location);
      });
      Geofence.backgroundLocationUpdated.stream.listen((location) {
        handleLocationUpdate(location);
      });
    }
    // BeaconHelper().readOrFetch();
    // BeaconHelper().startListening((data)
    //   {
    //     print('BeaconHelper got something! $data');
    //   }
    // );
  }

  void handleLocationInitialized(Coordinate location) {
    lastKnownLocation = location;
    print('handleLocationInitialized ${lastKnownLocation.latitude} - ${lastKnownLocation.longitude}');
    //NotificationHelper().send("Get location successfully", 'Location ${lastKnownLocation.latitude} - ${lastKnownLocation.longitude}');
    updateFences(location: lastKnownLocation);
  }

  void handleLocationUpdate(Coordinate location) {
    lastKnownLocation = location;
    //print('handleLocationUpdate ${lastKnownLocation.latitude} - ${lastKnownLocation.longitude}');
    //NotificationHelper().send("Background location updated", 'Location ${lastKnownLocation.latitude} - ${lastKnownLocation.longitude}');
    final shouldUpdate = GeofenceHelper().distance(lastKnownLocation, fencePivot) > GeofenceHelper.GEOFENCE_SCAN_RADIUS*0.8;
    if(shouldUpdate)
    {
      updateFences(location: lastKnownLocation);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print('didChangeAppLifecycleState $state');
    switch (state) {
      case AppLifecycleState.resumed:
        Location().changeSettings(
          accuracy: LocationAccuracy.high,
          interval: LOCATION_UPDATE_INTERVAL);
        break;
      case AppLifecycleState.paused:
        Location().changeSettings(
          accuracy: LocationAccuracy.balanced,
          interval: LOCATION_UPDATE_BG_INTERVAL);
        break;
      default:
    }
  }

  @override
  void dispose() {
    distanceCtrl.dispose();
    fenceCountCtrl.dispose();
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  void enterFence(String id)
  {

  }

  void updateFences({required Coordinate location, double radius = GeofenceHelper.GEOFENCE_SCAN_RADIUS})
  {
    final start = DateTime.now();
    print('updateFences');
    Geofence.removeAllGeolocations();
    final fences = GeofenceHelper().getNearByGeofences(location: location, radius: radius);
    fences.forEach((fence) {
      Geofence.addGeolocation(fence, GeolocationEvent.entry).then((onValue) {
        print("Your geofence has been added! ${fence.id}");
      }).catchError((error) {
          print("Geofence adding failed with $error");
      });
    });
    setState(() {
      fenceCircles = fences.map((fence) {
        return Circle(
          circleId: CircleId(fence.id),
          center: LatLng(fence.latitude, fence.longitude),
          radius: fence.radius,
          strokeWidth: 1,
          strokeColor: Colors.blueGrey,
          fillColor: Color(0x330077ff),
        );
      }).toSet();
    });
    print('updateFences costs ${DateTime.now().difference(start).inMilliseconds} ms');
    goTo(CameraPosition(
      target: LatLng(location.latitude, location.longitude),
      zoom: DEFAULT_ZOOM,
    ));
    fencePivot = location;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("Geofence Map"),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_location),
            onPressed: (){
              setState(() {
                showDebugControls = !showDebugControls;
              });
            },
          )
        ],
      ),
      body: AnimatedSwitcher(
      duration: Duration(milliseconds: 500),
        child: showDebugControls?
          buildDebugControls():
          buildGoogleMap(),
      ),
    );
  }

  Widget buildGoogleMap() {
    controller = new Completer<GoogleMapController>();
    return GoogleMap(
      initialCameraPosition: marugameOffice,
      onMapCreated: (GoogleMapController result) {
        controller.complete(result);
      },
      circles: fenceCircles,
      myLocationEnabled: true,
    );
  }

  Future<void> goTo(CameraPosition position) async {
    (await controller.future).animateCamera(CameraUpdate.newCameraPosition(position));
  }

  Widget buildDebugControls() {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 100),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
            child: Center(
              child: Text("Geofence Generator", style: TextStyle(fontSize: 30),),
            ),
          ),
          ListTile(
            leading: Icon(Icons.directions_walk),
            title: TextField(
              controller: distanceCtrl,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Filter Distance (default to ${GeofenceHelper.GEOFENCE_SCAN_RADIUS})'
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.location_pin),
            title:  TextField(
              controller: fenceCountCtrl,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Geofence Count (default to ${GeofenceHelper.FAKE_GEOFENCE_COUNT})'
              ),
            ),
          ),
          ElevatedButton(
            onPressed: generateNewGeofences,
            child: Text('Generate!!!'),
            ),
          Text('Now watching ${fenceCircles.length} geofences'),
        ],
      )
    );
  }

  void generateNewGeofences()
  {
    try{
      final count = int.parse(fenceCountCtrl.text);
      final distance = double.parse(distanceCtrl.text);
      assert(count is int);
      assert(distance is double);
      GeofenceHelper().generateFakeGeofence(count);
      Location().getLocation().then((value)
      {
        updateFences(location: Coordinate(value.latitude??DEFAULT_LAT, value.longitude??DEFAULT_LONG), radius: distance);
      });
    } on Exception catch (e) {
      print('error while generateNewGeofences ${e.toString()}');
    }
    setState(() {
      showDebugControls = false;
    });
  }
}
