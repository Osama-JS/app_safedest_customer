import 'package:url_launcher/url_launcher.dart';
import '../Widgets/PhoneInputField.dart';
import 'Login.dart';
import 'OTPScreen.dart';
import '../../Globals/MyColors.dart';
import '../../Helpers/Users.dart';
import '../../shared_prff.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../Globals/global_methods.dart' as gm;
import 'package:get/get.dart';
import '../../Globals/global.dart' as globals;

class Register extends StatefulWidget {
  const Register({super.key});
  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  User_Helper user = new User_Helper();

  late String name;
  late String email;
  late String phone;
  late String phoneCode;
  late String password;
  late String confirmPassword;


  RxBool secureText = true.obs;
  RxBool secureText2 = true.obs;
  RxString selectedPhoneCode = "+967".obs;
  List<Map<String, String>> phoneCodes = [{'flag':"ye",'code':"+967"},{'flag':"sa",'code':"+966"},{'flag':"eg",'code':"+20"}];

  GlobalKey<FormState> formState =  GlobalKey<FormState>();
  void startRegister() async {
    var form = formState.currentState;
    if (form!.validate()) {
      form.save();
      if (!await gm.isInternetAvailable()) {
        gm.errorView(context, 'check_internet_connection'.tr);
      }
      else {
        gm.showDialogLoading(context: context);

        try {
          var Data = await user.register(
            name,email, phone,selectedPhoneCode.value,password,confirmPassword,
              globals.notificationToken
          );
          if (Data["status"] == 200) {
            globals.email = email;
            // Data["data"];
            // globals.user= await Data;
            // Token_pref.setToken(Data["data"]["token"].toString());
            // User_pref.setUser(await Data);

            globals.isSignUp=true;
            globals.isForgetPassword= false;
            Get.to(OTPScreen());
          } else {
            Get.snackbar("error".tr, Data["message"]);
          }
        } catch (e) {
          // print("Niaaaaaaaaaaaaaaaaaaaa error:" + e.toString());

          gm.hideLoadingDialog();
          gm.sendError("Register : $e");

          Get.snackbar("error".tr, "something_went_wrong".tr);

          // Get.snackbar("error".tr, e.toString());
        }
      }
    }
  }
  // bool? _isAgreed = false;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,overlays: [SystemUiOverlay.bottom,SystemUiOverlay.top]);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        Get.back();
        // Get.to(Login());
      },
      child: Scaffold(
        backgroundColor:  MyColors.backgroundColor,
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
                    SizedBox(height: 16,),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      style: gm.textInput(),
                      decoration: gm.customInputDecoration('name'.tr,Icons.person),
                      validator: (text) {
                        if (text!.trim().isEmpty) {
                          return "${'name'.tr} ${'is_required'.tr}";
                        }
                        return null;
                      },
                      onSaved: (text) {
                        name = text.toString();
                      },

                    ),
                    SizedBox(height: 8,),
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
                    // TextFormField(
                    //   keyboardType: TextInputType.phone,
                    //   textDirection : TextDirection.ltr,
                    //   textAlign : TextAlign.left,
                    //   // initialValue: "966540632409",
                    //   inputFormatters: [
                    //     FilteringTextInputFormatter.digitsOnly,
                    //     LengthLimitingTextInputFormatter(9),
                    //   ],
                    //   style: gm.textInput(),
                    //   decoration: gm.customInputDecoration('phone_number'.tr,Icons.phone),
                    //   validator: (text) {
                    //     if (text!.trim().isEmpty) {
                    //       return "${'phone_number'.tr} ${'is_required'.tr}";
                    //     }else if(text.trim().substring(0,1)!="7"){
                    //       return "number_must_start_with_7".tr;
                    //     }else if(text.trim().length<9){
                    //       return "incorrect_phone_number".tr;
                    //     }
                    //     return null;
                    //   },
                    //   onSaved: (text) {
                    //     phone = text.toString();
                    //   },
                    //
                    // ),

                    Obx(()=> PhoneInputField(
                        // controller: _phoneController,
                        label: "phone".tr,
                        selectedCountryCode: selectedPhoneCode.value,
                        countryCodes: phoneCodes ?? [],
                        onCountryCodeChanged: (value) {
                          // setState(() {
                          selectedPhoneCode.value = value??'';
                          // });
                        },
                        prefixIcon: Icons.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "${'phone_number'.tr} ${'is_required'.tr}";
                          }
                          return null;
                        },
                      onSaved: (value){
                        phone=value!.trim();
                      },

                      ),
                    ),
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
                    Obx(()=> TextFormField(
                      style: gm.textInput(),

                      keyboardType: TextInputType.text,

                      obscureText: secureText2.value,
                      decoration: gm.customInputDecoration('confirmPassword'.tr,Icons.lock).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(secureText2.value ? Icons.remove_red_eye : Icons.visibility_off,color:MyColors.inputIconColor ),
                          onPressed: () {
                            secureText2.value = !secureText2.value;

                          },
                        ),
                      ),
                      validator: (text) {
                        if (text!.trim().isEmpty) {
                          return "${'confirmPassword'.tr} ${'isRequired'.tr}";
                        }

                        return null;
                      },
                      onSaved: (text) {
                        confirmPassword = text.toString();
                      },



                    ),
                    ),
                    // Row(
                    //   children: [
                    //     Checkbox(
                    //       value: _isAgreed,
                    //       onChanged: (value) {
                    //         setState(() {
                    //           _isAgreed = value;
                    //           // print("niaaaaaaaaa " + _isAgreed.toString());
                    //
                    //
                    //         });
                    //       },
                    //     ),
                    //     Expanded(
                    //       child: GestureDetector(
                    //         onTap: () async{
                    //           // Navigator.pushNamed(context, '/privacyPolicy');
                    //
                    //           final Uri _url = Uri.parse("http://www.nawaam.com/Home/Privacy");
                    //
                    //
                    //           // Future<void> _launchUrl() async {
                    //           if (!await launchUrl(_url)) {
                    //             throw Exception('Could not launch $_url');
                    //             // }
                    //           }
                    //
                    //
                    //         },
                    //         child: Text.rich(
                    //           TextSpan(
                    //             text: 'i_agree_to'.tr,
                    //             children: [
                    //               TextSpan(
                    //                 text: ' ${'privacy_policy'.tr}',
                    //                 style: TextStyle(
                    //                   color: MyColors.primaryColor,
                    //                   // decoration: TextDecoration.underline,
                    //                 ),
                    //               ),
                    //             ],
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    // SizedBox(height: 8,),
                    SizedBox(
                      width: double.maxFinite,
                      child: ElevatedButton(
                        onPressed: () {
                            startRegister();

                        },
                        style: gm.buttonStyle(),
                        child: Text('next'.tr,style: gm.textOnPrimaryButton(),),
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

