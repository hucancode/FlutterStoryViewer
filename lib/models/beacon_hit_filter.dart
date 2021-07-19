import 'package:flutter/material.dart';
import 'package:pop_experiment/models/hit_query_mode.dart';

class BeaconHitFilter
{
  int numDayToQuery;
  TimeOfDay hitTimeMin;
  TimeOfDay hitTimeMax;
  HitQueryMode queryMode;
  int queryMin;
  int queryMax;
  int beaconID;

  BeaconHitFilter({
    this.numDayToQuery = 1, 
    required this.hitTimeMin, 
    required this.hitTimeMax, 
    this.queryMode = HitQueryMode.averageDuration,
    this.queryMin = 0, 
    this.queryMax = 0, 
    this.beaconID = -1});

  factory BeaconHitFilter.empty()
  {
    return BeaconHitFilter(
      hitTimeMin: TimeOfDay(hour: 0, minute: 0), 
      hitTimeMax: TimeOfDay(hour: 23, minute: 59), 
    );
  }

  bool get isTwoDaySpan
  {
    if(hitTimeMin.hour > hitTimeMax.hour)
    {
      return true;
    }
    if(hitTimeMin.hour == hitTimeMax.hour && hitTimeMin.minute > hitTimeMax.minute)
    {
      return true;
    }
    return false;
  }
  
  factory BeaconHitFilter.fromJson(Map<String, dynamic> json) {
    final int hitTimeMin = json["hitTimeMin"];
    final int hitTimeMax = json["hitTimeMax"];
    final int queryMode = json["queryMode"];
    final int queryMin = json["queryMin"];
    final int queryMax = json["queryMax"];
    final int beaconID = json["beaconID"];
    final ret = BeaconHitFilter(
      numDayToQuery: json["numDayToQuery"], 
      hitTimeMin: TimeOfDay(hour: (hitTimeMin/60).floor(), minute: hitTimeMin%60), 
      hitTimeMax: TimeOfDay(hour: (hitTimeMax/60).floor(), minute: hitTimeMax%60), 
      queryMode: HitQueryMode.values[queryMode],
      queryMin: queryMin, 
      queryMax: queryMax, 
      beaconID: beaconID,
    );
    return ret;
  }

  Map<String, dynamic> toJson()
  {
    Map<String, dynamic> ret = {};
    ret["numDayToQuery"] = numDayToQuery;
    ret["hitTimeMin"] = '${hitTimeMin.hour*60+hitTimeMin.minute}';
    ret["hitTimeMax"] = '${hitTimeMax.hour*60+hitTimeMax.minute}';
    ret["queryMode"] = queryMode.index;
    ret["queryMin"] = queryMin;
    ret["queryMax"] = queryMax;
    ret["beaconID"] = beaconID;
    return ret;
  }
}