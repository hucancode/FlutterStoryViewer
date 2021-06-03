import 'package:flutter/material.dart';
import 'package:pop_experiment/models/filter.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  static const int SAVE_VERSION = 1;
  static const SAVE_VERSION_KEY = 'save_version';
  static const GENDER_KEY = 'gender';
  static const MARITAL_KEY = 'marital';
  static const BIRTHDAY_KEY = 'birthday';
  static const WORK_ADDRESS_KEY = 'work_address';
  static const HOME_ADDRESS_KEY = 'home_address';

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

  void performUpgrade(int oldVersion, int newVersion)
  {

  }

  static Future<Profile> hotLoad() async
  {
    final ret = Profile();
    await ret.load();
    return ret;
  }

  Future<void> load() async
  {
    final prefs = await SharedPreferences.getInstance();
    int version = prefs.getInt(SAVE_VERSION_KEY) ?? SAVE_VERSION;
    print('loading user prefs version = $version');
    
    if(version < SAVE_VERSION)
    {
      performUpgrade(version, SAVE_VERSION);
    }
    else
    {
      beginEdit();
      gender = Gender.values[prefs.getInt(GENDER_KEY) ?? 0];
      marital = Marital.values[prefs.getInt(MARITAL_KEY) ?? 0];
      birthDay = DateTime.tryParse(prefs.getString(BIRTHDAY_KEY) ?? "")??DateTime.now();
      workAddress = prefs.getInt(WORK_ADDRESS_KEY) ?? 0;
      homeAddress = prefs.getInt(HOME_ADDRESS_KEY) ?? 0;
      endEdit();
    }
    print('loaded user prefs '
      'gender = $gender, '
      'marital = $marital, '
      'birthDay = $birthDay, '
      'workAddress = $workAddress, '
      'homeAddress = $homeAddress, ');
    // NotificationHelper().send("loaded user prefs", 
    //   'gender = $gender, '
    //   'marital = $marital, '
    //   'birthDay = $birthDay, '
    //   'workAddress = $workAddress, '
    //   'homeAddress = $homeAddress, ');
  }

  Future<void> save() async
  {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(SAVE_VERSION_KEY, SAVE_VERSION);
    await prefs.setInt(GENDER_KEY, gender.index);
    await prefs.setInt(MARITAL_KEY, marital.index);
    await prefs.setString(BIRTHDAY_KEY, birthDay.toString());
    await prefs.setInt(WORK_ADDRESS_KEY, workAddress);
    await prefs.setInt(HOME_ADDRESS_KEY, homeAddress);
    print("Profile was saved!!!!");
  }

  int applyFilter(Filter filter)
  {
    var matched = false;
    var failed = false;
    filter.genders.forEach((e) => matched |= e == gender);
    failed = (!matched && filter.genderMode == FilterMode.include) || 
      (matched && filter.genderMode == FilterMode.exclude);
    if(failed)
    {
      print('apply filter ${filter.title}, return false because gender was not satified');
      return 1;
    }
    filter.maritals.forEach((e) => matched |= e == marital);
    failed = (!matched && filter.maritalMode == FilterMode.include) || 
      (matched && filter.maritalMode == FilterMode.exclude);
    if(failed)
    {
      print('apply filter ${filter.title}, return false because marital was not satified');
      return 2;
    }
    filter.ages.forEach((e) => matched |= age >= e.start && age <= e.end);
    failed = (!matched && filter.ageMode == FilterMode.include) || 
      (matched && filter.ageMode == FilterMode.exclude);
    if(failed)
    {
      print('apply filter ${filter.title}, return false because age was not satified');
      return 3;
    }
    filter.workAddresses.forEach((e) => matched |= e == workAddress);
    failed = (!matched && filter.workAddressMode == FilterMode.include) || 
      (matched && filter.workAddressMode == FilterMode.exclude);
    if(failed)
    {
      print('apply filter ${filter.title}, return false because work address was not satified');
      return 4;
    }
    filter.homeAddresses.forEach((e) => matched |= e == homeAddress);
    failed = (!matched && filter.homeAddressMode == FilterMode.include) || 
      (matched && filter.homeAddressMode == FilterMode.exclude);
    if(failed)
    {
      print('apply filter ${filter.title}, return false because home address was not satified');
      return 5;
    }
    print('apply filter ${filter.title}, return true');
    return 0;
  }
}