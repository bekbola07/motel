
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
              title: const Text('Foydalanuvchilar'),
              onTap: () => onItemTapped(0),
            ),
            ListTile(
              leading: const Icon(Icons.business),
              title: const Text('Yotoqxonalarni boshqarish'),
              onTap: () => onItemTapped(1),
            ),
            ListTile(
              leading: const Icon(Icons.king_bed),
              title: const Text('Xonalar'),
              onTap: () => onItemTapped(2),
            ),
          ]);
          break;
        case UserRole.STAFF:
          drawerItems.addAll([
            ListTile(
              leading: const Icon(Icons.pending_actions),
              title: const Text('Kutilayotgan so\'rovlar'),
              onTap: () => onItemTapped(0),
            ),
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text('Faol biriktirishlar'),
              onTap: () => onItemTapped(1),
            ),
            ListTile(
              leading: const Icon(Icons.business),
              title: const Text('Yotoqxonalarni boshqarish'),
              onTap: () => onItemTapped(2),
            ),
          ]);
          break;
        case UserRole.STUDENT:
          drawerItems.add(
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Mening boshqaruv panelim'),
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
            accountName: Text(currentUser?.role.name ?? 'Foydalanuvchi'),
            accountEmail: Text(currentUser?.email ?? 'Email yo\'q'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                currentUser?.email.substring(0, 1).toUpperCase() ?? 'F',
                style: const TextStyle(fontSize: 40.0),
              ),
            ),
          ),
          ...drawerItems,
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Chiqish'),
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
