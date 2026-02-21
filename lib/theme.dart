import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const _seedColorKey = 'seed_color';

  Color _seedColor = Colors.orangeAccent;

  Color get seedColor => _seedColor;

  ThemeProvider() {
    _loadSeedColor();
  }

  Future<void> _loadSeedColor() async {
    final prefs = await SharedPreferences.getInstance();
    final storedColor = prefs.getInt(_seedColorKey);

    if (storedColor != null) {
      _seedColor = Color(storedColor);
    }

    notifyListeners();
  }

  Future<void> setSeedColor(Color color) async {
    if (_seedColor == color) return;

    _seedColor = color;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_seedColorKey, color.toARGB32());
  }
}


ThemeData buildTheme({
  required Color seedColor,
  required Brightness brightness,
}) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: brightness,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
    textTheme: (brightness == Brightness.light
            ? ThemeData.light()
            : ThemeData.dark())
        .textTheme
        .apply(fontFamily: 'JetBrainsMono'),
  );
}
