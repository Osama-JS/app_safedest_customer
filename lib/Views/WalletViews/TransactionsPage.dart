import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../Controllers/TransactionController.dart';
import '../../Globals/MyColors.dart';
import '../../Globals/global_methods.dart' as global_methods;
import '../../Models/TransactionModel.dart';
import '../../Services/InitialService.dart';
import '../Widgets/AnimatedSearchBar.dart';
import '../Widgets/ProgressWithIcon.dart';
import '../Widgets/custom_image_view.dart';

class TransactionsPage extends StatefulWidget {

   const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final iniService = InitialService.to;
  final TransactionController controller = Get.put(TransactionController());
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      appBar: AppBar(
        leading: IconButton(onPressed: ()=>Get.back(),icon: const Icon(Icons.arrow_back_ios)),
        backgroundColor: MyColors.backgroundColor,
        surfaceTintColor: MyColors.backgroundColor,
        centerTitle: false,
        title: Text('all_transactions'.tr,style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
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
            Text("no_transactions".tr),
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
            bool divide = false;
            if(index!=0) {
              print("saeeeeeeeeeeeeeeeeeed1 ${controller.dataList[index].createdAt.value}");
              print("saeeeeeeeeeeeeeeeeeed2 ${global_methods.formatDate(controller.dataList[index].createdAt.value)}");
              print("saeeeeeeeeeeeeeeeeeed3 ${global_methods.formatDate(controller.dataList[index-1].createdAt.value)}");
              print("saeeeeeeeeeeeeeeeeeed4 ${global_methods.formatDateTime(controller.dataList[index].createdAt.value)}");
              print("///////////////////////////////////////////////////////////////////////////////////////////");
              if (controller.dataList[index].createdAt.value != '') {
                if (global_methods.formatDate(controller.dataList[index].createdAt.value)   !=
                    global_methods.formatDate(controller.dataList[index-1].createdAt.value)) {
                  divide = true;
                }
              }
            }
           return _buildCard( controller.dataList[index],index,divide);

          },

        ),
      ),
    );
  }

  Widget _buildCard(TransactionModel item ,int index ,bool divide){
    return
      // Obx(()=>
          Column(
          spacing: 16,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if(index!=0&&divide&&item.createdAt.value!='')
            Divider(color: Colors.grey.withAlpha(50),height: 1,),
            if((divide||index==0)&&item.createdAt.value!='')
              Obx(()=> Text(global_methods.formatDate(item.createdAt.value),style: global_methods.textCardTitle(),)),




            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                Obx(()=> ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item.image.value,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.receipt, size: 30),
                  ),
                ),
                ),

                // Obx(()=> Container(
                //   width: 50,
                //   height: 50,
                //   decoration: BoxDecoration(
                //     color: item.transactionType.value=="debit".tr ? Colors.red.withAlpha(30) : Colors.green.withAlpha(30),
                //     borderRadius: BorderRadius.circular(8),
                //   ),
                //   child: Icon(
                //     item.transactionType.value=="debit".tr ? Icons.arrow_downward : Icons.arrow_upward,
                //     color: item.transactionType.value=="debit".tr?Colors.red:Colors.green,
                //     size: 28,
                //   ),
                // ),
                // ),
                const SizedBox(width: 16),

                // --- النصوص ---
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // المبلغ + النوع
                      Row(
                        children: [
                          Obx(()=> Text(
                            item.amount.value.toStringAsFixed(2),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: item.transactionType.value=="debit".tr?Colors.red:Colors.green,
                            ),
                          ),
                          ),
                          const SizedBox(width: 8),
                          Obx(()=> Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: (item.transactionType.value=="debit".tr?Colors.red:Colors.green).withAlpha(30),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.transactionType.value,
                              style: TextStyle(
                                fontSize: 12,
                                color: item.transactionType.value=="debit".tr?Colors.red:Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // الوصف
                      Obx(()=> Text(
                        item.description.value,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      ),

                      // الرقم المرجعي
                      Obx(()=> Text(
                        item.sequence.value.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      ),

                      // التاريخ
                      Obx(()=> Text(
                        global_methods.formatDateTime(item.createdAt.value),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

          ],
        );
      // );

  }



}
