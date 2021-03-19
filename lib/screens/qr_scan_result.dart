import 'package:flutter/material.dart';
import 'package:pop_template/models/qr_scan_payload.dart';

class QRScanResult extends StatefulWidget {
  QRScanResultState createState() => QRScanResultState();
}

class QRScanResultState extends State<QRScanResult> {
  final QRScanPayload? payload = QRScanPayload(uuid: "783992c2-861c-11eb-8dcd-0242ac130003", major: 99, minor: 2);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("QR Scan Result"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.qr_code, size: 200),
            TextButton(
              onPressed: () {
                Navigator.pop(context, payload);
              },
              child: Text('Submit this result!'),
            ),
          ],
        ),
      ),
    );
  }
}