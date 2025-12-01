
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import 'database_service.dart';

class DormitoryService {
  final _dbService = DatabaseService.instance;
  final _uuid = const Uuid();

  Future<List<Dormitory>> getDormitories() async {
    final db = await _dbService.database;
    final maps = await db.query('dormitories', orderBy: 'name ASC');
    return maps.map((map) => Dormitory.fromMap(map)).toList();
  }

  Future<void> addDormitory(String name, String address) async {
    final db = await _dbService.database;
    final dormitory = Dormitory(
      id: _uuid.v4(),
      name: name,
      address: address,
      createdAt: DateTime.now(),
    );
    await db.insert('dormitories', dormitory.toMap());
  }

  Future<void> updateDormitory(Dormitory dormitory) async {
    final db = await _dbService.database;
    await db.update(
      'dormitories',
      dormitory.toMap(),
      where: 'id = ?',
      whereArgs: [dormitory.id],
    );
  }

  Future<void> deleteDormitory(String id) async {
    final db = await _dbService.database;
    await db.delete(
      'dormitories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
