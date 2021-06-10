import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_geofence/geofence.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pop_experiment/models/geofence.dart' as AppGeofence;
import 'package:pop_experiment/services/geofence_history.dart';
import 'package:pop_experiment/services/geofence_service.dart';
import 'package:pop_experiment/services/notification_service.dart';
import 'package:provider/provider.dart';

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
  var lastKnownLocation = Coordinate(DEFAULT_LAT, DEFAULT_LONG);//TODO: save this value to file
  var fencePivot = Coordinate(DEFAULT_LAT, DEFAULT_LONG);
  Completer<GoogleMapController> controller = Completer();
  var fenceCircles = Set<Circle>.identity();
  var fences = List<AppGeofence.Geofence>.empty();
  late GeofenceHistory history;
  late GeofenceService service;

  var shouldSendNotification = false;
  
  static final CameraPosition marugameOffice = CameraPosition(
    target: LatLng(34.2237964, 133.8622095),
    zoom: DEFAULT_ZOOM,
  );

  @override
  void initState()
  {
    super.initState();
    print("Geofence.initialize()");
    Geofence.initialize();
    Geofence.requestPermissions();
    WidgetsBinding.instance!.addObserver(this);
    history = Provider.of<GeofenceHistory>(context, listen: false);
    service = Provider.of<GeofenceService>(context, listen: false);
    print("Geofence.startListening()");
    Geofence.startListening(GeolocationEvent.entry, (location)
    {
      print("Entry of a georegion ${location.id}");
      if(shouldSendNotification)
      {
        NotificationService().send("Entry of a georegion", "Welcome to: ${location.id}");
      }
      fences.firstWhere((e) => e.id.toString() == location.id, orElse: () => AppGeofence.Geofence()).isSelected = true;
      redrawFences();
      history.add(int.tryParse(location.id)??-1);
    });
    Geofence.startListening(GeolocationEvent.exit, (location)
    {
      print("Exit of a georegion ${location.id}");
      if(shouldSendNotification)
      {
        NotificationService().send("Entry of a georegion", "Welcome to: ${location.id}");
      }
      fences.firstWhere((e) => e.id.toString() == location.id, orElse: () => AppGeofence.Geofence()).isSelected = false;
      redrawFences();
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
    final shouldUpdate = service.distance(lastKnownLocation, fencePivot) > GeofenceService.GEOFENCE_SCAN_RADIUS*0.8;
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
        shouldSendNotification = false;
        break;
      case AppLifecycleState.paused:
        Location().changeSettings(
          accuracy: LocationAccuracy.balanced,
          interval: LOCATION_UPDATE_BG_INTERVAL);
        shouldSendNotification = true;
        break;
      default:
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  void enterFence(String id)
  {

  }

  void updateFences({required Coordinate location, double radius = GeofenceService.GEOFENCE_SCAN_RADIUS})
  {
    print('updateFences');
    Geofence.removeAllGeolocations();
    fences = service.getNearByGeofences(location: location, radius: radius);
    fences.forEach((fence) {
      final geolocation = Geolocation(latitude: fence.latitude, longitude: fence.longitude, radius: fence.radius, id: fence.id.toString());
      Geofence.addGeolocation(geolocation, GeolocationEvent.entry);
    });
    redrawFences();
    goTo(CameraPosition(
      target: LatLng(location.latitude, location.longitude),
      zoom: DEFAULT_ZOOM,
    ));
    fencePivot = location;
  }

  void redrawFences() {
    setState(() {
      fenceCircles = fences.map((fence) {
        final isInHistory = history.entries.contains(fence);
        final color = fence.isSelected?Colors.yellow.withAlpha(100):
          isInHistory?Colors.blueGrey.withAlpha(60):
          Colors.blueGrey.withAlpha(30);
        return Circle(
          circleId: CircleId(fence.id.toString()),
          center: LatLng(fence.latitude, fence.longitude),
          radius: fence.radius,
          strokeWidth: 1,
          strokeColor: Colors.blueGrey,
          fillColor: color,
        );
      }).toSet();
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("Geofence Map"),
      ),
      body: buildGoogleMap(),
    );
  }

  void openGeofenceDetail(Geofence model)
  {
    Navigator.pushNamed(context, '/detail', arguments: model);
  }

  Widget buildGoogleMap() {
    controller = new Completer<GoogleMapController>();
    return GoogleMap(
      initialCameraPosition: marugameOffice,
      onMapCreated: (GoogleMapController result) {
        controller.complete(result);
      },
      circles: fenceCircles,
      //onLongPress: (location)
      onTap: (location)
      {
        final model = fences.firstWhere((fence) {
          final a = Coordinate(location.latitude, location.longitude);
          final b = Coordinate(fence.latitude, fence.longitude);
          return service.distance(a, b) < fence.radius;
        }, orElse: () => AppGeofence.Geofence());
        if(model.id != -1)
        {
          Navigator.pushNamed(context, '/detail', arguments: model);
        }
      },
      myLocationEnabled: true,
    );
  }

  Future<void> goTo(CameraPosition position) async {
    (await controller.future).animateCamera(CameraUpdate.newCameraPosition(position));
  }
}
