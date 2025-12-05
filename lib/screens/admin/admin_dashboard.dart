
import 'package:flutter/material.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/dormitory_crud_screen.dart';
import '../../widgets/user_list.dart';
import 'rooms_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    UserList(), // Now self-contained, no need to pass users
    DormitoryCrudScreen(),
    RoomsScreen(),
  ];

  static const List<String> _titles = <String>[
    'Foydalanuvchilarni boshqarish',
    'Yotoqxonalarni boshqarish',
    'Xonalar va joylarni boshqarish',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.of(context).pop(); // Close the drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
      ),
      drawer: AppDrawer(onItemTapped: _onItemTapped),
      body: _widgetOptions.elementAt(_selectedIndex),
    );
  }
}
