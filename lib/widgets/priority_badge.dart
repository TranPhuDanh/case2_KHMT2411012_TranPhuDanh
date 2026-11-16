import 'package:flutter/material.dart';

class PriorityBadge extends StatelessWidget {
  final String priority;

  const PriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    IconData icon;

    switch (priority) {
      case 'high':
        color = Colors.red;
        label = 'Cao';
        icon = Icons.keyboard_double_arrow_up;
        break;
      case 'medium':
        color = Colors.orange;
        label = 'Trung bình';
        icon = Icons.drag_handle;
        break;
      case 'low':
      default:
        color = Colors.green;
        label = 'Thấp';
        icon = Icons.keyboard_double_arrow_down;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
