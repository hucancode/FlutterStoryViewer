
import 'package:flutter/material.dart';
import 'package:pop_experiment/models/prefecture.dart';
import 'package:pop_experiment/services/prefecture_service.dart';

class PrefectureList extends ChangeNotifier {
  List<Prefecture> prefectures = [];

  Future<void> load() async
  {
    prefectures = await PrefectureService().fetch();
    notifyListeners();
  }

  Prefecture readById(int id) => prefectures.firstWhere((element) => element.id == id, orElse: () => Prefecture(id: -1, title: "prefecture $id isn't exist"));
}