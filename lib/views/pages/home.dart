import 'dart:convert';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:pop_experiment/models/filter.dart';
import 'package:pop_experiment/models/geofence.dart';
import 'package:pop_experiment/models/profile.dart';
import 'package:pop_experiment/models/qr_scan_payload.dart';
import 'package:pop_experiment/services/filter_service.dart';
import 'package:pop_experiment/services/geofence_history.dart';
import 'package:pop_experiment/services/geofence_service.dart';
import 'package:pop_experiment/services/local_entry_service.dart';
import 'package:pop_experiment/services/entry_service.dart';
import 'package:pop_experiment/services/notification_service.dart';
import 'package:pop_experiment/views/widgets/entry_list_view.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int selectedCategory = 0;
  int? geofenceID;
  
  static RectTween customTween(Rect? begin, Rect? end) {
    return MaterialRectCenterArcTween(begin: begin, end: end);
  }

  @override
  void initState()
  {
    super.initState();
    final provider = Provider.of<LocalEntryService>(context, listen: false);
    provider.eventController.stream.listen((event) {
      print('HomePageState got event ${event.type}');
      switch (event.type) {
        case EntryEventType.favorite:
          final snackBar = SnackBar(
            content: Text('Entry #${event.index} has been added to favorite!'),
            duration: Duration(milliseconds: 2000));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          break;
        case EntryEventType.delete:
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
    final filterObj = json.decode(filterJson);
    final filter = filterObj == null?Filter():Filter.fromJson(filterObj);
    final profile = await Profile.safeLoad();
    final filterResult = profile.applyFilter(filter);
    if(filterResult != 0)
    {
      //NotificationHelper().send("apply filter failed, no notification", "filter = ${message.data['filter']}");
      //NotificationHelper().send("apply filter failed, no notification", "filterResult = $filterResult");
      return;
    }
    // TODO: apply geofence filter & beacon filter for notification
    String title = message.data['title']??'Untitled';
    String description = message.data['description']??'No body';
    print('there is a message!! $title');
    NotificationService().send(title, description);
  }

  void foregroundMessageHandlerSync(RemoteMessage message) {
    foregroundMessageHandler(message);
  }

  Future<void> foregroundMessageHandler(RemoteMessage message) async {
    String title = message.data['title']??message.notification?.title??"Untitled";
    String description = message.data['description']??message.notification?.body??'No body';
    String filterJson = message.data['filter']??'null';
    //NotificationHelper().send("backgroundMessageHandler", "message.messageId = ${message.messageId}");
    final filterObj = json.decode(filterJson);
    final filter = filterObj == null?Filter():Filter.fromJson(filterObj);
    final profile = Provider.of<Profile>(context, listen: false);
    if(profile.applyFilter(filter) != 0)
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
    final provider = Provider.of<LocalEntryService>(context, listen: false);
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

  void removeGeofenceFilter()
  {
    setState(() {
      geofenceID = null;
      final snackBar = SnackBar(
          content: Text('Now showing all entries'),
          duration: Duration(milliseconds: 1800));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }

  void addGeofenceFilter(int id)
  {
    setState(() {
      geofenceID = id;
      final provider = Provider.of<GeofenceService>(context, listen: false);
      final fence = provider.geofences.firstWhere((e) => e.id == id, orElse: () => Geofence());
      final snackBar = SnackBar(
          content: Text('Now showing entries belong to ${fence.title}'),
          duration: Duration(milliseconds: 1800));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
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
        Consumer<LocalEntryService>(
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
        Consumer<LocalEntryService>(
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
    final history = Provider.of<GeofenceHistory>(context);
    final provider = Provider.of<GeofenceService>(context, listen: false);
    final fences = history.entries.map((id) => provider.geofences.firstWhere((fence) => id == fence.id, orElse: () => Geofence()));
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
            title: Text('All Entries'),
            selected: geofenceID is! int,
            leading: CircleAvatar(
              child: Text("ALL"),
            ),
            onTap: () {
              removeGeofenceFilter();
              Navigator.pop(context);
            },
          ),
          Column(
            children: fences.map((fence) =>
              ListTile(
                title: Text(fence.title??"Untitled"),
                selected: geofenceID == fence.id,
                leading: CircleAvatar(
                  child: CachedNetworkImage(
                    imageUrl: 'https://picsum.photos/seed/${fence.title}/64/64',
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    fit: BoxFit.cover,
                  ),
                ),
                onTap: () {
                  addGeofenceFilter(fence.id);
                  Navigator.pop(context);
                },
              ),
            ).toList(),
          )
        ],
      ),
    );
  }

  Widget buildEntryList(BuildContext context) {
    final profile = Provider.of<Profile>(context);
    final filters = Provider.of<FilterService>(context);
    final geofenceHistory = Provider.of<GeofenceHistory>(context);
    final data = Provider.of<EntryService>(context).entries;
    final provider = Provider.of<LocalEntryService>(context, listen: false);
    provider.loadWithProvider(
      data, 
      profileProvider: profile, 
      filterProvider: filters, 
      geofenceHistoryProvider: geofenceHistory
    );
    if(geofenceID is int)
    {
      return EntryListView(entries: provider.forGeofence(geofenceID!));
    }
    return EntryListView(entries: provider.entries);
  }
}
