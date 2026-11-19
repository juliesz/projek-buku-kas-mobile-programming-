import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';

class FinoteApp extends StatefulWidget {
  const FinoteApp({super.key});

  @override
  State<FinoteApp> createState() => _FinoteAppState();
}

class _FinoteAppState extends State<FinoteApp> {
  bool _isDarkMode = false;

  void _setDarkMode(bool value) {
    setState(() => _isDarkMode = value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FINOTE',
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xffF5F7FB),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3F51B5),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: DashboardScreen(
        isDarkMode: _isDarkMode,
        onToggleDarkMode: _setDarkMode,
      ),
    );
  }
}