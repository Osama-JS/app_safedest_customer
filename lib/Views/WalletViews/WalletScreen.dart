import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:save_dest_customer/Globals/MyColors.dart';
import '../../Helpers/WalletHelper.dart';
import '../../Models/TransactionModel.dart';
import '../../shared_prff.dart';
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

  void getData() async {
    try {
      isLoading.value = true;
      var data = await helperData.getData(Token_pref.getToken());

      if (data["status"] == 200) {
        walletId.value = data["data"]["wallet"]["id"] ?? 0;
        walletStatus.value = data["data"]["wallet"]["status"] ?? false;
        walletBalance.value = (data["data"]["wallet"]["balance"] ?? 0)
            .toDouble();
        walletCurrency.value = data["data"]["wallet"]["currency"] ?? '';

        final List<dynamic> dataListJson = data["data"]["recent_transactions"];
        transactionDataList.clear();
        transactionDataList.value = dataListJson
            .map((item) => TransactionModel.fromJson(item))
            .toList();
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

class _WalletScreenState extends State<WalletScreen> {
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
        title: Text(
          'wallet'.tr,
          style: TextStyle(
            color: MyColors.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: MyColors.whiteColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: const SizedBox(),
        actions: [
          IconButton(
            icon: Icon(Icons.receipt_long, color: MyColors.primaryColor),
            tooltip: 'transaction_history'.tr,
            onPressed: () {
              Get.to(() => TransactionsPage());
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          controller.getData();
        },
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: ProgressWithIcon());
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Wallet Balance Card
                _buildWalletBalanceCard(),

                const SizedBox(height: 16),

                // Recent Transactions
                _buildTransactionListCard(),

                const SizedBox(height: 100), // Bottom padding
              ],
            ),
          );
        }),
      ),
    );
  }

  // Wallet Balance Card مطابق لـ safedest_driver
  Widget _buildWalletBalanceCard() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              MyColors.primaryColor,
              MyColors.primaryColor.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'wallet_balance'.tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.visibility,
                  color: Colors.white.withOpacity(0.8),
                  size: 20,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Main Balance
            Obx(
              () => Text(
                '${controller.walletBalance.value.toStringAsFixed(2)} ${controller.walletCurrency.value}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'available_balance'.tr,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 24),

            // Additional Info
            Row(
              children: [
                Expanded(
                  child: _buildBalanceInfo(
                    'total_debit'.tr,
                    '${controller.totalDebit.value.toStringAsFixed(2)}',
                    Icons.trending_up,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withOpacity(0.3),
                ),
                Expanded(
                  child: _buildBalanceInfo(
                    'total_credit'.tr,
                    '${controller.totalCredit.value.toStringAsFixed(2)}',
                    Icons.trending_down,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceInfo(String label, String amount, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
        const SizedBox(height: 8),
        Text(
          amount,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Transaction List Card مطابق لـ safedest_driver
  Widget _buildTransactionListCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  color: MyColors.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'recent_transactions'.tr,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: MyColors.textPrimaryColor,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Get.to(() => TransactionsPage());
                  },
                  child: Text('view_all'.tr),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Obx(() {
              if (controller.transactionDataList.isEmpty) {
                return _buildEmptyTransactionsState();
              }

              return Column(
                children: controller.transactionDataList
                    .map((transaction) => _buildTransactionItem(transaction))
                    .toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyTransactionsState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: MyColors.neutral300,
          ),
          const SizedBox(height: 16),
          Text(
            'no_transactions_recorded'.tr,
            style: TextStyle(
              fontSize: 16,
              color: MyColors.neutral400,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(TransactionModel transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MyColors.neutral50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MyColors.outlineVariantColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: transaction.transactionType.value == 'credit'
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              transaction.transactionType.value == 'credit'
                  ? Icons.add_circle_outline
                  : Icons.remove_circle_outline,
              color: transaction.transactionType.value == 'credit'
                  ? Colors.green
                  : Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description.value.isNotEmpty
                      ? transaction.description.value
                      : 'transaction'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: MyColors.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.createdAt.value,
                  style: TextStyle(fontSize: 12, color: MyColors.neutral400),
                ),
              ],
            ),
          ),
          Text(
            '${transaction.transactionType.value == 'credit' ? '+' : '-'}${transaction.amount.value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: transaction.transactionType.value == 'credit'
                  ? Colors.green
                  : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
