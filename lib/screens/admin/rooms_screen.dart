
import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/admin_service.dart';
import '../../services/dormitory_service.dart';
import '../../services/room_service.dart';
import '../../widgets/expandable_room_tile.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({Key? key}) : super(key: key);

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  final AdminService _adminService = AdminService();
  final DormitoryService _dormitoryService = DormitoryService();
  final RoomService _roomService = RoomService();
  Future<List<Room>>? _roomsFuture;

  @override
  void initState() {
    super.initState();
    _refreshRooms();
  }

  void _refreshRooms() {
    setState(() {
      _roomsFuture = _adminService.getRooms();
    });
  }

  Future<void> _showAddRoomDialog() async {
    final dorms = await _dormitoryService.getDormitories();
    if (!mounted || dorms.isEmpty) return;

    Dormitory? selectedDorm = dorms.first;
    final numberController = TextEditingController();
    final capacityController = TextEditingController();
    final featuresController = TextEditingController();
    RoomGender? selectedGender = RoomGender.MALE;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateInDialog) {
            return AlertDialog(
              title: const Text('Add New Room'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<Dormitory>(
                      value: selectedDorm,
                      items: dorms.map((dorm) {
                        return DropdownMenuItem(value: dorm, child: Text(dorm.name));
                      }).toList(),
                      onChanged: (value) {
                        setStateInDialog(() {
                          selectedDorm = value;
                        });
                      },
                      decoration: const InputDecoration(labelText: 'Select Dormitory'),
                    ),
                    TextField(
                      controller: numberController,
                      decoration: const InputDecoration(labelText: 'Room Number'),
                    ),
                    TextField(
                      controller: capacityController,
                      decoration: const InputDecoration(labelText: 'Capacity'),
                      keyboardType: TextInputType.number,
                    ),
                    DropdownButtonFormField<RoomGender>(
                      value: selectedGender,
                      items: RoomGender.values.map((gender) {
                        return DropdownMenuItem(value: gender, child: Text(gender.name));
                      }).toList(),
                      onChanged: (value) {
                        setStateInDialog(() {
                          selectedGender = value;
                        });
                      },
                      decoration: const InputDecoration(labelText: 'Gender'),
                    ),
                    TextField(
                      controller: featuresController,
                      decoration: const InputDecoration(labelText: 'Features (e.g. AC, WiFi)'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    final number = numberController.text.trim();
                    final capacity = int.tryParse(capacityController.text.trim());
                    final features = featuresController.text.trim();

                    if (selectedDorm != null && number.isNotEmpty && capacity != null && selectedGender != null) {
                      try {
                        await _roomService.addRoom(selectedDorm!.id, number, capacity, selectedGender!, features.isNotEmpty ? features : null);
                        _refreshRooms();
                        Navigator.of(context).pop();
                      } catch (e) {
                        // Handle error
                      }
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => _refreshRooms(),
        child: FutureBuilder<List<Room>>(
          future: _roomsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No rooms found. Add one to get started.'));
            }

            final rooms = snapshot.data!;
            return ListView.builder(
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final room = rooms[index];
                return ExpandableRoomTile(room: room, onUpdate: _refreshRooms);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRoomDialog,
        tooltip: 'Add Room',
        child: const Icon(Icons.add),
      ),
    );
  }
}
