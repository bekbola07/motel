
import 'package:flutter/material.dart';
import 'package:motel/models/models.dart';
import 'package:motel/services/auth_service.dart';

class AppDrawer extends StatelessWidget {
  final Function(int) onItemTapped;

  const AppDrawer({Key? key, required this.onItemTapped}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService.instance.currentUser;

    List<Widget> drawerItems = [];

    if (currentUser != null) {
      switch (currentUser.role) {
        case UserRole.ADMIN:
          drawerItems.addAll([
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Users'),
              onTap: () => onItemTapped(0),
            ),
            ListTile(
              leading: const Icon(Icons.business),
              title: const Text('Dormitory Management'),
              onTap: () => onItemTapped(1),
            ),
            ListTile(
              leading: const Icon(Icons.king_bed),
              title: const Text('Rooms'),
              onTap: () => onItemTapped(2),
            ),
          ]);
          break;
        case UserRole.STAFF:
          drawerItems.addAll([
            ListTile(
              leading: const Icon(Icons.pending_actions),
              title: const Text('Pending Requests'),
              onTap: () => onItemTapped(0),
            ),
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text('Active Assignments'),
              onTap: () => onItemTapped(1),
            ),
            ListTile(
              leading: const Icon(Icons.business),
              title: const Text('Dormitory Management'),
              onTap: () => onItemTapped(2),
            ),
          ]);
          break;
        case UserRole.STUDENT:
          drawerItems.add(
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('My Dashboard'),
              onTap: () => onItemTapped(0),
            ),
          );
          break;
      }
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(currentUser?.role.name ?? 'User'),
            accountEmail: Text(currentUser?.email ?? 'No email'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                currentUser?.email.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(fontSize: 40.0),
              ),
            ),
          ),
          ...drawerItems,
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              AuthService.instance.logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
    );
  }
}
