import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00695C)),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF00695C),
    foregroundColor: Colors.white,
    centerTitle: true,
  ),
  textTheme: const TextTheme(
    titleMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
    bodyMedium: TextStyle(fontSize: 14, height: 1.6),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
);
