
import 'package:flutter/material.dart';
import 'package:pop_experiment/models/prefecture.dart';
import 'package:pop_experiment/services/prefecture_service.dart';

// TODO: merge services and provider to one, name it as Service

class PrefectureList extends ChangeNotifier {
  List<Prefecture> prefectures = [];

  Future<void> load() async
  {
    prefectures = await PrefectureService().fetch();
    notifyListeners();
  }

  Prefecture readById(int id) => prefectures.firstWhere((element) => element.id == id, orElse: () {
    return prefectures.isNotEmpty?prefectures.first:Prefecture();
  });
}