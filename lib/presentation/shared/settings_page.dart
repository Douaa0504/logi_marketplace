import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/theme_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _selectTheme(
    BuildContext context,
    ThemeMode themeMode,
  ) async {
    try {
      await context.read<ThemeCubit>().setThemeMode(themeMode);
    } catch (error) {
      debugPrint('Unable to save theme preference: $error');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save the theme preference.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) => ListView(
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Light mode'),
              value: ThemeMode.light,
              groupValue: themeMode,
              onChanged: (value) {
                if (value != null) _selectTheme(context, value);
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark mode'),
              value: ThemeMode.dark,
              groupValue: themeMode,
              onChanged: (value) {
                if (value != null) _selectTheme(context, value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
