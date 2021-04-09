import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_geofence/geofence.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pop_experiment/services/geofence_helper.dart';
import 'package:pop_experiment/services/notification_helper.dart';

class GeofenceMap extends StatefulWidget {
  GeofenceMapState createState() => GeofenceMapState();
}

class GeofenceMapState extends State<GeofenceMap> with SingleTickerProviderStateMixin {
  static const DEFAULT_ZOOM = 14.4746;
  static const DEFAULT_LAT = 34.2237964;
  static const DEFAULT_LONG = 133.8622095;
  static const LOCATION_UPDATE_INTERVAL = 5000;
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
    Location().getLocation().then((value) {
      if(value.latitude != null && value.longitude != null)
      {
        lastKnownLocation = Coordinate(value.latitude!, value.longitude!);
        print('getLocation ${lastKnownLocation.latitude} - ${lastKnownLocation.longitude}');
        //NotificationHelper().scheduleNotification("Get location successfully", 'Location ${lastKnownLocation.latitude} - ${lastKnownLocation.longitude}');
        updateFences(location: lastKnownLocation);
      }
    });
    Location().changeSettings(interval: LOCATION_UPDATE_INTERVAL);
    Location().onLocationChanged.listen((value) {
      lastKnownLocation = Coordinate(value.latitude!, value.longitude!);
      print('onLocationChanged ${lastKnownLocation.latitude} - ${lastKnownLocation.longitude}');
      //NotificationHelper().scheduleNotification("Background location updated", 'Location ${lastKnownLocation.latitude} - ${lastKnownLocation.longitude}');
      final shouldUpdate = GeofenceHelper().distance(lastKnownLocation, fencePivot) > GeofenceHelper.GEOFENCE_SCAN_RADIUS*0.8;
      if(shouldUpdate)
      {
        updateFences(location: lastKnownLocation);
      }
    });
    Geofence.startListening(GeolocationEvent.entry, (location)
    {
      NotificationHelper().scheduleNotification("Entry of a georegion", "Welcome to: ${location.id}");
    });
  }

  @override
  void dispose() {
    distanceCtrl.dispose();
    fenceCountCtrl.dispose();
    super.dispose();
  }

  void enterFence(String id)
  {

  }

  void updateFences({required Coordinate location, double radius = GeofenceHelper.GEOFENCE_SCAN_RADIUS})
  {
    final start = DateTime.now();
    Geofence.removeAllGeolocations();
    final fences = GeofenceHelper().getNearByGeofences(location: location, radius: radius);
    fences.forEach((fence) {
      Geofence.addGeolocation(fence, GeolocationEvent.entry).then((onValue) {
        //print("Your geofence has been added! ${fence.id}");
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
        actions: <Widget>[
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
      mapType: MapType.normal,
      initialCameraPosition: marugameOffice,
      onMapCreated: (GoogleMapController result) {
        controller.complete(result);
      },
      circles: fenceCircles,
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
