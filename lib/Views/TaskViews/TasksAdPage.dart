import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../Controllers/TaskAdController.dart';
import '../../Controllers/TaskController.dart';
import '../../Controllers/TransactionController.dart';
import '../../Globals/MyColors.dart';
import '../../Globals/global_methods.dart' as global_methods;
import '../../Models/TaskAdModel.dart';
import '../../Models/TaskModel.dart';
import '../../Models/TransactionModel.dart';
import '../../Services/InitialService.dart';
import '../Widgets/AnimatedSearchBar.dart';
import '../Widgets/ProgressWithIcon.dart';
import '../Widgets/custom_image_view.dart';
import 'AddTaskViews/ValidationOnePage.dart';
import '../../Globals/global.dart' as globals;
import 'TasksAdDetailsPage.dart';

class TasksAdPage extends StatefulWidget {

   const TasksAdPage({super.key});

  @override
  State<TasksAdPage> createState() => _TasksAdPageState();
}

class _TasksAdPageState extends State<TasksAdPage> {
  final iniService = InitialService.to;
  final TaskAdController controller = Get.put(TaskAdController());
  final TextEditingController searchController = TextEditingController();


  final List<String> filters = [
    'running',
    'closed',
  ];
  RxInt selectedFilter = 0.obs;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      appBar: AppBar(
        leading: IconButton(onPressed: ()=>Get.back(),icon: const Icon(Icons.arrow_back_ios)),
        backgroundColor: MyColors.backgroundColor,
        surfaceTintColor: MyColors.backgroundColor,
        centerTitle: false,
        title: Text('all_ad_tasks'.tr,style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
        actions: [
          AnimatedSearchBar(
            backgroundColor: Colors.white,
            textController: searchController,
            width: MediaQuery.of(context).size.width * 0.61,
            submitButtonColor: Colors.black,
            textStyle: const TextStyle(color: Colors.black),
            buttonIcon:  Icon(
              Icons.search,
              color: MyColors.primaryColor,
            ),
            onChanged: (text) {
              controller.search.value=text.toString();

            },
            onFieldSubmitted: (text){
              controller.search.value=text.toString();
              controller.resetData();
              controller.getData();
            },
            onSubmit: () {
              controller.search.value=searchController.text.toString();
              controller.resetData();
              controller.getData();
            },
            duration: const Duration(milliseconds: 1000),
            submitIcon: const Icon(Icons.send),
            animationAlignment: AnimationAlignment.left,
            searchQueryBuilder: (query, list) => list.where((item) {
              return item!
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase());
            }).toList(),
            overlaySearchListItemBuilder: (dynamic item) => Container(
              padding: const EdgeInsets.all(8),
              child: Text(
                item,
                style: const TextStyle(fontSize: 15, color: Colors.black),
              ),
            ),
            onItemSelected: (dynamic item) {

            },
            overlaySearchListHeight: 100, searchList: const [],
          ),
        ],
      ),


      body: Column(
        children: [
          Obx(()=>  Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(filters.length, (index) {
              RxBool isActive = (selectedFilter.value == index).obs;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    selectedFilter.value = index;
                    controller.selectedFilterOption.value=filters[index];
                    loadInitialData();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: isActive.value
                          ? MyColors.primaryColor
                          : Colors.transparent,
                      border: isActive.value
                          ? null
                          : Border.all(color: MyColors.gray, width: 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        filters[index].tr,
                        style: TextStyle(
                          color: isActive.value ? Colors.white : Colors.grey.shade700,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          ),

          const SizedBox(height: 10),
          Expanded(child: _buildList()),
        ],
      ),



    );
  }
  final RefreshController _refreshController = RefreshController(initialRefresh: true);

  loadInitialData() async {
    // await Future.delayed(const Duration(seconds: 1));
    controller.resetData();
    controller.getData();
    _refreshController.refreshCompleted();
  }

  loadMoreData() async {
    // await Future.delayed(const Duration(seconds: 1));
    if (controller.total.value > controller.lastItem.value) {
      controller.getData();
    } else {
      Get.snackbar("info".tr, "no_data_available".tr);
    }
    _refreshController.loadComplete();
  }


  Widget _buildList() {
    return Obx(
          () => SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: WaterDropHeader(
          complete: Text(
            "update_successful".tr,
            style: const TextStyle(color: Colors.green),
          ),
          failed: Text(
            "update_failed".tr,
            style: const TextStyle(color: Colors.red),
          ),
          refresh: Text(
            "updating".tr,
            style: TextStyle(color: MyColors.primaryColor),
          ),
          waterDropColor: MyColors.primaryColor,
        ),
        controller: _refreshController,
        onRefresh: () => loadInitialData(),
        onLoading: () => loadMoreData(),
        child: controller.isLoadingData.value
            ? const Center(child: ProgressWithIcon())
        // ? CircularProgressIndicator()
            : controller.isThereError.value
            ? Center(child: Text(global_methods.fixErrorMessage(controller.errorMessage.value)))
            : controller.dataList.isEmpty
            ? Center(child: Column(
          spacing: 48,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image.asset("assets/images/empty-inbox.png",width: 150 , height: 150,),
            Text("no_ad_tasks".tr),
            const SizedBox(height: 80,)
          ],
        ))
            :
        ListView.separated(
          padding: const EdgeInsets.only(left: 16 , right: 16 , top: 16 , bottom: 48),
          itemCount: controller.dataList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          // itemBuilder: (_, index)=>_buildCard( controller.dataList[index],index,false),
          itemBuilder: (_, index)
            {

           return _buildCard( controller.dataList[index],index);

          },

        ),
      ),
    );
  }





  Widget _buildDetailRow(IconData icon, String label, String value, {Color color = MyColors2.textDark}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: MyColors2.primaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  // TextSpan(
                  //   text: "$label: ",
                  //   style: TextStyle(fontWeight: FontWeight.bold, color: MyColors.textDark),
                  // ),
                  TextSpan(
                    text: value,
                    style: TextStyle(fontSize: 14, color: color, height: 1.2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(TaskAdModel item ,int index ){
    return
      GestureDetector(
        onTap: () {
          controller.pressedIndex.value = index;
          // print("saeeeeeeeeeeedddd ${item.taskId.value}");
          Get.to(()=> TasksAdDetailsPage(taskId: item.id.value,));
        },
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child:      Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. عنوان الكارد (اسم العميل ورقم المهمة)
                Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.customer.value.name.value,
                      style:  TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: MyColors.primaryColor,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: MyColors2.statusRunning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.status.value.tr, // افتراض أن الحالة مترجمة
                        style: TextStyle(
                          color: MyColors2.statusRunning,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                )),
                const Divider(height: 15, thickness: 1),

                // 2. تفاصيل السعر
                Obx(() => _buildDetailRow(
                  Icons.price_change,
                  "نطاق السعر",
                  "${item.lowPrice.value.toStringAsFixed(0)} - ${item.highPrice.value.toStringAsFixed(0)} ريال",
                  color: MyColors2.accentColor,
                )),

                const SizedBox(height: 10),

                // 3. تفاصيل الموقع
                Obx(() => _buildDetailRow(
                  Icons.location_on_outlined,
                  "من",
                  "من: ${item.fromAddress.value}",
                )),
                Obx(() => _buildDetailRow(
                  Icons.assistant_direction,
                  "إلى",
                  "إلى: ${item.toAddress.value}",
                )),

                const SizedBox(height: 10),

                // 4. رقم المهمة والملاحظات
                Obx(() => Row(
                  children: [
                    Icon(Icons.label_important_outline, size: 18, color: Colors.grey.shade600),
                    const SizedBox(width: 5),
                    Text(
                      "رقم المهمة: #${item.taskId.value}",
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                )),

                // عرض الملاحظات إذا كانت موجودة
                if (item.note.value.isNotEmpty)
                  Obx(() => Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: _buildDetailRow(
                        Icons.notes, "ملاحظات", item.note.value,
                        color: MyColors2.textDark.withOpacity(0.8)),
                  )),
              ],
            ),
          ),
        ),
      );

  }







}


class MyColors2 {
  static const Color primaryColor = Color(0xFF1E88E5); // أزرق داكن
  static const Color accentColor = Color(0xFFFFB300); // أصفر
  static const Color statusRunning = Color(0xFF4CAF50); // أخضر للحالة
  static const Color textDark = Color(0xFF333333);
}