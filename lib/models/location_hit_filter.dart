import 'package:flutter/material.dart';
import 'package:pop_experiment/models/hit_query_mode.dart';

class LocationHitFilter
{
  int numDayToQuery;
  TimeOfDay hitTimeMin;
  TimeOfDay hitTimeMax;
  HitQueryMode queryMode;
  int queryMin;
  int queryMax;
  String country;
  String area;
  String locality;
  String route;
  String street;
  String postalCode;
  LocationHitFilter({
    this.numDayToQuery = 1, 
    required this.hitTimeMin, 
    required this.hitTimeMax, 
    this.queryMode = HitQueryMode.averageDuration,
    this.queryMin = 0, 
    this.queryMax = 0, 
    this.country = "", 
    this.area = "", 
    this.locality = "", 
    this.route = "", 
    this.street = "", 
    this.postalCode = "", });

  factory LocationHitFilter.empty()
  {
    return LocationHitFilter(
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

  factory LocationHitFilter.fromJson(Map<String, dynamic> json) {
    //print('LocationHitFilter.fromJson, raw json = $json');
    final numDayToQuery = json["numDayToQuery"];
    final int hitTimeMin = json["hitTimeMin"];
    final int hitTimeMax = json["hitTimeMax"];
    final int queryMode = json["queryMode"];
    final int queryMin = json["queryMin"];
    final int queryMax = json["queryMax"];
    final country = json["country"];
    final area = json["area"];
    final locality = json["locality"];
    final route = json["route"];
    final street = json["street"];
    final postalCode = json["postalCode"];
    final ret = LocationHitFilter(
      numDayToQuery: numDayToQuery, 
      hitTimeMin: TimeOfDay(hour: (hitTimeMin/60).floor(), minute: hitTimeMin%60), 
      hitTimeMax: TimeOfDay(hour: (hitTimeMax/60).floor(), minute: hitTimeMax%60), 
      queryMode: HitQueryMode.values[queryMode],
      queryMin: queryMin, 
      queryMax: queryMax, 
      country: country,
      area: area,
      locality: locality,
      route: route,
      street: street,
      postalCode: postalCode,
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