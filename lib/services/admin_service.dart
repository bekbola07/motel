
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/models.dart';
import 'database_service.dart';

class AdminService {
  final _dbService = DatabaseService.instance;

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<List<User>> getUsers() async {
    final db = await _dbService.database;
    final maps = await db.query('users', orderBy: 'email ASC');
    return maps.map((map) => User.fromMap(map)).toList();
  }

  Future<List<Dormitory>> getDormitories() async {
    final db = await _dbService.database;
    final maps = await db.query('dormitories', orderBy: 'name ASC');
    return maps.map((map) => Dormitory.fromMap(map)).toList();
  }

  Future<List<Room>> getRooms() async {
    final db = await _dbService.database;
    final maps = await db.query('rooms', orderBy: 'number ASC');
    return maps.map((map) => Room.fromMap(map)).toList();
  }

  Future<void> updateUserEmail(String userId, String newEmail) async {
    final db = await _dbService.database;
    await db.update(
      'users',
      {'email': newEmail, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> updateUserPassword(String userId, String newPassword) async {
    final db = await _dbService.database;
    final passwordHash = _hashPassword(newPassword);
    await db.update(
      'users',
      {'password_hash': passwordHash, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> deleteUser(String userId) async {
    final db = await _dbService.database;
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
  }
}
