import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logi_marketplace/core/theme/theme_cubit.dart';

void main() {
  test('persists a theme change before emitting it', () async {
    ThemeMode? savedThemeMode;
    final cubit = ThemeCubit(
      initialThemeMode: ThemeMode.light,
      saveThemeMode: (themeMode) async {
        savedThemeMode = themeMode;
      },
    );
    final emittedModes = <ThemeMode>[];
    final subscription = cubit.stream.listen(emittedModes.add);

    await cubit.setThemeMode(ThemeMode.dark);
    await Future<void>.delayed(Duration.zero);

    expect(savedThemeMode, ThemeMode.dark);
    expect(cubit.state, ThemeMode.dark);
    expect(emittedModes, [ThemeMode.dark]);

    await subscription.cancel();
    await cubit.close();
  });

  test('does not emit if persisting a theme change fails', () async {
    final cubit = ThemeCubit(
      initialThemeMode: ThemeMode.light,
      saveThemeMode: (_) async => throw StateError('write failed'),
    );

    await expectLater(
      cubit.setThemeMode(ThemeMode.dark),
      throwsA(isA<StateError>()),
    );
    expect(cubit.state, ThemeMode.light);

    await cubit.close();
  });
}
