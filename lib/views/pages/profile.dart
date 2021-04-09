import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

const int SAVE_VERSION = 1;

class Profile extends StatefulWidget {
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  int gender = 0;
  int marriageStatus = 0;
  List<String> prefectureNames = [];
  DateTime birthDay = DateTime.now();
  int addressWork = 0;
  int addressHome = 0;

  double bodyPadding = 20;
  double iconSize = 24;

  bool editMode = false;
  bool isBusy = false;

  @override
  void initState()
  {
    super.initState();
    loadUserPrefs();
  }

  void enterEditMode() {
    setState(() {
      editMode = true;
    });
  }

  void exitEditMode() {
    setState(() {
      editMode = false;
    });
    saveUserPrefs();
  }

  Future<void> readPrefectures() async {
    print("read japan prefectures JSON");
    String response = await DefaultAssetBundle.of(context)
        .loadString("assets/japan_prefectures.json");
    print('reading japan prefectures JSON response = ${response.length}');
    prefectureNames = List.from(json.decode(response));
    print('done reading japan prefectures ${prefectureNames.length}');
  }

  Future<void> loadUserPrefs() async
  {
    setState(() {
      isBusy = true;
    });
    print('begin loading user prefs');
    await readPrefectures();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int version = prefs.getInt('save_version') ?? SAVE_VERSION;
    print('loading user prefs version = $version');
    if(version < SAVE_VERSION)
    {
      // performUpgrade(version, SAVE_VERSION);
    }
    else
    {
      gender = (prefs.getBool('gender')?? true)?1:0;
      marriageStatus = prefs.getInt('marriage') ?? 0;
      birthDay = DateTime.tryParse(prefs.getString('birthday') ?? "")??DateTime.now();
      addressWork = prefs.getInt('address_work') ?? 0;
      addressHome = prefs.getInt('address_home') ?? 0;
    }

    print('loaded user prefs '
    'gender = $gender, '
    'marriageStatus = $marriageStatus, '
    'birthDay = $birthDay, '
    'addressWork = $addressWork, '
    'addressHome = $addressHome, ');
    setState(() {
      isBusy = false;
    });
  }

  void handleSavePref(String key, bool success)
  {
    if(!success)
    {
      print('error while saving user pref - $key');
    }
  }

  Future<void> saveUserPrefs() async
  {
    setState(() {
      isBusy = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('save_version', SAVE_VERSION).
      then((success) => handleSavePref('save_version', success));
    await prefs.setBool('gender', gender==1?true:false).
      then((success) => handleSavePref('gender', success));
    await prefs.setInt('marriage', marriageStatus).
      then((success) => handleSavePref('marriage', success));
    await prefs.setString('birthday', birthDay.toString()).
      then((success) => handleSavePref('birthday', success));
    await prefs.setInt('address_work', addressWork).
      then((success) => handleSavePref('address_work', success));
    await prefs.setInt('address_home', addressHome).
      then((success) => handleSavePref('address_home', success));
    setState(() {
      isBusy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Profile"),
        actions: <Widget>[
          Visibility(
            visible: false, //fix appbar title alignment
            child: Icon(Icons.android),
          ),
          IconButton(
            icon: Icon(editMode?Icons.check:Icons.edit),
            onPressed: () {
              if (!editMode) {
                enterEditMode();
              } else {
                exitEditMode();
              }
              print('edit mode = $editMode');
            },
          ),
        ],
      ),
      body: isBusy?CircularProgressIndicator(): buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: bodyPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          buildAvatar(),
          buildGender(),
          buildMariageStatus(context),
          buildBirthday(),
          buildLocation(),
          buildHometown(),
        ],
      ),
    );
  }

  ListTile buildHometown() {
    final prefecture = prefectureNames[addressHome];
    List<int> ids = List.generate(prefectureNames.length, (index) => index);
    Widget editWidget = DropdownButton<int>(
      isExpanded: true,
      value: addressHome,
      items: ids.map((id) 
      {
        return DropdownMenuItem(
          value: id,
          child: Text(prefectureNames[id]),
        );
      }).toList(),
      onChanged: (int? val) 
      {
        setState(() {
          addressHome = val??0;
        });
      },
    );
    Widget displayWidget = Text(prefecture);
    return ListTile(
      leading: Icon(Icons.home),
      title: editMode?editWidget:displayWidget,
    );
  }

  ListTile buildLocation() {
    final prefecture = prefectureNames[addressWork];
    List<int> ids = List.generate(prefectureNames.length, (index) => index);
    Widget editWidget = DropdownButton<int>(
      isExpanded: true,
      value: addressWork,
      items: ids.map((id) 
      {
        return DropdownMenuItem(
          value: id,
          child: Text(prefectureNames[id]),
        );
      }).toList(),
      onChanged: (int? val) 
      {
        setState(() {
          addressWork = val??0;
        });
      },
    );
    Widget displayWidget = Text(prefecture);
    return ListTile(
      leading: Icon(Icons.my_location),
      title: editMode?editWidget:displayWidget,
    );
  }

  ListTile buildBirthday() {
    final format = DateFormat('dd/M/yyyy');
    final birthDayStr = format.format(birthDay);

    Widget editWidget = TextButton(
      onPressed: (){
        showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1950),
          lastDate: DateTime.now(),
          initialDatePickerMode: DatePickerMode.year,
        ).then((value) 
        {
          setState(() {
            birthDay = value??birthDay;
          });         
        });
      }, 
      child: Text(birthDayStr),
    );
    
    Widget displayWidget = Text(birthDayStr);
    return ListTile(
      leading: Icon(Icons.cake),
      title: editMode?editWidget:displayWidget,
    );
  }

  Padding buildAvatar() {
    const maleAvatars = [
      "avatar_male_0",
      "avatar_male_1",
      "avatar_male_2",
      "avatar_male_3",
      "avatar_male_4",
    ];
    const femaleAvatars = [
      "avatar_female_0",
      "avatar_female_1",
      "avatar_female_2",
      "avatar_female_3",
      "avatar_female_4",
    ];
    final avatars = [maleAvatars, femaleAvatars];
    final int age = DateTime.now().difference(birthDay).inDays ~/ 365;
    final int ageTier = min(max((age - 5) ~/ 10, 0), min(maleAvatars.length, femaleAvatars.length));
    final avatar = avatars[gender][ageTier];
    return Padding(
      child: SizedBox(
        height: 150,
        child: ClipOval(
          child: Image.asset('assets/$avatar.png'),
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: 50),
    );
  }

  ListTile buildGender() {
    int itemCount = 2;
    
    double contentPadding = 16;
    double borderWidth = 1;
    double contentWidth = MediaQuery.of(context).size.width -
        bodyPadding * 2 -
        iconSize -
        contentPadding * 4 -
        (itemCount + 1) * borderWidth;
    double itemWidth = contentWidth / itemCount;
    double itemHeight = iconSize - borderWidth * 4;
    var selected = List.filled(2, false);
    selected[gender] = true;
    Widget editWidget = ToggleButtons(
      isSelected: selected,
      children: [
        Container(
          alignment: Alignment.center,
          width: itemWidth,
          height: itemHeight,
          child: Text("Male"),
        ),
        Container(
          alignment: Alignment.center,
          width: itemWidth,
          height: itemHeight,
          child: Text("Female"),
        ),
      ],
      onPressed: (int index) {
        setState(() {
          gender = index;
        });
      },
    );
    final genderString = gender==0?'Male':'Female';
    Widget displayWidget = Text(genderString);
    return ListTile(
      leading: Icon(Icons.emoji_emotions, size: iconSize),
      title: editMode ? editWidget : displayWidget,
    );
  }

  ListTile buildMariageStatus(BuildContext context) {
    int itemCount = 3;
    
    double contentPadding = 16;
    double borderWidth = 1;
    double contentWidth = MediaQuery.of(context).size.width -
        bodyPadding * 2 -
        iconSize -
        contentPadding * 4 -
        (itemCount + 1) * borderWidth;
    double itemWidth = contentWidth / itemCount;
    double itemHeight = iconSize - borderWidth * 4;
    var selected = List.filled(3, false);
    selected[marriageStatus] = true;
    Widget editWidget = ToggleButtons(
      isSelected: selected,
      children: [
        Container(
            width: itemWidth,
            height: itemHeight,
            alignment: Alignment.center,
            child: Text("Single Dog")),
        Container(
            width: itemWidth,
            height: itemHeight,
            alignment: Alignment.center,
            child: Text("Married")),
        Container(
            width: itemWidth,
            height: itemHeight,
            alignment: Alignment.center,
            child: Text("Divorced")),
      ],
      onPressed: (int index) {
        setState(() {
          marriageStatus = index;
        });
      },
    );
    final marriageStatusString = marriageStatus==0?'Single':
    marriageStatus==1?'Married':'Divorced';
    Widget displayWidget = Text(marriageStatusString);

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: contentPadding),
      leading: Icon(Icons.favorite, size: iconSize),
      title: editMode ? editWidget : displayWidget,
    );
  }
}
