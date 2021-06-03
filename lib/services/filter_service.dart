import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pop_experiment/models/filter.dart';
import 'package:pop_experiment/services/server_config.dart';

// TODO: merge services and provider to one, name it as Service

class FilterService  extends ChangeNotifier {

  static const LOCAL_CACHE = 'filters.json';
  static const CACHE_MAX_AGE_HOUR = 12;
  static const READ_API = '/filter/read';

  var filters = List<Filter>.empty(growable: true);
  var ready = true;

  Future<File> get cacheFile async {
    final directory = await getApplicationDocumentsDirectory();
    final fullPath = '${directory.path}/$LOCAL_CACHE';
    print('cacheFile = $fullPath');
    return File(fullPath);
  }

  Future<void> load() async => readOrFetch();

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
    ready = false;
    print("FilterService readFromCache()");
    try {
      final cache = await cacheFile;
      String response = await cache.readAsString();
      Iterable models = json.decode(response);
      filters = models.map((model) => Filter.fromJson(model)).toList();
    } on Exception catch (e) {
      print('error while fetching json ${e.toString()}');
    }
    ready = true;
  }

  Future<void> writeToCache(dynamic jsonData) async {
    final file = await cacheFile;
    file.writeAsString(json.encode(jsonData));
  }

  Future<void> fetch() async {
    ready = false;
    print("FilterService fetch()");
    try {
      final uri = Uri.parse('${ServerConfig.ENDPOINT}$READ_API');
      final response = await http.get(uri).timeout(Duration(seconds: ServerConfig.TIMEOUT_IN_SECOND));
      if (response.statusCode == 200)
      {
        var responseJson = json.decode(response.body);
        //print('responseJson = $responseJson');
        Iterable models = responseJson['data'];
        writeToCache(models);
        filters = models.map((model) => Filter.fromShortJson(model)).toList();
      }
    } on Exception catch (e) {
      print('error while fetching json ${e.toString()}');
    }
    filters.forEach((e) {
      fetchSingleJSON(e.id).then((value) => e.reloadFromJson(value));
    });
    ready = true;
  }

  Future<Map<String, dynamic>> fetchSingleJSON(int id) async {
    //print("FilterService fetchSingleJSON()");
    try {
      final uri = Uri.parse('${ServerConfig.ENDPOINT}$READ_API/$id');
      final response = await http.get(uri).timeout(Duration(seconds: ServerConfig.TIMEOUT_IN_SECOND));
      if (response.statusCode == 200)
      {
        final responseJson = json.decode(response.body);
        responseJson["isFullyLoaded"] = true;
        return responseJson;
      }
    } on Exception catch (e) {
      print('error while fetching json ${e.toString()}');
    }
    return Map<String, dynamic>();
  }

  Future<Filter> fetchSingle(int id) async {
    //print("FilterService fetchSingle()");
    try {
      final responseJson = await fetchSingleJSON(id);
      return Filter.fromJson(responseJson);
    } on Exception catch (e) {
      print('error while fetching json ${e.toString()}');
    }
    return Filter();
  }

  Filter readById(int id) {
    final filter = filters.singleWhere((e) => e.id == id, orElse: () => Filter());
    return filter;
  }
}