import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../Controllers/TaskController.dart';
import '../../Controllers/TransactionController.dart';
import '../../Globals/MyColors.dart';
import '../../Globals/global_methods.dart' as global_methods;
import '../../Models/TaskModel.dart';
import '../../Models/TransactionModel.dart';
import '../../Services/InitialService.dart';
import '../Widgets/AnimatedSearchBar.dart';
import '../Widgets/ProgressWithIcon.dart';
import '../Widgets/custom_image_view.dart';
import 'AddTaskViews/ValidationOnePage.dart';
import '../../Globals/global.dart' as globals;

class TasksPage extends StatefulWidget {

   const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final iniService = InitialService.to;
  final TaskController controller = Get.put(TaskController());
  final TextEditingController searchController = TextEditingController();
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    globals.dashboardIndex=1;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      appBar: AppBar(
        leading: IconButton(onPressed: ()=>Get.back(),icon: const Icon(Icons.arrow_back_ios)),
        backgroundColor: MyColors.backgroundColor,
        surfaceTintColor: MyColors.backgroundColor,
        centerTitle: false,
        title: Text('all_tasks'.tr,style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.0),
            child: IconButton(
              icon: Icon(
                Icons.filter_list_rounded,
                color: MyColors.primaryColor,
              ),
              onPressed: () {
                showModalBottomSheet(
                  backgroundColor: MyColors.backgroundColor,
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (_) {
                    return DraggableScrollableSheet(
                      expand: false,
                      maxChildSize: 0.5,
                      minChildSize: 0.1,
                      initialChildSize: 0.3,
                      builder: (context, scrollController) {
                        final List<Map<String, dynamic>> filterOptions = [
                          {"value": 'created_at', "text": "sort_by_date".tr},
                          {"value": 'amount', "text": "sort_by_amount".tr},
                          {"value": 'sequence', "text": "sort_by_sequence".tr},
                        ];

                        return Container(
                          padding: const EdgeInsets.all(16),
                          child: ListView.builder(
                            controller: scrollController,
                            itemCount: filterOptions.length,
                            itemBuilder: (context, index) {
                              final option = filterOptions[index];
                              bool isSelected = controller.selectedSortOption.value == option["value"];

                              return ListTile(
                                title: Text(
                                  option["text"] as String,
                                  style: TextStyle(
                                    color: isSelected ? MyColors.primaryColor : Colors.black,
                                    fontWeight:
                                    isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                trailing: isSelected
                                    ? Icon(Icons.check, color: MyColors.primaryColor)
                                    : null,
                                onTap: () {
                                  controller.selectedSortOption.value=option["value"];
                                  controller.resetData();
                                  controller.getData();
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
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
      body: _buildList(),


      floatingActionButton: FloatingActionButton(
        onPressed: () {

          Get.to(ValidationOnePage());
        },
        backgroundColor: MyColors.primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

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
            Text("no_tasks".tr),
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



  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed': return Colors.green;
      case 'pending': return Colors.orange;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'completed': return 'مكتملة';
      case 'pending': return 'قيد التنفيذ';
      case 'cancelled': return 'ملغاة';
      default: return status;
    }
  }

  Widget _buildCard(TaskModel item ,int index ){
    return
      Obx(()=> Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- العنوان العلوي: المهمة + الحالة ---
                Row(
                  children: [
                    Text(
                      '#${item.id.value}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(item.status.value).withAlpha(30),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getStatusLabel(item.status.value),
                        style: TextStyle(
                          fontSize: 12,
                          color: _getStatusColor(item.status.value),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if(item.status.value=="in_progress"&&item.driver.name.value=='')
                    IconButton(onPressed: (){
                      controller.pressedIndex.value=index;
                      Get.to(()=> ValidationOnePage(taskIdForEdit: item.id.value,taskModelForEdit: item));
                    }, icon: Icon(Icons.edit))
                  ],
                ),
                const SizedBox(height: 12),

                // --- المبلغ وطريقة الدفع ---
                Row(
                  children: [
                    Text(
                      '${item.id.value.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: item.paymentStatus.value == 'paid' ? Colors.green.withAlpha(30) : Colors.red.withAlpha(30),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.paymentStatus.value == 'paid' ? 'مدفوع' : 'غير مدفوع',
                        style: TextStyle(
                          fontSize: 12,
                          color: item.paymentStatus.value == 'paid' ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.paymentMethod.value == 'cash' ? 'نقدًا' : 'إلكتروني',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // --- الاستلام والتسليم ---
                _buildLocationSection(
                  icon: Icons.location_on_outlined,
                  title: 'الاستلام',
                  address: item.pickup.address.value,
                  time: global_methods.formatDateTime(item.pickup.scheduledTime.value),
                ),
                const SizedBox(height: 12),
                _buildLocationSection(
                  icon: Icons.delivery_dining_outlined,
                  title: 'التسليم',
                  address: item.delivery.address.value,
                  time: global_methods.formatDateTime(item.delivery.scheduledTime.value),
                ),

                // --- بيانات السائق (إن وُجد) ---
                if (item.driver.name.value != '')
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          'السائق: $item.driver.name.value',
                          style: const TextStyle(fontSize: 13, color: Colors.black87),
                        ),
                        const SizedBox(width: 8),
                        if (item.driver.phone.value != '')
                          TextButton(
                            onPressed: () => launchPhoneCall(item.driver.phone.value),
                            child: Text(
                              item.driver.phone.value,
                              style: const TextStyle(color: Colors.blue, fontSize: 13),
                            ),
                          ),
                      ],
                    ),
                  ),

                // --- ملاحظات إضافية ---
                if (item.additionalData.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('تفاصيل إضافية:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        for (var i in item.additionalData)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text.rich(
                              TextSpan(
                                text: '${i.label.value}: ',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                children: [
                                  TextSpan(
                                    text: i.value.value,
                                    style: const TextStyle(fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      );

  }



  Widget _buildLocationSection({
    required IconData icon,
    required String title,
    required String address,
    required String time,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey),
            const SizedBox(width: 6),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          address,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, color: Colors.black87),
        ),
        Text(
          'الوقت: $time',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  void launchPhoneCall(String phone) {
    // يمكنك استخدام url_launcher لفتح تطبيق الاتصال
    // لكنه خارج نطاق هذا المثال
  }

}


