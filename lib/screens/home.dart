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

  void addFakeMessage() {
    listRef.currentState.addMessage();
  }

  void toggleDeleteButton() {
    listRef.currentState.toggleDeleteButton();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: toggleDeleteButton,
          ),
        ],
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
        tooltip: 'New Item',
        child: Icon(Icons.add),
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
