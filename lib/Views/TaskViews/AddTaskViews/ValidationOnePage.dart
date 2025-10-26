import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

import '../../../Globals/MyColors.dart';
import '../../../Globals/global_methods.dart' as global_methods;
import '../../../Helpers/TaskHelper.dart';
import '../../../Models/TaskModel.dart';
import '../../../shared_prff.dart';
import '../../../Globals/global.dart' as globals;
import 'ValidationTwoPage.dart';

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

class ValidationOneController extends GetxController {

  final Rx<TaskModel?> taskModelForEdit = Rx<TaskModel?>(null);
  final RxBool isEditMode = false.obs;

  final RxList<VehicleData> allVehicles = <VehicleData>[].obs;
  final RxList<DynamicFieldModel> additionalFields = <DynamicFieldModel>[].obs;
  Map<String, dynamic>? rawTaskTemplates;
  final List<String> templateKeys = ['task_template', 'task_from_template', 'task_to_template'];
  // final List<String> templateKeys = ['task_template'];
  final RxInt selectedTemplateIndex = (-1).obs;
  final RxList<String> availableTemplatesKeys = <String>[].obs;

  // 💡 تم تبسيط متغيرات القالب
  final RxInt selectedTemplateId = (-1).obs;
  final RxString selectedTemplateName = ''.obs;
  final Map<String, String> templateTitlesMap = {};

  final Rx<SelectedVehicleModel?> singleSelectedVehicle = Rx<SelectedVehicleModel?>(null);
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  RxBool isLoading = true.obs;
  TaskHelper helperData = TaskHelper();

  void setTaskModelForEdit(TaskModel taskModel) {
    taskModelForEdit.value = taskModel;
    isEditMode.value = true;
  }

  void loadInitialData() async {
    try {
      isLoading.value = true;
      var data = await helperData.getAddIni(Token_pref.getToken());

      if (data["status"] == 200) {
        final dataBody = data["data"];
        final List<dynamic> vehiclesJson = dataBody["vehicles"];

        allVehicles.clear();
        allVehicles.value = vehiclesJson.map((item) => VehicleData.fromJson(item)).toList();
print("ssssssaaaaaaaaaaaeeeeeeedddddddd task_template :${dataBody['task_template']} ");
print("ssssssaaaaaaaaaaaeeeeeeedddddddd task_from_template :${dataBody['task_from_template']} ");
print("ssssssaaaaaaaaaaaeeeeeeedddddddd task_to_template :${dataBody['task_to_template']} ");
        rawTaskTemplates = {
          'task_template': dataBody['task_template'],
          'task_from_template': dataBody['task_from_template'],
          'task_to_template': dataBody['task_to_template'],
        };

        if(rawTaskTemplates!["task_template"]!=null){
          rawTaskTemplates!["task_template"]['template']['name']="مهمه عاديه";
        }
        if(rawTaskTemplates!["task_from_template"]!=null){
          rawTaskTemplates!["task_from_template"]['template']['name']="مهمة من مينا";
        }
        if(rawTaskTemplates!["task_to_template"]!=null){
          rawTaskTemplates!["task_to_template"]['template']['name']="مهمة الى ميناء";
        }

        availableTemplatesKeys.clear();
        templateTitlesMap.clear();
        for (var key in templateKeys) {
          final templateData = rawTaskTemplates![key];
          if (templateData != null && templateData['template'] != null) {
            availableTemplatesKeys.add(key);
            templateTitlesMap[key] = templateData['template']['name'] ?? key;
          }
        }


        if (isEditMode.value && taskModelForEdit.value != null) {
          _initializeForEdit(taskModelForEdit.value!);
        } else {
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
      global_methods.sendError("ValidationOneController : $e");
    } finally {
      isLoading.value = false;
    }
  }


  // ... (دالة _initSingleVehicle تبقى كما هي)
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

  // 💡 تعديل دالة التهيئة لوضع التعديل
  void _initializeForEdit(TaskModel task) {
    final parts = task.vehicle.value.split(RegExp(r'\s*-\s*')).map((s) => s.trim()).toList();

    VehicleData? initialVehicle;
    TypeData? initialType;
    SizeData? initialSize;

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

  // 💡 إزالة دالة changeTemplate واستبدالها بالمنطق المبسّط لـ _updateAdditionalFields
  void _updateAdditionalFields(String templateKey, {List<AdditionalDataModel>? initialData}) {
    if (rawTaskTemplates == null || rawTaskTemplates![templateKey] == null) return;

    final List<dynamic> fieldsJson = rawTaskTemplates![templateKey]['fields'];

    additionalFields.clear();

    final List<DynamicFieldModel> tempFields = fieldsJson.map((item) => DynamicFieldModel.fromTemplateJson(item)).toList();

    if (initialData != null) {
      for (var field in tempFields) {
        final savedEntry = initialData.firstWhereOrNull((item) => item.label.value.trim() == field.label.trim());

        if (savedEntry != null) {
          if (field.type.contains('file') || field.type == 'image') {
            field.fileUrl.value = savedEntry.value.value;
          } else {
            field.textValue.value = savedEntry.value.value;
          }

          if (field.type == 'file_expiration_date') {
            if(savedEntry.expirationDate.value!=null) {
              field.expirationDate.value = savedEntry.expirationDate.value;
            }
            field.fileUrl.value = savedEntry.value.value; // تحديث رابط الملف
          }
        }
      }
    }
    additionalFields.value = tempFields;
  }

  // 💡 تعديل دالة generatePayload لتبسيط التعامل مع أنواع الحقول الجديدة والملفات
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
          additionalFieldsPayload["${field.name}_file_file"] = fileValue;
          additionalFieldsPayload["${field.name}_text"] = field.textValue.value;
          break;

        case 'file_expiration_date':
          if (field.required && (fileValue.isEmpty || field.expirationDate.value == null)) {
            Get.snackbar("خطأ", "الملف وتاريخ الانتهاء لـ ${field.label} مطلوبان.", snackPosition: SnackPosition.BOTTOM);
            return {};
          }
          additionalFieldsPayload["${field.name}_file_file"] = fileValue;
          additionalFieldsPayload["${field.name}_expiration"] = field.expirationDate.value?.toIso8601String().substring(0, 10);
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
class ValidationOnePage extends StatefulWidget {
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
  ValidationOneController controller = Get.put(ValidationOneController());

  @override
  void initState() {
    super.initState();
    if (widget.taskModelForEdit != null) {
      controller.setTaskModelForEdit(widget.taskModelForEdit!);
    }
    controller.loadInitialData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> sendTaskPayload(BuildContext context, Map<String, dynamic> payload, String token) async {
     String endpoint = "tasks/validate-step1";


    final url = Uri.parse(globals.public_uri + endpoint);
print("ddddddddddddddddddddddd:$url");
    if (!await global_methods.isInternetAvailable()) {
      global_methods.errorView(context, 'checkInternetConnection'.tr);
      return;
    }

    global_methods.showDialogLoading(context: context);

    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Language'] = global_methods.getLanguage();

    request.fields['template'] = payload['template'].toString();
    request.fields['vehicles'] = jsonEncode(payload['vehicles']);
     if(controller.isEditMode.value){
       request.fields['id'] = widget.taskIdForEdit.toString();
     }
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

      global_methods.hideLoadingDialog();

      print("API Response: $data");

      if (data["status"] == 200) {
        Get.snackbar("نجاح", "تم التحقق بنجاح", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green);

        globals.stepOnePayload=payload;
        if(controller.isEditMode.value){
          Get.to(() => ValidationTwoPage(stepOneResponse: response,taskModelForEdit: widget.taskModelForEdit,taskIdForEdit: widget.taskIdForEdit,));
        }else{
          Get.to(() => ValidationTwoPage(stepOneResponse: response));
        }
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
            print("niaaaaaaaaaaaaaaaaaaaa fileds page${field.label}");
            return _buildDynamicField(field);
          },
        )),
      ],
    );
  }

// في كلاس _ValidationOnePageState

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