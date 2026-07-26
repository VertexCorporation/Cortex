import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Supported app theme identifiers.
abstract final class AppTheme {
  static const String light = 'light';
  static const String dark = 'dark';

  static const List<String> all = [light, dark];

  /// Maps legacy or unknown saved values to a supported theme.
  static String normalize(String? theme) {
    if (theme == dark) return dark;
    return light;
  }
}

class ThemeProvider extends ChangeNotifier {
  String _currentTheme;

  ThemeProvider(this._currentTheme) {
    _currentTheme = AppTheme.normalize(_currentTheme);
    AppColors.currentTheme = _currentTheme;
    updateSystemUIOverlayStyle();
  }

  String get currentTheme => _currentTheme;

  void changeTheme(String theme) async {
    final normalized = AppTheme.normalize(theme);
    if (_currentTheme == normalized) return;

    _currentTheme = normalized;
    AppColors.currentTheme = normalized;
    updateSystemUIOverlayStyle();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedTheme', normalized);
  }

  void updateSystemUIOverlayStyle() {
    final themeColors = AppColors.getThemeColors(_currentTheme);

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        statusBarColor: Colors.transparent,
        systemNavigationBarIconBrightness:
            themeColors.navigationBarIconBrightness,
        statusBarIconBrightness: themeColors.statusBarIconBrightness,
      ),
    );
  }
}

class ThemeColors {
  final Color primaryColor;
  final Color secondaryColor;
  final Color tertiaryColor;
  final Color quaternaryColor;
  final Color quinaryColor;
  final Color senaryColor;
  final Color septenaryColor;
  final Color background;
  final Color border;
  final Color premium;
  final Color navigationBarColor;
  final Color statusBarColor;
  final Brightness navigationBarIconBrightness;
  final Brightness statusBarIconBrightness;

  const ThemeColors({
    required this.primaryColor,
    required this.secondaryColor,
    required this.tertiaryColor,
    required this.quaternaryColor,
    required this.quinaryColor,
    required this.senaryColor,
    required this.septenaryColor,
    required this.background,
    required this.border,
    required this.premium,
    required this.navigationBarColor,
    required this.statusBarColor,
    required this.navigationBarIconBrightness,
    required this.statusBarIconBrightness,
  });
}

class AppColors {
  static String _currentTheme = AppTheme.light;

  static String get currentTheme => _currentTheme;

  static set currentTheme(String value) {
    _currentTheme = AppTheme.normalize(value);
    _cachedColors = _themeDefinitions[_currentTheme]!;
  }

  static const ThemeColors _light = ThemeColors(
    primaryColor: Color(0xFFF5F5F5),
    secondaryColor: Color(0xFFFAFAFA),
    tertiaryColor: Color(0xFF888888),
    quaternaryColor: Color(0xFFEEEEEE),
    quinaryColor: Color(0xFFBBBBBB),
    senaryColor: Color(0xFF888888),
    septenaryColor: Color(0xFFE57373),
    background: Color(0xFFFFFFFF),
    border: Color(0xFFE0E0E0),
    premium: Color(0xFFBDB0A0),
    navigationBarColor: Color(0xFFFFFFFF),
    statusBarColor: Colors.transparent,
    navigationBarIconBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.dark,
  );

  static const ThemeColors _dark = ThemeColors(
    primaryColor: Color(0xFF121212),
    secondaryColor: Color(0xFF0A0A0A),
    tertiaryColor: Color(0xFF9E9E9E),
    quaternaryColor: Color(0xFF1A1A1A),
    quinaryColor: Color(0xFF616161),
    senaryColor: Color(0xFF888888),
    septenaryColor: Color(0xFFCF6679),
    background: Color(0xFF000000),
    border: Color(0xFF2C2C2C),
    premium: Color(0xFFBDB0A0),
    navigationBarColor: Color(0xFF000000),
    statusBarColor: Colors.transparent,
    navigationBarIconBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.light,
  );

  static final Map<String, ThemeColors> _themeDefinitions = {
    AppTheme.light: _light,
    AppTheme.dark: _dark,
  };

  static Map<String, ThemeColors> get themeDefinitions => _themeDefinitions;

  static ThemeColors _cachedColors = _light;

  static ThemeColors getThemeColors(String theme) {
    return _themeDefinitions[AppTheme.normalize(theme)] ?? _light;
  }

  static Map<String, dynamic> getSystemUIOverlayStyleForTheme(String theme) {
    final themeColors = getThemeColors(theme);
    return {
      'navigationBarColor': themeColors.navigationBarColor,
      'statusBarColor': themeColors.statusBarColor,
      'navigationBarIconBrightness': themeColors.navigationBarIconBrightness,
      'statusBarIconBrightness': themeColors.statusBarIconBrightness,
    };
  }

  static Color get primaryColor => _cachedColors.primaryColor;

  static Color get secondaryColor => _cachedColors.secondaryColor;

  static Color get tertiaryColor => _cachedColors.tertiaryColor;

  static Color get quaternaryColor => _cachedColors.quaternaryColor;

  static Color get quinaryColor => _cachedColors.quinaryColor;

  static Color get senaryColor => _cachedColors.senaryColor;

  static Color get septenaryColor => _cachedColors.septenaryColor;

  static Color get background => _cachedColors.background;

  static Color get border => _cachedColors.border;

  static Color get premium => _cachedColors.premium;

  static Map<String, Map<String, dynamic>> get overlayStyles {
    return _themeDefinitions.map((key, value) => MapEntry(
          key,
          {
            'navigationBarColor': value.navigationBarColor,
            'statusBarColor': value.statusBarColor,
            'navigationBarIconBrightness': value.navigationBarIconBrightness,
            'statusBarIconBrightness': value.statusBarIconBrightness,
          },
        ));
  }

  static List<Color> get animatedBorderGradientColors => [
        const Color(0xFFC26868),
        const Color(0xFFC2A068),
        const Color(0xFFA8B568),
        const Color(0xFF68B58A),
        const Color(0xFF6882C2),
        const Color(0xFF8A68C2),
        const Color(0xFFC268B5),
        const Color(0xFFC26868),
      ];

  static Color darken(Color color, double amount) {
    final luminance = color.computeLuminance();
    final t = (luminance - 0.5) * 1000;
    final blendFactor = (t.sign + 1) / 2;
    final targetColor = Color.lerp(Colors.white, Colors.black, blendFactor)!;
    return Color.lerp(color, targetColor, amount)!;
  }

  static Color get shimmerBase => darken(background, 0.1);

  static Color get shimmerHighlight => darken(background, 0.02);
}
