import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:save_dest_customer/Views/TaskViews/TasksAdPage.dart';

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
import 'TaskDetailsPage.dart';
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
    super.initState();
    globals.dashboardIndex = 1;
  }

  final List<String> filters = ['running', 'completed'];

  RxInt selectedFilter = 0.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        backgroundColor: MyColors.backgroundColor,
        surfaceTintColor: MyColors.backgroundColor,
        centerTitle: false,
        title: Text(
          'all_tasks'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Get.to(() => TasksAdPage());
            },
            icon: Icon(Icons.ads_click_outlined),
          ),
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
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
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
                              bool isSelected =
                                  controller.selectedSortOption.value ==
                                  option["value"];

                              return ListTile(
                                title: Text(
                                  option["text"] as String,
                                  style: TextStyle(
                                    color: isSelected
                                        ? MyColors.primaryColor
                                        : Colors.black,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                trailing: isSelected
                                    ? Icon(
                                        Icons.check,
                                        color: MyColors.primaryColor,
                                      )
                                    : null,
                                onTap: () {
                                  controller.selectedSortOption.value =
                                      option["value"];
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
            buttonIcon: Icon(Icons.search, color: MyColors.primaryColor),
            onChanged: (text) {
              controller.search.value = text.toString();
            },
            onFieldSubmitted: (text) {
              controller.search.value = text.toString();
              controller.resetData();
              controller.getData();
            },
            onSubmit: () {
              controller.search.value = searchController.text.toString();
              controller.resetData();
              controller.getData();
            },
            duration: const Duration(milliseconds: 1000),
            submitIcon: const Icon(Icons.send),
            animationAlignment: AnimationAlignment.left,
            searchQueryBuilder: (query, list) => list.where((item) {
              return item!.toString().toLowerCase().contains(
                query.toLowerCase(),
              );
            }).toList(),
            overlaySearchListItemBuilder: (dynamic item) => Container(
              padding: const EdgeInsets.all(8),
              child: Text(
                item,
                style: const TextStyle(fontSize: 15, color: Colors.black),
              ),
            ),
            onItemSelected: (dynamic item) {},
            overlaySearchListHeight: 100,
            searchList: const [],
          ),
        ],
      ),
      body: Column(
        children: [
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(filters.length, (index) {
                RxBool isActive = (selectedFilter.value == index).obs;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      selectedFilter.value = index;
                      controller.selectedFilterOption.value = filters[index];
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
                            color: isActive.value
                                ? Colors.white
                                : Colors.grey.shade700,
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

  final RefreshController _refreshController = RefreshController(
    initialRefresh: true,
  );

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
            ? Center(
                child: Text(
                  global_methods.fixErrorMessage(controller.errorMessage.value),
                ),
              )
            : controller.dataList.isEmpty
            ? Center(
                child: Column(
                  spacing: 48,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Image.asset("assets/images/empty-inbox.png",width: 150 , height: 150,),
                    Text("no_tasks".tr),
                    const SizedBox(height: 80),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: 48,
                ),
                itemCount: controller.dataList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                // itemBuilder: (_, index)=>_buildCard( controller.dataList[index],index,false),
                itemBuilder: (_, index) {
                  return _buildCard(controller.dataList[index], index);
                },
              ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'status_completed'.tr;
      case 'pending':
        return 'status_pending'.tr;
      case 'cancelled':
        return 'status_cancelled'.tr;
      default:
        return status;
    }
  }

  Widget _buildCard(TaskModel item, int index) {
    return Obx(
      () => Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _viewTaskDetails(item),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Header: Task ID + Status ---
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'task_number'.trParams({
                          'number': item.id.value.toString(),
                        }),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(item.status.value),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _getStatusLabel(item.status.value),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // --- Pickup Address ---
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${'from'.tr}: ${item.pickup.address.value}',
                        style: const TextStyle(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // --- Delivery Address ---
                Row(
                  children: [
                    const Icon(Icons.flag, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${'to'.tr}: ${item.delivery.address.value}',
                        style: const TextStyle(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // --- Price and Payment Status ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Show price range for advertised tasks, regular price for others
                    if (item.status.value == 'advertised' &&
                        item.ad.value != null &&
                        item.ad.value!.min > 0 &&
                        item.ad.value!.max > 0)
                      Text(
                        '${item.ad.value!.min.toStringAsFixed(2)} - ${item.ad.value!.max.toStringAsFixed(2)} ${'currency'.tr}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFd40019),
                        ),
                      )
                    else
                      Text(
                        '${item.price.value.toStringAsFixed(2)} ${'currency'.tr}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFd40019),
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: item.paymentStatus.value == 'paid'
                            ? Colors.green
                            : Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.paymentStatus.value.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressRow(
    BuildContext context,
    String label,
    String address,
    IconData icon,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                address,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _viewTaskDetails(TaskModel task) {
    Get.to(() => TaskDetailsPage(task: task));
  }

  void launchPhoneCall(String phone) {
    // يمكنك استخدام url_launcher لفتح تطبيق الاتصال
    // لكنه خارج نطاق هذا المثال
  }
}
