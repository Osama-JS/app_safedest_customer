import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../Dashboard.dart';
import 'SetPassword.dart';
import 'package:pinput/pinput.dart';
import 'ResetForgettenPassword.dart';
import '../../shared_prff.dart';
import '../../Helpers/Users.dart';
import '../../Globals/global_methods.dart' as gm;
import '../../Globals/MyColors.dart';
import '../../Globals/global.dart' as globals;
import 'package:get/get.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreen();
}

class _OTPScreen extends State<OTPScreen> {

  verifyOTP(var code) async{
    if (!await gm.isInternetAvailable()) {
      gm.errorView(context, 'checkInternetConnection'.tr);
    } else {
      gm.showDialogLoading(context: context);

      try {
        User_Helper HelperData =  User_Helper();
        var helperdata =
        await HelperData.OTPVerification(code,globals.email);
        gm.hideLoadingDialog();

        if (helperdata["status"] == 200) {
          // print("saeeeeeeeeed done"+globals.isForgetPassword.toString()+" bbbnbn");


          if(globals.isForgetPassword==true){
            // print("saeeeeeeeeed doneee1");
            Get.off(SetPassword(code: code,));

          // } else if(globals.isSignUp==true){
          //   // print("saeeeeeeeeed doneee2");
          //
          //   Get.off(SetPassword());
          }else{
            Token_pref.setToken(helperdata["data"]["token"].toString());

            globals.user=await helperdata;

            Get.offAll(()=>Dashboard());

          }



        }else{
          Get.snackbar("error".tr, helperdata["message"] );

        }

      } catch (e) {
        gm.hideLoadingDialog();
        gm.sendError("OTPScreen : $e");

        // print("saeeeeeeeeed error : "+e.toString());
        // Get.snackbar("error".tr, e.toString());
        Get.snackbar("error".tr, "somethingWentWrong".tr);

      }
    }
  }

  resendOTP() async{
    if (!await gm.isInternetAvailable()) {
      gm.errorView(context, 'check_internet_connection'.tr);
    } else {
      gm.showDialogLoading(context: context);

      try {

        User_Helper HelperData =  User_Helper();
        var helperdata =
        await HelperData.resendOTP(globals.email);
        gm.hideLoadingDialog();

        if (helperdata["error"].toString() == "false") {
          // helperdata["data"];

          // print("saeeeeeeeeed done");
          Get.snackbar("success".tr, "code_resent".tr);


        }else{
          Get.snackbar("error".tr, helperdata["message"] );

        }

      } catch (e) {
        gm.hideLoadingDialog();
        // print("saeeeeeeeeed error: "+e.toString());
        // Get.snackbar("error".tr, e.toString() );
        gm.sendError("OTPScreen : $e");

        Get.snackbar("error".tr, "something_went_wrong".tr);

      }
    }
  }
  late String code;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,overlays: [SystemUiOverlay.bottom,SystemUiOverlay.top]);

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
          fontSize: 20,
          color:MyColors.textPrimaryColor,
          fontWeight: FontWeight.bold),
      decoration: BoxDecoration(
        color: MyColors.inputFillColor,
        border: Border.all(color: MyColors.inputBorderColor),
        borderRadius: BorderRadius.circular(20),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: MyColors.primaryColor),
      borderRadius: BorderRadius.circular(8),
    );

    return Scaffold(
        backgroundColor: MyColors.backgroundColor,
        body: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/logo.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 20,),
                  Text('confirm_phone_number'.tr, style: gm.textHeader(),),
                  Text('code_sent_to_number'.tr, style: gm.textBody(),textAlign: TextAlign.center,),
                  // Text('code_sent_to_number'.tr, style: gm.textInput(),textAlign: TextAlign.center,),
                  SizedBox(height: 16,),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Pinput(
                      defaultPinTheme:defaultPinTheme,
                      focusedPinTheme:focusedPinTheme,
                      length: 4,
                      showCursor: true,
                      onCompleted: (pin) =>  code=  pin,
                    ),
                  ),
                  SizedBox(height: 16,),
                  SizedBox(
                    width: double.maxFinite,
                    child: ElevatedButton(
                      onPressed: () {
                        verifyOTP(code);
                      },
                      style: gm.buttonStyle(),
                      child: Text('next'.tr,style: gm.textOnPrimaryButton(),),
                    ),
                  ),
                  SizedBox(height: 8,),
                  SizedBox(
                    width: double.maxFinite,
                    child: ElevatedButton(
                      onPressed: () {
                        resendOTP();
                      },
                      style: gm.buttonSecondaryStyle(),
                      child: Text('resend_code'.tr,style: gm.textButton(),),
                    ),
                  ),
                  SizedBox(height: 40,),
                ],
              ),
            ),
          ],
        ),
    );
  }
}