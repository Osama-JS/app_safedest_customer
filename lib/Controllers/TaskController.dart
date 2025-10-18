

import 'package:get/get.dart';

import '../../shared_prff.dart';
import '../../Globals/global_methods.dart' as global_methods;
import '../Helpers/TaskHelper.dart';
import '../Models/TaskModel.dart';

class TaskController extends GetxController {




  TaskHelper helperData =  TaskHelper();



  RxInt pressedIndex= 0.obs;
  RxBool isLoadingData = true.obs;

  RxList<TaskModel> dataList = <TaskModel>[].obs;

  RxInt currentPage = 1.obs;
  RxInt total= 0.obs;
  RxInt lastItem= 0.obs;
  RxBool isRefreshing = false.obs;
  RxBool isFirstTime = true.obs;
  RxString selectedSortOption="created_at".obs;
  RxString search="".obs;


  RxBool isThereError = false.obs;
  RxString errorMessage = "".obs;

  Future<List> getData() async {

    try {
      // isLoadingData.value = true;

      var data = await helperData.getData(currentPage.value,selectedSortOption.value,search.value,Token_pref.getToken()!);



      isLoadingData.value = false;

      if(data["status"]==200) {

        final List<dynamic> dataListJson = data["data"]["tasks"];
        lastItem.value = data["data"]["pagination"]["to"];

        if (isFirstTime.value) {

          dataList.clear();
          dataList.value = dataListJson.map((item) => TaskModel.fromJson(item)).toList();

          total.value = data["data"]["pagination"]["total"];

          isFirstTime.value = false;
        }else{
          dataList.addAll(dataListJson.map((item) => TaskModel.fromJson(item)));

        }
        currentPage++;
      }


    } catch (e) {
      isThereError.value=true;
      errorMessage.value = e.toString();
      global_methods.sendError("TaskController : $e");

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
