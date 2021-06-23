import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:pop_experiment/models/location_hit.dart';
import 'package:pop_experiment/services/location_history.dart';
import 'package:provider/provider.dart';

class LocationHistoryPage extends StatefulWidget {
  LocationHistoryPage({Key? key}) : super(key: key);
  @override
  LocationHistoryState createState() => LocationHistoryState();
}
class LocationHistoryState extends State<LocationHistoryPage> {
  static const LOCATION_UPDATE_INTERVAL = 2000; // Only affects android
  LocationHistory? provider;
  @override
  void initState()
  {
    super.initState();
    provider = Provider.of<LocationHistory>(context, listen: false);
    Location().changeSettings(
        accuracy: LocationAccuracy.high,
        interval: LOCATION_UPDATE_INTERVAL);
      Location().getLocation().then((value) {
        if(value.latitude != null && value.longitude != null)
        {
          provider?.updateLocation(value.latitude!, value.longitude!);
        }
      });
      Location().onLocationChanged.listen((value) {
        provider?.updateLocation(value.latitude!, value.longitude!);
      });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: buildBody(context),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: Text("Location History"),
    );
  }

  Widget buildBody(BuildContext context) {
    final provider = Provider.of<LocationHistory>(context);
    return ListView(
      children: provider.entries.reversed.map((e) => buildItem(context, e)).toList(),
    );
  }
  Widget buildItem(BuildContext context, LocationHit location) {
    return ListTile(
      title: Text('${location.area} - ${location.locality} - ${location.route} - ${location.street}'),
      subtitle: Text('(Been here during: ${location.hitDay.hour}h${location.hitDay.minute} ~ ${location.leaveDay.hour}h${location.leaveDay.minute})'),
    );
  }
}