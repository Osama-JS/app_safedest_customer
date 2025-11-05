import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../Controllers/TaskAdController.dart';
import '../../Controllers/TaskAdDetailsController.dart';
import '../../Controllers/TaskController.dart';
import '../../Controllers/TransactionController.dart';
import '../../Globals/MyColors.dart';
import '../../Globals/global_methods.dart' as global_methods;
import '../../Models/OfferModel.dart';
import '../../Models/TaskAdDetailsModel.dart';
import '../../Models/TaskAdModel.dart';
import '../../Models/TaskModel.dart';
import '../../Models/TransactionModel.dart';
import '../../Services/InitialService.dart';
import '../../shared_prff.dart';
import '../Widgets/AnimatedSearchBar.dart';
import '../Widgets/ProgressWithIcon.dart';
import '../Widgets/custom_image_view.dart';
import 'AddTaskViews/ValidationOnePage.dart';
import '../../Globals/global.dart' as globals;

class TasksAdDetailsPage extends StatefulWidget {
  int taskId;
  TasksAdDetailsPage({super.key, required this.taskId});

  @override
  State<TasksAdDetailsPage> createState() => _TasksAdDetailsPageState();
}

class _TasksAdDetailsPageState extends State<TasksAdDetailsPage> {
  final iniService = InitialService.to;
  final TaskAdDetailsController controller = Get.put(TaskAdDetailsController());
  final TextEditingController searchController = TextEditingController();
  final controller2 = Get.find<TaskAdController>();

  final List<String> filters = [
    'details',
    'offers',
  ];
  RxInt selectedFilter = 0.obs;

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios)
        ),
        backgroundColor: MyColors.backgroundColor,
        surfaceTintColor: MyColors.backgroundColor,
        centerTitle: false,
        title: Obx(() => Text(
          selectedFilter.value == 0 ? 'task_ad_details'.tr : 'task_ad_offers'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        )),
      ),
      body: Column(
        children: [
          Obx(() => Row(
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
          )),
          const SizedBox(height: 10),
          Expanded(child: Obx(() =>
          controller.selectedFilterOption.value == "details"
              ? _buildDetailsCard(controller.details.value)
              : _buildList())),
        ],
      ),
    );
  }

  loadInitialData() async {
    controller.resetData();
    controller.getData(widget.taskId);
  }

  Widget _buildList() {
    return Obx(() => controller.isLoadingData.value
        ? const Center(child: ProgressWithIcon())
        : controller.isThereError.value
        ? Center(child: Text(global_methods.fixErrorMessage(controller.errorMessage.value)))
        : controller.offersDataList.isEmpty
        ? Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("no_offers".tr),
          const SizedBox(height: 80)
        ],
      ),
    )
        : ListView.separated(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 48),
      itemCount: controller.offersDataList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        return _buildOfferCard(controller.offersDataList[index], index);
      },
    ));
  }

  Widget _buildOfferCard(OfferModel offer, int index) {
    final Color statusColor = offer.accepted.value ? OfferColors.accepted : OfferColors.pending;
    final String statusText = offer.accepted.value ? 'accepted'.tr : 'pending'.tr;

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: statusColor.withOpacity(0.5), width: 1.5),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipOval(
                  child: Image.network(
                    offer.driver.value.image.value,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.person, size: 60, color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.driver.value.name.value,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold, color: OfferColors.primary),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 5),
                          Text(
                            offer.driver.value.phone.value,
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${offer.price.value.toStringAsFixed(2)} ${'currency'.tr}',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w900, color: OfferColors.price),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1),
            Text(
              'offer_description'.tr,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 4),
            Text(
              offer.description.value,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                if (!offer.accepted.value)
                  Expanded(
                    child: SizedBox(
                      width: double.maxFinite,
                      child: ElevatedButton(
                        onPressed: () {
                          acceptOffer(offer.id.value);
                        },
                        style: global_methods.buttonStyle(),
                        child: Text('accept'.tr, style: global_methods.textOnPrimaryButton()),
                      ),
                    ),
                  ),
                const SizedBox(width: 10),
                if (offer.accepted.value && controller2.dataList[controller2.pressedIndex.value].status.value != "closed")
                  Expanded(
                    child: SizedBox(
                      width: double.maxFinite,
                      child: ElevatedButton(
                        onPressed: () {
                          retractOffer(offer.id.value);
                        },
                        style: global_methods.buttonStyle(),
                        child: Text('cancel'.tr, style: global_methods.textOnPrimaryButton()),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        )),
      ),
    );
  }

  Widget _buildDetailsCard(TaskAdDetailsModel item) {
    return Obx(() => controller.isLoadingData.value
        ? const Center(child: ProgressWithIcon())
        : Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() => Text(
                        item.customer.value.name.value,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                      )),
                      const SizedBox(height: 4),
                      Text(
                        'task_number'.trParams({'number': item.taskId.value.toString()}),
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.statusBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.status.value.tr,
                    style: const TextStyle(
                        color: AppColors.statusFg, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'suggested_price_range'.tr,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                Text(
                  '${item.lowPrice.value.toStringAsFixed(0)} - ${item.highPrice.value.toStringAsFixed(0)} ${'currency'.tr}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.accent),
                ),
              ],
            ),
            if (item.note.value.isNotEmpty)
              Obx(() => Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  '${'ad_notes'.tr}: ${item.note.value}',
                  style: TextStyle(
                      fontSize: 13, fontStyle: FontStyle.italic, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )),
            const SizedBox(height: 15),
            _buildLocationItem(
              icon: Icons.location_on_outlined,
              title: 'pickup_point'.tr,
              address: item.task.value.pickup.value.address.value,
            ),
            const SizedBox(height: 10),
            _buildLocationItem(
              icon: Icons.assistant_direction,
              title: 'delivery_point'.tr,
              address: item.task.value.delivery.value.address.value,
            ),
            const SizedBox(height: 15),
            Text(
              'commission_details'.tr,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const Divider(height: 10, thickness: 0.5),
            _buildCommissionRow(
                label: 'service_commission'.tr, amount: item.serviceCommission.value),
            _buildCommissionRow(
                label: 'vat_commission'.tr, amount: item.vatCommission.value),
            const SizedBox(height: 8),
            Obx(() => Text(
              '${'task_conditions'.tr}: ${item.task.value.conditions.value}',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )),
          ],
        ),
      ),
    ));
  }

  Widget _buildLocationItem({
    required IconData icon,
    required String title,
    required String address,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.accent, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: 28.0, top: 2),
          child: Text(
            address,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCommissionRow({required String label, required double amount}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        Text(
          '${amount.toStringAsFixed(2)} ${'currency'.tr}',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ],
    );
  }

  void acceptOffer(int id) async {
    if (!await global_methods.isInternetAvailable()) {
      global_methods.errorView(context, 'check_internet_connection'.tr);
    } else {
      global_methods.showDialogLoading(context: context);
      try {
        var data = await controller.helperData.acceptOffer(id, Token_pref.getToken()!);
        global_methods.hideLoadingDialog();
        if (data["status"] == 200) {
          Get.snackbar("success".tr, data["message"]);
          loadInitialData();
        } else {
          Get.snackbar("error".tr, data["message"]);
        }
      } catch (e) {
        global_methods.hideLoadingDialog();
        global_methods.sendError("AcceptOffer : $e");
        Get.snackbar("error".tr, "something_went_wrong".tr);
      }
    }
  }

  void retractOffer(int id) async {
    if (!await global_methods.isInternetAvailable()) {
      global_methods.errorView(context, 'check_internet_connection'.tr);
    } else {
      global_methods.showDialogLoading(context: context);
      try {
        var data = await controller.helperData.retractOffer(id, Token_pref.getToken()!);
        global_methods.hideLoadingDialog();
        if (data["status"] == 200) {
          Get.snackbar("success".tr, data["message"]);
          controller2.resetData();
          controller2.getData();
          loadInitialData();
        } else {
          Get.snackbar("error".tr, data["message"]);
        }
      } catch (e) {
        global_methods.hideLoadingDialog();
        global_methods.sendError("AcceptOffer : $e");
        Get.snackbar("error".tr, "something_went_wrong".tr);
      }
    }
  }
}

class MyColors2 {
  static const Color primaryColor = Color(0xFF1E88E5);
  static const Color accentColor = Color(0xFFFFB300);
  static const Color statusRunning = Color(0xFF4CAF50);
  static const Color textDark = Color(0xFF333333);
}

class AppColors {
  static const Color primary = Color(0xFF0D47A1);
  static const Color accent = Color(0xFFFF9800);
  static const Color statusBg = Color(0xFFE8F5E9);
  static const Color statusFg = Color(0xFF4CAF50);
}

class OfferColors {
  static const Color primary = Color(0xFF00796B);
  static const Color accepted = Color(0xFF4CAF50);
  static const Color pending = Color(0xFFFF9800);
  static const Color price = Color(0xFFD32F2F);
}