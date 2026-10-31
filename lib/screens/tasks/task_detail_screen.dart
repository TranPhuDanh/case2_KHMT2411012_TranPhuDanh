import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../models/task_activity.dart';
import '../../services/task_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/priority_badge.dart';
import '../../widgets/loading_view.dart';
import '../../utils/date_formatter.dart';
import '../../utils/constants.dart';

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({super.key});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> with SingleTickerProviderStateMixin {
  final TaskService _taskService = TaskService();
  final AuthService _authService = AuthService();

  Task? _task;
  List<TaskActivity> _activities = [];
  bool _isLoading = true;
  bool _isUpdating = false;
  String? _errorMessage;
  String? _currentUserId;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentUser();
      _loadTask();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    _currentUserId = await _authService.getCachedUserId();
  }

  String get _taskId {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) return args;
    if (args is Task) return args.id;
    return '';
  }

  Future<void> _loadTask() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final task = await _taskService.getTaskById(_taskId);
      final activities = await _taskService.getActivities(_taskId);
      if (mounted) {
        setState(() {
          _task = task;
          _activities = activities;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool get _isOwner => _task?.createdBy == _currentUserId;

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isUpdating = true);
    try {
      final updated = await _taskService.updateStatus(_taskId, newStatus);
      if (mounted) setState(() => _task = updated);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _deleteTask() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa công việc này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await _taskService.deleteTask(_taskId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa công việc')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    }
  }

  Widget _buildInfoRow(IconData icon, String label, Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 10),
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết công việc'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          if (_task != null && _isOwner)
            PopupMenuButton<String>(
              onSelected: (v) async {
                if (v == 'edit') {
                  await Navigator.pushNamed(context, '/task-edit', arguments: _task);
                  _loadTask();
                } else if (v == 'assign') {
                  await Navigator.pushNamed(context, '/assign-task', arguments: _task);
                  _loadTask();
                } else if (v == 'share') {
                  await Navigator.pushNamed(context, '/task-sharing', arguments: _task);
                  _loadTask();
                } else if (v == 'delete') {
                  _deleteTask();
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit), title: Text('Chỉnh sửa'))),
                const PopupMenuItem(value: 'assign', child: ListTile(leading: Icon(Icons.person_add), title: Text('Giao việc'))),
                const PopupMenuItem(value: 'share', child: ListTile(leading: Icon(Icons.share), title: Text('Chia sẻ'))),
                const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete, color: Colors.red), title: Text('Xóa', style: TextStyle(color: Colors.red)))),
              ],
            ),
          if (_task != null && !_isOwner)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                await Navigator.pushNamed(context, '/task-edit', arguments: _task);
                _loadTask();
              },
            ),
        ],
      ),
      body: _isLoading
          ? const LoadingView(message: 'Đang tải...')
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 8),
                      Text(_errorMessage!),
                      TextButton(onPressed: _loadTask, child: const Text('Thử lại')),
                    ],
                  ),
                )
              : _task == null
                  ? const Center(child: Text('Không tìm thấy công việc'))
                  : Column(
                      children: [
                        TabBar(
                          controller: _tabController,
                          labelColor: Colors.indigo,
                          indicatorColor: Colors.indigo,
                          tabs: const [Tab(text: 'Thông tin'), Tab(text: 'Lịch sử')],
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildInfoTab(),
                              _buildActivityTab(),
                            ],
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildInfoTab() {
    final task = _task!;
    return RefreshIndicator(
      onRefresh: _loadTask,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                StatusBadge(status: task.status),
                const SizedBox(width: 8),
                PriorityBadge(priority: task.priority),
              ],
            ),
            const Divider(height: 28),
            if (task.description != null && task.description!.isNotEmpty) ...[
              _buildInfoRow(
                Icons.description_outlined,
                'Mô tả',
                Text(task.description!, style: const TextStyle(fontSize: 14)),
              ),
            ],
            _buildInfoRow(
              Icons.person_outlined,
              'Người tạo',
              Text(task.createdByUser?.fullName ?? task.createdBy),
            ),
            if (task.startDate != null)
              _buildInfoRow(
                Icons.play_circle_outline,
                'Bắt đầu',
                Text(DateFormatter.formatDate(task.startDate!)),
              ),
            if (task.dueDate != null)
              _buildInfoRow(
                Icons.event,
                'Hạn hoàn thành',
                Text(
                  DateFormatter.formatDate(task.dueDate!),
                  style: TextStyle(
                    color: DateFormatter.isOverdue(task.dueDate!) && task.status != AppConstants.statusCompleted
                        ? Colors.red
                        : null,
                    fontWeight: DateFormatter.isOverdue(task.dueDate!) && task.status != AppConstants.statusCompleted
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            if (task.assignees != null && task.assignees!.isNotEmpty)
              _buildInfoRow(
                Icons.group_outlined,
                'Người thực hiện',
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: task.assignees!.map((u) => Chip(
                    label: Text(u.fullName, style: const TextStyle(fontSize: 12)),
                    avatar: CircleAvatar(
                      radius: 10,
                      child: Text(u.fullName[0].toUpperCase(), style: const TextStyle(fontSize: 10)),
                    ),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  )).toList(),
                ),
              ),
            _buildInfoRow(
              Icons.access_time,
              'Cập nhật',
              Text(DateFormatter.getRelativeTime(task.updatedAt), style: const TextStyle(color: Colors.grey)),
            ),
            const SizedBox(height: 20),
            const Text('Cập nhật trạng thái', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 10),
            Row(
              children: [
                _statusButton(AppConstants.statusTodo, 'Chưa làm', Colors.grey),
                const SizedBox(width: 8),
                _statusButton(AppConstants.statusInProgress, 'Đang làm', Colors.blue),
                const SizedBox(width: 8),
                _statusButton(AppConstants.statusCompleted, 'Hoàn thành', Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusButton(String status, String label, Color color) {
    final isActive = _task!.status == status;
    return Expanded(
      child: OutlinedButton(
        onPressed: _isUpdating || isActive ? null : () => _updateStatus(status),
        style: OutlinedButton.styleFrom(
          backgroundColor: isActive ? color.withOpacity(0.15) : null,
          foregroundColor: color,
          side: BorderSide(color: color),
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
        child: Text(label, style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  Widget _buildActivityTab() {
    if (_activities.isEmpty) {
      return const Center(child: Text('Chưa có hoạt động nào', style: TextStyle(color: Colors.grey)));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _activities.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final activity = _activities[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
          leading: CircleAvatar(
            radius: 18,
            child: Text(
              activity.user?.fullName.isNotEmpty == true ? activity.user!.fullName[0].toUpperCase() : '?',
              style: const TextStyle(fontSize: 13),
            ),
          ),
          title: Text(
            '${activity.user?.fullName ?? activity.userId}: ${activity.action}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            DateFormatter.getRelativeTime(activity.createdAt),
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        );
      },
    );
  }
}
