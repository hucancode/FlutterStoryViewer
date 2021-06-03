import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pop_experiment/models/geofence.dart';
import 'package:pop_experiment/services/geofence_history.dart';
import 'package:provider/provider.dart';

class GeofenceDetail extends StatelessWidget {

  final Geofence model;

  GeofenceDetail({Key? key, required this.model})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GeofenceHistory>(context, listen: false);
    final isInHistory = provider.entries.contains(model.id);
    return Scaffold(
      appBar: AppBar(
        title: Text(model.title??"Untitled"),
      ),
      body: Container(
        color: Theme.of(context).canvasColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              width: double.infinity,
              height: 220,
              child: buildBanner(),
            ),
            Expanded(
              child: Center(
                child:Icon(
                  model.isSelected?Icons.home:
                  isInHistory?Icons.check_circle:
                  Icons.lock,
                  size: 50,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                model.isSelected?"You are here!!!!": 
                isInHistory? "You have been here!": 
                "You haven't been to this location yet!",
                style: TextStyle(fontSize: 30),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget buildBanner() {
    return CachedNetworkImage(
      imageUrl: "https://picsum.photos/seed/${model.title}/640/360",
      errorWidget: (context, url, error) => Icon(Icons.error),
      fit: BoxFit.cover,
    );
    //return Image.network(banner??"", fit: BoxFit.cover);
    //return Image.asset(banner??"", fit: BoxFit.cover);
  }
}
