import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/task_card.dart';
import '../../widgets/loading_view.dart';
import '../../utils/constants.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TaskService _taskService = TaskService();
  final NotificationService _notificationService = NotificationService();

  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  String _searchQuery = '';
  String? _filterStatus;
  String? _filterPriority;
  String _sortBy = 'createdAt';
  String _order = 'desc';

  int _unreadCount = 0;

  final List<String> _scopes = ['mine', 'assigned', 'shared'];
  final List<String> _tabLabels = ['Của tôi', 'Được giao', 'Được chia sẻ'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _loadTasks();
      }
    });
    _loadTasks();
    _loadUnreadCount();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String get _currentScope => _scopes[_tabController.index];

  Future<void> _loadTasks() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final tasks = await _taskService.getTasks(
        scope: _currentScope,
        status: _filterStatus,
        priority: _filterPriority,
        q: _searchQuery.isNotEmpty ? _searchQuery : null,
        sortBy: _sortBy,
        order: _order,
      );
      if (mounted) setState(() => _tasks = tasks);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadUnreadCount() async {
    try {
      final count = await _notificationService.getUnreadCount();
      if (mounted) setState(() => _unreadCount = count);
    } catch (_) {}
  }

  void _openFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        String? tempStatus = _filterStatus;
        String? tempPriority = _filterPriority;
        String tempSortBy = _sortBy;
        String tempOrder = _order;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Lọc & Sắp xếp', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Text('Trạng thái', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _filterChip('Tất cả', null, tempStatus, (v) => setModalState(() => tempStatus = v)),
                      _filterChip('Chưa làm', 'todo', tempStatus, (v) => setModalState(() => tempStatus = v)),
                      _filterChip('Đang làm', 'in_progress', tempStatus, (v) => setModalState(() => tempStatus = v)),
                      _filterChip('Hoàn thành', 'completed', tempStatus, (v) => setModalState(() => tempStatus = v)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text('Ưu tiên', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _filterChip('Tất cả', null, tempPriority, (v) => setModalState(() => tempPriority = v)),
                      _filterChip('Thấp', 'low', tempPriority, (v) => setModalState(() => tempPriority = v)),
                      _filterChip('Trung bình', 'medium', tempPriority, (v) => setModalState(() => tempPriority = v)),
                      _filterChip('Cao', 'high', tempPriority, (v) => setModalState(() => tempPriority = v)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text('Sắp xếp theo', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _filterChip('Ngày tạo', 'createdAt', tempSortBy, (v) => setModalState(() => tempSortBy = v ?? 'createdAt')),
                      _filterChip('Hạn hoàn thành', 'dueDate', tempSortBy, (v) => setModalState(() => tempSortBy = v ?? 'createdAt')),
                      _filterChip('Ưu tiên', 'priority', tempSortBy, (v) => setModalState(() => tempSortBy = v ?? 'createdAt')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Thứ tự: '),
                      ChoiceChip(
                        label: const Text('Mới nhất'),
                        selected: tempOrder == 'desc',
                        onSelected: (_) => setModalState(() => tempOrder = 'desc'),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Cũ nhất'),
                        selected: tempOrder == 'asc',
                        onSelected: (_) => setModalState(() => tempOrder = 'asc'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _filterStatus = null;
                              _filterPriority = null;
                              _sortBy = 'createdAt';
                              _order = 'desc';
                            });
                            Navigator.pop(ctx);
                            _loadTasks();
                          },
                          child: const Text('Đặt lại'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                          onPressed: () {
                            setState(() {
                              _filterStatus = tempStatus;
                              _filterPriority = tempPriority;
                              _sortBy = tempSortBy;
                              _order = tempOrder;
                            });
                            Navigator.pop(ctx);
                            _loadTasks();
                          },
                          child: const Text('Áp dụng'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _filterChip(String label, String? value, String? current, Function(String?) onSelected) {
    return ChoiceChip(
      label: Text(label),
      selected: current == value,
      onSelected: (_) => onSelected(value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Công việc'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () async {
                  await Navigator.pushNamed(context, '/notifications');
                  _loadUnreadCount();
                },
              ),
              if (_unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      _unreadCount > 99 ? '99+' : '$_unreadCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.person_outlined),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: _tabLabels.map((l) => Tab(text: l)).toList(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm công việc...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      isDense: true,
                    ),
                    onChanged: (v) {
                      _searchQuery = v;
                      _loadTasks();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.filter_list,
                    color: (_filterStatus != null || _filterPriority != null) ? Colors.indigo : null,
                  ),
                  tooltip: 'Lọc',
                  onPressed: _openFilter,
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: List.generate(3, (_) {
                if (_isLoading) return const LoadingView(message: 'Đang tải...');
                if (_errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 8),
                        Text(_errorMessage!, textAlign: TextAlign.center),
                        TextButton(onPressed: _loadTasks, child: const Text('Thử lại')),
                      ],
                    ),
                  );
                }
                if (_tasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text('Không có công việc nào', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: _loadTasks,
                  child: ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      final task = _tasks[index];
                      return TaskCard(
                        task: task,
                        onTap: () async {
                          await Navigator.pushNamed(context, '/task-detail', arguments: task.id);
                          _loadTasks();
                        },
                      );
                    },
                  ),
                );
              }),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        onPressed: () async {
          await Navigator.pushNamed(context, '/task-create');
          _loadTasks();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
