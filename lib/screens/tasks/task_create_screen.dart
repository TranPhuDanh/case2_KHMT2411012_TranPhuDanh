import 'package:flutter/material.dart';
import '../../services/task_service.dart';
import '../../utils/validators.dart';
import '../../utils/constants.dart';

class TaskCreateScreen extends StatefulWidget {
  const TaskCreateScreen({super.key});

  @override
  State<TaskCreateScreen> createState() => _TaskCreateScreenState();
}

class _TaskCreateScreenState extends State<TaskCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final TaskService _taskService = TaskService();

  String _priority = AppConstants.priorityMedium;
  String _status = AppConstants.statusTodo;
  DateTime? _startDate;
  DateTime? _dueDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? now) : (_dueDate ?? now),
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _dueDate = picked;
        }
      });
    }
  }

  Future<void> _createTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await _taskService.createTask(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        startDate: _startDate,
        dueDate: _dueDate,
        priority: _priority,
        status: _status,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tạo công việc thành công!')),
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo công việc mới'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) => Validators.validateRequired(v, 'Tiêu đề'),
                maxLength: 200,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description_outlined),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                maxLength: 2000,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _priority,
                      decoration: const InputDecoration(
                        labelText: 'Ưu tiên',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'low', child: Text('Thấp')),
                        DropdownMenuItem(value: 'medium', child: Text('Trung bình')),
                        DropdownMenuItem(value: 'high', child: Text('Cao')),
                      ],
                      onChanged: (v) => setState(() => _priority = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _status,
                      decoration: const InputDecoration(
                        labelText: 'Trạng thái',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'todo', child: Text('Chưa làm')),
                        DropdownMenuItem(value: 'in_progress', child: Text('Đang làm')),
                        DropdownMenuItem(value: 'completed', child: Text('Hoàn thành')),
                      ],
                      onChanged: (v) => setState(() => _status = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: _datePicker('Ngày bắt đầu', _startDate, () => _pickDate(true))),
                  const SizedBox(width: 12),
                  Expanded(child: _datePicker('Hạn hoàn thành', _dueDate, () => _pickDate(false))),
                ],
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _createTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: _isLoading
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.add),
                  label: const Text('Tạo công việc', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _datePicker(String label, DateTime? date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                date != null ? '${date.day}/${date.month}/${date.year}' : label,
                style: TextStyle(
                  color: date != null ? Colors.black87 : Colors.grey,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (date != null)
              GestureDetector(
                onTap: () => setState(() {
                  if (label.contains('bắt đầu')) {
                    _startDate = null;
                  } else {
                    _dueDate = null;
                  }
                }),
                child: const Icon(Icons.close, size: 16, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}
