import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'Controllers/NotificationController.dart';
import 'Services/InitialService.dart';
import 'splash.dart';
import 'Languages/LanguageController.dart';
import 'Languages/Messages.dart';
import 'shared_prff.dart';
import 'firebase_options.dart';

// flutter build apk --split-per-abi
void main() async{
  WidgetsFlutterBinding.ensureInitialized();






  await Selected_Language.init();
  await Theme_pref.init();
  await Token_pref.init();
  await User_pref.init();
  await Bool_pref.init();


  await dotenv.load(fileName: ".env");
  MapboxOptions.setAccessToken(dotenv.env["MAP_ACCESS_TOKEN"]!);


  WidgetsFlutterBinding.ensureInitialized();

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler) ;
  Get.put(NotificationController());
  await Get.putAsync(() async => InitialService());

  runApp(  MyApp());
}
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Background Notifications Received : ${message.notification?.title}" ) ;
  // final controller = Get.find<NotificationController>();
  // await controller.addNotification({
  //   "title": message.notification?.title ?? "No Title",
  //   "body": message.notification?.body ?? "No Body",
  //   "time": DateTime.now(),
  // });
}


class MyApp extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    LanguageController languageController = Get.put(LanguageController());

    // TODO: implement build
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      locale: languageController.selectedLang,
      translations: Messages(),
      theme: ThemeData(
          fontFamily:"Tajawal"
      ),
      getPages:[
        GetPage(name: "/", page: ()=> Splash()),
      ]


    );
  }
}


