
import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/room_service.dart';

class RoomManagementScreen extends StatefulWidget {
  final Dormitory dormitory;

  const RoomManagementScreen({Key? key, required this.dormitory}) : super(key: key);

  @override
  State<RoomManagementScreen> createState() => _RoomManagementScreenState();
}

class _RoomManagementScreenState extends State<RoomManagementScreen> {
  final RoomService _roomService = RoomService();
  Future<List<Room>>? _roomsFuture;

  @override
  void initState() {
    super.initState();
    _refreshRooms();
  }

  void _refreshRooms() {
    setState(() {
      _roomsFuture = _roomService.getRooms(widget.dormitory.id);
    });
  }

  Future<void> _showRoomDialog({Room? room}) async {
    final numberController = TextEditingController(text: room?.number);
    final capacityController = TextEditingController(text: room?.capacity.toString());
    final featuresController = TextEditingController(text: room?.features);
    RoomGender? selectedGender = room?.gender ?? RoomGender.MALE;
    final isEditing = room != null;

    await showDialog(
      context: context,
      builder: (context) {
        // Use a stateful builder to update the dropdown inside the dialog
        return StatefulBuilder(
          builder: (context, setStateInDialog) {
            return AlertDialog(
              title: Text(isEditing ? 'Xonani tahrirlash' : 'Xona qo\'shish'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: numberController,
                    decoration: const InputDecoration(labelText: 'Xona raqami'),
                  ),
                  TextField(
                    controller: capacityController,
                    decoration: const InputDecoration(labelText: 'Sig\'imi'),
                    keyboardType: TextInputType.number,
                    enabled: !isEditing, // Don't allow editing capacity
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
                    decoration: const InputDecoration(labelText: 'Jinsi'),
                  ),
                  TextField(
                    controller: featuresController,
                    decoration: const InputDecoration(labelText: 'Qulayliklar (masalan, Konditsioner, WiFi)'),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Bekor qilish')),
                ElevatedButton(
                  onPressed: () async {
                    final number = numberController.text.trim();
                    final capacity = int.tryParse(capacityController.text.trim());
                    final features = featuresController.text.trim();

                    if (number.isNotEmpty && capacity != null && selectedGender != null) {
                      try {
                        if (isEditing) {
                          final updatedRoom = room.copyWith(
                            number: number,
                            gender: selectedGender,
                            features: features.isNotEmpty ? features : null,
                          );
                          await _roomService.updateRoom(updatedRoom);
                        } else {
                          await _roomService.addRoom(widget.dormitory.id, number, capacity, selectedGender!, features.isNotEmpty ? features : null);
                        }
                        _refreshRooms();
                        Navigator.of(context).pop();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xatolik: $e')));
                      }
                    }
                  },
                  child: const Text('Saqlash'),
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
      appBar: AppBar(
        title: Text('`${widget.dormitory.name}`dagi xonalar'),
      ),
      body: FutureBuilder<List<Room>>(
        future: _roomsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Xatolik: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Xonalar topilmadi. Boshlash uchun yangi xona qo\'shing.'));
          }

          final rooms = snapshot.data!;
          return ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              return ListTile(
                title: Text('Xona ${room.number}'),
                subtitle: Text('Sig\'imi: ${room.capacity} | ${room.gender?.name ?? 'N/A'}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showRoomDialog(room: room),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await _roomService.deleteRoom(room.id);
                        _refreshRooms();
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
        onPressed: () => _showRoomDialog(),
        tooltip: 'Xona qo\'shish',
        child: const Icon(Icons.add),
      ),
    );
  }
}
