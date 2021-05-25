import 'dart:convert';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:pop_experiment/models/filter.dart';
import 'package:pop_experiment/models/qr_scan_payload.dart';
import 'package:pop_experiment/models/entry_list.dart';
import 'package:pop_experiment/services/entry_service.dart';
import 'package:pop_experiment/services/notification_helper.dart';
import 'package:pop_experiment/services/profile_manager.dart';
import 'package:pop_experiment/views/widgets/entry_list_view.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int selectedCategory = 0;
  
  static RectTween customTween(Rect? begin, Rect? end) {
    return MaterialRectCenterArcTween(begin: begin, end: end);
  }

  @override
  void initState()
  {
    super.initState();
    final provider = Provider.of<EntryList>(context, listen: false);
    provider.eventController.stream.listen((event) {
      print('HomePageState got event ${event.type}');
      switch (event.type) {
        case EntryListEventType.favorite:
          final snackBar = SnackBar(
            content: Text('Entry #${event.index} has been added to favorite!'),
            duration: Duration(milliseconds: 2000));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          break;
        case EntryListEventType.delete:
          final snackBar = SnackBar(
            content: Text('Deleted!'),
            duration: Duration(milliseconds: 2500));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          break;
        default:
      }
    });
    listenToFCM();
  }


  Future<void> backgroundMessageHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    //NotificationHelper().send("backgroundMessageHandler", "message.messageId = ${message.messageId}");
    String filterJson = message.data['filter']??'';
    final filterObj = jsonDecode(filterJson);
    final filter = filterObj == null?Filter.empty():Filter.fromJson(filterObj);
    final profile = await ProfileManager().load();
    final filterResult = ProfileManager().applyFilter(filter, profile);
    if(filterResult != 0)
    {
      //NotificationHelper().send("apply filter failed, no notification", "filter = ${message.data['filter']}");
      //NotificationHelper().send("apply filter failed, no notification", "filterResult = $filterResult");
      return;
    }
    String title = message.data['title']??'Untitled';
    String description = message.data['description']??'No body';
    print('there is a message!! $title');
    NotificationHelper().send(title, description);
  }

  void foregroundMessageHandlerSync(RemoteMessage message) {
    foregroundMessageHandler(message);
  }

  Future<void> foregroundMessageHandler(RemoteMessage message) async {
    String title = message.data['title']??message.notification?.title??"Untitled";
    String description = message.data['description']??message.notification?.body??'No body';
    String filterJson = message.data['filter']??'null';
    //NotificationHelper().send("backgroundMessageHandler", "message.messageId = ${message.messageId}");
    final filterObj = jsonDecode(filterJson);
    final filter = filterObj == null?Filter.empty():Filter.fromJson(filterObj);
    final profile = await ProfileManager().load();
    if(ProfileManager().applyFilter(filter, profile) != 0)
    {
      return;
    }
    showDialog(context: context, builder: (context)
    {
      return AlertDialog(
        title: Text(title),
        content: Text(description)
      );
    });
    final entryID = int.tryParse(message.data['entryID']);
    print('there is a message!! $entryID');
    if(entryID == null)
    {
      return;
    }
    final entry = await EntryService().fetchSingle(entryID);
    final provider = Provider.of<EntryList>(context, listen: false);
    provider.add(entry);
    print('fetched $entryID (${entry.title})');
  }
  

  Future<void> listenToFCM() async
  {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    // Set the background messaging handler early on, as a named top-level function
    FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance.getInitialMessage().then((fcmMessage) {
      if (fcmMessage == null)
      {
        return;
      }
      print('you have unread message from fcm ${fcmMessage.messageId}');
    });

    FirebaseMessaging.onMessage.listen(foregroundMessageHandlerSync);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage fcmMessage) {
      final id = int.tryParse(fcmMessage.data['entryID']);
      if(id == null)
      {
        return;
      }
      EntryService().fetchSingle(id).then((message) 
      {
        Navigator.pushNamed(context, '/detail', arguments: message);
      });
    });

    await FirebaseMessaging.instance.requestPermission(
      announcement: true,
      carPlay: true,
      criticalAlert: true,
    );
    final token = await FirebaseMessaging.instance.getToken();
    print("FCM token = $token");
    FirebaseMessaging.instance.onTokenRefresh.listen((value) {
      print("FCM token was renewed, $value");
    });

    await FirebaseMessaging.instance.subscribeToTopic('hucancode');
  }

  void selectCategory(int cat)
  {
    setState(() {
      selectedCategory = cat;
      cat++;
      final snackBar = SnackBar(
          content: Text('Now showing Category $cat'),
          duration: Duration(milliseconds: 1800));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      drawer: buildDrawer(context),
      body: buildBody(context),
      floatingActionButton: buildFloatingActionButton(context),
    );
  }

  FloatingActionButton buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.pushNamed(context, "/qr").then((scanResult) {
          if(scanResult is QRScanPayload)
          {
            final snackBar = SnackBar(
                  content: Text('New beacon detected, fetching mail...'),
                  duration: Duration(milliseconds: 1600));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            //final provider = Provider.of<EntryList>(context, listen: false);
          }
        });
      },
      tooltip: 'QR Scan',
      child: Icon(Icons.qr_code),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: Text("Home"),
      actions: [
        Consumer<EntryList>(
          builder: (context, model, child) {
            return Visibility(
              visible: model.totalSelected > 0,
              child: IconButton(
                icon: Icon(Icons.undo),
                onPressed: () => model.selectNone(),
              )
            );
          },
        ),
        Consumer<EntryList>(
          builder: (context, model, child) {
            return Visibility(
              visible: model.totalSelected > 0,
              child: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => model.deleteSelected(),
              )
            );
          },
        ),
      ],
    );
  }

  Widget buildBody(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildEntryList(context),
        ],
      ),
    );
  }

  Drawer buildDrawer(BuildContext context) {
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Image.asset(
                      'assets/pop_icon.png', 
                      fit: BoxFit.contain),
                  ),
                  Text(
                    '@POP',
                    style: TextStyle(fontSize: 30, color: Colors.orange),
                  ),
                ],
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.blue,
              image: DecorationImage(
                image: AssetImage("assets/header_bg_bright.png"), 
                fit: BoxFit.cover
              ),
            ),
          ),
          ListTile(
            title: Text('Category 1'),
            selected: selectedCategory == 0,
            leading: CircleAvatar(
              child: Image.asset('assets/amber.jpg', fit: BoxFit.contain),
            ),
            onTap: () {
              selectCategory(0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Category 2'),
            selected: selectedCategory == 1,
            leading: CircleAvatar(
              child: Image.asset('assets/phaser.png', fit: BoxFit.contain),
            ),
            onTap: () {
              selectCategory(1);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Category 3'),
            selected: selectedCategory == 2,
            leading: CircleAvatar(
              child: Image.asset('assets/cat.png', fit: BoxFit.contain),
            ),
            onTap: () {
              selectCategory(2);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Category 4'),
            selected: selectedCategory == 3,
            leading: CircleAvatar(
              child: Image.asset('assets/healing.png', fit: BoxFit.contain),
            ),
            onTap: () {
              selectCategory(3);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget buildEntryList(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<EntryList>(context, listen: false).load(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return CircularProgressIndicator();
        }
        return EntryListView();
      },
    );
  }
}
