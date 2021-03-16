import 'package:flutter/material.dart';

class ProfileEdit extends StatefulWidget {
  ProfileEditState createState() => ProfileEditState();
}

class ProfileEditState extends State<ProfileEdit> {
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
        title: Text("Profile Edit"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.contact_page, size: 200),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text('Save!'),
            ),
          ]
        ),
      ),
    );
  }
}