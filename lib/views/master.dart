import 'package:flutter/material.dart';
import 'package:pop_experiment/services/entry_service.dart';
import 'package:pop_experiment/services/local_entry_service.dart';
import 'package:pop_experiment/models/profile.dart';
import 'package:pop_experiment/services/filter_service.dart';
import 'package:pop_experiment/services/geofence_history.dart';
import 'package:pop_experiment/services/prefecture_service.dart';
import 'package:pop_experiment/views/navigators/map_navigator.dart';
import 'package:pop_experiment/views/pages/home.dart';
import 'package:pop_experiment/views/navigators/home_navigator.dart';
import 'package:pop_experiment/views/navigators/profile_navigator.dart';

class MasterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MasterPageState();
}

class MasterPageState extends State<MasterPage> {

  HeroController homeHeroController = HeroController(createRectTween: HomePageState.customTween);
  //HeroController qrHeroController;
  //HeroController profileHeroController;

  var homeRef = GlobalKey<NavigatorState>();
  var qrRef = GlobalKey<NavigatorState>();
  var mapRef = GlobalKey<NavigatorState>();
  var profileRef = GlobalKey<NavigatorState>();
  
  final filterProvider = FilterService();
  final entryProvider = EntryService();
  final localEntryProvider = LocalEntryService();
  final geofenceHistoryProvider = GeofenceHistory();
  final prefectureProvider = PrefectureService();
  final profileProvider = Profile();

  int currentTab = 0;

  void selectTab(int index) {
    setState(() {
      currentTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      body: IndexedStack(
        index: currentTab,
        children: [
          HomeNavigator(heroController: homeHeroController),
          MapNavigator(),
          ProfileNavigator(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentTab,
        onTap: selectTab,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Places',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          )
        ],
      ),
    );
    return scaffold;
  }
}
