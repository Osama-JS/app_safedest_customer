import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controllers/TaskController.dart';
import '../../Models/TaskModel.dart';
import '../../Globals/global_methods.dart' as global_methods;
import '../../Widgets/TaskStatusStepper.dart';
import '../../Widgets/TaskHistorySheet.dart';
import 'AddTaskViews/ValidationOnePage.dart';
import 'PaymentInputScreen.dart';

class TaskDetailsPage extends StatefulWidget {
  final TaskModel task;

  const TaskDetailsPage({super.key, required this.task});

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  TaskModel? _currentTask;
  bool _isLoading = true;
  List<dynamic> _taskHistory = [];
  final TaskController controller = Get.find<TaskController>();

  @override
  void initState() {
    super.initState();
    _currentTask = widget.task;
    _loadTaskDetails();
  }

  Future<void> _loadTaskDetails() async {
    try {
      final result = await controller.getTaskDetails(widget.task.id.value);

      if (result["success"] == true) {
        final data = result["data"];
        setState(() {
          _currentTask = widget.task;
          _taskHistory = data["history"] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _currentTask = widget.task;
          _taskHistory = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Get.snackbar(
        'error'.tr,
        'failed_to_load_task_details'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentTask == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(title: Text('error'.tr)),
        body: Center(child: Text('task_not_found'.tr)),
      );
    }

    final task = _currentTask!;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFFd40019),
            actions: [
              if ((task.status.value == "in_progress" ||
                  task.status.value == "advertised") &&
                  task.driver.name.value == '')
                IconButton(
                  onPressed: () {
                    Get.to(
                          () => ValidationOnePage(
                        taskIdForEdit: task.id.value,
                        taskModelForEdit: task,
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit, color: Colors.white),
                  tooltip: 'edit_task'.tr,
                ),
              IconButton(
                onPressed: () => _showTaskHistory(),
                icon: const Icon(Icons.timeline, color: Colors.white),
                tooltip: 'task_history'.tr,
              ),
              if (task.status.value != "in_progress" &&
                  task.status.value != "advertised" &&
                  task.status.value != "canceled" &&
                  task.status.value != "refound")
                IconButton(
                  onPressed: () {
                    Get.to(PaymentScreen(taskId: task.id.value));
                  },
                  icon: const Icon(Icons.payment_outlined, color: Colors.white),
                  tooltip: 'make_payment'.tr,
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'task_number'.trParams({'number': task.id.value.toString()}),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFd40019),
                      Color(0xFFa8001a),
                      Color(0xFF8b0000),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -50,
                      right: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -30,
                      left: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 30),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getStatusIcon(task.status.value),
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _getStatusLabel(task.status.value),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5),
                          Column(
                            children: [
                              Text(
                                'total_price'.tr,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (task.status.value == 'advertised' &&
                                  task.ad.value != null &&
                                  task.ad.value!.min > 0 &&
                                  task.ad.value!.max > 0)
                                Text(
                                  '${task.ad.value!.min.toStringAsFixed(2)} - ${task.ad.value!.max.toStringAsFixed(2)} ${'currency'.tr}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              else
                                Text(
                                  '${task.price.value.toStringAsFixed(2)} ${'currency'.tr}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusProgress(task),
                  const SizedBox(height: 24),
                  _buildTaskDetails(task),
                  const SizedBox(height: 24),
                  _buildLocations(task),
                  const SizedBox(height: 24),
                  if (task.driver.name.value.isNotEmpty) _buildDriverInfo(task),
                  if (task.additionalData.isNotEmpty) _buildAdditionalData(task),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusProgress(TaskModel task) {
    return TaskStatusStepper(task: task);
  }

  Widget _buildTaskDetails(TaskModel task) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'task_details'.tr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('task_id'.tr, '#${task.id.value}'),
            _buildDetailRow(
              'payment_method'.tr,
              task.paymentMethod.value == 'cash' ? 'cash'.tr : 'electronic'.tr,
            ),
            _buildDetailRow(
              'payment_status'.tr,
              task.paymentStatus.value == 'paid' ? 'paid'.tr : 'unpaid'.tr,
            ),
            _buildDetailRow(
              'created_at'.tr,
              global_methods.formatDateTime(task.createdAt.value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
          ],
        )
    );
  }

  Widget _buildLocations(TaskModel task) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'locations'.tr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildLocationRow(
              'task_pickup'.tr,
              task.pickup.address.value,
              Icons.location_on,
              Colors.blue,
              global_methods.formatDateTime(task.pickup.scheduledTime.value),
            ),
            const SizedBox(height: 16),
            _buildLocationRow(
              'task_delivery'.tr,
              task.delivery.address.value,
              Icons.flag,
              Colors.green,
              global_methods.formatDateTime(task.delivery.scheduledTime.value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow(
      String label,
      String address,
      IconData icon,
      Color color,
      String time,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.1),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                address,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (time.isNotEmpty)
                Text(
                  time,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDriverInfo(TaskModel task) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'driver_info'.tr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFd40019).withOpacity(0.1),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFFd40019),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.driver.name.value,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (task.driver.phone.value.isNotEmpty)
                        Text(
                          task.driver.phone.value,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalData(TaskModel task) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'additional_details'.tr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...task.additionalData.map(
                  (data) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: _buildDetailRow(data.label.value, data.value.value),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'advertised':
        return Icons.campaign;
      case 'in_progress':
        return Icons.local_shipping;
      case 'completed':
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'pending'.tr;
      case 'advertised':
        return 'advertised'.tr;
      case 'in_progress':
        return 'in_progress'.tr;
      case 'completed':
        return 'completed'.tr;
      default:
        return status;
    }
  }

  void _showTaskHistory() {
    if (_currentTask == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          TaskHistorySheet(task: _currentTask!, history: _taskHistory),
    );
  }
}