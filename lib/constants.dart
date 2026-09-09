// lib/constants.dart
import 'package:flutter/material.dart';

// 🎨 COLORES GLOBALES TRIATE
const Color colorBackground = Color(0xFF5285AB);
const Color colorBlue = Color(0xFF5285AB);
const Color colorBlueDark = Color(0xFF2B5778);
const Color colorGreen = Color(0xFF5FAB52);
const Color colorGreenDark = Color(0xFF32782B);
const Color colorGray = Color(0xFF8198AA);
const Color colorGrayDark = Color(0xFF53636F);
const Color colorRed = Color(0xFFE34242);
const Color colorRedDark = Color(0xFFC92929);
const Color colorYellow = Color(0xFFEFE16D);
const Color colorYellowDark = Color(0xFFB2A84D);
const Color colorOrange = Color(0xFFE38D42);
const Color colorOrangeDark = Color(0xFFBF7739);

Color colorWithOpacity(Color color, double opacity) {
  return Color.fromRGBO(
    (color.r * 255).round(),
    (color.g * 255).round(),
    (color.b * 255).round(),
    opacity,
  );
}