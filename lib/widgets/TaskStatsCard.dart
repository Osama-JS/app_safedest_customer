import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controllers/MapController.dart';
import '../Services/InitialService.dart';

class TaskStatsCard extends StatelessWidget {
  const TaskStatsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mapController = Get.find<MapController>();
    final initialService = Get.find<InitialService>();

    return Positioned(
      left: 8,
      bottom: 8,
      child: Obx(() {
        // إخفاء البطاقة إذا لم تكن هناك مهام
        if (mapController.dataList.isEmpty) {
          return const SizedBox.shrink();
        }

        return Card(
          elevation: 8,
          color: Colors.white.withOpacity(0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // عنوان البطاقة
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.analytics_outlined,
                      color: const Color(0xFFd40019),
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'task_statistics'.tr,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // إحصائيات المهام
                _buildStatRow(
                  'in_progress',
                  'in_progress'.tr,
                  mapController.taskStats['in_progress'] ?? 0,
                  Icons.pending_actions,
                  const Color(0xFF2196F3),
                ),
                _buildStatRow(
                  'advertised',
                  'advertised'.tr,
                  mapController.taskStats['advertised'] ?? 0,
                  Icons.campaign,
                  const Color(0xFFFF9800),
                ),
                _buildStatRow(
                  'running',
                  'running'.tr,
                  mapController.taskStats['running'] ?? 0,
                  Icons.local_shipping,
                  const Color(0xFF4CAF50),
                ),
                _buildStatRow(
                  'completed',
                  'completed'.tr,
                  mapController.taskStats['completed'] ?? 0,
                  Icons.check_circle,
                  const Color(0xFF9C27B0),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStatRow(
    String status,
    String statusName,
    int count,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // أيقونة الحالة
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(icon, size: 12, color: color),
          ),
          const SizedBox(width: 8),

          // اسم الحالة
          SizedBox(
            width: 80,
            child: Text(
              statusName,
              style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // عدد المهام
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
