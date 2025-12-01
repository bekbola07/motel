
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import 'database_service.dart';

class BedSpaceService {
  final _dbService = DatabaseService.instance;
  final _uuid = const Uuid();

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

  Future<void> addBedSpace(String roomId, String spaceNumber) async {
    final db = await _dbService.database;
    final bedSpace = BedSpace(
      id: _uuid.v4(),
      roomId: roomId,
      spaceNumber: spaceNumber,
      isOccupied: false,
      createdAt: DateTime.now(),
    );
    await db.insert('bed_spaces', bedSpace.toMap());
  }

  Future<void> updateBedSpace(BedSpace bedSpace) async {
    final db = await _dbService.database;
    await db.update(
      'bed_spaces',
      bedSpace.toMap(),
      where: 'id = ?',
      whereArgs: [bedSpace.id],
    );
  }

  Future<void> deleteBedSpace(String id) async {
    final db = await _dbService.database;
    await db.delete(
      'bed_spaces',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
