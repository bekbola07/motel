
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

import '../models/models.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;
  static const _dbVersion = 5; // Incremented for bed spaces

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('dormitory.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    var batch = db.batch();
    _createTables(batch);
    await _seedData(batch);
    await batch.commit(noResult: true);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      final tables = await db.query('sqlite_master', where: 'type = ?', whereArgs: ['table']);
      for (var table in tables) {
        final tableName = table['name'] as String;
        if (tableName != 'android_metadata' && tableName != 'sqlite_sequence') {
          await db.execute('DROP TABLE IF EXISTS $tableName');
        }
      }
      await _createDB(db, newVersion);
    }
  }

  void _createTables(Batch batch) {
    batch.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        role TEXT NOT NULL CHECK(role IN ('ADMIN', 'STAFF', 'STUDENT')),
        linked_student_id TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (linked_student_id) REFERENCES students(id)
      )
    ''');
    batch.execute('''
      CREATE TABLE students (
        id TEXT PRIMARY KEY,
        full_name TEXT NOT NULL,
        student_id TEXT UNIQUE NOT NULL,
        faculty TEXT NOT NULL,
        course TEXT NOT NULL,
        phone TEXT,
        email TEXT NOT NULL,
        photo_url TEXT,
        special_needs TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    batch.execute('''
      CREATE TABLE dormitories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        address TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    batch.execute('''
      CREATE TABLE rooms (
        id TEXT PRIMARY KEY,
        dorm_id TEXT NOT NULL,
        number TEXT NOT NULL,
        capacity INTEGER NOT NULL CHECK(capacity > 0),
        gender TEXT CHECK(gender IN ('MALE', 'FEMALE', 'MIXED')),
        features TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (dorm_id) REFERENCES dormitories(id) ON DELETE CASCADE
      )
    ''');
    batch.execute('''
      CREATE TABLE bed_spaces (
        id TEXT PRIMARY KEY,
        room_id TEXT NOT NULL,
        space_number TEXT NOT NULL,
        is_occupied INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (room_id) REFERENCES rooms(id) ON DELETE CASCADE
      )
    ''');
    batch.execute('''
      CREATE TABLE assignments (
        id TEXT PRIMARY KEY,
        student_id TEXT NOT NULL,
        bed_space_id TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT,
        status TEXT NOT NULL CHECK(status IN ('PENDING', 'ACTIVE', 'ENDED', 'CANCELLED')),
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
        FOREIGN KEY (bed_space_id) REFERENCES bed_spaces(id) ON DELETE CASCADE
      )
    ''');
    batch.execute('''
      CREATE TABLE requests (
        id TEXT PRIMARY KEY,
        student_id TEXT NOT NULL,
        preferred_capacity INTEGER,
        note TEXT,
        status TEXT NOT NULL CHECK(status IN ('PENDING', 'APPROVED', 'REJECTED')),
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _seedData(Batch batch) async {
    final uuid = const Uuid();

    // Users
    batch.insert('users', {
      'id': 'admin-001',
      'email': 'admin@dorm.edu',
      'password_hash': _hashPassword('admin123'),
      'role': 'ADMIN',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
    batch.insert('users', {
      'id': 'staff-001',
      'email': 'staff@dorm.edu',
      'password_hash': _hashPassword('staff123'),
      'role': 'STAFF',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
    const studentId = 'student-001';
    batch.insert('students', {
      'id': studentId,
      'full_name': 'Bekbola',
      'student_id': '2024001',
      'faculty': 'Computer Science',
      'course': 'Year 2',
      'email': 'student@dorm.edu',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
    batch.insert('users', {
      'id': 'user-student-001',
      'email': 'student@dorm.edu',
      'password_hash': _hashPassword('student123'),
      'role': 'STUDENT',
      'linked_student_id': studentId,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });

    // Dormitories, Rooms, and Bed Spaces
    final dormId = uuid.v4();
    batch.insert('dormitories', {
      'id': dormId,
      'name': 'North Hall',
      'address': '123 Campus Drive',
      'created_at': DateTime.now().toIso8601String(),
    });

    final rooms = [
      {'number': '101', 'capacity': 2, 'gender': 'MALE'},
      {'number': '102', 'capacity': 1, 'gender': 'FEMALE'},
    ];

    for (var roomData in rooms) {
      final roomId = uuid.v4();
      batch.insert('rooms', {
        'id': roomId,
        'dorm_id': dormId,
        'number': roomData['number'],
        'capacity': roomData['capacity'],
        'gender': roomData['gender'],
        'created_at': DateTime.now().toIso8601String(),
      });

      for (var i = 0; i < (roomData['capacity'] as int); i++) {
        batch.insert('bed_spaces', {
          'id': uuid.v4(),
          'room_id': roomId,
          'space_number': '${(i + 1)}',
          'is_occupied': 0,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    }
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
