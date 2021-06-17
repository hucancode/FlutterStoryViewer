import 'package:flutter/material.dart';

class BeaconHitFilter
{
  DateTime hitDayMin;
  DateTime hitDayMax;
  TimeOfDay hitTimeMin;
  TimeOfDay hitTimeMax;
  int hitDurationMin;
  int hitDurationMax;
  int beaconID;
  BeaconHitFilter({required this.hitDayMin, required this.hitDayMax, 
  required this.hitTimeMin, required this.hitTimeMax, 
  required this.hitDurationMin, required this.hitDurationMax, required this.beaconID});
  factory BeaconHitFilter.fromJson(Map<String, dynamic> json) {
    final ret = BeaconHitFilter(
      hitDayMin: json["hitDayMin"], 
      hitDayMax: json["hitDayMax"], 
      hitTimeMin: json["hitTimeMin"], 
      hitTimeMax: json["hitTimeMax"], 
      hitDurationMin: json["hitDurationMin"], 
      hitDurationMax: json["hitDurationMax"], 
      beaconID: json["beaconID"],
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
    ret["beaconID"] = beaconID;
    return ret;
  }
}