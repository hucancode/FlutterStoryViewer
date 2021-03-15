import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:pop_template/models/message.dart';
import 'package:pop_template/widgets/message_list.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final GlobalKey<MessageListState> listRef = GlobalKey();
  int selectedCategory = 0;
  
  static RectTween customTween(Rect begin, Rect end) {
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

  void selectCategory(int cat)
  {
    setState(() {
      selectedCategory = cat;
    });
  }

  void addFakeMessage() {
    listRef.currentState.addMessage();
  }

  void deleteSelected() {
    listRef.currentState.deleteSelected();
  }
  void deselectAll()
  {
    listRef.currentState.exitMultiSelect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: deselectAll,
          ),
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: deleteSelected,
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
              child: ListTile(
                title: Text('@POP'),
                leading: CircleAvatar(
                  child: Image.asset('assets/pop_icon.png', fit: BoxFit.contain),
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
        onPressed: addFakeMessage,
        tooltip: 'QR Scan',
        child: Icon(Icons.qr_code),
      ),
    );
  }

  FutureBuilder<List<Message>> buildMessageList(BuildContext context) {
    return FutureBuilder(
      future: readJSONFromCache(context),
      builder: (BuildContext context, AsyncSnapshot<List<Message>> snapshot) {
        if (!snapshot.hasData) {
          return Text(
            'Loading...',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          );
        }
        return MessageList(key: listRef, initialMessages: snapshot.data);
      },
    );
  }
}
