import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ألوان الهوية البصرية لتطبيق جنبك
  static const Color primaryColor = Color(0xFFFF6B00); // البرتقالي الحيوي للسرعة والنشاط
  static const Color secondaryColor = Color(0xFF0F172A); // الأزرق البترولي الداكن للثقة والعناوين
  static const Color backgroundColor = Color(0xFFF8FAFC); // خلفية فاتحة نظيفة ومريحة
  static const Color cardColor = Color(0xFFFFFFFF); // أبيض ناصع للبطاقات
  static const Color textGrey = Color(0xFF64748B); // رمادي للنصوص الفرعية

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: cardColor,
      ),
      // تطبيق خط Cairo على كل النصوص في التطبيق تلقائياً
      textTheme: GoogleFonts.cairoTextTheme(
        ThemeData.light().textTheme,
      ).apply(
        bodyColor: secondaryColor,
        displayColor: secondaryColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: cardColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: secondaryColor),
        titleTextStyle: TextStyle(
          color: secondaryColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}