import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'Globals/MyColors.dart';
import 'theme/app_theme.dart';
import 'theme/app_decorations.dart';

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

class _Dashboard extends State<Dashboard> with WidgetsBindingObserver {
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

    iniService.userEmail.value =
        globals.user["data"]["customer"]["email"] ?? "";
    iniService.userName.value = globals.user["data"]["customer"]["name"] ?? "";
    iniService.userPhone.value =
        globals.user["data"]["customer"]["phone"] ?? "";
    iniService.userImage.value =
        globals.user["data"]["customer"]["image"] ?? "";
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
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top],
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
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
            height: 65,
            decoration: AppDecorations.navigationBarDecoration,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing3,
                  vertical: AppTheme.spacing1,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(Icons.map_outlined, Icons.map, 0, 'home'),
                    _buildNavItem(
                      Icons.assignment_outlined,
                      Icons.assignment,
                      1,
                      'task',
                    ),
                    _buildNavItem(
                      Icons.account_balance_wallet_outlined,
                      Icons.account_balance_wallet,
                      2,
                      'wallet',
                    ),
                    _buildNavItem(
                      Icons.person_outline,
                      Icons.person,
                      3,
                      'profile',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData inactiveIcon,
    IconData activeIcon,
    int index,
    String label,
  ) {
    final bool isSelected = pageIndex == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              pageIndex = index;
            });
          },
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with animated container
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isSelected ? MyColors.primary50 : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isSelected ? activeIcon : inactiveIcon,
                    size: 22,
                    color: isSelected
                        ? MyColors.primaryColor
                        : MyColors.neutral400,
                  ),
                ),
                const SizedBox(height: 2),
                // Label
                Text(
                  label.tr,
                  style: AppTheme.labelSmall.copyWith(
                    color: isSelected
                        ? MyColors.primaryColor
                        : MyColors.neutral400,
                    fontWeight: isSelected
                        ? AppTheme.semiBold
                        : AppTheme.regular,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
