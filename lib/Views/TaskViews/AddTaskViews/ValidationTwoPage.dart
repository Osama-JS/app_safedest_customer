import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
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

class ValidationTwoController extends GetxController {
  final Rx<TaskModel?> taskModelForEdit = Rx<TaskModel?>(null);
  final RxBool isEditMode = false.obs;

  final RxList<PricingMethodModel> pricingMethods = <PricingMethodModel>[].obs;
  final Rx<PricingMethodModel?> selectedPricingMethod = Rx<PricingMethodModel?>(null);
  final Rx<PricingParam?> selectedPricingParam = Rx<PricingParam?>(null);
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final RxString pickupImage = ''.obs;
  final RxString pickupAddress = ''.obs;
  final RxDouble pickupLatitude = 0.0.obs;
  final RxDouble pickupLongitude = 0.0.obs;
  final Rx<DateTime?> pickupBeforeDate = Rx<DateTime?>(null);

  final RxString deliveryImage = ''.obs;
  final RxString deliveryAddress = ''.obs;
  final RxDouble deliveryLatitude = 0.0.obs;
  final RxDouble deliveryLongitude = 0.0.obs;
  final Rx<DateTime?> deliveryBeforeDate = Rx<DateTime?>(null);

  late TextEditingController pickupNameController;
  late TextEditingController pickupPhoneController;
  late TextEditingController pickupEmailController;
  late TextEditingController pickupNoteController;

  late TextEditingController deliveryNameController;
  late TextEditingController deliveryPhoneController;
  late TextEditingController deliveryEmailController;
  late TextEditingController deliveryNoteController;

  late TextEditingController conditionsController;

  void setTaskModelForEdit(TaskModel taskModel) {
    taskModelForEdit.value = taskModel;
    isEditMode.value = true;
  }

  @override
  void onInit() {
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
      pricingMethods.add(PricingMethodModel(id: 0,name: "ضع سعرك",type: "handed",params: []));
      if (isEditMode.value && taskModelForEdit.value != null) {
        loadTaskDataForEdit(taskModelForEdit.value!);
      } else {
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

  void loadTaskDataForEdit(TaskModel task) {
    pickupNameController.text = task.pickup.contactName.value;
    pickupPhoneController.text = task.pickup.contactPhone.value;
    pickupAddress.value = task.pickup.address.value;
    pickupLatitude.value = task.pickup.lat.value;
    pickupLongitude.value = task.pickup.lng.value;
    pickupImage.value = task.pickup.image.value;
    print("dddddddd"+pickupLatitude.value.toString());
    print("dddddddd"+pickupLongitude.value.toString());
    if (task.pickup.scheduledTime.isNotEmpty) {
      pickupBeforeDate.value = DateTime.tryParse(task.pickup.scheduledTime.value.split(' ')[0]);
    }
    pickupNoteController.text = task.pickup.note.value;

    deliveryNameController.text = task.delivery.contactName.value;
    deliveryPhoneController.text = task.delivery.contactPhone.value;
    deliveryAddress.value = task.delivery.address.value;
    deliveryLatitude.value = task.delivery.lat.value;
    deliveryLongitude.value = task.delivery.lng.value;
    deliveryImage.value = task.delivery.image.value;
    if (task.delivery.scheduledTime.isNotEmpty) {
      deliveryBeforeDate.value = DateTime.tryParse(task.delivery.scheduledTime.value.split(' ')[0]);
    }
    deliveryNoteController.text = task.delivery.note.value;

    final initialMethod = pricingMethods.firstWhereOrNull((m) => m.id == task.pricingMethodId.value);
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

      if(pickupImage.value!=''&&!pickupImage.value.startsWith("http"))
      "pickup_image":pickupImage.value,

      if(deliveryImage.value!=''&&!deliveryImage.value.startsWith("http"))
      "delivery_image":deliveryImage.value,

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

class ValidationTwoPage extends StatefulWidget {
  final http.Response stepOneResponse;
  final TaskModel? taskModelForEdit;
  final int? taskIdForEdit;

  const ValidationTwoPage({
    super.key,
    required this.stepOneResponse,
    this.taskModelForEdit,
    this.taskIdForEdit
  });

  @override
  State<ValidationTwoPage> createState() => _ValidationTwoPageState();
}

class _ValidationTwoPageState extends State<ValidationTwoPage> {
  final ValidationTwoController controller = Get.put(ValidationTwoController());
  var resp;

  @override
  void initState() {
    super.initState();

    if (widget.taskModelForEdit != null) {
      controller.setTaskModelForEdit(widget.taskModelForEdit!);
    }

    controller.initializePricingData(widget.stepOneResponse);
  }

  Future<void> sendStepTwoPayload(BuildContext context, Map<String, dynamic> payload2, String token) async {
    Map<String, dynamic> payload = globals.stepOnePayload;

    final String endpoint = "tasks/validate-step2";
    final url = Uri.parse(globals.public_uri + endpoint);

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
    final Map<String, dynamic> additionalFields = payload['additional_fields'];
    Map<String, dynamic> textAndUrlFields = {};

    for (var key in additionalFields.keys) {
      var value = additionalFields[key];

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
        } else {
          textAndUrlFields[key] = fileValue;
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


    for (var key in payload2.keys) {
      if(key.contains("email")){
        if(payload2[key].toString()!="null"&&payload2[key].toString()!=""){
          request.fields[key] = payload2[key].toString();
        }
      }


      else if(key.contains("image")){


        String imageValue = payload2[key].toString();

        if (imageValue.isNotEmpty && !imageValue.startsWith('http')) {
          File file = File(imageValue);
          if (await file.exists()) {
            var multipartFile = await http.MultipartFile.fromPath(
              key,
              imageValue,
              filename: basename(imageValue),
            );
            request.files.add(multipartFile);
          }
        }


      }

      else {
        request.fields[key] = payload2[key].toString();
      }
    }

    for(var f in request.files){
      print("saeeeeeeeeeeeeeeeeedddddddddd file : ${f.field}");

      print("saeeeeeeeeeeeeeeeeedddddddddd file : ${f.filename}");

    }

    try {
      http.StreamedResponse streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      var data = jsonDecode(response.body);

      global_methods.hideLoadingDialog();
print("saeeeeeeeeeeeeeeeeedddddddddd$data");
      if (data["status"] == 200 ) {
        Get.snackbar("نجاح", "تم التحقق بنجاح", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green);
        globals.stepTowPayload = payload2;
        if(controller.isEditMode.value){
          Get.to(() => AddTaskPage(stepTwoResponse: response,taskModelForEdit: widget.taskModelForEdit,priceMethodId: controller.selectedPricingMethod.value!.id,));

        }else{
          Get.to(() => AddTaskPage(stepTwoResponse: response,priceMethodId: controller.selectedPricingMethod.value!.id));
        }
      } else {
        Get.snackbar("خطأ في API", "فشل الإرسال. الاستجابة: ${data["message"] ?? 'Unknown error'}",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade600,
            colorText: Colors.white);
      }
    } catch (e) {
      print("saeeeeeeeeeeeeeeeeedddddddddd$e");

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
                    await sendStepTwoPayload(context, payload, Token_pref.getToken()!);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.primaryColor,
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

        _buildTextField(label: "اسم المسؤول", controller: nameController),
        _buildTextField(label: "رقم الهاتف", keyboardType: TextInputType.phone, controller: phoneController),
        _buildTextField(label: "البريد الإلكتروني (اختياري)", keyboardType: TextInputType.emailAddress, isRequired: false, controller: emailController),

        _buildLocationPicker(context, isPickup: isPickup, address: address),

        _buildDateTimePicker(label: "يجب أن يتم قبل", date: date, isRequired: true),

        Text(isPickup ? "اختر صورة موقع الاستلام (اختياري)": "اختر صورة موقع التسليم (اختياري)"),
        _buildFilePicker(isPickup ? controller.pickupImage: controller.deliveryImage),

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

  Widget _buildTextField({required String label, TextInputType keyboardType = TextInputType.text, required TextEditingController controller, bool isRequired = true, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
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




  Widget _buildFilePicker(RxString imageUrl) {


    Future<void> _pickFile() async {


      // تحديد الامتدادات المسموح بها:
      final List<String> extensions =  ['jpg', 'jpeg', 'png'] ;
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: extensions,
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        imageUrl.value= filePath;


      }
    }

    return
      Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imageUrl.value.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              "الملف المختار: ${imageUrl.value.startsWith('http') ? "ملف قديم محفوظ" : imageUrl.value.split('/').last}",
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: imageUrl.value.startsWith('http') ? Colors.blue.shade700 : Colors.black87,
              ),
            ),
          ),
        Obx(()=> ElevatedButton.icon(
          onPressed: _pickFile,
          icon: Icon(imageUrl.value.isEmpty ? Icons.upload_file : Icons.check_circle, color: Colors.white),
          label: Text(imageUrl.value.isEmpty ? "اختر ملف" : "تغيير الملف المختار", style: const TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(backgroundColor: imageUrl.value.isEmpty ? Colors.blue.shade700 : Colors.green.shade700),
        ),
        ),

      ],
    ));
  }


}