import 'dart:core';
import 'package:flutter/material.dart';
import 'package:pop_experiment/models/beacon_hit_filter.dart';
import 'package:pop_experiment/models/geofence_hit_filter.dart';
import 'package:pop_experiment/models/location_hit_filter.dart';
import 'package:pop_experiment/models/profile.dart';

enum FilterMode
{
  ignore,
  include,
  exclude
}

class Filter
{
  int id;
  String? title;
  FilterMode genderMode = FilterMode.ignore;
  List<Gender> genders;
  FilterMode maritalMode = FilterMode.ignore;
  List<Marital> maritals;
  FilterMode workAddressMode = FilterMode.ignore;
  List<int> workAddresses;
  FilterMode homeAddressMode = FilterMode.ignore;
  List<int> homeAddresses;
  FilterMode ageMode = FilterMode.ignore;
  List<RangeValues> ages;
  FilterMode geofenceMode = FilterMode.ignore;
  List<GeofenceHitFilter> geofences;
  FilterMode beaconMode = FilterMode.ignore;
  List<BeaconHitFilter> beacons;
  FilterMode locationMode = FilterMode.ignore;
  List<LocationHitFilter> locations;
  int authorID;
  bool isSelected;
  bool isFullyLoaded;

  Filter({
    this.id = -1,
    this.title,
    this.genderMode = FilterMode.ignore,
    this.genders = const [],
    this.maritalMode = FilterMode.ignore,
    this.maritals = const [],
    this.workAddressMode = FilterMode.ignore,
    this.workAddresses = const [],
    this.homeAddressMode = FilterMode.ignore,
    this.homeAddresses = const [],
    this.ageMode = FilterMode.ignore,
    this.ages = const [],
    this.geofenceMode = FilterMode.ignore,
    this.geofences = const [],
    this.beaconMode = FilterMode.ignore,
    this.beacons = const [],
    this.locationMode = FilterMode.ignore,
    this.locations = const [],
    this.authorID = -1,
    this.isSelected = false,
    this.isFullyLoaded = false,
  });

  factory Filter.fromShortJson(Map<String, dynamic> json)
  {
    return Filter(
        id: json["id"],
        title: json["title"],
        authorID: 1,
    );
  }

  void reloadFromJson(Map<String, dynamic> json)
  {
    //print("Filter reloadFromJson, raw json = $json");
    genderMode = FilterMode.values[json["genderMode"]??0];
    maritalMode = FilterMode.values[json["maritalMode"]??0];
    ageMode = FilterMode.values[json["ageMode"]??0];
    workAddressMode = FilterMode.values[json["workAddressMode"]??0];
    homeAddressMode = FilterMode.values[json["homeAddressMode"]??0];
    geofenceMode = FilterMode.values[json["geofenceMode"]??0];
    beaconMode = FilterMode.values[json["beaconMode"]??0];
    locationMode = FilterMode.values[json["locationMode"]??0];
    genders = List<int>.from(json["genders"])
      .map((e) => e.clamp(0, Gender.values.length - 1))
      .map((e) => Gender.values[e]).toList();
    maritals = List<int>.from(json["maritals"])
      .map((e) => e.clamp(0, Marital.values.length - 1))
      .map((e) => Marital.values[e]).toList();
    workAddresses = List<int>.from(json["workAddresses"]);
    homeAddresses = List<int>.from(json["homeAddresses"]);
    ages = List<dynamic>.from(json["ages"]).map((range) {
      int min = range["min"]??0;
      int max = range["max"]??0;
      return RangeValues(min.toDouble(), max.toDouble());
    }).toList();
    geofences = List<dynamic>.from(json["geofences"]).map((e) => GeofenceHitFilter.fromJson(e)).toList();
    beacons = List<dynamic>.from(json["beacons"]).map((e) => BeaconHitFilter.fromJson(e)).toList();
    locations = List<dynamic>.from(json["locations"]).map((e) => LocationHitFilter.fromJson(e)).toList();
    authorID = json["authorID"];
    isFullyLoaded = json["isFullyLoaded"]??false;
  }

  factory Filter.fromJson(Map<String, dynamic> json)
  {
    //print("Filter.fromJson, raw json = $json");
    int id = json["id"];
    String title = json["title"];
    final genderMode = FilterMode.values[json["genderMode"]??0];
    final maritalMode = FilterMode.values[json["maritalMode"]??0];
    final ageMode = FilterMode.values[json["ageMode"]??0];
    final workAddressMode = FilterMode.values[json["workAddressMode"]??0];
    final homeAddressMode = FilterMode.values[json["homeAddressMode"]??0];
    final geofenceMode = FilterMode.values[json["geofenceMode"]??0];
    final beaconMode = FilterMode.values[json["beaconMode"]??0];
    final locationMode = FilterMode.values[json["locationMode"]??0];
    final genders = List<int>.from(json["genders"])
      .map((e) => e.clamp(0, Gender.values.length - 1))
      .map((e) => Gender.values[e]).toList();
    final maritals = List<int>.from(json["maritals"])
      .map((e) => e.clamp(0, Marital.values.length - 1))
      .map((e) => Marital.values[e]).toList();
    final workAddresses = List<int>.from(json["workAddresses"]);
    final homeAddresses = List<int>.from(json["homeAddresses"]);
    final ages = List<dynamic>.from(json["ages"]).map((range) {
      int min = range["min"]??0;
      int max = range["max"]??0;
      return RangeValues(min.toDouble(), max.toDouble());
    }).toList();
    final geofences = List<dynamic>.from(json["geofences"]).map((e) => GeofenceHitFilter.fromJson(e)).toList();
    final beacons = List<dynamic>.from(json["beacons"]).map((e) => BeaconHitFilter.fromJson(e)).toList();
    final locations = List<dynamic>.from(json["locations"]).map((e) => LocationHitFilter.fromJson(e)).toList();
    int authorID = json["authorID"];
    bool isFullyLoaded = json["isFullyLoaded"]??false;
    print('build filter with id = $id, title = $title, genderMode = $genderMode, maritalMode = $maritalMode, '
          'ageMode = $ageMode, workAddressMode = $workAddressMode, homeAddressMode = $homeAddressMode,'
          'genders = $genders, maritals = $maritals, workAddresses = $workAddresses, homeAddresses = $homeAddresses, ages = $ages');
    return Filter(
        id: id,
        title: title,
        genderMode: genderMode,
        genders: genders,
        maritalMode: maritalMode,
        maritals: maritals,
        workAddressMode: workAddressMode,
        workAddresses: workAddresses,
        homeAddressMode: homeAddressMode,
        homeAddresses: homeAddresses,
        ageMode: ageMode,
        ages: ages,
        geofenceMode: geofenceMode,
        geofences: geofences,
        beaconMode: beaconMode,
        beacons: beacons,
        locationMode: locationMode,
        locations: locations,
        authorID: authorID,
        isFullyLoaded: isFullyLoaded,
    );
  }
  
  Map<String, dynamic> toJson()
  {
    Map<String, dynamic> ret = {};
    ret["id"] = id;
    ret["title"] = title;
    ret["genderMode"] = genderMode.index;
    if(genderMode != FilterMode.ignore)
    {
      ret["genders"] = genders.map((e) => e.index).toList();
    }
    ret["maritalMode"] = maritalMode.index;
    if(maritalMode != FilterMode.ignore)
    {
      ret["maritals"] = maritals.map((e) => e.index).toList();
    }
    ret["ageMode"] = ageMode.index;
    if(ageMode != FilterMode.ignore)
    {
      ret["ages"] = ages.map((e) => {"min": e.start, "max": e.end}).toList();
    }
    ret["workAddressMode"] = workAddressMode.index;
    if(workAddressMode != FilterMode.ignore)
    {
      ret["workAddresses"] = workAddresses;
    }
    ret["homeAddressMode"] = homeAddressMode.index;
    if(homeAddressMode != FilterMode.ignore)
    {
      ret["homeAddresses"] = homeAddresses;
    }
    ret["geofenceMode"] = geofenceMode.index;
    if(geofenceMode != FilterMode.ignore)
    {
      ret["geofences"] = geofences.map((e) => e.toJson()).toList();
    }
    ret["beaconMode"] = beaconMode.index;
    if(beaconMode != FilterMode.ignore)
    {
      ret["beacons"] = beacons.map((e) => e.toJson()).toList();
    }
    ret["locationMode"] = locationMode.index;
    if(locationMode != FilterMode.ignore)
    {
      ret["locations"] = locations.map((e) => e.toJson()).toList();
    }
    ret["authorID"] = authorID;
    ret["isFullyLoaded"] = isFullyLoaded;
    return ret;
  }
}