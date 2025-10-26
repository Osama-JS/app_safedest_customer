

import 'package:get/get.dart';

import '../../shared_prff.dart';
import '../../Globals/global_methods.dart' as global_methods;
import '../Helpers/WalletHelper.dart';
import '../Models/TransactionModel.dart';

class TransactionController extends GetxController {




  WalletHelper helperData =  WalletHelper();



  RxInt pressedIndex= 0.obs;
  RxBool isLoadingData = true.obs;

  RxList<TransactionModel> dataList = <TransactionModel>[].obs;

  RxInt currentPage = 1.obs;
  RxInt total= 0.obs;
  RxInt lastItem= 0.obs;
  RxBool isRefreshing = false.obs;
  RxBool isFirstTime = true.obs;
  RxString selectedSortOption="created_at".obs;
  RxString search="".obs;

  RxString selectedFilterOption="all".obs;
  RxInt withImageOnly = 0.obs;


  RxBool isThereError = false.obs;
  RxString errorMessage = "".obs;

  Future<List> getData() async {

    try {
      // isLoadingData.value = true;

      var data = await helperData.getTransactionData(currentPage.value,selectedSortOption.value,selectedFilterOption.value,withImageOnly.value,search.value,Token_pref.getToken()!);


      isLoadingData.value = false;

      if(data["status"]==200) {

        final List<dynamic> dataListJson = data["data"]["transactions"];
        lastItem.value = data["data"]["pagination"]["to"]??0;

        if (isFirstTime.value) {

          dataList.clear();
          dataList.value = dataListJson.map((item) => TransactionModel.fromJson(item)).toList();

          total.value = data["data"]["pagination"]["total"];

          isFirstTime.value = false;
        }else{
          dataList.addAll(dataListJson.map((item) => TransactionModel.fromJson(item)));

        }
        currentPage++;
      }


    } catch (e) {
      isThereError.value=true;
      errorMessage.value = e.toString();
      global_methods.sendError("TransactionController : $e");

      isLoadingData.value = false;

      print("saeeeeeeeeeeeed error is : $e");

    }

    return dataList;
  }

  void resetData() {
    isFirstTime.value=true;
    currentPage.value=1;
    isLoadingData.value=true;
    dataList.clear();
    isThereError.value=false;
    errorMessage.value = '';
  }












}
