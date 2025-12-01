
import '../models/models.dart';
import 'database_service.dart';

class StaffService {
  final _dbService = DatabaseService.instance;

  Future<List<Request>> getPendingRequests() async {
    final db = await _dbService.database;
    final maps = await db.query(
      'requests',
      where: 'status = ?',
      whereArgs: ['PENDING'],
      orderBy: 'created_at DESC',
    );
    if (maps.isEmpty) {
      return [];
    }
    return maps.map((map) => Request.fromMap(map)).toList();
  }

  Future<List<Assignment>> getActiveAssignments() async {
    final db = await _dbService.database;
    final maps = await db.query(
      'assignments',
      where: 'status = ?',
      whereArgs: ['ACTIVE'],
      orderBy: 'start_date DESC',
    );
    if (maps.isEmpty) {
      return [];
    }
    return maps.map((map) => Assignment.fromMap(map)).toList();
  }

  Future<List<BedSpace>> getAvailableBedSpaces(String roomId) async {
    final db = await _dbService.database;
    final maps = await db.query(
      'bed_spaces',
      where: 'room_id = ? AND is_occupied = 0',
      whereArgs: [roomId],
    );
    return maps.map((map) => BedSpace.fromMap(map)).toList();
  }

  Future<void> approveRequest(Request request, String bedSpaceId) async {
    final db = await _dbService.database;
    final batch = db.batch();

    batch.update(
      'requests',
      {'status': 'APPROVED', 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [request.id],
    );

    batch.insert('assignments', {
      'id': 'asgn-${DateTime.now().millisecondsSinceEpoch}',
      'student_id': request.studentId,
      'bed_space_id': bedSpaceId,
      'start_date': DateTime.now().toIso8601String(),
      'status': 'ACTIVE',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    batch.update(
      'bed_spaces',
      {'is_occupied': 1},
      where: 'id = ?',
      whereArgs: [bedSpaceId],
    );

    await batch.commit(noResult: true);
  }
}
