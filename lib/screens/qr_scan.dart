import 'package:flutter/material.dart';

class QRScan extends StatefulWidget {
  QRScanState createState() => QRScanState();
}

class QRScanState extends State<QRScan> {
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
        title: Text("QR Scan"),
      ),
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.qr_code, size: 200),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/result");
                },
                child: Text('See scan result!'),
              ),
            ]),
      ),
    );
  }
}
