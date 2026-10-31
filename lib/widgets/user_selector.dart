import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class UserSelector extends StatefulWidget {
  final Function(User) onUserSelected;
  final String? hintText;
  final List<String>? excludeUserIds;

  const UserSelector({
    super.key,
    required this.onUserSelected,
    this.hintText,
    this.excludeUserIds,
  });

  @override
  State<UserSelector> createState() => _UserSelectorState();
}

class _UserSelectorState extends State<UserSelector> {
  final TextEditingController _controller = TextEditingController();
  final UserService _userService = UserService();
  List<User> _results = [];
  bool _isLoading = false;
  bool _showDropdown = false;

  void _search(String q) async {
    if (q.trim().isEmpty) {
      setState(() {
        _results = [];
        _showDropdown = false;
      });
      return;
    }
    setState(() => _isLoading = true);
    try {
      final users = await _userService.searchUsers(q);
      final excluded = widget.excludeUserIds ?? [];
      setState(() {
        _results = users.where((u) => !excluded.contains(u.id)).toList();
        _showDropdown = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _showDropdown = false;
      });
    }
  }

  void _selectUser(User user) {
    _controller.clear();
    setState(() {
      _results = [];
      _showDropdown = false;
    });
    widget.onUserSelected(user);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: widget.hintText ?? 'Tìm kiếm người dùng...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _isLoading ? const SizedBox(width: 20, height: 20, child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2))) : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          ),
          onChanged: _search,
        ),
        if (_showDropdown && _results.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6, offset: const Offset(0, 3))],
            ),
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final user = _results[index];
                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 18,
                    child: Text(
                      user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  title: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text(user.email, style: const TextStyle(fontSize: 12)),
                  onTap: () => _selectUser(user),
                );
              },
            ),
          ),
        if (_showDropdown && _results.isEmpty && !_isLoading)
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('Không tìm thấy người dùng', style: TextStyle(color: Colors.grey)),
          ),
      ],
    );
  }
}
