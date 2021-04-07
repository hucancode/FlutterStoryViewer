import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GeofenceMap extends StatefulWidget {
  GeofenceMapState createState() => GeofenceMapState();
}

class GeofenceMapState extends State<GeofenceMap> {
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition marugameOffice = CameraPosition(
    target: LatLng(34.41967010498047, 132.9036865234375),
    zoom: 14.4746,
  );

  static final CameraPosition takamatsuOffice = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(34.3467879, 134.0466558),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("Geofence Map"),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: marugameOffice,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: goToTakamatsu,
        label: Text('Go to Takamatsu!'),
        icon: Icon(Icons.directions_boat),
      ),
    );
  }

  Future<void> goToTakamatsu() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(takamatsuOffice));
  }
}
