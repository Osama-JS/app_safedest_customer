import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:save_dest_customer/Dashboard.dart';
import '../../../Globals/MyColors.dart';
import '../../../Globals/global_methods.dart' as global_methods;
import '../../../Services/InitialService.dart';
import '../../../shared_prff.dart';
import 'package:http/http.dart' as http;
import '../../../Globals/global.dart' as globals;
import '../../Maps/MapPickerSimulationDialog.dart';
import 'package:path/path.dart';

// 💡 استيراد موديل المهمة
import '../../../Models/TaskModel.dart'; // نفترض أن هذا هو المسار الصحيح

// --- Modals (Pricing Summary Model) ---

class PricingSummaryModel {
  final double totalPrice;
  final double distance;
  final String pricingMethod;
  final double serviceCommission;
  final double vatCommission;
  final Map<String, double> breakdown;

  PricingSummaryModel({
    required this.totalPrice,
    required this.distance,
    required this.pricingMethod,
    required this.serviceCommission,
    required this.vatCommission,
    required this.breakdown,
  });

  factory PricingSummaryModel.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is double) return val;
      if (val is int) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    final breakdownMap = <String, double>{};

    // إضافة العناصر التي تشكل Breakdown
    breakdownMap['base_price'] = toDouble(
      json['base_price'],
    ); // تم إضافته ليتوافق مع العرض
    breakdownMap['distance_price'] = toDouble(json['distance_price']);
    breakdownMap['service_commission'] = toDouble(json['service_commission']);
    breakdownMap['vat'] = toDouble(json['vat_commission']);

    return PricingSummaryModel(
      totalPrice: toDouble(json['total_price']),
      distance: toDouble(json['distance']),
      pricingMethod: json['pricing_method'] ?? '',
      serviceCommission: toDouble(json['service_commission']),
      vatCommission: toDouble(json['vat_commission']),
      breakdown: breakdownMap,
    );
  }
}

// --- Controller (AddTaskController) ---

class AddTaskController extends GetxController {
  // 🏆 حالة التعديل
  final RxBool isEditMode = false.obs;
  final RxInt taskIdForEdit = 0.obs;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // 🏆 بيانات التسعير المُستلمة من API الخطوة الثانية
  final Rx<PricingSummaryModel?> pricingSummary = Rx<PricingSummaryModel?>(
    null,
  );

  // 🏆 متغيرات الإرسال النهائي (خيارات المزايدة)
  final RxBool included = true.obs; // القيمة الافتراضية
  final RxDouble maxPrice = 0.0.obs;
  final RxDouble minPrice = 0.0.obs;
  final RxString notePrice = ''.obs;
  final RxBool showPriceOption = false.obs;

  // 💡 حقول الصور (يجب تعيين قيم Base64 لها في الخطوة الأولى)
  final RxString pickupImageBase64 = "MOCK_PICKUP_IMAGE_BASE64_VALUE".obs;
  final RxString deliveryImageBase64 = "MOCK_DELIVERY_IMAGE_BASE64_VALUE".obs;

  // 💡 دالة لتهيئة وضع التعديل وتحميل بيانات المزايدة إذا كانت متاحة
  void setTaskModelForEdit(TaskModel taskModel) {
    isEditMode.value = true;
    taskIdForEdit.value = taskModel.id.value;

    // 2. استخراج وتهيئة بيانات الأسعار من حقل 'ad'
    final adDetails = taskModel.ad.value;

    if (adDetails != null) {
      // تعيين القيم من ad إلى المتغيرات المراقبة

      // تهيئة maxPrice و minPrice
      // نستخدم القيمة الافتراضية 0.0 في حال كانت القيم null
      maxPrice.value = adDetails.max;
      minPrice.value = adDetails.min;

      // تهيئة notePrice
      notePrice.value = adDetails.description;

      // تهيئة showPriceOption
      // نفترض أن الخيار يجب أن يظهر إذا كانت أي من القيم (min/max) أكبر من الصفر
      // أو إذا كان هناك وصف (notePrice)
      showPriceOption.value =
          adDetails.max > 0.0 ||
          adDetails.min > 0.0 ||
          adDetails.description.isNotEmpty;
    } else {
      // إذا كان حقل 'ad' فارغاً، يتم مسح القيم والتأكد من عدم عرض الخيار
      maxPrice.value = 0.0;
      minPrice.value = 0.0;
      notePrice.value = '';
      showPriceOption.value = false;
    }
  }

  // 💡 تهيئة ملخص التسعير وتعيين القيم الأولية للمزايدة
  void setPricingSummary(http.Response response) {
    try {
      final decodedBody = jsonDecode(response.body);
      final dataJson = decodedBody['data'] as Map<String, dynamic>?;

      if (dataJson != null) {
        pricingSummary.value = PricingSummaryModel.fromJson(dataJson);
      } else {
        Get.snackbar(
          "warning".tr,
          "pricing_data_empty".tr,
          backgroundColor: Colors.orange,
        );
      }
    } catch (e) {
      Get.snackbar(
        "loading_error".tr,
        "${'failed_to_load_pricing'.tr}: $e",
        backgroundColor: Colors.red,
      );
      print("Error loading pricing summary: $e");
    }
  }

  // 🏆 دالة تجميع الحمولة النهائية للإرسال
  Map<String, dynamic> generateFinalPayload() {
    // 💡 قراءة الحمولة من المتغيرات العامة (نفترض أنها خرائط جاهزة)
    final stepOne = globals.stepOnePayload as Map<String, dynamic>? ?? {};
    final stepTwo = globals.stepTowPayload as Map<String, dynamic>? ?? {};

    // 🏆 دمج جميع الحمولة في خريطة واحدة
    final finalPayload = <String, dynamic>{
      // دمج جميع حقول الخطوة الثانية
      // ...stepTwo,

      // إضافة حقول الصور (Base64) - إذا كانت مطلوبة كحقول نصية
      // "pickup_image": pickupImageBase64.value,
      // "delivery_image": deliveryImageBase64.value,
    };

    // 🏆 إضافة بيانات الخطوة الثالثة (المزايدة) إذا تم تفعيلها
    if (showPriceOption.value) {
      finalPayload["max_price"] = maxPrice.value;
      finalPayload["min_price"] = minPrice.value;
      finalPayload["note_price"] = notePrice.value;
      finalPayload["included"] = included.value;
    }

    // 🏆 إضافة معرف المهمة إذا كنا في وضع التعديل
    if (isEditMode.value && taskIdForEdit.value != 0) {
      finalPayload['id'] = taskIdForEdit.value;
    }

    return finalPayload;
  }

  Future<void> sendFinalTask(BuildContext context, String token) async {
    // 💡 يتم جلب الحمولة الأولية (Step 1) لتحميل ملفات Multipart
    Map<String, dynamic> payload = globals.stepOnePayload;
    Map<String, dynamic> payload2 = globals.stepTowPayload;

    // 💡 يتم جلب الحمولة المدمجة (Step 2 + Step 3 + Edit ID)
    final payloadFinal = generateFinalPayload();

    // 🏆 تحديد نقطة النهاية بناءً على وضع التعديل/الإضافة
    final String endpoint = isEditMode.value ? "tasks/update" : "tasks";

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

    // 1. إضافة حقول الخطوة الأولى الثابتة (Template, Vehicles)
    request.fields['template'] = payload['template'].toString();
    request.fields['vehicles'] = jsonEncode(payload['vehicles']);

    // 2. معالجة الحقول الإضافية والملفات من الخطوة الأولى
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

    // 3. إضافة جميع حقول الحمولة النهائية (العناوين، التسعير، ID, المزايدة)
    for (var key in payloadFinal.keys) {
      request.fields[key] = payloadFinal[key].toString();
    }

    for (var key in payload2.keys) {
      if (key.contains("email")) {
        if (payload2[key].toString() != "null" &&
            payload2[key].toString() != "") {
          request.fields[key] = payload2[key].toString();
        }
      } else {
        request.fields[key] = payload2[key].toString();
      }
    }
    if (isEditMode.value) {
      request.fields['id'] = taskIdForEdit.value.toString();
    }

    try {
      http.StreamedResponse streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      var data = jsonDecode(response.body);

      global_methods.hideLoadingDialog();

      if (data["status"] == 200) {
        Get.snackbar(
          "success_title".tr,
          isEditMode.value
              ? "task_updated_successfully".tr
              : "task_added_successfully".tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
        );

        // العودة إلى لوحة التحكم
        Get.offAll(() => Dashboard());
      } else {
        Get.snackbar(
          "api_error".tr,
          "${'send_failed'.tr}. ${'response'.tr}: ${data["message"] ?? 'Unknown error'}",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "send_error".tr,
        "${'server_connection_error'.tr}: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
      global_methods.hideLoadingDialog();
    }
  }
}

// --- Page (AddTaskPage) ---

class AddTaskPage extends StatelessWidget {
  final http.Response stepTwoResponse;
  // 🏆 إضافة خاصية TaskModel? لدعم التعديل
  final TaskModel? taskModelForEdit;
  final int priceMethodId;

  AddTaskPage({
    super.key,
    required this.stepTwoResponse,
    this.taskModelForEdit,
    required this.priceMethodId,
  });

  final AddTaskController controller = Get.put(AddTaskController());

  @override
  Widget build(BuildContext context) {
    // 1. تهيئة وضع التعديل إذا تم تمرير موديل
    if (taskModelForEdit != null) {
      controller.setTaskModelForEdit(taskModelForEdit!);
    }

    // 2. تحميل ملخص التسعير
    controller.setPricingSummary(stepTwoResponse);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          controller.isEditMode.value
              ? "step_3_edit_review".tr
              : "step_3_final_review".tr,
        ),
        backgroundColor: MyColors.appBarColor,
      ),
      body: Obx(() {
        final summary = controller.pricingSummary.value;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (summary != null) ...[
                _buildSummaryCard(summary),
                const SizedBox(height: 30),

                // 🏆 خيار إضافة تسعيرة مناقصة (Bidding Option)
                // ListTile(
                //   contentPadding: EdgeInsets.zero,
                //   leading: Obx(() => Checkbox(
                //     value: controller.showPriceOption.value,
                //     onChanged: (bool? value) {
                //       controller.showPriceOption.value = value ?? false;
                //     },
                //   )),
                //   title: Text("add_bidding_price".tr),
                // ),
                const SizedBox(height: 10),

                if (priceMethodId == 0)
                  Form(
                    key: controller.formKey, // ربط المفتاح بالنموذج
                    child: _buildAdvertisedOptions(),
                  ),
              ] else ...[
                const Center(child: CircularProgressIndicator()),
              ],

              const SizedBox(height: 30),

              // 🏆 زر الإرسال النهائي
              ElevatedButton(
                onPressed: summary != null
                    ? () async {
                        bool isValid = true;
                        if (priceMethodId == 0) {
                          isValid = controller.formKey.currentState!.validate();
                        }

                        if (isValid) {
                          await controller.sendFinalTask(
                            context,
                            Token_pref.getToken()!,
                          );
                        }

                        // await controller.sendFinalTask(context, Token_pref.getToken()!);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.primaryColor,
                  // minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(
                  controller.isEditMode.value
                      ? "save_changes".tr
                      : "send_final_task".tr,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // 🏆 عرض ملخص التسعير
  Widget _buildSummaryCard(PricingSummaryModel summary) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "pricing_summary".tr,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: MyColors.primaryColor,
              ),
            ),
            const Divider(height: 20),
            _buildDetailRow("pricing_method".tr, summary.pricingMethod),
            _buildDetailRow(
              "estimated_distance".tr,
              "${summary.distance.toStringAsFixed(2)} ${'km'.tr}",
            ),

            // عرض تفاصيل الـ Breakdown
            ...summary.breakdown.entries.map(
              (e) => _buildDetailRow(
                _formatBreakdownKey(e.key),
                "${e.value.toStringAsFixed(2)} ${'riyal'.tr}",
                isTotal: e.key == 'base_price',
              ),
            ),

            const Divider(height: 20),
            _buildDetailRow(
              "expected_total".tr,
              "${summary.totalPrice.toStringAsFixed(2)} ${'riyal'.tr}",
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  // دالة مساعدة لتنسيق مفاتيح Breakdown
  String _formatBreakdownKey(String key) {
    switch (key) {
      case 'base_price':
        return 'base_price'.tr;
      case 'distance_price':
        return 'distance_price'.tr;
      case 'service_commission':
        return 'service_commission'.tr;
      case 'vat':
        return 'vat'.tr;
      default:
        return key.replaceAll('_', ' ').capitalizeFirst ?? key;
    }
  }

  // دالة مساعدة لعرض تفاصيل السعر
  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? MyColors.primaryColor : Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? MyColors.primaryColor : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // 🏆 عرض خيارات التسعير (max/min price)
  Widget _buildAdvertisedOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "bidding_options".tr,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Divider(),

        // حقل الحد الأقصى للسعر
        _buildPriceField(
          label: "max_price".tr,
          currentValue: controller.maxPrice,
          onChanged: (val) {
            controller.maxPrice.value = double.tryParse(val) ?? 0.0;
          },
        ),

        // حقل الحد الأدنى للسعر
        _buildPriceField(
          label: "min_price".tr,
          currentValue: controller.minPrice,
          onChanged: (val) {
            controller.minPrice.value = double.tryParse(val) ?? 0.0;
          },
        ),

        // ملاحظات السعر
        _buildTextField(
          label: "pricing_notes".tr,
          isRequired: false,
          maxLines: 2,
          initialValue: controller.notePrice.value,
          onChanged: (val) => controller.notePrice.value = val,
        ),
      ],
    );
  }

  // في كلاس AddTaskPage

  // دالة مساعدة لحقول إدخال السعر
  Widget _buildPriceField({
    required String label,
    required RxDouble currentValue,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Obx(
        () => TextFormField(
          initialValue: currentValue.value == 0.0
              ? ''
              : currentValue.toStringAsFixed(2),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: label,
            suffixText: 'riyal'.tr,
            border: const OutlineInputBorder(),
          ),
          onChanged: onChanged,
          // 🏆 منطق التحقق: يجب أن تكون القيمة موجبة
          validator: (val) {
            final double? price = double.tryParse(val ?? '');
            if (price == null || price <= 0) {
              return "enter_valid_positive_price".trParams({'field': label});
            }
            return null;
          },
        ),
      ),
    );
  }

  // دالة مساعدة لحقول النص العادية
  Widget _buildTextField({
    required String label,
    TextInputType keyboardType = TextInputType.text,
    required ValueChanged<String> onChanged,
    bool isRequired = true,
    int maxLines = 1,
    String? initialValue,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: initialValue,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onChanged: onChanged,
        validator: (val) => (isRequired && (val == null || val.isEmpty))
            ? "field_required".trParams({'field': label})
            : null,
      ),
    );
  }
}
