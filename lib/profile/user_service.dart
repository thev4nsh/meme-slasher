import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class UserService {
  static final UserService instance = UserService._();
  UserService._();

  String? userId;
  String username = "";
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    if (userId == null) {
      userId = _generateId();
      await prefs.setString('userId', userId!);
    }
    username = prefs.getString('username') ?? "";
    _isInitialized = true;
  }

  Future<void> updateName(String newName) async {
    username = newName;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', newName);
  }

  // 🔥 HIGH SCORE MANAGEMENT
  Future<int> getHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('high_score') ?? 0;
  }

  Future<void> setHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('high_score', score);
  }

  String _generateId() {
    final r = Random();
    return "U${100000 + r.nextInt(900000)}";
  }
}