import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LocationHitFilter
{
  DateTime hitDayMin;
  DateTime hitDayMax;
  TimeOfDay hitTimeMin;
  TimeOfDay hitTimeMax;
  int hitDurationMin;
  int hitDurationMax;
  String country;
  String area;
  String locality;
  String route;
  String street;
  String postalCode;
  LocationHitFilter({required this.hitDayMin, required this.hitDayMax, 
  required this.hitTimeMin, required this.hitTimeMax, 
  required this.hitDurationMin, required this.hitDurationMax, 
  required this.country, 
  required this.area, 
  required this.locality, 
  required this.route, 
  required this.street, 
  required this.postalCode, });
  factory LocationHitFilter.fromJson(Map<String, dynamic> json) {
    final dateFormatter = DateFormat.yMd();
    final timeFormatter = DateFormat.Hm();
    final ret = LocationHitFilter(
      hitDayMin: dateFormatter.parse(json["hitDayMin"]), 
      hitDayMax: dateFormatter.parse(json["hitDayMax"]), 
      hitTimeMin: TimeOfDay.fromDateTime(timeFormatter.parse(json["hitTimeMin"])), 
      hitTimeMax: TimeOfDay.fromDateTime(timeFormatter.parse(json["hitTimeMax"])), 
      hitDurationMin: json["hitDurationMin"], 
      hitDurationMax: json["hitDurationMax"], 
      country: json["country"],
      area: json["area"],
      locality: json["locality"],
      route: json["route"],
      street: json["street"],
      postalCode: json["postalCode"],
    );
    return ret;
  }

  Map<String, dynamic> toJson()
  {
    Map<String, dynamic> ret = {};
    final dateFormatter = DateFormat.yMd();
    ret["hitDayMin"] = dateFormatter.format(hitDayMin);
    ret["hitDayMax"] = dateFormatter.format(hitDayMax);
    ret["hitTimeMin"] = '${hitTimeMin.hour}:${hitTimeMin.minute}';
    ret["hitTimeMax"] = '${hitTimeMax.hour}:${hitTimeMax.minute}';
    ret["hitDurationMin"] = hitDurationMin.toString();
    ret["hitDurationMax"] = hitDurationMax.toString();
    ret["country"] = country;
    ret["area"] = area;
    ret["locality"] = locality;
    ret["route"] = route;
    ret["street"] = street;
    ret["street"] = street;
    ret["postalCode"] = postalCode;
    return ret;
  }
}