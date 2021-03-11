import 'package:flutter/material.dart';

class UserSetting extends StatefulWidget {
  UserSettingState createState() => UserSettingState();
}

class UserSettingState extends State<UserSetting> {
  int counter = 0;

  void incrementCounter() {
    setState(() {
      counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Content Viewer"),
      ),
      body: Center(
        child: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Go Back!'),
        ),
      ),
    );
  }
}