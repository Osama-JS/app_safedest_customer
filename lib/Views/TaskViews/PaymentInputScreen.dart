import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:save_dest_customer/Globals/MyColors.dart';
import '../../../Globals/global.dart' as globals;
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import '../../../shared_prff.dart';
import '../../../Globals/global_methods.dart' as global_methods;
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

import '../../Dashboard.dart';

class PaymentController extends GetxController {
  // الحالة: طريقة الدفع (افتراضياً: محفظة)
  // نستخدم RxString لتتبع التغييرات التفاعلية
  final RxString paymentMethod = 'banking'.obs;

  // مفتاح النموذج للتحقق من صحة المدخلات
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // متحكمات المدخلات للحقول الشرطية
  final receiptNumberController = TextEditingController();
  final noteController = TextEditingController();

  // متغير لتخزين اسم الملف المختار (لتمثيل ملف الصورة)
  final RxString selectedFile = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // إعداد القيم الأولية
    receiptNumberController.text = '';
    noteController.text = '';
  }

  @override
  void onClose() {
    receiptNumberController.dispose();
    noteController.dispose();
    super.onClose();
  }

  // تحديث طريقة الدفع
  void setPaymentMethod(String method) {
    paymentMethod.value = method;
    // مسح الحقول عند التبديل لضمان عدم إرسال بيانات خاطئة
    receiptNumberController.clear();
    selectedFile.value = '';
    noteController.clear();
  }

  // دالة وهمية لالتقاط الملف (في تطبيق Flutter حقيقي، سيتم استخدام file_picker)
  void pickReceiptImage() {
    // محاكاة اختيار ملف
    // if (paymentMethod.value == 'banking') {
      selectedFile.value = 'receipt_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      // Get.snackbar(
      //   'تم الاختيار',
      //   'تم اختيار الملف: ${selectedFileName.value}',
      //   snackPosition: SnackPosition.BOTTOM,
      //   backgroundColor: Colors.green,
      //   colorText: Colors.white,
      // );
    // }
  }

  // تجهيز البيانات للإرسال (Payload)
  Map<String, dynamic> generatePayload() {
    if (!formKey.currentState!.validate()) {
      return {'error': 'الرجاء ملء جميع الحقول المطلوبة بشكل صحيح.'};
    }

    final Map<String, dynamic> payload = {
      'payment_method': paymentMethod.value,
    };

    if (paymentMethod.value == 'banking') {
      payload['receipt_number'] = receiptNumberController.text;
      // نستخدم اسم الملف كقيمة رمزية هنا
      // payload['receipt_image'] = selectedFile.value.isNotEmpty ? 'file' : null;
      payload['note'] = noteController.text.isNotEmpty ? noteController.text : null;

      if(selectedFile.value!=''&&!selectedFile.value.startsWith("http")) {
        payload['receipt_image']=selectedFile.value;
      }
    }

    return payload;
  }
}



class PaymentScreen extends StatelessWidget {
  int taskId;
  PaymentScreen({super.key,required this.taskId});

  // تهيئة المتحكم
  final PaymentController controller = Get.put(PaymentController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('الدفع',style: TextStyle(color: Colors.white),),
        backgroundColor: MyColors.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'اختَر طريقة الدفع:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 15),

              // 1. طريقة الدفع (payment_method)
              Obx(() => Row(
                children: [

                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('تحويل بنكي'),
                      value: 'banking',
                      groupValue: controller.paymentMethod.value,
                      onChanged: (val) => controller.setPaymentMethod(val!),
                      activeColor: MyColors.primaryColor,
                    ),
                  ),

                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('محفظة'),
                      value: 'wallet',
                      groupValue: controller.paymentMethod.value,
                      onChanged: (val) => controller.setPaymentMethod(val!),
                      activeColor: Colors.green,
                    ),
                  ),
                ],
              )),

              const SizedBox(height: 30),

              // 2. الحقول الشرطية للتحويل البنكي
              Obx(() => controller.paymentMethod.value == 'banking'
                  ?
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Divider(),
                  const SizedBox(height: 10),
                  // const Text(
                  //   'بيانات التحويل البنكي (مطلوبة):',
                  //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.red),
                  //   textAlign: TextAlign.right,
                  // ),
                  // const SizedBox(height: 15),

                  // رقم الإيصال (receipt_number)
                  TextFormField(
                    controller: controller.receiptNumberController,
                    decoration: const InputDecoration(
                      labelText: 'رقم الإيصال / مرجع التحويل',
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                      suffixIcon: Icon(Icons.receipt_long),
                    ),
                    textAlign: TextAlign.right,
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال رقم الإيصال.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),

                  // صورة الإيصال (receipt_image)
                  // Container(
                  //   decoration: BoxDecoration(
                  //     border: Border.all(color: Colors.grey.shade400),
                  //     borderRadius: BorderRadius.circular(10),
                  //   ),
                  //   padding: const EdgeInsets.all(12),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: [
                  //       Obx(() => Text(
                  //         controller.selectedFile.value.isEmpty
                  //             ? 'لم يتم اختيار ملف'
                  //             : controller.selectedFile.value,
                  //         style: TextStyle(color: controller.selectedFile.value.isEmpty ? Colors.red : Colors.green),
                  //       )),
                  //       ElevatedButton.icon(
                  //         onPressed: controller.pickReceiptImage,
                  //         icon: const Icon(Icons.upload_file),
                  //         label: const Text('تحميل الإيصال'),
                  //         style: ElevatedButton.styleFrom(
                  //           backgroundColor: Colors.indigo,
                  //           foregroundColor: Colors.white,
                  //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  _buildFilePicker( controller.selectedFile),

                  // ملاحظة: لا يوجد حقل 'Required' مباشر لـ 'receipt_image' في Flutter،
                  // لكن التحقق يتم عبر دالة `generatePayload` للتأكد من اختيار ملف.

                  const SizedBox(height: 15),

                  // ملاحظة (note)
                  TextFormField(
                    controller: controller.noteController,
                    decoration: const InputDecoration(
                      labelText: 'ملاحظات إضافية (اختياري)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                      alignLabelWithHint: true,
                    ),
                    textAlign: TextAlign.right,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                ],
              )
                  : Container()), // إخفاء الحقول إذا لم يكن "banking"

              const SizedBox(height: 20),

              // زر الإرسال
              ElevatedButton(
                onPressed: () async{
                  final payload = controller.generatePayload();
                  if (payload.isNotEmpty) {
                    print("payment Payload: ${payload}");
                    await sendPayload(context, payload, Token_pref.getToken()!);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'إرسال بيانات الدفع',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
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
          Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("تحميل الإيصال"),

          Obx(()=> ElevatedButton.icon(
            onPressed: _pickFile,
            icon: Icon(imageUrl.value.isEmpty ? Icons.upload_file : Icons.check_circle, color: Colors.white),
            label: Text(imageUrl.value.isEmpty ? "اختر ملف" : "تغيير الملف المختار", style: const TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: imageUrl.value.isEmpty ? Colors.blue.shade700 : Colors.green.shade700),
          ),
          ),

        ],
      );
  }



  Future<void> sendPayload(BuildContext context, Map<String, dynamic> payload, String token) async {

    final String endpoint = "initiate-payment";
    final url = Uri.parse(globals.public_uri + endpoint);

    if (!await global_methods.isInternetAvailable()) {
      global_methods.errorView(context, 'checkInternetConnection'.tr);
      return;
    }

    global_methods.showDialogLoading(context: context);

    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Language'] = global_methods.getLanguage();

    request.fields['id'] = taskId.toString();
    request.fields['payment_method'] = payload['payment_method'].toString();
    request.fields['receipt_number'] = payload['receipt_number'].toString();
    request.fields['note'] = payload['note'].toString();
    request.fields['vehicles'] = jsonEncode(payload['vehicles']);


    String imageValue = payload["receipt_image"].toString();

    if (imageValue.isNotEmpty) {
      File file = File(imageValue);
      if (await file.exists()) {
        var multipartFile = await http.MultipartFile.fromPath(
          "receipt_image",
          imageValue,
          filename: basename(imageValue),
        );
        request.files.add(multipartFile);
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
      if (data["status"] == 1 ) {

        Get.snackbar(
          "success_title".tr,
          data["message"],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
        );

        // العودة إلى لوحة التحكم
        Get.offAll(() => Dashboard());
        // global_methods.successView(context, data["message"]);


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

}
