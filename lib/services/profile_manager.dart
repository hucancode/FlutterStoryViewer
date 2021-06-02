import 'package:pop_experiment/models/filter.dart';
import 'package:pop_experiment/models/profile.dart';
import 'package:pop_experiment/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

const int SAVE_VERSION = 1;

class ProfileManager {
  static final ProfileManager _instance = ProfileManager._privateConstructor();
  ProfileManager._privateConstructor();

  factory ProfileManager() {
    return _instance;
  }

  bool busy = false;

  void performUpgrade(int oldVersion, int newVersion)
  {

  }

  Future<void> loadTo(Profile model) async
  {
    if(busy)
    {
      await Future.delayed(Duration(milliseconds: 100));
      return loadTo(model);
    }
    final prefs = await SharedPreferences.getInstance();
    int version = prefs.getInt('save_version') ?? SAVE_VERSION;
    print('loading user prefs version = $version');
    
    if(version < SAVE_VERSION)
    {
      performUpgrade(version, SAVE_VERSION);
    }
    else
    {
      model.beginEdit();
      model.gender = Gender.values[prefs.getInt('gender') ?? 0];
      model.marital = Marital.values[prefs.getInt('marital') ?? 0];
      model.birthDay = DateTime.tryParse(prefs.getString('birthday') ?? "")??DateTime.now();
      model.workAddress = prefs.getInt('work_address') ?? 0;
      model.homeAddress = prefs.getInt('home_address') ?? 0;
      model.endEdit();
    }
    print('loaded user prefs '
      'gender = ${model.gender}, '
      'marital = ${model.marital}, '
      'birthDay = ${model.birthDay}, '
      'workAddress = ${model.workAddress}, '
      'homeAddress = ${model.homeAddress}, ');
    // NotificationHelper().send("loaded user prefs", 
    //   'gender = ${model.gender}, '
    //   'marital = ${model.marital}, '
    //   'birthDay = ${model.birthDay}, '
    //   'workAddress = ${model.workAddress}, '
    //   'homeAddress = ${model.homeAddress}, ');
    busy = false;
  }

  Future<Profile> load() async {
    final model = Profile();
    loadTo(model);
    return model;
  }

  Future<void> save(Profile model) async
  {
    if(busy)
    {
      await Future.delayed(Duration(milliseconds: 100));
      return save(model);
    }
    busy = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('save_version', SAVE_VERSION);
    await prefs.setInt('gender', model.gender.index);
    await prefs.setInt('marital', model.marital.index);
    await prefs.setString('birthday', model.birthDay.toString());
    await prefs.setInt('work_address', model.workAddress);
    await prefs.setInt('home_address', model.homeAddress);
    busy = false;
    print("Profile was saved!!!!");
  }

  int applyFilter(Filter filter, Profile model)
  {
    var matched = false;
    var failed = false;
    filter.genders.forEach((e) { matched |= e == model.gender;});
    failed = (!matched && filter.genderMode == FilterMode.include) || 
      (matched && filter.genderMode == FilterMode.exclude);
    if(failed)
    {
      print('apply filter ${filter.title}, return false because gender was not satified');
      return 1;
    }
    filter.maritals.forEach((e) { matched |= e == model.marital;});
    failed = (!matched && filter.maritalMode == FilterMode.include) || 
      (matched && filter.maritalMode == FilterMode.exclude);
    if(failed)
    {
      print('apply filter ${filter.title}, return false because marital was not satified');
      return 2;
    }
    filter.ages.forEach((e) { matched |= model.age >= e.start && model.age <= e.end;});
    failed = (!matched && filter.ageMode == FilterMode.include) || 
      (matched && filter.ageMode == FilterMode.exclude);
    if(failed)
    {
      print('apply filter ${filter.title}, return false because age was not satified');
      return 3;
    }
    filter.workAddresses.forEach((e) { matched |= e == model.workAddress;});
    failed = (!matched && filter.workAddressMode == FilterMode.include) || 
      (matched && filter.workAddressMode == FilterMode.exclude);
    if(failed)
    {
      print('apply filter ${filter.title}, return false because work address was not satified');
      return 4;
    }
    filter.homeAddresses.forEach((e) { matched |= e == model.homeAddress;});
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