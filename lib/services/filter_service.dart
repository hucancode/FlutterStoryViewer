import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pop_experiment/models/filter.dart';
import 'package:pop_experiment/services/server_config.dart';

class FilterService {

  static const LOCAL_CACHE = 'filters.json';
  static const CACHE_MAX_AGE_HOUR = 12;
  static const READ_API = '/filter/read';
  static const CREATE_API = '/filter/create';
  static const UPDATE_API = '/filter/update';

  static final FilterService _instance = FilterService._privateConstructor();
  FilterService._privateConstructor();

  factory FilterService() {
    return _instance;
  }

  Future<File> get cacheFile async {
    final directory = await getApplicationDocumentsDirectory();
    final fullPath = '${directory.path}/$LOCAL_CACHE';
    print('cacheFile = $fullPath');
    return File(fullPath);
  }

  Future<List<Filter>> readOrFetch() async {
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

  Future<List<Filter>> readFromCache() async {
    print("GeofenceHelper readFromCache()");
    try {
      final cache = await cacheFile;
      String response = await cache.readAsString();
      Iterable it = json.decode(response);
      return List<Filter>.from(it.map((model) => Filter.fromJson(model)));
    } on Exception catch (e) {
      print('error while fetching json ${e.toString()}');
    }
    return List<Filter>.empty();
  }

  Future<void> writeToCache(dynamic jsonData) async {
    final file = await cacheFile;
    file.writeAsString(jsonEncode(jsonData));
  }

  Future<List<Filter>> fetch() async {
    print("FilterFetcher fetch()");
    try {
      final uri = Uri.parse('${ServerConfig.ENDPOINT}$READ_API');
      final response = await http.get(uri).timeout(Duration(seconds: ServerConfig.TIMEOUT_IN_SECOND));
      if (response.statusCode == 200)
      {
        final responseJson = jsonDecode(response.body);
        Iterable models = responseJson['data'];
        print('FilterFetcher, got ${models.length}');
        return models.map((model) => Filter.fromShortJson(model)).toList();
      }
    } on Exception catch (e) {
      print('error while fetching json ${e.toString()}');
    }
    return List<Filter>.empty();
  }

  Future<Filter> fetchSingle(int id) async {
    print("FilterFetcher fetch()");
    try {
      final uri = Uri.parse('${ServerConfig.ENDPOINT}$READ_API/$id');
      final response = await http.get(uri).timeout(Duration(seconds: ServerConfig.TIMEOUT_IN_SECOND));
      if (response.statusCode == 200)
      {
        final responseJson = jsonDecode(response.body);
        return Filter.fromJson(responseJson);
      }
    } on Exception catch (e) {
      print('error while fetching json ${e.toString()}');
    }
    return Filter();
  }
}