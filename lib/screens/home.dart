import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:pop_template/models/message.dart';
import 'package:pop_template/widgets/message_list.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  
  final GlobalKey<MessageListState> listRef = GlobalKey();
  Future<List<Message>> fetchJsonFromNet(BuildContext context) async
  {
    print("fetchJsonFromNet");
    var response = await http.get(Uri.https('example.com','/path/to/json'));
    //var dummy = await Future.delayed(Duration(seconds: 5),() => 'dummy');
    Iterable it = json.decode(response.body);
    return List<Message>.from(it.map((model)=> Message.fromJson(model)));
  }

  Future<List<Message>> readJSONFromCache(BuildContext context) async
  {
    print("readJSONFromCache");
    String response = await DefaultAssetBundle.of(context).loadString("assets/net_messages.json");
    //var dummy = await Future.delayed(Duration(seconds: 5),() => 'dummy');
    Iterable it = json.decode(response);
    return List<Message>.from(it.map((model)=> Message.fromJson(model)));
  }

  void addFakeMessage()
  {
    listRef.currentState.addMessage();
  }

  void toggleDeleteButton()
  {
    listRef.currentState.toggleDeleteButton();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: toggleDeleteButton,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
       currentIndex: 0,
       items: [
         BottomNavigationBarItem(
           icon: Icon(Icons.home),
           label: 'Home',
         ),
         BottomNavigationBarItem(
           icon: Icon(Icons.mail),
           label: 'Messages',
         ),
         BottomNavigationBarItem(
           icon: Icon(Icons.qr_code),
           label: 'QR',
         ),
         BottomNavigationBarItem(
           icon: Icon(Icons.person),
           label: 'Profile',
         )
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
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30,),
                  );
              }
              return MessageList(key: listRef, initialMessages: snapshot.data);
            },
          );
  }
}

