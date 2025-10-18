import 'package:flutter/material.dart';

import '../shared_prff.dart';

class MyColors {

  static const Color onBackgroundColor = Color(0xffF4F5F7);
  static const Color cardBColor = Color(0xffFFEBE5);

  static const Color primaryShadeColor = Color(0xffFFEBE5);
  static const Color textPrimaryColor = Color(0xff172B4D);
  static const Color textSecondaryColor = Color(0xff7A869A);
  static const Color whiteColor = Color(0xffFFFFFF);

  static const Color inputFillColor = Color(0xffF4F5F7);
  static const Color inputBorderColor = Color(0x1A868686);
  static const Color inputBorderErrorColor = Colors.red;
  static const Color inputIconColor = Color(0xff42526E);
  static const Color shimmerColor =  Color(0xFFF4B20A);



  static const Color splashBackgroundColor = Color(0xffFFFFFF);


  static const Color darkPrimaryColor = Color(0xffDE350B);
  static const Color lightPrimaryColor = Color(0xffDE350B);
  static  Color primaryColor = Theme_pref.getTheme()==0?MyColors.lightPrimaryColor:MyColors.darkPrimaryColor;

  static const Color darkBackground = Color(0xffFFFFFF);
  static const Color lightBackground = Color(0xffFFFFFF);
  static  Color backgroundColor = Theme_pref.getTheme()==0?MyColors.lightBackground:MyColors.darkBackground;

  static const Color darkBorder = Color(0xffbdbcbc);
  static const Color lightBorder = Color(0xffbdbcbc);
  static  Color borderColor = Theme_pref.getTheme()==0?MyColors.lightBorder:MyColors.darkBorder;






  static const Color darkFont = Color(0xff000000);
  static const Color lightFont = Color(0xffffffff);
  static  Color fontColor = Theme_pref.getTheme()==0?MyColors.lightFont:MyColors.darkFont;


  static const Color darkAppBar = Color(0xffffffff);
  static const Color lightAppBar = Color(0xffffffff);
  static  Color appBarColor = Theme_pref.getTheme()==0?MyColors.lightAppBar:MyColors.darkAppBar;

  static const Color inputLightFont = Color(0xff000000);
  static const Color inputDarkFont = Color(0xff000000);
  static  Color inputFontColor = Theme_pref.getTheme()==0?MyColors.inputLightFont:MyColors.inputDarkFont;


  static const Color linkColor = Color(0xff9393ff);







  static const Color white_100 = Color(0x1A7F7F7F);



  static const Color shimmerbase = Color(0x345B5A5A);
  static const Color shimmerhighlight = Color(0x345B5A5A);

  static const Color gray = Color(0xffd3cccc);
  static const Color black = Color(0xff000000);
  static const Color yellow = Color(0xffd7da0d);


}