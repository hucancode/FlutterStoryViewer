import 'package:flutter/material.dart';

class QRScanResult extends StatefulWidget {
  QRScanResultState createState() => QRScanResultState();
}

class QRScanResultState extends State<QRScanResult> {
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
        title: Text("QR Scan Result"),
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