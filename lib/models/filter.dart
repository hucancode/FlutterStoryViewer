import 'dart:core';
import 'package:flutter/material.dart';

enum Gender {
  male,
  female
}

enum Marital {
  single, 
  married,
  divorced
}

class Filter
{
  int id;
  String? title;
  int genderMode;
  List<Gender> genders;
  int maritalMode;
  List<Marital> maritals;
  int workAddressMode;
  List<int> workAddresses;
  int homeAddressMode;
  List<int> homeAddresses;
  int ageMode;
  List<RangeValues> ages;
  int authorID;
  bool isSelected;

  Filter({
    required this.id,
    this.title,
    required this.genderMode,
    required this.genders,
    required this.maritalMode,
    required this.maritals,
    required this.workAddressMode,
    required this.workAddresses,
    required this.homeAddressMode,
    required this.homeAddresses,
    required this.ageMode,
    required this.ages,
    required this.authorID,
    this.isSelected = false
  });

  factory Filter.fromShortJson(Map<String, dynamic> json)
  {
    return Filter(
        id: json["id"],
        title: json["title"],
        genderMode: 0,
        maritalMode: 0,
        workAddressMode: 0,
        homeAddressMode: 0,
        ageMode: 0, 
        authorID: 1,
        genders: [],
        maritals: [], 
        ages: [], 
        homeAddresses: [], 
        workAddresses: [],
    );
  }

  factory Filter.empty()
  {
    return Filter(
        id: -1,
        genderMode: 0,
        maritalMode: 0,
        workAddressMode: 0,
        homeAddressMode: 0,
        ageMode: 0,
        genders: [],
        maritals: [], 
        ages: [], 
        homeAddresses: [], 
        workAddresses: [],
        authorID: -1,
    );
  }
  factory Filter.fromJson(Map<String, dynamic> json)
  {
    print("build Filter from json, raw json = $json");
    int id = json["id"];
    String title = json["title"];
    int genderMode = json["genderMode"];
    int maritalMode = json["maritalMode"];
    int ageMode = json["ageMode"];
    int workAddressMode = json["workAddressMode"];
    int homeAddressMode = json["homeAddressMode"];
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
    ret["genderMode"] = genderMode;
    if(genderMode != 0)
    {
      ret["genders"] = genders.map((e) => e.index).toList();
    }
    ret["maritalMode"] = maritalMode;
    if(maritalMode != 0)
    {
      ret["maritals"] = maritals.map((e) => e.index).toList();
    }
    ret["ageMode"] = ageMode;
    if(ageMode != 0)
    {
      ret["ages"] = ages.map((e) => {"min": e.start, "max": e.end}).toList();
    }
    ret["workAddressMode"] = workAddressMode;
    if(workAddressMode != 0)
    {
      ret["workAddresses"] = workAddresses;
    }
    ret["homeAddressMode"] = homeAddressMode;
    if(homeAddressMode != 0)
    {
      ret["homeAddresses"] = homeAddresses;
    }
    ret["authorID"] = authorID;
    return ret;
  }
}