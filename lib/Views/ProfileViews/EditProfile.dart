import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide MultipartFile, FormData;
import '../../../Globals/MyColors.dart';
import '../../../shared_prff.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../Globals/global_methods.dart' as global_methods;
import '../../Globals/global.dart' as globals;
import '../../Helpers/Users.dart';
import '../../Services/InitialService.dart';
import '../Widgets/PhoneInputField.dart';
import '../Widgets/custom_image_view.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final iniService = InitialService.to;
  TextEditingController nameController = TextEditingController();
  TextEditingController companyController = TextEditingController();
  TextEditingController companyAddressController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  File? _image;


  RxString selectedPhoneCode = "+967".obs;
  List<Map<String, String>> phoneCodes = [{'flag':"ye",'code':"+967"},{'flag':"sa",'code':"+966"},{'flag':"eg",'code':"+20"}];


  @override
  void initState() {
    super.initState();
    nameController.text=iniService.userName.value;
    phoneController.text=iniService.userPhone.value;
    selectedPhoneCode.value=globals.user["data"]["customer"]["phone_code"]??"";
    companyController.text=globals.user["data"]["customer"]["company_name"]??"";
    companyAddressController.text=globals.user["data"]["customer"]["company_address"]??"";
  }

  User_Helper helperData =  User_Helper();

  void updateProfile() async {
    var form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      if (!await global_methods.isInternetAvailable()) {
        global_methods.errorView(
            context, 'check_internet'.tr);
      } else {
        global_methods.showDialogLoading(context: context);



        try {
          var data = await helperData.updateProfile(nameController.text,phoneController.text,
              selectedPhoneCode.value,companyController.text,companyAddressController.text              ,Token_pref.getToken());
          global_methods.hideLoadingDialog();

          if (data["status"] == 200) {
            // Data["data"];

            Token_pref.setToken(data["data"]["token"].toString());

            globals.user=await data;
            Get.snackbar("success".tr, data["message"] );

            iniService.userName.value=globals.user["data"]["customer"]["name"];
            iniService.userPhone.value=globals.user["data"]["customer"]["phone"];

            nameController.text=iniService.userName.value;
            phoneController.text=iniService.userPhone.value;
            selectedPhoneCode.value=globals.user["data"]["customer"]["phone_code"];
            companyController.text=globals.user["data"]["customer"]["company_name"];
            companyAddressController.text=globals.user["data"]["customer"]["company_address"];

          }else{
            Get.snackbar("error".tr, data["message"] );

          }
        }catch (e) {
          global_methods.hideLoadingDialog();
          global_methods.sendError("${'update_profile'.tr} : $e");

          Get.snackbar("error".tr, "something_wrong".tr);

          // Get.snackbar("error".tr, e.toString() );

        }

      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: MyColors.primaryColor,
        leadingWidth: 60,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsetsDirectional.only(start: 16.0),
          child: IconButton(
            onPressed: () {
             Get.back();
            },
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
        ),
        title: Text("personal_information".tr, style: const TextStyle(color: Colors.white)),
      ),
      resizeToAvoidBottomInset: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                width: double.maxFinite,
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: MyColors.primaryColor,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(5)),
                ),
              ),
              Container(
                width: double.maxFinite,
                alignment: Alignment.center,
                padding: const EdgeInsets.only(top: 20),
                child: Stack(
                  children: [
                    Obx(()=> Container(
                        height: 74,
                        width: 74,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          border: Border.all(color: MyColors.borderColor.withAlpha(90),
                          ),
                          color: Colors.white,
                          shape: BoxShape.circle,
                          // borderRadius: BorderRadius.circular(50),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 10,
                                offset: Offset(0, 10),
                              ),
                            ],

                        ),
                        child:iniService.userImage.value != ""
                            ?
                        CustomImageView(
                          imagePath:  iniService.userImage.value ,
                          height: 48,
                          width: 48,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          onTap: () {

                          },
                        )

                        // Image.network(
                        //   iniService.userImage.value,
                        //   fit: BoxFit.cover,
                        // )
                            :
                        Icon(Icons.person, size: 38,
                          color: MyColors.primaryColor,)
                      ),
                    ),


                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                width: double.maxFinite,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextButton(
                        onPressed: () {
                          pickImage();
                          // _pickAndCropImage(context);
                        },
                        child: Text(
                          "change_profile_picture".tr,
                          style: global_methods.textPrimaryBody(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: nameController,
                        keyboardType: TextInputType.text,
                        // initialValue:  iniService.userName.value??'',
                        style: global_methods.textInput(),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide:  BorderSide(color: MyColors.borderColor,),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: BorderSide(
                              color: MyColors.primaryColor,
                              width: 1,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 1.5,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: const BorderSide(
                              color: Colors.redAccent,
                              width: 2,
                            ),
                          ),
                          labelStyle: global_methods.textInput(),
                          labelText: 'name'.tr,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Obx(()=> PhoneInputField2(
                        controller: phoneController,
                        label: "phone_number".tr,
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


                      ),
                      ),

                      const SizedBox(height: 10),
                      TextFormField(
                        controller: companyController,
                        keyboardType: TextInputType.text,
                        // initialValue:  iniService.userName.value??'',
                        style: global_methods.textInput(),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide:  BorderSide(color: MyColors.borderColor,),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: BorderSide(
                              color: MyColors.primaryColor,
                              width: 1,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 1.5,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: const BorderSide(
                              color: Colors.redAccent,
                              width: 2,
                            ),
                          ),
                          labelStyle: global_methods.textInput(),
                          labelText: 'company_name'.tr,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: companyAddressController,
                        keyboardType: TextInputType.text,
                        // initialValue:  iniService.userName.value??'',
                        style: global_methods.textInput(),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide:  BorderSide(color: MyColors.borderColor,),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: BorderSide(
                              color: MyColors.primaryColor,
                              width: 1,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 1.5,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: const BorderSide(
                              color: Colors.redAccent,
                              width: 2,
                            ),
                          ),
                          labelStyle: global_methods.textInput(),
                          labelText: 'company_address'.tr,
                        ),
                      ),


                      const SizedBox(height: 30),
                       Obx(()=>

                       isUploading.value
                           ? const CircularProgressIndicator()
                           :
                       SizedBox(
                           width: double.maxFinite,
                           child:  ElevatedButton(
                             onPressed: () async {
                               updateProfile();
                             },
                             style: global_methods.buttonStyle(),
                             child: Text(
                               'save'.tr,
                               style: global_methods.textButton(),
                             ),
                           )),

                       ),

                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<bool> checkPermission() async {
    if (Platform.isAndroid) {
      // للاندرويد 13+ (API 33)
      if (await Permission.photos.request().isGranted) {
        return true;
      }

      // للاندرويد القديم
      final status = await Permission.storage.request();
      return status.isGranted;
    } else if (Platform.isIOS) {
      // للآيفون
      final status = await Permission.photos.request();
      return status.isGranted;
    }
    return false;
  }


  pickImage() async{
    try {



        if (await Permission.photos.request().isDenied) {
          final status = await Permission.storage.request();
          if(status.isDenied){
            return;
          }
        }else if (await Permission.photos.request().isPermanentlyDenied) {
          await global_methods.showPermissionDeniedDialog(context, "storage_permission_required".tr);
          return;
        }

      print("picker");
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _image = File(pickedFile.path);

        uploadImage();
      }
    }catch(e){
      throw "error";
    }
  }


  RxBool isUploading = false.obs;

  void uploadImage() async {

      if (!await global_methods.isInternetAvailable()) {
        global_methods.errorView(
            context, 'check_internet'.tr);
      } else {
        isUploading.value=true;

        global_methods.showDialogLoading(context: context);



        try {


          var data = await helperData.updateAvatar(_image,Token_pref.getToken());
          isUploading.value=false;

          global_methods.hideLoadingDialog();

          if (data["status"] == 200) {



            Get.snackbar("success".tr, data["message"] );
            iniService.userImage.value=data["avatar_url"];


          }else{
            Get.snackbar("error".tr, data["message"] );
          }
        }catch (e) {
          isUploading.value=false;

          global_methods.hideLoadingDialog();
          global_methods.sendError("UpdateProfile : $e");

          // Get.snackbar("error".tr, e.toString());
          Get.snackbar("error".tr, "something_wrong".tr);


        }

      }



  }

}

