import 'package:flutter/material.dart';
import 'package:pop_experiment/models/profile.dart';
import 'package:pop_experiment/services/entry_service.dart';
import 'package:pop_experiment/services/filter_service.dart';
import 'package:pop_experiment/services/geofence_history.dart';
import 'package:pop_experiment/services/geofence_service.dart';
import 'package:pop_experiment/services/local_entry_service.dart';
import 'package:pop_experiment/services/notification_service.dart';
import 'package:pop_experiment/services/prefecture_service.dart';
import 'package:pop_experiment/views/master.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  final filterProvider = FilterService();
  final entryProvider = EntryService();
  final geofenceProvider = GeofenceService();
  final localEntryProvider = LocalEntryService();
  final geofenceHistoryProvider = GeofenceHistory();
  final prefectureProvider = PrefectureService();
  final profileProvider = Profile();
  
  Future<void> load() async {
    NotificationService().initialize();
    await geofenceProvider.load();
    await profileProvider.load();
    await geofenceHistoryProvider.load();
    await filterProvider.readOrFetch();
    await entryProvider.readOrFetch();
    localEntryProvider.loadWithProvider(
      entryProvider.entries, 
      profileProvider: profileProvider, 
      filterProvider: filterProvider, 
      geofenceHistoryProvider: geofenceHistoryProvider
    );
    await prefectureProvider.load();
  }
  @override
  Widget build(BuildContext context) {
    
    final app = MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MasterPage(),
    );
    final provider = MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: filterProvider),
        ChangeNotifierProvider.value(value: entryProvider),
        ChangeNotifierProvider.value(value: geofenceProvider),
        ChangeNotifierProvider.value(value: localEntryProvider),
        ChangeNotifierProvider.value(value: geofenceHistoryProvider),
        ChangeNotifierProvider.value(value: prefectureProvider),
        ChangeNotifierProvider.value(value: profileProvider),
      ],
      child: app,
    );
    final loadingWidget = Container(
      decoration: BoxDecoration(
        color: Colors.white
      ),
      child: Center(
        child: CircularProgressIndicator()
      )
    );

    final loader = FutureBuilder(
      future: load(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return loadingWidget;
        }
        return provider;
      },
    );
    return loader;
  }
}
