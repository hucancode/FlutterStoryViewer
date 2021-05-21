import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:pop_experiment/models/entry.dart';
import 'package:pop_experiment/views/widgets/entry_list_view.dart';

class PrivateMessages extends StatefulWidget {
  PrivateMessagesState createState() => PrivateMessagesState();
}

class PrivateMessagesState extends State<PrivateMessages> {
  final GlobalKey<EntryListViewState> listRef = GlobalKey();
  bool showSelectionControl = false;
  
  static RectTween customTween(Rect? begin, Rect? end) {
    return MaterialRectCenterArcTween(begin: begin, end: end);
  }

  Future<List<Entry>> fetchJsonFromNet(BuildContext context) async {
    print("fetchJsonFromNet");
    var response = await http.get(Uri.https('example.com', '/path/to/json'));
    //var dummy = await Future.delayed(Duration(seconds: 5),() => 'dummy');
    Iterable it = json.decode(response.body);
    return List<Entry>.from(it.map((model) => Entry.fromJson(model)));
  }

  Future<List<Entry>> readJSONFromCache(BuildContext context) async {
    print("read pm JSON from cache");
    String response = await DefaultAssetBundle.of(context)
        .loadString("assets/private_messages.json");
    //var dummy = await Future.delayed(Duration(seconds: 5),() => 'dummy');
    Iterable it = json.decode(response);
    print('done loading pm');
    return List<Entry>.from(it.map((model) => Entry.fromJson(model)));
  }

  void deleteSelected() {
    //listRef.currentState?.deleteSelected();
  }
  
  void deselectAll()
  {
    //listRef.currentState?.exitMultiSelect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Private Messages"),
        actions: [
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildMessageList(context),
          ],
        ),
      ),
    );
  }

  FutureBuilder<List<Entry>> buildMessageList(BuildContext context) {
    return FutureBuilder(
      future: readJSONFromCache(context),
      builder: (BuildContext context, AsyncSnapshot<List<Entry>> snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        return EntryListView(key: listRef);
      },
    );
  }
}
