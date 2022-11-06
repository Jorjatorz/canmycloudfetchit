import 'package:flutter/material.dart';

// Style data
const Color cBackgroundColor = Color.fromARGB(255, 24, 28, 34);
const Color cPrimaryColor = Color(0xFFEEEEEE);
const Color cHighlightColor = Color(0xFF533483);

ThemeData cDarkThemeData = ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Georgia',
    textTheme: const TextTheme(
        headlineLarge: TextStyle(
            fontSize: 62.0, fontWeight: FontWeight.bold, color: Colors.white),
        titleMedium: TextStyle(
            fontSize: 24.0, fontStyle: FontStyle.italic, color: Colors.white),
        titleSmall: TextStyle(
            fontSize: 20.0, fontStyle: FontStyle.italic, color: Colors.white),
        bodyMedium: TextStyle(fontSize: 16.0, color: Colors.white)),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            backgroundColor: cPrimaryColor,
            foregroundColor: cBackgroundColor,
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w900))));

// Sizes data
const double cDefaultWidth = 800;
