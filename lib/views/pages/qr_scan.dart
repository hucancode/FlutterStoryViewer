import 'package:flutter/material.dart';
import 'package:pop_experiment/models/qr_scan_payload.dart';

class QRScan extends StatefulWidget {
  QRScanState createState() => QRScanState();
}

class QRScanState extends State<QRScan> {
  QRScanPayload? payload;
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
            children: [
              Icon(Icons.wifi, size: 200),
              Text("UUID: "+
                (payload?.uuid??"_________________") + 
                "\nMajor: "+
                (payload?.major.toString()??"_") +
                "\nMinor: "+
                (payload?.minor.toString()??"_")
              ),
              Visibility(
                visible: (payload is QRScanPayload),
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context, payload);
                  },
                  child: Text('Submit this result!'),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/qr_result").then((scanResult) {
                    setState(() {
                      if(scanResult is QRScanPayload)
                      {
                        payload = scanResult;
                      }
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
