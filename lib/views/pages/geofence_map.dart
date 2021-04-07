import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_geofence/geofence.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pop_experiment/services/geofence_manager.dart';

class GeofenceMap extends StatefulWidget {
  GeofenceMapState createState() => GeofenceMapState();
}

class GeofenceMapState extends State<GeofenceMap> {
  Completer<GoogleMapController> controller = Completer();
  Set<Circle> fenceCircles = Set<Circle>.identity();

  static final CameraPosition marugameOffice = CameraPosition(
    target: LatLng(34.2237964, 133.8622095),
    zoom: 14.4746,
  );

  static final CameraPosition takamatsuOffice = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(34.3467879, 134.0466558),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  void initState()
  {
    super.initState();
    Geofence.backgroundLocationUpdated.stream.listen((location) {
      print('backgroundLocationUpdated ${location.latitude} - ${location.longitude}');
      updateFences(location);
    });
    Geofence.getCurrentLocation().then((location) {
      if(location != null)
      {
        print('getCurrentLocation ${location.latitude} - ${location.longitude}');
        updateFences(location);
      }
    });
  }

  void updateFences(Coordinate location)
  {
    fenceCircles = GeofenceManager().getNearByGeofences(location).map((fence) {
        return Circle(
          circleId: CircleId(fence.id),
          center: LatLng(fence.latitude, fence.longitude),
          radius: fence.radius,
          strokeWidth: 2,
          strokeColor: Colors.blueGrey,
          fillColor: Color(0x330077ff),
        );
      }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("Geofence Map"),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: marugameOffice,
        onMapCreated: (GoogleMapController result) {
          controller.complete(result);
        },
        circles: fenceCircles,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: goToTakamatsu,
        label: Text('Go to Takamatsu!'),
        icon: Icon(Icons.directions_boat),
      ),
    );
  }

  Future<void> goToTakamatsu() async {
    (await controller.future).animateCamera(CameraUpdate.newCameraPosition(takamatsuOffice));
  }
}
