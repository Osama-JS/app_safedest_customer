import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:save_dest_customer/shared_prff.dart';
import 'package:save_dest_customer/splash.dart';
import '../Globals/MyColors.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {


  DateTime? _lastBackPressed;
  late TextDirection textDirection;

  @override
  Widget build(BuildContext context) {
    textDirection = Directionality.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async{
        if(!didPop) {
          DateTime now = DateTime.now();
          if (_lastBackPressed == null ||
              now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
            _lastBackPressed = now;
            Get.snackbar('warning'.tr, 'press_again_to_exit'.tr);
          } else {
            if (Platform.isAndroid) {
              await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            } else if (Platform.isIOS) {
              exit(0);
            }
          }
        }
      },
      child: Scaffold(
        appBar:
        AppBar(
          backgroundColor: MyColors.backgroundColor,
          surfaceTintColor: MyColors.backgroundColor,
leading: IconButton(onPressed: (){
  Token_pref.setToken("");
  Get.offAll(()=>Splash());
}, icon: Icon(Icons.logout)),
          title:Text("welcome_message".tr),
          centerTitle: true,

        ),
        backgroundColor:MyColors.onBackgroundColor,
        body: Center(child: Text("Niaaaaaaaaa"),)
      ),
    );
  }



}