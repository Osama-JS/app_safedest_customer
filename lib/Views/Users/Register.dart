import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:save_dest_customer/Views/Widgets/ProgressWithIcon.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Helpers/TaskHelper.dart';
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
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class DynamicFieldModel {
  final int id;
  final String name;
  final String label;
  final String type;
  final bool required;

  RxString textValue;
  Rx<DateTime?> expirationDate;
  RxString fileUrl;

  DynamicFieldModel({
    required this.id,
    required this.name,
    required this.label,
    required this.type,
    required this.required,
    String? initialTextValue,
    DateTime? initialExpirationDate,
    String? initialFileUrl,
  }) : textValue = (initialTextValue ?? '').obs,
        expirationDate = (initialExpirationDate).obs,
        fileUrl = (initialFileUrl ?? '').obs;

  factory DynamicFieldModel.fromTemplateJson(Map<String, dynamic> json) {
    return DynamicFieldModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      label: json['label'] ?? '',
      type: json['type'] ?? 'string',
      required: json['required'] ?? false,
      initialTextValue: '',
      initialFileUrl: '',
      initialExpirationDate: null,
    );
  }
}


class RegisterController extends GetxController {

  final RxList<DynamicFieldModel> additionalFields = <DynamicFieldModel>[].obs;
  List<dynamic>? rawTaskTemplateData; // تم تغيير الاسم

  // 💡 تم تبسيط متغيرات القالب
  // final RxInt selectedTemplateId = (-1).obs;
  // final RxString selectedTemplateName = ''.obs;



  RxBool isLoading = true.obs;
  TaskHelper helperData = TaskHelper();


  void loadInitialData() async {
    try {
      isLoading.value = true;
      var data = await helperData.getAddIni2();

      print("saeeeeeeeeeeedddd : $data");

      rawTaskTemplateData = data['customer_template'];


      _initializeTemplate();
      // if (data["status"] == 200) {
      //   final dataBody = data["data"];
      //
      //   // 💡 الاحتفاظ ببيانات القالب الوحيد مباشرة
      //   rawTaskTemplateData = dataBody['customer_template'];
      //
      //
      //     _initializeTemplate();
      //
      // }
    } catch (e) {
      gm.sendError("RegisterController : $e");
    } finally {
      isLoading.value = false;
    }
  }

  // 💡 دالة تهيئة مهمة جديدة مبسطة
  void _initializeTemplate() {
    if (rawTaskTemplateData != null) {
      // final templateInfo = rawTaskTemplateData!['template'];
      // selectedTemplateId.value = templateInfo['id'] ?? -1;
      // selectedTemplateName.value = templateInfo['name'] ?? '';
      _updateAdditionalFields();
    } else {
      additionalFields.clear();
      // selectedTemplateId.value = -1;
      // selectedTemplateName.value = '';
    }

  }


  // 💡 إزالة دالة changeTemplate واستبدالها بالمنطق المبسّط لـ _updateAdditionalFields
  void _updateAdditionalFields() {
    if (rawTaskTemplateData == null) return;

    final List<dynamic> fieldsJson = rawTaskTemplateData!;

    additionalFields.clear();

    final List<DynamicFieldModel> tempFields = fieldsJson.map((item) => DynamicFieldModel.fromTemplateJson(item)).toList();

    additionalFields.value = tempFields;
  }


  Map<String, dynamic> generatePayload() {

    if (rawTaskTemplateData == null) {
      Get.snackbar("خطأ", "لم يتم تحميل بيانات القالب.", snackPosition: SnackPosition.BOTTOM);
      return {};
    }


    Map<String, dynamic> additionalFieldsPayload = {};
    for (var field in additionalFields) {
      String fileValue = field.fileUrl.value;

      switch (field.type) {
        case 'string':
        case 'text':
        case 'number':
        case 'url':
        case 'date':
          additionalFieldsPayload[field.name] = field.textValue.value;
          break;

        case 'image':
        case 'file': // 💡 إضافة نوع 'file'
          if (field.required && fileValue.isEmpty) {
            // التحقق من الملف فقط إذا كان مطلوباً
            Get.snackbar("خطأ", "ملف ${field.label} مطلوب.", snackPosition: SnackPosition.BOTTOM);
            return {};
          }
          additionalFieldsPayload["${field.name}_file"] = fileValue;
          break;

        case 'file_with_text':
          if (field.required && fileValue.isEmpty) {
            Get.snackbar("خطأ", "ملف ${field.label} مطلوب.", snackPosition: SnackPosition.BOTTOM);
            return {};
          }
          additionalFieldsPayload["${field.name}_file"] = fileValue;
          additionalFieldsPayload["${field.name}_text"] = field.textValue.value;
          break;

        case 'file_expiration_date':
          if (field.required && (fileValue.isEmpty || field.expirationDate.value == null)) {
            Get.snackbar("خطأ", "الملف وتاريخ الانتهاء لـ ${field.label} مطلوبان.", snackPosition: SnackPosition.BOTTOM);
            return {};
          }
          additionalFieldsPayload["${field.name}_file"] = fileValue;
          additionalFieldsPayload["${field.name}_expiration"] = field.expirationDate.value?.toIso8601String().substring(0, 10);
          break;
      }
    }

    return {

      "additional_fields": additionalFieldsPayload,
    };
  }
}



class Register extends StatefulWidget {
  const Register({super.key});
  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  RegisterController controller = Get.put(RegisterController());


  @override
  void initState() {
    super.initState();
    controller.loadInitialData();

  }

  @override
  void dispose() {
    super.dispose();
  }


  Future<void> startRegister1(BuildContext context, Map<String, dynamic> payload, String token) async {
    if (!formState.currentState!.validate()) {
      Get.snackbar("خطأ", "يرجى ملء جميع الحقول المطلوبة بشكل صحيح.", snackPosition: SnackPosition.BOTTOM);
      return;
    }
    formState.currentState!.save();

    String endpoint = "register";


    final url = Uri.parse(globals.public_uri + endpoint);
    print("ddddddddddddddddddddddd:$url");
    if (!await gm.isInternetAvailable()) {
      gm.errorView(context, 'checkInternetConnection'.tr);
      return;
    }







    gm.showDialogLoading(context: context);

    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Language'] = gm.getLanguage();

    request.fields['name'] = name;
    request.fields['email'] = email;
    request.fields['phone'] = phone;
    request.fields['phone_code'] = selectedPhoneCode.value;
    request.fields['confirm-password'] = confirmPassword;
    request.fields['fcm_token'] = globals.notificationToken;

    final Map<String, dynamic> additionalFieldsPayload = payload['additional_fields'];

    Map<String, dynamic> textAndUrlFields = {};

    for (var key in additionalFieldsPayload.keys) {
      var value = additionalFieldsPayload[key];

      if (key.endsWith('_file')) {
        String fileValue = value;

        if (fileValue.isNotEmpty && !fileValue.startsWith('http')) {
          File file = File(fileValue);
          if (await file.exists()) {
            var multipartFile = await http.MultipartFile.fromPath(
              "additional_fields[${key.substring(0, key.length - 5)}]",
              fileValue,
              filename: basename(fileValue),
            );
            request.files.add(multipartFile);
          }
        }
        // else {
        //   textAndUrlFields[key.substring(0, key.length - 5)] = fileValue;
        // }
      } else {
        textAndUrlFields[key] = value.toString();
      }
    }

    if (textAndUrlFields.isNotEmpty) {
      textAndUrlFields.forEach((key, value) {
        request.fields['additional_fields[$key]'] = value.toString();
      });
    }



    try {

      print("niaaaaaaaaaaaaafff${request.fields}");
      http.StreamedResponse streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      var data = jsonDecode(response.body);

      gm.hideLoadingDialog();

      print("API Response: $data");

      if (data["status"] == 200) {
        Get.snackbar("نجاح", "تم التحقق بنجاح", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green);


        globals.email = email;
        // Data["data"];
        // globals.user= await Data;
        // Token_pref.setToken(Data["data"]["token"].toString());
        // User_pref.setUser(await Data);

        globals.isSignUp=true;
        globals.isForgetPassword= false;
        Get.to(OTPScreen());



      } else {
        String errorMessage = data["message"] ?? 'Unknown error';
        if (data["error"] != null) {
          errorMessage += "\n" + data["error"].toString();
        }

        Get.snackbar("خطأ في API", "فشل الإرسال: $errorMessage",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade600,
            colorText: Colors.white);
      }
    } catch (e) {
      print("niaaaaaaaaaaaa$e");

      Get.snackbar("خطأ الإرسال", "حدث خطأ أثناء الاتصال بالخادم: $e",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white);
      gm.hideLoadingDialog();
    }
  }


  User_Helper user =  User_Helper();

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
  // void startRegister() async {
  //   var form = formState.currentState;
  //   if (form!.validate()) {
  //     form.save();
  //     if (!await gm.isInternetAvailable()) {
  //       gm.errorView(context, 'check_internet_connection'.tr);
  //     }
  //     else {
  //       gm.showDialogLoading(context: context);
  //
  //       try {
  //         var Data = await user.register(
  //           name,email, phone,selectedPhoneCode.value,password,confirmPassword,
  //             globals.notificationToken
  //         );
  //         if (Data["status"] == 200) {
  //           globals.email = email;
  //           // Data["data"];
  //           // globals.user= await Data;
  //           // Token_pref.setToken(Data["data"]["token"].toString());
  //           // User_pref.setUser(await Data);
  //
  //           globals.isSignUp=true;
  //           globals.isForgetPassword= false;
  //           Get.to(OTPScreen());
  //         } else {
  //           Get.snackbar("error".tr, Data["message"]);
  //         }
  //       } catch (e) {
  //         // print("Niaaaaaaaaaaaaaaaaaaaa error:" + e.toString());
  //
  //         gm.hideLoadingDialog();
  //         gm.sendError("Register : $e");
  //
  //         Get.snackbar("error".tr, "something_went_wrong".tr);
  //
  //         // Get.snackbar("error".tr, e.toString());
  //       }
  //     }
  //   }
  // }
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
        body: Obx(()=>
            controller.isLoading.value?
                Center(child: ProgressWithIcon()):
            SingleChildScrollView(
              child: Column(
              children: [
                // Expanded(
                //   child: Container(
                //     decoration: BoxDecoration(
                //       image: DecorationImage(
                //         image: AssetImage('assets/images/logo.png'),
                //         fit: BoxFit.cover,
                //       ),
                //     ),
                //   ),
                // ),
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
                        const SizedBox(height: 30),
                        if (controller.additionalFields.isNotEmpty)
                          _buildAdditionalFieldsSection(),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.maxFinite,
                          child: ElevatedButton(
                            onPressed: () {
                                // startRegister();
                              final payload = controller.generatePayload();
              
                              startRegister1(context, payload, Token_pref.getToken()!);
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
        ),
      ),
    );
  }




  Widget _buildAdditionalFieldsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("بيانات القالب الإضافية", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Divider(),
        Obx(() => ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.additionalFields.length,
          itemBuilder: (context, index) {
            final field = controller.additionalFields[index];
            print("niaaaaaaaaaaaaaaaaaaaa fileds page${field.label}");
            return _buildDynamicField(field);
          },
        )),
      ],
    );
  }


  Widget _buildDynamicField(DynamicFieldModel field) {
    switch (field.type) {
      case 'string':
      case 'text': // 💡 إضافة نوع 'text'
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Obx(() => TextFormField(
            initialValue: field.textValue.value,
            keyboardType: TextInputType.text,
            maxLines: field.type == 'text' ? 3 : 1, // إتاحة أسطر متعددة للـ 'text'
            decoration: InputDecoration(
              labelText: field.label,
              border: const OutlineInputBorder(),
            ),
            onChanged: (val) => field.textValue.value = val,
            validator: (val) => (field.required && (val == null || val.isEmpty)) ? "${field.label} مطلوب" : null,
          )),
        );

      case 'number':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Obx(() => TextFormField(
            initialValue: field.textValue.value,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: field.label,
              border: const OutlineInputBorder(),
            ),
            onChanged: (val) => field.textValue.value = val,
            validator: (val) => (field.required && (val == null || val.isEmpty)) ? "${field.label} مطلوب" : null,
          )),
        );

      case 'url': // 💡 إضافة نوع 'url'
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Obx(() => TextFormField(
            initialValue: field.textValue.value,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              labelText: field.label,
              border: const OutlineInputBorder(),
            ),
            onChanged: (val) => field.textValue.value = val,
            validator: (val) {
              if (field.required && (val == null || val.isEmpty)) return "${field.label} مطلوب";
              if (val != null && val.isNotEmpty && !val.startsWith('http')) return "صيغة الرابط غير صحيحة";
              return null;
            },
          )),
        );

      case 'date': // 💡 إضافة نوع 'date'
        return _buildSimpleDatePicker(field);

      case 'image':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(field.label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              _buildFilePicker(field, fileType: FileType.image),
              const SizedBox(height: 10),
            ],
          ),
        );

      case 'file': // 💡 إضافة نوع 'file'
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(field.label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              _buildFilePicker(field),
              const SizedBox(height: 10),
            ],
          ),
        );


      case 'file_with_text':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(field.label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              _buildFilePicker(field),
              const SizedBox(height: 8),
              Obx(() => TextFormField(
                initialValue: field.textValue.value,
                decoration: InputDecoration(
                  labelText: "أدخل ${field.label}",
                  border: const OutlineInputBorder(),
                ),
                onChanged: (val) => field.textValue.value = val,
                validator: (val) => (field.required && (val == null || val.isEmpty)) ? "حقل النص لـ ${field.label} مطلوب" : null,
              )),
              const SizedBox(height: 10),
            ],
          ),
        );

      case 'file_expiration_date':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(field.label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              _buildFilePicker(field),
              const SizedBox(height: 8),
              _buildDatePicker(field),
              const SizedBox(height: 10),
            ],
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

// 💡 دالة جديدة لعرض حقل التاريخ البسيط (date)
  Widget _buildSimpleDatePicker(DynamicFieldModel field) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Obx(() => InkWell(
        onTap: () async {
          final date = await showDatePicker(
            context: Get.context!,
            initialDate: field.expirationDate.value ?? DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime(2050),
          );
          if (date != null) {
            field.textValue.value = date.toString().substring(0, 10);
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: field.label,
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.calendar_today),
            errorText: (field.required && field.textValue.value.isEmpty) ? "${field.label} مطلوب" : null,
          ),
          child: Text(
            field.textValue.value.isNotEmpty
                ? field.textValue.value
                : "اختر تأريخ",
          ),
        ),
      )),
    );
  }

// ... (بقية دوال الـ Widget تبقى كما هي)
  Widget _buildFilePicker(DynamicFieldModel field, {FileType fileType = FileType.custom}) {

    Future<void> _pickFile() async {

      final bool isImage = fileType == FileType.image;

      // تحديد الامتدادات المسموح بها:
      final List<String> extensions = isImage
          ? ['jpg', 'jpeg', 'png'] // لـ type: image
          : ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png']; // لـ type: file_expiration_date أو file_with_text

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        // 🏆 نستخدم FileType.custom دائماً إذا كنا نمرر allowedExtensions
        type: FileType.custom,
        allowedExtensions: extensions, // نمرر القائمة المحددة
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        field.fileUrl.value = filePath;
      }
    }

    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (field.fileUrl.value.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              "الملف المختار: ${field.fileUrl.value.startsWith('http') ? "ملف قديم محفوظ" : field.fileUrl.value.split('/').last}",
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: field.fileUrl.value.startsWith('http') ? Colors.blue.shade700 : Colors.black87,
              ),
            ),
          ),
        Obx(()=> ElevatedButton.icon(
          onPressed: _pickFile,
          icon: Icon(field.fileUrl.value.isEmpty ? Icons.upload_file : Icons.check_circle, color: Colors.white),
          label: Text(field.fileUrl.value.isEmpty ? "اختر ملف" : "تغيير الملف المختار", style: const TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(backgroundColor: field.fileUrl.value.isEmpty ? Colors.blue.shade700 : Colors.green.shade700),
        ),
        ),
        if (field.required)
          Container(
            height: 0,
            width: 0,
            child: TextFormField(
              validator: (val) => field.fileUrl.value.isEmpty ? "${field.label} مطلوب" : null,
              controller: TextEditingController(text: field.fileUrl.value),
            ),
          )
      ],
    ));
  }

  Widget _buildDatePicker(DynamicFieldModel field) {
    return Obx(() => InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: Get.context!,
          initialDate: field.expirationDate.value ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2050),
        );
        if (date != null) {
          field.expirationDate.value = date;
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: "تأريخ الانتهاء",
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
          errorText: (field.required && field.expirationDate.value == null) ? "تأريخ الانتهاء مطلوب" : null,
        ),
        child: Text(
          field.expirationDate.value != null
              ? field.expirationDate.value!.toString().substring(0, 10)
              : "اختر تأريخ الانتهاء",
        ),
      ),
    ));
  }

}

