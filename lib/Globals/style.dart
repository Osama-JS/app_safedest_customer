import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../shared_prff.dart';
import 'MyColors.dart';
import 'global_methods.dart' as GM;
InputDecoration customInputDecoration(String ? label,IconData? icon) {
  return InputDecoration(
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide:  BorderSide(color: Theme_pref.getTheme()==0?MyColors.lightBorder:MyColors.darkBorder,),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(
          color: MyColors.lightPrimaryColor,
          width: 1,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(
          color: MyColors.lightPrimaryColor,
          width: 2,
        ),
      ),
      labelStyle: GM.textInput(),
      labelText: label ?? null,
      prefixIcon: icon!=null ? Icon(icon,color:Theme_pref.getTheme()==0?MyColors.inputLightFont:MyColors.inputDarkFont):null
  );
}