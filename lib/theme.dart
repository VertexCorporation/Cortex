import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  String _currentTheme;

  ThemeProvider(this._currentTheme) {
    AppColors.currentTheme = _currentTheme;
    updateSystemUIOverlayStyle();
  }

  String get currentTheme => _currentTheme;

  void changeTheme(String theme) async {
    if (_currentTheme == theme) return; // Prevent unnecessary notifications

    _currentTheme = theme;
    AppColors.currentTheme = theme;
    updateSystemUIOverlayStyle();
    notifyListeners(); // This is the ONLY place that should notify.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedTheme', theme);
  }

  // It's a side effect, not a state change that affects the UI tree.
  void updateSystemUIOverlayStyle() {
    final themeColors = AppColors.getThemeColors(_currentTheme);

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: themeColors.navigationBarColor,
        statusBarColor: themeColors.statusBarColor,
        systemNavigationBarIconBrightness: themeColors
            .navigationBarIconBrightness,
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
  static String currentTheme = '';

  static Map<String, ThemeColors> get themeDefinitions {
    return {
      'light': ThemeColors(
        primaryColor: Colors.white,
        secondaryColor: const Color(0xFFF3F3F3),
        tertiaryColor: const Color(0xFF535353),
        quaternaryColor: const Color(0xFFEBEBEB),
        quinaryColor: const Color(0xA8000000),
        senaryColor: const Color(0xFF0D62FE),
        septenaryColor: const Color(0xFFFA2626),
        background: const Color(0xFFFFFFFF),
        border: const Color(0xFFBFBFBF),
        premium: const Color(0xFF9900FF),
        navigationBarColor: Colors.white,
        statusBarColor: Colors.transparent,
        navigationBarIconBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
      ),
      'dark': ThemeColors(
        primaryColor: Colors.black,
        secondaryColor: const Color(0xFF181818),
        tertiaryColor: const Color(0xFF8F8F8F),
        quaternaryColor: const Color(0xFF141414),
        quinaryColor: Colors.white70,
        senaryColor: const Color(0xFF0D31FE),
        septenaryColor: const Color(0xFFD32F2F),
        background: const Color(0xFF090909),
        border: const Color(0xFF303030),
        premium: const Color(0xFFBB86FC),
        navigationBarColor: const Color(0xFF090909),
        statusBarColor: const Color(0xFF090909),
        navigationBarIconBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
      ),
      'love': ThemeColors(
        primaryColor: Colors.white,
        secondaryColor: const Color(0xFFFFC8D6),
        tertiaryColor: const Color(0xA8000000),
        quaternaryColor: const Color(0xFFffc2d1),
        quinaryColor: const Color(0xA8000000),
        senaryColor: const Color(0xfffb7088),
        septenaryColor: const Color(0xffff607d),
        background: const Color(0xFFffb3c6),
        border: const Color(0xFFFFE5EC),
        premium: const Color(0xFFF900D0),
        navigationBarColor: const Color(0xFFffb3c6),
        statusBarColor: Colors.transparent,
        navigationBarIconBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
      ),
      'nature': ThemeColors(
        primaryColor: Colors.black,
        secondaryColor: const Color(0xff225a41),
        tertiaryColor: const Color(0xff79b191),
        quaternaryColor: const Color(0xff204c3a),
        quinaryColor: Colors.white70,
        senaryColor: const Color(0xFF23852C),
        septenaryColor: const Color(0xFF388E3C),
        background: const Color(0xff16392a),
        border: const Color(0xff275a44),
        premium: const Color(0xFF00FF95),
        navigationBarColor: const Color(0xFF16392a),
        statusBarColor: Colors.transparent,
        navigationBarIconBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
      'behindTheSlaughter': ThemeColors(
        primaryColor: Colors.black,
        secondaryColor: const Color(0xFF5A189A),
        tertiaryColor: const Color(0xFFC77DFF),
        quaternaryColor: const Color(0xFF3C096C),
        quinaryColor: Colors.white70,
        senaryColor: const Color(0xFF9D4EDD),
        septenaryColor: const Color(0xFFE0AAFF),
        background: const Color(0xFF240046),
        border: const Color(0xFF4A00A0),
        premium: const Color(0xFF0A16FF),
        navigationBarColor: const Color(0xFF240046),
        statusBarColor: Colors.transparent,
        navigationBarIconBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
      ),
      'grayscale': ThemeColors(
        primaryColor: Colors.black,
        secondaryColor: const Color(0xFF4D5359),
        tertiaryColor: const Color(0xFF9DA3A9),
        quaternaryColor: const Color(0xFF36393D),
        quinaryColor: Colors.white70,
        senaryColor: const Color(0xFF707478),
        septenaryColor: const Color(0xFF373739),
        background: const Color(0xFF1F2225),
        border: const Color(0xFF4D5359),
        premium: const Color(0xFFE5E4E2),
        navigationBarColor: const Color(0xFF1F2225),
        statusBarColor: Colors.transparent,
        navigationBarIconBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
      ),
      'ocean': ThemeColors(
        primaryColor: Colors.black,
        secondaryColor: const Color(0xff0259a1),
        tertiaryColor: const Color(0xFFB0DFFF),
        quaternaryColor: const Color(0xff025395),
        quinaryColor: Colors.white70,
        senaryColor: const Color(0xFF1435BA),
        septenaryColor: const Color(0xFF135083),
        background: const Color(0xff013077),
        border: const Color(0xff68a0f1),
        premium: const Color(0xFF00E5FF),
        navigationBarColor: const Color(0xff013077),
        statusBarColor: Colors.transparent,
        navigationBarIconBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
      ),
      'scarletSnow': ThemeColors(
        primaryColor: Colors.black,
        secondaryColor: const Color(0xff771424),
        tertiaryColor: const Color(0xFFD19FA6),
        quaternaryColor: const Color(0xFF680018),
        quinaryColor: Colors.white70,
        senaryColor: const Color(0xFFBF002B),
        septenaryColor: const Color(0xFF950D21),
        background: const Color(0xFF4D0012),
        border: const Color(0xFFFD8686),
        premium: const Color(0xFFFF0777),
        navigationBarColor: const Color(0xFF4D0012),
        statusBarColor: Colors.transparent,
        navigationBarIconBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
      ),
    };
  }

  static ThemeColors getThemeColors(String theme) {
    return themeDefinitions[theme] ?? themeDefinitions['light']!;
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

  static Color get primaryColor => getThemeColors(currentTheme).primaryColor;

  static Color get secondaryColor =>
      getThemeColors(currentTheme).secondaryColor;

  static Color get tertiaryColor => getThemeColors(currentTheme).tertiaryColor;

  static Color get quaternaryColor =>
      getThemeColors(currentTheme).quaternaryColor;

  static Color get quinaryColor => getThemeColors(currentTheme).quinaryColor;

  static Color get senaryColor => getThemeColors(currentTheme).senaryColor;

  static Color get septenaryColor =>
      getThemeColors(currentTheme).septenaryColor;

  static Color get background => getThemeColors(currentTheme).background;

  static Color get border => getThemeColors(currentTheme).border;

  // Yeni Getter
  static Color get premium => getThemeColors(currentTheme).premium;

  static Map<String, Map<String, dynamic>> get overlayStyles {
    return themeDefinitions.map((key, value) =>
        MapEntry(
          key,
          {
            'navigationBarColor': value.navigationBarColor,
            'statusBarColor': value.statusBarColor,
            'navigationBarIconBrightness': value.navigationBarIconBrightness,
            'statusBarIconBrightness': value.statusBarIconBrightness,
          },
        ));
  }

  static List<Color> get animatedBorderGradientColors =>
      [
        Colors.red,
        Colors.orange,
        Colors.yellow,
        Colors.green,
        Colors.blue,
        Colors.indigo,
        Colors.purple,
        Colors.red,
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
