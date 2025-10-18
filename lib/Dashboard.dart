import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'Globals/MyColors.dart';

import 'Globals/global.dart' as globals;


import 'package:get/get.dart';

import 'Services/InitialService.dart';
import 'Views/Home.dart';
import 'Views/Maps/MainMap.dart';
import 'Views/ProfileViews/ProfileScreen.dart';
import 'Views/TaskViews/TasksPage.dart';
import 'Views/WalletViews/WalletScreen.dart';

class Dashboard extends StatefulWidget {

  Dashboard({super.key});

  @override
  State<Dashboard> createState() => _Dashboard();
}


class _Dashboard extends State<Dashboard> with WidgetsBindingObserver{
  // String name;
  final iniService = InitialService.to;

  // _Dashboard(this.name);
  DateTime? _currentBackPressTime;

  int pageIndex = globals.dashboardIndex;
  List pages = [];

  @override
  void initState() {

    super.initState();
    WidgetsBinding.instance.addObserver(this);

    pages = [
      MainMap(),
      TasksPage(),
      WalletScreen(),
      ProfileScreenPage(),
      // MainMap(),
      // LandMarksPage(),

    ];


    iniService.userEmail.value=globals.user["data"]["customer"]["email"]??"";
    iniService.userName.value=globals.user["data"]["customer"]["name"]??"";
    iniService.userPhone.value=globals.user["data"]["customer"]["phone"]??"";
    iniService.userImage.value=globals.user["data"]["customer"]["image"]??"";
  }

  @mustCallSuper
  @protected
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   switch (state) {
  //     case AppLifecycleState.resumed:
  //
  //       break;
  //     case AppLifecycleState.paused:
  //       FA.check_noti();
  //       break;
  //     default:
  //       break;
  //   }
  // }



  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,overlays: [SystemUiOverlay.bottom,SystemUiOverlay.top]);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult : (bool didPop, Object? result)  async {
        // DateTime now = DateTime.now();
        // if (_currentBackPressTime == null ||
        //     now.difference(_currentBackPressTime!) > Duration(seconds: 2)) {
        //   _currentBackPressTime = now;
        //   Get.snackbar('warning'.tr, 'pressAgainToExit'.tr);
        // }
        },
      child: SafeArea(
        top: false,
        child: Scaffold(
          body: pages[pageIndex],
          bottomNavigationBar: Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home, Icons.home_outlined, 0, 'home'),
                _buildNavItem(Icons.task, Icons.task_outlined, 1, 'task'),
                _buildNavItem(Icons.wallet, Icons.wallet_outlined, 2, 'wallet'),
                _buildNavItem(Icons.person, Icons.person_outlined, 3, 'profile'),

              ],
            ),
          ),
        )
      ),
    );
  }
  Widget _buildNavItem(IconData activeIcon, IconData inactiveIcon, int index, String label) {
    return InkWell(
      onTap: () {
        setState(() {
          pageIndex = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            pageIndex == index ? activeIcon : inactiveIcon,
            size: 28,
            color: pageIndex == index ? MyColors.primaryColor : Colors.grey,
          ),
          const SizedBox(height: 4),
          Text(
            label.tr,
            style: TextStyle(
              fontSize: 12,
              color: pageIndex == index ? MyColors.primaryColor : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
