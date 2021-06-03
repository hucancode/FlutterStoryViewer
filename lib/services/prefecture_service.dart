import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pop_experiment/models/prefecture.dart';
import 'package:pop_experiment/services/server_config.dart';

class PrefectureService extends ChangeNotifier {

  static const LOCAL_CACHE = 'prefectures.json';
  static const CACHE_MAX_AGE_HOUR = 12;
  static const READ_API = '/prefecture/read';

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
    print("PrefectureService readFromCache()");
    try {
      final cache = await cacheFile;
      String response = await cache.readAsString();
      Iterable models = json.decode(response);
      prefectures = models.map((model) => Prefecture.fromJson(model)).toList();
    } on Exception catch (e) {
      print('error while fetching json ${e.toString()}');
    }
  }

  Future<void> writeToCache(dynamic jsonData) async {
    final file = await cacheFile;
    file.writeAsString(json.encode(jsonData));
  }

  Future<void> fetch() async {
    print("PrefectureService fetch()");
    try {
      final uri = Uri.parse('${ServerConfig.ENDPOINT}$READ_API');
      final response = await http.get(uri).timeout(Duration(seconds: ServerConfig.TIMEOUT_IN_SECOND));
      //print('response(${response.statusCode}) = ${response.body}');
      if (response.statusCode == 200)
      {
        Iterable models = json.decode(response.body);
        writeToCache(models);
        prefectures = models.map((model) => Prefecture.fromJson(model)).toList();
      }
    } on Exception catch (e) {
      print('error while fetching json ${e.toString()}');
    }
  }

  List<Prefecture> prefectures = [];

  Prefecture readById(int id) => prefectures.firstWhere((element) => element.id == id, orElse: () {
    return prefectures.isNotEmpty?prefectures.first:Prefecture();
  });
}