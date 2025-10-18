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


class ResetForgettenPassword extends StatefulWidget {
  const ResetForgettenPassword({super.key});

  @override
  State<ResetForgettenPassword> createState() => _ResetForgettenPasswordState();
}

class _ResetForgettenPasswordState extends State<ResetForgettenPassword> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool _secureText = true;
  bool _secureText2 = true;

  User_Helper user =  User_Helper();

  late String pass;
  late String passconfirm;
  GlobalKey<FormState> formState = new GlobalKey<FormState>();

  void resetPassword() async {
    var form = formState.currentState;
    if (form!.validate()) {
      form.save();
      if (!await gm.isInternetAvailable()) {
        gm.errorView(
            context, 'check_internet_connection'.tr);
      } else {
        gm.showDialogLoading(context: context);

        try {

          var Data = await user.resetForgettrnPassword(pass,passconfirm,Token_pref.getToken(),globals.notificationToken);
          gm.hideLoadingDialog();

          if (Data["error"].toString() == "false") {
            // Data["data"];
            Token_pref.setToken(Data["data"]["token"].toString());
            globals.user= await Data;
            
            // print("Niaaaaaa saeed");


            // Get.off(Dashboard());
            Get.offAll(()=>Dashboard());


          }else{
            Get.snackbar("error".tr, Data["message"] );
          }
        }catch (e) {
          // print("Niaaaaaaaaaaaaaaaaaaaa error:"+e.toString());

          gm.hideLoadingDialog();
          gm.sendError("ResetForgettenPassword : $e");

          Get.snackbar("error".tr, "something_went_wrong".tr);

          // Get.snackbar("error".tr, e.toString());

        }

      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,overlays: [SystemUiOverlay.bottom,SystemUiOverlay.top]);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult : (bool didPop, Object? result)  async {
      },
      child:Scaffold(
        backgroundColor: MyColors.backgroundColor,
        body: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/auth.png'),
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
                    Text('reset_password'.tr, style: gm.textHeader(),),
                    Text('create_new_password'.tr, style: gm.textBody(),textAlign: TextAlign.center,),
                    SizedBox(height: 8,),
                    TextFormField(
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      keyboardType: TextInputType.number,
                      textDirection : TextDirection.ltr,
                      textAlign : TextAlign.left,
                      style: gm.textInput(),
                      obscureText: _secureText,
                      decoration: gm.customInputDecoration('new_password'.tr,Icons.lock).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(_secureText ? Icons.remove_red_eye : Icons.visibility_off,color: MyColors.inputIconColor ),
                          onPressed: () {
                            setState(() {
                              _secureText = !_secureText;
                            });
                          },
                        ),
                      ),
                      validator: (text) {
                        if (text!.trim().isEmpty) {
                          return "${'new_password'.tr} ${'is_required'.tr}";
                        }else if(text.trim().length<6){
                          return "incorrect_password".tr;
                        }
                        return null;
                      },
                      onSaved: (text) {
                        pass = text.toString();
                      },
                    ),
                    SizedBox(height: 8,),
                    TextFormField(
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      keyboardType: TextInputType.number,
                      textDirection : TextDirection.ltr,
                      textAlign : TextAlign.left,
                      style: gm.textInput(),
                      obscureText: _secureText2,
                      decoration: gm.customInputDecoration('re_enter_password'.tr,Icons.lock).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(_secureText2 ? Icons.remove_red_eye : Icons.visibility_off,color: MyColors.inputIconColor ),
                          onPressed: () {
                            setState(() {
                              _secureText2 = !_secureText2;
                            });
                          },
                        ),
                      ),
                      validator: (text) {
                        if (text!.trim().isEmpty) {
                          return "${'re_enter_password'.tr} ${'is_required'.tr}";
                        }else if(text.trim().length<6){
                          return "incorrect_password".tr;
                        }
                        return null;
                      },
                      onSaved: (text) {
                        passconfirm = text.toString();
                      },
                    ),
                    SizedBox(height: 8,),
                    SizedBox(
                      width: double.maxFinite,
                      child: ElevatedButton(
                        onPressed: () {
                          resetPassword();
                        },
                        style: gm.buttonStyle(),
                        child: Text('update'.tr,style: gm.textOnPrimaryButton(),),
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
