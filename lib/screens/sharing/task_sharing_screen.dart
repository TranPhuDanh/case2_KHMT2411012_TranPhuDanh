import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../models/task_share.dart';
import '../../models/user.dart';
import '../../services/task_share_service.dart';
import '../../widgets/user_selector.dart';
import '../../widgets/loading_view.dart';
import '../../utils/constants.dart';

class TaskSharingScreen extends StatefulWidget {
  const TaskSharingScreen({super.key});

  @override
  State<TaskSharingScreen> createState() => _TaskSharingScreenState();
}

class _TaskSharingScreenState extends State<TaskSharingScreen> {
  final TaskShareService _shareService = TaskShareService();

  Task? _task;
  List<TaskShare> _shares = [];
  bool _isLoading = true;
  String _selectedPermission = AppConstants.permissionViewer;
  User? _selectedUser;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  void _init() {
    final task = ModalRoute.of(context)?.settings.arguments as Task?;
    if (task != null) {
      setState(() => _task = task);
      _loadShares(task.id);
    }
  }

  Future<void> _loadShares(String taskId) async {
    setState(() => _isLoading = true);
    try {
      final shares = await _shareService.getShares(taskId);
      if (mounted) setState(() => _shares = shares);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addShare() async {
    if (_selectedUser == null || _task == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn người dùng')),
      );
      return;
    }
    if (_shares.any((s) => s.userId == _selectedUser!.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Người dùng đã được chia sẻ')),
      );
      return;
    }
    try {
      await _shareService.addShare(_task!.id, _selectedUser!.id, _selectedPermission);
      setState(() => _selectedUser = null);
      await _loadShares(_task!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chia sẻ thành công!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _updatePermission(TaskShare share, String newPermission) async {
    if (_task == null) return;
    try {
      await _shareService.updateShare(_task!.id, share.id, newPermission);
      await _loadShares(_task!.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _revokeShare(TaskShare share) async {
    if (_task == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thu hồi quyền'),
        content: Text('Thu hồi quyền truy cập của ${share.user?.fullName ?? share.userId}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Thu hồi'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await _shareService.deleteShare(_task!.id, share.id);
      await _loadShares(_task!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã thu hồi quyền')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chia sẻ công việc'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const LoadingView()
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_task != null) ...[
                    Text(
                      _task!.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                  ],
                  const Text('Thêm người chia sẻ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 10),
                  UserSelector(
                    onUserSelected: (user) => setState(() => _selectedUser = user),
                    hintText: 'Tìm kiếm người dùng...',
                    excludeUserIds: _shares.map((s) => s.userId).toList(),
                  ),
                  if (_selectedUser != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.indigo.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            child: Text(_selectedUser!.fullName.isNotEmpty ? _selectedUser!.fullName[0].toUpperCase() : '?'),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_selectedUser!.fullName)),
                          DropdownButton<String>(
                            value: _selectedPermission,
                            underline: const SizedBox(),
                            items: const [
                              DropdownMenuItem(value: 'viewer', child: Text('Xem')),
                              DropdownMenuItem(value: 'editor', child: Text('Sửa')),
                            ],
                            onChanged: (v) => setState(() => _selectedPermission = v!),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _addShare,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            child: const Text('Thêm'),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  const Text('Đã chia sẻ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 8),
                  if (_shares.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('Chưa chia sẻ với ai', style: TextStyle(color: Colors.grey)),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: _shares.length,
                        itemBuilder: (context, index) {
                          final share = _shares[index];
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(
                                  share.user?.fullName.isNotEmpty == true
                                      ? share.user!.fullName[0].toUpperCase()
                                      : '?',
                                ),
                              ),
                              title: Text(share.user?.fullName ?? share.userId),
                              subtitle: Text(share.user?.email ?? ''),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  DropdownButton<String>(
                                    value: share.permission,
                                    underline: const SizedBox(),
                                    items: const [
                                      DropdownMenuItem(value: 'viewer', child: Text('Xem')),
                                      DropdownMenuItem(value: 'editor', child: Text('Sửa')),
                                    ],
                                    onChanged: (v) {
                                      if (v != null && v != share.permission) {
                                        _updatePermission(share, v);
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                    onPressed: () => _revokeShare(share),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
