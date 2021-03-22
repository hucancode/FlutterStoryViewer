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
                Navigator.pushNamed(context, "/edit").then((result) 
                {
                  if(result is bool && result)
                  {
                    final snackBar = SnackBar(
                      content: Text('All changes are saved!'),
                      duration: Duration(milliseconds: 800));
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                });
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              child: SizedBox(
                height: 150,
                child: ClipOval(
                  child: Image.asset(
                    'assets/avatar_male.png'
                  ),
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 50),
            ),
            ListTile(
                leading: Icon(Icons.emoji_emotions),
                title: Text("Male"),
              ),
            ListTile(
              leading: Icon(Icons.near_me_sharp),
              title: Text("Marugame - Kagawa - Japan"),
            ),
            ListTile(
              leading: Icon(Icons.cake),
              title: Text("13/11/1991"),
            ),
            ListTile(
              leading: Icon(Icons.favorite),
              title: Text("Single"),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("Cam Giang - Hai Duong - Vietnam"),
            ),
          ],
        ),
      ),
    );
  }
}
