import 'dart:convert';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:pop_experiment/models/filter.dart';
import 'package:pop_experiment/models/qr_scan_payload.dart';
import 'package:pop_experiment/models/message_list.dart';
import 'package:pop_experiment/services/message_fetcher.dart';
import 'package:pop_experiment/services/notification_helper.dart';
import 'package:pop_experiment/views/widgets/message_list_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final provider = Provider.of<MessageList>(context, listen: false);
    provider.eventController.stream.listen((event) {
      print('HomePageState got event ${event.type}');
      switch (event.type) {
        case MessageListEventType.favorite:
          final snackBar = SnackBar(
            content: Text('Message #${event.index} has been added to favorite!'),
            duration: Duration(milliseconds: 2000));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          break;
        case MessageListEventType.delete:
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
    print('Handling a background message ${message.messageId}');
    String title = message.data['title']??'Untitled';
    String description = message.data['description']??'No body';
    print('there is a message!! $title');
    String filterJson = message.data['filter']??'';

    final filter = Filter.fromJson(jsonDecode(filterJson));

    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final gender = (prefs.getBool('gender')?? true)?1:0;
    final marriageStatus = prefs.getInt('marriage') ?? 0;

    if(!filter.genders.contains(gender))
    {
      print("this message doens't match my gender");
      return;
    }
    if(!filter.maritals.contains(marriageStatus))
    {
      print("this message doens't match my marriage status");
      return;
    }
      
    NotificationHelper().scheduleNotification(title, description);
  }

  void foregroundMessageHandlerSync(RemoteMessage message) {
    foregroundMessageHandler(message);
  }

  Future<void> foregroundMessageHandler(RemoteMessage message) async {

    final entryID = int.parse(message.data['entryID']);
    print('there is a message!! $entryID, fetching content');
    String filterJson = message.data['filter']??'';

    final filter = Filter.fromJson(jsonDecode(filterJson));

    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final gender = (prefs.getBool('gender')?? true)?1:0;
    final marriageStatus = prefs.getInt('marriage') ?? 0;

    if(!filter.genders.contains(gender))
    {
      print("this message doens't match my gender");
      return;
    }
    if(!filter.maritals.contains(marriageStatus))
    {
      print("this message doens't match my marriage status");
      return;
    }
    final entry = await MessageFetcher().fetchSingle(entryID);

    final provider = Provider.of<MessageList>(context, listen: false);
    provider.addMessage(entry);
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
      final message = MessageFetcher().fetchSingle(int.parse(fcmMessage.data['entryID']));
      Navigator.pushNamed(context, '/detail', arguments: message);
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
            //final provider = Provider.of<MessageList>(context, listen: false);
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
        Consumer<MessageList>(
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
        Consumer<MessageList>(
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
          buildMessageList(context),
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

  Widget buildMessageList(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<MessageList>(context, listen: false).loadMessages(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return CircularProgressIndicator();
        }
        return MessageListView();
      },
    );
  }
}
