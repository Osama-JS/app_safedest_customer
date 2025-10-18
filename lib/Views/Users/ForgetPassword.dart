import '../../Globals/MyColors.dart';
import '../../Helpers/Users.dart';
import 'Login.dart';
import 'OTPScreen.dart';
import '../../shared_prff.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../Globals/global_methods.dart' as gm;
import '../../Globals/global.dart' as globals;
import 'package:get/get.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {

  @override
  void initState() {
   super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // User_Helper user = new User_Helper();
  late String email ;

  GlobalKey<FormState> formState =  GlobalKey<FormState>();

  forgetPassword() async{
    var form = formState.currentState;
    if (form!.validate()) {
      form.save();
      if (!await gm.isInternetAvailable()) {
        gm.errorView(context, 'check_internet_connection'.tr);
      } else {
        gm.showDialogLoading(context: context);
        try {
          User_Helper HelperData = new User_Helper();
          var helperdata =
          await HelperData.forgetPassword(email);
          gm.hideLoadingDialog();

          if (helperdata["status"] == 200) {

            globals.email = email;
            globals.isForgetPassword = true;

            Get.to(OTPScreen());
            // print("saeeeeeeeeed done");
          } else {
            Get.snackbar("error".tr, helperdata["message"] );

          }
        } catch (e) {
          gm.hideLoadingDialog();
          gm.sendError("ForgetPassword : $e");

          // print("saeeeeeeeeed error: " + e.toString());
          // Get.snackbar("error".tr, e.toString() );
          Get.snackbar("error".tr, "something_went_wrong".tr);

        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,overlays: [SystemUiOverlay.bottom]);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        Get.back();
        // Get.to(Login());
      },
        child: Scaffold(
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
                child: Form(
                  key: formState,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 20,),
                      Text('recover_password'.tr, style: gm.textHeader(),),
                      Text('enter_email_to_recover_password'.tr, style: gm.textBody(),textAlign: TextAlign.center,),
                      SizedBox(height: 16,),
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        textDirection : TextDirection.ltr,
                        textAlign : TextAlign.left,
                        style: gm.textInput(),
                        decoration: gm.customInputDecoration('email'.tr,Icons.email_outlined),
                        validator: (text) {
                          if (text!.trim().isEmpty) {
                            return "${'email'.tr} ${'is_required'.tr}";
                          }
                          // else if(!text.trim().contains("@gmail.com")){
                          //   return "InvalidEmail".tr;
                          // }
                          return null;
                        },
                        onSaved: (text) {
                          email = text.toString();
                        },
                      ),
                      SizedBox(height: 16,),
                      SizedBox(
                        width: double.maxFinite,
                        child: ElevatedButton(
                          onPressed: () {
                            forgetPassword();
                          },
                          style: gm.buttonStyle(),
                          child: Text('recover_password'.tr,style: gm.textOnPrimaryButton(),),
                        ),
                      ),
                      SizedBox(height: 40,),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}