// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'home_screen.dart';
import 'constants.dart'; // Solo constantes aquí

void main() {
  runApp(const TriateApp());
}

class TriateApp extends StatelessWidget {
  const TriateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Triate | Orientación sanitaria',
      debugShowCheckedModeBanner: false,

      // 🌍 Idioma fijo: Español (España)
      locale: const Locale('es', 'ES'),
      supportedLocales: const [
        Locale('es', 'ES'),
      ],

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      theme: ThemeData(
        fontFamily: 'VarelaRound',
        scaffoldBackgroundColor: colorBackground,
      ),
      home: const HomeScreen(),
    );
  }
}
