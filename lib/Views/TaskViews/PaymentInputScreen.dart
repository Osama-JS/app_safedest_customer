import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:save_dest_customer/Globals/MyColors.dart';
import '../../../Globals/global.dart' as globals;
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import '../../../shared_prff.dart';
import '../../../Globals/global_methods.dart' as global_methods;
import 'dart:convert';
import 'dart:io';
import '../../Dashboard.dart';

class PaymentController extends GetxController {
  final RxString paymentMethod = 'banking'.obs;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final receiptNumberController = TextEditingController();
  final noteController = TextEditingController();
  final RxString selectedFile = ''.obs;

  @override
  void onInit() {
    super.onInit();
    receiptNumberController.text = '';
    noteController.text = '';
  }

  @override
  void onClose() {
    receiptNumberController.dispose();
    noteController.dispose();
    super.onClose();
  }

  void setPaymentMethod(String method) {
    paymentMethod.value = method;
    receiptNumberController.clear();
    selectedFile.value = '';
    noteController.clear();
  }

  void pickReceiptImage() {
    selectedFile.value = 'receipt_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
  }

  Map<String, dynamic> generatePayload() {
    if (!formKey.currentState!.validate()) {
      Get.snackbar(
        'error'.tr,
        'pleaseFillRequiredFields'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
      return {};
    }

    final Map<String, dynamic> payload = {
      'payment_method': paymentMethod.value,
    };

    if (paymentMethod.value == 'banking') {
      payload['receipt_number'] = receiptNumberController.text;
      payload['note'] = noteController.text.isNotEmpty ? noteController.text : null;

      if(selectedFile.value != '' && !selectedFile.value.startsWith("http")) {
        payload['receipt_image'] = selectedFile.value;
      }
    }

    return payload;
  }
}

class PaymentScreen extends StatelessWidget {
  int taskId;
  PaymentScreen({super.key, required this.taskId});

  final PaymentController controller = Get.put(PaymentController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'payment'.tr,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: MyColors.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'choosePaymentMethod'.tr,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 15),

              Obx(() => Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text('bankTransfer'.tr),
                      value: 'banking',
                      groupValue: controller.paymentMethod.value,
                      onChanged: (val) => controller.setPaymentMethod(val!),
                      activeColor: MyColors.primaryColor,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text('wallet'.tr),
                      value: 'wallet',
                      groupValue: controller.paymentMethod.value,
                      onChanged: (val) => controller.setPaymentMethod(val!),
                      activeColor: Colors.green,
                    ),
                  ),
                ],
              )),

              const SizedBox(height: 30),

              Obx(() => controller.paymentMethod.value == 'banking'
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Divider(),
                  const SizedBox(height: 10),
                  Text(
                    'bankingDataRequired'.tr,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.red
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 15),

                  TextFormField(
                    controller: controller.receiptNumberController,
                    decoration: InputDecoration(
                      labelText: 'receiptNumber'.tr,
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                      suffixIcon: const Icon(Icons.receipt_long),
                    ),
                    textAlign: TextAlign.right,
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'pleaseEnterReceiptNumber'.tr;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),

                  _buildFilePicker(controller.selectedFile),

                  const SizedBox(height: 15),

                  TextFormField(
                    controller: controller.noteController,
                    decoration: InputDecoration(
                      labelText: 'additionalNotesOptional'.tr,
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                      alignLabelWithHint: true,
                    ),
                    textAlign: TextAlign.right,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                ],
              )
                  : Container()),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () async {
                  final payload = controller.generatePayload();
                  if (payload.isNotEmpty) {
                    await sendPayload(context, payload, Token_pref.getToken()!);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)
                  ),
                ),
                child: Text(
                  'sendPaymentData'.tr,
                  style: const TextStyle(fontSize: 18),
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
      final List<String> extensions = ['jpg', 'jpeg', 'png'];
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: extensions,
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        imageUrl.value = filePath;
        Get.snackbar(
          'fileSelected'.tr,
          'fileSelectedMessage'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'uploadReceipt'.tr,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Obx(() => Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                imageUrl.value.isEmpty ? 'noFileChosen'.tr : imageUrl.value.split('/').last,
                style: TextStyle(
                  color: imageUrl.value.isEmpty ? Colors.grey : Colors.green,
                  fontWeight: imageUrl.value.isEmpty ? FontWeight.normal : FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _pickFile,
                icon: Icon(
                  imageUrl.value.isEmpty ? Icons.upload_file : Icons.check_circle,
                  color: Colors.white,
                ),
                label: Text(
                  imageUrl.value.isEmpty ? 'chooseFile'.tr : 'changeSelectedFile'.tr,
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: imageUrl.value.isEmpty ? Colors.blue.shade700 : Colors.green.shade700,
                ),
              ),
            ],
          ),
        )),
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

    if (payload['payment_method'] == 'banking') {
      request.fields['receipt_number'] = payload['receipt_number'].toString();
      request.fields['note'] = payload['note']?.toString() ?? '';
    }

    if (payload['receipt_image'] != null) {
      String imageValue = payload["receipt_image"].toString();
      if (imageValue.isNotEmpty && !imageValue.startsWith("http")) {
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
    }

    try {
      http.StreamedResponse streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      var data = jsonDecode(response.body);

      global_methods.hideLoadingDialog();

      if (data["status"] == 1) {
        Get.snackbar(
          'success'.tr,
          data["message"],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        Get.offAll(() => Dashboard());
      } else {
        Get.snackbar(
          'apiError'.tr,
          "${'sendFailed'.tr}: ${data["message"] ?? 'Unknown error'}",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'sendError'.tr,
        "${'connectionError'.tr}: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
      global_methods.hideLoadingDialog();
    }
  }
}