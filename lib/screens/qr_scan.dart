import 'package:flutter/material.dart';
import 'package:pop_template/models/qr_scan_payload.dart';

class QRScan extends StatefulWidget {
  QRScanState createState() => QRScanState();
}

class QRScanState extends State<QRScan> {
  QRScanPayload? payload;
  void setPayload(QRScanPayload obj)
  {
    setState(() {
      payload = obj;
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
              Icon(Icons.wifi, size: 200),
              Text("UUID: "+
                (payload?.uuid??"_________________") + 
                "\nMajor: "+
                (payload?.major.toString()??"_") +
                "\nMinor: "+
                (payload?.minor.toString()??"_")
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, payload);
                },
                child: Text('Submit this result!'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/qr_result").then((scanResult) {
                    setState(() {
                      payload = scanResult as QRScanPayload;
                    });
                    
                  });
                },
                child: Text('Scan now!'),
              ),
            ]),
      ),
    );
  }
}
