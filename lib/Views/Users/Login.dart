import 'dart:io';
import '../../Dashboard.dart';
import '../../Globals/style.dart';
import '../../Globals/MyColors.dart';
import '../../Helpers/Users.dart';
import '../../shared_prff.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../Globals/global_methods.dart' as gm;
import 'package:get/get.dart';
import 'ForgetPassword.dart';
import 'OTPScreen.dart';
import 'Register.dart';
import '../../Globals/global.dart' as globals;

class Login extends StatefulWidget {
  final bool canPop;

  const Login({Key? key, this.canPop = false}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  @override
  void initState() {
   super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  RxBool secureText = true.obs;

  User_Helper user =  User_Helper();

  late String email ;
  late String password ;
  GlobalKey<FormState> formState =  GlobalKey<FormState>();

  void startLogin() async {
    var form = formState.currentState;
    if (form!.validate()) {
      form.save();
      if (!await gm.isInternetAvailable()) {
        gm.errorView(
            context, 'checkInternetConnection'.tr);
      } else {
        gm.showDialogLoading(context: context);



        try {
          var Data = await user.login(email,password,globals.notificationToken);
          gm.hideLoadingDialog();

          if (Data["status"] == 200) {
            // Data["data"];

            Token_pref.setToken(Data["data"]["token"].toString());

            globals.user=await Data;

            Get.offAll(()=>Dashboard());

          }else{
            Get.snackbar("error".tr, Data["message"] );

          }
        }catch (e) {
          gm.hideLoadingDialog();
          gm.sendError("Login : $e");

          Get.snackbar("error".tr, "somethingWentWrong".tr);

          // Get.snackbar("error".tr, e.toString() );

        }

        }
        }
      }


  DateTime? _lastBackPressed;

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,overlays: [SystemUiOverlay.bottom,SystemUiOverlay.top]);

    return PopScope(
      canPop: widget.canPop,
      onPopInvokedWithResult: (bool didPop, dynamic result) async{
        if(!didPop) {
          globals.fromLoginPassword=false;

          if(widget.canPop){
            Get.back();
          }else{
            DateTime now = DateTime.now();
            if (_lastBackPressed == null ||
                now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
              _lastBackPressed = now;
              Get.snackbar('warning'.tr, 'press_again_to_exit'.tr);
            } else {
              if (Platform.isAndroid) {
                await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
              } else if (Platform.isIOS) {
                exit(0);
              }
            }
          }


        }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
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

                      TextButton(
                          onPressed: () {
                            Get.to(Register());
                          },
                          child: Text('welcome_back_create'.tr, style: TextStyle(color: MyColors.primaryColor, fontSize: 16 , fontWeight: FontWeight.bold)
                          )
                      ),
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
                      SizedBox(height: 8,),
                      Obx(()=> TextFormField(
                          style: gm.textInput(),
                          keyboardType: TextInputType.text,

                          obscureText: secureText.value,
                          decoration: gm.customInputDecoration('password'.tr,Icons.lock).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(secureText.value ? Icons.remove_red_eye : Icons.visibility_off,color:MyColors.inputIconColor ),
                              onPressed: () {
                                  secureText.value = !secureText.value;

                              },
                            ),
                          ),
                          validator: (text) {
                            if (text!.trim().isEmpty) {
                              return "${'password'.tr} ${'isRequired'.tr}";
                            }

                            return null;
                          },
                          onSaved: (text) {
                            password = text.toString();
                          },



                        ),
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        child: TextButton(
                          onPressed: () {
                            Get.to(ForgetPassword());
                            // email_action();
                          },
                          child: Text('forgot_password'.tr,
                              style: TextStyle(color: MyColors.primaryColor, fontSize: 15 , fontWeight: FontWeight.bold)
                          ),
                        ),
                      ),

                      SizedBox(height: 8,),
                      SizedBox(
                        width: double.maxFinite,
                        child: ElevatedButton(
                          onPressed: () {
                            startLogin();
                          },
                          style: gm.buttonStyle(),
                          child: Text('login'.tr,style: gm.textOnPrimaryButton(),),
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
