import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pop_template/models/message.dart';

class MessageFetcher {
  static const LOCAL_CACHE = 'messages.json';
  static const CACHE_MAX_AGE_HOUR = 24;
  static const SERVER_ENDPOINT = 'pop-ex.atpop.info:3100';
  static const READ_API = '/entry/read';

  static final MessageFetcher _instance = MessageFetcher._privateConstructor();
  MessageFetcher._privateConstructor();

  factory MessageFetcher() {
    return _instance;
  }

  Future<File> get cacheFile async {
    final directory = await getApplicationDocumentsDirectory();
    final fullPath = '${directory.path}/$LOCAL_CACHE';
    print('cacheFile = $fullPath');
    return File(fullPath);
  }

  Future<List<Message>> readOrFetch() async {
    try
    {
      final file = await cacheFile;
      final date = await file.lastModified();
      final now = DateTime.now();
      if(now.difference(date).inHours < CACHE_MAX_AGE_HOUR)
      {
        return await readFromCache();
      }
    } on Exception catch (e) {
      print('error while reading cache ${e.toString()}');
    }
    return await fetch();
  }

  Future<List<Message>> readFromCache() async {
    print("MessageFetcher readFromCache()");
    try {
      final cache = await cacheFile;
      String response = await cache.readAsString();
      Iterable it = json.decode(response);
      return List<Message>.from(it.map((model) => Message.fromJson(model)));
    } on Exception catch (e) {
      print('error while fetching json ${e.toString()}');
    }
    return List<Message>.empty();
  }

  Future<void> writeToCache(dynamic jsonData) async {
    final file = await cacheFile;
    file.writeAsString(jsonEncode(jsonData));
  }

  Future<List<Message>> fetch() async {
    print("MessageFetcher fetch()");
    try {
      var uri = Uri.https(SERVER_ENDPOINT, READ_API);
      var response = await http.get(uri).timeout(Duration(seconds: 10), onTimeout: (){
        print('request timed out {$uri.toString()}');
        return null;
      });
      print('response(${response.statusCode}) = ${response.body}');
      if (response.statusCode == 200)
      {
        var responseJson = jsonDecode(response.body);
        Iterable models = responseJson['data'];
        writeToCache(models);
        return List<Message>.from(models.map((model) => Message.fromJson(model)));
      }
    } on Exception catch (e) {
      print('error while fetching json ${e.toString()}');
    }
    return List<Message>.empty();
  }
}
  