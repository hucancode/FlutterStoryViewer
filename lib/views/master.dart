import 'package:flutter/material.dart';
import 'package:pop_experiment/services/geofence_helper.dart';
import 'package:pop_experiment/views/navigators/map_navigator.dart';
// import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:pop_experiment/views/pages/home_legacy.dart';
import 'package:pop_experiment/views/navigators/home_navigator.dart';
import 'package:pop_experiment/views/navigators/pm_navigator.dart';
import 'package:pop_experiment/views/navigators/profile_navigator.dart';
import 'package:pop_experiment/views/pages/private_messages.dart';

class MasterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MasterPageState();
}

class MasterPageState extends State<MasterPage> {

  HeroController homeHeroController = HeroController(createRectTween: HomePageState.customTween);
  HeroController pmHeroController = HeroController(createRectTween: PrivateMessagesState.customTween);
  //HeroController qrHeroController;
  //HeroController profileHeroController;

  var homeRef = GlobalKey<NavigatorState>();
  var pmRef = GlobalKey<NavigatorState>();
  var qrRef = GlobalKey<NavigatorState>();
  var mapRef = GlobalKey<NavigatorState>();
  var profileRef = GlobalKey<NavigatorState>();

  int currentTab = 0;

  void selectTab(int index) {
    setState(() {
      currentTab = index;
    });
  }

  @override
  void initState() {
    GeofenceHelper().initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentTab,
        children: <Widget>[
          HomeNavigator(heroController: homeHeroController),
          PrivateMessagesNavigator(heroController: pmHeroController),
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
            icon: Icon(Icons.mail),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          )
        ],
      ),
    );
  }
}
