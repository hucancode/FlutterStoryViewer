import 'package:flutter/material.dart';

class BeaconHit
{
  DateTime hitDay = DateTime.now();
  TimeOfDay hitTime = TimeOfDay.now();
  TimeOfDay lastSeen = TimeOfDay.now();
  int beaconID;
  BeaconHit({required this.beaconID});
  factory BeaconHit.fromJson(Map<String, dynamic> json) {
    final ret = BeaconHit(
      beaconID: json["beaconID"],
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
    ret["beaconID"] = beaconID;
    return ret;
  }
}