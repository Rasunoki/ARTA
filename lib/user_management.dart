import 'package:flutter/material.dart';
import 'admin_scaffold.dart';
import 'src/mock_api.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  List<Map<String, String>> _users = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await MockApi.instance.fetchUsers();
      if (!mounted) return;
      setState(() {
        _users = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  String _query = '';

  List<Map<String, String>> get _filtered => _users.where((u) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return u.values.any((v) => v.toLowerCase().contains(q));
  }).toList();

  @override
  Widget build(BuildContext context) {
    final rows = _filtered;
    return AdminScaffold(
      selectedRoute: '/admin/users',
      onNavigate: (route) => Navigator.of(context).pushReplacementNamed(route),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height,
        ),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with Search
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'User Management',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 280,
                      height: 40,
                      child: TextField(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search, color: Colors.blue),
                          hintText: 'Search users by id, email, dept...',
                          filled: true,
                          fillColor: Colors.blue[50],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                        ),
                        onChanged: (v) => setState(() => _query = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Data Table
                    Expanded(
                      child: _loading
                          ? const Center(child: CircularProgressIndicator())
                          : _error != null
                              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Text('Failed to load users', style: TextStyle(color: Colors.red)), const SizedBox(height: 8), ElevatedButton(onPressed: _loadUsers, child: const Text('Retry'))]))
                              : SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: DataTable(
                                      columnSpacing: 20,
                                      dataRowMinHeight: 40,
                                      dataRowMaxHeight: 60,
                                      columns: const [
                                        DataColumn(label: Text('User ID', style: TextStyle(fontWeight: FontWeight.bold))),
                                        DataColumn(label: Text('User Role', style: TextStyle(fontWeight: FontWeight.bold))),
                                        DataColumn(label: Text('User Email', style: TextStyle(fontWeight: FontWeight.bold))),
                                        DataColumn(label: Text('Department', style: TextStyle(fontWeight: FontWeight.bold))),
                                        DataColumn(label: Text('Phone Number', style: TextStyle(fontWeight: FontWeight.bold))),
                                        DataColumn(label: Text('Access', style: TextStyle(fontWeight: FontWeight.bold))),
                                      ],
                                      rows: rows.map((u) => DataRow(
                                        cells: [
                                          DataCell(Text(u['id']!)),
                                          DataCell(Text(u['role']!)),
                                          DataCell(Text(u['email']!)),
                                          DataCell(Text(u['dept']!)),
                                          DataCell(Text(u['phone']!)),
                                          DataCell(
                                            IconButton(
                                              icon: const Icon(Icons.more_vert, size: 20),
                                              onPressed: () => _showUserActions(context, u['id']!),
                                            ),
                                          ),
                                        ],
                                      )).toList(),
                                    ),
                                  ),
                                ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showUserActions(BuildContext context, String userId) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'User Actions: $userId',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _actionButton('Edit User', Icons.edit, Colors.blue, () {
              Navigator.pop(context);
              _showEditUserDialog(context, userId);
            }),
            _actionButton('Reset Password', Icons.lock_reset, Colors.orange, () {
              Navigator.pop(context);
              _showResetPasswordDialog(context, userId);
            }),
            _actionButton('Deactivate User', Icons.person_off, Colors.red, () {
              Navigator.pop(context);
              _showDeactivateDialog(context, userId);
            }),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(String text, IconData icon, Color color, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(text, style: const TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(backgroundColor: color),
      ),
    );
  }

  void _showEditUserDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit User'),
        content: const Text('User editing functionality would be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('User $userId updated successfully')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showResetPasswordDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: const Text('Are you sure you want to reset the password for this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Password reset for $userId')),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showDeactivateDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate User'),
        content: const Text('Are you sure you want to deactivate this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('User $userId deactivated')),
              );
            },
            child: const Text('Deactivate', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}