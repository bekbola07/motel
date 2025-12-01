
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/dormitory_service.dart';
import '../screens/staff/room_management_screen.dart';

class DormitoryCrudScreen extends StatefulWidget {
  const DormitoryCrudScreen({Key? key}) : super(key: key);

  @override
  State<DormitoryCrudScreen> createState() => _DormitoryCrudScreenState();
}

class _DormitoryCrudScreenState extends State<DormitoryCrudScreen> {
  final DormitoryService _dormitoryService = DormitoryService();
  Future<List<Dormitory>>? _dormitoriesFuture;

  @override
  void initState() {
    super.initState();
    _refreshDormitories();
  }

  void _refreshDormitories() {
    setState(() {
      _dormitoriesFuture = _dormitoryService.getDormitories();
    });
  }

  Future<void> _showDormitoryDialog({Dormitory? dormitory}) async {
    final nameController = TextEditingController(text: dormitory?.name);
    final addressController = TextEditingController(text: dormitory?.address);
    final isEditing = dormitory != null;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Dormitory' : 'Add Dormitory'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final address = addressController.text.trim();

                if (name.isNotEmpty && address.isNotEmpty) {
                  try {
                    if (isEditing) {
                      final updatedDorm = dormitory.copyWith(name: name, address: address);
                      await _dormitoryService.updateDormitory(updatedDorm);
                    } else {
                      await _dormitoryService.addDormitory(name, address);
                    }
                    _refreshDormitories();
                    Navigator.of(context).pop();
                  } catch (e) {
                    // Handle error
                  }
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
    return Scaffold(
      body: FutureBuilder<List<Dormitory>>(
        future: _dormitoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No dormitories found.'));
          }

          final dormitories = snapshot.data!;
          return ListView.builder(
            itemCount: dormitories.length,
            itemBuilder: (context, index) {
              final dormitory = dormitories[index];
              return ListTile(
                title: Text(dormitory.name),
                subtitle: Text(dormitory.address),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => RoomManagementScreen(dormitory: dormitory),
                    ),
                  );
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit), onPressed: () => _showDormitoryDialog(dormitory: dormitory)),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await _dormitoryService.deleteDormitory(dormitory.id);
                        _refreshDormitories();
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDormitoryDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
