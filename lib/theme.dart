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
        systemNavigationBarColor: Colors.transparent,
        // Enforce transparent for Edge-to-Edge
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
  static String _currentTheme = 'light';

  static String get currentTheme => _currentTheme;

  static set currentTheme(String value) {
    _currentTheme = value;
    _cachedColors = _themeDefinitions[value] ?? _themeDefinitions['light']!;
  }

  static final Map<String, ThemeColors> _themeDefinitions = {
    'light': ThemeColors(
      primaryColor: Colors.white,
      secondaryColor: const Color(0xFFF3F3F3),
      tertiaryColor: const Color(0xFF535353),
      quaternaryColor: const Color(0xFFEBEBEB),
      quinaryColor: const Color(0xA8000000),
      senaryColor: const Color(0xFF0D62FE),
      septenaryColor: const Color(0xFFFF322B),
      // Soft Red (was 0xFFFA2626)
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
      septenaryColor: const Color(0xFF6E1E1E),
      // Soft Red (was 0xFFD32F2F)
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
    'cyberpunk': ThemeColors(
      primaryColor: Colors.black,
      secondaryColor: const Color(0xFF0F0F1B),
      tertiaryColor: const Color(0xFFE92EFB),
      quaternaryColor: const Color(0xFF0C0C16),
      quinaryColor: Colors.white70,
      senaryColor: const Color(0xFFFF003C),
      septenaryColor: const Color(0xFFB026FF),
      background: const Color(0xFF05050A),
      border: const Color(0xFF1F1F35),
      premium: const Color(0xFF00FFCC),
      navigationBarColor: const Color(0xFF05050A),
      statusBarColor: Colors.transparent,
      navigationBarIconBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ),
    'sunset': ThemeColors(
      primaryColor: Colors.black,
      secondaryColor: const Color(0xFFD64933),
      tertiaryColor: const Color(0xFFFFB347),
      quaternaryColor: const Color(0xFF9E2A2B),
      quinaryColor: Colors.white70,
      senaryColor: const Color(0xFFE36414),
      septenaryColor: const Color(0xFF0F4C5C),
      background: const Color(0xFF540B0E),
      border: const Color(0xFFE07A5F),
      premium: const Color(0xFFFFD166),
      navigationBarColor: const Color(0xFF540B0E),
      statusBarColor: Colors.transparent,
      navigationBarIconBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ),
    'coffee': ThemeColors(
      primaryColor: Colors.black,
      secondaryColor: const Color(0xFF6F4E37),
      tertiaryColor: const Color(0xFFD4A373),
      quaternaryColor: const Color(0xFF5E3A21),
      quinaryColor: Colors.white70,
      senaryColor: const Color(0xFFA67C52),
      septenaryColor: const Color(0xFF8B5A2B),
      background: const Color(0xFF3E2723),
      border: const Color(0xFF8D6E63),
      premium: const Color(0xFFFAEDCD),
      navigationBarColor: const Color(0xFF3E2723),
      statusBarColor: Colors.transparent,
      navigationBarIconBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ),
    'deepSpace': ThemeColors(
      primaryColor: Colors.black,
      secondaryColor: const Color(0xFF14142B),
      tertiaryColor: const Color(0xFF5A5A8C),
      quaternaryColor: const Color(0xFF0C0C1C),
      quinaryColor: Colors.white70,
      senaryColor: const Color(0xFF333366),
      septenaryColor: const Color(0xFF4B4B80),
      background: const Color(0xFF050512),
      border: const Color(0xFF2E2E5D),
      premium: const Color(0xFF9999FF),
      navigationBarColor: const Color(0xFF050512),
      statusBarColor: Colors.transparent,
      navigationBarIconBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ),
  };

  static Map<String, ThemeColors> get themeDefinitions => _themeDefinitions;

  static ThemeColors _cachedColors = _themeDefinitions['light']!;

  static ThemeColors getThemeColors(String theme) {
    return _themeDefinitions[theme] ?? _themeDefinitions['light']!;
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

  // Accent color reserved for premium/subscription highlights.
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
