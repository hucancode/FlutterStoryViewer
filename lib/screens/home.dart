import 'dart:convert';
import 'dart:ui';
import 'package:enough_mail/enough_mail.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:pop_template/models/message.dart';
import 'package:pop_template/models/qr_scan_payload.dart';
import 'package:pop_template/widgets/at_pop_adapter.dart';
import 'package:pop_template/widgets/mime_message_list.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final GlobalKey<MimeMessageListState> listRef = GlobalKey();
  int selectedCategory = 0;
  bool showSelectionControl = false;
  
  static RectTween customTween(Rect? begin, Rect? end) {
    return MaterialRectCenterArcTween(begin: begin, end: end);
  }

  Future<List<Message>> fetchJsonFromNet(BuildContext context) async {
    print("fetchJsonFromNet");
    var response = await http.get(Uri.https('example.com', '/path/to/json'));
    //var dummy = await Future.delayed(Duration(seconds: 5),() => 'dummy');
    Iterable it = json.decode(response.body);
    return List<Message>.from(it.map((model) => Message.fromJson(model)));
  }

  Future<List<Message>> readJSONFromCache(BuildContext context) async {
    print("read public messages JSON from cache");
    String response = await DefaultAssetBundle.of(context)
        .loadString("assets/public_messages.json");
    //var dummy = await Future.delayed(Duration(seconds: 5),() => 'dummy');
    Iterable it = json.decode(response);
    print('done loading public messages');
    return List<Message>.from(it.map((model) => Message.fromJson(model)));
  }

  Future<List<MimeMessage>> loginAndFetchMail(BuildContext context) async {
    ImapClient? client = await AtPopAdapter.login(userName: 'b58a39c4a7a9711ce', password: '64641286464128');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Login OK! now fetching mails'),
        duration: Duration(milliseconds: 1800)
      )
    );
    List<MimeMessage> result = await AtPopAdapter.fetch(client: client, maxResult: 10);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('fetched '+result.length.toString()+' mails'),
        duration: Duration(milliseconds: 1800)
      )
    );
    return result;
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

  void addFakeMessage() {
    MimeMessage message = MimeMessage();
    listRef.currentState?.addMessage(message);
  }

  void deleteSelected() {
    listRef.currentState?.deleteSelected();
  }

  void deselectAll()
  {
    listRef.currentState?.exitMultiSelect();
  }

  @override
  Widget build(BuildContext context) {
    print('home - buildScaffold');
    return Scaffold(
      appBar: buildAppBar(),
      drawer: buildDrawer(context),
      body: buildBody(context),
      floatingActionButton: buildFloatingActionButton(context),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: Text("Home"),
      actions: <Widget>[
        Visibility(
          visible: showSelectionControl,
          child: IconButton(
            icon: Icon(Icons.undo),
            onPressed: deselectAll,
          )
        ),
        Visibility(
          visible: showSelectionControl,
          child: IconButton(
            icon: Icon(Icons.delete),
            onPressed: deleteSelected,
          )
        ),
      ],
    );
  }

  Widget buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.pushNamed(context, "/qr").then((scanResult) {
          if(scanResult is QRScanPayload)
          {
            final snackBar = SnackBar(
                  content: Text('New beacon detected, fetching mail...'),
                  duration: Duration(milliseconds: 1600));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            addFakeMessage();
          }
        });
      },
      tooltip: 'QR Scan',
      child: Icon(Icons.qr_code),
    );
  }

  Widget buildBody(BuildContext context) {
    print('home - buildBody');
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          buildMessageList(context),
        ],
      ),
    );
  }

  Drawer buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
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

  FutureBuilder<List<MimeMessage>> buildMessageList(BuildContext context) {
    print('home - buildMessageList');
    return FutureBuilder(
      future: loginAndFetchMail(context),
      builder: (BuildContext context, AsyncSnapshot<List<MimeMessage>> snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        return MimeMessageList(key: listRef, 
        initialMessages: snapshot.data,
        onSelectionCountChanged: (count) {
          setState(() {
            showSelectionControl = count != 0;
          });
        },
        onSingleMessageDeleted: () {
          final snackBar = SnackBar(
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () {
                  addFakeMessage();
                },
              ),
              content: Text('Deleted!'),
              duration: Duration(milliseconds: 2500));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
        },
        onMessageDeleted: (count) {
          final snackBar = SnackBar(
              action: SnackBarAction(
                label: 'Undo All',
                onPressed: () {
                  addFakeMessage();
                  addFakeMessage();
                },
              ),
              content: Text('$count messages have been deleted!'),
              duration: Duration(milliseconds: 2500));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        },
        onFavoriteChanged: (id, value) {
          final snackBar = SnackBar(
              content: Text('Message id - $id has been added to favorite!'),
              duration: Duration(milliseconds: 2000));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        },
        );
      },
    );
  }
}
