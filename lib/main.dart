import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:guia_start/presentation/screens/auth/auth_wrapper.dart';
import 'package:guia_start/presentation/providers/app_state_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

// Habilitar la persisntencia offline
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  runApp(const GuiaStartApp());
}

class GuiaStartApp extends StatelessWidget {
  const GuiaStartApp({super.key});

// Colores GUIA
  static const Color _primaryOrange = Color(0xFFFF6F00);
  static const Color _secondaryOrange = Color(0xFFffA040);
  static const Color _darkBlue = Color(0xFF07007C);
  static const Color _backGroundGrey = Color(0xFFF5F5F5);
  static const Color _white = Colors.white;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppStateProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'GUIA Start',
        theme: _buildTheme(),
        home: const AuthWrapper(),
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: _backGroundGrey,
      colorScheme: const ColorScheme.light(
        primary: _primaryOrange,
        secondary: _secondaryOrange,
        tertiary: _darkBlue,
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: _darkBlue),
        bodyMedium: TextStyle(color: _darkBlue),
        titleLarge: TextStyle(color: _darkBlue),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: _primaryOrange,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _white,
        prefixIconColor: _primaryOrange,
        suffixIconColor: _primaryOrange,
        labelStyle: const TextStyle(fontSize: 14.0, color: _darkBlue),
        hintStyle: const TextStyle(fontSize: 14.0, color: _darkBlue),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 5.0,
          horizontal: 16.0,
        ),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: _primaryOrange,
            width: 1.0,
          ),
        ),
      ),
    );
  }
}
