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


class AddTaskController extends GetxController {

  // 🏆 بيانات التسعير المُستلمة من API الخطوة الثانية
  final Rx<PricingSummaryModel?> pricingSummary = Rx<PricingSummaryModel?>(null);
  // 🏆 متغيرات الإرسال النهائي (خيارات المزايدة)
  final RxBool included = true.obs; // القيمة الافتراضية
  final RxDouble maxPrice = 0.0.obs;
  final RxDouble minPrice = 0.0.obs;
  final RxString notePrice = ''.obs;

  // 💡 حقول الصور (يجب تعيين قيم Base64 لها في الخطوة الأولى)
  // سنفترض وجود هذه القيم في المتحكم أو يتم جلبها من مكان تخزين
  final RxString pickupImageBase64 = "MOCK_PICKUP_IMAGE_BASE64_VALUE".obs;
  final RxString deliveryImageBase64 = "MOCK_DELIVERY_IMAGE_BASE64_VALUE".obs;

// 💡 تهيئة ملخص التسعير وتعيين القيم الأولية للمزايدة
  void setPricingSummary(http.Response response) {
    try {
      final decodedBody = jsonDecode(response.body);

      // 🚨🚨 التعديل الصحيح الآن 🚨🚨: توقع خريطة مباشرة من 'data'
      final dataJson = decodedBody['data'] as Map<String, dynamic>?;

      if (dataJson != null) {
        // نستخدم ملخص التسعير الذي يمثل ملخص التسعير الذي يظهر في الواجهة
        // نمرر الخريطة مباشرة إلى نموذج PricingSummaryModel
        pricingSummary.value = PricingSummaryModel.fromJson(dataJson);

        // تعيين السعر الأقصى والادنى بناءً على السعر الكلي (كافتراض 120% و 80%)
        final total = pricingSummary.value!.totalPrice;
        maxPrice.value = (total * 1.2).ceilToDouble(); // تقريب للأعلى
        minPrice.value = (total * 0.8).floorToDouble(); // تقريب للأسفل
      } else {
        Get.snackbar("تحذير", "بيانات التسعير المستلمة فارغة.", backgroundColor: Colors.orange);
      }
    } catch (e) {
      Get.snackbar("خطأ تحميل", "فشل تحميل ملخص التسعير: $e", backgroundColor: Colors.red);
      print("Error loading pricing summary: $e");
    }
  }
  // 🏆 دالة تجميع الحمولة النهائية للإرسال (POST /tasks/add)
  Map<String, dynamic> generateFinalPayload() {

    // 💡 قراءة الحمولة من المتغيرات العامة (نفترض أنها خرائط جاهزة)
    final stepOne = globals.stepOnePayload as Map<String, dynamic>? ?? {};
    final stepTwo = globals.stepTowPayload as Map<String, dynamic>? ?? {};

    // 🏆 تجميع الحمولة النهائية
    final finalPayload = <String, dynamic>{
      // 1. دمج بيانات الخطوة الثانية (العناوين، التواريخ، الشروط، pricing_method)
      // ...stepTwo,

      // 2. دمج حقول محددة من الخطوة الأولى
      // "vehicles": stepOne['vehicles'] ?? [],
      // "additional_fields": stepOne['additional_fields'] ?? {},

      // 3. إضافة حقول الصور (Base64)
      "pickup_image": pickupImageBase64.value,
      "delivery_image": deliveryImageBase64.value,

      // 4. دمج بيانات الخطوة الثالثة (المزايدة)
      "max_price": maxPrice.value,
      "min_price": minPrice.value,
      "note_price": notePrice.value,
      "included": included.value,
    };

    // 💡 تنظيف البايلود من الحقول غير المطلوبة (مثل 'template' من الخطوة 1)
    finalPayload.remove('template');
    finalPayload.removeWhere((key, value) => value == null || (value is String && value.isEmpty) || (value is double && value == 0.0) || (value is int && value == 0));

    return finalPayload;
  }


  Future<void> sendFinalTask(BuildContext context,  String token) async {

    Map<String, dynamic> payload = globals.stepOnePayload;
    Map<String, dynamic> payload2 = globals.stepTowPayload;
    final payload3 = generateFinalPayload();

    // تحديد نقطة النهاية (Endpoint)
    final String endpoint = "asks/add";

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
    for (var key in payload3.keys) {
      // بما أن حقول الخطوة الثانية هي حقول نصية فقط (عناوين، تواريخ، تسعير)، نرسلها كحقول نصية
      request.fields[key] = payload3[key].toString();
    }

    try {
      http.StreamedResponse streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      var data = jsonDecode(response.body);

      global_methods.hideLoadingDialog();

      print("saeeeeeeeeeeeeeedddddddddd: ${response.body}");

      if (data["status"] == 200 ) {
        Get.snackbar("نجاح", "تم التحقق بنجاح", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green);
        // if (!isEdit) {
        Get.offAll(() => Dashboard());
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
      print("saeeeeeeeeeeeeeeddddddddddث: $e");

      Get.snackbar("خطأ الإرسال", "حدث خطأ أثناء الاتصال بالخادم: $e",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white);
      global_methods.hideLoadingDialog();
    }
  }





}
// 💡 يجب إدراج النماذج والمتحكمات المطلوبة في هذا الملف أو استيرادها
// نفترض هنا أن المتحكم والنموذج تم تعريفهما كما في القسمين السابقين.

class AddTaskPage extends StatelessWidget {
  final http.Response stepTwoResponse;

  AddTaskPage({
    super.key,
    required this.stepTwoResponse,
  });

  // 💡 استخدام نفس المتحكم المعرّف
  final AddTaskController controller = Get.put(AddTaskController());

  @override
  Widget build(BuildContext context) {
    // تحميل ملخص التسعير عند بناء الصفحة
    controller.setPricingSummary(stepTwoResponse);

    return Scaffold(
      appBar: AppBar(
        title: const Text("الخطوة 3: المراجعة النهائية"),
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
                _buildAdvertisedOptions(), // خيارات max/min price
              ] else ...[
                const Center(child: CircularProgressIndicator()),
              ],

              const SizedBox(height: 30),

              // 🏆 زر الإرسال النهائي
              ElevatedButton(
                onPressed: summary != null ? () async {
                  // استدعاء دالة الإرسال النهائية
                  controller.sendFinalTask(context, Token_pref.getToken()!);
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.primaryColor,
                  // minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("إرسال المهمة النهائية", style: TextStyle(color: Colors.white, fontSize: 18)),
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
             Text("ملخص التسعير", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: MyColors.primaryColor)),
            const Divider(height: 20),
            _buildDetailRow("طريقة التسعير", summary.pricingMethod),
            _buildDetailRow("المسافة المقدرة", "${summary.distance} كم"),

            // عرض تفاصيل الـ Breakdown
            ...summary.breakdown.entries.map((e) => _buildDetailRow(
                _formatBreakdownKey(e.key),
                "${e.value.toStringAsFixed(2)} ريال",
                isTotal: e.key == 'base_price'
            )),

            const Divider(height: 20),
            _buildDetailRow("الإجمالي المتوقع", "${summary.totalPrice.toStringAsFixed(2)} ريال", isTotal: true),
          ],
        ),
      ),
    );
  }

  // دالة مساعدة لتنسيق مفاتيح Breakdown
  String _formatBreakdownKey(String key) {
    switch(key) {
      case 'base_price': return 'السعر الأساسي';
      case 'service_fee': return 'رسوم الخدمة';
      case 'vat': return 'ضريبة القيمة المضافة';
      default: return key.replaceAll('_', ' ').capitalizeFirst ?? key;
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
        const Text("خيارات المزايدة (اختياري)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Divider(),

        // حقل الحد الأقصى للسعر
        _buildPriceField(
          label: "الحد الأقصى للسعر (للمزايدة)",
          initialValue: controller.maxPrice.value.toStringAsFixed(2),
          onChanged: (val) {
            controller.maxPrice.value = double.tryParse(val) ?? 0.0;
          },
        ),

        // حقل الحد الأدنى للسعر
        _buildPriceField(
          label: "الحد الأدنى للسعر (للمزايدة)",
          initialValue: controller.minPrice.value.toStringAsFixed(2),
          onChanged: (val) {
            controller.minPrice.value = double.tryParse(val) ?? 0.0;
          },
        ),

        // ملاحظات السعر
        _buildTextField(
            label: "ملاحظات حول التسعير (اختياري)",
            isRequired: false,
            maxLines: 2,
            initialValue: controller.notePrice.value,
            onChanged: (val) => controller.notePrice.value = val
        ),
      ],
    );
  }

  // دالة مساعدة لحقول إدخال السعر
  Widget _buildPriceField({required String label, required String initialValue, required ValueChanged<String> onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Obx(() => TextFormField(
        initialValue: controller.minPrice.value == 0.0 && controller.maxPrice.value == 0.0
            ? initialValue : (label.contains('الأقصى') ? controller.maxPrice.value.toStringAsFixed(2) : controller.minPrice.value.toStringAsFixed(2)),
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          suffixText: 'ريال',
          border: const OutlineInputBorder(),
        ),
        onChanged: onChanged,
      )),
    );
  }

  // دالة مساعدة لحقول النص العادية
  Widget _buildTextField({required String label, TextInputType keyboardType = TextInputType.text, required ValueChanged<String> onChanged, bool isRequired = true, int maxLines = 1, String? initialValue}) {
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
        validator: (val) => (isRequired && (val == null || val.isEmpty)) ? "${label} مطلوب" : null,
      ),
    );
  }
}



// 💡 يجب وضع هذا الكلاس في ملفه الخاص (مثل models/pricing_summary_model.dart)
// ولكن تم إدراجه هنا لضمان عمل الكود بشكل موحد.

class PricingSummaryModel {
  final double totalPrice;
  final double distance; // 🚨 تم تعديل النوع إلى double ليناسب الرد 15.62
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

    // إضافة العناصر التي تشكل Breakdown من الـ API مباشرة
    breakdownMap['distance_price'] = toDouble(json['distance_price']);
    breakdownMap['service_commission'] = toDouble(json['service_commission']);
    // يمكن إضافة ضريبة القيمة المضافة كعنصر مستقل في Breakdown إذا أردت فصله
    // breakdownMap['vat'] = toDouble(json['vat_commission']);
    return PricingSummaryModel(
      totalPrice: toDouble(json['total_price']),
      distance: toDouble(json['distance']), // تحويل إلى double
      pricingMethod: json['pricing_method'] ?? '',
      serviceCommission: toDouble(json['service_commission']),
      vatCommission: toDouble(json['vat_commission']),
      breakdown: breakdownMap, // استخدام Breakdown الجديد
    );
  }
}