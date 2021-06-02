import 'dart:core';
import 'package:flutter/material.dart';
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
  int authorID;
  bool isSelected;

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
    this.authorID = -1,
    this.isSelected = false
  });

  factory Filter.fromShortJson(Map<String, dynamic> json)
  {
    return Filter(
        id: json["id"],
        title: json["title"],
        authorID: 1,
    );
  }

  factory Filter.fromJson(Map<String, dynamic> json)
  {
    print("build Filter from json, raw json = $json");
    int id = json["id"];
    String title = json["title"];
    FilterMode genderMode = FilterMode.values[json["genderMode"]??0];
    FilterMode maritalMode = FilterMode.values[json["maritalMode"]??0];
    FilterMode ageMode = FilterMode.values[json["ageMode"]??0];
    FilterMode workAddressMode = FilterMode.values[json["workAddressMode"]??0];
    FilterMode homeAddressMode = FilterMode.values[json["homeAddressMode"]??0];
    List<int> genders = List<int>.from(json["genders"]);
    List<int> maritals = List<int>.from(json["maritals"]);
    List<int> workAddresses = List<int>.from(json["workAddresses"]);
    List<int> homeAddresses = List<int>.from(json["homeAddresses"]);
    List<dynamic> ages = List<dynamic>.from(json["ages"]);
    int authorID = json["authorID"];
    print('build filter with id = $id, title = $title, genderMode = $genderMode, maritalMode = $maritalMode, '
          'ageMode = $ageMode, workAddressMode = $workAddressMode, homeAddressMode = $homeAddressMode,'
          'genders = $genders, maritals = $maritals, workAddresses = $workAddresses, homeAddresses = $homeAddresses, ages = $ages');
    return Filter(
        id: id,
        title: title,
        genderMode: genderMode,
        genders: genders
          .map((e) => e.clamp(0, Gender.values.length - 1))
          .map((e) => Gender.values[e]).toList(),
        maritalMode: maritalMode,
        maritals: maritals
          .map((e) => e.clamp(0, Marital.values.length - 1))
          .map((e) => Marital.values[e]).toList(),
        workAddressMode: workAddressMode,
        workAddresses: workAddresses,
        homeAddressMode: homeAddressMode,
        homeAddresses: homeAddresses,
        ageMode: ageMode,
        ages: ages.map((range) {
          int min = range["min"]??0;
          int max = range["max"]??0;
          return RangeValues(min.toDouble(), max.toDouble());
        }).toList(),
        authorID: authorID,
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
    ret["authorID"] = authorID;
    return ret;
  }
}