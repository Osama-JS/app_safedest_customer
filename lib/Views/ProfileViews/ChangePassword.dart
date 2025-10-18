import '../../Dashboard.dart';
import '../../Globals/MyColors.dart';
import '../../Globals/style.dart';
import '../../Helpers/Users.dart';
import '../../shared_prff.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../Globals/global_methods.dart' as gm;
import '../../Globals/global.dart' as globals;
import 'package:get/get.dart';



class ChangePassword extends StatefulWidget {
   const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePassword();
}

class _ChangePassword extends State<ChangePassword> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  RxBool secureText = true.obs;
  RxBool secureText2 = true.obs;
  RxBool secureText3 = true.obs;

  User_Helper user =  User_Helper();

  late String oldPass;
  late String pass;
  late String passconfirm;
  GlobalKey<FormState> formState =  GlobalKey<FormState>();

  void changePassword() async {
    var form = formState.currentState;
    if (form!.validate()) {
      form.save();
      if (!await gm.isInternetAvailable()) {
        gm.errorView(context, 'check_internet_connection'.tr);
      } else {
        gm.showDialogLoading(context: context);

        try {

          var Data = await user.changePassword(oldPass,pass,passconfirm,Token_pref.getToken());
          gm.hideLoadingDialog();

          if (Data["status"] == 200) {
            // Data["data"];

              Get.back();
            // print("Niaaaaaa saeed");
            Get.snackbar("success".tr, Data["message"] );


            // Get.off(Dashboard());


          }else{
            Get.snackbar("error".tr, Data["message"] );
          }
        }catch (e) {

          // print("Niaaaaaaaaaaaaaaaaaaaa error:"+e.toString());

          gm.hideLoadingDialog();
          gm.sendError("ChangePassword : $e");

          Get.snackbar("error".tr, "something_went_wrong".tr);

          // Get.snackbar("error".tr, e.toString());

        }

      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,overlays: [SystemUiOverlay.bottom,SystemUiOverlay.top]);

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
            child: Form(
              key: formState,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 20,),
                  Text('change_password'.tr, style: gm.textHeader(),),
                  SizedBox(height: 8,),
                  Obx(()=> TextFormField(

                    keyboardType: TextInputType.text,

                    style: gm.textInput(),
                    obscureText: secureText3.value,
                    decoration: gm.customInputDecoration('old_password'.tr,Icons.lock).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                            secureText3.value ? Icons.remove_red_eye : Icons
                                .visibility_off,color: MyColors.inputIconColor ),
                        onPressed: () {
                          secureText3.value = !secureText3.value;
                        },
                      ),
                    ),
                    validator: (text) {
                      if (text!.trim().isEmpty) {
                        return "${'old_password'.tr} ${'is_required'.tr}";
                      }
                      // else if(text.trim().length<6){
                      //   return "incorrect_password".tr;
                      // }
                      return null;
                    },
                    onSaved: (text) {
                      oldPass = text.toString();
                    },
                  ),
                  ),
                  SizedBox(height: 15,),
                  Obx(()=> TextFormField(

                      keyboardType: TextInputType.text,

                      style: gm.textInput(),
                      obscureText: secureText.value,
                      decoration: gm.customInputDecoration('new_password'.tr,Icons.lock).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                              secureText.value ? Icons.remove_red_eye : Icons
                                  .visibility_off,color: MyColors.inputIconColor ),
                          onPressed: () {
                              secureText.value = !secureText.value;
                          },
                        ),
                      ),
                      validator: (text) {
                        if (text!.trim().isEmpty) {
                          return "${'new_password'.tr} ${'is_required'.tr}";
                        }
                        // else if(text.trim().length<6){
                        //   return "incorrect_password".tr;
                        // }
                        return null;
                      },
                      onSaved: (text) {
                        pass = text.toString();
                      },
                    ),
                  ),
                  SizedBox(height: 8,),

                  Obx(()=> TextFormField(
                      keyboardType: TextInputType.text,
                      style: gm.textInput(),
                      obscureText: secureText2.value,
                      decoration: gm.customInputDecoration('re_enter_password'.tr,Icons.lock).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                              secureText2.value ? Icons.remove_red_eye : Icons
                                  .visibility_off,color: MyColors.inputIconColor ),
                          onPressed: () {
                              secureText2.value = !secureText2.value;
                          },
                        ),
                      ),
                      validator: (text) {
                        if (text!.trim().isEmpty) {
                          return "${'re_enter_password'.tr} ${'is_required'.tr}";
                        }
                        // else if(text.trim().length<6){
                        //   return "incorrect_password".tr;
                        // }

                        return null;
                      },
                      onSaved: (text) {
                        passconfirm = text.toString();
                      },
                    ),
                  ),
                  SizedBox(height: 8,),
                  SizedBox(
                    width: double.maxFinite,
                    child: ElevatedButton(
                      onPressed: () {
                        changePassword();
                      },
                      style: gm.buttonStyle(),
                      child: Text('save'.tr,style: gm.textOnPrimaryButton(),),
                    ),
                  ),
                  SizedBox(height: 40,),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}
