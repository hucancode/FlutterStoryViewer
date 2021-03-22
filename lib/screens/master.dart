import 'package:flutter/material.dart';
import 'package:pop_template/screens/navigators/home_navigator.dart';
import 'package:pop_template/screens/navigators/pm_navigator.dart';
import 'package:pop_template/screens/navigators/profile_navigator.dart';
import 'package:pop_template/screens/private_messages.dart';

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
  var profileRef = GlobalKey<NavigatorState>();

  int currentTab = 0;

  void selectTab(int index) {
    setState(() {
      currentTab = index;
    });
  }

  @override
  void initState() {
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
            icon: Icon(Icons.person),
            label: 'Profile',
          )
        ],
      ),
    );
  }
}
