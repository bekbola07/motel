
import 'package:sqflite/sqflite.dart';
import '../models/models.dart';
import 'database_service.dart';

class StudentService {
  final _dbService = DatabaseService.instance;

  Future<Map<String, dynamic>> createStudent(Student student) async {
    final db = await _dbService.database;
    try {
      await db.insert(
        'students',
        student.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return {'success': true};
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        return {'success': false, 'message': 'A student with this email or student ID already exists.'};
      }
      return {'success': false, 'message': 'An unexpected database error occurred.'};
    } catch (e) {
      return {'success': false, 'message': 'An unexpected error occurred.'};
    }
  }

  Future<Student?> getStudentProfile(String studentId) async {
    final db = await _dbService.database;
    final maps = await db.query(
      'students',
      where: 'id = ?',
      whereArgs: [studentId],
    );
    if (maps.isNotEmpty) {
      return Student.fromMap(maps.first);
    } 
    return null;
  }

  Future<Assignment?> getActiveAssignment(String studentId) async {
    final db = await _dbService.database;
    final maps = await db.query(
      'assignments',
      where: 'student_id = ? AND status = ?',
      whereArgs: [studentId, 'ACTIVE'],
      orderBy: 'start_date DESC',
    );
    if (maps.isNotEmpty) {
      return Assignment.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Request>> getMyRequests(String studentId) async {
    final db = await _dbService.database;
    final maps = await db.query(
      'requests',
      where: 'student_id = ?',
      whereArgs: [studentId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Request.fromMap(map)).toList();
  }

  Future<void> createRequest(String studentId, int preferredCapacity, String note) async {
    final db = await _dbService.database;
    await db.insert('requests', {
      'id': 'req-${DateTime.now().millisecondsSinceEpoch}',
      'student_id': studentId,
      'preferred_capacity': preferredCapacity,
      'note': note,
      'status': 'PENDING',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
