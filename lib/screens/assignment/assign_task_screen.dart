import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../models/user.dart';
import '../../services/task_share_service.dart';
import '../../widgets/user_selector.dart';
import '../../widgets/loading_view.dart';

class AssignTaskScreen extends StatefulWidget {
  const AssignTaskScreen({super.key});

  @override
  State<AssignTaskScreen> createState() => _AssignTaskScreenState();
}

class _AssignTaskScreenState extends State<AssignTaskScreen> {
  final TaskShareService _shareService = TaskShareService();

  Task? _task;
  List<User> _assignees = [];
  String? _primaryAssigneeId;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  void _init() {
    final task = ModalRoute.of(context)?.settings.arguments as Task?;
    if (task != null) {
      setState(() => _task = task);
      _loadAssignees(task);
    }
  }

  Future<void> _loadAssignees(Task task) async {
    setState(() => _isLoading = true);
    try {
      if (task.assignees != null && task.assignees!.isNotEmpty) {
        setState(() {
          _assignees = List.from(task.assignees!);
          _primaryAssigneeId = task.primaryAssigneeId;
        });
      } else {
        final assignees = await _shareService.getAssignees(task.id);
        if (mounted) {
          setState(() {
            _assignees = assignees;
            _primaryAssigneeId = task.primaryAssigneeId;
          });
        }
      }
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

  void _addAssignee(User user) {
    if (_assignees.any((u) => u.id == user.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Người dùng đã được thêm')),
      );
      return;
    }
    setState(() {
      _assignees.add(user);
      if (_assignees.length == 1) _primaryAssigneeId = user.id;
    });
  }

  void _removeAssignee(User user) {
    setState(() {
      _assignees.removeWhere((u) => u.id == user.id);
      if (_primaryAssigneeId == user.id) {
        _primaryAssigneeId = _assignees.isNotEmpty ? _assignees.first.id : null;
      }
    });
  }

  Future<void> _save() async {
    if (_task == null) return;

    setState(() => _isSaving = true);
    try {
      await _shareService.addAssignees(
        _task!.id,
        _assignees.map((u) => u.id).toList(),
        primaryAssigneeId: _primaryAssigneeId,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Giao việc thành công!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giao việc'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Lưu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
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
                  const Text('Thêm người thực hiện', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 10),
                  UserSelector(
                    onUserSelected: _addAssignee,
                    hintText: 'Tìm kiếm người dùng...',
                    excludeUserIds: _assignees.map((u) => u.id).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text('Danh sách người thực hiện', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 8),
                  if (_assignees.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('Chưa có người thực hiện', style: TextStyle(color: Colors.grey)),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: _assignees.length,
                        itemBuilder: (context, index) {
                          final user = _assignees[index];
                          final isPrimary = _primaryAssigneeId == user.id;
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(
                                  user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                                ),
                              ),
                              title: Row(
                                children: [
                                  Text(user.fullName),
                                  if (isPrimary) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.indigo.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.indigo.withOpacity(0.4)),
                                      ),
                                      child: const Text('Chính', style: TextStyle(fontSize: 11, color: Colors.indigo)),
                                    ),
                                  ],
                                ],
                              ),
                              subtitle: Text(user.email),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Radio<String>(
                                    value: user.id,
                                    groupValue: _primaryAssigneeId,
                                    onChanged: (v) => setState(() => _primaryAssigneeId = v),
                                    activeColor: Colors.indigo,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                    onPressed: () => _removeAssignee(user),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  if (_assignees.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '* Chọn Radio để đặt làm người phụ trách chính',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
