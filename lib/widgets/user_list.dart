
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/admin_service.dart';

class UserList extends StatefulWidget {
  // The 'users' parameter is removed, making this widget self-contained.
  const UserList({Key? key}) : super(key: key);

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  final AdminService _adminService = AdminService();
  Future<List<User>>? _usersFuture;

  @override
  void initState() {
    super.initState();
    _refreshUsers();
  }

  void _refreshUsers() {
    setState(() {
      _usersFuture = _adminService.getUsers();
    });
  }

  Future<void> _showEditUserDialog(User user) async {
    final emailController = TextEditingController(text: user.email);
    final passwordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit ${user.email}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'New Password (optional)'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final newEmail = emailController.text.trim();
                final newPassword = passwordController.text.trim();

                try {
                  if (newEmail.isNotEmpty && newEmail != user.email) {
                    await _adminService.updateUserEmail(user.id, newEmail);
                  }
                  if (newPassword.isNotEmpty) {
                    await _adminService.updateUserPassword(user.id, newPassword);
                  }
                  _refreshUsers(); // This will now refetch the users and update the UI.
                  Navigator.of(context).pop();
                } catch (e) {
                  // Handle error
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<User>>(
      future: _usersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error.toString()}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No users found.'));
        }

        final users = snapshot.data!;
        return RefreshIndicator(
          onRefresh: () async => _refreshUsers(),
          child: ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                title: Text(user.email),
                subtitle: Text(user.role.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showEditUserDialog(user),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await _adminService.deleteUser(user.id);
                        _refreshUsers();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
