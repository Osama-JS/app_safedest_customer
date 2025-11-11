import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Controllers/TaskAdController.dart';
import '../../Controllers/TransactionController.dart';
import '../../Globals/MyColors.dart';
import '../../Globals/global_methods.dart' as global_methods;
import '../../Models/TransactionModel.dart';
import '../../Services/InitialService.dart';

import '../Widgets/ProgressWithIcon.dart';
import '../Widgets/custom_image_view.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage>
    with SingleTickerProviderStateMixin {
  final iniService = InitialService.to;
  final TransactionController controller = Get.put(TransactionController());
  final TextEditingController searchController = TextEditingController();
  late TabController _tabController;

  final List<String> filters = ['all', 'credit', 'debit', 'withImage'];
  RxInt selectedFilter = 0.obs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        backgroundColor: MyColors.primaryColor,
        surfaceTintColor: MyColors.primaryColor,
        centerTitle: false,
        title: Text(
          'all_transactions'.tr,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // شريط البحث
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'search_in_transactions'.tr,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              searchController.clear();
                              controller.search.value = '';
                              controller.resetData();
                              controller.getData();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    controller.search.value = value;
                  },
                  onSubmitted: (value) {
                    controller.search.value = value;
                    controller.resetData();
                    controller.getData();
                  },
                ),
              ),
              // التبويبات
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
                indicatorColor: Colors.white,
                tabs: [
                  Tab(text: 'all'.tr),
                  Tab(text: 'credit'.tr),
                  Tab(text: 'debit'.tr),
                  Tab(text: 'with_image'.tr),
                ],
                onTap: (index) {
                  selectedFilter.value = index;
                  if (index == 3) {
                    controller.withImageOnly.value = 1;
                    controller.selectedFilterOption.value = 'all';
                  } else {
                    controller.withImageOnly.value = 0;
                    controller.selectedFilterOption.value = filters[index];
                  }
                  loadInitialData();
                },
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
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
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              controller.resetData();
              controller.getData();
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(_refreshController1),
          _buildList(_refreshController2),
          _buildList(_refreshController3),
          _buildList(_refreshController4),
        ],
      ),
    );
  }

  final RefreshController _refreshController1 = RefreshController(
    initialRefresh: true,
  );
  final RefreshController _refreshController2 = RefreshController(
    initialRefresh: true,
  );
  final RefreshController _refreshController3 = RefreshController(
    initialRefresh: true,
  );
  final RefreshController _refreshController4 = RefreshController(
    initialRefresh: true,
  );

  loadInitialData() async {
    // await Future.delayed(const Duration(seconds: 1));
    controller.resetData();
    controller.getData();
    _refreshController1.refreshCompleted();
    _refreshController2.refreshCompleted();
    _refreshController3.refreshCompleted();
    _refreshController4.refreshCompleted();
  }

  loadMoreData() async {
    // await Future.delayed(const Duration(seconds: 1));
    if (controller.total.value > controller.lastItem.value) {
      controller.getData();
    } else {
      Get.snackbar("info".tr, "no_data_available".tr);
    }
    _refreshController1.loadComplete();
    _refreshController2.loadComplete();
    _refreshController3.loadComplete();
    _refreshController4.loadComplete();
  }

  Widget _buildList(RefreshController refreshController) {
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
        controller: refreshController,
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
                    Text("no_transactions".tr),
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
                  bool divide = false;
                  if (index != 0) {
                    print(
                      "saeeeeeeeeeeeeeeeeeed1 ${controller.dataList[index].createdAt.value}",
                    );
                    print(
                      "saeeeeeeeeeeeeeeeeeed2 ${global_methods.formatDate(controller.dataList[index].createdAt.value)}",
                    );
                    print(
                      "saeeeeeeeeeeeeeeeeeed3 ${global_methods.formatDate(controller.dataList[index - 1].createdAt.value)}",
                    );
                    print(
                      "saeeeeeeeeeeeeeeeeeed4 ${global_methods.formatDateTime(controller.dataList[index].createdAt.value)}",
                    );
                    print(
                      "///////////////////////////////////////////////////////////////////////////////////////////",
                    );
                    if (controller.dataList[index].createdAt.value != '') {
                      if (global_methods.formatDate(
                            controller.dataList[index].createdAt.value,
                          ) !=
                          global_methods.formatDate(
                            controller.dataList[index - 1].createdAt.value,
                          )) {
                        divide = true;
                      }
                    }
                  }
                  return _buildCard(controller.dataList[index], index, divide);
                },
              ),
      ),
    );
  }

  Widget _buildCard(TransactionModel item, int index, bool divide) {
    final isCredit = item.transactionType.value != "debit".tr;
    final color = isCredit ? Colors.green : Colors.red;
    final hasAttachment = item.image.value.isNotEmpty;

    return Column(
      spacing: 16,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (index != 0 && divide && item.createdAt.value != '')
          Divider(color: Colors.grey.withAlpha(50), height: 1),
        if ((divide || index == 0) && item.createdAt.value != '')
          Obx(
            () => Text(
              global_methods.formatDate(item.createdAt.value),
              style: global_methods.textCardTitle(),
            ),
          ),
        Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _showDetails(context, item),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Icon(
                          isCredit
                              ? Icons.add_circle_outline
                              : Icons.remove_circle_outline,
                          color: color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Obx(
                                    () => Text(
                                      item.description.value,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                if (hasAttachment)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isImageFile(item.image.value)
                                              ? Icons.image
                                              : Icons.picture_as_pdf,
                                          size: 16,
                                          color: Colors.blue,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'attachment'.tr,
                                          style: const TextStyle(
                                            color: Colors.blue,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Obx(
                                    () => Text(
                                      item.sequence.value.toString(),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Obx(
                                  () => Text(
                                    global_methods.formatDateTime(
                                      item.createdAt.value,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Obx(
                            () => Text(
                              '${isCredit ? '+' : '-'}${item.amount.value.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ),
                          const Text(
                            'ر.س',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool isImageFile(String url) {
    if (url.isEmpty) return false;

    final ext = Uri.parse(url).path.toLowerCase();

    return ext.endsWith('.jpg') ||
        ext.endsWith('.jpeg') ||
        ext.endsWith('.png') ||
        ext.endsWith('.gif');
  }

  IconData getFileIcon(String url) {
    final ext = Uri.parse(url).path.toLowerCase();
    if (ext.endsWith('.pdf')) return Icons.picture_as_pdf;
    if (ext.endsWith('.doc') || ext.endsWith('.docx')) return Icons.description;
    if (ext.endsWith('.xls') || ext.endsWith('.xlsx') || ext.endsWith('.csv'))
      return Icons.table_chart;
    if (ext.endsWith('.txt')) return Icons.text_fields;
    if (ext.endsWith('.zip') || ext.endsWith('.rar')) return Icons.folder_zip;
    if (ext.endsWith('.ppt') || ext.endsWith('.pptx')) return Icons.slideshow;
    return Icons.insert_drive_file;
  }

  void _showDetails(BuildContext context, TransactionModel item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (context) {
        final String url = item.image.value;
        final bool isImage = item.image.value != '' ? isImageFile(url) : false;

        return Container(
          padding: const EdgeInsets.all(20),
          height: context.mediaQuerySize.height * 0.80,
          child: SingleChildScrollView(
            child: Obx(
              () => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.close, color: Colors.black),
                      ),
                      Text(
                        'تفاصيل المعاملة',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 24), // لتفادي التداخل
                    ],
                  ),
                  const SizedBox(height: 24),

                  // تفاصيل المعاملة
                  _buildDetailRow(
                    'المبلغ',
                    '${item.amount.value.toStringAsFixed(2)} ر.س',
                  ),
                  _buildDetailRow('النوع', item.transactionType.value),
                  _buildDetailRow('الوصف', item.description.value),
                  _buildDetailRow('التاريخ', item.createdAt.value),
                  _buildDetailRow('الوقت', item.createdAt.value),

                  const SizedBox(height: 32),

                  // المرفق (صورة)
                  if (item.image.value != '')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Icon(Icons.attach_file, color: Colors.blue),
                            const Text(
                              'المرفق',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: isImage
                              ?
                                // 🔹 حالة: الملف صورة (عرض Image.network)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    url,
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                    // Fallback في حال فشل تحميل الصورة
                                    errorBuilder: (_, __, ___) =>
                                        const SizedBox(
                                          height: 200,
                                          child: Center(
                                            child: Icon(
                                              Icons.broken_image,
                                              size: 64,
                                              color: Colors.redAccent,
                                            ),
                                          ),
                                        ),
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return const SizedBox(
                                            height: 200,
                                            child: Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          );
                                        },
                                  ),
                                )
                              :
                                // 🔸 حالة: الملف ليس صورة (عرض أيقونة المستند)
                                Container(
                                  width: double.infinity,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        getFileIcon(
                                          url,
                                        ), // استخدام الدالة المساعدة
                                        size: 64,
                                        color: Colors.blueGrey,
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Document File',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        url
                                            .split('/')
                                            .last, // عرض اسم الملف من الرابط
                                        style: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontSize: 10,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                          // ClipRRect(
                          //   borderRadius: BorderRadius.circular(12),
                          //   child: Image.network(
                          //     item.image.value,
                          //     width: double.infinity,
                          //     height: 200,
                          //     fit: BoxFit.cover,
                          //     errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.image, size: 64)),
                          //     loadingBuilder: (context, child, loadingProgress) {
                          //       if (loadingProgress == null) return child;
                          //       return const Center(child: CircularProgressIndicator());
                          //     },
                          //   ),
                          // ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  if (item.image.value != '')
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _downloadDocument(item.image.value);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.red),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.download, size: 16),
                                SizedBox(width: 8),
                                Text('تحميل'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final Uri uri = Uri.parse(url);

                              if (await canLaunchUrl(uri)) {
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                              } else {
                                Get.snackbar(
                                  "error".tr,
                                  "غير قادر على عرض المرفق",
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.remove_red_eye, size: 16),
                                SizedBox(width: 8),
                                Text('عرض'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Future<String?> getDownloadsDirectoryPath() async {
    if (Platform.isAndroid) {
      // الحصول على مسار مجلد التنزيلات العام
      final Directory? downloadsDir = await getExternalStorageDirectory();
      final String downloadsPath =
          '${downloadsDir?.path}/SafeDestCustomerDownloads';
      // final String downloadsPath = '/storage/emulated/0/Download/SafeDestCustomerDownloads';

      // إنشاء المجلد إذا لم يكن موجوداً
      final Directory dir = Directory(downloadsPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return downloadsPath;
    } else if (Platform.isIOS) {
      final Directory documentsDir = await getApplicationDocumentsDirectory();
      return documentsDir.path;
    }
    return null;
  }

  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (status.isGranted) {
        print("تم منح إذن الوصول إلى التخزين");
        return true;
      } else if (status.isPermanentlyDenied) {
        print("تم رفض الإذن نهائيًا، يتم فتح إعدادات الجهاز...");
        openAppSettings();
        return false;
      } else {
        print("تم رفض إذن الوصول إلى التخزين");
        return false;
      }
    }
    return true;
  }

  void _downloadDocument(String fileUrl) async {
    bool hasPermission = await requestStoragePermission();
    if (!hasPermission) {
      Get.snackbar("خطأ", "لم يتم منح إذن الوصول إلى التخزين.");
      return;
    }
    // fileUrl = "https://youtu.be/-C_0fcVZkXo?si=QClNfF7WhueXEGuM";

    try {
      final Uri url = Uri.parse(fileUrl);

      final downloadsPath = await getDownloadsDirectoryPath();
      if (downloadsPath != null) {
        String fileName = p.basename(url.path);

        if (fileName.isEmpty || !fileName.contains('.')) {
          final extension = url.queryParameters['ext'] ?? 'dat';
          fileName =
              'document_${DateTime.now().millisecondsSinceEpoch}.$extension';
        }
        final String savePath = '$downloadsPath/$fileName}';

        final RxDouble downloadProgress = 0.0.obs;
        showDownloadProgressDialog(downloadProgress);

        final response = await http.get(url);
        if (response.statusCode == 200) {
          final totalBytes = response.contentLength ?? 1;
          final bytes = <int>[];
          final stream = http.ByteStream.fromBytes(response.bodyBytes);

          await for (final data in stream) {
            bytes.addAll(data);

            downloadProgress.value = bytes.length / totalBytes;
          }

          final file = File(savePath);
          await file.writeAsBytes(bytes);
          Get.back();

          Get.snackbar("نجاح", "تم تنزيل الوثيقة بنجاح في: $savePath");
        } else {
          Get.back();

          Get.snackbar(
            "خطأ",
            "حدث خطأ أثناء تنزيل الوثيقة: ${response.statusCode}",
          );
        }
      }
    } catch (e) {
      print("saeeeeeeeeeeeeeeeeeeed : $e");
      Get.snackbar("خطأ", "حدث خطأ أثناء تنزيل الوثيقة");
    }
  }

  void showDownloadProgressDialog(RxDouble downloadProgress) {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(horizontal: 40),
            child: Center(
              child: SizedBox(
                width: 80,
                height: 80,
                child: Obx(
                  () => CircularProgressIndicator(
                    semanticsValue: downloadProgress.value.toStringAsFixed(2),
                    semanticsLabel: downloadProgress.value.toStringAsFixed(2),
                    value: downloadProgress.value,
                    strokeWidth: 5,
                    backgroundColor: MyColors.primaryColor,
                    color: MyColors.backgroundColor,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
