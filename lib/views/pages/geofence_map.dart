import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_geofence/geofence.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pop_experiment/services/geofence_manager.dart';

class GeofenceMap extends StatefulWidget {
  GeofenceMapState createState() => GeofenceMapState();
}

class GeofenceMapState extends State<GeofenceMap> with SingleTickerProviderStateMixin {
  static const DEFAULT_ZOOM = 14.4746;
  Coordinate? lastKnownLocation;
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
    Geofence.backgroundLocationUpdated.stream.listen((location) {
      print('backgroundLocationUpdated ${location.latitude} - ${location.longitude}');
      lastKnownLocation = location;
      updateFences(location: location);
    });
    Geofence.getCurrentLocation().then((location) {
      if(location != null)
      {
        lastKnownLocation = location;
        print('getCurrentLocation ${location.latitude} - ${location.longitude}');
        updateFences(location: location);
      }
    });
  }

  @override
  void dispose() {
    distanceCtrl.dispose();
    fenceCountCtrl.dispose();
    super.dispose();
  }

  void updateFences({required Coordinate location, double radius = GeofenceManager.GEOFENCE_SCAN_RADIUS})
  {
    final start = DateTime.now();
    setState(() {
      fenceCircles = GeofenceManager().getNearByGeofences(location: location, radius: radius).map((fence) {
        final width = radius>500?2:1;
        return Circle(
          circleId: CircleId(fence.id),
          center: LatLng(fence.latitude, fence.longitude),
          radius: fence.radius,
          strokeWidth: width,
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
              hintText: 'Filter Distance (default to ${GeofenceManager.GEOFENCE_SCAN_RADIUS})'
            ),
          ),),
          
          ListTile(
            leading: Icon(Icons.location_pin),
            title:  TextField(
            controller: fenceCountCtrl,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Geofence Count (default to ${GeofenceManager.FAKE_GEOFENCE_COUNT})'
            ),
          ),),
          ElevatedButton(
            onPressed: generateNewGeofences,
            child: Text('Generate!!!'),
            )
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
      GeofenceManager().generateFakeGeofence(count);
      if(lastKnownLocation != null)
      {
        updateFences(location: lastKnownLocation!, radius: distance);
      }
    } on Exception catch (e) {
      print('error while generateNewGeofences ${e.toString()}');
    }
    setState(() {
      showDebugControls = false;
    });
  }
}
