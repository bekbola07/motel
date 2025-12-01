
import 'package:flutter/material.dart';
import '../models/models.dart';

class RoomList extends StatelessWidget {
  final List<Room> rooms;

  const RoomList({Key? key, required this.rooms}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        final room = rooms[index];
        return ListTile(
          title: Text('Room ${room.number}'),
          subtitle: Text('Capacity: ${room.capacity}'),
        );
      },
    );
  }
}
