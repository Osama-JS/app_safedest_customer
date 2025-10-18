import 'dart:ui';
import 'package:get/get.dart';

import '../shared_prff.dart';

class LanguageController extends GetxController{
  Locale selectedLang = Selected_Language.getLanguage()== null ? Locale("ar") : Locale(Selected_Language.getLanguage()!);
  void changeLanguage(var p1){

    Locale local = Locale(p1);
    Selected_Language.setLanguage(p1);
    Get.updateLocale(local);
  }
}