import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GeofenceHitFilter
{
  DateTime hitDayMin;
  DateTime hitDayMax;
  TimeOfDay hitTimeMin;
  TimeOfDay hitTimeMax;
  int hitDurationMin;
  int hitDurationMax;
  int geofenceID;
  GeofenceHitFilter({required this.hitDayMin, required this.hitDayMax, 
  required this.hitTimeMin, required this.hitTimeMax, 
  required this.hitDurationMin, required this.hitDurationMax, required this.geofenceID});
  factory GeofenceHitFilter.fromJson(Map<String, dynamic> json) {
    final dateFormatter = DateFormat.yMd();
    final timeFormatter = DateFormat.Hm();
    final ret = GeofenceHitFilter(
      hitDayMin: dateFormatter.parse(json["hitDayMin"]), 
      hitDayMax: dateFormatter.parse(json["hitDayMax"]), 
      hitTimeMin: TimeOfDay.fromDateTime(timeFormatter.parse(json["hitTimeMin"])), 
      hitTimeMax: TimeOfDay.fromDateTime(timeFormatter.parse(json["hitTimeMax"])), 
      hitDurationMin: json["hitDurationMin"], 
      hitDurationMax: json["hitDurationMax"], 
      geofenceID: json["geofenceID"],
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
    ret["geofenceID"] = geofenceID;
    return ret;
  }
}