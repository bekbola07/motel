
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/bed_space_service.dart';
import '../services/room_service.dart';

class ExpandableRoomTile extends StatefulWidget {
  final Room room;
  final VoidCallback onUpdate;

  const ExpandableRoomTile({Key? key, required this.room, required this.onUpdate}) : super(key: key);

  @override
  State<ExpandableRoomTile> createState() => _ExpandableRoomTileState();
}

class _ExpandableRoomTileState extends State<ExpandableRoomTile> {
  final BedSpaceService _bedSpaceService = BedSpaceService();
  final RoomService _roomService = RoomService();
  bool _isExpanded = false;

  Future<void> _showBedSpaceDialog({BedSpace? bedSpace, required String roomId}) async {
    final numberController = TextEditingController(text: bedSpace?.spaceNumber);
    final isEditing = bedSpace != null;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Joyni tahrirlash' : 'Joy qo\'shish'),
          content: TextField(
            controller: numberController,
            decoration: const InputDecoration(labelText: 'Joy raqami (masalan, A, B, 1, 2)'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Bekor qilish')),
            ElevatedButton(
              onPressed: () async {
                final number = numberController.text.trim();
                if (number.isNotEmpty) {
                  try {
                    if (isEditing) {
                      final updatedBedSpace = bedSpace.copyWith(spaceNumber: number);
                      await _bedSpaceService.updateBedSpace(updatedBedSpace);
                    } else {
                      await _bedSpaceService.addBedSpace(roomId, number);
                    }
                    setState(() {}); // Refresh bed space list
                    Navigator.of(context).pop();
                  } catch (e) {
                    // Handle error
                  }
                }
              },
              child: const Text('Saqlash'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        children: [
          ListTile(
            title: Text('Xona ${widget.room.number}'),
            subtitle: Text('Sig\'imi: ${widget.room.capacity} | ${widget.room.gender?.name ?? 'N/A'}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.edit), onPressed: () {}), // Placeholder for room edit
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await _roomService.deleteRoom(widget.room.id);
                    widget.onUpdate();
                  },
                ),
                IconButton(
                  icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () => setState(() => _isExpanded = !_isExpanded),
                ),
              ],
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () => _showBedSpaceDialog(roomId: widget.room.id),
                      icon: const Icon(Icons.add),
                      label: const Text('Joy qo\'shish'),
                    ),
                  ),
                  FutureBuilder<List<BedSpace>>(
                    future: _bedSpaceService.getBedSpaces(widget.room.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('Joylar topilmadi.'));
                      }
                      final bedSpaces = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: bedSpaces.length,
                        itemBuilder: (context, index) {
                          final bedSpace = bedSpaces[index];
                          return ListTile(
                            title: Text('Joy ${bedSpace.spaceNumber}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _showBedSpaceDialog(bedSpace: bedSpace, roomId: widget.room.id),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () async {
                                    await _bedSpaceService.deleteBedSpace(bedSpace.id);
                                    setState(() {}); // Refresh bed space list
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
