import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pop_experiment/models/entry.dart';

class EntryService extends ChangeNotifier {
  static const LOCAL_CACHE = 'entries.json';
  static const CACHE_MAX_AGE_HOUR = 12;
  static const SERVER_ENDPOINT = 'pop-ex.atpop.info:3100';
  static const READ_API = '/entry/read';

  List<Entry> entries = [];

  Future<File> get cacheFile async {
    final directory = await getApplicationDocumentsDirectory();
    final fullPath = '${directory.path}/$LOCAL_CACHE';
    print('cacheFile = $fullPath');
    return File(fullPath);
  }

  Future<void> readOrFetch() async {
    return await fetch();
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

  Future<void> readFromCache() async {
    print("EntryService readFromCache()");
    try {
      final cache = await cacheFile;
      String response = await cache.readAsString();
      Iterable models = json.decode(response);
      entries = models.map((model) => Entry.fromJson(model)).toList();
    } on Exception catch (e) {
      print('error while fetching json ${e.toString()}');
    }
  }

  Future<void> writeToCache(dynamic jsonData) async {
    final file = await cacheFile;
    file.writeAsString(json.encode(jsonData));
  }

  Future<void> fetch() async {
    print("EntryService fetch()");
    try {
      var uri = Uri.https(SERVER_ENDPOINT, READ_API);
      var response = await http.get(uri).timeout(Duration(seconds: 10));
      //print('response(${response.statusCode}) = ${response.body}');
      if (response.statusCode == 200)
      {
        var responseJson = json.decode(response.body);
        Iterable models = responseJson['data'];
        writeToCache(models);
        entries = models.map((model) => Entry.fromJson(model)).toList();
      }
    } on Exception catch (e) {
      print('error while fetching json ${e.toString()}');
    }
  }

  Future<Entry> fetchSingle(int id) async {
    print("EntryService fetch()");
    try {
      var uri = Uri.https(SERVER_ENDPOINT, READ_API+'/$id');
      var response = await http.get(uri).timeout(Duration(seconds: 10));
      //print('response(${response.statusCode}) = ${response.body}');
      if (response.statusCode == 200)
      {
        var responseJson = json.decode(response.body);
        return Entry.fromJson(responseJson);
      }
    } on Exception catch (e) {
      print('error while fetching json ${e.toString()}');
    }
    return Entry();
  }
}