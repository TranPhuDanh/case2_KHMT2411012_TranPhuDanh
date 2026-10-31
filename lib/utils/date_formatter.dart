import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) {
      return 'Vừa xong';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} phút trước';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} giờ trước';
    } else if (diff.inDays == 1) {
      return 'Hôm qua';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} ngày trước';
    } else if (diff.inDays < 30) {
      final weeks = (diff.inDays / 7).floor();
      return '$weeks tuần trước';
    } else if (diff.inDays < 365) {
      final months = (diff.inDays / 30).floor();
      return '$months tháng trước';
    } else {
      final years = (diff.inDays / 365).floor();
      return '$years năm trước';
    }
  }

  static bool isOverdue(DateTime dueDate) {
    return DateTime.now().isAfter(dueDate);
  }

  static bool isDueSoon(DateTime dueDate, {int hours = 24}) {
    final now = DateTime.now();
    final diff = dueDate.difference(now);
    return diff.inHours <= hours && diff.inHours >= 0;
  }
}
