import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pop_experiment/models/entry.dart';
import 'package:pop_experiment/services/server_config.dart';

class EntryService extends ChangeNotifier {
  
  static const LOCAL_CACHE = 'entries.json';
  static const CACHE_MAX_AGE_HOUR = 12;
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
      final uri = Uri.parse('${ServerConfig.ENDPOINT}$READ_API');
      final response = await http.get(uri).timeout(Duration(seconds: ServerConfig.TIMEOUT_IN_SECOND));
      //print('response(${response.statusCode}) = ${response.body}');
      if (response.statusCode == 200)
      {
        var responseJson = json.decode(response.body);
        Iterable models = responseJson['data'];
        writeToCache(models);
        entries = models.map((model) => Entry.fromJson(model)).toList();
        print("EntryService fetch() returns ${entries.length}");
        notifyListeners();
      }
    } on Exception catch (e) {
      print('error while fetching json ${e.toString()}');
    }
  }

  Future<String> fetchContent(int id) async {
    print("EntryService fetchContent()");
    try {
      final uri = Uri.parse('${ServerConfig.ENDPOINT}$READ_API/$id');
      final response = await http.get(uri).timeout(Duration(seconds: ServerConfig.TIMEOUT_IN_SECOND));
      if (response.statusCode == 200)
      {
        final responseJson = json.decode(response.body);
        return responseJson["content"];
      }
    } on Exception catch (e) {
      print('error while fetching content ${e.toString()}');
    }
    return "";
  }

  Future<Entry> fetchSingle(int id) async {
    print("EntryService fetchSingle()");
    try {
      final uri = Uri.parse('${ServerConfig.ENDPOINT}$READ_API/$id');
      final response = await http.get(uri).timeout(Duration(seconds: ServerConfig.TIMEOUT_IN_SECOND));
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