import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<Profile> {
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
        title: Text("User Profile"),
        actions: <Widget>[
          Visibility(
            visible: false,//fix appbar title alignment
            child: IconButton(
              icon: Icon(Icons.cloud),
              onPressed: () => null,
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
                Navigator.pushNamed(context, "/edit").then((value) 
                {
                  final snackBar = SnackBar(
                    content: Text('All changes are saved!'),
                    duration: Duration(milliseconds: 800));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                });
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.contact_mail, size: 200),
            ]),
      ),
    );
  }
}
