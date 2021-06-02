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

class Profile extends ChangeNotifier
{
  Gender _gender = Gender.male;
  Marital _marital = Marital.single;
  DateTime _birthDay = DateTime.now();
  int _workAddress = 0;
  int _homeAddress = 0;
  bool shouldNotify = true;

  void beginEdit()
  {
    shouldNotify = false;
  }
  void endEdit()
  {
    notifyListeners();
    shouldNotify = true;
  }

  set gender(Gender value)
  {
    _gender = value;
    if(shouldNotify) notifyListeners();
  }
  Gender get gender => _gender;

  set marital(Marital value)
  {
    _marital = value;
    if(shouldNotify) notifyListeners();
  }
  Marital get marital => _marital;

  set birthDay(DateTime value)
  {
    _birthDay = value;
    if(shouldNotify) notifyListeners();
  }
  DateTime get birthDay => _birthDay;

  set workAddress(int value)
  {
    _workAddress = value;
    if(shouldNotify) notifyListeners();
  }
  int get workAddress => _workAddress;

  set homeAddress(int value)
  {
    _homeAddress = value;
    if(shouldNotify) notifyListeners();
  }
  int get homeAddress => _homeAddress;


  int get age {
    final now = DateTime.now();
    final deltaY = now.year - _birthDay.year - 1;
    final passBirthday = now.month >= _birthDay.month && now.day >= _birthDay.day;
    return deltaY + (passBirthday?1:0);
  }
}