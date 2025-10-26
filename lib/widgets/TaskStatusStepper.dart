import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Models/TaskModel.dart';

class TaskStatusStepper extends StatelessWidget {
  final TaskModel task;

  const TaskStatusStepper({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    final steps = _getSteps();
    final currentStepIndex = _getCurrentStepIndex(steps);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFd40019).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.timeline,
                    color: Color(0xFFd40019),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'task_stages'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildHorizontalStepper(steps, currentStepIndex),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalStepper(List<TaskStep> steps, int currentStepIndex) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          final isActive = index <= currentStepIndex;
          final isCurrent = index == currentStepIndex;
          final isCompleted = index < currentStepIndex;

          return Row(
            children: [
              _buildStepItem(step, isActive, isCurrent, isCompleted),
              if (index < steps.length - 1)
                _buildConnector(index < currentStepIndex),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStepItem(TaskStep step, bool isActive, bool isCurrent, bool isCompleted) {
    Color backgroundColor;
    Color iconColor;
    Color textColor;
    IconData icon;

    if (isCompleted) {
      backgroundColor = Colors.green;
      iconColor = Colors.white;
      textColor = Colors.green;
      icon = Icons.check;
    } else if (isCurrent) {
      backgroundColor = const Color(0xFFd40019);
      iconColor = Colors.white;
      textColor = const Color(0xFFd40019);
      icon = _getStepIcon(step.status);
    } else {
      backgroundColor = Colors.grey.withOpacity(0.2);
      iconColor = Colors.grey.withOpacity(0.6);
      textColor = Colors.grey.withOpacity(0.6);
      icon = _getStepIcon(step.status);
    }

    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: backgroundColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          child: Text(
            step.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: textColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildConnector(bool isCompleted) {
    return Container(
      width: 30,
      height: 2,
      margin: const EdgeInsets.only(bottom: 30),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green : Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  IconData _getStepIcon(String status) {
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

  List<TaskStep> _getSteps() {
    return [
      TaskStep(
        title: 'pending'.tr,
        content: 'task_pending_desc'.tr,
        status: 'pending',
      ),
      if (task.status.value == 'advertised')
        TaskStep(
          title: 'advertised'.tr,
          content: 'task_advertised_desc'.tr,
          status: 'advertised',
        ),
      TaskStep(
        title: 'assign'.tr,
        content: 'task_assign_desc'.tr,
        status: 'assign',
      ),
      TaskStep(
        title: 'started'.tr,
        content: 'task_started_desc'.tr,
        status: 'started',
      ),
      TaskStep(
        title: 'in_pickup_point'.tr,
        content: 'task_in_pickup_point_desc'.tr,
        status: 'in pickup point',
      ),
      TaskStep(
        title: 'loading'.tr,
        content: 'task_loading_desc'.tr,
        status: 'loading',
      ),
      TaskStep(
        title: 'in_the_way'.tr,
        content: 'task_in_the_way_desc'.tr,
        status: 'in the way',
      ),
      TaskStep(
        title: 'in_delivery_point'.tr,
        content: 'task_in_delivery_point_desc'.tr,
        status: 'in delivery point',
      ),
      TaskStep(
        title: 'unloading'.tr,
        content: 'task_unloading_desc'.tr,
        status: 'unloading',
      ),
      TaskStep(
        title: 'completed'.tr,
        content: 'task_completed_desc'.tr,
        status: 'completed',
      ),
    ];
  }

  int _getCurrentStepIndex(List<TaskStep> steps) {
    for (int i = 0; i < steps.length; i++) {
      if (steps[i].status == task.status.value) {
        return i;
      }
    }
    return 0; // Default to first step if status not found
  }
}

class TaskStep {
  final String title;
  final String? content;
  final String status;

  TaskStep({
    required this.title,
    this.content,
    required this.status,
  });
}
