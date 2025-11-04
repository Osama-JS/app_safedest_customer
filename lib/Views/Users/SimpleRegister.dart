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
import 'package:path/path.dart' as path;
import '../../theme/app_theme.dart';
import '../../Views/Widgets/CustomTextField.dart';
import '../../Views/Widgets/CustomButton.dart';

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
  List<dynamic>? rawTaskTemplateData;

  // حقول الشركة الاختيارية
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController companyAddressController =
      TextEditingController();

  RxBool isLoading = true.obs;
  TaskHelper helperData = TaskHelper();

  void loadInitialData() async {
    try {
      isLoading.value = true;
      var data = await helperData.getAddIni2();

      print("saeeeeeeeeeeedddd : $data");

      rawTaskTemplateData = data['customer_template'];

      _initializeTemplate();
    } catch (e) {
      gm.sendError("RegisterController : $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _initializeTemplate() {
    if (rawTaskTemplateData != null) {
      _updateAdditionalFields();
    } else {
      additionalFields.clear();
    }
  }

  void _updateAdditionalFields() {
    if (rawTaskTemplateData == null) return;

    final List<dynamic> fieldsJson = rawTaskTemplateData!;

    additionalFields.clear();

    final List<DynamicFieldModel> tempFields = fieldsJson
        .map((item) => DynamicFieldModel.fromTemplateJson(item))
        .toList();

    additionalFields.value = tempFields;
  }

  Map<String, dynamic> generatePayload() {
    if (rawTaskTemplateData == null) {
      Get.snackbar(
        "error_title".tr,
        "template_data_not_loaded".tr,
        snackPosition: SnackPosition.BOTTOM,
      );
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
        case 'file':
          if (field.required && fileValue.isEmpty) {
            Get.snackbar(
              "error_title".tr,
              "file_required".trParams({'field': field.label}),
              snackPosition: SnackPosition.BOTTOM,
            );
            return {};
          }
          additionalFieldsPayload["${field.name}_file"] = fileValue;
          break;

        case 'file_with_text':
          if (field.required && fileValue.isEmpty) {
            Get.snackbar(
              "error_title".tr,
              "file_required".trParams({'field': field.label}),
              snackPosition: SnackPosition.BOTTOM,
            );
            return {};
          }
          additionalFieldsPayload["${field.name}_file"] = fileValue;
          additionalFieldsPayload["${field.name}_text"] = field.textValue.value;
          break;

        case 'file_expiration_date':
          if (field.required &&
              (fileValue.isEmpty || field.expirationDate.value == null)) {
            Get.snackbar(
              "error_title".tr,
              "file_and_expiration_required".trParams({'field': field.label}),
              snackPosition: SnackPosition.BOTTOM,
            );
            return {};
          }
          additionalFieldsPayload["${field.name}_file"] = fileValue;
          additionalFieldsPayload["${field.name}_expiration"] = field
              .expirationDate
              .value
              ?.toIso8601String()
              .substring(0, 10);
          break;
      }
    }

    // إضافة حقول الشركة الاختيارية
    Map<String, dynamic> payload = {
      "additional_fields": additionalFieldsPayload,
    };

    if (companyNameController.text.isNotEmpty) {
      payload["c_name"] = companyNameController.text;
    }

    if (companyAddressController.text.isNotEmpty) {
      payload["c_address"] = companyAddressController.text;
    }

    return payload;
  }
}

class SimpleRegister extends StatefulWidget {
  const SimpleRegister({super.key});
  @override
  State<SimpleRegister> createState() => _SimpleRegisterState();
}

class _SimpleRegisterState extends State<SimpleRegister>
    with TickerProviderStateMixin {
  RegisterController controller = Get.put(RegisterController());
  late TabController _tabController;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentStep = _tabController.index;
      });
    });
    controller.loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (!formState.currentState!.validate()) {
      Get.snackbar(
        "error_title".tr,
        "fill_all_required_fields".tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    formState.currentState!.save();
    if (_currentStep < 2) {
      _tabController.animateTo(_currentStep + 1);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _tabController.animateTo(_currentStep - 1);
    }
  }

  void _register() {
    final payload = controller.generatePayload();
    startRegister1(context, payload, Token_pref.getToken()!);
  }

  User_Helper user = User_Helper();

  // Text Controllers for form fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  RxBool secureText = true.obs;
  RxBool secureText2 = true.obs;
  RxString selectedPhoneCode = "+967".obs;
  List<Map<String, String>> phoneCodes = [
    {'flag': "ye", 'code': "+967"},
    {'flag': "sa", 'code': "+966"},
    {'flag': "eg", 'code': "+20"},
  ];

  GlobalKey<FormState> formState = GlobalKey<FormState>();

  Future<void> startRegister1(
    BuildContext context,
    Map<String, dynamic> payload,
    String token,
  ) async {
    if (!formState.currentState!.validate()) {
      Get.snackbar(
        "error_title".tr,
        "fill_all_required_fields".tr,
        snackPosition: SnackPosition.BOTTOM,
      );
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

    request.fields['name'] = nameController.text;
    request.fields['email'] = emailController.text;
    request.fields['phone'] = phoneController.text;
    request.fields['phone_code'] = selectedPhoneCode.value;
    request.fields['password'] = passwordController.text;
    request.fields['confirm-password'] = confirmPasswordController.text;
    request.fields['fcm_token'] = globals.notificationToken;

    // إضافة حقول الشركة إذا كانت موجودة
    if (payload.containsKey('c_name')) {
      request.fields['c_name'] = payload['c_name'];
    }
    if (payload.containsKey('c_address')) {
      request.fields['c_address'] = payload['c_address'];
    }

    final Map<String, dynamic> additionalFieldsPayload =
        payload['additional_fields'];

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
              filename: path.basename(fileValue),
            );
            request.files.add(multipartFile);
          }
        }
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
        Get.snackbar(
          "success_title".tr,
          "verification_successful".tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
        );

        globals.email = emailController.text;

        globals.isSignUp = true;
        globals.isForgetPassword = false;
        Get.to(OTPScreen());
      } else {
        String errorMessage = data["message"] ?? 'Unknown error';
        if (data["error"] != null) {
          errorMessage += "\n" + data["error"].toString();
        }

        Get.snackbar(
          "api_error".tr,
          "${'send_failed'.tr}: $errorMessage",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("niaaaaaaaaaaaa$e");

      Get.snackbar(
        "send_error".tr,
        "${'server_connection_error'.tr}: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
      gm.hideLoadingDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top],
    );

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        Get.back();
      },
      child: Scaffold(
        backgroundColor: MyColors.backgroundColor,
        appBar: AppBar(
          title: Text('create_account'.tr),
          backgroundColor: MyColors.backgroundColor,
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            labelColor: MyColors.primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: MyColors.primaryColor,
            tabs: [
              Tab(text: 'basic_data'.tr),
              Tab(text: 'additional_info'.tr),
              Tab(text: 'review_confirm'.tr),
            ],
          ),
        ),
        body: Obx(
          () => controller.isLoading.value
              ? Center(child: ProgressWithIcon())
              : Column(
                  children: [
                    // Progress indicator
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          for (int i = 0; i < 3; i++) ...[
                            Expanded(
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: i <= _currentStep
                                      ? MyColors.primaryColor
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            if (i < 2) const SizedBox(width: 8),
                          ],
                        ],
                      ),
                    ),

                    // TabBarView content
                    Expanded(
                      child: Form(
                        key: formState,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildBasicInfoTab(),
                            _buildAdditionalInfoTab(),
                            _buildReviewTab(),
                          ],
                        ),
                      ),
                    ),

                    // Navigation buttons
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          if (_currentStep > 0)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _previousStep,
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: MyColors.primaryColor,
                                  ),
                                ),
                                child: Text(
                                  'previous'.tr,
                                  style: TextStyle(
                                    color: MyColors.primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          if (_currentStep > 0) const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _currentStep == 2
                                  ? _register
                                  : _nextStep,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: MyColors.primaryColor,
                                foregroundColor: Colors.white,
                              ),
                              child: Text(
                                _currentStep == 2
                                    ? 'create_account'.tr
                                    : 'next'.tr,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // التاب الأول: البيانات الأساسية
  Widget _buildBasicInfoTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'basic_data'.tr,
          style: AppTheme.headlineSmall.copyWith(
            color: MyColors.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        _buildRegistrationForm(),
      ],
    );
  }

  // التاب الثاني: المعلومات الإضافية
  Widget _buildAdditionalInfoTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'additional_info'.tr,
          style: AppTheme.headlineSmall.copyWith(
            color: MyColors.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        _buildCompanyFieldsSection(),
        if (controller.additionalFields.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildAdditionalFieldsSection(),
        ],
      ],
    );
  }

  // التاب الثالث: مراجعة البيانات
  Widget _buildReviewTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'review_confirm'.tr,
          style: AppTheme.headlineSmall.copyWith(
            color: MyColors.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        _buildReviewContent(),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const SizedBox(height: 20),

        // Logo
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: MyColors.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(60),
          ),
          child: Icon(Icons.person_add, size: 60, color: MyColors.primaryColor),
        ),

        const SizedBox(height: 24),

        // Title
        Text(
          'joinSafeDestFamily'.tr,
          style: AppTheme.headlineMedium.copyWith(
            color: MyColors.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        // Subtitle
        Text(
          'createAccountToGetStarted'.tr,
          style: AppTheme.bodyLarge.copyWith(
            color: MyColors.textSecondaryColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRegistrationForm() {
    return Column(
      children: [
        // Name Field
        TextFormField(
          controller: nameController,
          keyboardType: TextInputType.text,
          style: gm.textInput(),
          decoration: gm.customInputDecoration('name'.tr, Icons.person),
          validator: (text) {
            if (text!.trim().isEmpty) {
              return "${'name'.tr} ${'is_required'.tr}";
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Email Field
        TextFormField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.left,
          style: gm.textInput(),
          decoration: gm.customInputDecoration(
            'email'.tr,
            Icons.email_outlined,
          ),
          validator: (text) {
            if (text!.trim().isEmpty) {
              return "${'email'.tr} ${'is_required'.tr}";
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Phone Field
        Obx(
          () => PhoneInputField2(
            controller: phoneController,
            label: "phone".tr,
            selectedCountryCode: selectedPhoneCode.value,
            countryCodes: phoneCodes,
            onCountryCodeChanged: (value) {
              selectedPhoneCode.value = value ?? '';
            },
            prefixIcon: Icons.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "${'phone_number'.tr} ${'is_required'.tr}";
              }
              return null;
            },
            // onSaved: (value) {
            //   phoneController.text = value!.trim();
            // },
          ),
        ),

        const SizedBox(height: 16),

        // Password Field
        Obx(
          () => TextFormField(
            controller: passwordController,
            style: gm.textInput(),
            keyboardType: TextInputType.text,
            obscureText: secureText.value,
            decoration: gm
                .customInputDecoration('password'.tr, Icons.lock)
                .copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      secureText.value
                          ? Icons.remove_red_eye
                          : Icons.visibility_off,
                      color: MyColors.inputIconColor,
                    ),
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
          ),
        ),

        const SizedBox(height: 16),

        // Confirm Password Field
        Obx(
          () => TextFormField(
            controller: confirmPasswordController,
            style: gm.textInput(),
            keyboardType: TextInputType.text,
            obscureText: secureText2.value,
            decoration: gm
                .customInputDecoration('confirmPassword'.tr, Icons.lock)
                .copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      secureText2.value
                          ? Icons.remove_red_eye
                          : Icons.visibility_off,
                      color: MyColors.inputIconColor,
                    ),
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
          ),
        ),
      ],
    );
  }

  Widget _buildCompanyFieldsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "company_information".tr,
          style: AppTheme.headlineSmall.copyWith(
            color: MyColors.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),

        // حقل اسم الشركة
        CustomTextField(
          controller: controller.companyNameController,
          label: "company_name".tr,
          hint: "company_name".tr,
          prefixIcon: Icons.business,
        ),
        const SizedBox(height: 16),

        // حقل عنوان الشركة
        CustomTextField(
          controller: controller.companyAddressController,
          label: "company_address".tr,
          hint: "company_address".tr,
          prefixIcon: Icons.location_on,
          maxLines: 2,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildAdditionalFieldsSection() {
    if (controller.additionalFields.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "additional_info".tr,
          style: AppTheme.headlineSmall.copyWith(
            color: MyColors.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),
        Obx(
          () => ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.additionalFields.length,
            itemBuilder: (context, index) {
              final field = controller.additionalFields[index];
              print("niaaaaaaaaaaaaaaaaaaaa fileds page${field.label}");
              return _buildDynamicField(field);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.maxFinite,
      child: ElevatedButton(
        onPressed: () {
          final payload = controller.generatePayload();
          startRegister1(context, payload, Token_pref.getToken()!);
        },
        style: gm.buttonStyle(),
        child: Text('next'.tr, style: gm.textOnPrimaryButton()),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'alreadyHaveAccountText'.tr,
              style: AppTheme.bodyMedium.copyWith(
                color: MyColors.textSecondaryColor,
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                Get.off(() => const Login());
              },
              child: Text(
                'loginButtonText'.tr,
                style: AppTheme.bodyMedium.copyWith(
                  color: MyColors.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDynamicField(DynamicFieldModel field) {
    switch (field.type) {
      case 'string':
      case 'text':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Obx(
            () => TextFormField(
              initialValue: field.textValue.value,
              keyboardType: TextInputType.text,
              maxLines: field.type == 'text' ? 3 : 1,
              decoration: InputDecoration(
                labelText: field.label,
                border: const OutlineInputBorder(),
              ),
              onChanged: (val) => field.textValue.value = val,
              validator: (val) =>
                  (field.required && (val == null || val.isEmpty))
                  ? "field_required".trParams({'field': field.label})
                  : null,
            ),
          ),
        );

      case 'number':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Obx(
            () => TextFormField(
              initialValue: field.textValue.value,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: field.label,
                border: const OutlineInputBorder(),
              ),
              onChanged: (val) => field.textValue.value = val,
              validator: (val) =>
                  (field.required && (val == null || val.isEmpty))
                  ? "field_required".trParams({'field': field.label})
                  : null,
            ),
          ),
        );

      case 'url':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Obx(
            () => TextFormField(
              initialValue: field.textValue.value,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                labelText: field.label,
                border: const OutlineInputBorder(),
              ),
              onChanged: (val) => field.textValue.value = val,
              validator: (val) {
                if (field.required && (val == null || val.isEmpty))
                  return "field_required".trParams({'field': field.label});
                if (val != null && val.isNotEmpty && !val.startsWith('http'))
                  return "invalid_url_format".tr;
                return null;
              },
            ),
          ),
        );

      case 'date':
        return _buildSimpleDatePicker(field);

      case 'image':
      case 'file':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                field.label + (field.required ? ' *' : ''),
                style: AppTheme.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: MyColors.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              _buildModernFilePicker(field, field.type),
            ],
          ),
        );

      case 'file_with_text':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                field.label + (field.required ? ' *' : ''),
                style: AppTheme.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: MyColors.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              _buildModernFilePicker(field, 'file'),
              const SizedBox(height: 8),
              Obx(
                () => TextFormField(
                  initialValue: field.textValue.value,
                  decoration: InputDecoration(
                    labelText: "enter_field".trParams({'field': field.label}),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (val) => field.textValue.value = val,
                  validator: (val) =>
                      (field.required && (val == null || val.isEmpty))
                      ? "text_field_required".trParams({'field': field.label})
                      : null,
                ),
              ),
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
              Text(
                field.label + (field.required ? ' *' : ''),
                style: AppTheme.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: MyColors.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              _buildModernFilePicker(field, 'file'),
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

  Widget _buildSimpleDatePicker(DynamicFieldModel field) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Obx(
        () => InkWell(
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
              errorText: (field.required && field.textValue.value.isEmpty)
                  ? "field_required".trParams({'field': field.label})
                  : null,
            ),
            child: Text(
              field.textValue.value.isNotEmpty
                  ? field.textValue.value
                  : "choose_date".tr,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernFilePicker(DynamicFieldModel field, String fieldType) {
    return Obx(
      () => InkWell(
        onTap: () => _pickFileForField(field, fieldType),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
            color: field.fileUrl.value.isNotEmpty
                ? MyColors.primaryColor.withOpacity(0.05)
                : Colors.grey[50],
          ),
          child: Column(
            children: [
              Icon(
                field.fileUrl.value.isNotEmpty
                    ? Icons.check_circle_outline
                    : Icons.cloud_upload_outlined,
                size: 48,
                color: field.fileUrl.value.isNotEmpty
                    ? MyColors.primaryColor
                    : Colors.grey[600],
              ),
              const SizedBox(height: 8),
              Text(
                field.fileUrl.value.isNotEmpty
                    ? 'file_selected'.tr
                    : 'tap_to_select_file'.tr,
                style: TextStyle(
                  color: field.fileUrl.value.isNotEmpty
                      ? MyColors.primaryColor
                      : Colors.grey[600],
                  fontWeight: field.fileUrl.value.isNotEmpty
                      ? FontWeight.w500
                      : FontWeight.normal,
                ),
              ),
              if (field.fileUrl.value.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  _getFileName(field.fileUrl.value),
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickFileForField(
    DynamicFieldModel field,
    String fieldType,
  ) async {
    try {
      FilePickerResult? result;

      if (fieldType == 'image') {
        result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );
      } else {
        result = await FilePicker.platform.pickFiles(
          type: FileType.any,
          allowMultiple: false,
        );
      }

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        field.fileUrl.value = file.path!;

        Get.snackbar(
          'success_title'.tr,
          'file_selected_successfully'.trParams({'file': file.name}),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'error_title'.tr,
        'file_selection_error'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  String _getFileName(String filePath) {
    if (filePath.startsWith('http')) {
      return 'old_saved_file'.tr;
    }
    return filePath.split('/').last;
  }

  Widget _buildFilePicker(
    DynamicFieldModel field, {
    FileType fileType = FileType.custom,
  }) {
    Future<void> _pickFile() async {
      final bool isImage = fileType == FileType.image;

      final List<String> extensions = isImage
          ? ['jpg', 'jpeg', 'png']
          : ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'];

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: extensions,
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        field.fileUrl.value = filePath;
      }
    }

    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (field.fileUrl.value.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                "${'selected_file'.tr}: ${field.fileUrl.value.startsWith('http') ? 'old_saved_file'.tr : field.fileUrl.value.split('/').last}",
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: field.fileUrl.value.startsWith('http')
                      ? Colors.blue.shade700
                      : Colors.black87,
                ),
              ),
            ),
          Obx(
            () => ElevatedButton.icon(
              onPressed: _pickFile,
              icon: Icon(
                field.fileUrl.value.isEmpty
                    ? Icons.upload_file
                    : Icons.check_circle,
                color: Colors.white,
              ),
              label: Text(
                field.fileUrl.value.isEmpty
                    ? "choose_file".tr
                    : "change_selected_file".tr,
                style: const TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: field.fileUrl.value.isEmpty
                    ? Colors.blue.shade700
                    : Colors.green.shade700,
              ),
            ),
          ),
          if (field.required)
            Container(
              height: 0,
              width: 0,
              child: TextFormField(
                validator: (val) => field.fileUrl.value.isEmpty
                    ? "field_required".trParams({'field': field.label})
                    : null,
                controller: TextEditingController(text: field.fileUrl.value),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(DynamicFieldModel field) {
    return Obx(
      () => InkWell(
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
            labelText: "expiration_date".tr,
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.calendar_today),
            errorText: (field.required && field.expirationDate.value == null)
                ? "expiration_date_required".tr
                : null,
          ),
          child: Text(
            field.expirationDate.value != null
                ? field.expirationDate.value!.toString().substring(0, 10)
                : "choose_expiration_date".tr,
          ),
        ),
      ),
    );
  }

  Widget _buildReviewContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Basic Information Review
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: MyColors.lightBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'basic_data'.tr,
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: MyColors.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              _buildReviewItem('name'.tr, nameController.text),
              _buildReviewItem('email'.tr, emailController.text),
              _buildReviewItem(
                'phone_number'.tr,
                '${selectedPhoneCode.value} ${phoneController.text}',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Company Information Review (if filled)
        if (controller.companyNameController.text.isNotEmpty ||
            controller.companyAddressController.text.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: MyColors.lightBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'company_information'.tr,
                  style: AppTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: MyColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                if (controller.companyNameController.text.isNotEmpty)
                  _buildReviewItem(
                    'company_name'.tr,
                    controller.companyNameController.text,
                  ),
                if (controller.companyAddressController.text.isNotEmpty)
                  _buildReviewItem(
                    'company_address'.tr,
                    controller.companyAddressController.text,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Additional Fields Review (if any)
        if (controller.additionalFields.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: MyColors.lightBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'additional_info'.tr,
                  style: AppTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: MyColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                ...controller.additionalFields.map((field) {
                  return _buildReviewItem(
                    field.label,
                    _getFieldDisplayValue(field),
                  );
                }),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'not_specified'.tr,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: value.isNotEmpty
                    ? MyColors.textPrimaryColor
                    : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getFieldDisplayValue(DynamicFieldModel field) {
    switch (field.type) {
      case 'file':
      case 'image':
        return field.fileUrl.value.isNotEmpty
            ? 'file_selected'.tr
            : 'no_file_selected'.tr;
      case 'file_with_text':
        String fileStatus = field.fileUrl.value.isNotEmpty
            ? 'file_selected'.tr
            : 'no_file_selected'.tr;
        String textValue = field.textValue.value.isNotEmpty
            ? field.textValue.value
            : 'no_text_entered'.tr;
        return '$fileStatus - $textValue';
      case 'file_expiration_date':
        String fileStatus = field.fileUrl.value.isNotEmpty
            ? 'file_selected'.tr
            : 'no_file_selected'.tr;
        String dateValue = field.expirationDate.value != null
            ? field.expirationDate.value!.toIso8601String().substring(0, 10)
            : 'no_date_selected'.tr;
        return '$fileStatus - $dateValue';
      default:
        return field.textValue.value;
    }
  }
}
