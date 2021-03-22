import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  List<bool> selectedGender = [true, false];
  List<bool> selectedMarriageStatus = [true, false, false];
  int selectedLocation = 0;
  int selectedHometown = 0;

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Profile"),
        actions: <Widget>[
          Visibility(
            visible: false, //fix appbar title alignment
            child: IconButton(
              icon: Icon(Icons.cloud),
              onPressed: () => null,
            ),
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
      body: Padding(
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
      ),
    );
  }

  ListTile buildHometown() {
    Widget editWidget = TextButton(
      onPressed: () => null, 
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 9),
        child: Text("Cam Giang - Hai Duong - Vietnam")
      ),
    );
    Widget displayWidget = Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Text("Cam Giang - Hai Duong - Vietnam")
    );
    return ListTile(
      leading: Icon(Icons.home),
      title: editMode?editWidget:displayWidget,
    );
  }

  ListTile buildLocation() {
    Widget editWidget = TextButton(
      onPressed: () => null, 
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 9),
        child: Text("Marugame - Kagawa - Japan")
      ),
    );
    Widget displayWidget = Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Text("Marugame - Kagawa - Japan")
    );
    return ListTile(
      leading: Icon(Icons.my_location),
      title: editMode?editWidget:displayWidget,
    );
  }

  ListTile buildBirthday() {
    Widget editWidget = TextButton(
      onPressed: () => null, 
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 9),
        child: Text("13/11/1991")
      ),
    );
    Widget displayWidget = Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Text("13/11/1991")
    );
    return ListTile(
      leading: Icon(Icons.cake),
      title: editMode?editWidget:displayWidget,
    );
  }

  Padding buildAvatar() {
    return Padding(
      child: SizedBox(
        height: 150,
        child: ClipOval(
          child: Image.asset('assets/avatar_male.png'),
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
    Widget editWidget = ToggleButtons(
      isSelected: selectedGender,
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
          selectedGender = List.filled(2, false);
          selectedGender[index] = true;
        });
      },
    );
    Widget displayWidget = Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Text("Male"),
    );
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
    Widget editWidget = ToggleButtons(
      isSelected: selectedMarriageStatus,
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
          selectedMarriageStatus = List.filled(3, false);
          selectedMarriageStatus[index] = true;
        });
      },
    );
    Widget displayWidget = Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Text("Single")
    );

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: contentPadding),
      leading: Icon(Icons.favorite, size: iconSize),
      title: editMode ? editWidget : displayWidget,
    );
  }
}
