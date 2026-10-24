import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final Future<void> Function(ThemeMode themeMode) _saveThemeMode;

  ThemeCubit({
    required ThemeMode initialThemeMode,
    required Future<void> Function(ThemeMode themeMode) saveThemeMode,
  }) : _saveThemeMode = saveThemeMode,
       super(initialThemeMode);

  Future<void> setThemeMode(ThemeMode themeMode) async {
    // Persiste la préférence avant d'émettre le nouvel état.
    await _saveThemeMode(themeMode);
    emit(themeMode);
  }
}
