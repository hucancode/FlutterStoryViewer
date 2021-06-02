import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pop_experiment/models/filter.dart';
import 'package:pop_experiment/services/filter_service.dart';

class FilterList extends ChangeNotifier {
  List<Filter> models = [];

  Future<void> load() async
  {
    models = await FilterService().readOrFetch();
  }

  Filter readById(int id) => models.singleWhere((e) => e.id == id);
}