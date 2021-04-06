import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:pop_template/models/message.dart';
import 'package:pop_template/models/qr_scan_payload.dart';
import 'package:pop_template/views/widgets/message_list.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final GlobalKey<MessageListState> listRef = GlobalKey();
  int selectedCategory = 0;
  bool showSelectionControl = false;
  
  static RectTween customTween(Rect? begin, Rect? end) {
    return MaterialRectCenterArcTween(begin: begin, end: end);
  }

  Future<List<Message>> fetchJsonFromNet(BuildContext context) async {
    const serverEndpoint = 'pop-ex.atpop.info:3100';
    const selectAPI = '/entry/read';
    print("fetchJsonFromNet");
    try {      
      var uri = Uri.https(serverEndpoint, selectAPI);
      var response = await http.get(uri).timeout(Duration(seconds: 10), onTimeout: (){
        print('request timed out {$uri.toString()}');
        return null;
      });
      if (response.statusCode == 200)
      {
        //var dummy = await Future.delayed(Duration(seconds: 5),() => 'dummy');
        print('response.body = ${response.body}');
        var responseJson = json.decode(response.body);
        Iterable models = responseJson['data'];
        return List<Message>.from(models.map((model) => Message.fromJson(model)));
      }
      print('response.statusCode = ${response.statusCode}: ${response.body}');
    } on Exception catch (e) {
      print('error while fetching json ${e.toString()}');
    }
    return List<Message>.empty();
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
    listRef.currentState?.addMessage();
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
    return Scaffold(
      appBar: AppBar(
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
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
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
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            buildMessageList(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, "/qr").then((scanResult) {
            if(scanResult is QRScanPayload)
            {
              final snackBar = SnackBar(
                    content: Text('New beacon detected, fetching mail...'),
                    duration: Duration(milliseconds: 1600));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              addFakeMessage();
              addFakeMessage();
              addFakeMessage();
            }
          });
        },
        tooltip: 'QR Scan',
        child: Icon(Icons.qr_code),
      ),
    );
  }

  FutureBuilder<List<Message>> buildMessageList(BuildContext context) {
    return FutureBuilder(
      future: fetchJsonFromNet(context),
      builder: (BuildContext context, AsyncSnapshot<List<Message>> snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        print('buildMessageList data ready ${snapshot.data?.length??0}');
        return MessageList(key: listRef, 
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
