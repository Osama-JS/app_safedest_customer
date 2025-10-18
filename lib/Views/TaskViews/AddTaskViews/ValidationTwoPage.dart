import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../../../Globals/MyColors.dart';
import '../../../Globals/global_methods.dart' as global_methods;
import '../../../Models/TaskModel.dart';
import '../../../Services/InitialService.dart';
import '../../../shared_prff.dart';
import 'package:http/http.dart' as http;
import '../../../Globals/global.dart' as globals;
import '../../Maps/MapPickerSimulationDialog.dart';
import 'AddTaskPage.dart';
import 'package:path/path.dart';




// ==========================================================
// 💼 نماذج التسعير (Pricing Models) 💼
// ==========================================================

class PricingParam {
  final int id;
  final String name;

  PricingParam({required this.id, required this.name});

  factory PricingParam.fromJson(String type, Map<String, dynamic> json) {
    if (type == 'points') {
      return PricingParam(
        id: json['from_point']['id'] ?? 0,
        name: '${json['from_point']['name'] ?? 'N/A'} - ${json['to_point']['name'] ?? 'N/A'} (السعر: ${json['price'] ?? 0})',
      );
    }
    // تستخدم للحالات الأخرى (مثل distance) حيث يتم تمرير ID المعامل
    return PricingParam(id: json['param'] ?? 0, name: 'Default Parameter');
  }
}

class PricingMethodModel {
  final int id;
  final String name;
  final String type;
  final List<PricingParam> params;

  PricingMethodModel({
    required this.id,
    required this.name,
    required this.type,
    required this.params,
  });

  factory PricingMethodModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? paramsJson = json['params'];
    List<PricingParam> paramsList = [];

    if (paramsJson != null) {
      paramsList = paramsJson.map((item) => PricingParam.fromJson(json['type'] ?? 'distance', item)).toList();
    }

    return PricingMethodModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? 'distance',
      params: paramsList,
    );
  }
}

// ==========================================================
// ⚙️ المتحكم (ValidationTwoController) ⚙️
// ==========================================================

class ValidationTwoController extends GetxController {
  // وضع التعديل
  final Rx<TaskModel?> taskModelForEdit = Rx<TaskModel?>(null);
  final RxBool isEditMode = false.obs;

  final RxList<PricingMethodModel> pricingMethods = <PricingMethodModel>[].obs;
  final Rx<PricingMethodModel?> selectedPricingMethod = Rx<PricingMethodModel?>(null);
  final Rx<PricingParam?> selectedPricingParam = Rx<PricingParam?>(null);
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // حقول الاستلام (Pickup) التي تعتمد على الإحداثيات والتواريخ
  final RxString pickupAddress = ''.obs;
  final RxDouble pickupLatitude = 0.0.obs;
  final RxDouble pickupLongitude = 0.0.obs;
  final Rx<DateTime?> pickupBeforeDate = Rx<DateTime?>(null);

  // حقول التسليم (Delivery) التي تعتمد على الإحداثيات والتواريخ
  final RxString deliveryAddress = ''.obs;
  final RxDouble deliveryLatitude = 0.0.obs;
  final RxDouble deliveryLongitude = 0.0.obs;
  final Rx<DateTime?> deliveryBeforeDate = Rx<DateTime?>(null);

  // 🚨🚨🚨 المتحكمات النصية الجديدة 🚨🚨🚨
  late TextEditingController pickupNameController;
  late TextEditingController pickupPhoneController;
  late TextEditingController pickupEmailController;
  late TextEditingController pickupNoteController;

  late TextEditingController deliveryNameController;
  late TextEditingController deliveryPhoneController;
  late TextEditingController deliveryEmailController;
  late TextEditingController deliveryNoteController;

  late TextEditingController conditionsController;

  // دالة لتهيئة بيانات التعديل
  void setTaskModelForEdit(TaskModel taskModel) {
    taskModelForEdit.value = taskModel;
    isEditMode.value = true;
  }

  @override
  void onInit() {
    // تهيئة المتحكمات قبل الاستخدام
    pickupNameController = TextEditingController();
    pickupPhoneController = TextEditingController();
    pickupEmailController = TextEditingController();
    pickupNoteController = TextEditingController();

    deliveryNameController = TextEditingController();
    deliveryPhoneController = TextEditingController();
    deliveryEmailController = TextEditingController();
    deliveryNoteController = TextEditingController();

    conditionsController = TextEditingController();
    super.onInit();
  }

  @override
  void onClose() {
    // التخلص من المتحكمات
    pickupNameController.dispose();
    pickupPhoneController.dispose();
    pickupEmailController.dispose();
    pickupNoteController.dispose();

    deliveryNameController.dispose();
    deliveryPhoneController.dispose();
    deliveryEmailController.dispose();
    deliveryNoteController.dispose();

    conditionsController.dispose();
    super.onClose();
  }


  void initializePricingData(http.Response response) {
    try {
      final decodedBody = jsonDecode(response.body);
      final List<dynamic> dataJson = decodedBody['data'] ?? [];

      pricingMethods.value = dataJson
          .map((item) => PricingMethodModel.fromJson(item))
          .toList();

      if (isEditMode.value && taskModelForEdit.value != null) {
        loadTaskDataForEdit(taskModelForEdit.value!);
      } else {
        // وضع الإنشاء: اختيار طريقة التسعير الافتراضية
        if (pricingMethods.isNotEmpty) {
          selectedPricingMethod.value = pricingMethods.first;
          if (selectedPricingMethod.value!.type == 'points' && selectedPricingMethod.value!.params.isNotEmpty) {
            selectedPricingParam.value = selectedPricingMethod.value!.params.first;
          }
        }
      }

    } catch (e) {
      Get.snackbar("خطأ تهيئة", "فشل تحليل بيانات التسعير: $e", backgroundColor: Colors.red);
      print("Error initializing pricing data: $e");
    }
  }

  // دالة لملء الحقول ببيانات المهمة المحفوظة
  void loadTaskDataForEdit(TaskModel task) {
    // 1. تهيئة حقول الاستلام
    pickupNameController.text = task.pickup.contactName.value;
    pickupPhoneController.text = task.pickup.contactPhone.value;
    // لا يوجد حقل إيميل في TaskModel، نتركه فارغاً أو نضبطه هنا إذا أضيف
    pickupAddress.value = task.pickup.address.value;
    pickupLatitude.value = task.pickup.lat.value;
    pickupLongitude.value = task.pickup.lng.value;
    if (task.pickup.scheduledTime.isNotEmpty) {
      pickupBeforeDate.value = DateTime.tryParse(task.pickup.scheduledTime.value.split(' ')[0]);
    }
    pickupNoteController.text = task.pickup.note.value;

    // 2. تهيئة حقول التسليم
    deliveryNameController.text = task.delivery.contactName.value;
    deliveryPhoneController.text = task.delivery.contactPhone.value;
    deliveryAddress.value = task.delivery.address.value;
    deliveryLatitude.value = task.delivery.lat.value;
    deliveryLongitude.value = task.delivery.lng.value;
    if (task.delivery.scheduledTime.isNotEmpty) {
      deliveryBeforeDate.value = DateTime.tryParse(task.delivery.scheduledTime.value.split(' ')[0]);
    }
    deliveryNoteController.text = task.delivery.note.value;

    // 3. تهيئة الشروط
    // conditionsController.text = task.conditions.value; // إذا كان لديك هذا الحقل في TaskModel

    // 4. تهيئة طريقة التسعير
    final initialMethod = pricingMethods.firstWhereOrNull((m) => m.name == task.paymentMethod.value);
    selectedPricingMethod.value = initialMethod;

    if (initialMethod?.type == 'points' && initialMethod!.params.isNotEmpty) {
      selectedPricingParam.value = initialMethod.params.first;
    }
  }

  Map<String, dynamic> generatePayload() {
    if (!formKey.currentState!.validate()) {
      Get.snackbar("خطأ", "يرجى ملء جميع حقول العناوين والتواريخ المطلوبة.", snackPosition: SnackPosition.BOTTOM);
      return {};
    }

    final selectedMethod = selectedPricingMethod.value;
    if (selectedMethod == null) {
      Get.snackbar("خطأ", "يجب اختيار طريقة تسعير.", snackPosition: SnackPosition.BOTTOM);
      return {};
    }

    if (selectedMethod.type == 'points' && selectedPricingParam.value == null) {
      Get.snackbar("خطأ", "يجب اختيار نقطة انطلاق ووصول للتسعير.", snackPosition: SnackPosition.BOTTOM);
      return {};
    }

    String? formatDateTime(DateTime? dt) {
      if (dt == null) return null;
      return "${dt.toIso8601String().substring(0, 10)} 12:00:00";
    }

    final payload = {
      "pricing_method": selectedMethod.type == 'points'
          ? (selectedPricingParam.value?.id)
          : selectedMethod.id,

      // 🚨🚨 استخدام controller.text 🚨🚨
      "pickup_name": pickupNameController.text,
      "pickup_phone": pickupPhoneController.text,
      "pickup_email": pickupEmailController.text,
      "pickup_address": pickupAddress.value,
      "pickup_latitude": pickupLatitude.value,
      "pickup_longitude": pickupLongitude.value,
      "pickup_before": formatDateTime(pickupBeforeDate.value),
      "pickup_note": pickupNoteController.text,

      "delivery_name": deliveryNameController.text,
      "delivery_phone": deliveryPhoneController.text,
      "delivery_email": deliveryEmailController.text,
      "delivery_address": deliveryAddress.value,
      "delivery_latitude": deliveryLatitude.value,
      "delivery_longitude": deliveryLongitude.value,
      "delivery_before": formatDateTime(deliveryBeforeDate.value),
      "delivery_note": deliveryNoteController.text,

      "conditions": conditionsController.text,
    };

    if (isEditMode.value && taskModelForEdit.value != null) {
      payload['task_id'] = taskModelForEdit.value!.id.value;
    }

    return payload;
  }

  void selectLocation(BuildContext context, bool isPickup) async {
    double? initialLat = isPickup ? pickupLatitude.value : deliveryLatitude.value;
    double? initialLon = isPickup ? pickupLongitude.value : deliveryLongitude.value;

    if (initialLat == 0.0) initialLat = null;
    if (initialLon == 0.0) initialLon = null;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => MapPickerSimulationDialog(
        isPickup: isPickup,
        initialLat: initialLat,
        initialLng: initialLon,
      ),
    );

    if (result != null) {
      final double lat = result['lat'];
      final double lon = result['lon'];
      final String address = result['address'];

      if (isPickup) {
        pickupLatitude.value = lat;
        pickupLongitude.value = lon;
        pickupAddress.value = address;
        Get.snackbar("اختيار الموقع", "تم تحديد موقع الاستلام: ${address}");
      } else {
        deliveryLatitude.value = lat;
        deliveryLongitude.value = lon;
        deliveryAddress.value = address;
        Get.snackbar("اختيار الموقع", "تم تحديد موقع التسليم: ${address}");
      }
    }
  }
}

// ==========================================================
// 🖥️ الواجهة (ValidationTwoPage) 🖥️
// ==========================================================

class ValidationTwoPage extends StatefulWidget {
  final http.Response stepOneResponse;
  final TaskModel? taskModelForEdit; // بارامتر جديد للتعديل

  const ValidationTwoPage({
    super.key,
    required this.stepOneResponse,
    this.taskModelForEdit
  });

  @override
  State<ValidationTwoPage> createState() => _ValidationTwoPageState();
}

class _ValidationTwoPageState extends State<ValidationTwoPage> {
  // يتم استخدام .put لضمان وجود نسخة واحدة من المتحكم
  final ValidationTwoController controller = Get.put(ValidationTwoController());
  var resp;

  @override
  void initState() {
    super.initState();

    // 1. تهيئة وضع التعديل إن وجد
    if (widget.taskModelForEdit != null) {
      controller.setTaskModelForEdit(widget.taskModelForEdit!);
    }

    // 2. تحميل وتهيئة بيانات التسعير
    controller.initializePricingData(widget.stepOneResponse);
  }


  // دالة الإرسال الموحدة (تدعم الإنشاء والتعديل)
  Future<void> sendStepTwoPayload(BuildContext context, Map<String, dynamic> payload2, String token) async {
    // if (!controller.formKey.currentState!.validate()) {
    //   Get.snackbar("خطأ", "يرجى ملء جميع حقول العناوين والتواريخ المطلوبة.", snackPosition: SnackPosition.BOTTOM);
    //   return ;
    // }
    Map<String, dynamic> payload = globals.stepOnePayload;

    // تحديد نقطة النهاية (Endpoint)
    final String endpoint = "tasks/validate-step2";

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

    for (var key in payload2.keys) {
      // بما أن حقول الخطوة الثانية هي حقول نصية فقط (عناوين، تواريخ، تسعير)، نرسلها كحقول نصية
      request.fields[key] = payload2[key].toString();
    }

    try {
      http.StreamedResponse streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      var data = jsonDecode(response.body);

      global_methods.hideLoadingDialog();

      print("saeeeeeeeeeeeeeedddddddddd: $data");


      if (data["status"] == 200 ) {
        Get.snackbar("نجاح", "تم التحقق بنجاح", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green);
        // if (!isEdit) {
        globals.stepTowPayload = payload2;
        Get.to(() => AddTaskPage(stepTwoResponse: response));
        // } else {
        //   // العودة إلى قائمة المهام بعد التعديل
        //   Get.back();
        // }


      } else {
        print("saeeeeeeeeeeeeeedddddddddde: $data");

        Get.snackbar("خطأ في API", "فشل الإرسال. الاستجابة: ${data["message"] ?? 'Unknown error'}",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade600,
            colorText: Colors.white);
      }
    } catch (e) {
      print("saeeeeeeeeeeeeeeddddddddddee: $e");

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
        title: Text(controller.isEditMode.value ? "تعديل: العناوين والتسعير" : "الخطوة 2: العناوين والتسعير"),
        backgroundColor: MyColors.appBarColor,
      ),
      body: Form(
        key: controller.formKey,
        autovalidateMode: AutovalidateMode.disabled,
        // autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPricingSection(),
              const SizedBox(height: 30),
              _buildPickupDeliverySection(context, isPickup: true),
              const SizedBox(height: 30),
              _buildPickupDeliverySection(context, isPickup: false),
              const SizedBox(height: 30),
              _buildConditionsField(),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () async {
                  final payload = controller.generatePayload();
                  if (payload.isNotEmpty) {
                    print("Step 2 Payload: ${payload}");
                    // نرسل البايلود مع التوكن
                    await sendStepTwoPayload(context, payload, Token_pref.getToken()!);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.primaryColor,
                  // minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(
                    controller.isEditMode.value ? "تعديل وحفظ العناوين" : "المتابعة لإرسال المهمة",
                    style: const TextStyle(color: Colors.white)
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // دوال بناء الواجهة
  // --------------------------------------------------------------------------

  Widget _buildPricingSection() {
    return Obx(() {
      if (controller.pricingMethods.isEmpty) {
        return const Center(child: Text("لا تتوفر طرق تسعير."));
      }

      final methods = controller.pricingMethods.toList();
      final selectedMethod = controller.selectedPricingMethod.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("1. اختيار طريقة التسعير", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(),
          _buildDropdown<PricingMethodModel>(
            title: "طريقة التسعير",
            value: selectedMethod,
            items: methods.map((m) => DropdownMenuItem(value: m, child: Text(m.name))).toList(),
            onChanged: (newMethod) {
              if (newMethod != null) {
                controller.selectedPricingMethod.value = newMethod;
                if (newMethod.type == 'points' && newMethod.params.isNotEmpty) {
                  controller.selectedPricingParam.value = newMethod.params.first;
                } else {
                  controller.selectedPricingParam.value = null;
                }
              }
            },
          ),

          if (selectedMethod?.type == 'points' && selectedMethod!.params.isNotEmpty)
            _buildDropdown<PricingParam>(
              title: "نقطة الانطلاق والوصول",
              value: controller.selectedPricingParam.value,
              items: selectedMethod.params.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
              onChanged: (newParam) {
                controller.selectedPricingParam.value = newParam;
              },
            ),
        ],
      );
    });
  }

  Widget _buildPickupDeliverySection(BuildContext context, {required bool isPickup}) {
    final String title = isPickup ? "2. بيانات الاستلام (Pickup)" : "3. بيانات التسليم (Delivery)";
    // 🚨🚨 استخدام المتحكمات 🚨🚨
    final TextEditingController nameController = isPickup ? controller.pickupNameController : controller.deliveryNameController;
    final TextEditingController phoneController = isPickup ? controller.pickupPhoneController : controller.deliveryPhoneController;
    final TextEditingController emailController = isPickup ? controller.pickupEmailController : controller.deliveryEmailController;
    final TextEditingController noteController = isPickup ? controller.pickupNoteController : controller.deliveryNoteController;

    final RxString address = isPickup ? controller.pickupAddress : controller.deliveryAddress;
    final Rx<DateTime?> date = isPickup ? controller.pickupBeforeDate : controller.deliveryBeforeDate;


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Divider(),

        // 🚨🚨 تمرير المتحكمات مباشرة 🚨🚨
        _buildTextField(label: "اسم المسؤول", controller: nameController),
        _buildTextField(label: "رقم الهاتف", keyboardType: TextInputType.phone, controller: phoneController),
        _buildTextField(label: "البريد الإلكتروني (اختياري)", keyboardType: TextInputType.emailAddress, isRequired: false, controller: emailController),

        _buildLocationPicker(context, isPickup: isPickup, address: address),

        _buildDateTimePicker(label: "يجب أن يتم قبل", date: date, isRequired: true),
        _buildTextField(label: "ملاحظات إضافية (اختياري)", isRequired: false, maxLines: 3, controller: noteController),
      ],
    );
  }

  Widget _buildConditionsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("4. شروط المهمة (اختياري)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Divider(),
        _buildTextField(
            label: "الشروط",
            isRequired: false,
            maxLines: 4,
            controller: controller.conditionsController
        ),
      ],
    );
  }

  // 🚨🚨 تحديث دالة بناء حقل النص لاستخدام Controller 🚨🚨
  Widget _buildTextField({required String label, TextInputType keyboardType = TextInputType.text, required TextEditingController controller, bool isRequired = true, int maxLines = 1}) {
    // تم إزالة initialValue و onChanged و ValueKey لحل مشكلة فقدان التركيز (Focus)
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller, // استخدام المتحكم
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (val) => (isRequired && (val == null || val.isEmpty)) ? "${label} مطلوب" : null,
      ),
    );
  }

  Widget _buildDropdown<T>({required String title, required T? value, required List<DropdownMenuItem<T>> items, required ValueChanged<T?> onChanged}) {
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
        validator: (v) => v == null ? "يرجى اختيار قيمة لـ $title" : null,
      ),
    );
  }

  Widget _buildLocationPicker(BuildContext context, {required bool isPickup, required RxString address}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          controller.selectLocation(context, isPickup);
        },
        child: Obx(() => TextFormField(
          readOnly: true,
          enabled: false,
          controller: TextEditingController(
            text: address.value.isEmpty ? "انقر لاختيار الموقع" : address.value,
          ),
          decoration: InputDecoration(
            labelText: "اختيار الموقع على الخريطة",
            border: const OutlineInputBorder(),
            suffixIcon: Icon(address.value.isEmpty ? Icons.map : Icons.check_circle_outline, color: address.value.isEmpty ? Colors.grey : Colors.green),
            disabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          ),
          validator: (val) {
            if (address.value.isEmpty) {
              return "يجب تحديد الموقع على الخريطة";
            }
            return null;
          },
        )),
      ),
    );
  }

  Widget _buildDateTimePicker({required String label, required Rx<DateTime?> date, required bool isRequired}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Obx(() => InkWell(
        onTap: () async {
          final selectedDate = await showDatePicker(
            context: Get.context!,
            initialDate: date.value ?? DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2050),
          );
          if (selectedDate != null) {
            date.value = selectedDate;
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.calendar_today),
            errorText: (isRequired && date.value == null) ? "${label} مطلوب" : null,
          ),
          child: Text(
            date.value != null
                ? date.value!.toString().substring(0, 10)
                : "اختر التاريخ",
          ),
        ),
      )),
    );
  }
}