import 'package:flutter/material.dart';

class LocationHit
{
  DateTime hitDay = DateTime.now();
  TimeOfDay hitTime = TimeOfDay.now();
  TimeOfDay lastSeen = TimeOfDay.now();
  double latitude;
  double longitude;
  String country = "";
  String areaLevel1 = "";
  String areaLevel2 = "";
  String locality = "";
  String route = "";
  String street = "";
  String postalCode = "";

  LocationHit({required this.latitude, required this.longitude});
  factory LocationHit.fromJson(Map<String, dynamic> json) {
    final ret = LocationHit(
      latitude: json["latitude"],
      longitude: json["longitude"],
    );
    ret.hitDay = json["hitDay"];
    ret.hitTime = json["hitTime"];
    ret.lastSeen = json["lastSeen"];
    ret.country = json["country"];
    ret.areaLevel1 = json["areaLevel1"];
    ret.areaLevel2 = json["areaLevel2"];
    ret.locality = json["locality"];
    ret.route = json["route"];
    ret.street = json["street"];
    ret.postalCode = json["postalCode"];
    return ret;
  }

  Map<String, dynamic> toJson()
  {
    Map<String, dynamic> ret = {};
    ret["hitDay"] = hitDay.toString();
    ret["hitTime"] = hitTime.toString();
    ret["lastSeen"] = lastSeen.toString();
    ret["latitude"] = latitude;
    ret["longitude"] = longitude;
    ret["country"] = country;
    ret["areaLevel1"] = areaLevel1;
    ret["areaLevel2"] = areaLevel2;
    ret["locality"] = locality;
    ret["route"] = route;
    ret["street"] = street;
    ret["postalCode"] = postalCode;
    return ret;
  }
}