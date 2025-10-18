

import 'package:get/get.dart';

import '../../shared_prff.dart';
import '../../Globals/global_methods.dart' as global_methods;
import '../Helpers/WalletHelper.dart';
import '../Models/TransactionModel.dart';

class WalletController extends GetxController {



  RxInt walletId = 0.obs;
  RxBool walletStatus = false.obs;
  RxDouble walletBalance = 0.0.obs;
  RxString walletCurrency = ''.obs;

  RxDouble totalDebit = 0.0.obs;
  RxDouble totalCredit = 0.0.obs;
  RxDouble netBalance = 0.0.obs;

  RxList<TransactionModel> transactionDataList = <TransactionModel>[].obs;

  RxBool isLoading = true.obs;

  WalletHelper helperData = WalletHelper();

  @override
  void onInit() {
    super.onInit();

    getData();
  }

  void getData() async {
    try {
      print("ffffffffffffffffffffffff0");
      isLoading.value = true;
      var data = await helperData.getData(Token_pref.getToken()); // الكود الأصلي


      if (data["status"] == 200) {
        walletId.value = data["data"]["wallet"]["id"] ?? 0;
        walletStatus.value = data["data"]["wallet"]["status"] ?? false;
        walletBalance.value = (data["data"]["wallet"]["balance"] ?? 0).toDouble();
        walletCurrency.value = data["data"]["wallet"]["currency"] ?? '';

        totalDebit.value = (data["data"]["statistics"]["total_debit"] ?? 0).toDouble();
        totalCredit.value = (data["data"]["statistics"]["total_credit"] ?? 0).toDouble();
        netBalance.value = (data["data"]["statistics"]["net_balance"] ?? 0).toDouble();

        final List<dynamic> dataListJson = data["data"]["recent_transactions"];
        transactionDataList.clear();
        transactionDataList.value = dataListJson.map((item) => TransactionModel.fromJson(item)).toList();
      }
    } catch (e) {
      global_methods.sendError("WalletController : $e");
    } finally {
      isLoading.value = false;
    }
  }
}
