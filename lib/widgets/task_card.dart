import 'package:flutter/material.dart';
import '../models/task.dart';
import '../utils/date_formatter.dart';
import 'status_badge.dart';
import 'priority_badge.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;

  const TaskCard({super.key, required this.task, this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool overdue = task.dueDate != null && DateFormatter.isOverdue(task.dueDate!) && task.status != 'completed';
    final bool dueSoon = task.dueDate != null && DateFormatter.isDueSoon(task.dueDate!) && !overdue;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: overdue
            ? const BorderSide(color: Colors.red, width: 1)
            : dueSoon
                ? const BorderSide(color: Colors.orange, width: 1)
                : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  PriorityBadge(priority: task.priority),
                ],
              ),
              if (task.description != null && task.description!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  task.description!,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  StatusBadge(status: task.status),
                  const Spacer(),
                  if (task.dueDate != null)
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 13,
                          color: overdue
                              ? Colors.red
                              : dueSoon
                                  ? Colors.orange
                                  : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormatter.formatDate(task.dueDate!),
                          style: TextStyle(
                            fontSize: 12,
                            color: overdue
                                ? Colors.red
                                : dueSoon
                                    ? Colors.orange
                                    : Colors.grey[600],
                            fontWeight: overdue || dueSoon
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              if (overdue)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: const [
                      Icon(Icons.warning_amber_rounded, size: 14, color: Colors.red),
                      SizedBox(width: 4),
                      Text(
                        'Đã quá hạn',
                        style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
