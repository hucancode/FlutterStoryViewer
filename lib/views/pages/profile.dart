import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pop_experiment/models/profile.dart';
import 'package:pop_experiment/services/prefecture_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

const int SAVE_VERSION = 1;


class ProfilePage extends StatefulWidget {
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<ProfilePage> {

  double bodyPadding = 20;
  double iconSize = 24;

  bool editMode = false;

  void enterEditMode() {
    setState(() {
      editMode = true;
    });
  }

  void exitEditMode() {
    setState(() {
      editMode = false;
    });
    final profile = Provider.of<Profile>(context, listen: false);
    profile.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Profile"),
        actions: [
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
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: bodyPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Spacer(flex: 1),
          buildAvatar(),
          Spacer(flex: 1),
          buildGender(),
          buildMariageStatus(context),
          buildBirthday(),
          buildLocation(),
          buildHometown(),
          Spacer(flex: 1),
        ],
      ),
    );
  }

  Widget buildHometown() {
    final provider = Provider.of<PrefectureService>(context);
    final profile = Provider.of<Profile>(context);
    final prefecture = provider.readById(profile.homeAddress);
    Widget editWidget = DropdownButton<int>(
      isExpanded: true,
      value: prefecture.id,
      items: provider.prefectures.map((prefecture) 
      {
        return DropdownMenuItem(
          value: prefecture.id,
          child: Text(prefecture.title??""),
        );
      }).toList(),
      onChanged: (int? val) 
      {
          profile.homeAddress = val??0;
      },
    );
    Widget displayWidget = Text(prefecture.title??"");
    return ListTile(
      leading: Icon(Icons.home),
      title: editMode?editWidget:displayWidget,
    );
  }

  Widget buildLocation() {
    final provider = Provider.of<PrefectureService>(context);
    final profile = Provider.of<Profile>(context);
    final prefecture = provider.readById(profile.workAddress);
    Widget editWidget = DropdownButton<int>(
      isExpanded: true,
      value: prefecture.id,
      items: provider.prefectures.map((prefecture) 
      {
        return DropdownMenuItem(
          value: prefecture.id,
          child: Text(prefecture.title??""),
        );
      }).toList(),
      onChanged: (int? val) 
      {
          profile.workAddress = val??0;
      },
    );
    Widget displayWidget = Text(prefecture.title??"");
    return ListTile(
      leading: Icon(Icons.my_location),
      title: editMode?editWidget:displayWidget,
    );
  }

  Widget buildBirthday() {
    final profile = Provider.of<Profile>(context);
    final format = DateFormat('dd/M/yyyy');
    final birthDayStr = '${format.format(profile.birthDay)} (${profile.age} years old)';

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
          profile.birthDay = value??profile.birthDay;     
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

  Widget buildAvatar() {
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

    final profile = Provider.of<Profile>(context);

    final avatars = [maleAvatars, femaleAvatars];
    final int ageTier = min(max((profile.age - 5) ~/ 10, 0), min(maleAvatars.length, femaleAvatars.length));
    final avatar = avatars[profile.gender.index][ageTier];
    return SizedBox(
      height: 150,
      child: ClipOval(
        child: Image.asset('assets/$avatar.png'),
      ),
    );
  }

  Widget buildGender() {
    final profile = Provider.of<Profile>(context);

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
    var selected = List.filled(Gender.values.length, false);
    selected[profile.gender.index] = true;
    Widget editWidget = ToggleButtons(
      isSelected: selected,
      children: Gender.values.map((e) => 
        Container(
            width: itemWidth,
            height: itemHeight,
            alignment: Alignment.center,
            child: Text(e.toString().split('.').last),
        )).toList(),
      onPressed: (int index) {
        setState(() {
          profile.gender = Gender.values[index];
        });
      },
    );
    Widget displayWidget = Text(profile.gender.toString().split('.').last);
    return ListTile(
      leading: Icon(Icons.emoji_emotions, size: iconSize),
      title: editMode ? editWidget : displayWidget,
    );
  }

  Widget buildMariageStatus(BuildContext context) {
    final profile = Provider.of<Profile>(context);
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
    var selected = List.filled(Marital.values.length, false);
    selected[profile.marital.index] = true;
    Widget editWidget = ToggleButtons(
      isSelected: selected,
      children: Marital.values.map((e) => 
        Container(
            width: itemWidth,
            height: itemHeight,
            alignment: Alignment.center,
            child: Text(e.toString().split('.').last),
        )).toList(),
      onPressed: (int index) {
        setState(() {
          profile.marital = Marital.values[index];
        });
      },
    );
    Widget displayWidget = Text(profile.marital.toString().split('.').last);

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: contentPadding),
      leading: Icon(Icons.favorite, size: iconSize),
      title: editMode ? editWidget : displayWidget,
    );
  }
}
