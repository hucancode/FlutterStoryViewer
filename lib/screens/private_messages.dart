import 'package:flutter/material.dart';

class PrivateMessages extends StatefulWidget {
  PrivateMessagesState createState() => PrivateMessagesState();
}

class PrivateMessagesState extends State<PrivateMessages> {
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
        title: Text("Private Message"),
      ),
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.message, size: 200),
              TextButton(
                onPressed: () {
                  //Navigator.pushNamed(context, "/detail");
                },
                child: Text('Go to message detail!'),
              ),
            ]),
      ),
    );
  }
}
