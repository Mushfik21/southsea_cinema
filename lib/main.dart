import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/views/basket_view.dart';
import 'package:southsea_cinema/views/home_view.dart';
import 'package:southsea_cinema/views/settings_view.dart';

void main() {
  runApp(const SouthseaCinemaApp());
}

class SouthseaCinemaApp extends StatefulWidget {
  const SouthseaCinemaApp({super.key});

  @override
  State<SouthseaCinemaApp> createState() => _SouthseaCinemaAppState();
}

class _SouthseaCinemaAppState extends State<SouthseaCinemaApp> {
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();
  bool _darkMode = true;

  @override
  void initState() {
    super.initState();
    _loadDarkMode();
  }

  Future<void> _loadDarkMode() async {
    final bool? savedDarkMode = await _prefs.getBool(prefDarkMode);
    if (!mounted || savedDarkMode == null) {
      return;
    }
    setState(() {
      _darkMode = savedDarkMode;
    });
  }

  Future<void> _setDarkMode(bool value) async {
    setState(() {
      _darkMode = value;
    });
    await _prefs.setBool(prefDarkMode, value);
  }

  ThemeData _buildDarkTheme() {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: cinemaBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: cinemaBrand,
        brightness: Brightness.dark,
        primary: cinemaBrand,
        surface: cinemaSurface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: cinemaSurface,
        iconTheme: IconThemeData(color: cinemaBrand),
        titleTextStyle: cinemaHeaderStyle,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(color: cinemaSurface),
      drawerTheme: const DrawerThemeData(backgroundColor: cinemaBackground),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: cinemaLightBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: cinemaBrand,
        brightness: Brightness.light,
        primary: cinemaBrandDark,
        surface: cinemaLightSurface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: cinemaBrandDark,
        iconTheme: IconThemeData(color: cinemaFontWhite),
        titleTextStyle: cinemaHeaderStyle,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(color: cinemaLightSurface),
      drawerTheme: const DrawerThemeData(
        backgroundColor: cinemaLightBackground,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Southsea Cinema & Arts Centre',
      debugShowCheckedModeBanner: false,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeView(),
        '/basket': (context) => const BasketView(),
        '/settings': (context) => SettingsView(
              darkMode: _darkMode,
              onDarkModeChanged: _setDarkMode,
            ),
      },
    );
  }
}
