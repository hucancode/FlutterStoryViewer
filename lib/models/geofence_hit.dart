import 'package:flutter/material.dart';

class GeofenceHit
{
  DateTime hitDay = DateTime.now();
  TimeOfDay hitTime = TimeOfDay.now();
  TimeOfDay lastSeen = TimeOfDay.now();
  int geofenceID;
  GeofenceHit({required this.geofenceID});
  factory GeofenceHit.fromJson(Map<String, dynamic> json) {
    final ret = GeofenceHit(
      geofenceID: json["geofenceID"],
    );
    ret.hitDay = json["hitDay"];
    ret.hitDay = json["hitTime"];
    ret.hitDay = json["lastSeen"];
    return ret;
  }

  Map<String, dynamic> toJson()
  {
    Map<String, dynamic> ret = {};
    ret["hitDay"] = hitDay.toString();
    ret["hitTime"] = hitTime.toString();
    ret["lastSeen"] = lastSeen.toString();
    ret["geofenceID"] = geofenceID;
    return ret;
  }
}