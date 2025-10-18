import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:save_dest_customer/Globals/MyColors.dart';
// import 'package:save_dest_customer/Views/Widgets/ProgressWithIcon.dart'; // افترض وجودها
// import '../../Controllers/WalletController.dart';
import '../../Helpers/WalletHelper.dart'; // افترض وجودها
import '../../Models/TransactionModel.dart'; // افترض وجودها
import '../../shared_prff.dart'; // افترض وجودها
import '../../../Globals/global_methods.dart' as global_methods;
import '../Widgets/ProgressWithIcon.dart';
import 'TransactionsPage.dart';




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

  // @override
  // void onInit() {
  //   super.onInit();
  //
  //   getData();
  // }

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

        // totalDebit.value = (data["data"]["statistics"]["total_debit"] ?? 0).toDouble();
        // totalCredit.value = (data["data"]["statistics"]["total_credit"] ?? 0).toDouble();
        // netBalance.value = (data["data"]["statistics"]["net_balance"] ?? 0).toDouble();

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


class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>  {

   WalletController controller = Get.put(WalletController());

  @override
  void initState() {
    super.initState();
controller.getData();
  }

   @override
   void dispose() {
     super.dispose();
   }


   @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,

      appBar: AppBar(
        title: const Text('المحفظة والإحصائيات'),
        backgroundColor: MyColors.appBarColor,
        elevation: 0,
      ),

      // استخدام Obx لمراقبة حالة التحميل
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: ProgressWithIcon());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. رأس المحفظة
              _buildWalletHeader(),
              const SizedBox(height: 20),

              // 2. بطاقة الإحصائيات
              _buildStatisticsCard(),
              const SizedBox(height: 20),

              // 3. المعاملات الأخيرة
              Container(
                decoration: global_methods.appDecoration(),
                width: double.maxFinite,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    spacing: 16,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("latest_transactions".tr,style: global_methods.textSubTitle(),textAlign: TextAlign.center,),
                      Divider(color: Colors.grey.withAlpha(50),height: 1,),
                      Obx(()=>
                      controller.transactionDataList.isNotEmpty?
                      Column(
                        spacing: 8,
                        children: [
                          for(TransactionModel item in controller.transactionDataList)
                            _buildTransactionCard(item),

                        ],
                      ):
                      Text("no_transactions".tr),
                      ),
                      Divider(color: Colors.grey.withAlpha(50),height: 1,),
                      Obx(()=>
                      controller.transactionDataList.isNotEmpty? GestureDetector(
                          onTap: () {
                            Get.to( TransactionsPage());
                          },
                          child: Text("view_more".tr,style: global_methods.textPrimaryBody(),textAlign: TextAlign.center,)):
                      const SizedBox()
                      ),
                    ],
                  ),
                ),
              ),




            ],
          ),
        );
      }),
    );
  }

  // 1. تصميم رأس المحفظة
  Widget _buildWalletHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [MyColors.primaryColor, MyColors.primaryColor.withAlpha(110)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'رصيدك الحالي',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Obx(() => Text(
            '${controller.walletBalance.value.toStringAsFixed(2)} ${controller.walletCurrency.value}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w900,
            ),
          ),
          ),
          const SizedBox(height: 15),
          Obx(() => Row(
            children: [
              Icon(
                controller.walletStatus.value ? Icons.check_circle : Icons.error,
                color: controller.walletStatus.value ? Colors.greenAccent : Colors.amberAccent,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                controller.walletStatus.value ? 'المحفظة نشطة' : 'المحفظة غير نشطة',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          ),
        ],
      ),
    );
  }

  // 2. تصميم بطاقة الإحصائيات
  Widget _buildStatisticsCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Obx(() => _buildStatItem('إجمالي المدين', controller.totalDebit.value, Colors.red.shade700, Icons.arrow_upward)),
            Obx(() => _buildStatItem('إجمالي الدائن', controller.totalCredit.value, Colors.green.shade700, Icons.arrow_downward)),
            Obx(() => _buildStatItem('الرصيد الصافي', controller.netBalance.value, Colors.blue.shade700, Icons.account_balance)),
          ],
        ),
      ),
    );
  }

  // عنصر إحصائي فرعي (يستقبل Double)
  Widget _buildStatItem(String title, double value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(height: 5),
        Text(
          value.toStringAsFixed(2),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 3),
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  // 3. تصميم قائمة المعاملات
  Widget _buildTransactionsList() {
    return Obx(() => ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: controller.transactionDataList.length,
      itemBuilder: (context, index) {
        return _buildTransactionCard(controller.transactionDataList[index]);
      },
    ),
    );
  }

  // بطاقة المعاملة
  Widget _buildTransactionCard(TransactionModel item) {

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child:
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
      ),
    );
  }
}