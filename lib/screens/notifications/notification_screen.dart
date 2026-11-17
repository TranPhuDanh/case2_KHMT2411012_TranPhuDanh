import 'package:flutter/material.dart';
import '../../models/notification_model.dart';
import '../../services/notification_service.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/loading_view.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationService _notificationService = NotificationService();
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedFilter = 'all'; // all, history, assign, share, edit, email

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await _notificationService.getNotifications();
      if (mounted) {
        setState(() {
          _notifications = list;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();
      setState(() {
        _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã đánh dấu tất cả là đã đọc')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _handleNotificationTap(NotificationModel notif) async {
    if (!notif.isRead) {
      try {
        await _notificationService.markAsRead(notif.id);
        setState(() {
          final index = _notifications.indexWhere((n) => n.id == notif.id);
          if (index != -1) {
            _notifications[index] = _notifications[index].copyWith(isRead: true);
          }
        });
      } catch (_) {}
    }

    if (notif.taskId != null && notif.taskId!.isNotEmpty && mounted) {
      await Navigator.pushNamed(context, '/task-detail', arguments: notif.taskId);
      _loadNotifications();
    }
  }

  List<NotificationModel> get _filteredNotifications {
    if (_selectedFilter == 'all') return _notifications;
    if (_selectedFilter == 'history') {
      return _notifications.where((n) =>
        n.type == 'status_changed' ||
        n.type == 'task_updated' ||
        n.type == 'due_date_changed' ||
        n.type == 'task_completed'
      ).toList();
    }
    if (_selectedFilter == 'assign') {
      return _notifications.where((n) => n.type == 'task_assigned').toList();
    }
    if (_selectedFilter == 'share') {
      return _notifications.where((n) => n.type == 'task_shared').toList();
    }
    if (_selectedFilter == 'edit') {
      return _notifications.where((n) => n.type == 'task_edited').toList();
    }
    if (_selectedFilter == 'email') {
      return _notifications.where((n) => n.type == 'email_sent').toList();
    }
    return _notifications;
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'task_assigned':
        return Icons.person_add_alt_1;
      case 'task_shared':
        return Icons.share;
      case 'task_edited':
        return Icons.edit_note;
      case 'email_sent':
        return Icons.mark_email_read;
      case 'status_changed':
      case 'task_updated':
        return Icons.history;
      case 'task_completed':
        return Icons.check_circle_outline;
      case 'deadline_reminder':
        return Icons.alarm_on_outlined;
      case 'security_alert':
      case 'user_login':
      case 'user_logout':
        return Icons.shield_outlined;
      default:
        return Icons.notifications_none;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'task_assigned':
        return Colors.blue;
      case 'task_shared':
        return Colors.teal;
      case 'task_edited':
        return Colors.orange.shade800;
      case 'email_sent':
        return Colors.deepPurple;
      case 'status_changed':
      case 'task_updated':
        return Colors.indigo;
      case 'task_completed':
        return Colors.green;
      case 'deadline_reminder':
        return Colors.red;
      case 'security_alert':
        return Colors.amber.shade900;
      default:
        return Colors.indigo;
    }
  }

  Widget _buildFilterChips() {
    final filters = [
      {'key': 'all', 'label': 'Tất cả (${_notifications.length})', 'icon': Icons.notifications},
      {'key': 'history', 'label': 'Lịch sử việc', 'icon': Icons.history},
      {'key': 'assign', 'label': 'Giao việc', 'icon': Icons.person_add_alt_1},
      {'key': 'share', 'label': 'Chia sẻ', 'icon': Icons.share},
      {'key': 'edit', 'label': 'Chỉnh sửa', 'icon': Icons.edit_note},
      {'key': 'email', 'label': 'Gửi mail', 'icon': Icons.mark_email_read},
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((f) {
            final isSelected = _selectedFilter == f['key'];
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: FilterChip(
                selected: isSelected,
                avatar: Icon(
                  f['icon'] as IconData,
                  size: 15,
                  color: isSelected ? Colors.white : Colors.indigo,
                ),
                label: Text(f['label'] as String),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 12,
                ),
                selectedColor: Colors.indigo,
                backgroundColor: Colors.grey.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(
                    color: isSelected ? Colors.indigo : Colors.grey.shade300,
                  ),
                ),
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = f['key'] as String;
                  });
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo hệ thống'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          if (unreadCount > 0)
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'Đọc tất cả',
              onPressed: _markAllAsRead,
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm mới',
            onPressed: _loadNotifications,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          const Divider(height: 1, thickness: 1),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _notifications.isEmpty) {
      return const LoadingView(message: 'Đang tải thông báo...');
    }

    if (_errorMessage != null && _notifications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadNotifications,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    final items = _filteredNotifications;

    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadNotifications,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.notifications_off_outlined, size: 72, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      _selectedFilter == 'all'
                          ? 'Chưa có thông báo nào'
                          : 'Chưa có thông báo trong mục này',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Các cập nhật lịch sử, giao việc, chia sẻ, chỉnh sửa và gửi mail sẽ hiển thị tại đây.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final notif = items[index];
          final iconColor = _getNotificationColor(notif.type);

          return ListTile(
            onTap: () => _handleNotificationTap(notif),
            tileColor: notif.isRead ? Colors.transparent : Colors.indigo.withValues(alpha: 0.05),
            leading: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  backgroundColor: iconColor.withValues(alpha: 0.12),
                  child: Icon(_getNotificationIcon(notif.type), color: iconColor),
                ),
                if (!notif.isRead)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.indigo,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(
              notif.title.isNotEmpty ? notif.title : 'Thông báo hệ thống',
              style: TextStyle(
                fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
                fontSize: 15,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  notif.message,
                  style: TextStyle(
                    color: notif.isRead ? Colors.grey.shade700 : Colors.black87,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormatter.getRelativeTime(notif.createdAt),
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                ),
              ],
            ),
            trailing: notif.taskId != null && notif.taskId!.isNotEmpty
                ? const Icon(Icons.chevron_right, size: 20, color: Colors.grey)
                : null,
          );
        },
      ),
    );
  }
}
