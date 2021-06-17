import 'package:flutter/material.dart';

class LocationHitFilter
{
  DateTime hitDayMin;
  DateTime hitDayMax;
  TimeOfDay hitTimeMin;
  TimeOfDay hitTimeMax;
  int hitDurationMin;
  int hitDurationMax;
  String country;
  String areaLevel1;
  String areaLevel2;
  String locality;
  String route;
  String street;
  String postalCode;
  String fullLocation;
  LocationHitFilter({required this.hitDayMin, required this.hitDayMax, 
  required this.hitTimeMin, required this.hitTimeMax, 
  required this.hitDurationMin, required this.hitDurationMax, 
  required this.country, 
  required this.areaLevel1, 
  required this.areaLevel2, 
  required this.locality, 
  required this.route, 
  required this.street, 
  required this.postalCode, 
  required this.fullLocation, });
  factory LocationHitFilter.fromJson(Map<String, dynamic> json) {
    final ret = LocationHitFilter(
      hitDayMin: json["hitDayMin"], 
      hitDayMax: json["hitDayMax"], 
      hitTimeMin: json["hitTimeMin"], 
      hitTimeMax: json["hitTimeMax"], 
      hitDurationMin: json["hitDurationMin"], 
      hitDurationMax: json["hitDurationMax"], 
      country: json["country"],
      areaLevel1: json["areaLevel1"],
      areaLevel2: json["areaLevel2"],
      locality: json["locality"],
      route: json["route"],
      street: json["street"],
      postalCode: json["postalCode"],
      fullLocation: json["fullLocation"],
    );
    return ret;
  }

  Map<String, dynamic> toJson()
  {
    Map<String, dynamic> ret = {};
    ret["hitDayMin"] = hitDayMin.toString();
    ret["hitDayMax"] = hitDayMax.toString();
    ret["hitTimeMin"] = hitTimeMin.toString();
    ret["hitTimeMax"] = hitTimeMax.toString();
    ret["hitDurationMin"] = hitDurationMin.toString();
    ret["hitDurationMax"] = hitDurationMax.toString();
    ret["country"] = country;
    ret["areaLevel1"] = areaLevel1;
    ret["areaLevel2"] = areaLevel2;
    ret["locality"] = locality;
    ret["route"] = route;
    ret["street"] = street;
    ret["street"] = street;
    ret["postalCode"] = postalCode;
    ret["fullLocation"] = fullLocation;
    return ret;
  }
}