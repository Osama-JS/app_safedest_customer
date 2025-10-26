import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Models/TaskModel.dart';
import '../Globals/global_methods.dart' as global_methods;

class TaskHistorySheet extends StatefulWidget {
  final TaskModel task;
  final List<dynamic> history;

  const TaskHistorySheet({
    super.key,
    required this.task,
    required this.history,
  });

  @override
  State<TaskHistorySheet> createState() => _TaskHistorySheetState();
}

class _TaskHistorySheetState extends State<TaskHistorySheet> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[600] : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(
                  Icons.history,
                  color: const Color(0xFFd40019),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'task_history'.trParams({'number': widget.task.id.value.toString()}),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          const Divider(),

          // Content
          Expanded(
            child: _buildHistoryList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    if (widget.history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'no_task_history'.tr,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: widget.history.length,
      itemBuilder: (context, index) {
        final log = widget.history[index];
        return _buildHistoryItem(log);
      },
    );
  }

  Widget _buildHistoryItem(dynamic log) {
    final timestamp = log['created_at'] ?? '';
    final status = log['status'] ?? '';
    final note = log['note'] ?? '';
    final hasFile = log['file_name'] != null && log['file_name'].toString().isNotEmpty;
    final fileName = log['file_name'];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey[800]
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.grey.withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFd40019).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  _getStatusIcon(status),
                  color: const Color(0xFFd40019),
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status.tr,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      global_methods.formatDateTime(timestamp),
                      style: TextStyle(
                        color: Colors.grey.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasFile)
                GestureDetector(
                  onTap: () => _openAttachment(fileName, log),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.attach_file,
                      color: Colors.green[600],
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
          if (note.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              note,
              style: const TextStyle(fontSize: 14),
            ),
          ],
          if (hasFile && fileName != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFd40019).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: const Color(0xFFd40019).withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.attach_file,
                    size: 16,
                    color: const Color(0xFFd40019),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    fileName.toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFd40019),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.pending;
      case 'advertised':
        return Icons.campaign;
      case 'assign':
        return Icons.assignment;
      case 'started':
        return Icons.play_arrow;
      case 'in pickup point':
        return Icons.location_on;
      case 'loading':
        return Icons.upload;
      case 'in the way':
        return Icons.local_shipping;
      case 'in delivery point':
        return Icons.flag;
      case 'unloading':
        return Icons.download;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.circle;
    }
  }

  Future<void> _openAttachment(String? fileName, dynamic log) async {
    if (log['file_path'] == null) return;

    try {
      final fileUrl = 'https://your-domain.com/storage/${log['file_path']}';
      
      // Show attachment dialog
      showDialog(
        context: context,
        builder: (context) => _buildAttachmentDialog(fileName, fileUrl),
      );
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'error_opening_attachment'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Widget _buildAttachmentDialog(String? fileName, String fileUrl) {
    final displayName = fileName ?? 'attachment'.tr;

    return Dialog(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFd40019).withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.insert_drive_file,
                    color: const Color(0xFFd40019),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.insert_drive_file,
                        size: 64,
                        color: const Color(0xFFd40019),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () => _downloadFile(fileUrl),
                icon: const Icon(Icons.download),
                label: Text('download'.tr),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFd40019),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadFile(String fileUrl) async {
    try {
      final uri = Uri.parse(fileUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $fileUrl';
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'error_downloading_file'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
