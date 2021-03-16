import 'package:flutter/material.dart';
import 'package:pop_template/screens/home.dart';
import 'package:pop_template/screens/navigators/home_navigator.dart';
import 'package:pop_template/screens/navigators/pm_navigator.dart';
import 'package:pop_template/screens/navigators/profile_navigator.dart';
// import 'package:pop_template/screens/navigators/qr_navigator.dart';
import 'package:pop_template/screens/private_messages.dart';

enum TabItem 
{ 
  home, 
  pm, 
  //qr, 
  profile,
}

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

  TabItem currentTab = TabItem.home;

  void selectTab(int index) {
    setState(() {
      currentTab = TabItem.values[index];
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: <Widget>[
        Offstage(
          offstage: currentTab != TabItem.home,
          child: HomeNavigator(navigatorKey: homeRef, heroController: homeHeroController,),
        ),
        Offstage(
          offstage: currentTab != TabItem.pm,
          child: PrivateMessagesNavigator(navigatorKey: pmRef, heroController: pmHeroController,),
        ),
        // Offstage(
        //   offstage: currentTab != TabItem.qr,
        //   child: QRScanNavigator(navigatorKey: qrRef),
        // ),
        Offstage(
          offstage: currentTab != TabItem.profile,
          child: ProfileNavigator(navigatorKey: profileRef),
        ),
      ]),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentTab.index,
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
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.qr_code),
          //   label: 'QR',
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          )
        ],
      ),
    );
  }
}
