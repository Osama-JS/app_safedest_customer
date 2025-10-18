import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Dashboard.dart';
import 'Globals/MyColors.dart';
import 'Helpers/Users.dart';
import 'Views/Users/Login.dart';
import 'Views/Widgets/ProgressWithIcon.dart';
import 'shared_prff.dart';
import 'Globals/global_methods.dart' as global_methods;
import 'Globals/global.dart' as globals;
import 'package:get/get.dart';

class Splash extends StatefulWidget {
  @override
  State<StatefulWidget> createState() =>SplashState();
}

class SplashState extends State<Splash>{

  User_Helper user = new User_Helper();

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  startapp()async{

    messaging.getToken().then((token) {
      if (token != null) {
       globals.notificationToken=token.toString();
       print("MY FCM Token : $token");
      }
    });
    print("saeeeeeeeeeeeeeeeeeeeeed : "+Token_pref.getToken().toString());

    if (!await global_methods.isInternetAvailable()) {
        global_methods.errorView(
            context, 'cannot_continue_without_internet'.tr);

    }

    else if(Token_pref.getToken()==""){

        Get.offAll(()=> Login());

    }
    else {
      try {
        print("saeeeeeeeeeeeeeeeeeeeeed2 : "+Token_pref.getToken().toString());

        var Data = await user.checkToken(Token_pref.getToken());
        if (Data["status"] == 200) {
          globals.user= await Data;
          Get.offAll(()=>Dashboard());
        }else{

            Get.offAll(()=> Login());

        }
      }catch (e) {
        global_methods.sendError("splash : $e");

          Get.offAll(()=> Login());

      }
    }
  }

  @override
  void initState() {
    super.initState();
    if(Selected_Language.getLanguage()== null){
      Selected_Language.setLanguage("ar");
    }

    Future.delayed(const Duration(seconds: 1), () async{
      // Get.to(ReservationPage());
      startapp();
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,overlays: [SystemUiOverlay.bottom,SystemUiOverlay.top]);
    return Scaffold(
        backgroundColor:MyColors.backgroundColor,
        body: const Center(child: ProgressWithIcon(),)
    );
  }
}