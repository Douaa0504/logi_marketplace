import 'package:hive_flutter/hive_flutter.dart';

class AppStorage {
  // Une instance partagée évite d'ouvrir plusieurs fois les mêmes boxes Hive.
  static final AppStorage _instance = AppStorage._internal();
  factory AppStorage() => _instance;
  AppStorage._internal();

  static const String _authBoxName = 'auth_box';
  static const String _settingsBoxName = 'settings_box';
  static const String _roleKey = 'user_role';
  static const String _themeModeKey = 'theme_mode';

  late Box _authBox;
  late Box _settingsBox;

  // Initialize Hive and open the local storage box
  Future<void> init() async {
    await Hive.initFlutter();
    _authBox = await Hive.openBox(_authBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
  }

  // Save the validated user role dynamically
  Future<void> saveUserRole(String role) async {
    await _authBox.put(_roleKey, role);
  }

  // Retrieve the stored user role from cache
  String? getUserRole() {
    return _authBox.get(_roleKey) as String?;
  }

  String? getThemeMode() {
    return _settingsBox.get(_themeModeKey) as String?;
  }

  Future<void> saveThemeMode(String themeMode) async {
    await _settingsBox.put(_themeModeKey, themeMode);
  }

  // Clear local session data during logout
  Future<void> clearAuthData() async {
    await _authBox.clear();
  }
}
