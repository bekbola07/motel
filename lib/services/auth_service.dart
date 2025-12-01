
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/models.dart';
import 'database_service.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService instance = AuthService._init();
  AuthService._init();

  final _uuid = const Uuid();
  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  // Add this method
  void setCurrentUser(User user) {
    _currentUser = user;
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required UserRole role,
    String? linkedStudentId,
  }) async {
    try {
      final db = await DatabaseService.instance.database;

      // Check if email already exists
      final existingUsers = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );

      if (existingUsers.isNotEmpty) {
        return {'success': false, 'message': 'Email already registered'};
      }

      final userId = _uuid.v4();
      final passwordHash = _hashPassword(password);

      final user = User(
        id: userId,
        email: email,
        passwordHash: passwordHash,
        role: role,
        linkedStudentId: linkedStudentId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await db.insert('users', user.toMap());

      return {'success': true, 'message': 'Registration successful', 'userId': userId};
    } catch (e) {
      return {'success': false, 'message': 'Registration failed: $e'};
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final db = await DatabaseService.instance.database;
      final passwordHash = _hashPassword(password);

      final users = await db.query(
        'users',
        where: 'email = ? AND password_hash = ?',
        whereArgs: [email, passwordHash],
      );

      if (users.isEmpty) {
        return {'success': false, 'message': 'Invalid email or password'};
      }

      _currentUser = User.fromMap(users.first);

      // Save session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user_id', _currentUser!.id);

      return {
        'success': true,
        'message': 'Login successful',
        'user': _currentUser,
      };
    } catch (e) {
      return {'success': false, 'message': 'Login failed: $e'};
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_id');
  }

  Future<bool> restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('current_user_id');

      if (userId == null) return false;

      final db = await DatabaseService.instance.database;
      final users = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );

      if (users.isEmpty) return false;

      _currentUser = User.fromMap(users.first);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> changePassword(
      String oldPassword,
      String newPassword,
      ) async {
    if (_currentUser == null) {
      return {'success': false, 'message': 'Not authenticated'};
    }

    try {
      final db = await DatabaseService.instance.database;
      final oldPasswordHash = _hashPassword(oldPassword);

      if (_currentUser!.passwordHash != oldPasswordHash) {
        return {'success': false, 'message': 'Incorrect old password'};
      }

      final newPasswordHash = _hashPassword(newPassword);

      await db.update(
        'users',
        {
          'password_hash': newPasswordHash,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [_currentUser!.id],
      );

      _currentUser = User(
        id: _currentUser!.id,
        email: _currentUser!.email,
        passwordHash: newPasswordHash,
        role: _currentUser!.role,
        linkedStudentId: _currentUser!.linkedStudentId,
        createdAt: _currentUser!.createdAt,
        updatedAt: DateTime.now(),
      );

      return {'success': true, 'message': 'Password changed successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Password change failed: $e'};
    }
  }
}
