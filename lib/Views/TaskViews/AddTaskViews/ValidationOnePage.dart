import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';



// ==========================================================
// 🚨🚨🚨 استيرادات المكتبات المحلية 🚨🚨🚨
// يجب أن تضمن أن المسارات التالية صحيحة في مشروعك:
// ==========================================================
import '../../../Globals/MyColors.dart';
import '../../../Globals/global_methods.dart' as global_methods;
import '../../../Helpers/TaskHelper.dart';
import '../../../Models/TaskModel.dart';
import '../../../shared_prff.dart';
import '../../../Globals/global.dart' as globals;
import 'ValidationTwoPage.dart'; // واجهة الخطوة التالية للإنشاء

// ==========================================================
// 💼 نماذج بيانات API الخطوة الأولى (Vehicles & Templates) 💼
// هذه النماذج خاصة بهذه الشاشة ويجب أن تبقى هنا
// ==========================================================

class SizeData {
  final int id;
  final String name;
  SizeData({required this.id, required this.name});

  factory SizeData.fromJson(Map<String, dynamic> json) {
    return SizeData(id: json['id'] ?? 0, name: json['name'] ?? '');
  }
}

class TypeData {
  final int id;
  final String name;
  final List<SizeData> sizes;
  TypeData({required this.id, required this.name, required this.sizes});

  factory TypeData.fromJson(Map<String, dynamic> json) {
    var sizesList = json['sizes'] as List<dynamic>?;
    List<SizeData> sizes = sizesList != null
        ? sizesList.map((sizeJson) => SizeData.fromJson(sizeJson)).toList()
        : [];
    return TypeData(id: json['id'] ?? 0, name: json['name'] ?? '', sizes: sizes);
  }
}

class VehicleData {
  final int id;
  final String name;
  final List<TypeData> types;
  VehicleData({required this.id, required this.name, required this.types});

  factory VehicleData.fromJson(Map<String, dynamic> json) {
    var typesList = json['types'] as List<dynamic>?;
    List<TypeData> types = typesList != null
        ? typesList.map((typeJson) => TypeData.fromJson(typeJson)).toList()
        : [];
    return VehicleData(id: json['id'] ?? 0, name: json['name'] ?? '', types: types);
  }
}

class DynamicFieldModel {
  final int id;
  final String name;
  final String label;
  final String type;
  final bool required;

  // Rx Fields for user input and saved data
  RxString textValue;
  Rx<DateTime?> expirationDate;
  RxString fileUrl; // Path for new file upload OR URL for saved file

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

  // Factory to create model from the *template* structure (API Initial Data)
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

class SelectedVehicleModel {
  RxInt vehicleId;
  RxInt vehicleTypeId;
  RxInt vehicleSizeId;
  RxInt quantity;
  RxString vehicleName;
  RxString vehicleTypeName;
  RxString vehicleSizeName;

  SelectedVehicleModel({
    required int vehicleId,
    required int vehicleTypeId,
    required int vehicleSizeId,
    required int quantity,
    required String vehicleName,
    required String vehicleTypeName,
    required String vehicleSizeName,
  }) : vehicleId = vehicleId.obs,
        vehicleTypeId = vehicleTypeId.obs,
        vehicleSizeId = vehicleSizeId.obs,
        quantity = quantity.obs,
        vehicleName = vehicleName.obs,
        vehicleTypeName = vehicleTypeName.obs,
        vehicleSizeName = vehicleSizeName.obs;
}

// ==========================================================
// ⚙️ المتحكم (ValidationOneController) ⚙️
// ==========================================================

class ValidationOneController extends GetxController {

  // ==========================================================
  // حقول خاصة بعملية التعديل (EDIT MODE FIELDS)
  // ==========================================================
  final Rx<TaskModel?> taskModelForEdit = Rx<TaskModel?>(null);
  final RxBool isEditMode = false.obs;
  // ==========================================================

  final RxList<VehicleData> allVehicles = <VehicleData>[].obs;
  final RxList<DynamicFieldModel> additionalFields = <DynamicFieldModel>[].obs;
  Map<String, dynamic>? rawTaskTemplates;
  final List<String> templateKeys = ['task_template', 'task_from_template', 'task_to_template'];
  final RxInt selectedTemplateIndex = (-1).obs;
  final RxList<String> availableTemplatesKeys = <String>[].obs;
  final RxInt selectedTemplateId = (-1).obs;
  final RxString selectedTemplateName = ''.obs;
  final Map<String, String> templateTitlesMap = {};
  final Rx<SelectedVehicleModel?> singleSelectedVehicle = Rx<SelectedVehicleModel?>(null);
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  RxBool isLoading = true.obs;
  TaskHelper helperData = TaskHelper();


  // دالة لتعيين بيانات المهمة عند بدء التعديل
  void setTaskModelForEdit(TaskModel taskModel) {
    taskModelForEdit.value = taskModel;
    isEditMode.value = true;
  }

  // ==========================================================
  // منطق تحميل البيانات الأولية والتهيئة (Load & Initialize)
  // ==========================================================

  void loadInitialData() async {
    try {
      isLoading.value = true;
      var data = await helperData.getAddIni(Token_pref.getToken());

      if (data["status"] == 200) {
        final dataBody = data["data"];
        final List<dynamic> vehiclesJson = dataBody["vehicles"];

        allVehicles.clear();
        allVehicles.value = vehiclesJson.map((item) => VehicleData.fromJson(item)).toList();

        rawTaskTemplates = {
          'task_template': dataBody['task_template'],
          'task_from_template': dataBody['task_from_template'],
          'task_to_template': dataBody['task_to_template'],
        };

        availableTemplatesKeys.clear();
        templateTitlesMap.clear();
        for (var key in templateKeys) {
          final templateData = rawTaskTemplates![key];
          if (templateData != null && templateData['template'] != null) {
            availableTemplatesKeys.add(key);
            templateTitlesMap[key] = templateData['template']['name'] ?? key;
          }
        }

        // التوجيه: تعديل أو إنشاء
        if (isEditMode.value && taskModelForEdit.value != null) {
          _initializeForEdit(taskModelForEdit.value!);
        } else {
          // وضع الإنشاء (Create Mode)
          if (availableTemplatesKeys.isNotEmpty) {
            changeTemplate(availableTemplatesKeys.first);
          } else {
            additionalFields.clear();
            selectedTemplateId.value = -1;
            selectedTemplateName.value = '';
          }
          _initSingleVehicle();
        }
      }
    } catch (e) {
      print("Error in loadInitialData: $e");
      global_methods.sendError("ValidationOneController : $e");
    } finally {
      isLoading.value = false;
    }
  }


  // تهيئة البيانات للإنشاء (Initialization for Create)
  void _initSingleVehicle() {
    if (allVehicles.isNotEmpty && singleSelectedVehicle.value == null) {
      final defaultVehicle = allVehicles.first;
      final defaultType = defaultVehicle.types.first;
      final defaultSizeId = defaultType.sizes.isNotEmpty ? defaultType.sizes.first.id : 0;
      final defaultSizeName = defaultType.sizes.isNotEmpty ? defaultType.sizes.first.name : "N/A";

      singleSelectedVehicle.value = SelectedVehicleModel(
        vehicleId: defaultVehicle.id,
        vehicleTypeId: defaultType.id,
        vehicleSizeId: defaultSizeId,
        quantity: 1,
        vehicleName: defaultVehicle.name,
        vehicleTypeName: defaultType.name,
        vehicleSizeName: defaultSizeName,
      );
    }
  }


  // تهيئة البيانات للتعديل (Initialization for Edit)
  void _initializeForEdit(TaskModel task) {
    // 1. تهيئة المركبة (Vehicle) - تفكيك اسم المركبة المحفوظ
    final parts = task.vehicle.value.split(RegExp(r'\s*-\s*')).map((s) => s.trim()).toList();

    VehicleData? initialVehicle;
    TypeData? initialType;
    SizeData? initialSize;

    // محاولة العثور على المركبة والنوع والحجم بناءً على الاسم المحفوظ
    for(var v in allVehicles) {
      if (parts.contains(v.name)) {
        initialVehicle = v;
        for(var t in v.types) {
          if (parts.contains(t.name)) {
            initialType = t;
            initialSize = t.sizes.firstWhereOrNull((s) => parts.contains(s.name));
            break;
          }
        }
        break;
      }
    }

    // تعيين المركبة المبدئية
    if (initialVehicle != null && initialType != null) {
      singleSelectedVehicle.value = SelectedVehicleModel(
        vehicleId: initialVehicle.id,
        vehicleTypeId: initialType.id,
        vehicleSizeId: initialSize?.id ?? 0,
        quantity: 1,
        vehicleName: initialVehicle.name,
        vehicleTypeName: initialType.name,
        vehicleSizeName: initialSize?.name ?? "N/A",
      );
    } else {
      _initSingleVehicle();
    }

    // 2. تهيئة القالب والحقول الإضافية
    // نختار أول قالب متاح ونملأ حقوله بالبيانات المحفوظة
    if (availableTemplatesKeys.isNotEmpty) {
      final defaultKey = availableTemplatesKeys.first;
      final templateData = rawTaskTemplates![defaultKey];
      final templateInfo = templateData['template'];

      selectedTemplateIndex.value = templateKeys.indexOf(defaultKey);
      selectedTemplateId.value = templateInfo['id'] ?? -1;
      selectedTemplateName.value = templateInfo['name'] ?? '';

      _updateAdditionalFields(defaultKey, initialData: task.additionalData.toList());
    }
  }

  // تحديث منطق تغيير القالب ليشمل تهيئة بيانات التعديل
  void changeTemplate(String templateKey) {
    if (templateKeys.contains(templateKey) && availableTemplatesKeys.contains(templateKey)) {
      final templateData = rawTaskTemplates![templateKey];
      if (templateData != null && templateData['template'] != null) {
        final templateInfo = templateData['template'];
        _updateAdditionalFields(
            templateKey,
            initialData: isEditMode.value ? taskModelForEdit.value!.additionalData.toList() : null
        );
        selectedTemplateIndex.value = templateKeys.indexOf(templateKey);
        selectedTemplateId.value = templateInfo['id'] ?? -1;
        selectedTemplateName.value = templateInfo['name'] ?? '';
      }
    }
  }

  // دالة داخلية لتحديث الحقول الإضافية (معدلة لتقبل البيانات الأولية)
  void _updateAdditionalFields(String templateKey, {List<AdditionalDataModel>? initialData}) {
    if (rawTaskTemplates == null || rawTaskTemplates![templateKey] == null) return;

    final List<dynamic> fieldsJson = rawTaskTemplates![templateKey]['fields'];

    additionalFields.clear();

    // بناء الحقول من القالب
    final List<DynamicFieldModel> tempFields = fieldsJson.map((item) => DynamicFieldModel.fromTemplateJson(item)).toList();

    // تهيئة الحقول من بيانات المهمة المحفوظة
    if (initialData != null) {
      for (var field in tempFields) {
        final savedEntry = initialData.firstWhereOrNull((item) => item.label.value.trim() == field.label.trim());

        if (savedEntry != null) {
          // تعيين القيمة النصية
          field.textValue.value = savedEntry.value.value;

          // تعيين الملف أو تاريخ الانتهاء بناءً على نوع الحقل
          if (field.type.contains('file') && savedEntry.value.value.startsWith('http')) {
            field.fileUrl.value = savedEntry.value.value; // رابط URL للملف المحفوظ
          }

          if (field.type == 'file_expiration_date') {
            // محاولة تحليل القيمة المخزنة كتاريخ
            try {
              field.expirationDate.value = DateTime.tryParse(savedEntry.value.value);
            } catch (e) {
              // في حالة فشل التحليل، نتركها فارغة
            }
          }
        }
      }
    }

    additionalFields.value = tempFields;
  }

  // ==========================================================
  // منطق توليد الحمولة (Payload Generation)
  // ==========================================================

  Map<String, dynamic> generatePayload() {
    if (!formKey.currentState!.validate()) {
      Get.snackbar("خطأ", "يرجى ملء جميع الحقول المطلوبة بشكل صحيح.", snackPosition: SnackPosition.BOTTOM);
      return {};
    }

    final vehicle = singleSelectedVehicle.value;
    if (vehicle == null) {
      Get.snackbar("خطأ", "يجب اختيار مركبة واحدة.", snackPosition: SnackPosition.BOTTOM);
      return {};
    }

    if (selectedTemplateIndex.value == -1 || rawTaskTemplates == null) {
      Get.snackbar("خطأ", "لم يتم تحميل أو اختيار قالب بيانات إضافية.", snackPosition: SnackPosition.BOTTOM);
      return {};
    }

    List<Map<String, dynamic>> vehiclesPayload = [
      {
        "vehicle": vehicle.vehicleId.value,
        "vehicle_type": vehicle.vehicleTypeId.value,
        "vehicle_size": vehicle.vehicleSizeId.value == 0 ? null : vehicle.vehicleSizeId.value,
        "quantity": vehicle.quantity.value,
      }
    ];

    Map<String, dynamic> additionalFieldsPayload = {};
    for (var field in additionalFields) {

      String fileValue = field.fileUrl.value;

      switch (field.type) {
        case 'string':
          additionalFieldsPayload[field.name] = field.textValue.value;
          break;

        case 'file_with_text':
        case 'file_expiration_date':

          if (field.required && fileValue.isEmpty) {
            Get.snackbar("خطأ", "ملف ${field.label} مطلوب.", snackPosition: SnackPosition.BOTTOM);
            return {};
          }

          // إذا كانت القيمة مسار محلي أو URL محفوظة، تُضاف إلى حقل الملف في البايلود
          additionalFieldsPayload["${field.name}_file"] = fileValue;

          if (field.type == 'file_with_text') {
            additionalFieldsPayload["${field.name}_text"] = field.textValue.value;
          }

          if (field.type == 'file_expiration_date') {
            additionalFieldsPayload["${field.name}_expiration"] = field.expirationDate.value?.toIso8601String().substring(0, 10);
          }
          break;
      }
    }

    final currentTemplateKey = availableTemplatesKeys[selectedTemplateIndex.value];
    final templateData = rawTaskTemplates![currentTemplateKey];

    return {
      "vehicles": vehiclesPayload,
      "template": templateData['template']['id'],
      "additional_fields": additionalFieldsPayload,
    };
  }
}

// ==========================================================
// 🖥️ الواجهة (ValidationOnePage) 🖥️
// ==========================================================

class ValidationOnePage extends StatefulWidget {
  // إضافة حقول التعديل
  final TaskModel? taskModelForEdit;
  final int? taskIdForEdit;

  const ValidationOnePage({
    super.key,
    this.taskModelForEdit,
    this.taskIdForEdit,
  });

  @override
  State<ValidationOnePage> createState() => _ValidationOnePageState();
}

class _ValidationOnePageState extends State<ValidationOnePage> {
  // استخدام .put هنا لضمان وجود نسخة واحدة من المتحكم
  ValidationOneController controller = Get.put(ValidationOneController());

  @override
  void initState() {
    super.initState();
    // تعيين بيانات التعديل في المتحكم قبل تحميل البيانات الأولية
    if (widget.taskModelForEdit != null) {
      controller.setTaskModelForEdit(widget.taskModelForEdit!);
    }
    controller.loadInitialData();
  }

  @override
  void dispose() {
    super.dispose();
  }



  // دالة الإرسال الموحدة (تدعم الإنشاء والتعديل)
  Future<void> sendTaskPayload(BuildContext context, Map<String, dynamic> payload, String token) async {
    final bool isEdit = controller.isEditMode.value;
    final int? taskId = widget.taskIdForEdit ?? controller.taskModelForEdit.value?.id.value;

    // تحديد نقطة النهاية (Endpoint)
    final String endpoint = "tasks/validate-step1";

    final url = Uri.parse(globals.public_uri + endpoint);

    if (!await global_methods.isInternetAvailable()) {
      global_methods.errorView(context, 'checkInternetConnection'.tr);
      return;
    }

    global_methods.showDialogLoading(context: context);

    // إعداد الطلب (Multipart)
    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Language'] = global_methods.getLanguage();

    // إضافة الحقول الثابتة
    request.fields['template'] = payload['template'].toString();
    request.fields['vehicles'] = jsonEncode(payload['vehicles']);

    final Map<String, dynamic> additionalFields = payload['additional_fields'];

    for (var key in additionalFields.keys) {
      var value = additionalFields[key];

      if (key.endsWith('_file')) {
        String fileValue = value;

        if (fileValue.isNotEmpty && !fileValue.startsWith('http')) {
          // ملف جديد تم اختياره (مسار محلي) - يجب إرساله كـ MultipartFile
          File file = File(fileValue);
          if (await file.exists()) {
            var multipartFile = await http.MultipartFile.fromPath(
              key,
              fileValue,
              filename: basename(fileValue),
            );
            request.files.add(multipartFile);
          }
        } else {
          // رابط URL لملف سابق أو قيمة فارغة (يرسل كحقل نصي)
          request.fields[key] = fileValue;
        }
      } else {
        // حقول النص العادية والتاريخ
        request.fields[key] = value.toString();
      }
    }

    try {
      http.StreamedResponse streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      global_methods.hideLoadingDialog();

      var data = jsonDecode(response.body);

      if (data["status"] == 200 ) {
        Get.snackbar("نجاح", "تم التحقق بنجاح", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green);

        // if (!isEdit) {
          globals.stepOnePayload=payload;
          Get.to(() => ValidationTwoPage(stepOneResponse: response));
        // } else {
        //   // العودة إلى قائمة المهام بعد التعديل
        //   Get.back();
        // }

      } else {
        Get.snackbar("خطأ في API", "فشل الإرسال. الاستجابة: ${data["message"] ?? 'Unknown error'}",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade600,
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("خطأ الإرسال", "حدث خطأ أثناء الاتصال بالخادم: $e",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white);
      global_methods.hideLoadingDialog();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.isEditMode.value
            ? "تعديل المهمة #${widget.taskIdForEdit ?? controller.taskModelForEdit.value?.id.value ?? 'N/A'}"
            : "إنشاء مهمة جديدة")),
        backgroundColor: MyColors.appBarColor,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildVehiclesSection(),
                const SizedBox(height: 30),
                _buildTemplateSelection(),
                const SizedBox(height: 30),
                if (controller.additionalFields.isNotEmpty)
                  _buildAdditionalFieldsSection(),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    final payload = controller.generatePayload();
                    if (payload.isNotEmpty) {
                      await sendTaskPayload(context, payload, Token_pref.getToken()!);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.primaryColor,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Obx(() => Text(
                      controller.isEditMode.value ? "تعديل وحفظ التغييرات" : "المتابعة إلى الخطوة التالية",
                      style: const TextStyle(color: Colors.white)
                  )),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // --------------------------------------------------------------------------
  // دوال بناء الواجهة
  // --------------------------------------------------------------------------

  Widget _buildVehiclesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("تحديد المركبة المطلوبة", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Divider(),
        Obx(() {
          final selectedItem = controller.singleSelectedVehicle.value;
          if (selectedItem == null || controller.allVehicles.isEmpty) {
            return const Center(child: Text("لا توجد بيانات مركبات متاحة."));
          }

          final currentVehicle = controller.allVehicles.firstWhereOrNull((v) => v.id == selectedItem.vehicleId.value);
          final currentTypes = currentVehicle?.types ?? [];

          return Obx(() {
            final currentType = currentTypes.firstWhereOrNull((t) => t.id == selectedItem.vehicleTypeId.value);
            final currentSizes = currentType?.sizes ?? [];

            return Column(
              children: [
                _buildDropdown<int>(
                  title: "نوع المركبة",
                  value: selectedItem.vehicleId.value,
                  items: controller.allVehicles.map((v) => DropdownMenuItem(value: v.id, child: Text(v.name))).toList(),
                  onChanged: (newId) {
                    if (newId == null) return;
                    final newVehicle = controller.allVehicles.firstWhere((v) => v.id == newId);
                    final newType = newVehicle.types.first;
                    final newSizeId = newType.sizes.isNotEmpty ? newType.sizes.first.id : 0;

                    selectedItem.vehicleId.value = newId;
                    selectedItem.vehicleName.value = newVehicle.name;
                    selectedItem.vehicleTypeId.value = newType.id;
                    selectedItem.vehicleTypeName.value = newType.name;
                    selectedItem.vehicleSizeId.value = newSizeId;
                    selectedItem.vehicleSizeName.value = newType.sizes.isNotEmpty ? newType.sizes.first.name : "N/A";
                  },
                ),
                _buildDropdown<int>(
                  title: "تفصيل المركبة",
                  value: selectedItem.vehicleTypeId.value,
                  items: currentTypes.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))).toList(),
                  onChanged: (newId) {
                    if (newId == null) return;
                    final newType = currentTypes.firstWhere((t) => t.id == newId);
                    final newSizeId = newType.sizes.isNotEmpty ? newType.sizes.first.id : 0;

                    selectedItem.vehicleTypeId.value = newId;
                    selectedItem.vehicleTypeName.value = newType.name;
                    selectedItem.vehicleSizeId.value = newSizeId;
                    selectedItem.vehicleSizeName.value = newType.sizes.isNotEmpty ? newType.sizes.first.name : "N/A";
                  },
                ),
                if (currentSizes.isNotEmpty)
                  _buildDropdown<int>(
                    title: "الحجم (اختياري)",
                    value: selectedItem.vehicleSizeId.value != 0 ? selectedItem.vehicleSizeId.value : currentSizes.first.id,
                    items: currentSizes.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                    onChanged: (newId) {
                      if (newId == null) return;
                      final newSize = currentSizes.firstWhere((s) => s.id == newId);
                      selectedItem.vehicleSizeId.value = newId;
                      selectedItem.vehicleSizeName.value = newSize.name;
                    },
                  ),
              ],
            );
          });
        }),
      ],
    );
  }

  Widget _buildTemplateSelection() {
    return Obx(() {
      if (controller.availableTemplatesKeys.isEmpty) {
        return const SizedBox.shrink();
      }

      final String selectedKey = controller.availableTemplatesKeys.firstWhere(
              (key) => controller.templateKeys.indexOf(key) == controller.selectedTemplateIndex.value,
          orElse: () => controller.availableTemplatesKeys.first
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("اختيار قالب البيانات الإضافية", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(),
          _buildDropdown<String>(
            title: "القالب المختار",
            value: selectedKey,
            items: controller.availableTemplatesKeys.map((key) => DropdownMenuItem(
                value: key,
                child: Text(controller.templateTitlesMap[key] ?? key)
            )).toList(),
            onChanged: (newKey) {
              if (newKey != null) {
                controller.changeTemplate(newKey);
              }
            },
          ),
        ],
      );
    });
  }

  Widget _buildDropdown<T>({required String title, required T value, required List<DropdownMenuItem<T>> items, required ValueChanged<T?> onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<T>(
        decoration: InputDecoration(
          labelText: title,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        value: value,
        items: items,
        onChanged: onChanged,
        validator: (v) {
          if (title == "الحجم (اختياري)") return null;
          return v == null || (v is int && v == 0) ? "يرجى اختيار قيمة لـ $title" : null;
        },
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
            return _buildDynamicField(field);
          },
        )),
      ],
    );
  }

  Widget _buildDynamicField(DynamicFieldModel field) {
    switch (field.type) {
      case 'string':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Obx(() => TextFormField(
            initialValue: field.textValue.value,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              labelText: field.label,
              border: const OutlineInputBorder(),
            ),
            onChanged: (val) => field.textValue.value = val,
            validator: (val) => (field.required && (val == null || val.isEmpty)) ? "${field.label} مطلوب" : null,
          )),
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

  Widget _buildFilePicker(DynamicFieldModel field) {
    Future<void> _pickFile() async {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        field.fileUrl.value = filePath; // مسار محلي جديد
      }
    }

    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (field.fileUrl.value.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              // عرض اسم الملف المحلي أو رابط الـ URL المحفوظ
              "الملف المختار: ${field.fileUrl.value.startsWith('http') ? "ملف قديم محفوظ" : field.fileUrl.value.split('/').last}",
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: field.fileUrl.value.startsWith('http') ? Colors.blue.shade700 : Colors.black87,
              ),
            ),
          ),
        ElevatedButton.icon(
          onPressed: _pickFile,
          icon: Icon(field.fileUrl.value.isEmpty ? Icons.upload_file : Icons.check_circle, color: Colors.white),
          label: Text(field.fileUrl.value.isEmpty ? "اختر ملف" : "تغيير الملف المختار", style: const TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(backgroundColor: field.fileUrl.value.isEmpty ? Colors.blue.shade700 : Colors.green.shade700),
        ),
        if (field.required)
        // حقل مخفي للتحقق من وجود ملف (سواء كان رابطاً قديماً أو مساراً جديداً)
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