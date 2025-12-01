
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import 'database_service.dart';

class RoomService {
  final _dbService = DatabaseService.instance;
  final _uuid = const Uuid();

  Future<List<Room>> getRooms(String dormId) async {
    final db = await _dbService.database;
    final maps = await db.query(
      'rooms',
      where: 'dorm_id = ?',
      whereArgs: [dormId],
      orderBy: 'number ASC',
    );
    return maps.map((map) => Room.fromMap(map)).toList();
  }

  Future<List<BedSpace>> getBedSpaces(String roomId) async {
    final db = await _dbService.database;
    final maps = await db.query(
      'bed_spaces',
      where: 'room_id = ?',
      whereArgs: [roomId],
      orderBy: 'space_number ASC',
    );
    return maps.map((map) => BedSpace.fromMap(map)).toList();
  }

  Future<void> addRoom(String dormId, String number, int capacity, RoomGender gender, String? features) async {
    final db = await _dbService.database;
    final batch = db.batch();

    final roomId = _uuid.v4();
    final room = Room(
      id: roomId,
      dormId: dormId,
      number: number,
      capacity: capacity,
      gender: gender,
      features: features,
      createdAt: DateTime.now(),
    );
    batch.insert('rooms', room.toMap());

    for (var i = 0; i < capacity; i++) {
      final bedSpace = BedSpace(
        id: _uuid.v4(),
        roomId: roomId,
        spaceNumber: '${i + 1}',
        isOccupied: false,
        createdAt: DateTime.now(),
      );
      batch.insert('bed_spaces', bedSpace.toMap());
    }

    await batch.commit(noResult: true);
  }

  Future<void> updateRoom(Room room) async {
    final db = await _dbService.database;
    await db.update(
      'rooms',
      room.toMap(),
      where: 'id = ?',
      whereArgs: [room.id],
    );
  }

  Future<void> deleteRoom(String id) async {
    final db = await _dbService.database;
    // Note: This will cascade and delete bed spaces due to the FOREIGN KEY constraint
    await db.delete(
      'rooms',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
