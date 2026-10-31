import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/statistics_service.dart';
import '../../models/user.dart';
import '../../widgets/loading_view.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final StatisticsService _statisticsService = StatisticsService();

  User? _currentUser;
  Map<String, dynamic>? _taskStats;
  Map<String, dynamic>? _deadlineStats;
  Map<String, dynamic>? _assignmentStats;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _authService.getCurrentUser();
      final taskStats = await _statisticsService.getTaskStats();
      final deadlineStats = await _statisticsService.getDeadlineStats();
      final assignmentStats = await _statisticsService.getAssignmentStats();

      if (mounted) {
        setState(() {
          _currentUser = user;
          _taskStats = taskStats['data'] is Map<String, dynamic> ? taskStats['data'] : taskStats;
          _deadlineStats = deadlineStats['data'] is Map<String, dynamic> ? deadlineStats['data'] : deadlineStats;
          _assignmentStats = assignmentStats['data'] is Map<String, dynamic> ? assignmentStats['data'] : assignmentStats;
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

  Future<void> _openEditProfileDialog() async {
    final nameController = TextEditingController(text: _currentUser?.fullName ?? '');
    final formKey = GlobalKey<FormState>();

    final updated = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Chỉnh sửa thông tin'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Họ và tên',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập họ tên' : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  await _authService.updateProfile(nameController.text.trim());
                  if (ctx.mounted) Navigator.pop(ctx, true);
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );

    if (updated == true) {
      _loadData();
    }
  }

  Future<void> _openChangePasswordDialog() async {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đổi mật khẩu'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu hiện tại',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập mật khẩu hiện tại' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu mới',
                  prefixIcon: Icon(Icons.lock_reset),
                ),
                validator: (v) {
                  if (v == null || v.length < 6) return 'Mật khẩu mới ít nhất 6 ký tự';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Xác nhận mật khẩu mới',
                  prefixIcon: Icon(Icons.check_circle_outline),
                ),
                validator: (v) {
                  if (v != newPasswordController.text) return 'Mật khẩu xác nhận không khớp';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  await _authService.changePassword(
                    oldPasswordController.text,
                    newPasswordController.text,
                  );
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                  }
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đổi mật khẩu thành công!'), backgroundColor: Colors.green),
                    );
                  }
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              }
            },
            child: const Text('Đổi mật khẩu'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất tài khoản này không?'),
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
      await _authService.logout();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ & Thống kê'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm mới',
            onPressed: _loadData,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _currentUser == null) {
      return const LoadingView(message: 'Đang tải thông tin...');
    }

    if (_currentUser == null && _errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 12),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildUserCard(),
            const SizedBox(height: 16),
            _buildStatusStatisticsCard(),
            const SizedBox(height: 16),
            _buildDeadlineStatisticsCard(),
            const SizedBox(height: 16),
            _buildAssignmentStatisticsCard(),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Đăng xuất', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard() {
    final name = _currentUser?.fullName ?? 'Người dùng';
    final email = _currentUser?.email ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.indigo,
                  child: Text(
                    initial,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(email, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: _openEditProfileDialog,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Đổi tên'),
                ),
                Container(height: 20, width: 1, color: Colors.grey.shade300),
                TextButton.icon(
                  onPressed: _openChangePasswordDialog,
                  icon: const Icon(Icons.lock_outline, size: 18),
                  label: const Text('Đổi mật khẩu'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusStatisticsCard() {
    final byStatus = (_taskStats?['byStatus'] as Map?) ?? {};
    final todo = byStatus['todo'] ?? 0;
    final inProgress = byStatus['in_progress'] ?? 0;
    final completed = byStatus['completed'] ?? 0;
    final total = byStatus['total'] ?? (todo + inProgress + completed);
    final percent = total > 0 ? ((completed / total) * 100).toStringAsFixed(1) : '0';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tiến độ công việc',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '$percent% Hoàn thành',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: total > 0 ? (completed / total) : 0,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatTile('Cần làm', todo.toString(), Colors.blue),
                _buildStatTile('Đang làm', inProgress.toString(), Colors.orange),
                _buildStatTile('Hoàn thành', completed.toString(), Colors.green),
                _buildStatTile('Tổng số', total.toString(), Colors.indigo),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeadlineStatisticsCard() {
    final overdueObj = _deadlineStats?['overdue'];
    final overdueCount = (overdueObj is Map ? overdueObj['count'] : overdueObj) ?? 0;
    final dueSoon = (_deadlineStats?['dueSoon'] as Map?) ?? {};
    final in24h = dueSoon['in24Hours'] ?? 0;
    final in7d = dueSoon['in7Days'] ?? 0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hạn hoàn thành',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _buildStatTile('Quá hạn', overdueCount.toString(), Colors.red),
                _buildStatTile('Hạn trong 24h', in24h.toString(), Colors.deepOrange),
                _buildStatTile('Hạn trong 7 ngày', in7d.toString(), Colors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentStatisticsCard() {
    final created = _assignmentStats?['tasksCreated'] ?? 0;
    final assigned = _assignmentStats?['tasksAssignedToMe'] ?? 0;
    final shared = _assignmentStats?['tasksSharedWithMe'] ?? 0;
    final completedByMe = _assignmentStats?['tasksCompletedByMe'] ?? 0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Phân bổ công việc',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _buildStatTile('Việc đã tạo', created.toString(), Colors.indigo),
                _buildStatTile('Được giao', assigned.toString(), Colors.blue),
                _buildStatTile('Được chia sẻ', shared.toString(), Colors.teal),
                _buildStatTile('Đã làm xong', completedByMe.toString(), Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(String label, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
