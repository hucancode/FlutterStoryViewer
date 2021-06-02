import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pop_experiment/models/prefecture.dart';

class PrefectureService {

  static final PrefectureService _instance = PrefectureService._privateConstructor();
  PrefectureService._privateConstructor();

  factory PrefectureService() {
    return _instance;
  }

  static const LOCAL_CACHE = 'prefectures.json';
  static const CACHE_MAX_AGE_HOUR = 12;
  static const SERVER_ENDPOINT = 'pop-ex.atpop.info:3100';
  static const READ_API = '/prefecture/read';

  Future<File> get cacheFile async {
    final directory = await getApplicationDocumentsDirectory();
    final fullPath = '${directory.path}/$LOCAL_CACHE';
    print('cacheFile = $fullPath');
    return File(fullPath);
  }

  Future<List<Prefecture>> readOrFetch() async {
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

  Future<List<Prefecture>> readFromCache() async {
    print("PrefectureService readFromCache()");
    try {
      final cache = await cacheFile;
      String response = await cache.readAsString();
      Iterable models = json.decode(response);
      return models.map((model) => Prefecture.fromJson(model)).toList();
    } on Exception catch (e) {
      print('error while fetching json ${e.toString()}');
    }
    return List<Prefecture>.empty();
  }

  Future<void> writeToCache(dynamic jsonData) async {
    final file = await cacheFile;
    file.writeAsString(json.encode(jsonData));
  }

  Future<List<Prefecture>> fetch() async {
    print("PrefectureService fetch()");
    try {
      var uri = Uri.https(SERVER_ENDPOINT, READ_API);
      var response = await http.get(uri).timeout(Duration(seconds: 10));
      //print('response(${response.statusCode}) = ${response.body}');
      if (response.statusCode == 200)
      {
        Iterable models = json.decode(response.body);
        writeToCache(models);
        return models.map((model) => Prefecture.fromJson(model)).toList();
      }
    } on Exception catch (e) {
      print('error while fetching json ${e.toString()}');
    }
    return List<Prefecture>.empty();
  }
}