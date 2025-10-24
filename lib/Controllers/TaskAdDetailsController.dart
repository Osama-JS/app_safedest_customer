

import 'package:get/get.dart';

import '../../shared_prff.dart';
import '../../Globals/global_methods.dart' as global_methods;
import '../Helpers/TaskAdHelper.dart';
import '../Helpers/TaskHelper.dart';
import '../Models/OfferModel.dart';
import '../Models/TaskAdDetailsModel.dart';
import '../Models/TaskAdModel.dart';

class TaskAdDetailsController extends GetxController {




  TaskAdHelper helperData =  TaskAdHelper();



  RxInt pressedIndex= 0.obs;
  RxBool isLoadingData = true.obs;

  RxList<OfferModel> offersDataList = <OfferModel>[].obs;
  Rx<TaskAdDetailsModel> details = TaskAdDetailsModel().obs;


  RxString selectedFilterOption="details".obs;
  RxString search="".obs;


  RxBool isThereError = false.obs;
  RxString errorMessage = "".obs;

  Future<List> getData(int id) async {

    try {
      isLoadingData.value = true;

      if(selectedFilterOption.value=="details"){
        var data = await helperData.getDetails(id,Token_pref.getToken()!);
        isLoadingData.value = false;

        if(data["status"]==200) {

          details.value = TaskAdDetailsModel.fromJson(data["data"]);

        }

      }else{
        var data = await helperData.getOffers(id,Token_pref.getToken()!);



        isLoadingData.value = false;

        if(data["status"]==200) {

          final List<dynamic> dataListJson = data["data"];
          offersDataList.clear();
          offersDataList.value = dataListJson.map((item) => OfferModel.fromJson(item)).toList();

        }
      }




    } catch (e) {
      isThereError.value=true;
      errorMessage.value = e.toString();
      global_methods.sendError("TaskAdDetailsController : $e");

      isLoadingData.value = false;

      print("saeeeeeeeeeeeed error is : $e");

    }

    return offersDataList;
  }

  void resetData() {
    isLoadingData.value=true;
    isThereError.value=false;
    errorMessage.value = '';
  }












}
