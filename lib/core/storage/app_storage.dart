import 'package:hive_flutter/hive_flutter.dart';

class AppStorage {
  static final AppStorage _instance = AppStorage._internal();
  factory AppStorage() => _instance;
  AppStorage._internal();

  static const String _authBoxName = 'auth_box';
  static const String _roleKey = 'user_role';

  late Box _authBox;

  // Initialize Hive and open the local storage box
  Future<void> init() async {
    await Hive.initFlutter();
    _authBox = await Hive.openBox(_authBoxName);
  }

  // Save the validated user role dynamically
  Future<void> saveUserRole(String role) async {
    await _authBox.put(_roleKey, role);
  }

  // Retrieve the stored user role from cache
  String? getUserRole() {
    return _authBox.get(_roleKey) as String?;
  }

  // Clear local session data during logout
  Future<void> clearAuthData() async {
    await _authBox.clear();
  }
}