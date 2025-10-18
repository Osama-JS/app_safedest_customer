
library my_prj.globals;

import 'package:get/get.dart';




var current_language = 'ar';
var dashboardIndex=0;

  var public_uri = "https://tester.safedest.com/api/customer/";

var token;
var notificationToken;
String email='';
var isForgetPassword=false;
var isSignUp=false;


var user;
String userName= "";
int userId= 0;
String lat = "";
String lng = "";


RxInt selectedCategoryId = 0.obs;


int tabIndex=0;
bool fromHome = false;
bool fromLoginPassword = false;


Map<String, dynamic> stepOnePayload={};
Map<String, dynamic> stepTowPayload={};
