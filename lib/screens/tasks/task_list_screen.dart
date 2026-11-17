import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/task_card.dart';
import '../../widgets/loading_view.dart';

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
  int _unreadCount = 0;

  String _searchQuery = '';
  String? _filterStatus;
  String? _filterPriority;
  String _sortBy = 'createdAt';
  String _order = 'desc';

  final List<String> _scopes = ['created', 'assigned', 'shared'];
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

  Future<void> _loadUnreadCount() async {
    try {
      final count = await _notificationService.getUnreadCount();
      if (mounted) setState(() => _unreadCount = count);
    } catch (_) {}
  }

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

  void _openFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        String? tempStatus = _filterStatus;
        String? tempPriority = _filterPriority;
        String tempSortBy = _sortBy;
        String tempOrder = _order;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 16,
                right: 16,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Bộ lọc & Sắp xếp', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const Divider(),
                  const Text('Trạng thái', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: [
                      _filterChip('Tất cả', null, tempStatus, (v) => setModalState(() => tempStatus = v)),
                      _filterChip('Cần làm', 'todo', tempStatus, (v) => setModalState(() => tempStatus = v)),
                      _filterChip('Đang làm', 'in_progress', tempStatus, (v) => setModalState(() => tempStatus = v)),
                      _filterChip('Hoàn thành', 'completed', tempStatus, (v) => setModalState(() => tempStatus = v)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Mức ưu tiên', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: [
                      _filterChip('Tất cả', null, tempPriority, (v) => setModalState(() => tempPriority = v)),
                      _filterChip('Thấp', 'low', tempPriority, (v) => setModalState(() => tempPriority = v)),
                      _filterChip('Trung bình', 'medium', tempPriority, (v) => setModalState(() => tempPriority = v)),
                      _filterChip('Cao', 'high', tempPriority, (v) => setModalState(() => tempPriority = v)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Sắp xếp theo', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: [
                      _filterChip('Hạn hoàn thành', 'dueDate', tempSortBy, (v) => setModalState(() => tempSortBy = v ?? 'createdAt')),
                      _filterChip('Ngày tạo', 'createdAt', tempSortBy, (v) => setModalState(() => tempSortBy = v ?? 'createdAt')),
                      _filterChip('Mức ưu tiên', 'priority', tempSortBy, (v) => setModalState(() => tempSortBy = v ?? 'createdAt')),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text('Thứ tự: ', style: TextStyle(fontWeight: FontWeight.w600)),
                      ChoiceChip(
                        label: const Text('Giảm dần / Mới nhất'),
                        selected: tempOrder == 'desc',
                        onSelected: (_) => setModalState(() => tempOrder = 'desc'),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Tăng dần / Cũ nhất'),
                        selected: tempOrder == 'asc',
                        onSelected: (_) => setModalState(() => tempOrder = 'asc'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Quản lý công việc',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            FutureBuilder<String?>(
              future: AuthService().getCachedFullName(),
              builder: (context, snapshot) {
                final name = snapshot.data;
                if (name == null || name.isEmpty) return const SizedBox.shrink();
                return Text(
                  'Xin chào, $name',
                  style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.normal),
                  overflow: TextOverflow.ellipsis,
                );
              },
            ),
          ],
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm mới',
            onPressed: () {
              _loadTasks();
              _loadUnreadCount();
            },
          ),
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                tooltip: 'Thông báo',
                onPressed: () async {
                  await Navigator.pushNamed(context, '/notifications');
                  _loadUnreadCount();
                  _loadTasks();
                },
              ),
              if (_unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      _unreadCount > 99 ? '99+' : '$_unreadCount',
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.pie_chart_outline),
            tooltip: 'Thống kê & Cá nhân',
            onPressed: () async {
              await Navigator.pushNamed(context, '/profile');
              _loadTasks();
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: 'Tùy chọn',
            onSelected: (value) async {
              if (value == 'notifications') {
                await Navigator.pushNamed(context, '/notifications');
                _loadTasks();
              } else if (value == 'profile') {
                await Navigator.pushNamed(context, '/profile');
                _loadTasks();
              } else if (value == 'logout') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Đăng xuất'),
                    content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                        child: const Text('Đăng xuất'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await AuthService().logout();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                  }
                }
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                enabled: false,
                child: FutureBuilder<String?>(
                  future: AuthService().getCachedFullName(),
                  builder: (context, snapshot) => Text(
                    snapshot.data ?? 'Tài khoản',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                  ),
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'notifications',
                child: Row(
                  children: [
                    Icon(Icons.notifications_active_outlined, size: 20, color: Colors.indigo),
                    SizedBox(width: 8),
                    Text('Thông báo hệ thống'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline, size: 20, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Hồ sơ & Thống kê'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Đăng xuất', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
                    color: (_filterStatus != null || _filterPriority != null || _sortBy != 'createdAt')
                        ? Colors.indigo
                        : null,
                  ),
                  tooltip: 'Lọc & Sắp xếp',
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
                  final isAuthError = _errorMessage!.contains('401') ||
                      _errorMessage!.toLowerCase().contains('token') ||
                      _errorMessage!.toLowerCase().contains('unauthorized') ||
                      _errorMessage!.toLowerCase().contains('expired');
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isAuthError ? Icons.lock_clock_outlined : Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            isAuthError
                                ? 'Phiên đăng nhập đã hết hạn do đã lâu bạn chưa vào ứng dụng.\nVui lòng đăng nhập lại để tiếp tục.'
                                : _errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                          const SizedBox(height: 16),
                          if (isAuthError)
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              ),
                              onPressed: () async {
                                await AuthService().logout();
                                if (context.mounted) {
                                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                                }
                              },
                              icon: const Icon(Icons.login),
                              label: const Text('Đăng nhập lại'),
                            )
                          else
                            ElevatedButton.icon(
                              onPressed: _loadTasks,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Thử lại'),
                            ),
                        ],
                      ),
                    ),
                  );
                }
                if (_tasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Không tìm thấy công việc phù hợp'
                              : 'Chưa có công việc nào',
                          style: const TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: _loadTasks,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      final task = _tasks[index];
                      return TaskCard(
                        task: task,
                        onTap: () async {
                          await Navigator.pushNamed(context, '/task-detail', arguments: task.id);
                          _loadTasks();
                          _loadUnreadCount();
                        },
                        onEdit: task.isOwner
                            ? () async {
                                final updated = await Navigator.pushNamed(context, '/task-edit', arguments: task);
                                if (updated == true) {
                                  _loadTasks();
                                  _loadUnreadCount();
                                }
                              }
                            : null,
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
        foregroundColor: Colors.white,
        tooltip: 'Tạo công việc',
        child: const Icon(Icons.add),
        onPressed: () async {
          final created = await Navigator.pushNamed(context, '/task-create');
          if (created == true) {
            _loadTasks();
            _loadUnreadCount();
          }
        },
      ),
    );
  }
}
